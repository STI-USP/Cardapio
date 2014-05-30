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

@implementation MenuStub
@synthesize menus;
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
 *  Obtem uma lista de restaurantes, com informacoes de cada um a partir de um campi, formato REST JSON
 *  param _menus
 */
- (NSMutableArray *) loadRestaurantsInformation:(NSString *)_campi
{
    // Mapeamento de NSData para NSMutableArray
    NSMutableArray* json = [self iniciar_JSONBinding:@"http://kaimbu.uspnet.usp.br:8080/cardapio/restaurantes.json"];
    
    if (!json)
    {
        NSLog(@"Error parsing JSON: %@", nil);
    } else
    {
    
    }
    return NULL;
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
