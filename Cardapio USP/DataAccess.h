//
//  DataAccess.h
//  Cardapio USP
//
//  Created by Vagner Machado on 5/21/15.
//  Copyright (c) 2015 EPUSP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BoletoDataModel.h"
#import "DataModel.h"

@interface DataAccess : NSObject

@property (nonatomic, weak) BoletoDataModel *boletoDataModel;
@property (nonatomic, weak) DataModel *dataModel;

+ (DataAccess *)sharedInstance;
- (void)getBoleto;
- (void)getBoletos;
- (void)createBoleto;
- (void)consultarSaldo;

@end
