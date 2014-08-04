//
//  MainViewController.h
//  Cardapio USP
//
//  Created by Jun Okamoto Jr. on 19/05/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, weak) IBOutlet UILabel *diaDaSemanaLabel;

- (IBAction)showRestaurantSelector:(id)sender;
- (void)forwardDate:(id)sender;

@end
