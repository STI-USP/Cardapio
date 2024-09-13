//
//  STIOauth.m
//  Bibliotecas USP
//
//  Created by Vagner Machado on 4/2/15.
//  Copyright (c) 2015 USP. All rights reserved.
//

#import "STIOauth.h"
#import "Constants.h"

@implementation STIOauth


+ (STIOauth *)sharedInstance {
  // Aloca e inicializa objeto singleton.
  // Utiliza Grand Central Dispatch (GCD) para ser thread safe.
  static STIOauth *oauth = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{ oauth = [[STIOauth alloc] init]; });
  return oauth;
}

#pragma mark - STI

- (void)registrarToken:(NSString *)token {

  //configura parametros
  NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
             token, @"token",
             @"AppBibliot", @"app",
             nil];
  
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
        [self consultarToken:token];
      } else {
        NSLog(@"error: %ld", (long)[httpResponse statusCode]);
      }
    } else if (error) {
      NSLog(@"error: %@", [error description]);
    }
  }];
  
  [dataTask resume];
}


- (void)invalidarToken:(NSString *)token {

  //configura parametros
  NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithObjectsAndKeys:
                               token, @"token",
                               nil];
  
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
        NSLog(@"invalidar: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
      } else {
        NSLog(@"error: %ld", (long)[httpResponse statusCode]);
      }
    } else if (error) {
      NSLog(@"error: %@", [error description]);
    }
  }];
  
  [dataTask resume];
}

- (void)consultarToken:(NSString *)token {
  
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
    } else if (error) {
      NSLog(@"error: %@", [error description]);
    }
  }];
  
  [dataTask resume];
}


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
