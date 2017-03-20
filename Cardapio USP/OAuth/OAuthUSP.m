//
//  OAuthUSP.m
//  CeTI OAuth
//
//  Created by Vagner Machado on 8/28/15.
//  Copyright (c) 2015 USP. All rights reserved.
//

#import "OAuthUSP.h"
#import "AppDelegate.h"
#import "OAuth1Controller.h"
#import "LoginWebViewController.h"

//#define OAuthServiceURL @"https://dev.uspdigital.usp.br/mobile/servicos/oauth" //dev
#define OAuthServiceURL @"https://uspdigital.usp.br/mobile/servicos/oauth" //prod

@interface OAuthUSP () {
  LoginWebViewController *loginViewController;
  NSUserDefaults *defaults;
}
@end

@implementation OAuthUSP

// Thread safe singleton - Grand Central Dispatch (GCD) solution (best!)
+ (OAuthUSP *)sharedInstance {
  // Aloca e inicializa objeto singleton.
  // Utiliza Grand Central Dispatch (GCD) para ser thread safe.
  static OAuthUSP *oAuth = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{ oAuth = [[OAuthUSP alloc] init]; });
  return oAuth;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    defaults = [NSUserDefaults standardUserDefaults];
    _oauthToken = [defaults stringForKey:@"oauthToken"];
    _oauthTokenSecret = [defaults stringForKey:@"oauthTokenSecret"];
  }
  return self;
}

#pragma mark - Getters

- (NSDictionary *)userData {
  if ([self isLoggedIn]) {
    return [NSJSONSerialization JSONObjectWithData:[[defaults objectForKey:@"userData"] copy] options: NSJSONReadingMutableContainers error: nil];
  } else {
    return nil;
  }
}

#pragma mark - Setters

- (void)setUserData:(NSDictionary *)userData {
  [[NSNotificationCenter defaultCenter] postNotificationName:@"DidReceiveUserData" object:self];
}

- (void)setOauthToken:(NSString *)oauthToken {
  _oauthToken = oauthToken;
  [defaults setObject:_oauthToken forKey:@"oauthToken"];
  [defaults synchronize];
}

- (void)setOauthTokenSecret:(NSString *)oauthTokenSecret {
  _oauthTokenSecret = oauthTokenSecret;
  [defaults setObject:_oauthTokenSecret forKey:@"oauthTokenSecret"];
  [defaults synchronize];
}

#pragma mark - OAuth

- (BOOL) isLoggedIn {
  if (_oauthToken)
    return YES;
  else
    return NO;
}

- (void)login {
  UIViewController *rootViewController = (UIViewController *)[[(AppDelegate *) [[UIApplication sharedApplication] delegate] window] rootViewController];
  loginViewController = [rootViewController.storyboard instantiateViewControllerWithIdentifier:@"loginWebViewController"];
  [rootViewController presentViewController:loginViewController animated:YES completion:nil];
}

- (void)logout {
  [self invalidarToken];
}

- (void)apagarCredenciais {
  loginViewController.webView = nil;
  [defaults setObject:nil forKey:@"userData"];
  [defaults setObject:nil forKey:@"oauthToken"];
  [defaults setObject:nil forKey:@"oauthTokenSecret"];
  
  _oauthToken = nil;
  _oauthTokenSecret = nil;
  //[self setOauthToken:nil];
  //[self setOauthTokenSecret:nil];
}

#pragma mark - STI

- (void)registrarToken {
  
  //configura parametros
  NSString *token = self.userData[@"wsuserid"];
  NSString *tokenNotificacao = nil;
  //tokenNotificacao = [[LibrariesDataModel sharedInstance] pushToken];
  
  NSMutableDictionary *dict;

  //#warning @":::DEV::: para producao, precisa comentar os 2 ultimos parametros, ainda nao implementados"
  if (tokenNotificacao) {
    dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
            token, @"token",
            @"AppCardapi", @"app",
            tokenNotificacao, @"tokenNotificacao",
            @"I", @"ambiente", //iOS
            nil];
  } else {
    dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
            token, @"token",
            @"AppCardapi", @"app",
            nil];
  }
  
  NSString *path = @"/registrar";
  NSData* params = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", OAuthServiceURL, path]];
  NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
  [urlRequest setHTTPMethod:@"POST"];
  [urlRequest setHTTPBody:params];
  [urlRequest setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
  
  //Executa requisição
  NSURLSessionDataTask *dataTask = [[self session] dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    if ([data length] > 0 && error == nil) {
      if ([httpResponse statusCode] == 200) {
        NSLog(@"registro: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
      } else {
        NSLog(@"error: %ld", (long)[httpResponse statusCode]);
      }
    } else if (error) {
      NSLog(@"error: %@", [error description]);
    }
  }];
  
  [dataTask resume];
}


- (void)invalidarToken {
  
  //configura parametros
  NSString *token = self.userData[@"wsuserid"];
  NSString *tokenNotificacao = nil;
  //tokenNotificacao = [[LibrariesDataModel sharedInstance] pushToken];
  
  NSMutableDictionary *dict;
  
  if (tokenNotificacao) {
    dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
            token, @"token",
            tokenNotificacao, @"tokenNotificacao",
            @"I", @"ambiente", //iOS
            nil];
  } else {
    dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
            token, @"token",
            nil];
  }
  
  NSString *path = @"/sair";
  NSData* params = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", OAuthServiceURL, path]];
  NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
  [urlRequest setHTTPMethod:@"POST"];
  [urlRequest setHTTPBody:params];
  [urlRequest setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
  
  //Executa requisição
  NSURLSessionDataTask *dataTask = [[self session] dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    if ([data length] > 0 && error == nil) {
      if ([httpResponse statusCode] == 200) {
        //NSLog(@"invalidar: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
        [self apagarCredenciais];
      } else {
        NSLog(@"error: %ld", (long)[httpResponse statusCode]);
      }
    } else if (error) {
      NSLog(@"error: %@", [error description]);
    }
  }];
  
  [dataTask resume];
}

- (void)consultarToken {
  
  NSString *token = self.userData[@"wsuserid"];

  //configura parametros
  NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                               token, @"token",
                               nil];
  
  NSString *path = @"/consultar";
  NSData* params = [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
  NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", OAuthServiceURL, path]];
  NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
  [urlRequest setHTTPMethod:@"POST"];
  [urlRequest setHTTPBody:params];
  [urlRequest setValue:@"application/json; charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
  
  //Executa requisição
  NSURLSessionDataTask *dataTask = [[self session] dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
    
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
    
    if ([data length] > 0 && error == nil) {
      if ([httpResponse statusCode] == 200) {
        NSLog(@"numero USP: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
      } else {
        NSLog(@"error: %ld", (long)[httpResponse statusCode]);
      }
    } else {
      [self invalidarToken];
    }
  }];
  
  [dataTask resume];
}

/*
- (void)checkUser {
  // USP Digital POST Request
  NSString *path = @"https://dev.uspdigital.usp.br/wsusuario/oauth/validar";
  NSDictionary *parameters;
  if (self.userData) {
    parameters = @{@"wsuserid" : [self.userData objectForKey:@"wsuserid"]};
    
    //configura parametros
    NSData* params = [NSJSONSerialization dataWithJSONObject:parameters options:0 error:nil];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", OAuthServiceURL, path]];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    [urlRequest setHTTPMethod:@"POST"];
    [urlRequest setHTTPBody:params];
    
    //Executa requisição
    NSURLSessionDataTask *dataTask = [[self session] dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
      
      if (error) { //Erro na execuçao da API
        //NSLog(@"Error in API request: %@", error.localizedDescription);
      } else if ([data length] == 0) { // não passou pela validação
        [defaults setObject:nil forKey:@"userData"];
        [defaults setObject:nil forKey:@"oauthToken"];
        [defaults setObject:nil forKey:@"oauthTokenSecret"];
        
        [self setOauthToken: nil];
        [self setOauthTokenSecret: nil];
        //[self setMessage:[json valueForKey:@"message"]];
      } else { // Usuário válido
        //NSLog(@"%@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
      }
    }];
    [dataTask resume];
  } else {
    [defaults setObject:nil forKey:@"userData"];
    [defaults setObject:nil forKey:@"oauthToken"];
    [defaults setObject:nil forKey:@"oauthTokenSecret"];
    
    [self setOauthToken: nil];
    [self setOauthTokenSecret: nil];
    //[self setMessage:[json valueForKey:@"message"]];
  }
}
 */

- (NSURLSession *)session {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    // Session Configuration
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    // Initialize Session
    _session = [NSURLSession sessionWithConfiguration:defaultConfigObject delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
  });
  return _session;
}


@end
