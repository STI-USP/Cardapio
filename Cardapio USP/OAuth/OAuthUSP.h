//
//  OAuthUSP.h
//  CeTI OAuth
//
//  Created by Vagner Machado on 8/28/15.
//  Copyright (c) 2015 USP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OAuthUSP : NSObject {
  
}

+ (OAuthUSP *)sharedInstance; ///< construtor singleton

//OAuth credentials
@property (nonatomic, strong) NSString *oauthToken;
@property (nonatomic, strong) NSString *oauthTokenSecret;

//WSUsuario
@property (nonatomic, copy) NSDictionary *userData;

//HTTPSession
@property (strong, nonatomic) NSURLSession *session;

- (BOOL)isLoggedIn;
- (void)login;
- (void)logout;
- (void)registrarToken;
- (void)invalidarToken;
- (void)consultarToken;
//- (void)checkUser;

@end
