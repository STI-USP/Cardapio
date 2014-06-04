//
//  CardapioStub.m
//  Cardapio USP
//
//  Created by Alessandro Souzadidier on 26/05/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import "MenuStub.h"
#import "Menu.h"
#import "Period.h"
#import "Cash.h"
#import "Items.h"
#import "Restaurant.h"
#import "WeeklyPeriod.h"

@implementation MenuStub
@synthesize menus,restaurants;
static MenuStub *instancia = nil;
  
/*
 * Inicializaçao do objeto, singleton
 */
+(MenuStub *) getInstance
{
    static dispatch_once_t once;   
    dispatch_once(&once, ^{
        instancia = [[self alloc] init];
    });
    
    return instancia;
}

/**
 *  Inicia Binding ao serviço REST JSON
 *
 */
- (NSMutableArray *) iniciar_JSONBinding:(NSString *)_url
{
    NSURL *url1 = [NSURL URLWithString:_url];
    NSMutableURLRequest *req1 = [NSMutableURLRequest requestWithURL:url1];
    NSError *error;
    NSURLResponse *resp = nil;
    NSData *data = [NSURLConnection sendSynchronousRequest:req1 returningResponse:&resp error:&error];
    // Mapeamento de NSData para NSMutableArray
    NSMutableArray* json = [NSJSONSerialization JSONObjectWithData:data  options:NSJSONReadingMutableContainers  error:&error];
    
    return json;
}

/**
 *  Obtem a lista de menus relacionados a um restaurante, formato REST JSON
 *  param _restaurant
 */
- (NSMutableArray *) loadMenus:(NSString *) _restaurant;
{
    NSMutableArray *json = [self iniciar_JSONBinding:@"http://kaimbu.uspnet.usp.br:8080/cardapio/central.json"];
    menus = [[NSMutableArray alloc] init];
    if (!json) {
        NSLog(@"Error parsing JSON: %@", nil);
    } else {
    
        for(NSDictionary *item in json) {
            NSString *hour = [item objectForKey:@"date"];
            NSDictionary *lunch = [item objectForKey:@"lunch"];
            NSDictionary *dinner = [item objectForKey:@"dinner"];
            
            NSMutableArray *ps = [[NSMutableArray alloc] init];
            Period *p0 = [[Period alloc ] initWithPeriod:@"lunch" Menu:[lunch objectForKey:@"menu"] Calories:[lunch objectForKey:@"calories"]];
            Period *p1 = [[Period alloc ] initWithPeriod:@"dinner" Menu:[dinner objectForKey:@"menu"] Calories:[lunch objectForKey:@"calories"]];
            [ps addObject:p0];
            [ps addObject:p1];
            
            Menu *m = [[Menu  alloc ] initWithMenu:hour Period:ps ];
            [menus addObject:m];
        }
    }
    return menus;
}

/**
 *  Obtem um cardapio a partir de uma data especificada, formato REST JSON
 *  param _menus
 *  param _date
 */
- (Menu *) loadMenu:(NSMutableArray *) _menus Date:(NSString *)_date
{
    Menu *menudate;
    for (Menu *m in _menus) {
        if ([[m date] isEqualToString:_date]) {
            menudate = m;
        }
    }
    return menudate;
}


/**
 *  Obtem restaurante, com informacoes a partir de um campi, formato REST JSON
 *  param _campi
 *  param _restaurant
 */
- (Restaurant *) loadRestaurantInformation:(NSString *)_campi Restaurant:(NSString *)_restaurant
{
    Restaurant *res;
    for (Restaurant *r in [self loadRestaurantsInformation:_campi]) {
        if ([[r title] isEqualToString:_restaurant]) {
            res = r;
        }
    }  
    return res;
}


/**
 *  Obtem uma lista de restaurantes, com informacoes de cada um a partir de um campi, formato REST JSON
 *  param _campi
 */
- (NSMutableArray *) loadRestaurantsInformation:(NSString *)_campi
{
    restaurants = [[NSMutableArray alloc] init];
    // Mapeamento de NSData para NSMutableArray
    NSDictionary *json = (NSDictionary *) [self iniciar_JSONBinding:@"http://kaimbu.uspnet.usp.br:8080/cardapio/restaurantes.json"];
    
    if (!json)
    {
        NSLog(@"Error parsing JSON: %@", nil);
    } else
    {
        for(NSDictionary *item in json[_campi]) {
            NSMutableArray *wpitems = [[NSMutableArray alloc] init];
            for(NSDictionary *wp in [item objectForKey:@"weeklyperiod"])
            {
               //NSLog(@"Horarios : %@ %@ %@ %@", wp[@"period"], wp[@"breakfast"], wp[@"lunch"], wp[@"dinner"]);
               WeeklyPeriod *weekperiod = [[WeeklyPeriod alloc] initWithWeeklyPeriod:wp[@"period"] Breakfast:wp[@"breakfast"] Lunch:wp[@"lunch"] Dinner:wp[@"dinner"]];
            [wpitems addObject:weekperiod];
            }
            
            Restaurant *restaurant = [[Restaurant alloc] initWithRestaurant:item[@"id"] Title:item[@"title"] Name:item[@"name"] Address:item[@"address"] Phone:item[@"phone"] Latitude:item[@"latitude"] Longitude:item[@"longitude"] Photourl:item[@"photourl"] WeeklyPeriod:wpitems];
            [restaurants addObject:restaurant];
        }
    }
    return restaurants;
}

/**
 *  Obtem informacoes sobre o caixa dos restaurantes USP, formato REST JSON
 *
 */
- (Cash *) loadCashInformation
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    Cash *cash;
    NSDictionary *json = (NSDictionary *)[self iniciar_JSONBinding:@"http://kaimbu.uspnet.usp.br:8080/cardapio/restaurantes.json"];
    if (!json)
    {
        NSLog(@"Error parsing JSON: %@", nil);
    } else
    {
        for(NSDictionary *item in json[@"CAIXA"]) {
            for(NSDictionary *i in item[@"items"]) {
                NSString *category = i[@"category"];
                NSString *price = i[@"price"];
                Items *i = [[Items alloc] initWithItems:category Price:price];
                [items addObject:i];
            }
            cash = [[Cash alloc] initWithMenu:item[@"workinghours"] Items:items];
        }
    }
    return cash;
}

@end
