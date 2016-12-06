//
//  BoletoViewController.h
//  Cardapio USP
//
//  Created by Vagner Machado on 06/12/16.
//  Copyright © 2016 EPUSP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BoletoViewController : UIViewController

@property (weak, nonatomic) IBOutlet UILabel *valorLabel;
@property (weak, nonatomic) IBOutlet UILabel *codBarrasLabel;


- (IBAction)dismiss:(id)sender;
- (IBAction)copyToPasteboard:(id)sender;
- (IBAction)sendMail:(id)sender;


@end
