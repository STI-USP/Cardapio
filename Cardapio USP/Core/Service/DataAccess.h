//
//  DataAccess.h
//  Cardapio USP
//
//  Created by Vagner Machado on 5/21/15.
//  Copyright (c) 2015 EPUSP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CheckoutDataModel.h"
#import "DataModel.h"

@interface DataAccess : NSObject

@property (nonatomic, weak) CheckoutDataModel *boletoDataModel;
@property (nonatomic, weak) DataModel *dataModel;


+ (DataAccess *)sharedInstance;
- (void)consultarSaldo;
- (void)createPix;
- (void)checkPix:(NSString *)pixId;

- (void)getLastPix;
- (void)getBoletos;

@end
