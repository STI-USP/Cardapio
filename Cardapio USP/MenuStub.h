//
//  CardapioStub.h
//  Cardapio USP
//
//  Created by Alessandro Souzadidier on 26/05/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Restaurant.h"
#import "Menu.h"
#import "Cash.h"

@interface MenuStub : NSObject{
    Menu *menu;
    NSMutableArray *menus;
}

@property (nonatomic, retain) Menu *menu;
@property (nonatomic, retain) NSMutableArray *menus;
@property (nonatomic, retain) NSMutableArray *restaurants;


/**
 * Inicializaçao do objeto, singleton
 */
+ (MenuStub *) getInstance;


- (NSMutableArray *) loadMenus:(NSString *) _restaurant;
- (Menu *) loadMenu:(NSMutableArray *) _menus Date:(NSString *)_date ;
- (NSMutableArray *) loadRestaurantsInformation:(NSString *) _campi;
- (Restaurant *) loadRestaurantInformation:(NSString *)_campi Restaurant:(NSString *)_restaurant;
- (Cash *) loadCashInformation;


@end
