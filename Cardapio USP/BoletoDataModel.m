//
//  BoletoDataModel.m
//  Cardapio USP
//
//  Created by Vagner Machado on 15/12/16.
//  Copyright © 2016 EPUSP. All rights reserved.
//

#import "BoletoDataModel.h"
#import "DataAccess.h"

@interface BoletoDataModel () {
  DataAccess *dataAccess;
}

@end

@implementation BoletoDataModel

// - Lifecycle
+ (BoletoDataModel *)sharedInstance {
  static BoletoDataModel *instance = nil;
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    instance = [[BoletoDataModel alloc] init];
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
- (void)getBoleto {
  [dataAccess getBoleto];
}

- (void)getBoletos {
  [dataAccess getBoletos];
}


- (void)createBill {
  [dataAccess createBill];
}

- (void)deleteBill {
  [dataAccess deleteBill];
}

- (void)createPix {
  [dataAccess createPix];
}

- (void)checkPix:(NSString *)pixId {
  [dataAccess checkPix:pixId];
}

@end
