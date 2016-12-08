//
//  BoletoViewController.m
//  Cardapio USP
//
//  Created by Vagner Machado on 06/12/16.
//  Copyright © 2016 EPUSP. All rights reserved.
//

#import "BoletoViewController.h"
#import "SVProgressHUD.h"

@interface BoletoViewController ()

@end

@implementation BoletoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  [SVProgressHUD showWithMaskType:SVProgressHUDMaskTypeBlack];
  //[SVProgressHUD setSuccessImage:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
  [SVProgressHUD showSuccessWithStatus:@"O boleto foi gerado e enviado para seu e-mail institucional"];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)dismiss:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)copyToPasteboard:(id)sender {
  [[UIPasteboard generalPasteboard] setString:_codBarrasLabel.text];
  [SVProgressHUD showSuccessWithStatus:@"copiado"];
}


@end
