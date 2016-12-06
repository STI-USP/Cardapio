//
//  CreditsViewController.h
//  Cardapio USP
//
//  Created by Vagner Machado on 05/12/16.
//  Copyright © 2016 EPUSP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreditsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *saldoLabel;
@property (weak, nonatomic) IBOutlet UILabel *valorLabel;
@property (weak, nonatomic) IBOutlet UIButton *gerarBoleto;
@property (weak, nonatomic) IBOutlet UITextField *maisCreditos;

- (IBAction)gerarBoleto:(id)sender;

- (IBAction)logout:(id)sender;
- (IBAction)dismiss:(id)sender;

@end
