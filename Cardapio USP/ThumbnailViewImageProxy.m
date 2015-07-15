//
//  ThumbnailViewImageProxy.m
//  PxP
//
//  Created by Jun Okamoto on 26/03/12.
//  Copyright (c) 2012 EPUSP. All rights reserved.
//
//  [jo:120328] autoreleasepool modificado para iOS5
//  [jo:120328] carrega imagem da Internet
//  [jo:120328] adicionado indicador de atividade
//  [jo:120330] carrega a imagem sem distorcer
//  [jo:120330] adicionado controle de zoom para evitar
//              tarjas pretas nas laterais se YES
//
//  [ga:120401] união das classes ThumbnailView e ThumbnailViewImageProxy
//  [ga:120425] contorno tracejado opcional
//  [jo:120426] dealloc removido para funcionar com ARC

#import "ThumbnailViewImageProxy.h"

@interface ThumbnailViewImageProxy ()

- (void)forwadImageLoadingThread;

@end

@implementation ThumbnailViewImageProxy

@synthesize image;
@synthesize imagePath = _imagePath;
@synthesize aspect;
@synthesize hasBorders;

// Clients can use this method directly to forward-load a real image
// if there is no need to show this object on a view
- (UIImage *)image {
  if (_realImage == nil) {
    //  // [jo:120328] originalmente, lê imagem de arquivo
    //  _realImage = [[UIImage alloc] initWithContentsOfFile:_imagePath];
    // [jo:120328] alterado para pegar imagem da Internet
    NSURL *url = [NSURL URLWithString:_imagePath];
    NSData *imageData = [NSData dataWithContentsOfURL:url];
    _realImage = [[UIImage alloc] initWithData:imageData]; // obs: método de convêniênica não funciona
  }
  return _realImage;
}

// A foward call will be established in a separate thread to get
// a real payload from a real image.
// Before a real payload is returned, drawRecr: will handle the background
// loading process and draw a placeholder frame.
// Once the real payload is loaded, it will redraw itself with the real one.
- (void)drawRect:(CGRect)rect {
  // if thre is no real image available from realImageView_,
  // then just draw a blank frame a a placeholder image
  if (_realImage == nil) {
    // Drawing code
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // [ga:120425] Contorno tracejado opcional
    // Draw a placeholder
    if (hasBorders) {
      CGContextSetLineWidth(context, 10.0);
      const CGFloat dashLengths[2] = {10,3};
      CGContextSetLineDash(context, 3, dashLengths, 2);
      CGContextSetStrokeColorWithColor(context, [[UIColor darkGrayColor] CGColor]);
    }
    
    CGContextSetFillColorWithColor(context, [[UIColor lightGrayColor] CGColor]);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context, kCGPathFillStroke);
    
    // [jo:120328] Indicador de atividade
    if (_activityIndicator == nil) {
      _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
      _activityIndicator.center = CGPointMake(rect.size.width/2., rect.size.height/2.);
      _activityIndicator.hidesWhenStopped = YES;
      [self addSubview:_activityIndicator];
      [_activityIndicator startAnimating];
    }
    
    // Launch a thread to load the real payload
    // if it hasn't done yet
    if (!_loadingThreadHasLaunched) {
      [self performSelectorInBackground:@selector(forwadImageLoadingThread) withObject:nil];
      _loadingThreadHasLaunched = YES;
    }
  } else {
    // otherwise pass the draw*: message along to realImage_ and
    // let it draw the real image
    
    // [ga:120330] Todo o laço 'else' abaixo foi substituído.
    // Há 3 modos de aspecto para ficar mais genérico e a qualidade da imagem não é reduzida.
    
    if (_activityIndicator != nil)
      [_activityIndicator stopAnimating];
    
    CGSize targetSize = rect.size;
    CGFloat targetRatio = targetSize.width / targetSize.height;
    
    CGSize imageSize = _realImage.size;
    CGFloat imageRatio = imageSize.width / imageSize.height;
    
    CGFloat delta = 0;
    
    switch (aspect) {
      case ThumbnailAspectFill:
        [_realImage drawInRect:rect];
        break;
        
      case ThumbnailAspectKeepRatio:
      {
        CGRect newRect;
        
        if (imageRatio > targetRatio) {
          // Adiciona barras horizontais
          delta = targetSize.height / targetSize.width * imageSize.width - imageSize.height;
          delta = delta * targetSize.width / imageSize.width;
          newRect = CGRectMake(0, delta / 2, targetSize.width, targetSize.height - delta);
        }
        else {
          // Adiciona barras verticais
          delta = targetSize.width / targetSize.height * imageSize.height - imageSize.width;
          delta = delta * targetSize.height / imageSize.height;
          newRect = CGRectMake(delta / 2, 0, targetSize.width - delta, targetSize.height);
        }
        [_realImage drawInRect:newRect];
      }
        break;
        
      case ThumbnailAspectZoom:
      {
        UIImage *zoomedImage = nil;
        CGImageRef imageRef = nil;
        
        if (imageRatio > targetRatio) {
          // A largura será encurtada
          delta = imageSize.width - targetSize.width / targetSize.height * imageSize.height;
          imageRef = CGImageCreateWithImageInRect([_realImage CGImage], CGRectMake(delta / 2, 0, imageSize.width - delta, imageSize.height));
        }
        else {
          // A altura será encurtada
          delta = imageSize.height - targetSize.height / targetSize.width * imageSize.width;
          imageRef = CGImageCreateWithImageInRect([_realImage CGImage], CGRectMake(0, delta / 2, imageSize.width, imageSize.height - delta));
        }
        
        zoomedImage = [UIImage imageWithCGImage:imageRef];
        [zoomedImage drawInRect:rect];
        CGImageRelease(imageRef);
      }
        break;
        
      default:
        [NSException raise:NSInvalidArgumentException format:@"Invalid ThumbnailViewImageProxy Aspect"];
        break;
    }
  }
}

// [jo:120426 removido para funcionar com ARC
//- (void)dealloc {
//    [_realImage release];
//    [_imagePath release];
//    [super dealloc];
//}

#pragma mark - A private method for an image forward loading thread

- (void)forwadImageLoadingThread {
  
  //  [jo:120328] antes de iOS5
  //  NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
  //
  //  // forward loading the real payload
  //  [self image];
  //
  //  // redraw itself with the newly loaded image
  //  [self performSelectorInBackground:@selector(setNeedsDisplay) withObject:nil];
  //
  //  [pool release];
  
  // [jo:120328] com iOS5
  @autoreleasepool {
    [self image];  // forward loading the real payload
    [self performSelectorInBackground:@selector(setNeedsDisplay) withObject:nil]; // redraw itself with the newly loaded image
  }
}

@end
