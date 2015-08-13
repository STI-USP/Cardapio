//
//  CarrierDataModel.h
//  Eventos USP
//
//  Created by Jun Okamoto on 08/06/12.
//  Copyright (c) 2012 EPUSP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CarrierDataModel : NSObject

//@property (nonatomic, copy) NSString *currentCarrierName; // nome da operadora preferida
@property (nonatomic, copy) NSString *currentCarrierCode; // código da operadora preferida

+ (CarrierDataModel *)allocInitSingleton;

@end
