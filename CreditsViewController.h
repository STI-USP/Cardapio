//
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

@property (nonatomic, strong) UIButton *listarBoletosButton;

- (IBAction)gerarPix:(id)sender;
- (IBAction)listarBoletos:(id)sender;

- (IBAction)logout:(id)sender;

@end
