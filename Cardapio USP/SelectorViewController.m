//
//  SelectorViewController.m
//  Cardapio USP
//
//  Created by Jun Okamoto Jr. on 19/05/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import "SelectorViewController.h"
#import "MainViewController.h"

@interface SelectorViewController () {
  NSMutableArray *restaurantList;
  NSMutableDictionary *sectionContentDict;
  NSMutableArray      *arrayForBool;

}

@end

@implementation SelectorViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad{
  [super viewDidLoad];
  
    if (!restaurantList) {
        restaurantList = [NSMutableArray arrayWithObjects:@"CUASO", @"EACH", @"SÃO FRANCISCO", @"SAÚDE", @"LORENA", nil];
    }
    if (!arrayForBool) {
        arrayForBool    = [NSMutableArray arrayWithObjects:[NSNumber numberWithBool:NO],
                           [NSNumber numberWithBool:NO],
                           [NSNumber numberWithBool:NO],
                           [NSNumber numberWithBool:NO],
                           [NSNumber numberWithBool:NO] , nil];
    }
    if (!sectionContentDict) {
        sectionContentDict  = [[NSMutableDictionary alloc] init];
        NSArray *array1     = [NSArray arrayWithObjects:@"Central", @"Física", @"Químicas", @"PUSP-C", nil];
        [sectionContentDict setValue:array1 forKey:[restaurantList objectAtIndex:0]];
        NSArray *array2     = [NSArray arrayWithObjects:@" ", nil];
        [sectionContentDict setValue:array2 forKey:[restaurantList objectAtIndex:1]];
        NSArray *array3     = [NSArray arrayWithObjects:@" ", nil];
        [sectionContentDict setValue:array3 forKey:[restaurantList objectAtIndex:2]];
        NSArray *array4     = [NSArray arrayWithObjects:@" ", nil];
        [sectionContentDict setValue:array4 forKey:[restaurantList objectAtIndex:3]];
        NSArray *array5     = [NSArray arrayWithObjects:@" ", nil];
        [sectionContentDict setValue:array5 forKey:[restaurantList objectAtIndex:4]];
    }

    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [restaurantList count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if ([[arrayForBool objectAtIndex:section] boolValue]) {
        return [[sectionContentDict valueForKey:[restaurantList objectAtIndex:section]] count];
    }
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *headerView              = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    headerView.tag                  = section;
    headerView.backgroundColor      = [UIColor whiteColor];
    UILabel *headerString           = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, self.view.frame.size.width-20-50, 50)];
    BOOL manyCells                  = [[arrayForBool objectAtIndex:section] boolValue];

    headerString.text = [restaurantList objectAtIndex:section];

    if (!manyCells) {
        headerString.textColor = [UIColor blackColor];
    }else{
        headerString.textColor = [UIColor redColor];
    }
    headerString.textAlignment      = NSTextAlignmentLeft;
    [headerView addSubview:headerString];
    
    UITapGestureRecognizer  *headerTapped   = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(sectionHeaderTapped:)];
    [headerView addGestureRecognizer:headerTapped];
    
    return headerView;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *footer  = [[UIView alloc] initWithFrame:CGRectZero];
    return footer;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 42;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([[arrayForBool objectAtIndex:indexPath.section] boolValue]) {
        return 42;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RestaurantCell" forIndexPath:indexPath];
    //cell.textLabel.text = restaurantList[indexPath.row];
  //if (indexPath.row == 1) {
  //  cell.accessoryType = UITableViewCellAccessoryCheckmark;
  //}
    
    BOOL manyCells  = [[arrayForBool objectAtIndex:indexPath.section] boolValue];
    if (!manyCells) {
        cell.textLabel.text = [restaurantList objectAtIndex:indexPath.section];
    }
    else{
        NSArray *content = [sectionContentDict valueForKey:[restaurantList objectAtIndex:indexPath.section]];
        cell.textLabel.text = [content objectAtIndex:indexPath.row];
    }

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];

}

#pragma mark - gesture tapped
- (void)sectionHeaderTapped:(UITapGestureRecognizer *)gestureRecognizer{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:gestureRecognizer.view.tag];
    if (indexPath.row == 0) {
        BOOL collapsed = [[arrayForBool objectAtIndex:indexPath.section] boolValue];
        collapsed = !collapsed;
        [arrayForBool replaceObjectAtIndex:indexPath.section withObject:[NSNumber numberWithBool:collapsed]];
        
        //reload specific section animated
        NSRange range   = NSMakeRange(indexPath.section, 1);
        NSIndexSet *sectionToReload = [NSIndexSet indexSetWithIndexesInRange:range];
        [self.tableView reloadSections:sectionToReload withRowAnimation:UITableViewRowAnimationFade];
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
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
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
