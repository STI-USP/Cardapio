//
//  MenuDataModel.m
//  Cardapio USP
//
//  Created by Alessandro Souzadidier on 10/06/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import "MenuDataModel.h"
#import "Period.h"
#import "WeeklyPeriod.h"
#import "Items.h"
#import "RestaurantDataModel.h"

#define kRestaurantsURL @"http://kaimbu2.uspnet.usp.br:8080/cardapio/%@.json"


@implementation MenuDataModel
   

/*
 * Inicializaçao do objeto, singleton
 */
+(MenuDataModel *) getInstance
{
    static MenuDataModel *instancia = nil;
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
    NSMutableArray* json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:&error];
    
    return json;
}


/**
 *  Obtem a lista de menus relacionados a um restaurante, formato REST JSON
 *
 */
- (NSMutableArray *)menus {
  NSMutableArray *json = [self iniciar_JSONBinding:
                          [NSString stringWithFormat:kRestaurantsURL, [[RestaurantDataModel getInstance] restaurant]]];   
  _menus = [[NSMutableArray alloc] init];
  
  if (!json) {
    NSLog(@"Error parsing JSON: %@", nil);
  } else {
    
    for(NSMutableDictionary *item in json) {
      
      
      NSMutableArray *period = [[NSMutableArray alloc] init];
      
      // [di:150316] Teste se refeicao diaria presente no json, cria o array com os periodos de refeicao
      if ([item objectForKey:@"breakfast"] != nil) {
        Period *breakfast = [[Period alloc ] initWithPeriod:@"breakfast" andMenu:[item objectForKey:@"breakfast"][@"menu"] andCalories:[item objectForKey:@"breakfast"][@"calories"]];
        [period addObject:breakfast];
      }
      
      if ([item objectForKey:@"lunch"] != nil) {
        Period *lunch = [[Period alloc ] initWithPeriod:@"lunch" andMenu:[item objectForKey:@"lunch"][@"menu"] andCalories:[item objectForKey:@"lunch"][@"calories"]];
        [period addObject:lunch];
      }
      
      if ([item objectForKey:@"dinner"] != nil) {
        Period *dinner = [[Period alloc ] initWithPeriod:@"dinner" andMenu:[item objectForKey:@"dinner"][@"menu"] andCalories:[item objectForKey:@"dinner"][@"calories"]];
        [period addObject:dinner];
      }
      
      // [di:150316] Adiciona os periodos de refeicao no menu
      Menu *menu = [[Menu alloc] initWithDate:[item objectForKey:@"date"] andPeriod:period];
      [_menus addObject:menu];
    }
  }
  
  return _menus;
}

/**
 *  Obtem um cardapio a partir de uma data especificada, formato REST JSON
 *  param _date
 */
- (Menu *)menu
{
    Menu *menudate;
    for (Menu *m in [self menus]) {
        if ([[m date] isEqualToString:_date]) {
            menudate = m;
        }
    }
    return menudate;
}

/**
 *  Obtem restaurante, com informacoes a partir de um campi, formato REST JSON
 *  param _rest
 */
- (Restaurant *)restaurant
{
    Restaurant *res;
    for (Restaurant *r in [self restaurants]) {
        if ([[r title] isEqualToString:_rest]) {
            res = r;
        }
    }
    return res;
}

/**
 *  Obtem uma lista de restaurantes, com informacoes de cada um a partir de um campi, formato REST JSON
 *  param _campi
 */
- (NSMutableArray *)restaurants
{
    _restaurants = [[NSMutableArray alloc] init];
    // Mapeamento de NSData para NSMutableArray
    NSDictionary *json = (NSDictionary *) [self iniciar_JSONBinding: [NSString stringWithFormat:kRestaurantsURL, @"restaurantes"]];
    
    if (!json)
    {
        NSLog(@"Error parsing JSON: %@", nil);
    } else {
        for(NSDictionary *item in json[_campi]) {
            NSMutableArray *wpitems = [[NSMutableArray alloc] init];
            for(NSDictionary *wp in [item objectForKey:@"weeklyperiod"])
            {
                //NSLog(@"Horarios : %@ %@ %@ %@", wp[@"period"], wp[@"breakfast"], wp[@"lunch"], wp[@"dinner"]);
                WeeklyPeriod *weekperiod = [[WeeklyPeriod alloc] initWithWeeklyPeriod:wp[@"period"] andBreakfast:wp[@"breakfast"] andLunch:wp[@"lunch"] andDinner:wp[@"dinner"]];
                [wpitems addObject:weekperiod];
            }
            
            Restaurant *restaurant = [[Restaurant alloc] initWithId:item[@"id"] andTitle:item[@"title"] andName:item[@"name"] andAddress:item[@"address"] andPhone:item[@"phone"] andLatitude:item[@"latitude"] andLongitude:item[@"longitude"] andPhotoURL:item[@"photourl"] andWeeklyPeriod:wpitems];
            [_restaurants addObject:restaurant];
        }
    }
    return _restaurants;
}

-(Cash *)cash
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    NSDictionary *json = (NSDictionary *)[self iniciar_JSONBinding: [NSString stringWithFormat:kRestaurantsURL, @"restaurantes"]];
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
            _cash = [[Cash alloc] initWithMenu:item[@"workinghours"] andItems:items];
        }
    }
    return _cash;
}



@end
