//
//  FrostedViewController.m
//  Cardapio USP
//
//  Created by Jun Okamoto Jr. on 19/05/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import "FrostedViewController.h"

@interface FrostedViewController ()

@end

@implementation FrostedViewController

- (void)awakeFromNib {
  self.contentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"restaurantController"];
  self.menuViewController = [ self.storyboard instantiateViewControllerWithIdentifier:@"selectorController"];
}

@end
