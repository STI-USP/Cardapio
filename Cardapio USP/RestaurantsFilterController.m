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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
  [self setTitle:@"Restaurantes"];
  //restaurantDataModel = [RestaurantDataModel getInstance];
  //menuDataModel = [MenuDataModel getInstance];
  dataModel = [DataModel getInstance];
  
  if (!campiList) {
    campiList = [[NSMutableArray alloc] init];
    for (id campus in [dataModel getRestaurants]){
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
  //oldCampusOption = [restaurantDataModel campusOption]; // pega o filtro de campus que está setado no modelo
  //oldRestaurantOption = [restaurantDataModel restaurantOption]; // pega o filtro de restaurante que está setado no modelo
  NSIndexPath *oldFilterOptionIndexPath = [NSIndexPath indexPathForRow:[dataModel restaurantOption] inSection:[dataModel campusOption]];
  [[self.tableView cellForRowAtIndexPath:oldFilterOptionIndexPath] setAccessoryType: UITableViewCellAccessoryCheckmark];
}


#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  return [[campiList objectAtIndex:section]valueForKey:@"name"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  //NSString *selectedRestaurant = [[[restaurantDict valueForKey:[restaurantList objectAtIndex:indexPath.section]] objectAtIndex:indexPath.row]valueForKey:@"name"];
  
  NSIndexPath *oldFilterOptionIndexPath = [NSIndexPath indexPathForRow:oldRestaurantOption inSection:oldCampusOption];
  //if ((oldFilterOptionIndexPath.row != indexPath.row) || (oldFilterOptionIndexPath.section != indexPath.section)) {
    dataModel.restaurantOption = indexPath.row; // salva como nova opção
    dataModel.campusOption = indexPath.section;
    oldCampusOption = indexPath.section; // salva como opção anterior
    oldRestaurantOption = indexPath.row; // salva como opção anterior
    [tableView cellForRowAtIndexPath:oldFilterOptionIndexPath].accessoryType = UITableViewCellAccessoryNone;
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark;
  

  [dataModel setCampus:[campiList objectAtIndex:indexPath.section]];
  [dataModel setRestaurantId:[[[[campiList objectAtIndex:indexPath.section] valueForKey:@"restaurants"]objectAtIndex:indexPath.row] valueForKey:@"id"]];
  
  NSString *name = [[[[campiList objectAtIndex:indexPath.section] valueForKey:@"restaurants"]objectAtIndex:indexPath.row] valueForKey:@"name"];
  name = [name stringByReplacingOccurrencesOfString:@"Restaurante da " withString:@""];
  name = [name stringByReplacingOccurrencesOfString:@"Restaurante " withString:@""];
  [dataModel setRestaurantName:name];

  [[NSNotificationCenter defaultCenter] postNotificationName:@"DidChangeRestaurant" object:self];

  
  //}
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [campiList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[[campiList objectAtIndex:section] valueForKey:@"restaurants"] count];
  
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FilterCell" forIndexPath:indexPath];
  
  NSString *name = [[[[campiList objectAtIndex:indexPath.section] valueForKey:@"restaurants"]objectAtIndex:indexPath.row] valueForKey:@"name"];
  name = [name stringByReplacingOccurrencesOfString:@"Restaurante da " withString:@""];
  name = [name stringByReplacingOccurrencesOfString:@"Restaurante " withString:@""];
  cell.textLabel.text = name;
  
  return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
