//
//  CarrierDataModel.m
//  Eventos USP
//
//  Created by Jun Okamoto on 08/06/12.
//  Copyright (c) 2012 EPUSP. All rights reserved.
//

#import "CarrierDataModel.h"
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

@interface CarrierDataModel () {
  NSUserDefaults *userDefaults;
  NSArray *carrierList;
}

@end

@implementation CarrierDataModel

//@synthesize currentCarrierName = _currentCarrierName;
@synthesize currentCarrierCode = _currentCarrierCode;

// Singleton (Thread Safe)
+ (CarrierDataModel *)allocInitSingleton {
  static dispatch_once_t once;
  static CarrierDataModel *carrierDataModel;
  dispatch_once(&once, ^ { carrierDataModel = [[CarrierDataModel alloc] init]; });
  return carrierDataModel;
}

- (id)init {
  self = [super init];
  if (self) {

    // lê operadora atual do User Defaults
    userDefaults = [NSUserDefaults standardUserDefaults];
    
//    _currentCarrierName = [userDefaults stringForKey:@"carrierName"];
    _currentCarrierCode = [userDefaults stringForKey:@"carrierCode"];

    // se não tiver operadora atual,
    if ([_currentCarrierCode isEqualToString:@""] || _currentCarrierCode == nil) {
      // define a operadora pelo MNC
      // determina a operadora do telefone
      CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
      CTCarrier *carrier = [netinfo subscriberCellularProvider];
      if ([carrier mobileNetworkCode] != nil) { // se o MNC não for nil
        // carrega a lista de operadoras
        carrierList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Carriers" ofType:@"plist"]];
        // procura o MNC na lista
        for (NSDictionary *d in carrierList) {
          // verifica se o MNC está em alguma operadora
          if ([[d objectForKey:@"MNC"] rangeOfString:[carrier mobileNetworkCode]].location != NSNotFound) {
            // se estiver faz como operadora atual
//            _currentCarrierName = [d objectForKey:@"name"];
            _currentCarrierCode = [d objectForKey:@"code"];
            break;
          }
        }
      } else { // se o MMC for nil usa Embratel, [jo:120712] era Embratel, mas se não tiver nada é porque não é iPhone, então deixa em branco
//        _currentCarrierName = @"";
        _currentCarrierCode = @"";
      }
      
    }
    
    // salva valores no user defaults
//    NSDictionary *defaultsToRegister = [NSDictionary dictionaryWithObjectsAndKeys:_currentCarrierName, @"carrierName", _currentCarrierCode, @"carrierCode", nil];
    NSDictionary *defaultsToRegister = [NSDictionary dictionaryWithObject:_currentCarrierCode forKey:@"carrierCode"];
    [userDefaults registerDefaults:defaultsToRegister];
    [userDefaults synchronize];
  }
  return self;
}

//#pragma mark - Setters
//
//- (void)setCurrentCarrierName:(NSString *)currentCarrierName {
//  _currentCarrierName = [currentCarrierName copy];
//  // salva valor no userDefaults
//  [userDefaults setObject:_currentCarrierName forKey:@"carrierName"];
//  [userDefaults synchronize];
//}
//
//- (void)setCurrentCarrierCode:(NSString *)currentCarrierCode {
//  _currentCarrierCode = [currentCarrierCode copy];
//  // salva valor no userDefaults
//  [userDefaults setObject:_currentCarrierCode forKey:@"carrierCode"];
//  [userDefaults synchronize];
//}

#pragma mark - Getters

- (NSString *)currentCarrierCode {
  _currentCarrierCode = [userDefaults objectForKey:@"carrierCode"];
  return _currentCarrierCode;
}

@end
