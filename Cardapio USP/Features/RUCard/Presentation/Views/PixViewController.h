//
//  PixViewController.h
//  Cardapio USP
//
//  Created by Vagner Machado on 26/10/22.
//  Copyright © 2022 USP. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PixViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *qrCodePix;
@property (weak, nonatomic) IBOutlet UILabel *valorPix;
@property (weak, nonatomic) IBOutlet UIButton *pasteboardButton;

- (IBAction)copyToPasteboard:(id)sender;
- (IBAction)share:(id)sender;
- (IBAction)dismiss:(id)sender;

@end

NS_ASSUME_NONNULL_END
