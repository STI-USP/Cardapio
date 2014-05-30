//
//  CardapioStub.h
//  Cardapio USP
//
//  Created by Alessandro Souzadidier on 26/05/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Menu.h"
#import "Cash.h"

@interface MenuStub : NSObject{
    Menu *menu;
    NSMutableArray *menus;
}

@property (nonatomic, retain) Menu *menu;
@property (nonatomic, retain) NSMutableArray *menus;


/**
 * Inicializaçao do objeto, singleton
 */
+ (MenuStub *) getInstance;


- (NSMutableArray *) loadMenus:(NSString *) _restaurant;
- (Menu *) loadMenu:(NSMutableArray *) _menus Date:(NSString *)_date ;
- (NSMutableArray *) loadRestaurantsInformation:(NSString *) _campi;
- (Cash *) loadCashInformation;


@end
