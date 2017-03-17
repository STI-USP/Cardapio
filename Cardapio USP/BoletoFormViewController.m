//
//  BoletoFormViewController.m
//  Cardapio USP
//
//  Created by Vagner Machado on 13/12/16.
//  Copyright © 2016 EPUSP. All rights reserved.
//

#import "BoletoFormViewController.h"
#import "DataModel.h"
#import "BoletoDataModel.h"
#import "SVProgressHUD.h"


@interface BoletoFormViewController () {
  DataModel *dataModel;
  BoletoDataModel *boletoDataModel;
}

@end

@implementation BoletoFormViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  dataModel = [DataModel getInstance];
  boletoDataModel = [BoletoDataModel sharedInstance];
  
  [_username setText:@""];

  _maisCreditos.delegate = self;
  
  UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
  [keyboardDoneButtonView sizeToFit];
  UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"   OK" style:UIBarButtonItemStylePlain target:self action:@selector(doneClicked:)];
  [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
  _maisCreditos.inputAccessoryView = keyboardDoneButtonView;
  [_maisCreditos setFont:[UIFont systemFontOfSize:17]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)gerarBoleto:(id)sender {
  //[self dismissViewControllerAnimated:NO completion:nil];
  float valorRecarga = [[[[boletoDataModel.valorRecarga stringByReplacingOccurrencesOfString:@"R" withString:@""] stringByReplacingOccurrencesOfString:@"$" withString:@""] stringByReplacingOccurrencesOfString:@"," withString:@"."] floatValue];
  if ((valorRecarga >= 20) && (valorRecarga <= 200)) {
    [self.navigationController popViewControllerAnimated:YES];
    [boletoDataModel createBill];
  } else {
    [SVProgressHUD showErrorWithStatus:@"Insira um valor entre R$ 20,00 e R$ 200,00"];
  }
  
}

- (void)doneClicked:(id)sender {
  [self.view endEditing:YES];
  [[self maisCreditos] resignFirstResponder];
}

- (IBAction)dismiss:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Text Field Delegate

- (void)textFieldDidEndEditing:(UITextField *)textField {
  //validar valores
  [textField setText:[[[textField text] stringByReplacingOccurrencesOfString:@"R" withString:@""] stringByReplacingOccurrencesOfString:@"$" withString:@""]];

  [boletoDataModel setValorRecarga:[textField text]];

  NSString *value = [[boletoDataModel valorRecarga]stringByReplacingOccurrencesOfString:@"," withString:@"."];
  
  if (([value floatValue] >= 20) && ([value floatValue] <= 200)) {
    NSNumberFormatter *currencyFormatter = [[NSNumberFormatter alloc] init];
    [currencyFormatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    [textField setText:[[currencyFormatter stringFromNumber:[NSNumber numberWithFloat:[value floatValue]]] stringByReplacingOccurrencesOfString:@"." withString:@","]];

    [boletoDataModel setValorRecarga:[currencyFormatter stringFromNumber:[NSNumber numberWithFloat:[value floatValue]]]];

  } else {
    [SVProgressHUD showErrorWithStatus:@"Insira um valor entre R$20,00 e R$200,00"];
  }
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
  [textField setText:@""];
  return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField {
  [textField resignFirstResponder];
  return YES;
}

@end
