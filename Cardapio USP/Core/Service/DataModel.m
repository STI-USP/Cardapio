//
//  DataModel.m
//  Cardapio USP
//
//  Created by Vagner Machado on 21/05/15.
//  Revisitado em 18/06/25 — compatível com RestaurantServiceImpl (Swift)
//

#import "Cardapio_USP-Swift.h"
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

  AFJSONResponseSerializer *json = [AFJSONResponseSerializer serializerWithReadingOptions:NSJSONReadingMutableContainers];
  NSMutableSet *types = [json.acceptableContentTypes mutableCopy];
  [types addObject:@"text/plain"];
  [types addObject:@"application/x-www-form-urlencoded"];
  [types addObject:@"application/json; charset=utf-8"];
  json.acceptableContentTypes = types;
  mgr.responseSerializer = json;

  NSString *base = [kBaseRUCardURL hasSuffix:@"/"] ? [kBaseRUCardURL substringToIndex:kBaseRUCardURL.length-1] : kBaseRUCardURL;
  NSString *url   = [NSString stringWithFormat:@"%@/restaurants", base];
  NSDictionary *p = @{ @"hash": kToken };

  __weak typeof(self) weakSelf = self;
  [mgr POST:url parameters:p success:^(AFHTTPRequestOperation *op, id resp) {
    __strong typeof(self) self = weakSelf; if (!self) return;

    NSHTTPURLResponse *http = (NSHTTPURLResponse *)op.response;
    NSLog(@"[DataModel] /restaurants status=%ld content-type=%@",
          (long)http.statusCode, http.allHeaderFields[@"Content-Type"]);

    if (http.statusCode != 200 || ![resp isKindOfClass:[NSArray class]]) {
      [self notifyRestaurants];
      return;
    }

    self.restaurants = (NSArray *)resp;
    [NSUserDefaults.standardUserDefaults setObject:self.restaurants forKey:@"Restaurants"];

    // seleção de preferido / current
    NSDictionary *pref = [DataModel loadPreferredRestaurantDict];
    NSString *prefId   = pref[@"id"];

    self.currentRestaurant = nil;
    for (NSDictionary *camp in self.restaurants) {
      for (NSMutableDictionary *ru in camp[@"restaurants"]) {
        if ([[NSString stringWithFormat:@"%@", ru[@"id"]] isEqualToString:[NSString stringWithFormat:@"%@", prefId]]) {
          self.preferredRestaurant = ru;
          self.currentRestaurant   = ru;
          break;
        }
      }
      if (self.currentRestaurant) break;
    }
    // fallback para Central (6) ou primeiro RU
    if (!self.currentRestaurant) {
      for (NSDictionary *camp in self.restaurants) {
        for (NSMutableDictionary *ru in camp[@"restaurants"]) {
          if ([[NSString stringWithFormat:@"%@", ru[@"id"]] intValue] == 6) { self.currentRestaurant = ru; break; }
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
    // fallback cacheado
    self.restaurants = [NSUserDefaults.standardUserDefaults objectForKey:@"Restaurants"];
    [self notifyRestaurants];
  }];
}

#pragma mark - MENU

static inline NSString *CurlFromRequest(NSURLRequest *req) {
    NSMutableArray *parts = [NSMutableArray arrayWithObject:@"curl -i"];
    [parts addObject:[NSString stringWithFormat:@"-X %@", req.HTTPMethod]];
    [req.allHTTPHeaderFields enumerateKeysAndObjectsUsingBlock:^(NSString *k, NSString *v, BOOL *stop) {
        [parts addObject:[NSString stringWithFormat:@"-H '%@: %@'", k, v]];
    }];
    if (req.HTTPBody.length) {
        NSString *body = [[NSString alloc] initWithData:req.HTTPBody encoding:NSUTF8StringEncoding] ?: @"<binary>";
        body = [body stringByReplacingOccurrencesOfString:@"'" withString:@"'\"'\"'"]; // escapar '
        [parts addObject:[NSString stringWithFormat:@"--data '%@'", body]];
    }
    [parts addObject:[NSString stringWithFormat:@"'%@'", req.URL.absoluteString]];
    return [parts componentsJoinedByString:@" "];
}

static inline void LogAFOperation(AFHTTPRequestOperation *op, NSError *err) {
    NSString *reqBody = op.request.HTTPBody.length
        ? [[NSString alloc] initWithData:op.request.HTTPBody encoding:NSUTF8StringEncoding]
        : @"<empty>";
    NSLog(@"\n➡️ REQUEST\n  %@ %@\n  Headers: %@\n  Body: %@",
          op.request.HTTPMethod, op.request.URL.absoluteString,
          op.request.allHTTPHeaderFields, reqBody);

    NSHTTPURLResponse *http = (NSHTTPURLResponse *)op.response;
    NSLog(@"\n⬅️ RESPONSE\n  Status: %ld\n  Headers: %@\n  Body: %@",
          (long)http.statusCode, http.allHeaderFields, op.responseString);

    NSLog(@"\n🔁 cURL\n%@", CurlFromRequest(op.request));

    if (err) {
        NSLog(@"\n⚠️ ERROR\n  Domain: %@  Code: %ld\n  Desc: %@\n  UserInfo: %@",
              err.domain, (long)err.code, err.localizedDescription, err.userInfo);
    }
}

- (void)getMenu {
  [SVProgressHUD show];
  self.menuArray = NSMutableArray.new;

  AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
  mgr.responseSerializer = [AFHTTPResponseSerializer serializer];

  
  NSLog(@"🧪 currentRestaurant = %@", self.currentRestaurant);
  if ([self.currentRestaurant respondsToSelector:@selector(allKeys)]) {
      NSLog(@"🔑 keys = %@", [self.currentRestaurant allKeys]);
  }
  id rawId = self.currentRestaurant[@"id"];
  NSLog(@"🆔 raw id = %@ (class: %@)", rawId, rawId ? NSStringFromClass([rawId class]) : @"<nil>");
  
  
  NSMutableSet *types = [mgr.responseSerializer.acceptableContentTypes mutableCopy];
  [types addObject:@"application/json"];
  mgr.responseSerializer.acceptableContentTypes = types;

  // Garante barra única e id válido
  NSString *rid = [NSString stringWithFormat:@"%@", self.currentRestaurant[@"id"] ?: @""];
  if (rid.length == 0) {
    NSLog(@"❌ currentRestaurant['id'] vazio/nulo");
    [self menuError];
    return;
  }
  NSString *base = [kBaseRUCardURL hasSuffix:@"/"] ? [kBaseRUCardURL substringToIndex:kBaseRUCardURL.length-1] : kBaseRUCardURL;
  NSString *url = [NSString stringWithFormat:@"%@/menu/%@", base, rid];

  NSDictionary *params = @{ @"hash": kToken };
  NSLog(@"🔎 URL final: %@  params: %@", url, params);

  __weak typeof(self) weakSelf = self;
  [mgr POST:url parameters:params success:^(AFHTTPRequestOperation *op, id resp) {
    LogAFOperation(op, nil);

    __strong typeof(self) self = weakSelf;
    if (!self) return;

    if (op.response.statusCode != 200) { [self menuError]; return; }

    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:resp options:NSJSONReadingMutableContainers error:nil];
    if (![json isKindOfClass:[NSDictionary class]] || [json[@"message"][@"error"] boolValue]) {
      [self menuError];
      return;
    }

    [self.menuArray removeAllObjects];
    for (NSDictionary *raw in json[@"meals"]) {
      NSDictionary *day = [self cleanDictionary:[raw mutableCopy]];
      NSMutableArray *periods = NSMutableArray.new;
      for (NSString *period in @[@"lunch",@"dinner"]) {
        id block = day[period];
        if ([block isKindOfClass:[NSDictionary class]]) {
          [periods addObject:[[Period alloc] initWithPeriod:period andMenu:block[@"menu"] andCalories:block[@"calories"]]];
        }
      }
      Menu *menu = [[Menu alloc] initWithDate:day[@"date"] andPeriod:periods];
      [self.menuArray addObject:menu];
    }

    self.observation = json[@"observation"][@"observation"] ?: @"";
    [SVProgressHUD dismiss];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveMenu" object:self];

  } failure:^(AFHTTPRequestOperation *op, NSError *err) {
    LogAFOperation(op, err);
    NSLog(@"[DataModel] menu erro: %@", err.localizedDescription);
    [self menuError];
  }];
}

//- (void)getMenu {
//  [SVProgressHUD show];
//  self.menuArray = NSMutableArray.new;
//  
//  AFHTTPRequestOperationManager *mgr = [AFHTTPRequestOperationManager manager];
//  mgr.responseSerializer = [AFHTTPResponseSerializer serializer];     // mantém raw
//  NSMutableSet *types = [mgr.responseSerializer.acceptableContentTypes mutableCopy];
//  [types addObject:@"application/json"];                              // <-- acrescenta
//  mgr.responseSerializer.acceptableContentTypes = types;
//  
//  NSString *url = [NSString stringWithFormat:@"%@menu/%@", kBaseRUCardURL, self.currentRestaurant[@"id"]];
//  
//  NSDictionary *params = @{ @"hash" : kToken };
//  
//  __weak typeof(self) weakSelf = self;
//  [mgr POST:url parameters:params success:^(AFHTTPRequestOperation *op, id resp) {
//    
//    __strong typeof(self) self = weakSelf;
//    if (!self) return;
//    
//    if (op.response.statusCode != 200) {
//      [self menuError];
//      return;
//    }
//    
//    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:resp options:NSJSONReadingMutableContainers error:nil];
//    if (![json isKindOfClass:[NSDictionary class]] ||
//        [json[@"message"][@"error"] boolValue]) {
//      [self menuError];
//      return;
//    }
//    
//    [self.menuArray removeAllObjects];
//    
//    for (NSDictionary *raw in json[@"meals"]) {
//      NSDictionary *day = [self cleanDictionary:[raw mutableCopy]];
//      NSMutableArray *periods = NSMutableArray.new;
//      
//      for (NSString *period in @[@"lunch",@"dinner"]) {
//        id block = day[period];
//        if ([block isKindOfClass:[NSDictionary class]]) {
//          [periods addObject:[[Period alloc] initWithPeriod:period andMenu:block[@"menu"] andCalories:block[@"calories"]]];
//        }
//      }
//      Menu *menu = [[Menu alloc] initWithDate:day[@"date"] andPeriod:periods];
//      [self.menuArray addObject:menu];
//    }
//    
//    self.observation = json[@"observation"][@"observation"] ?: @"";
//    
//    [SVProgressHUD dismiss];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveMenu" object:self];
//    
//  } failure:^(AFHTTPRequestOperation *op, NSError *err) {
//    NSLog(@"[DataModel] menu erro: %@", err.localizedDescription);
//    [self menuError];
//  }];
//}


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
