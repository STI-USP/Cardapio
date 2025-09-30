//
//  MainViewController.m
//  Cardapio USP
//
//  Created by Vagner Machado on 14/08/25.
//

#import "MenuDataModel.h"
#import "Menu.h"
#import "Period.h"
#import "MenuViewController.h"
#import "REFrostedViewController.h"
#import "DKScrollingTabController.h"
#import "RestaurantDataModel.h"
#import "DataModel.h"
#import "SVProgressHUD.h"
#import "OAuthUSP.h"
#import "LoginWebViewController.h"
#import "CreditsViewController.h"
#import "CreditsNavigationViewController.h"
#import "BoletoViewController.h"
#import "MenuViewModel.h" // 🔸 novo

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)
#define kWIDTH UIScreen.mainScreen.bounds.size.width

@interface MenuViewController () <DKScrollingTabControllerDelegate, SWRevealViewControllerDelegate, MenuViewModelDelegate> {
  RestaurantDataModel *_restaurantDataModel;
  MenuDataModel *_menuDataModel;
  DataModel *dataModel;

  // Mantidos se você quiser compat, mas o VM já expõe week/selectedIndex
  NSMutableArray<Menu *> *menuArray;
  Menu *menu;
  int diaDaSemana;
  NSMutableString *stringForLunch;

  OAuthUSP *oauth;
  LoginWebViewController *loginViewController;
  CreditsViewController *creditsViewController;
  BoletoViewController *boletoViewController;
}

// UI
@property (nonatomic, strong) DKScrollingTabController *dateTabController;
@property (nonatomic, strong) UIButton *infoButton;

// MVVM
@property (nonatomic, strong) MenuViewModel *viewModel;

@end

@implementation MenuViewController

@synthesize diaDaSemanaLabel;

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];

  dataModel = [DataModel getInstance];
  oauth = [OAuthUSP sharedInstance];
  stringForLunch = [NSMutableString stringWithFormat:@""];

  // ViewModel
  self.viewModel = [[MenuViewModel alloc] initWithDataModel:dataModel];
  self.viewModel.delegate = self;

  [self setupDKScrollingTabController];
  self.tableView.contentInset = UIEdgeInsetsMake(8, 0, 0, 0);

  // Notifications (somente as que não são do menu; o VM já escuta DidChangeRestaurant/DidReceiveMenu)
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecieveUserData:) name:@"DidRecieveUserData" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveBill:) name:@"DidReceiveBill" object:nil];

  // Filtro & Info
  [self setupFilterButton];
  [self setupInfoButton];
}

- (void)viewSafeAreaInsetsDidChange {
  [super viewSafeAreaInsetsDidChange];
  [self setupInfoButton];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  NSString *name = [[dataModel currentRestaurant] valueForKey:@"name"];
  [self.navigationItem setTitle:(name ?: @"")];

  // Dispara carregamento via VM
  [self.viewModel reloadMenus];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  if ([self isMovingFromParentViewController]) {
    NSLog(@"View controller was popped");
  }
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - DKScrollingTabController (setup)

- (void)setupDKScrollingTabController {
  self.dateTabController = [[DKScrollingTabController alloc] init];
  [self addChildViewController:self.dateTabController];
  [self.dateTabController didMoveToParentViewController:self];
  [self.view addSubview:self.dateTabController.view];

  CGFloat topPadding = 0.0;
  if (@available(iOS 11.0, *)) {
    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
    topPadding = window.safeAreaInsets.top;
    self.dateTabController.view.frame = CGRectMake(0, topPadding+40., CGRectGetWidth(self.view.bounds), 56);
  } else {
    self.dateTabController.view.frame = CGRectMake(0, 40., CGRectGetWidth(self.view.bounds), 56);
  }

  if (@available(iOS 13.0, *)) {
    self.dateTabController.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
  } else {
    self.dateTabController.view.backgroundColor = [UIColor lightTextColor];
  }

  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat screenWidth  = [UIScreen mainScreen].bounds.size.width;
    if (screenHeight < screenWidth) screenHeight = screenWidth;

    if (screenHeight > 480 && screenHeight < 667) {
      self.dateTabController.buttonPadding = 4.2;
    } else if (screenHeight > 480 && screenHeight < 736) {
      self.dateTabController.buttonPadding = 8.2;
    } else if (screenHeight > 480 && screenHeight < 812) {
      self.dateTabController.buttonPadding = 11;
    } else if (screenHeight > 480 && screenHeight < 896) {
      self.dateTabController.buttonPadding = 8.2;
    } else if (screenHeight > 480) {
      self.dateTabController.buttonPadding = 11;
    } else {
      self.dateTabController.buttonPadding = 3.2;
    }
  }

  self.dateTabController.underlineIndicator = YES;
  self.dateTabController.underlineIndicatorColor = [UIColor colorNamed:@"usp_orange"];
  self.dateTabController.buttonsScrollView.showsHorizontalScrollIndicator = NO;
  self.dateTabController.selectedBackgroundColor = [UIColor clearColor];
  if (@available(iOS 13.0, *)) {
    self.dateTabController.selectedTextColor = [UIColor labelColor];
  } else {
    self.dateTabController.selectedTextColor = [UIColor blackColor];
  }
  self.dateTabController.unselectedTextColor = [UIColor grayColor];
  self.dateTabController.unselectedBackgroundColor = [UIColor clearColor];

  // Placeholder inicial (7 botões) — será substituído pelo VM quando chegar a semana
  self.dateTabController.selection = @[@"           \n0",
                                       @"           \n0",
                                       @"           \n0",
                                       @"           \n0",
                                       @"           \n0",
                                       @"           \n0",
                                       @"           \n0"];
  self.dateTabController.delegate = self;
}

#pragma mark - Botões (Filtro / Info)

- (void)setupFilterButton {
  UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"slider.horizontal.3"]
                                                                   style:UIBarButtonItemStylePlain
                                                                  target:self
                                                                  action:@selector(showRestaurantsFilter)];
  self.navigationItem.rightBarButtonItem = filterButton;
}

- (void)setupInfoButton {
  CGFloat buttonSize = 40;
  CGFloat padding = 20;

  if (!self.infoButton) {
    self.infoButton = [UIButton buttonWithType:UIButtonTypeCustom];

    self.infoButton.layer.cornerRadius = buttonSize / 2;
    self.infoButton.backgroundColor = [UIColor colorNamed:@"usp_green"];
    self.infoButton.tintColor = [UIColor whiteColor];

    self.infoButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.infoButton.layer.shadowOpacity = 0.2;
    self.infoButton.layer.shadowOffset = CGSizeMake(0, 2);
    self.infoButton.layer.shadowRadius = 4;

    self.infoButton.contentEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);
    [self.infoButton addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.infoButton];
  }

  UIEdgeInsets safeAreaInsets = self.view.safeAreaInsets;
  CGFloat x = CGRectGetWidth(self.view.bounds) - buttonSize - safeAreaInsets.right - padding;
  CGFloat y = CGRectGetHeight(self.view.bounds) - buttonSize - safeAreaInsets.bottom - padding;
  self.infoButton.frame = CGRectMake(x, y, buttonSize, buttonSize);

  UIImage *infoImage = nil;
  if (@available(iOS 13.0, *)) {
    infoImage = [UIImage systemImageNamed:@"info.circle"];
  } else {
    infoImage = [UIImage imageNamed:@"info"];
  }
  [self.infoButton setImage:infoImage forState:UIControlStateNormal];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
  [super traitCollectionDidChange:previousTraitCollection];
  if (@available(iOS 13.0, *)) {
    if ([self.traitCollection userInterfaceStyle] != [previousTraitCollection userInterfaceStyle]) {
      [self setupInfoButton];
    }
  }
}

- (void)showRestaurantsFilter {
  UIViewController *filterVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RestaurantsFilterController"];
  filterVC.modalPresentationStyle = UIModalPresentationPageSheet;
  [self presentViewController:filterVC animated:YES completion:nil];
}

- (void)showInfo {
  [SVProgressHUD show];
  [self performSegueWithIdentifier:@"showInfo" sender:self];
}

#pragma mark - Semana / Tabs (via VM)

- (void)setupWeekTabsWithTitles:(NSArray<NSString *> *)titles {
  for (NSInteger i = 0; i < titles.count; i++) {
    [self.dateTabController setButtonName:titles[i] atIndex:i];
  }
  [self.dateTabController.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
    button.titleLabel.numberOfLines = 2;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
  }];

  [self refreshTabButtonsStyleForSelection:self.viewModel.selectedIndex];

  self.dateTabController.buttonPadding = 12;
  self.dateTabController.underlineIndicator = YES;
  self.dateTabController.underlineIndicatorColor = [UIColor colorNamed:@"usp_orange"];
  self.dateTabController.delegate = self;

  [self.dateTabController selectButtonWithIndex:self.viewModel.selectedIndex];
}

- (void)refreshTabButtonsStyleForSelection:(NSUInteger)selection {
  [self.dateTabController.buttons enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
    NSString *titulo = button.titleLabel.text ?: @"";
    NSArray *linhas = [titulo componentsSeparatedByString:@"\n"];
    if (linhas.count != 2) return;

    NSString *linha1 = linhas[0];
    NSString *linha2 = linhas[1];

    BOOL isSelecionado = (idx == selection);
    UIFont *fontDia = isSelecionado ? [UIFont boldSystemFontOfSize:12] : [UIFont systemFontOfSize:12];
    UIFont *fontNumero = isSelecionado ? [UIFont boldSystemFontOfSize:14] : [UIFont systemFontOfSize:14];
    UIColor *corTexto;
    if (@available(iOS 13.0, *)) {
      corTexto = isSelecionado ? [UIColor labelColor] : [UIColor grayColor];
    } else {
      corTexto = isSelecionado ? [UIColor blackColor] : [UIColor grayColor];
    }

    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:titulo];
    [attributed addAttribute:NSFontAttributeName value:fontDia range:NSMakeRange(0, linha1.length)];
    [attributed addAttribute:NSFontAttributeName value:fontNumero range:NSMakeRange(linha1.length + 1, linha2.length)];
    [attributed addAttribute:NSForegroundColorAttributeName value:corTexto range:NSMakeRange(0, titulo.length)];
    [button setAttributedTitle:attributed forState:UIControlStateNormal];
  }];
}

- (void)setupDayLabel:(int)dia {
  if (dia < 0 || dia >= self.viewModel.week.count) return;
  [diaDaSemanaLabel setText:self.viewModel.dayHeaderTitle];
  
  [[self tableView] reloadData];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [self.viewModel numberOfSections];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 26;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  CGFloat height = 26, imageSize = 18, padding = 0;

  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, height)];
  view.backgroundColor = [UIColor clearColor];

  UILabel *label = [[UILabel alloc] init];
  label.font = [UIFont boldSystemFontOfSize:15];
  label.textColor = [UIColor grayColor];

  UIImageView *imageView = nil;
  switch (section) {
    case 0: label.text = @"ALMOÇO"; imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"almoco"]]; break;
    case 1: label.text = @"JANTAR"; imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jantar"]]; break;
    case 2: label.text = @"OBSERVAÇÃO"; break;
    default: break;
  }

  if (imageView) {
    imageView.tintColor = [UIColor grayColor];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(padding, (height - imageSize) / 2, imageSize, imageSize);
    [view addSubview:imageView];
    label.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + 8, 0, tableView.frame.size.width - padding - imageSize - 8, height);
  } else {
    label.frame = CGRectMake(padding, 0, tableView.frame.size.width - padding * 2, height);
  }

  [view addSubview:label];
  return view;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
  return [self.viewModel footerForSection:section];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell" forIndexPath:indexPath];
  self.tableView.estimatedRowHeight = 150.;

  NSString *texto = [self.viewModel textForSection:indexPath.section];

  UIColor* (^SecondaryLabelColor)(void) = ^UIColor *{
    if (@available(iOS 13.0, *)) return [UIColor secondaryLabelColor];
    return [UIColor grayColor];
  };

  if (indexPath.section <= 1) {
    BOOL hasMenu = (texto.length && ![texto isEqualToString:@"Sem cardápio publicado"]);
    UIColor *textColor;
    if (@available(iOS 13.0, *)) {
      textColor = hasMenu ? [UIColor labelColor] : SecondaryLabelColor();
      cell.backgroundColor = [UIColor systemBackgroundColor];
    } else {
      textColor = hasMenu ? [UIColor blackColor] : SecondaryLabelColor();
    }
    cell.textLabel.text = texto;
    cell.textLabel.textColor = textColor;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
  } else {
    cell.textLabel.text = texto ?: @"";
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    if (@available(iOS 13.0, *)) {
      cell.backgroundColor = [UIColor systemGroupedBackgroundColor];
    }
  }
  return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return UITableViewAutomaticDimension;
}

#pragma mark - Ações

- (IBAction)showRestaurantSelector:(id)sender {
  [self showRestaurantsFilter];
}

- (IBAction)showCredits:(id)sender {
  creditsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"creditsViewController"];

  if (![oauth isLoggedIn]) {
    loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginWebViewController"];
    [self presentViewController:loginViewController animated:YES completion:nil];
  } else {
    [dataModel getCreditoRUCard];
    CreditsNavigationViewController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"navController"];
    [self presentViewController:navController animated:YES completion:nil];
  }
}

#pragma mark - DKScrollingTabControllerDelegate

- (void)ScrollingTabController:(DKScrollingTabController *)controller selection:(NSUInteger)selection {
  if (selection >= self.viewModel.week.count) return;
  self.viewModel.selectedIndex = selection; // dispara delegate de dia
  [self refreshTabButtonsStyleForSelection:selection];
}

#pragma mark - ViewModel Delegate

- (void)menuViewModelDidUpdateWeek:(MenuViewModel *)viewModel {
  // Atualiza Tabs e seleciona o dia atual
  [self setupWeekTabsWithTitles:self.viewModel.tabTitles];
}

- (void)menuViewModelDidUpdateDay:(MenuViewModel *)viewModel {
  diaDaSemana = (int)self.viewModel.selectedIndex;
  [self setupDayLabel:(int)self.viewModel.selectedIndex];

  NSString *name = [[dataModel currentRestaurant] valueForKey:@"name"];
  [self.navigationItem setTitle:(name ?: @"")];

  [self.tableView reloadData];
}

- (void)menuViewModelNoServerMenu:(MenuViewModel *)viewModel {
  [SVProgressHUD showInfoWithStatus:@"Sem cardápio publicado para essa semana."];
}

#pragma mark - Model Notifications (não relacionadas ao menu)

- (void)didRecieveUserData:(NSNotification *)notification {
  [self presentViewController:creditsViewController animated:YES completion:nil];
}

- (void)didReceiveBill:(NSNotification *)notification {
  boletoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"boletoViewController"];
  [self presentViewController:boletoViewController animated:YES completion:nil];
}

#pragma mark - Fechamento RU

- (BOOL)isClosed {
  return [self.viewModel isClosed];
}

#pragma mark - SWRevealViewControllerDelegate

- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position {
  if (position == 2) {
    [self.infoButton setHidden:YES];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
      self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
  } else {
    [self.infoButton setHidden:NO];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
      self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
  }
}

@end
