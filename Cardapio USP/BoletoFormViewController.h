//
//  BoletoFormViewController.h
//  Cardapio USP
//
//  Created by Vagner Machado on 13/12/16.
//  Copyright © 2016 EPUSP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BoletoFormViewController : UIViewController


@property (weak, nonatomic) IBOutlet UILabel *username;
@property (weak, nonatomic) IBOutlet UITextField *maisCreditos;

- (IBAction)gerarBoleto:(id)sender;
- (IBAction)dismiss:(id)sender;

@end
