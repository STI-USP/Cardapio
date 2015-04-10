//
//  RestaurantDataModel.h
//  Cardapio USP
//
//  Created by Vagner Machado on 7/23/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Restaurant.h"

@interface RestaurantDataModel : NSObject

@property (nonatomic, strong) NSString *restaurant;
@property (nonatomic) NSInteger restaurantOption;


+ (RestaurantDataModel *) getInstance;

@end
