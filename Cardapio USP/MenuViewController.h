//
//  MainViewController.h
//  Cardapio USP
//
//  Created by Jun Okamoto Jr. on 19/05/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DKScrollingTabController.h"
#import "SWRevealViewController.h"


@interface MenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate, UIAlertViewDelegate, SWRevealViewControllerDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UILabel *diaDaSemanaLabel;
@property (nonatomic, strong) DKScrollingTabController *dateTabController;
@property (nonatomic) BOOL isClosed;
@property (nonatomic, strong) UIButton *infoButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightButton;


- (IBAction)showRestaurantSelector:(id)sender;
- (IBAction)showCredits:(id)sender;

@end
