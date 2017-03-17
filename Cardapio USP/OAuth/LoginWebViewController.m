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

#define UserURLString    @"https://dev.uspdigital.usp.br/wsusuario/oauth/usuariousp" //dev
//#define UserURLString    @"https://uspdigital.usp.br/wsusuario/oauth/usuariousp" //prod

@interface LoginWebViewController ()

@property (nonatomic, strong) OAuth1Controller *oauthController;
@property (nonatomic, strong) KeychainItemWrapper *keychainWrapper;
@property (nonatomic, strong) OAuthUSP *oAuthUSP;

@end



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
  
  
  _oAuthUSP = [OAuthUSP sharedInstance];
  //_keychainWrapper = [[KeychainItemWrapper alloc] initWithIdentifier:@"UserAuthToken" accessGroup:nil];
  
  //NavigationBar
  UINavigationBar *navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 64)];
  UINavigationItem *navItem = [[UINavigationItem alloc] init];
  UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancelar" style:UIBarButtonItemStylePlain target:self action:@selector(cancelar)];
  navItem.rightBarButtonItem = rightButton;
  navBar.items = @[navItem];
  [self.view addSubview:navBar];
  
  [self login];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (BOOL)shouldAutorotate {
  return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
  return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation {
  return UIInterfaceOrientationPortrait;
}

- (OAuth1Controller *)oauthController {
  if (_oauthController == nil)
    _oauthController = [[OAuth1Controller alloc] init];
  
  return _oauthController;
}


#pragma mark - Action
- (void)cancelar {
  [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - STIOauth

- (void)login {
  [self.oauthController loginWithWebView:self.webView completion:^(NSDictionary *oauthTokens, NSError *error) {

    [self dismissViewControllerAnimated:YES completion: ^{
      self.oauthController = nil;
    }];

    if (!error) {
      // Store your tokens for authenticating your later requests, consider storing the tokens in the Keychain
      //[_keychainWrapper setObject:oauthTokens[@"oauth_token"] forKey:(__bridge id)(kSecAttrAccount)];
      //[_keychainWrapper setObject:oauthTokens[@"oauth_token_secret"] forKey:(__bridge id)(kSecValueData)];
      
      [_oAuthUSP setOauthToken:oauthTokens[@"oauth_token"]];
      [_oAuthUSP setOauthTokenSecret:oauthTokens[@"oauth_token_secret"]];

      [self saveUserData];
      
    } else {
      UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Erro" message:@"Não foi possível fazer o login no momento. Tente novamente mais tarde." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
      [alertView show];
      NSLog(@"%@", [error description]);
    }
    
  }];
  
}
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
  //[defaults setObject:nil forKey:@"userData"];
  [defaults setObject:nil forKey:@"oauthToken"];
  [defaults setObject:nil forKey:@"oauthTokenSecret"];
  
  [_oAuthUSP setOauthToken: nil];
  [_oAuthUSP setOauthTokenSecret: nil];
  
  [self.tabBarController setSelectedIndex:0];
  
}

#pragma mark - STI Data

- (void)saveUserData {
  // Taking oauthToken and oauthTokenSecret
  //[_oAuthUSP setOauthToken: [_keychainWrapper objectForKey:(__bridge id)(kSecAttrAccount)]];
  //[_oAuthUSP setOauthTokenSecret: [_keychainWrapper objectForKey:(__bridge id)(kSecValueData)]];
  
  // USP Digital POST Request
  NSDictionary *parameters = nil;
  
  // Build authorized request based on path, parameters, tokens, timestamp etc.
  NSURLRequest *preparedRequest = [OAuth1Controller preparedRequestForPath:UserURLString
                                                                parameters:parameters
                                                                HTTPmethod:@"POST"
                                                                oauthToken:_oAuthUSP.oauthToken
                                                               oauthSecret:_oAuthUSP.oauthTokenSecret];
  
  
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
    //NSLog(@"%@", self.userData);
    [_oAuthUSP setUserData:self.userData];
    [_oAuthUSP registrarToken];
  }
}

@end
