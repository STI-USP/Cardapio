//
//  ImageCell.h
//  Cardapio USP
//
//  Created by Vagner Machado on 8/10/15.
//  Copyright (c) 2015 EPUSP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *restImage;

@property (strong, nonatomic) IBOutlet UILabel *restaurantName;
@property (strong, nonatomic) IBOutlet UILabel *restaurantNameOverlay;

@end
