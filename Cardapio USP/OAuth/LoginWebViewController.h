//
//  LoginWebViewController.h
//  Simple-OAuth1
//
//  Created by Christian Hansen on 02/12/12.
//  Copyright (c) 2012 Christian-Hansen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

@interface LoginWebViewController : UIViewController <WKNavigationDelegate>

@property (weak, nonatomic) IBOutlet WKWebView *webView;

// OAuth credentials
//@property (nonatomic, strong) NSString *oauthToken;
//@property (nonatomic, strong) NSString *oauthTokenSecret;

// STI User Data
@property (nonatomic, strong) NSMutableDictionary *userData;

//- (BOOL)isLoggedIn;
- (void)logout;

@end
