//
//  CreditsViewController.m
//  Cardapio USP
//
//  Created by Vagner Machado on 05/12/16.
//  Copyright © 2016 EPUSP. All rights reserved.
//

#import "CreditsViewController.h"
#import "DataModel.h"
#import "SVProgressHUD.h"
#import "OAuthUSP.h"

@interface CreditsViewController () {
  DataModel *dataModel;
  OAuthUSP *oauth;
}

@end

@implementation CreditsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

  //Modelo
  dataModel = [DataModel getInstance];
  oauth = [OAuthUSP sharedInstance];
  
  [_gerarBoleto.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
  [_saldoLabel setText:@"Saldo do RUCard \n"];
  
  //Notificacoes
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecieveCredits:) name:@"DidReceiveCredits" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecieveCreditsError:) name:@"DidReceiveCreditsError" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];

  [dataModel getCreditoRUCard];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)didRecieveCredits:(NSNotification *)notification {
  
  NSMutableString *message = nil;
  
  if ([[dataModel ruCardCredit] integerValue] == 1) {
    message = [NSMutableString stringWithFormat: @"Saldo do RUCard \n1 crédito"];
  } else {
    message = [NSMutableString stringWithFormat: @"Saldo do RUCard \n%@ créditos", [dataModel ruCardCredit]];
  }
  
  [_saldoLabel setNumberOfLines:0];
  [_saldoLabel setLineBreakMode:NSLineBreakByWordWrapping];
  [_saldoLabel setText:message];
  
  UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
  [keyboardDoneButtonView sizeToFit];
  UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"   OK" style:UIBarButtonItemStylePlain target:self action:@selector(doneClicked:)];
  [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
  _maisCreditos.inputAccessoryView = keyboardDoneButtonView;
}


- (void)didRecieveCreditsError:(NSNotification *)notification {
  NSString *message = @"Não foi possível obter o saldo. \nTente novamente mais tarde.";
  [SVProgressHUD showErrorWithStatus:message];
}

- (IBAction)gerarBoleto:(id)sender {
  [self dismissViewControllerAnimated:NO completion:nil];
  [dataModel getBill];
}

- (IBAction)doneClicked:(id)sender {
  
  float valor = [_maisCreditos.text integerValue] * 1.90;
  [_valorLabel setText:[[NSString stringWithFormat: @"R$ %2.2f", valor] stringByReplacingOccurrencesOfString:@"." withString:@","]];
  
  [self.view endEditing:YES];
}

- (IBAction)logout:(id)sender {
  [oauth logout];
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)dismiss:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

@end
