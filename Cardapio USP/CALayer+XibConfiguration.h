//
//  CALayer+XibConfiguration.h
//  Cardapio USP
//
//  Created by Vagner Machado on 14/04/21.
//  Copyright © 2021 USP. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface CALayer(XibConfiguration)

// This assigns a CGColor to borderColor.
@property(nonatomic, assign) UIColor* borderUIColor;

@end

NS_ASSUME_NONNULL_END
