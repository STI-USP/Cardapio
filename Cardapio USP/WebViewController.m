//
//  WebViewController.m
//  Cardapio USP
//
//  Created by Vagner Machado on 20/04/21.
//  Copyright © 2021 USP. All rights reserved.
//

#import "WebViewController.h"
#import "SVProgressHUD.h"

@interface WebViewController ()

@end

@implementation WebViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  [self.view addSubview:_webview];
  _webview.navigationDelegate = self;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self.navigationItem setTitle:self.navTitle];
  [SVProgressHUD show];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];

  //URL Request
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:_urlString] cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
  [_webview loadRequest:request];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
  NSLog(@"didCommitNavigation");
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
  NSLog(@"didFinishNavigation");
  [SVProgressHUD dismiss];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
  NSLog(@"didFailNavigation");
  [SVProgressHUD showErrorWithStatus:error.localizedDescription];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(nonnull WKNavigationAction *)navigationAction decisionHandler:(nonnull void (^)(WKNavigationActionPolicy))decisionHandler {

  if (navigationAction.navigationType == WKNavigationTypeLinkActivated) {
    if (navigationAction.request.URL) {
      NSLog(@"%@", navigationAction.request.URL.host);
      if ([navigationAction.request.URL.resourceSpecifier containsString:@"usp.br"]) {
        if ([[UIApplication sharedApplication] canOpenURL:navigationAction.request.URL]) {
          UIApplication *application = [UIApplication sharedApplication];
          [application openURL:navigationAction.request.URL options:@{} completionHandler:nil];
          decisionHandler(WKNavigationActionPolicyCancel);
        }
      } else {
        decisionHandler(WKNavigationActionPolicyAllow);
      }
    }
  } else {
    decisionHandler(WKNavigationActionPolicyAllow);
  }
}

@end
