//
//  BoletoDataModel.m
//  Cardapio USP
//
//  Created by Vagner Machado on 15/12/16.
//  Copyright © 2016 EPUSP. All rights reserved.
//

#import "CheckoutDataModel.h"
#import "DataAccess.h"

@interface CheckoutDataModel () {
  DataAccess *dataAccess;
}

@end

@implementation CheckoutDataModel

// - Lifecycle
+ (CheckoutDataModel *)sharedInstance {
  static CheckoutDataModel *instance = nil;
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    instance = [[CheckoutDataModel alloc] init];
  });
  return instance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    dataAccess = [DataAccess sharedInstance];
    [dataAccess setBoletoDataModel:self];
  }
  return self;
}


// - Getters and Setters

- (void)setPix:(NSMutableDictionary *)pix {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:[NSKeyedArchiver archivedDataWithRootObject:pix requiringSecureCoding:NO error:nil] forKey:@"pix"];
  [defaults synchronize];
}

- (NSMutableDictionary *)pix {
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  NSData *data = [defaults objectForKey:@"pix"];
  NSMutableDictionary *pix = [[NSKeyedUnarchiver unarchiveTopLevelObjectWithData:data error:nil] mutableCopy];
  return pix;
}


// - API

- (void)createPix {
  [dataAccess createPix];
}

- (void)checkPix:(NSString *)pixId {
  [dataAccess checkPix:pixId];
}

- (void)getBoletos {
  [dataAccess getBoletos];
}

- (void)getLastPix {
  [dataAccess getLastPix];
}

@end
