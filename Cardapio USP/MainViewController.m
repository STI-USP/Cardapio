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
#import "MainViewController.h"
#import "REFrostedViewController.h"
#import "DKScrollingTabController.h"
#import "RestaurantDataModel.h"  
#import "DataModel.h"

@interface MainViewController () {

  DKScrollingTabController *dateTabController;

  RestaurantDataModel *_restaurantDataModel;
  MenuDataModel *_menuDataModel;
  DataModel *dataModel;
  
  NSMutableArray *menuArray;
  Menu *menu;
  Period *period;
  int diaDaSemana;
}

@end

@implementation MainViewController

@synthesize diaDaSemanaLabel;

- (void)viewDidLoad {
  [super viewDidLoad];

  // Gesture recognizer
  UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showRestaurantSelector:)];
  [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
  [[self view] addGestureRecognizer: swipeRight];
  
  
  NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  [gregorian setFirstWeekday:2];
  NSDateComponents *weekdayComponents =[gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
  NSInteger weekday = [weekdayComponents weekday] - 2; //para deixar a segunda feira como 0
  
  if ((int)weekday == -1) {
    diaDaSemana = 6;
  } else {
    diaDaSemana = (int)weekday;
  }
  
  dataModel = [DataModel getInstance];
  
  dateTabController = [[DKScrollingTabController alloc] init];
  dateTabController.delegate = self;
  
  if ([dataModel preferredRestaurant]) {
    [dataModel setCurrentRestaurant:[dataModel preferredRestaurant]];
  }
  
  [dataModel getMenu];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeRestaurant:) name:@"DidChangeRestaurant" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMenu:) name:@"DidReceiveMenu" object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
  NSString *name;
  name = [[dataModel currentRestaurant]valueForKey:@"name"];
  [self.navigationItem setTitle: name];
  
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)setupWeekView: (NSArray *) weekMenu {
  
  [self addChildViewController:dateTabController];
  [dateTabController didMoveToParentViewController:self];
  [self.view addSubview:dateTabController.view];
  dateTabController.view.frame = CGRectMake(0, 65, 320, 40);
  dateTabController.view.backgroundColor = [UIColor lightTextColor];
  dateTabController.buttonPadding = 3.2;
  dateTabController.underlineIndicator = YES;
  dateTabController.underlineIndicatorColor = [UIColor redColor];
  dateTabController.buttonsScrollView.showsHorizontalScrollIndicator = NO;
  dateTabController.selectedBackgroundColor = [UIColor clearColor];
  dateTabController.selectedTextColor = [UIColor blackColor];
  dateTabController.unselectedTextColor = [UIColor grayColor];
  dateTabController.unselectedBackgroundColor = [UIColor clearColor];
  dateTabController.selection = @[@"PLACE\n0", @"PLACE\n0", @"PLACE\n0", @"PLACE\n0", @"PLACE\n0", @"PLACE\n0", @"PLACE\n0" ];
  

  NSString *monButtonName = [[NSString stringWithFormat:@"S\n%@", [[menuArray objectAtIndex:0] date]]substringToIndex:4];
  NSString *tueButtonName = [[NSString stringWithFormat:@"T\n%@", [[menuArray objectAtIndex:1] date]]substringToIndex:4];
  NSString *wedButtonName = [[NSString stringWithFormat:@"Q\n%@", [[menuArray objectAtIndex:2] date]]substringToIndex:4];
  NSString *thuButtonName = [[NSString stringWithFormat:@"Q\n%@", [[menuArray objectAtIndex:3] date]]substringToIndex:4];
  NSString *friButtonName = [[NSString stringWithFormat:@"S\n%@", [[menuArray objectAtIndex:4] date]]substringToIndex:4];
  NSString *satButtonName = [[NSString stringWithFormat:@"S\n%@", [[menuArray objectAtIndex:5] date]]substringToIndex:4];
  NSString *sunButtonName = [[NSString stringWithFormat:@"D\n%@", [[menuArray objectAtIndex:6] date]]substringToIndex:4];

  [dateTabController setButtonName:monButtonName atIndex:0];
  [dateTabController setButtonName:tueButtonName atIndex:1];
  [dateTabController setButtonName:wedButtonName atIndex:2];
  [dateTabController setButtonName:thuButtonName atIndex:3];
  [dateTabController setButtonName:friButtonName atIndex:4];
  [dateTabController setButtonName:satButtonName atIndex:5];
  [dateTabController setButtonName:sunButtonName atIndex:6];
  
  [dateTabController.buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    UIButton *button = obj;
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    NSString *buttonName = button.titleLabel.text;
    NSString *text =  [buttonName substringWithRange: NSMakeRange(0, [buttonName rangeOfString: @"\n"].location)];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:buttonName];
    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:8] };
    NSRange range = [buttonName rangeOfString:text];
    [attributedString addAttributes:attributes range:range];
    
    button.titleLabel.text = @"";
    [button setAttributedTitle:attributedString forState:UIControlStateNormal];
  }];

  [dateTabController selectButtonWithIndex:diaDaSemana];
  
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


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [menu.period count] + 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  switch (section) {
    case 0:
      return @"Almoço"; break;
    case 1:
      return @"Jantar"; break;
    case 2:
      return @"Observação"; break;
      
    default:
      break;
  }
  return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
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
  return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellID = @"MenuCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
  
  switch ([indexPath section]) {
    case 0:
      cell.textLabel.text = [NSString stringWithFormat:@"%@", [[[menu period] objectAtIndex:0] menu]]; //almoço
      break;
    case 1:
      cell.textLabel.text = [NSString stringWithFormat:@"%@", [[[menu period] objectAtIndex:1] menu]]; //jantar
      break;
    case 2:
      [cell.textLabel setText:[NSString stringWithFormat:@"%@", dataModel.observation]];
      [cell.textLabel setTextColor:[UIColor grayColor]];
      [cell setBackgroundColor:[UIColor groupTableViewBackgroundColor]];
      break;
      
    default:
      break;
  }

  return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  switch ([indexPath section]) {
    case 2:
      return 66;
      break;
  
    default:
      return 130.0;
      break;
  }
}

#pragma mark - Button

- (void)showRestaurantSelector:(id)sender {
  [self.frostedViewController presentMenuViewController];
}

#pragma mark - TabControllerDelegate

- (void)DKScrollingTabController:(DKScrollingTabController *)controller selection:(NSUInteger)selection {
  menu = [menuArray objectAtIndex:selection];
  [self setupDayLabel:(int)selection];
}

#pragma mark - Model

-(void) didChangeRestaurant:(NSNotification *)notification {
  [dataModel getMenu];
  [self.navigationItem setTitle: [[dataModel currentRestaurant]valueForKey:@"name"]];
}

-(void) didReceiveMenu:(NSNotification *)notification {

  menuArray = [dataModel menuArray];
  menu = [menuArray objectAtIndex:diaDaSemana];
  
  [self setupWeekView: menuArray];
  [self setupDayLabel:diaDaSemana];
  
  [self reloadInputViews];
  [self.tableView reloadData];
}


@end
