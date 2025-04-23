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
#import "CheckoutDataModel.h"
#import "BoletoViewController.h"
#import "LoginWebViewController.h"
#import "VMPix.h"

@interface CreditsViewController () {
  DataModel *dataModel;
  CheckoutDataModel *boletoDataModel;
  OAuthUSP *oauth;
  LoginWebViewController *loginViewController;
  NSNumberFormatter *currencyFormatter;
  BoletoViewController *boletoViewController;
  VMPix *pix;
}
@end

@implementation CreditsViewController

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setupModels];
  [self setupUI];
  [self registerNotifications];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self checkLoginStatus];
}

- (void)viewWillDisappear:(BOOL)animated {
  [self.navigationItem setTitle:@""];
  [super viewWillDisappear:animated];
}

- (void)dealloc {
  [self removeKeyboardNotifications];
}

#pragma mark - Setup

- (void)setupUI {
  _maisCreditos.delegate = self;
  _maisCreditos.inputAccessoryView = [self createKeyboardDoneButton];
  [_saldoLabel setText:@"R$ --,--"];
  currencyFormatter = [self createCurrencyFormatter];
}

- (void)setupModels {
  dataModel = [DataModel getInstance];
  boletoDataModel = [CheckoutDataModel sharedInstance];
  oauth = [OAuthUSP sharedInstance];
}

- (void)registerNotifications {
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecieveCredits:) name:@"DidReceiveCredits" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecieveCreditsError:) name:@"DidReceiveCreditsError" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(logout:) name:@"DidReceiveLoginError" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveBills:) name:@"DidReceiveBills" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCreatePix:) name:@"DidCreatePix" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveLastPix:) name:@"DidReceiveLastPix" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRegisterUser:) name:@"DidRegisterUser" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)removeKeyboardNotifications {
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
  [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

#pragma mark - UI Helpers

- (UIToolbar *)createKeyboardDoneButton {
  UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
  [keyboardDoneButtonView sizeToFit];
  UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"OK" style:UIBarButtonItemStylePlain target:self action:@selector(doneClicked:)];
  [doneButton setTintColor:[UIColor colorNamed:@"usp_green"]];
  [keyboardDoneButtonView setItems:@[doneButton]];
  return keyboardDoneButtonView;
}

- (NSNumberFormatter *)createCurrencyFormatter {
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
  [formatter setMaximumSignificantDigits:9];
  [formatter setLenient:YES];
  [formatter setGeneratesDecimalNumbers:YES];
  return formatter;
}

#pragma mark - Actions

- (IBAction)doneClicked:(id)sender {
  [_maisCreditos resignFirstResponder];
  [self updateTextField];
}

- (IBAction)gerarPix:(id)sender {
  if ([self validarValorRecarga:10]) {
    [SVProgressHUD show];
    [boletoDataModel createPix];
  }
}

- (IBAction)listarBoletos:(id)sender {
  //[boletoDataModel getBoletos];
}

- (IBAction)logout:(id)sender {
  [oauth logout];
  [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Validation

- (BOOL)validarValorRecarga:(float)valorMinimo {
  [self updateTextField];
  [self.view endEditing:YES];
  
  NSString *valorString = [_maisCreditos.text stringByReplacingOccurrencesOfString:@"R$" withString:@""];
  valorString = [valorString stringByReplacingOccurrencesOfString:@"." withString:@""];
  valorString = [valorString stringByReplacingOccurrencesOfString:@"," withString:@"."];
  
  float valorRecarga = [valorString floatValue];
  
  if (valorRecarga >= valorMinimo && valorRecarga <= 200.0f) {
    [boletoDataModel setValorRecarga:valorString];
    return YES;
  } else {
    NSString *errorMessage = [NSString stringWithFormat:@"Insira um valor entre R$ %.2f e R$ 200,00", valorMinimo];
    [SVProgressHUD showErrorWithStatus:[errorMessage stringByReplacingOccurrencesOfString:@"." withString:@","]];
    return NO;
  }
}

- (NSString *)extractNumericString:(NSString *)input {
  NSScanner *scanner = [NSScanner scannerWithString:input];
  NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789,."];
  NSString *numberString;
  [scanner scanUpToCharactersFromSet:numbers intoString:nil];
  [scanner scanCharactersFromSet:numbers intoString:&numberString];
  return numberString;
}

#pragma mark - Notifications Handlers

- (void)didRecieveCredits:(NSNotification *)notification {
  NSString *message = [NSString stringWithFormat:@"R$ %@", [dataModel ruCardCredit]];
  [_saldoLabel setText:message];
  [_username setText:[dataModel.userData objectForKey:@"nomeUsuario"]];
}

- (void)didRecieveCreditsError:(NSNotification *)notification {
  [SVProgressHUD showErrorWithStatus:@"Não foi possível obter o saldo. Tente novamente mais tarde."];
}

- (void)didCreatePix:(NSNotification *)notification {
  [SVProgressHUD dismiss];
  [self clearTextField];
  [self updatePixUI];
  [self performSegueWithIdentifier:@"showPix" sender:self];
}

- (void)didReceiveLastPix:(NSNotification *)notification {
  [SVProgressHUD dismiss];
  [self updatePixUI];
}

- (void)updatePixUI {
  pix = [VMPix modelWithDictionary:boletoDataModel.pix];
  [_lastPixValue setText:pix.valorFormatado];
  [_lastPixStatus setText:pix.statusDescricao];
  [_lastPixValue setText:[NSString stringWithFormat:@"Valor: %@", pix.valorFormatado]];
  [_lastPixStatus setText:[NSString stringWithFormat:@"Situação: %@", pix.statusDescricao]];
}

- (void)didRegisterUser:(NSNotification *)notification {
  [SVProgressHUD dismiss];
  [dataModel getCreditoRUCard];
}

#pragma mark - Helpers

- (void)clearTextField {
  [_maisCreditos setText:@""];
}

- (void)showBoletoViewController {
  if (!boletoViewController) {
    boletoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"boletoViewController"];
  }
  [self presentViewController:boletoViewController animated:YES completion:nil];
}

#pragma mark - Text Field Delegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
  [self updateTextField];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  
  if ([string isEqualToString:@""]) {
    return YES;
  }
  
  NSString *replaced = [textField.text stringByReplacingCharactersInRange:range withString:string];
  NSDecimalNumber *amount = (NSDecimalNumber*)[currencyFormatter numberFromString:replaced];
  if (amount == nil) {
    return NO;
  }
  
  short powerOf10 = ([textField.text isEqualToString:@""]) ? -currencyFormatter.maximumFractionDigits : (short)[string length];
  amount = [amount decimalNumberByMultiplyingByPowerOf10:powerOf10];
  
  textField.text = [currencyFormatter stringFromNumber:amount];
  
  return NO;
}

- (void)updateTextField {
  NSString *text = _maisCreditos.text;
  
  NSScanner *scanner = [NSScanner scannerWithString:text];
  NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789,."];
  
  NSString *numberString;
  [scanner scanUpToCharactersFromSet:numbers intoString:NULL];
  [scanner scanCharactersFromSet:numbers intoString:&numberString];
  
  NSString *value = [numberString stringByReplacingOccurrencesOfString:@"," withString:@"."];
  float floatValue = [value floatValue];
  
  if ([value hasPrefix:@"."]) {
    value = [@"0" stringByAppendingString:value];
    floatValue = [value floatValue];
  }
  
  NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
  [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
  [formatter setCurrencySymbol:@"R$"];
  [formatter setLocale:[NSLocale localeWithLocaleIdentifier:@"pt_BR"]];
  
  NSString *formattedValue = [formatter stringFromNumber:@(floatValue)];
  
  _maisCreditos.text = formattedValue;
}

#pragma mark - Keyboard Notifications

- (void)keyboardWillShow:(NSNotification *)notification {
  NSDictionary *userInfo = notification.userInfo;
  CGRect keyboardFrame = [userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
  NSTimeInterval animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  [self adjustViewForKeyboardAppearance:YES keyboardFrame:keyboardFrame animationDuration:animationDuration];
}

- (void)keyboardWillHide:(NSNotification *)notification {
  NSDictionary *userInfo = notification.userInfo;
  NSTimeInterval animationDuration = [userInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
  [self adjustViewForKeyboardAppearance:NO keyboardFrame:CGRectZero animationDuration:animationDuration];
}

- (void)adjustViewForKeyboardAppearance:(BOOL)isVisible keyboardFrame:(CGRect)keyboardFrame animationDuration:(NSTimeInterval)animationDuration {
  CGFloat offsetY = isVisible ? CGRectGetMaxY([self.view convertRect:_maisCreditos.frame fromView:_maisCreditos.superview]) - (self.view.frame.size.height - keyboardFrame.size.height) : 0;
  [UIView animateWithDuration:animationDuration animations:^{
    self.view.frame = CGRectMake(0, -offsetY, self.view.frame.size.width, self.view.frame.size.height);
  }];
}

#pragma mark - Login Check

- (void)checkLoginStatus {
  if (![oauth isLoggedIn]) {
    loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginWebViewController"];
    [self presentViewController:loginViewController animated:YES completion:nil];
  } else {
    [dataModel getCreditoRUCard];
    //[self fetchBoletos];
    [self fetchLastPix];
    [_username setText:[dataModel.userData objectForKey:@"nomeUsuario"]];
  }
}

#pragma mark - Boletos

- (void)setupListarBoletosButton {
  self.listarBoletosButton = [UIButton buttonWithType:UIButtonTypeSystem];
  self.listarBoletosButton.titleLabel.font = [UIFont systemFontOfSize:20];
  [self.listarBoletosButton setTitle:@"Listar boletos em aberto" forState:UIControlStateNormal];
  [self.listarBoletosButton addTarget:self action:@selector(listarBoletosPendentes:) forControlEvents:UIControlEventTouchUpInside];
  
  [self.view addSubview:self.listarBoletosButton];

  self.listarBoletosButton.translatesAutoresizingMaskIntoConstraints = NO;
  [NSLayoutConstraint activateConstraints:@[
    [self.listarBoletosButton.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor constant:-20],
    [self.listarBoletosButton.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor]
  ]];
}

- (void)fetchLastPix {
  //[SVProgressHUD show];
  [boletoDataModel getLastPix];
}

- (void)didReceivePix:(NSNotification *)notification {
  [SVProgressHUD dismiss];
  
  // Verifica se existem boletos no retorno
  NSArray *boletos = [boletoDataModel boletosPendentes];
  
  if (boletos.count > 0) {
    // Mostra o botão caso existam boletos
    self.listarBoletosButton.hidden = NO;
  } else {
    // Esconde o botão caso não existam boletos
    self.listarBoletosButton.hidden = YES;
  }
}

- (void)didReceiveBills:(NSNotification *)notification {
  [SVProgressHUD dismiss];
  
  // Verifica se existem boletos no retorno
  NSArray *boletos = [boletoDataModel boletosPendentes];
  
  if (boletos.count > 0) {
    // Mostra o botão caso existam boletos
    self.listarBoletosButton.hidden = NO;
  } else {
    // Esconde o botão caso não existam boletos
    self.listarBoletosButton.hidden = YES;
  }
}

- (void)listarBoletosPendentes:(id)sender {
  [self performSegueWithIdentifier:@"listarBoletosPendentes" sender:self];
}

- (IBAction)copyPixToPB:(id)sender {
  if (pix.qrcpix.length) {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = pix.qrcpix;
    
    [SVProgressHUD showSuccessWithStatus:@"copiado"];
  }
}

@end
