//
//  PaddedLabel.m
//  Cardapio USP
//
//  Created by Vagner Machado on 16/08/24.
//  Copyright © 2024 USP. All rights reserved.
//

#import "PaddedLabel.h"

@implementation PaddedLabel

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self commonInit];
}

- (void)commonInit {
    self.textInsets = UIEdgeInsetsMake(8, 16, 8, 16);
    
    if (self.text) {
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = self.font.lineHeight * 0.15;
        
        NSDictionary *attributes = @{
            NSParagraphStyleAttributeName: paragraphStyle,
            NSFontAttributeName: self.font
        };
        
        NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:self.text attributes:attributes];
        self.attributedText = attributedText;
    }
}

- (void)drawTextInRect:(CGRect)rect {
    CGRect insetRect = UIEdgeInsetsInsetRect(rect, self.textInsets);
    [super drawTextInRect:insetRect];
}

- (CGSize)intrinsicContentSize {
    CGSize textSize = [self.attributedText boundingRectWithSize:CGSizeMake(self.frame.size.width - self.textInsets.left - self.textInsets.right, CGFLOAT_MAX)
                                                        options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                        context:nil].size;
    
    CGSize adjustedSize = CGSizeMake(ceil(textSize.width) + self.textInsets.left + self.textInsets.right,
                                     ceil(textSize.height) + self.textInsets.top + self.textInsets.bottom);
    
    return adjustedSize;
}

@end
