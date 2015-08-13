//
//  TelephoneUtils.h
//  Telefones USP
//
//  Created by Jun Okamoto Jr. on 26/09/12.
//  Copyright (c) 2012 EPUSP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TelephoneUtils : NSObject

/// Converte um string contendo telefones em vários formatos e separa cada um deles num elemento
///   de um array, como string no formato 0 xx yy nnnn mmmm para ser discado.
/// Os formatos de entrada podem ser: nnnn-mmmm/pppp/..., (yy)nnnn-mmmm ramal interno usp nnmmmm
+ (NSArray *)telephoneListForString:(NSString *)aString;

/// Extrai um número de telefone do string
+ (NSString *)telephoneFromString:(NSString *)aString;

/// Retorna um string com uma lista de telefones a partir de um array de telefones
+ (NSString *)telephoneListFromArray:(NSArray *)telephoneArray;

/// insere operadora num numero de telefone no formato (dd) [n]nnn-mmmm
/// retorna um telefone no formato (0 oo dd) [n]nnn-mmmm
+ (NSString *)telephoneWithCarrierFromString:(NSString *)telephoneString;

/// disca um número de telefone, o número do telefone é do formato (0 oo dd) [n]nnn-mmmm
+ (void)dialToTelephone:(NSString *)telephoneNumber;

//+ (void)setPreferredCarrierWithName:(NSString *)carrierName andCode:(NSString *)carrierCode;

//+ (NSArray *)listCarriers;


@end
