//
//  MenuViewController.h
//  Cardapio USP
//
//  Criado em 19/05/14 — Atualizado em 13/06/25
//

#import <UIKit/UIKit.h>
#import "SWRevealViewController.h"
#import "DKScrollingTabController.h"

@interface MenuViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DKScrollingTabControllerDelegate, UIScrollViewDelegate, SWRevealViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *diaDaSemanaLabel;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rightButton;

@property (strong, nonatomic) DKScrollingTabController *dateTabController;
@property (strong, nonatomic) UIButton *infoButton;

@end
