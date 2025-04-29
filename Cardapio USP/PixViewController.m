//
//  PixViewController.m
//  Cardapio USP
//
//  Created by Vagner Machado on 26/10/22.
//  Copyright © 2022 USP. All rights reserved.
//

#import "PixViewController.h"
#import "CheckoutDataModel.h"
#import "DataModel.h"
#import "SVProgressHUD.h"


@interface PixViewController () {
  CheckoutDataModel *boletoDataModel;
  DataModel *dataModel;
}
@property (weak, nonatomic) IBOutlet UIBarButtonItem *shareButton;

@end

@implementation PixViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  
  boletoDataModel = [CheckoutDataModel sharedInstance];
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
  
  UIImage *image = nil;
  if (_qrCodePix.image.CIImage) {
    image = [UIImage imageWithCIImage:_qrCodePix.image.CIImage];
  }
  
  NSData *data = nil;
  if (image) {
    data = UIImageJPEGRepresentation(image, 0.8);
  }
  
  if (data) {
    NSArray *activityItems = @[data];
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
    [activityViewController setValue:@"Código QR para pagamento Pix/RUCard" forKey:@"subject"];
    activityViewController.excludedActivityTypes = @[];
    [self presentViewController:activityViewController animated:YES completion:nil];
  } else {
    NSLog(@"Erro: A imagem ou os dados do QR Code estão inválidos.");
    // Opcional: exiba um alerta para o usuário
  }
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
  if (chave != nil && ![chave isEqual:[NSNull null]] && ![chave isEqualToString:@""]) {
    [_qrCodePix setImage:[UIImage imageWithCIImage:[self createQRForString:chave]]];
    [self copyToPB];
    _qrCodePix.tintColor = nil;
    [_shareButton setEnabled:true];
    [_pasteboardButton setEnabled:true];
  } else {
    // Caso o QR code seja nulo ou inválido
    [_qrCodePix setImage:[UIImage systemImageNamed:@"qrcode"]];
    [_qrCodePix setAlpha:0.37];
    _qrCodePix.tintColor = [UIColor lightGrayColor];
    [SVProgressHUD showErrorWithStatus:@"Sistema temporariamente indisponível. Tente novamente mais tarde"];
    [_shareButton setEnabled:false];
    [_pasteboardButton setEnabled:false];
  }
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
  NSString *chave = [boletoDataModel.pix valueForKey:@"qrcpix"];
  if (chave != nil && ![chave isEqual:[NSNull null]] && ![chave isEqualToString:@""]) {
    [[UIPasteboard generalPasteboard] setString:chave];
  } else {
    [SVProgressHUD showInfoWithStatus:@"Sistema temporariamente indisponível. Tente novamente mais tarde"];
  }
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
