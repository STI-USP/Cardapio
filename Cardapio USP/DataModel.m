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
    NSData *userDataRaw = [defaults objectForKey:@"userData"];
    
    if (userDataRaw == nil || [userDataRaw isKindOfClass:[NSNull class]]) {
      return nil; // Retorna nil se os dados não existirem ou forem NSNull
    }
    
    NSError *error = nil;
    NSDictionary *userData = [NSJSONSerialization JSONObjectWithData:userDataRaw options:NSJSONReadingMutableContainers error:&error];
    
    if (error || ![userData isKindOfClass:[NSDictionary class]]) {
      // Retorna nil se houver erro na desserialização ou se o formato não for um NSDictionary
      return nil;
    }
    
    return userData;
  } else {
    return nil; // Retorna nil se o usuário não estiver logado
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
    } else {
      logNetworkError(operation, responseObject, statusCode, @"restaurants", webServicePath);
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
      logNetworkError(operation, responseObject, statusCode, @"menu", webServicePath);
      [SVProgressHUD showErrorWithStatus:@"Não foi possível obter o cardápio. Tente novamente mais tarde."];
    }
  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
    NSLog(@"error::: %@", error.localizedDescription);
    [SVProgressHUD showErrorWithStatus:@"Não foi possível obter o cardápio. Tente novamente mais tarde."];
    //NSLog(@"%@", error);
  }];
}

static void logNetworkError(AFHTTPRequestOperation *operation, id responseObject, NSInteger statusCode, NSString *endpointName, NSString *urlPath) {
  
  NSString *logMessage = [NSString stringWithFormat:@"Resposta com status diferente de 200 na chamada ao %@", endpointName];
  [[FIRCrashlytics crashlytics] log:logMessage];
  
  [[FIRCrashlytics crashlytics] setCustomValue:@(statusCode) forKey:[NSString stringWithFormat:@"%@_http_status", endpointName]];
  [[FIRCrashlytics crashlytics] setCustomValue:urlPath forKey:[NSString stringWithFormat:@"%@_url", endpointName]];
  
  NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
  [formatter setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
  [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"America/Sao_Paulo"]];
  NSString *timestamp = [formatter stringFromDate:[NSDate date]];
  [[FIRCrashlytics crashlytics] setCustomValue:timestamp forKey:[NSString stringWithFormat:@"%@_timestamp", endpointName]];
  
  // Trecho da resposta
  if ([responseObject isKindOfClass:[NSData class]]) {
    NSString *responseString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
    if (responseString.length > 300) {
      responseString = [responseString substringToIndex:300];
    }
    [[FIRCrashlytics crashlytics] setCustomValue:responseString forKey:[NSString stringWithFormat:@"%@_response_snippet", endpointName]];
  }
  
  // Content-Type (header)
  NSString *contentType = operation.response.allHeaderFields[@"Content-Type"];
  if (contentType) {
    [[FIRCrashlytics crashlytics] setCustomValue:contentType forKey:[NSString stringWithFormat:@"%@_content_type", endpointName]];
  }
}

- (void)getCreditoRUCard {
  [dataAccess consultarSaldo];
}

- (NSMutableArray *)getCampiList{
  return self.restaurantList;
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
