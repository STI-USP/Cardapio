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


@end
