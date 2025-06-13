//  CreditsViewController.h
//  Cardapio USP
//
//  Created by Vagner Machado on 05/12/16.
//  Copyright © 2016 EPUSP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "MyTextField.h"

@interface CreditsViewController : UIViewController <SWRevealViewControllerDelegate, UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *saldoLabel;
@property (weak, nonatomic) IBOutlet MyTextField *maisCreditos;
@property (weak, nonatomic) IBOutlet UILabel *lastPixValue;
@property (weak, nonatomic) IBOutlet UILabel *lastPixStatus;
@property (weak, nonatomic) IBOutlet UIButton *cpPixButton;
@property (nonatomic, strong) UIButton *listarBoletosButton;

- (IBAction)copyPixToPB:(id)sender;
- (IBAction)gerarPix:(id)sender;
- (IBAction)logout:(id)sender;
//- (IBAction)listarBoletos:(id)sender;

@end
