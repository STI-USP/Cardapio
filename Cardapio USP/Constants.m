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
NSString *kBaseRUCardURL;
NSString *kOAuthServiceURL;
NSString *kOAuthURL;
NSString *kOAuthConsumerSecret;
NSString *UserURLString;

@implementation Constants

+ (void)initialize {
  if (self == [Constants class]) {
    kBaseSTIURL = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"BASE_URL"];
    kBaseRUCardURL = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"RUCARD_URL"];
    kOAuthServiceURL = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"OAUTH_SERVICE_URL"];
    kOAuthURL = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"OAUTH_URL"];
    kOAuthConsumerSecret = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"OAUTH_CONSUMER_SECRET"];
    UserURLString = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"USER_URL_STRING"];
    
    if (!kBaseSTIURL || !kOAuthServiceURL || !UserURLString) {
      NSLog(@"Erro ao carregar variáveis de ambiente a partir do Build Settings");
    }
  }
}

@end
