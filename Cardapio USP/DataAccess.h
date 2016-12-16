//
//  DataAccess.h
//  Cardapio USP
//
//  Created by Vagner Machado on 5/21/15.
//  Copyright (c) 2015 EPUSP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BoletoDataModel.h"

@interface DataAccess : NSObject

@property (nonatomic, weak) BoletoDataModel *boletoDataModel;

+ (DataAccess *)sharedInstance;
- (void)getBoleto;
- (void)createBoleto;

@end
