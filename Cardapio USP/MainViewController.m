//
//  MainViewController.m
//  Cardapio USP
//
//  Created by Jun Okamoto Jr. on 19/05/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import "MainViewController.h"
#import "REFrostedViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  // Gesture recognizer
  UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(showRestaurantSelector:)];
  [swipe setDirection:UISwipeGestureRecognizerDirectionRight];
  [[self view] addGestureRecognizer: swipe];
  
  // [jo:140523] Teste JSON
  NSError *error = nil;
  NSData *data = [NSData dataWithContentsOfFile: [[NSBundle mainBundle] pathForResource:@"central" ofType:@"json"]];
  NSMutableArray *array = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
  if (error)
    NSLog(@"JSONObjectWithData error: %@", error);
  
  for (NSMutableDictionary *dictionary in array) {
    NSLog(@"%@", dictionary);
  }
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
  if (section == 0) {
    return @"Valor calórico para uma refeição: 1195 kcal";
  } else {
    return @"Valor calórico para uma refeição: 1005 kcal";
  }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *cellID = @"MenuCell";
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID forIndexPath:indexPath];
  if (indexPath.section == 0) {
    cell.textLabel.text = @"Arroz/feijão preto/arroz integral\nCopa lombo com molho de abacaxi\nVirado de milho\nSalada de alcelga\nOpcional: PVT à califórnia\nMexerica/refresco";
  } else {
    cell.textLabel.text = @"Arroz/feijão preto/arroz integral\nFrango Assado\nCenoura com ervilha\nSalada de almeirão\nOpcional: Quibe de PVT\nGoiabinha/refresco";
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


@end
