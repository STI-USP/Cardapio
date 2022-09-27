//
//  ThumbnailViewImageProxy.h
//  PxP
//
//  Created by Jun Okamoto on 26/03/12.
//  Copyright (c) 2012 EPUSP. All rights reserved.
//

#import <UIKit/UIKit.h>

/// Essa é uma classe auxiliar para carregar imagens
/// em background e libera a classe que a utiliza.

typedef enum {
  ThumbnailAspectFill,
  ThumbnailAspectKeepRatio,
  ThumbnailAspectZoom
} ThumbnailAspect;

typedef void (^ResponseBlock)(UIImage *image, NSError *error);

@interface ThumbnailViewImageProxy : UIView {
    
@protected
  NSString *_imagePath;
    
@private
  UIImage *_realImage;
  BOOL _loadingThreadHasLaunched;
  UIActivityIndicatorView *_activityIndicator;   // [jo:120328]
}

- (void)getImageWithCompletionHandler:(ResponseBlock)completionBlock;

@property (unsafe_unretained, nonatomic, readonly) UIImage *image;
@property (nonatomic, copy) NSString *imagePath;
@property (nonatomic) ThumbnailAspect aspect;      // [ga:120330] controle de aspect ratio
@property (nonatomic) BOOL hasBorders;             // [ga:120425] contorno tracejado opcional

@end
