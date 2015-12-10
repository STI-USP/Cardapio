//
//  LoginWebViewController.m
//  Simple-OAuth1
//
//  Created by Christian Hansen on 02/12/12.
//  Copyright (c) 2012 Christian-Hansen. All rights reserved.
//

#import "LoginWebViewController.h"
#import "KeychainItemWrapper.h"
#import "OAuth1Controller.h"
#import "OAuthUSP.h"
#import "SVProgressHUD.h"

#define UserURLString    @"https://uspdigital.usp.br/wsusuario/oauth/usuariousp"

@interface LoginWebViewController () {
}

@property (nonatomic, strong) OAuth1Controller *oauthController;
@property (nonatomic, strong) KeychainItemWrapper *keychainWrapper;

@end

OAuthUSP *oAuthUSP;

@implementation LoginWebViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.

  
  oAuthUSP = [OAuthUSP sharedInstance];
  _keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"UserAuthToken" accessGroup:nil];
  
  [self.oauthController loginWithWebView:self.webView completion:^(NSDictionary *oauthTokens, NSError *error) {
    if (!error) {
      // Store your tokens for authenticating your later requests, consider storing the tokens in the Keychain
      [_keychainWrapper setObject:oauthTokens[@"oauth_token"] forKey:(__bridge id)(kSecAttrAccount)];
      [_keychainWrapper setObject:oauthTokens[@"oauth_token_secret"] forKey:(__bridge id)(kSecValueData)];

      [[NSNotificationCenter defaultCenter] postNotificationName:@"LoggedIn" object:self];

      [self saveUserData];
      
    } else {
      [SVProgressHUD showErrorWithStatus:@"Não foi possível fazer o login no momento. Tente novamente mais tarde."];

      /*
      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Erro" message:@"Não foi possível fazer o login no momento. Tente novamente mais tarde." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
      [alertView show];*/
    }
    
    [self dismissViewControllerAnimated:YES completion: ^{
        self.oauthController = nil;
    }];
  }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (OAuth1Controller *)oauthController
{
  if (_oauthController == nil) {
    _oauthController = [[OAuth1Controller alloc] init];
  }
  return _oauthController;
}


#pragma mark - Action
- (IBAction)cancelTapped:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - STIOauth


- (void)logout {
  // Clear cookies so no session cookies can be used for the UIWebview
  NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
  for (NSHTTPCookie *cookie in [storage cookies]) {
    if (cookie.isSecure) {
      [storage deleteCookie:cookie];
    }
  }
  
  self.webView = Nil;

  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [defaults setObject:nil forKey:@"userData"];
  [defaults setObject:nil forKey:@"oauthToken"];
  [defaults setObject:nil forKey:@"oauthTokenSecret"];

  [oAuthUSP setOauthToken: nil];
  [oAuthUSP setOauthTokenSecret: nil];
  
  [self.tabBarController setSelectedIndex:0];

}

#pragma mark - STI Data

- (void)saveUserData {
  // Taking oauthToken and oauthTokenSecret
  [oAuthUSP setOauthToken: [_keychainWrapper objectForKey:(__bridge id)(kSecAttrAccount)]];
  [oAuthUSP setOauthTokenSecret: [_keychainWrapper objectForKey:(__bridge id)(kSecValueData)]];
  
  // USP Digital POST Request
  NSDictionary *parameters = nil;
  
  // Build authorized request based on path, parameters, tokens, timestamp etc.
  NSURLRequest *preparedRequest = [OAuth1Controller preparedRequestForPath:UserURLString
                                                                parameters:parameters
                                                                HTTPmethod:@"POST"
                                                                oauthToken:oAuthUSP.oauthToken
                                                               oauthSecret:oAuthUSP.oauthTokenSecret];
  
  
  // Request sincrono para travar as opções que dependem dessa resposta
  NSURLResponse *response = nil;
  NSError *error = nil;
  NSData *data = [NSURLConnection sendSynchronousRequest:preparedRequest
                                        returningResponse:&response
                                                    error:&error];
  if (error) {
      //NSLog(@"Error in API request: %@", error.localizedDescription);
  } else {
    self.userData = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: nil];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:data forKey:@"userData"];
    [defaults synchronize];
    [oAuthUSP setUserData:self.userData];
  }
  
}

@end
