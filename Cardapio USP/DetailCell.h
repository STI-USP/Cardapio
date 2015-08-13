//
//  DetailCell.h
//  Bibliotecas USP
//
//  Created by Jun Okamoto Jr. on 17/11/14.
//  Copyright (c) 2014 USP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RWLabel.h"

@interface DetailCell : UITableViewCell

@property (nonatomic, weak) IBOutlet RWLabel *title;
@property (nonatomic, weak) IBOutlet RWLabel *subtitle;

@end
