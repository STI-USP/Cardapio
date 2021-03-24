//
//  MenuDataModel.h
//  Cardapio USP
//
//  Created by Alessandro Souzadidier on 13/06/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MenuDataModel.h" 
#import "DataModel.h"
#import "Restaurant.h"


@interface InfoViewController : UITableViewController<UITabBarControllerDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableDictionary *restaurantDc;

@property (strong, nonatomic) MenuDataModel *_menuDataModel;
@property (strong, nonatomic) Restaurant *restaurant;

- (IBAction)doneButtonTapped:(id)sender;
- (IBAction)setAsPreferred:(id)sender;
- (IBAction)resetPreferred:(id)sender;


@end
  
