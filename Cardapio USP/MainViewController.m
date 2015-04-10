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

@interface MainViewController () {
  
  RestaurantDataModel *restaurantDataModel;
  MenuDataModel *menuDataModel;
  
  NSMutableArray *menuArray;
  Menu *menu;
  Period *period;
  int diaDaSemana;
}

@end

@implementation MainViewController

@synthesize diaDaSemanaLabel;

-(id)initWithCoder:(NSCoder *)aDecoder {
  // precisa inicializar o modelo logo no início pois a busca com o scanner é feita antes de carregar a vista
  self = [super initWithCoder:aDecoder];
  if (self) {
    restaurantDataModel = [RestaurantDataModel getInstance]; // modelo singleton
    menuDataModel = [MenuDataModel getInstance];
  }
  return self;
}   

- (void)viewDidLoad {
  [super viewDidLoad];

  // Gesture recognizer
  UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showRestaurantSelector:)];
  [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
  [[self view] addGestureRecognizer: swipeRight];
  
  //UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self
  //                                                                                action:@selector(forwardDate:)];
  //[swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
  //[[self view] addGestureRecognizer: swipeLeft];
  
  diaDaSemana = 0;
  
  NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
  NSDateComponents *weekdayComponents =[gregorian components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
  NSInteger weekday = [weekdayComponents weekday];
  
  menuArray = menuDataModel.menus;
  menu = [menuArray objectAtIndex:weekday];
  
  [self setupWeekView: menuArray];
  [self setupDayLabel:diaDaSemana];
  
  /*
   // [jo:140523] Teste JSON
   NSError *error = nil;
   NSData *data = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"central" ofType:@"json"]];
   NSMutableArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
   if (error)
   NSLog(@"JSONObjectWithData error: %@", error);
   
   for (NSMutableDictionary *dictionary in array) {
   NSLog(@"%@", dictionary);
   }
   */
  
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)setupWeekView: (NSArray *) weekMenu {
  DKScrollingTabController *dateTabController = [[DKScrollingTabController alloc] init];
  
  dateTabController.delegate = self;
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
  NSString *sunButtonName = [[NSString stringWithFormat:@"D\n%@", [[menuArray objectAtIndex:6] date]] substringToIndex:4];
  
  [dateTabController setButtonName:monButtonName atIndex:0];
  [dateTabController setButtonName:tueButtonName atIndex:1];
  [dateTabController setButtonName:wedButtonName atIndex:2];
  [dateTabController setButtonName:thuButtonName atIndex:3];
  [dateTabController setButtonName:friButtonName atIndex:4];
  [dateTabController setButtonName:satButtonName atIndex:5];
  [dateTabController setButtonName:sunButtonName atIndex:6];
  
  
  [dateTabController.buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    UIButton *button = obj;
    button.titleLabel.numberOfLines = 2;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    NSString *buttonName = button.titleLabel.text;
    NSString *text =  [buttonName substringWithRange: NSMakeRange(0, [buttonName rangeOfString: @"\n"].location)];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:buttonName];
    NSDictionary *attributes = @{ NSFontAttributeName : [UIFont systemFontOfSize:6] };
    NSRange range = [buttonName rangeOfString:text];
    [attributedString addAttributes:attributes range:range];
    
    button.titleLabel.text = @"";
    [button setAttributedTitle:attributedString forState:UIControlStateNormal];
  }];
  
}

- (void)setupDayLabel:(int)dia {
  
  NSString *diaSemana;
  NSString *strData = [NSString stringWithFormat:@"%@", [[menuArray objectAtIndex:dia] date]];
  
  //set weekday
  switch ((int)dia) {
    case 0:
      diaSemana = @"Segunda-feira";
      break;
    case 1:
      diaSemana = @"Terça-feira";
      break;
    case 2:
      diaSemana = @"Quarta-feira";
      break;
    case 3:
      diaSemana = @"Quinta-feira";
      break;
    case 4:
      diaSemana = @"Sexta-feira";
      break;
    case 5:
      diaSemana = @"Sábado";
      break;
    case 6:
      diaSemana = @"Domingo";
      break;
      
    default:
      break;
  }
  
  
  //set day
  NSString *strDay = [NSString stringWithFormat:@"%@", [strData substringToIndex:2]];
  
  //set month
  NSString *strMonth = [self dayToString:[NSString stringWithFormat:@"%@", [[strData substringFromIndex:3]substringToIndex:2]]];
  
  //set year
  NSString *strYear = [NSString stringWithFormat:@"%@", [strData substringFromIndex:6]];
  
  //set label
  [diaDaSemanaLabel setText:[NSString stringWithFormat:@"%@, %@ de %@ de %@", diaSemana, strDay, strMonth, strYear]];
  
  [[self tableView] reloadData];
  
}

- (NSString *)dayToString: (NSString *)strMonth{
  switch ([strMonth intValue]) {
    case 1:
      return @"Janeiro";
      break;
    case 2:
      return @"Fevereiro";
      break;
    case 3:
      return @"Março";
      break;
    case 4:
      return @"Abril";
      break;
    case 5:
      return @"Maio";
      break;
    case 6:
      return @"Junho";
      break;
    case 7:
      return @"Julho";
      break;
    case 8:
      return @"Agosto";
      break;
    case 9:
      return @"Setembro";
      break;
    case 10:
      return @"Outrubro";
      break;
    case 11:
      return @"Novembro";
      break;
    case 12:
      return @"Dezembro";
      break;
      
    default:
      return @"";
      break;
  }
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [menu.period count];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  switch (section) {
    case 0:
      return @"Almoço";
      break;
    case 1:
      return @"Jantar";
      break;
      
    default:
      break;
  }
  return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
  switch (section) {
    case 0:
      return [NSString stringWithFormat:@"Valor calórico para uma refeição: %@", [[[menu period] objectAtIndex:0] calories]];
      break;
    case 1:
      return [NSString stringWithFormat:@"Valor calórico para uma refeição: %@", [[[menu period] objectAtIndex:1] calories]];
      break;
      
    default:
      break;
  }
  return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellID = @"MenuCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
  
  if (indexPath.section == 0) {
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [[[menu period] objectAtIndex:0] menu]]; //almoço
  } else {
    cell.textLabel.text = [NSString stringWithFormat:@"%@", [[[menu period] objectAtIndex:1] menu]]; //janta
  }
  return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 130.0;
}

#pragma mark - Button

- (void)showRestaurantSelector:(id)sender {
  [self.frostedViewController presentMenuViewController];
}

- (void)forwardDate:(id)sender {
  menu = [menuArray objectAtIndex:++diaDaSemana];
  [[self tableView] reloadData];
}

#pragma mark - TabControllerDelegate

- (void)DKScrollingTabController:(DKScrollingTabController *)controller selection:(NSUInteger)selection {
  menu = [menuArray objectAtIndex:selection];
  [self setupDayLabel:(int)selection];
}



@end
