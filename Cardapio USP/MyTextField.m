//
//  MyTextField.m
//  Cardapio USP
//
//  Created by Vagner Machado on 31/10/22.
//  Copyright © 2022 USP. All rights reserved.
//

#import "MyTextField.h"

@implementation MyTextField

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect {
 // Drawing code
 }
 */

static CGFloat leftMargin = 12;

- (CGRect)textRectForBounds:(CGRect)bounds {
  bounds.origin.x += leftMargin;
  return bounds;
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
  bounds.origin.x += leftMargin;
  
  return bounds;
}

@end
