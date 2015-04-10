//
//  RestaurantDataModel.m
//  Cardapio USP
//
//  Created by Vagner Machado on 7/23/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import "RestaurantDataModel.h"
#import "Restaurant.h"

@interface RestaurantDataModel () {
  NSArray *restaurantsOption;
}

@end

@implementation RestaurantDataModel

@synthesize restaurant = _restaurant;
@synthesize campusOption = _campusOption;
@synthesize restaurantOption = _restaurantOption;

+(RestaurantDataModel *) getInstance
{
    static RestaurantDataModel *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype) init {

  restaurantsOption = @[@"all", @"byTitle", @"byAuthor", @"bySubject", @"byIsxn"];
  self.restaurantOption = 0; // valor inicial caso não tenha nada salvo
  self.campusOption = 0;
  
  return self;
}


@end
