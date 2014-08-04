//
//  RestaurantDataModel.m
//  Cardapio USP
//
//  Created by Vagner Machado on 7/23/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import "RestaurantDataModel.h"
#import "Restaurant.h"

@implementation RestaurantDataModel

@synthesize restaurant;

+(RestaurantDataModel *) getInstance
{
    static RestaurantDataModel *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

@end
