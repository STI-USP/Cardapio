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

@interface MainViewController () {
    NSMutableArray *menuArray;
    Menu *menu;
    Period *period;
    int diaDaSemana;
}

@end

@implementation MainViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // Gesture recognizer
    UISwipeGestureRecognizer *swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showRestaurantSelector:)];
    [swipeRight setDirection:UISwipeGestureRecognizerDirectionRight];
    [[self view] addGestureRecognizer: swipeRight];
    
    UISwipeGestureRecognizer *swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(back:)];
    [swipeLeft setDirection:UISwipeGestureRecognizerDirectionLeft];
    [[self view] addGestureRecognizer: swipeLeft];
    
    diaDaSemana = 0;
    
    menuArray = [[MenuDataModel getInstance] menus];
    menu = [menuArray objectAtIndex:diaDaSemana];

    
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
    
    NSString *mondayButtonName = [NSString stringWithFormat:@"S\n21"];
    NSString *tuesdayButtonName = [NSString stringWithFormat:@"T\n22"];
    NSString *wednesdayButtonName = [NSString stringWithFormat:@"Q\n23"];
    NSString *thursdayButtonName = [NSString stringWithFormat:@"Q\n24"];
    NSString *fridayButtonName = [NSString stringWithFormat:@"S\n25"];
    NSString *saturdayButtonName = [NSString stringWithFormat:@"S\n26"];
    NSString *sundayButtonName = [NSString stringWithFormat:@"D\n27"];
    
    [dateTabController setButtonName:mondayButtonName atIndex:0];
    [dateTabController setButtonName:tuesdayButtonName atIndex:1];
    [dateTabController setButtonName:wednesdayButtonName atIndex:2];
    [dateTabController setButtonName:thursdayButtonName atIndex:3];
    [dateTabController setButtonName:fridayButtonName atIndex:4];
    [dateTabController setButtonName:saturdayButtonName atIndex:5];
    [dateTabController setButtonName:sundayButtonName atIndex:6];
    
    
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

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
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
    
    NSLog(@"Footer::: %@", [[[menu period] objectAtIndex:1] valueForKey:@"calories"]);
    return [NSString stringWithFormat:@"Valor calórico para uma refeição: %@",
            [[[menu period] objectAtIndex:section] valueForKey:@"calories"]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellID = @"MenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
    
    //configure cell
    cell.textLabel.text = [[[menu period] objectAtIndex:indexPath.section] valueForKey:@"menu"];
    
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 130.0;
}

#pragma mark - Button

- (void)showRestaurantSelector:(id)sender {
  [self.frostedViewController presentMenuViewController];
}

- (void)back:(id)sender {
    menu = [menuArray objectAtIndex:++diaDaSemana];
    [[self tableView] reloadData];
}

#pragma mark - TabControllerDelegate

- (void)DKScrollingTabController:(DKScrollingTabController *)controller selection:(NSUInteger)selection {
    NSLog(@"Selection controller action button with index=%lu",(unsigned long)selection);
    menu = [menuArray objectAtIndex:selection];
    [[self tableView] reloadData];
}



@end
