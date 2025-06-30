//
//  MenuViewController.h
//  Cardapio USP
//
//  Created by Jun Okamoto Jr. on 19/05/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//
//  Atualizado em 17/06/25 por Vagner Machado
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "DKScrollingTabController.h"

@interface MenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DKScrollingTabControllerDelegate, UIScrollViewDelegate, SWRevealViewControllerDelegate>

@property (weak,   nonatomic) IBOutlet UITableView *tableView;
@property (weak,   nonatomic) IBOutlet UILabel    *diaDaSemanaLabel;

@property (strong, nonatomic) DKScrollingTabController *dateTabController;
@property (strong, nonatomic) UIButton                *infoButton;

@end
