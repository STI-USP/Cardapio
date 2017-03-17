//
//  BoletoDataModel.h
//  Cardapio USP
//
//  Created by Vagner Machado on 15/12/16.
//  Copyright © 2016 EPUSP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BoletoDataModel : NSObject

@property (nonatomic, strong) NSMutableDictionary *boleto;
@property (nonatomic, strong) NSMutableArray *boletosPendentes;
@property (nonatomic, strong) NSString *valorRecarga;

+ (BoletoDataModel *)sharedInstance;
- (void)getBoleto;
- (void)getBoletos;
- (void)createBill;
- (void)deleteBill;



@end
