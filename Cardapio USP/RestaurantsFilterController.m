//
//  RestaurantsFilterController.m
//  Cardapio USP
//
//  Created by Vagner Machado on 4/10/15.
//  Copyright (c) 2015 EPUSP. All rights reserved.
//

#import "RestaurantsFilterController.h"
#import "RestaurantDataModel.h"

@interface RestaurantsFilterController () {
  NSMutableArray *campiList;
  NSMutableDictionary *restaurantDict;
  RestaurantDataModel *restaurantDataModel;
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void) viewWillAppear:(BOOL) animated {
  // Filter Option
  oldCampusOption = restaurantDataModel.restaurantOption; // pega o filtro de campus que está setado no modelo
  oldRestaurantOption = restaurantDataModel.restaurantOption; // pega o filtro de restaurante que está setado no modelo
  NSIndexPath *oldFilterOptionIndexPath = [NSIndexPath indexPathForRow:oldRestaurantOption inSection:oldCampusOption] ; // cria indexPath para opção de filtro que está  armazenada no modelo
  [self.tableView cellForRowAtIndexPath:oldFilterOptionIndexPath].accessoryType = UITableViewCellAccessoryCheckmark; // marca com check na tabela
}


#pragma mark - Table view data source

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return @"CUASO";
  }
  return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  
  NSString *selectedRestaurant = [[restaurantDict valueForKey:[campiList objectAtIndex:indexPath.section]]objectAtIndex:indexPath.row];
  
  NSIndexPath *oldFilterOptionIndexPath = [NSIndexPath indexPathForRow:oldRestaurantOption inSection:oldCampusOption];
  if ((oldFilterOptionIndexPath.row != indexPath.row) || (oldFilterOptionIndexPath.section != indexPath.section)) { // só muda se não tiver tocado na mesma
    restaurantDataModel.restaurantOption = indexPath.row; // salva como nova opção
    oldCampusOption = indexPath.section; // salva como opção anterior
    oldRestaurantOption = indexPath.row; // salva como opção anterior
    [tableView cellForRowAtIndexPath:indexPath].accessoryType = UITableViewCellAccessoryCheckmark; // marca a nova
    [tableView cellForRowAtIndexPath:oldFilterOptionIndexPath].accessoryType = UITableViewCellAccessoryNone; //tira a marca da anterior
    [[RestaurantDataModel getInstance] setRestaurant:selectedRestaurant];
    [[RestaurantDataModel getInstance] setCampusOption:indexPath.section];
    [[RestaurantDataModel getInstance] setRestaurantOption:indexPath.row];
    
    NSLog(@"%@", selectedRestaurant);
  }
  [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 0;
}
*/

/*
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:<#@"reuseIdentifier"#> forIndexPath:indexPath];
    
    // Configure the cell...
    
    return cell;
}
*/

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
