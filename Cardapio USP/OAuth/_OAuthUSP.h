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


- (BOOL)isLoggedIn;
- (void)checkUser;
- (void)login;
- (void)logout;

@end
