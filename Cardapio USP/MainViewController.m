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
  UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showRestaurantSelector:)];
  [swipe setDirection:UISwipeGestureRecognizerDirectionRight];
  [[self view] addGestureRecognizer: swipe];
  
    diaDaSemana = 0;
    
    menuArray = [[MenuDataModel getInstance] menus];
    menu = [menuArray objectAtIndex:diaDaSemana];

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
    
    NSLog(@"Footer::: %@", [[menu period]objectAtIndex:section]);
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


@end
