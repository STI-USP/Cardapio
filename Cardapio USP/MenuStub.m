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

- (NSMutableArray *) loadMenus
{
    NSURL *url1 = [NSURL URLWithString:@"http://kaimbu.uspnet.usp.br:8080/cardapio/central.json"];
    NSMutableURLRequest *req1 = [NSMutableURLRequest requestWithURL:url1];
    
    NSError *error;
    NSURLResponse *resp = nil;

    NSData *data = [NSURLConnection sendSynchronousRequest:req1 returningResponse:&resp error:&error];
    
    // Mapeamento de NSData para NSDictionary
    NSMutableArray* json = [NSJSONSerialization JSONObjectWithData:data  options:NSJSONReadingMutableContainers  error:&error];

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

@end
