//
//  Constant.m
//  Cardapio USP
//
//  Created by Vagner Machado on 13/09/24.
//  Copyright © 2024 USP. All rights reserved.
//

#import "Constants.h"

// Define a variável como estática
NSString *kBaseSTIURL;
NSString *OAuthServiceURL;
NSString *UserURLString;
NSString *kBaseRUCardURL;

@implementation Constants

+ (void)initialize {
    if (self == [Constants class]) {
      kBaseSTIURL = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"BASE_URL"];
      kBaseRUCardURL = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"RUCARD_URL"];
      OAuthServiceURL = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"OAUTH_SERVICE_URL"];
      UserURLString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"USER_URL_STRING"];

        if (!kBaseSTIURL || !OAuthServiceURL || !UserURLString) {
            NSLog(@"Erro ao carregar variáveis de ambiente a partir do Build Settings");
        }
    }
}

@end
