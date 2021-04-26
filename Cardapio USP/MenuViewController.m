//
//  MainViewController.m
//  Cardapio USP
//
//  Created by Jun Okamoto Jr. on 19/05/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
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


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]

#define kWIDTH UIScreen.mainScreen.bounds.size.width


@interface MenuViewController () <DKScrollingTabControllerDelegate> {

  //DKScrollingTabController *dateTabController;

  RestaurantDataModel *_restaurantDataModel;
  MenuDataModel *_menuDataModel;
  DataModel *dataModel;
  
  NSMutableArray *menuArray;
  Menu *menu;
  Period *period;
  int diaDaSemana;
  NSMutableString *stringForLunch;
  
  OAuthUSP *oauth;
  LoginWebViewController *loginViewController;
  CreditsViewController *creditsViewController;
  BoletoViewController *boletoViewController;
}

@end

@implementation MenuViewController

@synthesize diaDaSemanaLabel;

- (void)viewDidLoad {
  [super viewDidLoad];

  dataModel = [DataModel getInstance];
  oauth = [OAuthUSP sharedInstance];
  stringForLunch = [NSMutableString stringWithFormat:@""];
  
  [dataModel getMenu];

  self.revealViewController.delegate = self;
  [self.rightButton setAction: @selector(rightRevealToggle:)];
  
  //DKScrollingTabController
  _dateTabController = [[DKScrollingTabController alloc] init];
  [self addChildViewController:_dateTabController];
  [_dateTabController didMoveToParentViewController:self];
  [self.view addSubview:_dateTabController.view];
  
  
  CGFloat topPadding = 0.0;
  CGFloat bottomPadding = 0.0;
  
  if (@available(iOS 11.0, *)) { //Safe Área
    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
    topPadding = window.safeAreaInsets.top;
    bottomPadding = window.safeAreaInsets.bottom;
    
    _dateTabController.view.frame = CGRectMake(0, topPadding+40., CGRectGetWidth(self.view.bounds), 56);
  }

  
  /*
  if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
    CGFloat topPadding = 65.;
    if (((int)[[UIScreen mainScreen] nativeBounds].size.height == 2436) || ((int)[[UIScreen mainScreen] nativeBounds].size.height == 2688)) {
      UIWindow *window = UIApplication.sharedApplication.keyWindow;
      if (@available(iOS 11.0, *)) {
        topPadding += window.safeAreaInsets.top - 40;
      }
    }
    
    UIWindow *window = UIApplication.sharedApplication.keyWindow;
    if (@available(iOS 13.0, *)) {
      topPadding += window.safeAreaInsets.top - 20;
    }

    _dateTabController.view.frame = CGRectMake(0, topPadding, CGRectGetWidth(self.view.bounds), 56);
  }
   */
  
  if (@available(iOS 13.0, *)) {
    _dateTabController.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
  } else {
    _dateTabController.view.backgroundColor = [UIColor lightTextColor];
  }
  if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ){
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if( screenHeight < screenWidth ){
      screenHeight = screenWidth;
    }
    if( screenHeight > 480 && screenHeight < 667 ){
      _dateTabController.buttonPadding = 4.2;
    } else if ( screenHeight > 480 && screenHeight < 736 ){
      _dateTabController.buttonPadding = 8.2;
    } else if ( screenHeight > 480 && screenHeight < 812 ){
      _dateTabController.buttonPadding = 11;
    } else if ( screenHeight > 480 && screenHeight < 896){
      _dateTabController.buttonPadding = 8.2;
    } else if ( screenHeight > 480 ){
      _dateTabController.buttonPadding = 11;
    } else {
      _dateTabController.buttonPadding = 3.2;
    }
  }
  
  _dateTabController.underlineIndicator = YES;
  _dateTabController.underlineIndicatorColor = UIColorFromRGB(0xFCB421);
  _dateTabController.buttonsScrollView.showsHorizontalScrollIndicator = NO;
  _dateTabController.selectedBackgroundColor = [UIColor clearColor];
  if (@available(iOS 13.0, *)) {
    _dateTabController.selectedTextColor = [UIColor labelColor];
  } else {
    // Fallback on earlier versions
    _dateTabController.selectedTextColor = [UIColor blackColor];
  }
  _dateTabController.unselectedTextColor = [UIColor grayColor];
  _dateTabController.unselectedBackgroundColor = [UIColor clearColor];
  _dateTabController.selection = @[@"           \n0",
                                   @"           \n0",
                                   @"           \n0",
                                   @"           \n0",
                                   @"           \n0",
                                   @"           \n0",
                                   @"           \n0"
                                   ];

  //Notification
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeRestaurant:) name:@"DidChangeRestaurant" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMenu:) name:@"DidReceiveMenu" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecieveUserData:) name:@"DidRecieveUserData" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveBill:) name:@"DidReceiveBill" object:nil];

  
  //Float Button - info
  CGFloat width = [UIScreen mainScreen].bounds.size.width - 40;
  CGFloat height = ([UIScreen mainScreen].bounds.size.height - (40 + bottomPadding));
  self.infoButton = [UIButton buttonWithType:UIButtonTypeInfoLight];
  self.infoButton.frame = CGRectMake(width, height, 24., 24.);
  self.infoButton.layer.cornerRadius = self.infoButton.layer.frame.size.width/2;
  self.infoButton.backgroundColor = UIColorFromRGB(0x00A4B9);
  self.infoButton.tintColor = [UIColor whiteColor];
  //[self.infoButton setImage:[UIImage imageNamed:@"CameraButton56x56.png"] forState:UIControlStateNormal];
  [self.infoButton addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchUpInside];
  [self.view insertSubview:self.infoButton aboveSubview:self.view];
}


- (void)viewWillAppear:(BOOL)animated {
  NSString *name;
  name = [[dataModel currentRestaurant]valueForKey:@"name"];
  [self.navigationItem setTitle:name];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  if ([self isMovingFromParentViewController]) {
    NSLog(@"View controller was popped");
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)setupWeekView: (NSArray *) weekMenu {
  
  NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  [gregorian setFirstWeekday:2];
  NSDateComponents *weekdayComponents =[gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
  NSInteger weekday = [weekdayComponents weekday] - 2; //para deixar a segunda feira como 0
  
  if ((int)weekday == -1) {
    diaDaSemana = 6;
  } else {
    diaDaSemana = (int)weekday;
  }

  
  NSString *monButtonName = [[NSString stringWithFormat:@"S\n%@", [[menuArray objectAtIndex:0] date]] substringToIndex:4];
  NSString *tueButtonName = [[NSString stringWithFormat:@"T\n%@", [[menuArray objectAtIndex:1] date]] substringToIndex:4];
  NSString *wedButtonName = [[NSString stringWithFormat:@"Q\n%@", [[menuArray objectAtIndex:2] date]] substringToIndex:4];
  NSString *thuButtonName = [[NSString stringWithFormat:@"Q\n%@", [[menuArray objectAtIndex:3] date]] substringToIndex:4];
  NSString *friButtonName = [[NSString stringWithFormat:@"S\n%@", [[menuArray objectAtIndex:4] date]] substringToIndex:4];
  NSString *satButtonName = [[NSString stringWithFormat:@"S\n%@", [[menuArray objectAtIndex:5] date]] substringToIndex:4];
  NSString *sunButtonName = [[NSString stringWithFormat:@"D\n%@", [[menuArray objectAtIndex:6] date]] substringToIndex:4];

  [_dateTabController setButtonName:monButtonName atIndex:0];
  [_dateTabController setButtonName:tueButtonName atIndex:1];
  [_dateTabController setButtonName:wedButtonName atIndex:2];
  [_dateTabController setButtonName:thuButtonName atIndex:3];
  [_dateTabController setButtonName:friButtonName atIndex:4];
  [_dateTabController setButtonName:satButtonName atIndex:5];
  [_dateTabController setButtonName:sunButtonName atIndex:6];
  
  [_dateTabController.buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    UIButton *button = obj;
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    NSString *buttonName = button.titleLabel.text;
    NSString *text =  [buttonName substringWithRange: NSMakeRange(0, [buttonName rangeOfString: @"\n"].location)];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:buttonName];
    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:8] };
    NSRange range = [buttonName rangeOfString:text];
    [attributedString addAttributes:attributes range:range];
    
    button.titleLabel.text = @"S";
    //[button setAttributedTitle:attributedString forState:UIControlStateNormal];
    [button.viewForFirstBaselineLayout setNeedsDisplay];
  }];

  _dateTabController.delegate = self;
  [_dateTabController selectButtonWithIndex:diaDaSemana];
}

- (void)setupDayLabel:(int)dia {
  
  NSString *diaSemana;
  NSString *strData = [NSString stringWithFormat:@"%@", [[menuArray objectAtIndex:dia] date]];
  
  //set weekday
  switch ((int)dia) {
    case 0:
      diaSemana = @"Segunda-feira"; break;
    case 1:
      diaSemana = @"Terça-feira"; break;
    case 2:
      diaSemana = @"Quarta-feira"; break;
    case 3:
      diaSemana = @"Quinta-feira"; break;
    case 4:
      diaSemana = @"Sexta-feira"; break;
    case 5:
      diaSemana = @"Sábado"; break;
    case 6:
      diaSemana = @"Domingo"; break;
      
    default:
      break;
  }
  
  //set date
  NSString *strDay = [NSString stringWithFormat:@"%@", [strData substringToIndex:2]];
  NSString *strMonth = [self dayToString:[NSString stringWithFormat:@"%@", [[strData substringFromIndex:3]substringToIndex:2]]];
  NSString *strYear = [NSString stringWithFormat:@"%@", [strData substringFromIndex:6]];
  //set date label
  [diaDaSemanaLabel setText:[NSString stringWithFormat:@"%@, %@ de %@ de %@", diaSemana, strDay, strMonth, strYear]];
  
  [[self tableView] reloadData];
}

- (NSString *)dayToString: (NSString *)strMonth{
  switch ([strMonth intValue]) {
    case 1:
      return @"Janeiro"; break;
    case 2:
      return @"Fevereiro"; break;
    case 3:
      return @"Março"; break;
    case 4:
      return @"Abril"; break;
    case 5:
      return @"Maio"; break;
    case 6:
      return @"Junho"; break;
    case 7:
      return @"Julho"; break;
    case 8:
      return @"Agosto"; break;
    case 9:
      return @"Setembro"; break;
    case 10:
      return @"Outrubro"; break;
    case 11:
      return @"Novembro"; break;
    case 12:
      return @"Dezembro"; break;
      
    default:
      return @""; break;
  }
}

- (void)showInfo {
  [SVProgressHUD show];
  [self performSegueWithIdentifier:@"showInfo" sender:self];
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  if ([self isClosed]) {
    return [menu.period count];
  } else {
    return [menu.period count] + 1;
  }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 26;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 22)];

  //imagem
  UIImage *myImage = nil;
  UIImageView *imageView = nil;
  
  //texto
  UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(34, 0, tableView.frame.size.width, 22)];
  [label setFont:[UIFont systemFontOfSize:13]];
  [label setTextColor:[UIColor grayColor]];

  //posiciona imagem e texto
  switch (section) {
    case 0:
      [label setText:stringForLunch];
      myImage = [UIImage imageNamed:@"almoco"];
      imageView = [[UIImageView alloc] initWithImage:myImage];
      imageView.frame = CGRectMake(12, 2 , 18, 18);
      break;
    case 1:
      [label setText:@"JANTAR"];
      myImage = [UIImage imageNamed:@"jantar"];
      imageView = [[UIImageView alloc] initWithImage:myImage];
      imageView.frame = CGRectMake(12, 2 , 18, 18);
      break;
    case 2:
      [label setText:@"OBSERVAÇÃO"];
      [label setFrame:CGRectMake(12, 0 , tableView.frame.size.width, 22)];
      break;
      
    default:
      break;
  }
  [imageView setTintColor:[UIColor grayColor]];
  [view addSubview:imageView];
  [view addSubview:label];

  return view;
}



- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
  if (menu) {
    switch (section) {
      case 0:
        if (([[[[menu period] objectAtIndex:0] calories] isEqualToString:@""]) || ([[[[menu period] objectAtIndex:0] calories] isEqualToString:@"0"])) {
          return @"";
        } else {
          return [NSString stringWithFormat:@"Valor calórico para uma refeição: %@ kcal", [[[menu period] objectAtIndex:0] calories]];
        }
        break;
      case 1:
        if (([[[[menu period] objectAtIndex:1] calories] isEqualToString:@""]) || ([[[[menu period] objectAtIndex:1] calories] isEqualToString:@"0"])) {
          return @"";
        } else {
          return [NSString stringWithFormat:@"Valor calórico para uma refeição: %@ kcal", [[[menu period] objectAtIndex:1] calories]];
        }
        break;
        
      default:
        break;
    }
  } else {
    return @"";
  }
  return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell" forIndexPath:indexPath];
  
  self.tableView.estimatedRowHeight = 150.;

  if (menu) {
    NSString *menuString = @"";
    switch ([indexPath section]) {
      case 0:
        menuString = [NSString stringWithFormat:@"%@", [[[menu period] objectAtIndex:0] menu]];
        if ([menuString isEqualToString:@""]) {
          cell.textLabel.text = @"Fechado";
        } else {
          cell.textLabel.text = menuString;
        }
        break;
      case 1:
        menuString = [NSString stringWithFormat:@"%@", [[[menu period] objectAtIndex:1] menu]];
        if ([menuString isEqualToString:@""]) {
          cell.textLabel.text = @"Fechado";
        } else {
          cell.textLabel.text = menuString;
        }
        break;
      case 2:
        [cell.textLabel setText:[NSString stringWithFormat:@"%@", dataModel.observation]];
        [cell.textLabel setTextColor:[UIColor grayColor]];
        [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
        [cell setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
        break;
        
      default:
        break;
    }
  }
  return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  switch ([indexPath section]) {
    case 2:
      if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        return UITableViewAutomaticDimension;
      } else {
        return 66.;
      }
      break;
  
    default:
      if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        return UITableViewAutomaticDimension;
      } else {
        return 140.;
      }
      break;
  }
}

#pragma mark - Button

- (IBAction)showRestaurantSelector:(id)sender {

}

- (IBAction)showCredits:(id)sender {
  creditsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"creditsViewController"];
  

  if (![oauth isLoggedIn]) {
    loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginWebViewController"];
    [self presentViewController:loginViewController animated:YES completion:nil];
  } else {
    [dataModel getCreditoRUCard];
    //[self presentViewController:creditsViewController animated:YES completion:nil];
    CreditsNavigationViewController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"navController"];
    [self presentViewController:navController animated:YES completion:nil];
  }
}

#pragma mark - TabControllerDelegate

- (void)ScrollingTabController:(DKScrollingTabController *)controller selection:(NSUInteger)selection {
  menu = [menuArray objectAtIndex:selection];
  [self setupDayLabel:(int)selection];
}

#pragma mark - Model

- (void)didChangeRestaurant:(NSNotification *)notification {
  [dataModel getMenu];
  [self.navigationItem setTitle: [[dataModel currentRestaurant]valueForKey:@"name"]];
}

- (void)didReceiveMenu:(NSNotification *)notification {

  menuArray = [dataModel menuArray];

  if ([menuArray count] > 0) {
    [self setupWeekView:menuArray];
    [self setupDayLabel:diaDaSemana];

    menu = [menuArray objectAtIndex:diaDaSemana];

    [self viewDidAppear:YES];
    [self.tableView reloadData];
  } else {
    [SVProgressHUD showInfoWithStatus:@"Não foi possível obter o cardápio. \nTente novamente mais tarde."];
  }
  stringForLunch = [NSMutableString stringWithFormat:@"ALMOÇO"];

}

- (void)didRecieveUserData:(NSNotification *)notification {
  [self presentViewController:creditsViewController animated:YES completion:nil];
}

- (void)didReceiveBill:(NSNotification *)notification {
  boletoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"boletoViewController"];
  [self presentViewController:boletoViewController animated:YES completion:nil];
}


- (BOOL)isClosed {
  NSString *strLunch = [[[[NSString stringWithFormat:@"%@", [[[menu period] objectAtIndex:0] menu]] capitalizedString] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""];

  NSString *strDinner = [[[[NSString stringWithFormat:@"%@", [[[menu period] objectAtIndex:1] menu]] capitalizedString] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""];

  
  if ([strLunch isEqualToString:@"Fechado"] || [strLunch isEqualToString:@""]) {
    if ([strDinner isEqualToString:@"Fechado"] || [strDinner isEqualToString:@""]) {
      return YES;
    }
  }
  return NO;
}

#pragma mark - SWRevealViewControllerDelegate
// The following delegate methods will be called before and after the front view moves to a position
- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position {
  if (position == 2) {
    
    //esconde info
    [_infoButton setHidden:YES];

    //desabilita swipe na tela
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
      self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
  }
  else {
    //mostra info
    [_infoButton setHidden:NO];
    
    //habilita swipe na tela
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
      self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
  }
}

@end
