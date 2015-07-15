//
//  RestaurantDetailTableViewController.h
//  Cardapio USP
//
//  Created by Vagner Machado on 7/14/15.
//  Copyright (c) 2015 EPUSP. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RestaurantDetailTableViewController : UITableViewController

@property(nonatomic, weak) NSDictionary *restaurant;

@property (strong, nonatomic) IBOutlet UIImageView *restImage;
@property (strong, nonatomic) IBOutlet UIImageView *restMap;
@property (strong, nonatomic) IBOutlet UILabel *restaurantName;
@property (strong, nonatomic) IBOutlet UILabel *restaurantNameOverlay;

- (IBAction)setAsPreferred:(id)sender;
- (IBAction)resetPreferred:(id)sender;

@end
