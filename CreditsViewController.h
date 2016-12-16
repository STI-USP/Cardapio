//
//  CreditsViewController.h
//  Cardapio USP
//
//  Created by Vagner Machado on 05/12/16.
//  Copyright © 2016 EPUSP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CreditsViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UILabel *saldoLabel;

- (IBAction)gerarNovoBoleto:(id)sender;
- (IBAction)visualizarBoleto:(id)sender;

- (IBAction)logout:(id)sender;
- (IBAction)dismiss:(id)sender;

@end
