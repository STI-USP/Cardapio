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
#import "BoletoDataModel.h"
#import "BoletoViewController.h"
#import "LoginWebViewController.h"


@interface CreditsViewController () {
  DataModel *dataModel;
  BoletoDataModel *boletoDataModel;
  BoletoViewController *boletoViewController;
  OAuthUSP *oauth;
  LoginWebViewController *loginViewController;
  NSNumberFormatter *currencyFormatter;
}

@end

@implementation CreditsViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  
  [_username setText:@""];
  
  _maisCreditos.delegate = self;
  UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
  [keyboardDoneButtonView sizeToFit];
  UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"OK" style:UIBarButtonItemStylePlain target:self action:@selector(doneClicked:)];
  [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
  _maisCreditos.inputAccessoryView = keyboardDoneButtonView;
  
  currencyFormatter = [[NSNumberFormatter alloc] init];
  [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
  [currencyFormatter setMaximumSignificantDigits:9];
  [currencyFormatter setLenient:YES];
  [currencyFormatter setGeneratesDecimalNumbers:YES];
  
  //Modelo
  dataModel = [DataModel getInstance];
  boletoDataModel = [BoletoDataModel sharedInstance];
  oauth = [OAuthUSP sharedInstance];
  
  [_saldoLabel setText:@"R$ --,--"];
  
  //Notificacoes
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecieveCredits:) name:@"DidReceiveCredits" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecieveCreditsError:) name:@"DidReceiveCreditsError" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout:) name:@"DidReceiveLoginError" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCreateBill:) name:@"DidCreateBill" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveBill:) name:@"DidReceiveBill" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCreatePix:) name:@"DidCreatePix" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRegisterUser:) name:@"DidRegisterUser" object:nil];
  
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
  [super viewWillAppear:animated];
  
  if (![oauth isLoggedIn]) {
    loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginWebViewController"];
    [self presentViewController:loginViewController animated:YES completion:nil];
  } else {
    [dataModel getCreditoRUCard];
    [_username setText:[dataModel.userData objectForKey:@"nomeUsuario"]];
    //[self.navigationItem setTitle:[[[dataModel.userData objectForKey:@"nomeUsuario"] componentsSeparatedByString:@" "] objectAtIndex:0]];
  }
}

- (void)viewWillDisappear:(BOOL)animated {
  [self.navigationItem setTitle:@""];
}

- (void)doneClicked:(id)sender {
  [[self maisCreditos] resignFirstResponder];
  [self updateTextField];
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
  NSMutableString *message = [NSMutableString stringWithFormat: @"R$ %@", [dataModel ruCardCredit]];
  [_saldoLabel setNumberOfLines:0];
  [_saldoLabel setLineBreakMode:NSLineBreakByWordWrapping];
  [_saldoLabel setText:message];
  
  [_username setText:[dataModel.userData objectForKey:@"nomeUsuario"]];
}

- (void)didRecieveCreditsError:(NSNotification *)notification {
  NSString *message = @"Não foi possível obter o saldo. \nTente novamente mais tarde.";
  [SVProgressHUD showErrorWithStatus:message];
}

- (IBAction)visualizarBoleto:(id)sender {
  [SVProgressHUD show];
  [boletoDataModel getBoleto];
}

- (IBAction)listarBoletos:(id)sender {
  [boletoDataModel getBoletos];
}

- (IBAction)gerarNovoBoleto:(id)sender {
  if ([self validarValorRecarga:20]) {
    [boletoDataModel createBill];
  }
}

- (IBAction)gerarPix:(id)sender {
  if ([self validarValorRecarga:0]) {
    [SVProgressHUD show];
    [boletoDataModel createPix];
  }
}


- (BOOL)validarValorRecarga:(float)valorMinimo {
  [self updateTextField];
  [self.view endEditing:YES];
  
  NSString *numberString;
  NSScanner *scanner = [NSScanner scannerWithString:boletoDataModel.valorRecarga];
  NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789,."];
  
  [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
  [scanner scanCharactersFromSet:numbers intoString:&numberString];
  
  float valorRecarga = [numberString floatValue];
  if ((valorRecarga >= valorMinimo) && (valorRecarga <= 200)) {
    return true;
  } else {
    [SVProgressHUD showErrorWithStatus:@"Insira um valor entre R$ 20,00 e R$ 200,00"];
    return false;
  }
  
}


- (void)updateTextField {
  NSString *numberString;
  NSScanner *scanner = [NSScanner scannerWithString:_maisCreditos.text];
  NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789,."];
  [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
  [scanner scanCharactersFromSet:numbers intoString:&numberString];
  
  [_maisCreditos setText:numberString];
  [boletoDataModel setValorRecarga:[_maisCreditos text]];
  
  NSString *value = [[boletoDataModel valorRecarga]stringByReplacingOccurrencesOfString:@"," withString:@"."];
  [_maisCreditos setText:[[NSString stringWithFormat:@"R$ %.2f", [value floatValue]]stringByReplacingOccurrencesOfString:@"." withString:@","]];
}

- (void)clearTextField {
  [_maisCreditos setText:@""];
}


- (void)didCreateBill:(NSNotification *)notification {
  [SVProgressHUD dismiss];
  [self clearTextField];
  if (!boletoViewController) {
    boletoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"boletoViewController"];
  }
  [self presentViewController:boletoViewController animated:YES completion:nil];
}

- (void)didReceiveBill:(NSNotification *)notification {
  [SVProgressHUD dismiss];
  if (!boletoViewController) {
    boletoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"boletoViewController"];
  }
  [self presentViewController:boletoViewController animated:YES completion:nil];
}

- (void)didRegisterUser:(NSNotification *)notification {
  
  [SVProgressHUD dismiss];
  [dataModel getCreditoRUCard];
  
}

- (void)didCreatePix:(NSNotification *)notification {
  [SVProgressHUD dismiss];
  [self clearTextField];
  [self performSegueWithIdentifier:@"showPix" sender:self];
  
}




- (IBAction)logout:(id)sender {
  [oauth logout];
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - SWRevealViewControllerDelegate

// Implement this to return NO when you want the pan gesture recognizer to be ignored
- (BOOL)revealControllerPanGestureShouldBegin:(SWRevealViewController *)revealController {
  return NO;
}


#pragma mark - Text Field Delegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
  //validar valores
  [self updateTextField];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  NSString *replaced = [textField.text stringByReplacingCharactersInRange:range withString:string];
  NSDecimalNumber *amount = (NSDecimalNumber*) [currencyFormatter numberFromString:replaced];
  if (amount == nil) {
    // Something screwed up the parsing. Probably an alpha character.
    return NO;
  }
  // If the field is empty (the inital case) the number should be shifted to
  // start in the right most decimal place.
  short powerOf10 = 0;
  if ([textField.text isEqualToString:@""]) {
    powerOf10 = -currencyFormatter.maximumFractionDigits;
  }
  // If the edit point is to the right of the decimal point we need to do
  // some shifting.
  else if (range.location + currencyFormatter.maximumFractionDigits >= textField.text.length) {
    // If there's a range of text selected, it'll delete part of the number
    // so shift it back to the right.
    if (range.length) {
      powerOf10 = -range.length;
    }
    else if ([replaced length] > currencyFormatter.maximumSignificantDigits) {
      textField.text = replaced;
    }
    // Otherwise they're adding this many characters so shift left.
    else {
      powerOf10 = [string length];
    }
  }
  amount = [amount decimalNumberByMultiplyingByPowerOf10:powerOf10];
  
  // Replace the value and then cancel this change.
  textField.text = [currencyFormatter stringFromNumber:amount];
  return NO;
}
@end
