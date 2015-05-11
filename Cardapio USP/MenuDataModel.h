//
//  MenuDataModel.h
//  Cardapio USP
//
//  Created by Alessandro Souzadidier on 10/06/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Restaurant.h"
#import "Menu.h"
#import "Cash.h"  

@interface MenuDataModel : NSObject


@property (nonatomic, strong) Menu *menu;
@property (nonatomic, strong) Restaurant *restaurant;
@property (nonatomic, strong) Cash *cash;
@property (nonatomic, strong) NSMutableArray *menus;
@property (nonatomic, strong) NSMutableArray *restaurantsByCampus;
@property (nonatomic, strong) NSArray *diasDaSemana;
  
@property (nonatomic, strong) NSString *restaurantId;
@property (nonatomic, strong) NSString *restaurantName;
@property (nonatomic, strong) NSString *campus;
@property (nonatomic, strong) NSString *date;


/**
 * Inicializaçao do objeto, singleton
 */
+ (MenuDataModel *) getInstance;

@end
