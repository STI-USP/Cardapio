//
//  MenuDataModel.h
//  Cardapio USP
//
//  Created by Alessandro Souzadidier on 13/06/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuDataModel.h" 
#import "Restaurant.h"

@interface InfoViewController : UITableViewController<UITabBarControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) IBOutlet MenuDataModel *model;
@property (strong, nonatomic) IBOutlet Restaurant *restaurant;  
@property (strong, nonatomic) IBOutlet UIImageView *restImage;
@property (strong, nonatomic) IBOutlet UIImageView *restMap;
@property (strong, nonatomic) IBOutlet UILabel *address;
@property (strong, nonatomic) IBOutlet UILabel *phone;
@property (strong, nonatomic) IBOutlet UILabel *hour;
@property (strong, nonatomic) IBOutlet UILabel *weeklyperiod;


@property (strong, nonatomic) IBOutlet UILabel *workinghours;
@property (strong, nonatomic) IBOutlet UILabel *priceItens;

- (IBAction)doneButtonTapped:(id)sender;

@end
  