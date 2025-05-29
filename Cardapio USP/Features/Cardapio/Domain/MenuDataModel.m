//
//  MenuDataModel.m
//  Cardapio USP
//
//  Created by Alessandro Souzadidier on 10/06/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import "MenuDataModel.h"
#import "DataModel.h"
#import "Period.h"
#import "WeeklyPeriod.h"
#import "Items.h"
#import "RestaurantDataModel.h"
#import "AFNetworking.h"

#define kRestaurantsURL @"http://kaimbu2.uspnet.usp.br:8080/cardapio/"
#define kBaseURL @"http://kaimbu2.uspnet.usp.br:8080/"

#define kBaseDevSTIURL @"https://dev.uspdigital.usp.br/rucard/servicos/"
#define kBaseSTIURL @"https://uspdigital.usp.br/rucard/servicos/"

@implementation MenuDataModel
   

/*
 * Inicializaçao do objeto, singleton
 */
+(MenuDataModel *) getInstance
{
    static MenuDataModel *instancia = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      instancia = [[MenuDataModel alloc] init];
      //instancia.restaurantId = @"10";
      //instancia.restaurantName = @"Central";
      //instancia.campus = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"CUASO", nil]
        //                                                    forKeys:[NSArray arrayWithObjects:@"name", nil]];
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

- (NSMutableArray *)menus {
  NSMutableArray *json = [self iniciar_JSONBinding:
                          [NSString stringWithFormat:@"%@%@.json", kRestaurantsURL, [[DataModel getInstance] restaurant]]];
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

- (Menu *)menu {
    Menu *menudate;
    for (Menu *m in [self menus])
        if ([[m date] isEqualToString:_date])
            menudate = m;

  return menudate;
}

- (Restaurant *)restaurant {
    Restaurant *res;
    for (Restaurant *r in [self restaurantsByCampus])
        if ([[r title] isEqualToString:_restaurantName])
            res = r;

          return res;
}

- (NSMutableArray *)restaurantsByCampus {
  
  _restaurantsByCampus = [[NSMutableArray alloc] init];

  //read from file
  NSError *error;
  NSString *strFileContent = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource: @"restaurants" ofType: @"json"] encoding:NSUTF8StringEncoding error:&error];
  
  if (!error) {
    
    NSData *objectData = [strFileContent dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData options: NSJSONReadingMutableContainers error: &error];
    
    if (!error) {
      for (id campus in [json valueForKey:@"campi"])
        [_restaurantsByCampus addObject:campus];
    }else{
      NSLog(@"%@", error);
    }
  }

  return _restaurantsByCampus;

}

-(Cash *)cash
{
    NSMutableArray *items = [[NSMutableArray alloc] init];
    NSDictionary *json = (NSDictionary *)[self iniciar_JSONBinding: [NSString stringWithFormat:@"%@restaurantes.json", kRestaurantsURL]];
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
