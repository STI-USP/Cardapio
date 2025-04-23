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
  
  // ---------- formato de datas ----------
  static NSDateFormatter *isoFmt;
  static NSDateFormatter *brFmt;
  static dispatch_once_t once;
  dispatch_once(&once, ^{
    // 1) ISO-8601  (ex.: 2025-04-22T14:27:03-0300)
    isoFmt = [[NSDateFormatter alloc] init];
    isoFmt.locale   = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    isoFmt.timeZone = [NSTimeZone timeZoneWithAbbreviation:@"UTC"];
    isoFmt.dateFormat = @"yyyy-MM-dd'T'HH:mm:ssZ";
    
    // 2) dd/MM/yyyy HH:mm:ss  (ex.: 22/04/2025 14:27:03)
    brFmt = [[NSDateFormatter alloc] init];
    brFmt.locale   = [NSLocale localeWithLocaleIdentifier:@"pt_BR"];
    brFmt.timeZone = [NSTimeZone timeZoneWithName:@"America/Sao_Paulo"];
    brFmt.dateFormat = @"dd/MM/yyyy HH:mm:ss";
  });
  
  // helper
  NSDate * (^dateFrom)(id) = ^NSDate * (id value) {
    NSString *s = strFrom(value);
    if (!s) return nil;
    
    NSDate *d = [isoFmt dateFromString:s];
    if (!d)  d = [brFmt dateFromString:s];
    return d;
  };
  
  // ---------- atribuição ----------
  pix.codftercs = numFrom(dict[@"codftercs"]);
  pix.codpesefepix = numFrom(dict[@"codpesefepix"]);
  pix.codpeslibcre = numFrom(dict[@"codpeslibcre"]);
  pix.codptovda = numFrom(dict[@"codptovda"]);
  pix.codrtnptovda = numFrom(dict[@"codrtnptovda"]);
  pix.codunddstvda = numFrom(dict[@"codunddstvda"]);
  pix.tmpedopag = numFrom(dict[@"tmpedopag"]);
  
  pix.vlrpix = decimalFrom(dict[@"vlrpix"]);
  
  pix.cpfefepix = strFrom(dict[@"cpfefepix"]);
  
  pix.dtacrepix = dateFrom(dict[@"dtacrepix"]);
  pix.dtagrcpix = dateFrom(dict[@"dtagrcpix"]);
  
  pix.endToEndId = strFrom(dict[@"endToEndId"]);
  pix.etrhie = strFrom(dict[@"etrhie"]);
  pix.idfpix = strFrom(dict[@"idfpix"]);
  pix.msgErro = strFrom(dict[@"msgErro"]);
  pix.nompes = strFrom(dict[@"nompes"]);
  pix.qrCodeImgBase64 = strFrom(dict[@"qrCodeImgBase64"]);
  pix.qrcpix = strFrom(dict[@"qrcpix"]);
  pix.sitpagpix = strFrom(dict[@"sitpagpix"]);
  pix.tipitfvdapix = strFrom(dict[@"tipitfvdapix"]);
  pix.tipopessoa = strFrom(dict[@"tipopessoa"]);
  
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
  
  // ---- status “AT” / “ATIVA” precisam checar o tempo de geração ----
  NSString *status = [self.sitpagpix uppercaseString];
  if ([status isEqualToString:@"AT"] || [status isEqualToString:@"ATIVA"]) {
    
    NSDate *geracao = self.dtagrcpix;
    if (geracao) {
      NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:geracao];
      if (diff < 3600) { // menos de 1h
        return @"Em aberto";
      } else {
        return @"Expirado";
      }
    }
    return @"Em aberto";
  }
  
  // ---- demais códigos vindos da API ----
  if ([status isEqualToString:@"CO"]) { return @"Pago"; }
  if ([status isEqualToString:@"CA"]) { return @"Cancelado"; }
  
  return self.sitpagpix; // fallback: devolve original, caso apareça novo código
}

@end
