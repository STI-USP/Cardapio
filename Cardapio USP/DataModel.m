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

+(DataModel *) getInstance {
  static DataModel *instance = nil;
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    instance = [[DataModel alloc] init];
    [instance setDefault];
  });
  return instance;
}

- (void) getRestaurants{
  
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  manager.requestSerializer = [AFHTTPRequestSerializer serializer];
  manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/x-www-form-urlencoded"];
  manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  
  NSString *webServicePath;
  webServicePath = [NSString stringWithFormat:@"%@restaurants", kBaseDevSTIURL];
  
  NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"596df9effde6f877717b4e81fdb2ca9f" , @"hash", nil];
  
  [manager GET:webServicePath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject){
    //[manager POST:webServicePath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject){
    self.restaurants = [[NSMutableArray alloc] init];

    // Parse da resposta
    NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options: NSJSONReadingMutableContainers error: nil];
    for (id campus in json){
      [self.restaurants addObject:campus];
    }
    
    // Notifica atualizações
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveRestaurants" object:self];
    
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"%@", error);
  }];
  
}

- (void)getMenu {
  
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
  
  //[manager POST: webServicePath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
  [manager GET:webServicePath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
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

- (NSMutableArray *) iniciar_JSONBinding:(NSString *)_url
{
  NSURL *url1 = [NSURL URLWithString:_url];
  NSMutableURLRequest *req1 = [NSMutableURLRequest requestWithURL:url1];
  NSError *error;
  NSURLResponse *resp = nil;
  NSData *data = [NSURLConnection sendSynchronousRequest:req1 returningResponse:&resp error:&error];
  NSMutableArray* json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers  error:&error];
  return json;
}

-(Cash *)cash {
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


#pragma mark Setters

- (void)setDefault {
  self.campus = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"CUASO", nil]
                                                   forKeys:[NSArray arrayWithObjects:@"name", nil]];
  
  //
  NSDictionary *dcPhones = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"(11) 2648-1172", nil]
                                                              forKeys:[NSArray arrayWithObjects:@"", nil]];
  NSDictionary *dcCashiers = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"", nil]
                                                                forKeys:[NSArray arrayWithObjects:@"", nil]];
  NSDictionary *dcWorkingHours = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"", nil]
                                                                    forKeys:[NSArray arrayWithObjects:@"", nil]];
  
  [self setCurrentRestaurant:[NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"Praça do Relógio Solar, travessa 8, n300", @"Central", dcPhones, @"6", @"0", dcCashiers, @"http://www.usp.br/coseas/COSEASHP/ALM/fotosnovaRestCentral/SAS-USP%20Restaurante%20Central%20252-12%20Foto%20Francisco%20Emolo%20043.jpg", @"0", @"CENTRAL - São Paulo", dcWorkingHours, nil]
                                                                forKeys:[NSArray arrayWithObjects:@"address", @"alias", @"phones", @"id", @"longitude", @"cashiers", @"photourl", @"latitude", @"name", @"workinghours", nil]]];
  [self setPreferredRestaurant: self.currentRestaurant];
}

- (void)setPreferredRestaurant:(NSDictionary *)preferredRestaurant {
  _preferredRestaurant = [preferredRestaurant copy];

  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  //[defaults setValue:_preferredRestaurant forKey:@"preferredRestaurant"];
  [defaults synchronize];
}

- (void)setRestaurantList:(NSMutableArray *)restaurants {
  _restaurantList = [restaurants copy]; // copia lista
  
  // Notifica atualizações
  [[NSNotificationCenter defaultCenter] postNotificationName:@"DidRecieveRestaurants" object:self];
}

//limpa os objetos com NULL
- (NSMutableDictionary *) cleanDictionary: (NSMutableDictionary *)dictionary {
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
