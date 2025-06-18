//
//  DataModel.m
//  Cardapio USP
//
//  Created by Vagner Machado on 21/05/15.
//  Revisitado em 18/06/25 — compatível com RestaurantServiceImpl (Swift)
//

#import "DataModel.h"
#import "Period.h"
#import "Items.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "OAuthUSP.h"
#import "DataAccess.h"
#import "Constants.h"
#import "Cardapio_USP-Swift.h"

@import Firebase;

#define kToken @"596df9effde6f877717b4e81fdb2ca9f"

@interface DataModel () {
  OAuthUSP *oauth;
  DataAccess *dataAccess;
}

//@property (nonatomic, strong) NSMutableArray *restaurants; ///< lista hierárquica (campi+RUs)
//@property (nonatomic, strong) NSMutableDictionary *currentRestaurant;
//@property (nonatomic, strong) NSMutableDictionary *preferredRestaurant;
//
//@property (nonatomic, strong) NSMutableArray *menuArray;
//@property (nonatomic, copy) NSString *observation;

@end

@implementation DataModel
#pragma mark - Singleton
+ (instancetype)getInstance {
  static DataModel *instance = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{ instance = [[self alloc] init]; });
  return instance;
}

- (instancetype)init {
  if (self = [super init]) {
    oauth = [OAuthUSP sharedInstance];
    dataAccess = [DataAccess sharedInstance];
    [dataAccess setDataModel:self];
  }
  return self;
}

#pragma mark - Login & user
- (BOOL)isLoggedIn { return [oauth isLoggedIn]; }

- (NSDictionary *)userData {
  if (![self isLoggedIn]) return nil;
  NSData *raw = [NSUserDefaults.standardUserDefaults objectForKey:@"userData"];
  if (![raw isKindOfClass:[NSData class]]) return nil;
  return [NSJSONSerialization JSONObjectWithData:raw
                                         options:NSJSONReadingMutableContainers
                                           error:nil];
}

#pragma mark - Persistência preferido
static NSString * const kPrefDictKey = @"preferredRestaurant";
static NSString * const kPrefJSONKey = @"preferredRestaurantJSON";

+ (void)savePreferredRestaurantDict:(NSDictionary *)dict {
  NSUserDefaults *ud = NSUserDefaults.standardUserDefaults;
  [ud setObject:dict forKey:kPrefDictKey];                                      // Obj-C legacy
  NSData *json = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
  if (json) [ud setObject:json forKey:kPrefJSONKey];                            // Swift
  [ud synchronize];
}

+ (NSDictionary *)loadPreferredRestaurantDict {
  NSUserDefaults *ud = NSUserDefaults.standardUserDefaults;
  
  id raw = [ud objectForKey:kPrefDictKey];
  if ([raw isKindOfClass:[NSDictionary class]]) return raw;
  
  NSData *json = [ud objectForKey:kPrefJSONKey];
  if ([json isKindOfClass:[NSData class]]) {
    id dict = [NSJSONSerialization JSONObjectWithData:json
                                              options:NSJSONReadingMutableContainers
                                                error:nil];
    if ([dict isKindOfClass:[NSDictionary class]]) return dict;
  }
  return nil;
}

#pragma mark - RESTAURANTES
- (void)getRestaurantList {
  AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
  mgr.requestSerializer  = [AFHTTPRequestSerializer serializer];
  mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
  mgr.responseSerializer.acceptableContentTypes =
  [NSSet setWithObject:@"application/x-www-form-urlencoded"];
  
  NSString *url   = [NSString stringWithFormat:@"%@restaurants", kBaseRUCardURL];
  NSDictionary *p = @{ @"hash": kToken };
  
  [mgr POST:url parameters:p success:^(AFHTTPRequestOperation *op, id resp) {
    if (op.response.statusCode != 200) { [self notifyRestaurants]; return; }
    
    self.restaurants = [NSJSONSerialization JSONObjectWithData:resp
                                                       options:NSJSONReadingMutableContainers
                                                         error:nil];
    [NSUserDefaults.standardUserDefaults setObject:self.restaurants
                                            forKey:@"Restaurants"];
    
    /* --- seleção de preferido / current --- */
    NSDictionary *pref = [DataModel loadPreferredRestaurantDict];
    NSString *prefId   = pref[@"id"];
    
    self.currentRestaurant = nil;
    for (NSDictionary *camp in self.restaurants) {
      for (NSMutableDictionary *ru in camp[@"restaurants"]) {
        if ([ru[@"id"] isEqualToString:prefId]) {
          self.preferredRestaurant = ru;
          self.currentRestaurant   = ru;
          break;
        }
      }
      if (self.currentRestaurant) break;
    }
    /* fallback para Central (6) ou primeiro RU */
    if (!self.currentRestaurant) {
      for (NSDictionary *camp in self.restaurants) {
        for (NSMutableDictionary *ru in camp[@"restaurants"]) {
          if ([ru[@"id"] intValue] == 6) { self.currentRestaurant = ru; break; }
        }
        if (self.currentRestaurant) break;
      }
      if (!self.currentRestaurant) {
        NSDictionary *firstCampus = self.restaurants.firstObject;
        self.currentRestaurant    = [firstCampus[@"restaurants"] firstObject];
      }
    }
    
    [self notifyRestaurants];
    
  } failure:^(AFHTTPRequestOperation *op, NSError *err) {
    NSLog(@"[DataModel] restaurantes erro: %@", err.localizedDescription);
    self.restaurants = [NSUserDefaults.standardUserDefaults objectForKey:@"Restaurants"];
    [self notifyRestaurants];
  }];
}

#pragma mark - MENU
- (void)getMenu {
  [SVProgressHUD show];
  
  self.menuArray = NSMutableArray.new;
  AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
  mgr.requestSerializer = [AFHTTPRequestSerializer serializer];
  mgr.responseSerializer = [AFHTTPResponseSerializer serializer];
  mgr.responseSerializer.acceptableContentTypes =
  [NSSet setWithObject:@"application/x-www-form-urlencoded"];
  
  NSString *url = [NSString stringWithFormat:@"%@menu/%@", kBaseRUCardURL,
                   self.currentRestaurant[@"id"]];
  
  [mgr POST:url parameters:@{@"hash":kToken} success:^(AFHTTPRequestOperation *op, id resp) {
    if (op.response.statusCode != 200) { [self menuError]; return; }
    
    NSMutableDictionary *json = [NSJSONSerialization JSONObjectWithData:resp options:NSJSONReadingMutableContainers error:nil];
    if ([json[@"message"][@"error"] boolValue]) { [self menuError]; return; }
    
    for (NSMutableDictionary *raw in json[@"meals"]) {
      NSMutableDictionary *day = [self cleanDictionary:raw];
      NSMutableArray *periods  = NSMutableArray.new;
      
      if (![day[@"lunch"] isKindOfClass:[NSString class]]) {
        [periods addObject:[[Period alloc] initWithPeriod:@"lunch" andMenu:day[@"lunch"][@"menu"] andCalories:day[@"lunch"][@"calories"]]];
      }
      if (![day[@"dinner"] isKindOfClass:[NSString class]]) {
        [periods addObject:[[Period alloc] initWithPeriod:@"dinner" andMenu:day[@"dinner"][@"menu"] andCalories:day[@"dinner"][@"calories"]]];
      }
      [self.menuArray addObject:[[Menu alloc] initWithDate:day[@"date"] andPeriod:periods]];
    }
    self.observation = json[@"observation"][@"observation"];
    
    [SVProgressHUD dismiss];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveMenu" object:self];
    
  } failure:^(AFHTTPRequestOperation *op, NSError *err) {
    NSLog(@"[DataModel] menu erro: %@", err.localizedDescription);
    [self menuError];
  }];
}

- (void)menuError {
  [SVProgressHUD showErrorWithStatus:@"Não foi possível obter o cardápio. Tente novamente mais tarde."];
  [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveMenu" object:self];
}

#pragma mark - Setters com ponte para Swift
- (void)setCurrentRestaurant:(NSDictionary *)currentRestaurant {
  _currentRestaurant = [self dictionaryFromPossiblyData:currentRestaurant];
  [self sanitizeWorkingHours:_currentRestaurant];
  [[RestaurantBridge shared] setCurrentRestaurantFrom:_currentRestaurant];
}

- (void)setPreferredRestaurant:(NSDictionary *)preferredRestaurant {
  _preferredRestaurant = [self dictionaryFromPossiblyData:preferredRestaurant];
  [self sanitizeWorkingHours:_preferredRestaurant];
  [DataModel savePreferredRestaurantDict:_preferredRestaurant];
}

#pragma mark - Helpers
/// Converte 'obj' (NSData / NSDictionary / NSMutableDictionary / nil)
/// em NSMutableDictionary seguro para mutação.
- (NSMutableDictionary *)dictionaryFromPossiblyData:(id)obj {
  
  if (!obj || obj == (id)[NSNull null])
    return NSMutableDictionary.dictionary;
  
  if ([obj isKindOfClass:[NSData class]]) {
    id decoded = [NSJSONSerialization JSONObjectWithData:obj options:NSJSONReadingMutableContainers error:nil];
    if (!decoded) {
      decoded = [NSPropertyListSerialization propertyListWithData:obj options:NSPropertyListMutableContainersAndLeaves format:nil error:nil];
    }
    obj = decoded;
  }
  
  if ([obj isKindOfClass:[NSDictionary class]] &&
      ![obj isKindOfClass:[NSMutableDictionary class]]) {
    obj = [obj mutableCopy];
  }
  
  if (![obj isKindOfClass:[NSMutableDictionary class]]) {
    return NSMutableDictionary.dictionary;
  }
  
  return obj;
}

- (void)sanitizeWorkingHours:(NSMutableDictionary *)restaurant {
  
  NSLog(@"%@", restaurant);
  id raw = restaurant[@"workinghours"];
  
  if ([raw isKindOfClass:[NSData class]]) {
    NSData *data = raw;
    id decoded = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    
    if (!decoded) {
      decoded = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListMutableContainersAndLeaves format:nil error:nil];
    }
    raw = decoded ?: @{};
  }
  
  if ([raw isKindOfClass:[NSString class]]) {
    NSData *data = [raw dataUsingEncoding:NSUTF8StringEncoding];
    id decoded = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    raw = decoded ?: @{};
  }
  
  if (![raw isKindOfClass:[NSMutableDictionary class]]) {
    if ([raw isKindOfClass:[NSDictionary class]]) {
      raw = [raw mutableCopy];
    } else {
      raw = [@{} mutableCopy];
    }
  }
  
  restaurant[@"workinghours"] = raw;
  NSMutableDictionary *wh = (NSMutableDictionary *)raw;
  
  NSDictionary *empty = @{ @"breakfast":@"",
                           @"lunch":@"",
                           @"dinner":@"" };
  
  for (NSString *key in @[@"weekdays", @"saturday", @"sunday"]) {
    id val = wh[key];
    if (val == (id)[NSNull null] || !val) {
      wh[key] = [empty mutableCopy];
    } else if ([val isKindOfClass:[NSDictionary class]] &&
               ![val isKindOfClass:[NSMutableDictionary class]]) {
      // garante mutabilidade dos filhos
      wh[key] = [val mutableCopy];
    }
  }
}

- (NSMutableDictionary *)cleanDictionary:(NSMutableDictionary *)dict {
  [dict enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
    if (obj == [NSNull null])
      dict[key] = @"";
    else if ([obj isKindOfClass:[NSDictionary class]])
      [self cleanDictionary:(NSMutableDictionary *)obj];
  }];
  return dict;
}

- (void)notifyRestaurants {
  [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveRestaurants" object:self];
}

#pragma mark - Crédito
- (void)getCreditoRUCard { [dataAccess consultarSaldo]; }

#pragma mark - API legada
- (NSMutableArray *)getCampiList { return self.restaurants; }

@end
