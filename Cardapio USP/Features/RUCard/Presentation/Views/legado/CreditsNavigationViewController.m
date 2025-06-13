//
//  CreditsNavigationViewController.m
//  Cardapio USP
//
//  Created by Vagner Machado on 19/12/16.
//  Copyright © 2016 EPUSP. All rights reserved.
//

#import "CreditsNavigationViewController.h"

@interface CreditsNavigationViewController ()

@end

@implementation CreditsNavigationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
  //Reveal View Controller ----------------
  SWRevealViewController *revealViewController = self.revealViewController;
  if (revealViewController) {
    [self.revealViewController panGestureRecognizer];
    [self.revealViewController tapGestureRecognizer];
    self.revealViewController.delegate = self;
  }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - SWRevealViewControllerDelegate

// Implement this to return NO when you want the pan gesture recognizer to be ignored
- (BOOL)revealControllerPanGestureShouldBegin:(SWRevealViewController *)revealController {
  return NO;
}

@end
