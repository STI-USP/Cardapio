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

@interface DataModel ()

@property (strong, nonatomic) NSMutableArray *restaurantList;
@property (strong, nonatomic) NSMutableArray *campiList;
@property (strong, nonatomic) NSMutableDictionary *restaurantDict;
@end

@implementation DataModel

+(DataModel *)getInstance {
  static DataModel *instance = nil;
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    instance = [[DataModel alloc] init];
    [instance setDefault];
  });
  return instance;
}

- (void)getRestaurantList {
  
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  manager.requestSerializer = [AFHTTPRequestSerializer serializer];
  manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/x-www-form-urlencoded"];
  manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  
  NSString *webServicePath;
  webServicePath = [NSString stringWithFormat:@"%@restaurants", kBaseDevSTIURL];
  
  NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"596df9effde6f877717b4e81fdb2ca9f" , @"hash", nil];
  
  [manager POST:webServicePath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject){
    self.restaurants = [[NSMutableArray alloc] init];

    // Parse da resposta
    NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options: NSJSONReadingMutableContainers error: nil];
    for (NSMutableDictionary *campus in json){
      [self.restaurants addObject:campus];
    }
    // Notifica atualizações
    //[[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveRestaurants" object:self];
    
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    //ler do arquivo
    
    NSLog(@"%@", error);
  }];
}

- (void)getMenu{
  
  self.menuArray = [[NSMutableArray alloc] init];
  
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  manager.requestSerializer = [AFHTTPRequestSerializer serializer];
  manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/x-www-form-urlencoded"];
  manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  
  NSString *webServicePath;
  webServicePath = [NSString stringWithFormat:@"%@menu/%d", kBaseDevSTIURL, 1];
  
  NSDictionary *parameters = nil;
  parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                @"596df9effde6f877717b4e81fdb2ca9f" , @"hash",
                nil];
  
  [manager POST: webServicePath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    // Parse da resposta
    NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options: NSJSONReadingMutableContainers error: nil];
    for(NSMutableDictionary *rawItem in json) {
      NSMutableDictionary *item = [self cleanDictionary:rawItem];
      
      NSMutableArray *period = [[NSMutableArray alloc] init];
      if (![[item objectForKey:@"lunch"]isKindOfClass:[NSString class]]) {
        Period *lunch = [[Period alloc ] initWithPeriod:@"lunch" andMenu:[item objectForKey:@"lunch"][@"menu"] andCalories:[item objectForKey:@"lunch"][@"calories"]];
        [period addObject:lunch];
      }
      
      if (![[item valueForKey:@"dinner"] isKindOfClass:[NSString class]]) {
        Period *dinner = [[Period alloc ] initWithPeriod:@"dinner" andMenu:[item objectForKey:@"dinner"][@"menu"] andCalories:[item objectForKey:@"dinner"][@"calories"]];
        [period addObject:dinner];
      }
      
      Menu *menu = [[Menu alloc] initWithDate:[item objectForKey:@"date"] andPeriod:period];
      [self.menuArray addObject:menu];
    }
    // Notifica atualizações
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveMenu" object:self];
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"%@", error);
  }];
}


- (NSMutableArray *)getCampiList{
  return self.restaurantList;
}

- (NSMutableArray *)iniciar_JSONBinding:(NSString *)_url {
  NSURL *url1 = [NSURL URLWithString:_url];
  NSMutableURLRequest *req1 = [NSMutableURLRequest requestWithURL:url1];
  NSError *error;
  NSURLResponse *resp = nil;
  NSData *data = [NSURLConnection sendSynchronousRequest:req1 returningResponse:&resp error:&error];
  NSMutableArray* json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:&error];
  return json;
}

- (Cash *)cash{
  NSMutableArray *items = [[NSMutableArray alloc] init];
  NSDictionary *json = (NSDictionary *)[self iniciar_JSONBinding: [NSString stringWithFormat:@"%@restaurantes.json", kRestaurantsURL]];
  if (!json) {
    NSLog(@"Error parsing JSON: %@", nil);
  } else {
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

#pragma mark Getters

- (NSMutableArray *)restaurants{
  NSString *filePath = [[NSBundle mainBundle] pathForResource:@"restaurants" ofType:@"json"];
  if (filePath) {
    NSString *jsonString = [NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil];
    if (jsonString) {
      NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
      NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: nil];
      for (NSMutableDictionary *campus in json){
        [self.restaurants addObject:campus];
      }
    }
  }
  return self.restaurants;
}


#pragma mark Setters

- (void)setRestaurants:(NSMutableArray *)restaurants {
  
}

- (void)setDefault { //restaurante default para quando não houver nenhum selecionado
  self.campus = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"São Paulo - Cidade Universitária \"Armando de Salles Oliveira\"", nil]
                                                   forKeys:[NSArray arrayWithObjects:@"name", nil]];
  
  NSDictionary *dcPhones = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"(11) 3091-3318", nil]
                                                              forKeys:[NSArray arrayWithObjects:@"", nil]];
  NSDictionary *dcCashiers = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"", nil]
                                                                forKeys:[NSArray arrayWithObjects:@"", nil]];
  NSDictionary *dcWorkingHours = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"", nil]
                                                                    forKeys:[NSArray arrayWithObjects:@"", nil]];
  
  [self setCurrentRestaurant:[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Praça do Relógio Solar, travessa 8, 300, Cidade Universitária, São Paulo - SP", @"Central", dcPhones, @"6", @"-46.7212049", dcCashiers, @"http://bahamas.uspnet.usp.br/dominios/cce/servicos/restaurantesUSP/central.jpg", @"-23.5598117", @"Restaurante Central", dcWorkingHours, nil]
                                                                forKeys:[NSArray arrayWithObjects:@"address", @"alias", @"phones", @"id", @"longitude", @"cashiers", @"photourl", @"latitude", @"name", @"workinghours", nil]]];
  [self setPreferredRestaurant: self.currentRestaurant];
}

- (void)setCurrentRestaurant:(NSDictionary *)currentRestaurant {
  _currentRestaurant = [currentRestaurant copy];
  
  NSMutableDictionary *emptyDc = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"", @"", @"", nil] forKeys:[NSArray arrayWithObjects:@"breakfast", @"lunch", @"dinner", nil]];
  
  if ([[[_currentRestaurant valueForKey:@"workinghours"] valueForKey:@"weekdays"] isKindOfClass:[NSNull class]]) {
    [[_currentRestaurant valueForKey:@"workinghours"] setValue:emptyDc forKey:@"weekdays"];
  }
  if ([[[_currentRestaurant valueForKey:@"workinghours"] valueForKey:@"saturday"] isKindOfClass:[NSNull class]]) {
    [[_currentRestaurant valueForKey:@"workinghours"] setValue:emptyDc forKey:@"saturday"];
  }
  if ([[[_currentRestaurant valueForKey:@"workinghours"] valueForKey:@"sunday"] isKindOfClass:[NSNull class]]) {
    [[_currentRestaurant valueForKey:@"workinghours"] setValue:emptyDc forKey:@"sunday"];
  }
}

- (void)setPreferredRestaurant:(NSDictionary *)preferredRestaurant {
  _preferredRestaurant = [preferredRestaurant copy];
  
  NSMutableDictionary *emptyDc = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"", @"", @"", nil] forKeys:[NSArray arrayWithObjects:@"breakfast", @"lunch", @"dinner", nil]];
  
  if ([[[_preferredRestaurant valueForKey:@"workinghours"] valueForKey:@"weekdays"] isKindOfClass:[NSNull class]]) {
    [[_preferredRestaurant valueForKey:@"workinghours"] setValue:emptyDc forKey:@"weekdays"];
  }
  if ([[[_preferredRestaurant valueForKey:@"workinghours"] valueForKey:@"saturday"] isKindOfClass:[NSNull class]]) {
    [[_preferredRestaurant valueForKey:@"workinghours"] setValue:emptyDc forKey:@"saturday"];
  }
  if ([[[_preferredRestaurant valueForKey:@"workinghours"] valueForKey:@"sunday"] isKindOfClass:[NSNull class]]) {
    [[_preferredRestaurant valueForKey:@"workinghours"] setValue:emptyDc forKey:@"sunday"];
  }

  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setValue:_preferredRestaurant forKey:@"preferredRestaurant"];
  [defaults synchronize];
}

- (void)setRestaurantList:(NSMutableArray *)restaurants {
  _restaurantList = [restaurants copy]; // copia lista
  
  // Notifica atualizações
  [[NSNotificationCenter defaultCenter] postNotificationName:@"DidRecieveRestaurants" object:self];
}

//limpa os objetos com NULL
- (NSMutableDictionary *)cleanDictionary: (NSMutableDictionary *)dictionary {
  [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    if (obj == [NSNull null]) {
      [dictionary setObject:@"" forKey:key];
    } else if ([obj isKindOfClass:[NSDictionary class]]) {
      [self cleanDictionary:obj];
    }
  }];
  return dictionary;
}

@end
