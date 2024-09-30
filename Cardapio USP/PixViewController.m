//
//  PixViewController.m
//  Cardapio USP
//
//  Created by Vagner Machado on 26/10/22.
//  Copyright © 2022 USP. All rights reserved.
//

#import "PixViewController.h"
#import "BoletoDataModel.h"
#import "DataModel.h"
#import "SVProgressHUD.h"


@interface PixViewController () {
  BoletoDataModel *boletoDataModel;
  DataModel *dataModel;
}

@end

@implementation PixViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  
  boletoDataModel = [BoletoDataModel sharedInstance];
  dataModel = [DataModel getInstance];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(becomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didPaidPix:) name:@"DidPaidPix" object:nil];

  [self configureUI];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
}

#pragma mark - Selectors

- (IBAction)copyToPasteboard:(id)sender {
  [self copyToPB];
  [SVProgressHUD showSuccessWithStatus:@"copiado"];
}

- (IBAction)dismiss:(id)sender {
  [self dismissViewControllerAnimated:true completion:nil];
}

- (IBAction)share:(id)sender {
  
  NSString *valor = [[NSString stringWithFormat:@"%@", [boletoDataModel.pix valueForKey:@"vlrpix"]] stringByReplacingOccurrencesOfString:@"," withString:@"."];
  NSString *titulo = [[NSString stringWithFormat:@"R$ %.2f", [valor floatValue]] stringByReplacingOccurrencesOfString:@"." withString:@","];

  UIImage *image = [UIImage imageWithCIImage:_qrCodePix.image.CIImage];
  NSData *data = UIImageJPEGRepresentation (image, 0.8);
  NSArray *activityItems = @[data];

  UIActivityViewController *activityViewControntroller = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
  [activityViewControntroller setValue:@"Código QR para pagamento Pix/RUCard" forKey:@"subject"];
  activityViewControntroller.excludedActivityTypes = @[];
  [self presentViewController:activityViewControntroller animated:true completion:nil];
  
}


#pragma mark - Helpers

- (void)configureUI {
  NSString *valor = [[NSString stringWithFormat:@"%@", [boletoDataModel.pix valueForKey:@"vlrpix"]] stringByReplacingOccurrencesOfString:@"," withString:@"."];
  NSString *chave = [boletoDataModel.pix valueForKey:@"qrcpix"];
  
  // Valor
  if (valor != (id)[NSNull null] && valor.length > 0) {
    NSString *titulo = [[NSString stringWithFormat:@"R$ %.2f", [valor floatValue]] stringByReplacingOccurrencesOfString:@"." withString:@","];
    [_valorPix setText:titulo];
  } else {
    [_valorPix setText:@"R$ 0,00"];
  }
  
  // qrCode
  if (chave != nil && ![chave isEqualToString:@""]) {
      [_qrCodePix setImage:[UIImage imageWithCIImage:[self createQRForString:chave]]];
  } else {
      // Caso o QR code seja nulo ou inválido
      [_qrCodePix setImage:[UIImage systemImageNamed:@"qrcode"]];
      [SVProgressHUD showErrorWithStatus:@"Chave PIX inválida, tente novamente mais tarde"];
  }
  [self copyToPB];
}

- (CIImage *)createQRForString:(NSString *)qrString {
  if (qrString == nil || [qrString isEqualToString:@""]) {
    return nil; // Retorna nil caso a string seja nula ou inválida
  }
  
  NSData *stringData = [qrString dataUsingEncoding:NSISOLatin1StringEncoding];
  CIFilter *qrFilter = [CIFilter filterWithName:@"CIQRCodeGenerator"];
  [qrFilter setValue:stringData forKey:@"inputMessage"];
  
  CIImage *qrCodeImage = qrFilter.outputImage;
  CGAffineTransform transform = CGAffineTransformMakeScale(5.f, 5.f);
  return [qrCodeImage imageByApplyingTransform:transform];
}


- (void)copyToPB {
  [[UIPasteboard generalPasteboard] setString:[boletoDataModel.pix valueForKey:@"qrcpix"]];
}


#pragma mark - Notification

- (void)becomeActive:(NSNotification *)notification {
  [boletoDataModel checkPix:[boletoDataModel.pix valueForKey:@"idfpix"]];
}

- (void)didPaidPix:(NSNotification *)notification {
  dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 1.0 * NSEC_PER_SEC);
  dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    [self dismissViewControllerAnimated:true completion:^{
      [self->dataModel getCreditoRUCard];
    }];
  });
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/




@end
