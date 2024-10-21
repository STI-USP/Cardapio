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
#import "Constants.h"

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
  
  [_webView setNavigationDelegate:self];

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
  [self.oauthController loginWithWebView:_webView completion:^(NSDictionary *oauthTokens, NSError *error) {

    dispatch_async(dispatch_get_main_queue(), ^{
      [self dismissViewControllerAnimated:YES completion: ^{
        self.oauthController = nil;
      }];
    });

    if (!error) {
      // Store your tokens for authenticating your later requests, consider storing the tokens in the Keychain
      //[_keychainWrapper setObject:oauthTokens[@"oauth_token"] forKey:(__bridge id)(kSecAttrAccount)];
      //[_keychainWrapper setObject:oauthTokens[@"oauth_token_secret"] forKey:(__bridge id)(kSecValueData)];
      
      [self->_oAuthUSP setOauthToken:oauthTokens[@"oauth_token"]];
      [self->_oAuthUSP setOauthTokenSecret:oauthTokens[@"oauth_token_secret"]];

      [self saveUserData];
      
    } else {
      [SVProgressHUD showErrorWithStatus:@"Não foi possível fazer o login no momento. Tente novamente mais tarde."];
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

  // USP Digital POST Request
  NSDictionary *parameters = nil;
  
  // Build authorized request based on path, parameters, tokens, timestamp etc.
  NSURLRequest *preparedRequest = [OAuth1Controller preparedRequestForPath:UserURLString
                                                                parameters:parameters
                                                                HTTPmethod:@"POST"
                                                                oauthToken:_oAuthUSP.oauthToken
                                                               oauthSecret:_oAuthUSP.oauthTokenSecret];
  
  
  NSURLSession *session = [NSURLSession sharedSession];
  [[session dataTaskWithRequest:preparedRequest completionHandler:^(NSData *data,
                                NSURLResponse *response,
                                NSError *error) {
    // handle response
    if (error) {
      NSLog(@"Error in API request: %@", error.localizedDescription);
    } else {
      self.userData = [NSJSONSerialization JSONObjectWithData:data options: NSJSONReadingMutableContainers error: nil];
      if (self.userData) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:data forKey:@"userData"];
        [defaults synchronize];
        [self->_oAuthUSP setUserData:self.userData];
        [self->_oAuthUSP registrarToken];
      } else {
        NSLog(@"Received nil or invalid JSON data, not saving to defaults.");
      }
    }
  }] resume];
}

@end
