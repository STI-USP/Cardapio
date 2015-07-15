//
//  DetailCell.m
//  Bibliotecas USP
//
//  Created by Jun Okamoto Jr. on 17/11/14.
//  Copyright (c) 2014 USP. All rights reserved.
//

#import "DetailCell.h"

@implementation DetailCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)setBounds:(CGRect)bounds
{
  [super setBounds:bounds];
  
  self.contentView.frame = self.bounds;
}

- (void)layoutSubviews
{
  [super layoutSubviews];
  
  [self.contentView updateConstraintsIfNeeded];
  [self.contentView layoutIfNeeded];
  
  self.titleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.titleLabel.frame);
  self.subtitleLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.subtitleLabel.frame);
}

@end
