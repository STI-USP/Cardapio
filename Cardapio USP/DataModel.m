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
#import "SVProgressHUD.h"

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
  webServicePath = [NSString stringWithFormat:@"%@restaurants", kBaseSTIURL];
  
  NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: @"596df9effde6f877717b4e81fdb2ca9f" , @"hash", nil];
  
  [manager POST:webServicePath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject){
    self.restaurants = [[NSMutableArray alloc] init];

    // Parse da resposta
    NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options: NSJSONReadingMutableContainers error: nil];
    for (NSMutableDictionary *campus in json){
      [self.restaurants addObject:campus];
    }
    if ([self.restaurants count] != 0) {
      NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
      [defaults setObject:self.restaurants forKey:@"Restaurants"];
      [defaults synchronize];    }
      // Notifica atualizações
      [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveRestaurants" object:self];
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.restaurants = [defaults objectForKey:@"Restaurants"];
    NSLog(@"%@", error);
    // Notifica atualizações
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveRestaurants" object:self];

  }];
}

- (void)getMenu{
  
  [SVProgressHUD show];
  
  self.menuArray = [[NSMutableArray alloc] init];
  
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  manager.requestSerializer = [AFHTTPRequestSerializer serializer];
  manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/x-www-form-urlencoded"];
  manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  
  NSString *webServicePath;
  webServicePath = [NSString stringWithFormat:@"%@menu/%@", kBaseSTIURL, [self.currentRestaurant valueForKey:@"id"]];
  
  NSLog(@"%@", webServicePath);
  
  NSDictionary *parameters = nil;
  parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                @"596df9effde6f877717b4e81fdb2ca9f" , @"hash",
                nil];
  
  [manager POST: webServicePath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    // Parse da resposta
    NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options: NSJSONReadingMutableContainers error: nil];
    
    if (![[[json valueForKey:@"message"] valueForKey:@"error"] boolValue]) {
      for(NSMutableDictionary *rawItem in [json valueForKey:@"meals"]) {
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
      self.observation = [[json objectForKey:@"observation"]valueForKey:@"observation"];
    } else {
      
      for (int i = 1; i<=7; i++) {
        NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        
        NSDate *today = [NSDate date];
        NSDate *beginningOfWeek = nil;
        [gregorian rangeOfUnit:NSWeekCalendarUnit startDate:&beginningOfWeek interval:NULL forDate:today];
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateFormat:@"dd-MM-yyyy"];
        
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        [dateComponents setDay:i];
        
        NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:beginningOfWeek options:0];
        
        Menu *menu = [[Menu alloc] initWithDate:[dateFormatter stringFromDate:newDate] andPeriod:nil];
        [self.menuArray addObject:menu];
      }
      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Aviso" message:@"Não foi possível obter o cardápio. \nTente novamente mais tarde." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
      [alertView show];
    }

    // Notifica atualizações
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveMenu" object:self];
    [SVProgressHUD dismiss];

  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Aviso" message:@"Não foi possível obter o cardápio. \nTente novamente mais tarde." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
    [alertView show];
    [SVProgressHUD dismiss];

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

#pragma mark Setters

- (void)setDefault { //restaurante default para quando não houver nenhum selecionado

  NSError *jsonError;
  NSString *defString = @"{\"alias\" : \"Central\",\"address\" : \"Praça do Relógio Solar, travessa 8, no 300, Campus Butantã, São Paulo - SP\",\"name\" : \"Central\",\"phones\" : \"(11) 3091-3318\",\"id\" : \"6\",\"latitude\" : \"-23.56021110\",\"longitude\" : \"-46.7218170\",\"photourl\" : \"http://bahamas.uspnet.usp.br/dominios/cce/servicos/restaurantesUSP/central.jpg\",\"workinghours\" : {\"sunday\" : {\"lunch\" : \"12:00 às 14:15\",\"breakfast\" : \"08:00 às 09:30\",\"dinner\" : \"\"},\"saturday\" : {\"lunch\" : \"11:15 às 14:15\",\"breakfast\" : \"07:30 às 09:00\",\"dinner\" : \"\"},\"weekdays\" : {\"lunch\" : \"11:15 às 14:15\",\"breakfast\" : \"07:00 às 08:30\",\"dinner\" : \"17:30 às 19:45\"}},\"cashiers\" : [ {\"address\" : \"Rua do Anfiteatro, nº 295 - Cidade Universitária - São Paulo - CEP 05508-060\",\"prices\" : {\"special\" : {\"dinner\" : \"6,00\",\"lunch\" : \"6,00\",\"breakfast\" : \"\"},\"students\" : {\"dinner\" : \"1,90\",\"lunch\" : \"1,90\",\"breakfast\" : \"\"},\"visiting\" : {\"dinner\" : \"12,00\",\"lunch\" : \"12,00\",\"breakfast\" : \"\"},\"employees\" : {\"dinner\" : \"12,00\",\"lunch\" : \"12,00\",\"breakfast\" : \"\"}},\"longitude\" : \"-46.7216980\",\"latitude\" : \"-23.5594340\",\"workinghours\" : \"Segunda à Sexta - 7h as 19h30\"} ],\"hasCashier\" : \"false\"}";
  
  NSData *objectData = [defString dataUsingEncoding:NSUTF8StringEncoding];
  NSMutableDictionary *defaultRestaurant = [NSJSONSerialization JSONObjectWithData:objectData
                                                       options:NSJSONReadingMutableContainers
                                                         error:&jsonError];
  
  if (!jsonError) {
    [self setCurrentRestaurant:defaultRestaurant];
  } else {
    NSLog(@"%@", [jsonError description]);
  }
  
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
  
  if ([[[_preferredRestaurant valueForKey:@"workinghours"] valueForKey:@"weekdays"] isKindOfClass:[NSNull class]])
    [[_preferredRestaurant valueForKey:@"workinghours"] setValue:emptyDc forKey:@"weekdays"];

  if ([[[_preferredRestaurant valueForKey:@"workinghours"] valueForKey:@"saturday"] isKindOfClass:[NSNull class]])
    [[_preferredRestaurant valueForKey:@"workinghours"] setValue:emptyDc forKey:@"saturday"];

  if ([[[_preferredRestaurant valueForKey:@"workinghours"] valueForKey:@"sunday"] isKindOfClass:[NSNull class]])
    [[_preferredRestaurant valueForKey:@"workinghours"] setValue:emptyDc forKey:@"sunday"];

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
