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
  
  if (([boletoDataModel.valorRecarga floatValue] >= 20) && ([boletoDataModel.valorRecarga floatValue] <= 200)) {
    [self.navigationController popViewControllerAnimated:YES];
    [boletoDataModel createBoleto];
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
  
  if (([[textField text] floatValue] >= 20) && ([[textField text] floatValue] <= 200)) {
    [boletoDataModel setValorRecarga:[textField text]];
  } else {
    [SVProgressHUD showErrorWithStatus:@"Insira um valor entre R$ 20,00 e R$ 200,00"];
  }
  
}

/*
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
  if (string.length) {
    if (textField.text.length<=9) {
      if (textField.text.length>0) {
        NSString *tempStr=[NSString stringWithFormat:@"R$ %@",textField.text];
        textField.text=tempStr;
      } else if (textField.text.length==10) {
        NSString *tempStr=[NSString stringWithFormat:@"%@-",textField.text];
        textField.text=tempStr;
      }
    } else {
      return NO;
    }
  }
  return YES;
}
*/

@end
