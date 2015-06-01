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
@synthesize menu, menus,restaurants;
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

- (NSMutableArray *) loadMenus:(NSString *)restaurant; {
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
            Period *p0 = [[Period alloc ] initWithPeriod:@"lunch" andMenu:[lunch objectForKey:@"menu"] andCalories:[lunch objectForKey:@"calories"]];
            Period *p1 = [[Period alloc ] initWithPeriod:@"dinner" andMenu:[dinner objectForKey:@"menu"] andCalories:[lunch objectForKey:@"calories"]];
            [ps addObject:p0];
            [ps addObject:p1];
            
            Menu *m = [[Menu  alloc ] initWithDate:hour andPeriod:ps ];
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
- (Menu *) loadMenu:(NSMutableArray *)menusArray Date:(NSString *)date {
    Menu *menudate;
    for (Menu *m in menusArray)
        if ([[m date] isEqualToString:date])
            menudate = m;

  return menudate;
}


- (Restaurant *) loadRestaurantInformation:(NSString *)campus Restaurant:(NSString *)restaurant {
    Restaurant *res;
    for (Restaurant *r in [self loadRestaurantsInformation:campus])
        if ([[r title] isEqualToString:restaurant])
            res = r;

  return res;
}

- (NSMutableArray *) loadRestaurantsInformation:(NSString *)campi {
    restaurants = [[NSMutableArray alloc] init];
    // Mapeamento de NSData para NSMutableArray
    NSDictionary *json = (NSDictionary *) [self iniciar_JSONBinding:@"http://kaimbu.uspnet.usp.br:8080/cardapio/restaurantes.json"];
    
    if (!json)
    {
        NSLog(@"Error parsing JSON: %@", nil);
    } else
    {
        for(NSDictionary *item in json[campi]) {
            NSMutableArray *wpitems = [[NSMutableArray alloc] init];
            for(NSDictionary *wp in [item objectForKey:@"weeklyperiod"])
            {
               //NSLog(@"Horarios : %@ %@ %@ %@", wp[@"period"], wp[@"breakfast"], wp[@"lunch"], wp[@"dinner"]);
               WeeklyPeriod *weekperiod = [[WeeklyPeriod alloc] initWithWeeklyPeriod:wp[@"period"] andBreakfast:wp[@"breakfast"] andLunch:wp[@"lunch"] andDinner:wp[@"dinner"]];
            [wpitems addObject:weekperiod];
            }
            
            Restaurant *restaurant = [[Restaurant alloc] initWithId:item[@"id"] andTitle:item[@"title"] andName:item[@"name"] andAddress:item[@"address"] andPhone:item[@"phone"] andLatitude:item[@"latitude"] andLongitude:item[@"longitude"] andPhotoURL:item[@"photourl"] andWeeklyPeriod:wpitems];
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
                Items *i = [[Items alloc] initWithItems:category andPrice:price];
                [items addObject:i];
            }
            cash = [[Cash alloc] initWithMenu:item[@"workinghours"] andItems:items];
        }
    }
    return cash;
}

@end
