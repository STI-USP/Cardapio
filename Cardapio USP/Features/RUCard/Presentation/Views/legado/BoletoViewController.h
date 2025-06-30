//
//  BoletoViewController.h
//  Cardapio USP
//
//  Created by Vagner Machado on 06/12/16.
//  Copyright © 2016 EPUSP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"

@interface BoletoViewController : UIViewController <SWRevealViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *valorLabel;
@property (weak, nonatomic) IBOutlet UILabel *vencimentoLabel;
@property (weak, nonatomic) IBOutlet UILabel *codBarrasLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailTxt;
@property (weak, nonatomic) IBOutlet UIButton *okButton;


- (IBAction)dismiss:(id)sender;
- (IBAction)copyToPasteboard:(id)sender;
- (IBAction)deleteBill:(id)sender;

@end
