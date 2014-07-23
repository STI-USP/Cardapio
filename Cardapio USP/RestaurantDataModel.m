//
//  RestaurantDataModel.m
//  Cardapio USP
//
//  Created by Vagner Machado on 7/23/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import "RestaurantDataModel.h"

@implementation RestaurantDataModel



+(RestaurantDataModel *) getInstance
{
    static RestaurantDataModel *instancia = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instancia = [[self alloc] init];
    });
    
    return instancia;
}


@end
