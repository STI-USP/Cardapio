//
//  BoletosPendentesTableViewController.m
//  Cardapio USP
//
//  Created by Vagner Machado on 20/12/16.
//  Copyright © 2016 EPUSP. All rights reserved.
//

#import "BoletosPendentesTableViewController.h"
#import "BoletoDataModel.h"
#import "DataModel.h"
#import "SVProgressHUD.h"
#import "SwipeableCell.h"

@interface BoletosPendentesTableViewController () <SwipeableCellDelegate> {
  BoletoDataModel *boletoDataModel;
  DataModel *dataModel;
  SwipeableCell *openedCell;
}

@property (nonatomic, strong) NSMutableSet *cellsCurrentlyEditing;

@end

@implementation BoletosPendentesTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  boletoDataModel = [BoletoDataModel sharedInstance];
  dataModel = [DataModel getInstance];
  self.cellsCurrentlyEditing = [NSMutableSet new];

  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveBills:) name:@"DidReceiveBills" object:nil];
  
  [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"boletosPendentes"];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [boletoDataModel getBoletos];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [[boletoDataModel boletosPendentes] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  SwipeableCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SwipeableCell" forIndexPath:indexPath];
  
  // Configure the cell...
  [cell setTitle:[[[boletoDataModel boletosPendentes] objectAtIndex:indexPath.row] valueForKey:@"valor"]];
  [cell setValue:[NSString stringWithFormat:@"vencimento em %@", [[[boletoDataModel boletosPendentes] objectAtIndex:indexPath.row] valueForKey:@"vencimento"]]];
  [cell setSubTitle:[[[boletoDataModel boletosPendentes] objectAtIndex:indexPath.row] valueForKey:@"codigoBarras"]];

  [cell setDelegate: self];
  
  if ([self.cellsCurrentlyEditing containsObject:indexPath])
    [cell openCell];
  
  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [tableView deselectRowAtIndexPath:indexPath animated:YES];
  [boletoDataModel setBoleto:[[boletoDataModel boletosPendentes] objectAtIndex:indexPath.row]];
  [self performSegueWithIdentifier:@"showDetail" sender:self];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return 55.f;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - SwipeableCellDelegate
- (void)buttonOneActionForItemText:(NSString *)itemText {
  [self copyToPasteboard];
}

- (void)buttonTwoActionForItemText:(NSString *)itemText {
}

- (void)closeModal {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)cellDidOpen:(UITableViewCell *)cell {
  if (![cell isEqual:openedCell]) {
    [openedCell closeCell]; // fecha celula anterior
    NSIndexPath *currentEditingIndexPath = [self.tableView indexPathForCell:cell];
    self.cellsCurrentlyEditing = nil;
    [self.cellsCurrentlyEditing addObject:currentEditingIndexPath];
    openedCell = [[SwipeableCell alloc] init];
    openedCell = (SwipeableCell *)cell; //atribui novo valor à celula de edição
  }
}

- (void)cellDidClose:(UITableViewCell *)cell {
  [self.cellsCurrentlyEditing removeObject:[self.tableView indexPathForCell:cell]];
}


- (void)didReceiveBills:(NSNotification *)notification {
  [SVProgressHUD dismiss];
  [self.tableView reloadData];
}

- (IBAction)dismiss:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)copyToPasteboard {
  [[UIPasteboard generalPasteboard] setString:[openedCell subTitle]];
  [openedCell closeCell];
}

@end
