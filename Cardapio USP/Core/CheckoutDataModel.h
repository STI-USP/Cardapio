//
//  BoletoDataModel.h
//  Cardapio USP
//
//  Created by Vagner Machado on 15/12/16.
//  Copyright © 2016 EPUSP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CheckoutDataModel : NSObject

@property (nonatomic, strong) NSMutableDictionary *boleto;
@property (nonatomic, strong) NSMutableDictionary *pix;
@property (nonatomic, strong) NSMutableArray *boletosPendentes;
@property (nonatomic, strong) NSString *valorRecarga;

+ (CheckoutDataModel *)sharedInstance;
- (void)createPix;
- (void)checkPix:(NSString *)pixId;
- (void)getLastPix;

//- (void)getBoleto;
//- (void)getBoletos;

@end
