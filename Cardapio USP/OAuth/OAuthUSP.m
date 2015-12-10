//
//  OAuthUSP.m
//  CeTI OAuth
//
//  Created by Vagner Machado on 8/28/15.
//  Copyright (c) 2015 USP. All rights reserved.
//

#import "OAuthUSP.h"
#import "OAuth1Controller.h"
#import "LoginWebViewController.h"

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
    self.userData = [NSJSONSerialization JSONObjectWithData:[[defaults objectForKey:@"userData"] copy] options: NSJSONReadingMutableContainers error: nil];
    return self.userData;
  } else {
    return nil;
  }
}

#pragma mark - Setters

-(void)setUserData:(NSDictionary *)userData {
  [[NSNotificationCenter defaultCenter] postNotificationName:@"DidRecieveUserData" object:self];
}

-(void)setOauthToken:(NSString *)oauthToken {
  _oauthToken = oauthToken;
  [defaults setObject:_oauthToken forKey:@"oauthToken"];
  [defaults synchronize];
}

-(void)setOauthTokenSecret:(NSString *)oauthTokenSecret {
  _oauthTokenSecret = oauthTokenSecret;
  [defaults setObject:_oauthTokenSecret forKey:@"oauthTokenSecret"];
  [defaults synchronize];
}

#pragma mark - OAuth

- (BOOL) isLoggedIn {
  if (self.oauthToken) {
    return YES;
  } else {
    return NO;
  }
}

- (void)login {

}

- (void)logout {
  
  loginViewController.webView = nil;
  
  [defaults setObject:nil forKey:@"userData"];
  [defaults setObject:nil forKey:@"oauthToken"];
  [defaults setObject:nil forKey:@"oauthTokenSecret"];
  [defaults synchronize];
  
  [self setOauthToken: nil];
  [self setOauthTokenSecret: nil];
}

- (void)checkUser {
  // USP Digital POST Request
  NSString *path = @"https://uspdigital.usp.br/wsusuario/oauth/validar";
  NSDictionary *parameters;
  if (self.userData) {
    parameters = @{@"wsuserid" : [self.userData objectForKey:@"wsuserid"]};
    
    // Build authorized request based on path, parameters, tokens, timestamp etc.
    NSURLRequest *preparedRequest = [OAuth1Controller preparedRequestForPath:path
                                                                  parameters:parameters
                                                                  HTTPmethod:@"POST"
                                                                  oauthToken:self.oauthToken
                                                                 oauthSecret:self.oauthTokenSecret];
    
    // Send the request and when received show the response in the text view
    [NSURLConnection sendAsynchronousRequest:preparedRequest
                                       queue:NSOperationQueue.mainQueue
                           completionHandler:^(NSURLResponse *response, NSData *data, NSError *error) {
                             dispatch_async(dispatch_get_main_queue(), ^{
                               
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
                             });
                           }];
  } else {
    [defaults setObject:nil forKey:@"userData"];
    [defaults setObject:nil forKey:@"oauthToken"];
    [defaults setObject:nil forKey:@"oauthTokenSecret"];
    
    [self setOauthToken: nil];
    [self setOauthTokenSecret: nil];
    //[self setMessage:[json valueForKey:@"message"]];
  }
}


@end
