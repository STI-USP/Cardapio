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
#import "OAuthUSP.h"
#import "DataAccess.h"
#import "Constants.h"

@import Firebase;

#define kRestaurantsURL @"http://kaimbu2.uspnet.usp.br:8080/cardapio/"
//#define kBaseURL @"http://kaimbu2.uspnet.usp.br:8080/"

#define kToken @"596df9effde6f877717b4e81fdb2ca9f"

@interface DataModel () {
  OAuthUSP *oauth;
  DataAccess *dataAccess;
}

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
    //    [instance setDefault];
  });
  return instance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    oauth = [OAuthUSP sharedInstance];
    dataAccess = [DataAccess sharedInstance];
    [dataAccess setDataModel:self];
  }
  return self;
}

- (NSDictionary *)userData {
  if ([self isLoggedIn]) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    _userData = [NSJSONSerialization JSONObjectWithData:[[defaults objectForKey:@"userData"] copy] options: NSJSONReadingMutableContainers error: nil];
    
    return _userData;
  } else {
    return nil;
  }
}

- (void)getRestaurantList {
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  manager.requestSerializer = [AFHTTPRequestSerializer serializer];
  manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/x-www-form-urlencoded"];
  manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  
  NSString *webServicePath;
  webServicePath = [NSString stringWithFormat:@"%@restaurants", kBaseRUCardURL];
  
  NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys: kToken , @"hash", nil];
  
  [manager POST:webServicePath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject){
    self.restaurants = [[NSMutableArray alloc] init];
    
    
    NSInteger statusCode = [operation.response statusCode];
    if (statusCode == 200) {
      NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:responseObject options: NSJSONReadingMutableContainers error: nil];
      for (NSMutableDictionary *campus in json){
        [self.restaurants addObject:campus];
      }
      if ([self.restaurants count] != 0) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:self.restaurants forKey:@"Restaurants"];
        
        for (NSDictionary *campus in self.restaurants) {
          NSArray *restaurantsArray = campus[@"restaurants"];
          for (NSMutableDictionary *restaurant in restaurantsArray) {
            NSString *restaurantId = restaurant[@"id"];
            NSString *preferredRestaurantId = [[defaults objectForKey:@"preferredRestaurant"] valueForKey:@"id"];
            
            if ([restaurantId isEqualToString:preferredRestaurantId]) {
              self.preferredRestaurant = restaurant;
              self.currentRestaurant = restaurant;
              break;
            }
          }
        }
        
        if (!self.currentRestaurant && self.restaurants.count > 0) {
          // Inicialmente assumimos que o restaurante "CUASO" não foi encontrado.
          BOOL cuasoFound = NO;
          
          // Itera sobre os campi e restaurantes para encontrar "CUASO".
          for (NSDictionary *campus in self.restaurants) {
            NSArray *restaurantsArray = campus[@"restaurants"];
            for (NSDictionary *restaurant in restaurantsArray) {
              NSNumber *restaurantId = restaurant[@"id"];
              if (restaurantId.intValue == 6) { // Restaurante central
                self.currentRestaurant = [restaurant mutableCopy];
                break; // Sai do loop interno uma vez que o restaurante com ID 6 foi encontrado.
              }
            }
            if (cuasoFound) {
              break; // Interrompe o loop externo se "CUASO" foi encontrado.
            }
          }
          
          // Se Central não foi encontrado, então define o primeiro restaurante como current.
          if (!cuasoFound) {
            NSDictionary *firstCampus = [self.restaurants firstObject];
            NSArray *restaurantsArray = firstCampus[@"restaurants"];
            
            if (restaurantsArray.count > 0) {
              self.currentRestaurant = [restaurantsArray firstObject];
            }
          }
        }
        
        [defaults synchronize];
      }
      // Notifica atualizações
      [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveRestaurants" object:self];
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.restaurants = [defaults objectForKey:@"Restaurants"];
    NSLog(@"%@", error);
    // Notifica atualizações
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveRestaurants" object:self];
  }];
}

- (void)getMenu {
  
  [SVProgressHUD show];
  [[FIRCrashlytics crashlytics] setCustomValue:@"" forKey:@""];
  
  [FIRAnalytics logEventWithName:@"share_image"
                      parameters:@{
    @"name": @"",
    @"full_text": @""
  }];
  
  self.menuArray = [[NSMutableArray alloc] init];
  
  AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
  manager.requestSerializer = [AFHTTPRequestSerializer serializer];
  manager.responseSerializer.acceptableContentTypes = [NSSet setWithObject:@"application/x-www-form-urlencoded"];
  manager.responseSerializer = [AFHTTPResponseSerializer serializer];
  
  NSString *webServicePath;
  webServicePath = [NSString stringWithFormat:@"%@menu/%@", kBaseRUCardURL, [self.currentRestaurant valueForKey:@"id"]];
  
  //NSLog(@"%@", webServicePath);
  
  NSDictionary *parameters = nil;
  parameters = [NSDictionary dictionaryWithObjectsAndKeys:
                kToken , @"hash",
                nil];
  
  [manager POST:webServicePath parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
    
    
    NSInteger statusCode = [operation.response statusCode];
    if (statusCode == 200) {
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
        self.observation = [[json objectForKey:@"observation"] valueForKey:@"observation"];
        [SVProgressHUD dismiss];
      } else {
        for (int i = 1; i<=7; i++) {
          NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
          
          NSDate *today = [NSDate date];
          NSDate *beginningOfWeek = nil;
          [gregorian rangeOfUnit:NSCalendarUnitWeekOfMonth startDate:&beginningOfWeek interval:NULL forDate:today];
          NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
          [dateFormatter setDateFormat:@"dd-MM-yyyy"];
          NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
          [dateComponents setDay:i];
          NSDate *newDate = [[NSCalendar currentCalendar] dateByAddingComponents:dateComponents toDate:beginningOfWeek options:0];
          
          Menu *menu = [[Menu alloc] initWithDate:[dateFormatter stringFromDate:newDate] andPeriod:nil];
          [self.menuArray addObject:menu];
        }
        [SVProgressHUD showErrorWithStatus:@"Não foi possível obter o cardápio. Tente novamente mais tarde."];
      }
      // Notifica atualizações
      [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveMenu" object:self];
    } else {
      [SVProgressHUD showErrorWithStatus:@"Não foi possível obter o cardápio. Tente novamente mais tarde."];
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"error::: %@", error.localizedDescription);
    [SVProgressHUD showErrorWithStatus:@"Não foi possível obter o cardápio. Tente novamente mais tarde."];
    //NSLog(@"%@", error);
  }];
}

//- (void)getRestaurantList {
//    NSString *webServicePath = [NSString stringWithFormat:@"%@restaurants", kBaseRUCardURL];
//    
//    // Configura os parâmetros
//    NSDictionary *parameters = @{ @"hash": kToken };
//    
//    // Cria a requisição
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:webServicePath]];
//    [request setHTTPMethod:@"POST"];
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    
//    // Serializa os parâmetros
//    NSError *error;
//    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
//    if (error) {
//        NSLog(@"Erro ao serializar parâmetros: %@", error.localizedDescription);
//        return;
//    }
//    [request setHTTPBody:bodyData];
//    
//    // Cria a sessão e a tarefa de requisição
//    NSURLSession *session = [NSURLSession sharedSession];
//    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        if (error) {
//            NSLog(@"Erro na requisição: %@", error.localizedDescription);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//                self.restaurants = [defaults objectForKey:@"Restaurants"];
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveRestaurants" object:self];
//            });
//            return;
//        }
//        
//        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//        if (httpResponse.statusCode == 200) {
//            NSError *jsonError;
//            NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
//            
//            if (jsonError) {
//                NSLog(@"Erro ao parsear JSON: %@", jsonError.localizedDescription);
//                return;
//            }
//            
//            self.restaurants = [[NSMutableArray alloc] init];
//            for (NSMutableDictionary *campus in json) {
//                [self.restaurants addObject:campus];
//            }
//            
//            if ([self.restaurants count] != 0) {
//                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
//                [defaults setObject:self.restaurants forKey:@"Restaurants"];
//                [defaults synchronize];
//                
//                // Seleciona o restaurante preferido
//                for (NSDictionary *campus in self.restaurants) {
//                    NSArray *restaurantsArray = campus[@"restaurants"];
//                    for (NSMutableDictionary *restaurant in restaurantsArray) {
//                        NSString *restaurantId = restaurant[@"id"];
//                        NSString *preferredRestaurantId = [[defaults objectForKey:@"preferredRestaurant"] valueForKey:@"id"];
//                        
//                        if ([restaurantId isEqualToString:preferredRestaurantId]) {
//                            self.preferredRestaurant = restaurant;
//                            self.currentRestaurant = restaurant;
//                            break;
//                        }
//                    }
//                }
//                
//                // Caso o restaurante preferido não tenha sido encontrado
//                if (!self.currentRestaurant && self.restaurants.count > 0) {
//                    BOOL cuasoFound = NO;
//                    for (NSDictionary *campus in self.restaurants) {
//                        NSArray *restaurantsArray = campus[@"restaurants"];
//                        for (NSDictionary *restaurant in restaurantsArray) {
//                            NSNumber *restaurantId = restaurant[@"id"];
//                            if (restaurantId.intValue == 6) { // Restaurante central
//                                self.currentRestaurant = [restaurant mutableCopy];
//                                cuasoFound = YES;
//                                break;
//                            }
//                        }
//                        if (cuasoFound) break;
//                    }
//                    
//                    // Se "CUASO" não foi encontrado, define o primeiro restaurante
//                    if (!cuasoFound) {
//                        NSDictionary *firstCampus = [self.restaurants firstObject];
//                        NSArray *restaurantsArray = firstCampus[@"restaurants"];
//                        if (restaurantsArray.count > 0) {
//                            self.currentRestaurant = [restaurantsArray firstObject];
//                        }
//                    }
//                }
//            }
//            
//            // Notifica atualizações
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveRestaurants" object:self];
//            });
//        }
//    }];
//    
//    // Inicia a tarefa
//    [dataTask resume];
//}
//
//- (void)getMenu {
//    [SVProgressHUD show];
//    self.menuArray = [[NSMutableArray alloc] init];
//    
//    NSString *webServicePath = [NSString stringWithFormat:@"%@menu/%@", kBaseRUCardURL, [self.currentRestaurant valueForKey:@"id"]];
//    NSDictionary *parameters = @{ @"hash": kToken };
//    
//    // Cria a requisição
//    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:webServicePath]];
//    [request setHTTPMethod:@"POST"];
//    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
//    
//    // Serializa os parâmetros
//    NSError *error;
//    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:&error];
//    if (error) {
//        NSLog(@"Erro ao serializar parâmetros: %@", error.localizedDescription);
//        return;
//    }
//    [request setHTTPBody:bodyData];
//    
//    // Cria a sessão e a tarefa de requisição
//    NSURLSession *session = [NSURLSession sharedSession];
//    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
//        if (error) {
//            NSLog(@"Erro na requisição: %@", error.localizedDescription);
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [SVProgressHUD showErrorWithStatus:@"Não foi possível obter o cardápio. Tente novamente mais tarde."];
//            });
//            return;
//        }
//        
//        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
//        if (httpResponse.statusCode == 200) {
//            NSError *jsonError;
//            NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&jsonError];
//            
//            if (jsonError) {
//                NSLog(@"Erro ao parsear JSON: %@", jsonError.localizedDescription);
//                return;
//            }
//            
//            if (![[[json valueForKey:@"message"] valueForKey:@"error"] boolValue]) {
//                for (NSMutableDictionary *rawItem in [json valueForKey:@"meals"]) {
//                    NSMutableDictionary *item = [self cleanDictionary:rawItem];
//                    NSMutableArray *period = [[NSMutableArray alloc] init];
//                    
//                    if (![item[@"lunch"] isKindOfClass:[NSString class]]) {
//                        Period *lunch = [[Period alloc] initWithPeriod:@"lunch" andMenu:item[@"lunch"][@"menu"] andCalories:item[@"lunch"][@"calories"]];
//                        [period addObject:lunch];
//                    }
//                    
//                    if (![item[@"dinner"] isKindOfClass:[NSString class]]) {
//                        Period *dinner = [[Period alloc] initWithPeriod:@"dinner" andMenu:item[@"dinner"][@"menu"] andCalories:item[@"dinner"][@"calories"]];
//                        [period addObject:dinner];
//                    }
//                    
//                    Menu *menu = [[Menu alloc] initWithDate:item[@"date"] andPeriod:period];
//                    [self.menuArray addObject:menu];
//                }
//                
//                self.observation = json[@"observation"][@"observation"];
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [SVProgressHUD dismiss];
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveMenu" object:self];
//                });
//            } else {
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [SVProgressHUD showErrorWithStatus:@"Não foi possível obter o cardápio. Tente novamente mais tarde."];
//                });
//            }
//        } else {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [SVProgressHUD showErrorWithStatus:@"Não foi possível obter o cardápio. Tente novamente mais tarde."];
//            });
//        }
//    }];
//    [dataTask resume];
//}

- (void)getCreditoRUCard {
  [dataAccess consultarSaldo];
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

- (Cash *)cash {
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

- (BOOL) isLoggedIn {
  return [oauth isLoggedIn];
}

@end
