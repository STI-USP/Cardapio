//
//  TelephoneUtils.m
//  Telefones USP
//
//  Created by Jun Okamoto Jr. on 26/09/12.
//  Copyright (c) 2012 EPUSP. All rights reserved.
//

#import "TelephoneUtils.h"
#import "CarrierDataModel.h"

@interface TelephoneUtils () {
//  CarrierDataModel *carrierDataModel;
}

@end

@implementation TelephoneUtils

//+ (TelephoneUtils *)allocInitSingleton {
//  static dispatch_once_t once;
//  static TelephoneUtils *telephoneUtils;
//  dispatch_once(&once, ^ { telephoneUtils = [[TelephoneUtils alloc] init]; });
//  return telephoneUtils;
//}
//
//- (id)init {
//  self = [super init];
//  if (self) {
//    carrierDataModel = [CarrierDataModel allocInitSingleton];
//  }
//  return self;
//}
//
#pragma mark - Class Methods

+ (NSArray *)telephoneListForString:(NSString *)aString {
  NSMutableArray *telephoneList = [[NSMutableArray alloc] init];
  // separa diversos telefones no string em um telefone por posição do array no formato 0 xx yy nnnn mmmm, pronto para discar do telefone
  if ([aString rangeOfString:@"ramal"].location == NSNotFound) {  // telefones no formato: nnnn-mmmm/pppp/uuuu ....
    NSString *telephonePrefix;
    NSString *telephoneExtension;
    NSScanner *telephoneScanner = [NSScanner scannerWithString:aString];
    [telephoneScanner scanUpToString:@"-" intoString:&telephonePrefix];  // primeiro pega o prefixo
    [telephoneScanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:NULL]; // avança até o próximo grupo de números
    while ([telephoneScanner isAtEnd] == NO) { // depois varre até o fim pegando cada uma das extensões
      [telephoneScanner scanUpToString:@"/" intoString:&telephoneExtension];
      [telephoneList addObject:[NSString stringWithFormat:@"%@-%@", telephonePrefix, telephoneExtension]];
      [telephoneScanner scanUpToCharactersFromSet:[NSCharacterSet decimalDigitCharacterSet] intoString:NULL];
    }
//    NSLog(@"%@", telephoneList);
  } else {  // telefones no formato: (0xxdd)nnnn-mmmm ramal usp: nnmmmm
    
  }
  
  return telephoneList;
}

+ (NSString *)telephoneFromString:(NSString *)aString {
  NSMutableString *telephoneNumber = [NSMutableString stringWithString:aString];
  NSString *returnString;
  if ([aString rangeOfString:@"(0xx"].location != NSNotFound) {  // telefones no formato: (0xxdd)nnnn-mmmm ramal usp: nnmmmm
//    [telephoneNumber replaceOccurrencesOfString:@"xx" withString:@" xx " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [telephoneNumber length])];
//    [telephoneNumber replaceOccurrencesOfString:@")" withString:@") " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [telephoneNumber length])];
    [telephoneNumber replaceOccurrencesOfString:@"(0xx" withString:@"(" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [telephoneNumber length])];
    [telephoneNumber replaceOccurrencesOfString:@")" withString:@") " options:NSCaseInsensitiveSearch range:NSMakeRange(0, [telephoneNumber length])];
    NSScanner *telephoneScanner = [NSScanner scannerWithString:telephoneNumber];
    [telephoneScanner scanUpToString:@" -" intoString:&returnString];  // primeiro pega o número antes de ' -'
  } else {
    returnString = aString;
  }
  return returnString;
}

+ (NSString *)telephoneListFromArray:(NSArray *)telephoneArray {
  if (telephoneArray == nil) { // se a array for nula
    return nil;                // retorna nulo
  } // senão continua
  
  NSMutableString *telephoneList = [[NSMutableString alloc] init];
  for (NSString *s in telephoneArray) { // coloca cada um dos telefones da lista separados por ', '
    [telephoneList appendFormat:@"%@, ", [self telephoneFromString:s]];
  }
  [telephoneList deleteCharactersInRange:NSMakeRange(telephoneList.length - 2, 2)]; // remove ', ' do final do string
  
  return [NSString stringWithString:telephoneList];
}

+ (NSString *)telephoneWithCarrierFromString:(NSString *)telephoneString {
  NSMutableString *telephoneWithCarrier = [[NSMutableString alloc] initWithString:[self telephoneFromString:telephoneString]];
  [telephoneWithCarrier replaceOccurrencesOfString:@"(" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [telephoneWithCarrier length])]; // retira '('
//  [telephoneWithCarrier replaceOccurrencesOfString:@") " withString:@"-" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [telephoneWithCarrier length])]; // retira ') ' e coloca '-' no lugar
//  [telephoneWithCarrier insertString:[NSString stringWithFormat:@"(0%@ ",[[TelephoneUtils allocInitSingleton] currentCarrierCodeFromModel]] atIndex:0]; // insere código da operadora no início do string
  [telephoneWithCarrier insertString:[NSString stringWithFormat:@"(0%@ ",[[CarrierDataModel allocInitSingleton] currentCarrierCode]] atIndex:0]; // insere código da operadora no início do string
  return telephoneWithCarrier;
}

+ (void)dialToTelephone:(NSString *)telephoneNumber {
  // o telefone sempre vem no formato (0 oo dd) nnnn-mmmm
  NSMutableString *telephoneToDial = [[NSMutableString alloc] initWithString:telephoneNumber];
  // o telefone sempre vem no formato (dd) nnnn-mmmm
//  NSMutableString *telephoneToDial = [[NSMutableString alloc] initWithString:[self telephoneWithCarrierFromString:telephoneNumber]];
  
  // prepara a URL para telefone
//  [telephoneToDial replaceOccurrencesOfString:@"(" withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [telephoneToDial length])]; // retira '('
  [telephoneToDial replaceOccurrencesOfString:@"(" withString:@"tel://" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [telephoneToDial length])]; // retira '(' e coloca 'tel://' no lugar
  [telephoneToDial replaceOccurrencesOfString:@") " withString:@"-" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [telephoneToDial length])]; // retira ') ' e coloca '-' no lugar
  [telephoneToDial replaceOccurrencesOfString:@" " withString:@"" options:NSCaseInsensitiveSearch range:NSMakeRange(0, [telephoneToDial length])]; // retira ' ' e coloca '' no lugar
//  [telephoneToDial insertString:[NSString stringWithFormat:@"tel://0%@",[[TelephoneUtils allocInitSingleton] currentCarrierCodeFromModel]] atIndex:0]; // insere código da operadora no início do string
  
//  NSLog(@"%@", telephoneToDial);
  
  [[UIApplication sharedApplication] openURL:[NSURL URLWithString:telephoneToDial] options:@{} completionHandler:nil]; // disca pelo telefone

}

//+ (void)setPreferredCarrierWithName:(NSString *)carrierName andCode:(NSString *)carrierCode {
//  
//}

//+ (NSArray*)listCarriers {
//  return [[TelephoneUtils allocInitSingleton] listOfCarriersFromModel];
//}

#pragma mark - Instance Methods

//- (NSArray*)listOfCarriersFromModel {
//  return carrierDataModel.carrierList;
//}

//- (NSString *)currentCarrierCodeFromModel {
//  return carrierDataModel.currentCarrierCode;
//}

@end
