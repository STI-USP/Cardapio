//
//  DataModel.m
//  Cardapio USP
//
//  Created by Vagner Machado on 5/21/15.
//  Copyright (c) 2015 EPUSP. All rights reserved.
//

#import "DataModel.h"
#import "Period.h"
#import "Items.h"
#import "AFNetworking.h"

#define kRestaurantsURL @"http://kaimbu2.uspnet.usp.br:8080/cardapio/"
#define kBaseURL @"http://kaimbu2.uspnet.usp.br:8080/"

#define kBaseDevSTIURL @"https://dev.uspdigital.usp.br/rucard/servicos/"
#define kBaseSTIURL @"https://uspdigital.usp.br/rucard/servicos/"


@interface DataModel () {
  
}

@property (strong, nonatomic) NSMutableArray *restaurantList;
@property (strong, nonatomic) NSMutableArray *campiList;
@property (strong, nonatomic) NSMutableDictionary *restaurantDict;

@end

@implementation DataModel {
}


+(DataModel *) getInstance {
  static DataModel *instance = nil;
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    instance = [[DataModel alloc] init];
    instance.restaurantId = @"10";
    instance.restaurantName = @"Central";
    instance.campus = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"CUASO", nil]
                                                          forKeys:[NSArray arrayWithObjects:@"name", nil]];
  });

  return instance;
}


#pragma mark Setters

- (void)setRestaurantList:(NSMutableArray *)restaurants {
  _restaurantList = [restaurants copy]; // copia lista
  
  // Notifica atualizações
  [[NSNotificationCenter defaultCenter] postNotificationName:@"DidRecieveRestaurants" object:self];
}



- (NSMutableArray *)getMenu {
  
  NSMutableArray *menuArray = [[NSMutableArray alloc] init];
  
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  
  NSString *webServicePath;
  webServicePath = [NSString stringWithFormat:@"%@menu/%d", kBaseDevSTIURL, 1];
  
  NSDictionary *parameters = nil;
  parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                @"596df9effde6f877717b4e81fdb2ca9f" , @"hash",
                nil];
  
  [manager GET:webServicePath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
    // Parse da resposta
    NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options: NSJSONReadingMutableContainers error: nil];
    for(NSMutableDictionary *item in json) {
      NSMutableArray *period = [[NSMutableArray alloc] init];
      
      if ([item objectForKey:@"breakfast"] != nil) {
        Period *breakfast = [[Period alloc] initWithPeriod:@"breakfast" andMenu:[item   objectForKey:@"breakfast"][@"menu"] andCalories:[item objectForKey:@"breakfast"][@"calories"]];
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
      
      Menu *menu = [[Menu alloc] initWithDate:[item objectForKey:@"date"] andPeriod:period];
      [menuArray addObject:menu];
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"%@", error);
  }];

  return menuArray;
  
  /*
  NSMutableArray *json = [self iniciar_JSONBinding:
                          [NSString stringWithFormat:@"%@%@.json", kRestaurantsURL, @"central"]];
  _menus = [[NSMutableArray alloc] init];
  
  if (!json) {
    NSLog(@"Error parsing JSON: %@", nil);
  } else {
    for(NSMutableDictionary *item in json) {
      NSMutableArray *period = [[NSMutableArray alloc] init];
      
      // [di:150316] Teste se refeicao diaria presente no json, cria o array com os periodos de refeicao
      if ([item objectForKey:@"breakfast"] != nil) {
        Period *breakfast = [[Period alloc] initWithPeriod:@"breakfast" andMenu:[item objectForKey:@"breakfast"][@"menu"] andCalories:[item objectForKey:@"breakfast"][@"calories"]];
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
   */
}


- (NSMutableArray *) getRestaurants{
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
  
  /*
  //Define parametros para webservice
  NSDictionary *parameters;
  parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                @"value", @"key",
                @"value", @"key",
                nil];
  
  //Monta requisição
  AFSecurityPolicy *policy = [[AFSecurityPolicy alloc] init];
  [policy setAllowInvalidCertificates:YES];
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  [manager setSecurityPolicy:policy];
  manager.requestSerializer = [AFHTTPRequestSerializer serializer];
  manager.responseSerializer = [AFJSONResponseSerializer serializer];
  
  //Executa requisição
  [manager POST: [NSString stringWithFormat:@"%@", kBaseDevSTIURL]
     parameters:parameters
        success:^(AFHTTPRequestOperation *operation, id responseObject) {
          // Parse da resposta
          for (id restaurant in [responseObject objectForKey:@"publications"])
            [_restaurantsByCampus addObject:restaurant];
          
          // Atualiza resultado da busca no modelo
          [self setRestaurantList:_restaurantsByCampus];
          
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
          UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Acesso à rede de dados" message:[error localizedDescription]delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
          [alertView show];
        }
   ];
  return _restaurantList;
   */
}


- (NSMutableArray *)getCampiList{
  return self.restaurantList;
}


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
  for (Restaurant *r in [self restaurantList]) {
    if ([[r title] isEqualToString:_restaurantName]) {
      res = r;
    }
  }
  return res;
}

/**
 *  Obtem uma lista de restaurantes, com informacoes de cada um a partir de um campi, formato REST JSON
 *  param _campi
 */
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
