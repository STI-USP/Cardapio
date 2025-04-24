//
//  VMPix.h
//  Cardapio USP
//
//  Created by Vagner Machado on 17/04/25.
//  Copyright © 2025 USP. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface VMPix : NSObject

@property (nonatomic, strong, nullable) NSNumber   *codftercs;
@property (nonatomic, strong, nullable) NSNumber   *codpesefepix;
@property (nonatomic, strong, nullable) NSNumber   *codpeslibcre;
@property (nonatomic, strong, nullable) NSNumber   *codptovda;
@property (nonatomic, strong, nullable) NSNumber   *codrtnptovda;
@property (nonatomic, strong, nullable) NSNumber   *codunddstvda;
@property (nonatomic, copy,   nullable) NSString   *cpfefepix;
@property (nonatomic, strong, nullable) NSDate     *dtacrepix;
@property (nonatomic, strong, nullable) NSDate     *dtagrcpix;
@property (nonatomic, copy,   nullable) NSString   *endToEndId;
@property (nonatomic, copy,   nullable) NSString   *etrhie;
@property (nonatomic, copy,   nullable) NSString   *idfpix;
@property (nonatomic, copy,   nullable) NSString   *msgErro;
@property (nonatomic, copy,   nullable) NSString   *nompes;
@property (nonatomic, copy,   nullable) NSString   *qrCodeImgBase64;
@property (nonatomic, copy,   nullable) NSString   *qrcpix;
@property (nonatomic, copy,   nullable) NSString   *sitpagpix;
@property (nonatomic, copy,   nullable) NSString   *tipitfvdapix;
@property (nonatomic, copy,   nullable) NSString   *tipopessoa;
@property (nonatomic, strong, nullable) NSNumber   *tmpedopag;
@property (nonatomic, strong, nullable) NSDecimalNumber *vlrpix;
@property (nonatomic, readonly, nullable) NSString *valorFormatado;
@property (nonatomic, readonly, nullable) NSString *statusDescricao;

+ (instancetype)modelWithDictionary:(NSDictionary *)dict;

@end

NS_ASSUME_NONNULL_END
