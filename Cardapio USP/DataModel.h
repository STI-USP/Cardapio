//
//  DataModel.h
//  Cardapio USP
//
//  Created by Vagner Machado on 5/21/15.
//  Copyright (c) 2015 EPUSP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MenuDataModel.h"
#import "RestaurantDataModel.h"
#import "Restaurant.h"
#import "Menu.h"
#import "Cash.h"


@interface DataModel : NSObject

@property (nonatomic, strong) NSMutableArray *menuArray;
@property (nonatomic, strong) Menu *menu;
@property (nonatomic, strong) Restaurant *restaurant;
@property (nonatomic, strong) Cash *cash;
@property (nonatomic, strong) NSDictionary *defaulRestaurant;
@property (nonatomic, strong) NSDictionary *currentRestaurant;
@property (nonatomic, strong) NSDictionary *preferedRestaurant;
@property (nonatomic, strong) NSMutableArray *menus;
@property (nonatomic, strong) NSMutableArray *restaurants;
@property (nonatomic, strong) NSArray *diasDaSemana;

@property (nonatomic, strong) NSString *restaurantId;
@property (nonatomic, strong) NSString *restaurantName;
@property (nonatomic, strong) NSMutableDictionary *campus;
@property (nonatomic, strong) NSString *date;

@property (nonatomic) NSInteger campusOption;
@property (nonatomic) NSInteger restaurantOption;

+ (DataModel *) getInstance;
- (void)getMenu;
- (void)getRestaurants;
- (void)setDefault;

@end
