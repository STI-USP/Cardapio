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

@interface RestaurantsFilterController () {
  NSMutableArray *restaurantList;
  NSMutableArray *campiList;
  NSMutableDictionary *restaurantDict;
  RestaurantDataModel *_restaurantDataModel;
  MenuDataModel *_menuDataModel;
  DataModel *dataModel;
  NSInteger oldCampusOption;
  NSInteger oldRestaurantOption;
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL) animated {

  // Filter Option
  NSIndexPath *oldFilterOptionIndexPath = [NSIndexPath indexPathForRow:[dataModel restaurantOption] inSection:[dataModel campusOption]];
  [[self.tableView cellForRowAtIndexPath:oldFilterOptionIndexPath] setAccessoryType: UITableViewCellAccessoryCheckmark];
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

  cell.textLabel.font = [UIFont systemFontOfSize:14.0];
  cell.textLabel.text = [[[[campiList objectAtIndex:indexPath.section] valueForKey:@"restaurants"]objectAtIndex:indexPath.row] valueForKey:@"name"];
 
  UIButton *favButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  favButton.frame = CGRectMake(240.0f, 5.0f, 25.0f, 30.0f);
  [favButton setImage:[UIImage imageNamed:@"fav.png"] forState:UIControlStateNormal];
  [favButton setTintColor:[UIColor colorWithWhite:0.7 alpha:0.5]];
  [favButton addTarget:self action:@selector(favoriteRestaurant:) forControlEvents:UIControlEventTouchUpInside];
  cell.accessoryView = favButton;

  return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  [dataModel setCampus:[campiList objectAtIndex:indexPath.section]];
  [dataModel setCurrentRestaurant:[[[campiList objectAtIndex:indexPath.section] valueForKey:@"restaurants"]objectAtIndex:indexPath.row]];

  [[NSNotificationCenter defaultCenter] postNotificationName:@"DidChangeRestaurant" object:self];
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
  NSLog(@"favoritar %@", [[[[campiList objectAtIndex:indexPath.section] valueForKey:@"restaurants"]objectAtIndex:indexPath.row]valueForKey:@"name"]);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)favoriteRestaurant:(id)sender {

  NSLog(@"favoritar");
  /*
  NSIndexPath *oldFilterOptionIndexPath = [NSIndexPath indexPathForRow:oldRestaurantOption inSection:oldCampusOption];
  dataModel.restaurantOption = indexPath.row; // salva como nova opção
  dataModel.campusOption = indexPath.section;
  oldCampusOption = indexPath.section; // salva como opção anterior
  oldRestaurantOption = indexPath.row; // salva como opção anterior
  [tableView cellForRowAtIndexPath:oldFilterOptionIndexPath].accessoryType = UITableViewCellAccessoryNone;
  [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
   */
}

@end
