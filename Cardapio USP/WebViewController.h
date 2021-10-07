//
//  WebViewController.h
//  Cardapio USP
//
//  Created by Vagner Machado on 20/04/21.
//  Copyright © 2021 USP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "SWRevealViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface WebViewController : UIViewController <WKNavigationDelegate, SWRevealViewControllerDelegate>

@property (weak, nonatomic) IBOutlet WKWebView *webview;
@property (strong, nonatomic) NSString *urlString;
@property (strong, nonatomic) NSString *navTitle;


@end

NS_ASSUME_NONNULL_END
