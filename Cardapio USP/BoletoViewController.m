//
//  BoletoViewController.m
//  Cardapio USP
//
//  Created by Vagner Machado on 06/12/16.
//  Copyright © 2016 EPUSP. All rights reserved.
//

#import "BoletoViewController.h"
#import "SVProgressHUD.h"
#import "BoletoDataModel.h"
#import "DataModel.h"
#import "CreditsNavigationViewController.h"
#import "BoletosPendentesTableViewController.h"


@interface BoletoViewController () {
  BoletoDataModel *boletoDataModel;
  DataModel *dataModel;
}

@end

@implementation BoletoViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  boletoDataModel = [BoletoDataModel sharedInstance];
  dataModel = [DataModel getInstance];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didDeleteBill:) name:@"DidDeleteBill" object:nil];
  
  //Reveal View Controller ----------------
  SWRevealViewController *revealViewController = self.revealViewController;
  if (revealViewController) {
    [self.revealViewController panGestureRecognizer];
    [self.revealViewController tapGestureRecognizer];
    self.revealViewController.delegate = self;
  }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
  
  //show/hide OK Button
  NSLog(@"%@", [self.navigationController.viewControllers lastObject]);
  if ([[self.navigationController.viewControllers objectAtIndex:self.navigationController.viewControllers.count-2] isKindOfClass:[BoletosPendentesTableViewController class]])
    [_okButton setHidden:YES];
   else
    [_okButton setHidden:NO];
  

  NSString *valor = [boletoDataModel.boleto valueForKey:@"valor"];
  NSString *codBarras = [boletoDataModel.boleto valueForKey:@"codigoBarras"];
  NSString *vencimento = [boletoDataModel.boleto valueForKey:@"vencimento"];
  NSString *email = [boletoDataModel.boleto valueForKey:@"email"];
  
  if (valor != (id)[NSNull null])
    [_valorLabel setText:[NSString stringWithFormat:@"R$ %@", valor]];
  else
    [_valorLabel setText:@"R$ 0,00"];

  
  if (codBarras != (id)[NSNull null])
    [_codBarrasLabel setText:codBarras];
  else
    [_codBarrasLabel setText:@""];
  
  if (vencimento != (id)[NSNull null])
    [_vencimentoLabel setText:[NSString stringWithFormat:@"vencimento em %@", vencimento]];
  else
    [_vencimentoLabel setText:@""];
  
  [_emailTxt setText:@""];
  if (email != (id)[NSNull null])
    if (email) {
      [_emailTxt setText:[NSString stringWithFormat:@"Uma cópia do boleto foi enviado para o email %@", email]];
    }
  [_emailTxt sizeToFit];

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

//- (IBAction)deleteBill:(id)sender {
//  [boletoDataModel deleteBill];
//}

- (void)didDeleteBill:(NSNotification *)notification {

  [SVProgressHUD dismiss];
  if ([self.parentViewController isKindOfClass:[CreditsNavigationViewController class]]) {
    [self.navigationController popViewControllerAnimated:YES];
  } else {
    [self dismissViewControllerAnimated:YES completion:nil];
  }
}

#pragma mark - SWRevealViewControllerDelegate

// Implement this to return NO when you want the pan gesture recognizer to be ignored
- (BOOL)revealControllerPanGestureShouldBegin:(SWRevealViewController *)revealController {
  return NO;
}

@end
