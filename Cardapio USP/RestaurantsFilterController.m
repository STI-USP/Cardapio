//
//  RestaurantsFilterController.m
//  Cardapio USP
//
//  Created by Vagner Machado on 4/10/15.
//  Copyright (c) 2015 EPUSP. All rights reserved.
//

#import "RestaurantsFilterController.h"
#import "RestaurantDataModel.h"
#import "MenuDataModel.h"
#import "DataModel.h"
#import "REFrostedViewController.h"


@interface RestaurantsFilterController () {
  NSMutableArray *restaurantList;
  NSMutableArray *campiList;
  NSMutableDictionary *restaurantDict;
  NSMutableDictionary *prefRestaurant;
  DataModel *dataModel;
  NSInteger oldCampusOption;
  NSInteger oldRestaurantOption;
  NSUserDefaults *defaults;
  NSIndexPath *indexPathForFavoriteRestaurant;
}

@end


@implementation RestaurantsFilterController

- (void)viewDidLoad {
    [super viewDidLoad];
    
  [self setTitle:@"Restaurantes"];

  
  dataModel = [DataModel getInstance];
  
  if (!campiList) {
    campiList = [[NSMutableArray alloc] init];
    for (id campus in [dataModel restaurants]){
      [dataModel setRestaurantName:[campus objectForKey:@"name"]];
      [campiList addObject:campus];
    }
  }
  
  if (!restaurantDict) {
    restaurantDict  = [[NSMutableDictionary alloc] init];
    
    for (int i=0; i<[campiList count]; i++) {
      restaurantList = [[campiList objectAtIndex:i]valueForKey:@"restaurants"];
      [restaurantDict setValue:restaurantList forKey:[[campiList objectAtIndex:i] objectForKey:@"name"]];
    }
  }
  
  defaults = [NSUserDefaults standardUserDefaults];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL) animated {

  // Filter Option
  NSIndexPath *oldFilterOptionIndexPath = [NSIndexPath indexPathForRow:[dataModel restaurantOption] inSection:[dataModel campusOption]];
  [[self.tableView cellForRowAtIndexPath:oldFilterOptionIndexPath] setAccessoryType: UITableViewCellAccessoryCheckmark];
  
  [self.tableView reloadData];  
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return [campiList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[[campiList objectAtIndex:section] valueForKey:@"restaurants"] count];
  
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return [[campiList objectAtIndex:section]valueForKey:@"name"];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FilterCell" forIndexPath:indexPath];

  NSString *name = [[[[campiList objectAtIndex:indexPath.section] valueForKey:@"restaurants"]objectAtIndex:indexPath.row] valueForKey:@"name"];
  cell.textLabel.font = [UIFont systemFontOfSize:14.0];
  cell.textLabel.text = name;
 
  UIButton *favButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  favButton.frame = CGRectMake(240.0f, 5.0f, 25.0f, 30.0f);
  [favButton setImage:[UIImage imageNamed:@"fav.png"] forState:UIControlStateNormal];
  
  prefRestaurant = [NSMutableDictionary dictionaryWithDictionary:[defaults dictionaryForKey:@"preferredRestaurant"]];

  if ([[prefRestaurant valueForKey:@"name"] isEqualToString:[[[[campiList objectAtIndex:indexPath.section] valueForKey:@"restaurants"]objectAtIndex:indexPath.row] valueForKey:@"name"]]) {
    [favButton setTintColor:[UIColor orangeColor]];
  } else {
    [favButton setTintColor:[UIColor colorWithWhite:0.7 alpha:0.5]];
  }
  
  [favButton addTarget:self action:@selector(favoriteRestaurant:) forControlEvents:UIControlEventTouchUpInside];
  cell.accessoryView = favButton;

  return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  [dataModel setCampus:[campiList objectAtIndex:indexPath.section]];
  [dataModel setCurrentRestaurant:[[[campiList objectAtIndex:indexPath.section] valueForKey:@"restaurants"]objectAtIndex:indexPath.row]];

  [[NSNotificationCenter defaultCenter] postNotificationName:@"DidChangeRestaurant" object:self];
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
  
  [self.frostedViewController hideMenuViewController];
}


- (void)favoriteRestaurant:(id)sender {

  UITableViewCell *cell = (UITableViewCell *)[sender superview];
  NSIndexPath *indexPath = [self.tableView indexPathForCell:cell];

  prefRestaurant = [[[campiList objectAtIndex:[indexPath section]] valueForKey:@"restaurants"] objectAtIndex:[indexPath row]];
  
  [dataModel setPreferredRestaurant: prefRestaurant];
  
  [self.tableView reloadData];
  //[self.tableView reloadInputViews];
}

@end
