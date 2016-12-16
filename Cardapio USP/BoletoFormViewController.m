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

  UIToolbar *keyboardDoneButtonView = [[UIToolbar alloc] init];
  [keyboardDoneButtonView sizeToFit];
  UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"   OK" style:UIBarButtonItemStylePlain target:self action:@selector(doneClicked:)];
  [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:doneButton, nil]];
  _maisCreditos.inputAccessoryView = keyboardDoneButtonView;

}

- (void)viewWillAppear:(BOOL)animated {
  [_username setText:[dataModel.userData objectForKey:@"nomeUsuario"]];
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
  [self dismissViewControllerAnimated:NO completion:nil];
  [boletoDataModel createBoleto];
}

- (void)doneClicked:(id)sender {
  [self.view endEditing:YES];
}

- (IBAction)dismiss:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}
@end
