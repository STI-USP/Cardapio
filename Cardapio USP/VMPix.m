//
//  VMPix.m
//  Cardapio USP
//
//  Created by Vagner Machado on 17/04/25.
//  Copyright © 2025 USP. All rights reserved.
//

#import "VMPix.h"

@implementation VMPix

+ (instancetype)modelWithDictionary:(NSDictionary *)dict {
  VMPix *pix = [[VMPix alloc] init];
  
  // ---------- helpers ----------
  id (^clean)(id) = ^id(id value) {
    if (!value || value == (id)kCFNull ||
        [value isKindOfClass:[NSNull class]]) return nil;
    if ([value isKindOfClass:[NSString class]] &&
        [(NSString *)value isEqualToString:@"<null>"]) return nil;
    return value;
  };
  
  NSNumber * (^numFrom)(id) = ^NSNumber * (id value) {
    value = clean(value);
    if ([value isKindOfClass:[NSNumber class]]) return value;
    if ([value isKindOfClass:[NSString class]]) return @([(NSString *)value longLongValue]);
    return nil;
  };
  
  NSDecimalNumber * (^decimalFrom)(id) = ^NSDecimalNumber * (id value) {
    value = clean(value);
    if (!value) return nil;
    if ([value isKindOfClass:[NSNumber class]]) {
      return [NSDecimalNumber decimalNumberWithDecimal:
              [(NSNumber *)value decimalValue]];
    }
    if ([value isKindOfClass:[NSString class]]) {
      NSString *s = [(NSString *)value stringByReplacingOccurrencesOfString:@"," withString:@"."];
      return [NSDecimalNumber decimalNumberWithString:s];
    }
    return nil;
  };
  
  NSString * (^strFrom)(id) = ^NSString * (id value) {
    value = clean(value);
    return [value isKindOfClass:[NSString class]] ? value : [value description];
  };
  
  // ---------- datas ----------
  static NSDateFormatter *fmt;
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    fmt = [[NSDateFormatter alloc] init];
    fmt.locale   = [NSLocale localeWithLocaleIdentifier:@"pt_BR"];
    fmt.timeZone = [NSTimeZone timeZoneWithName:@"America/Sao_Paulo"];
    fmt.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";   // ajuste se necessário
  });
  
  NSDate * (^dateFrom)(id) = ^NSDate * (id value) {
    NSString *s = strFrom(value);
    return s ? [fmt dateFromString:s] : nil;
  };
  
  // ---------- atribuição ----------
  pix.codftercs     = numFrom(dict[@"codftercs"]);
  pix.codpesefepix  = numFrom(dict[@"codpesefepix"]);
  pix.codpeslibcre  = numFrom(dict[@"codpeslibcre"]);
  pix.codptovda     = numFrom(dict[@"codptovda"]);
  pix.codrtnptovda  = numFrom(dict[@"codrtnptovda"]);
  pix.codunddstvda  = numFrom(dict[@"codunddstvda"]);
  pix.tmpedopag     = numFrom(dict[@"tmpedopag"]);
  
  pix.vlrpix        = decimalFrom(dict[@"vlrpix"]);
  
  pix.cpfefepix     = strFrom(dict[@"cpfefepix"]);
  
  pix.dtacrepix     = dateFrom(dict[@"dtacrepix"]);
  pix.dtagrcpix     = dateFrom(dict[@"dtagrcpix"]);
  
  pix.endToEndId    = strFrom(dict[@"endToEndId"]);
  pix.etrhie        = strFrom(dict[@"etrhie"]);
  pix.idfpix        = strFrom(dict[@"idfpix"]);
  pix.msgErro       = strFrom(dict[@"msgErro"]);
  pix.nompes        = strFrom(dict[@"nompes"]);
  pix.qrCodeImgBase64 = strFrom(dict[@"qrCodeImgBase64"]);
  pix.qrcpix        = strFrom(dict[@"qrcpix"]);
  pix.sitpagpix     = strFrom(dict[@"sitpagpix"]);
  pix.tipitfvdapix  = strFrom(dict[@"tipitfvdapix"]);
  pix.tipopessoa    = strFrom(dict[@"tipopessoa"]);
  
  return pix;
}

- (NSString *)valorFormatado {
  if (!self.vlrpix) return nil;
  
  static NSNumberFormatter *fmt;
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    fmt = [[NSNumberFormatter alloc] init];
    fmt.locale = [NSLocale localeWithLocaleIdentifier:@"pt_BR"];
    fmt.numberStyle = NSNumberFormatterCurrencyStyle;
    fmt.minimumFractionDigits = 2;
    fmt.maximumFractionDigits = 2;
  });
  return [fmt stringFromNumber:self.vlrpix];
}

- (NSString *)statusDescricao {
  if (!self.sitpagpix) { return nil; }
  
  if ([self.sitpagpix isEqualToString:@"AT"]) { return @"Em aberto"; }
  if ([self.sitpagpix isEqualToString:@"CO"]) { return @"Concluído"; }
  if ([self.sitpagpix isEqualToString:@"CA"]) { return @"Cancelado"; }
  return self.sitpagpix; // fallback: devolve o valor original
}

@end
