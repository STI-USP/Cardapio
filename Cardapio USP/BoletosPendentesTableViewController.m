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

@interface BoletosPendentesTableViewController () {
  BoletoDataModel *boletoDataModel;
  DataModel *dataModel;
}

@end

@implementation BoletosPendentesTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];

  boletoDataModel = [BoletoDataModel sharedInstance];
  dataModel = [DataModel getInstance];
  
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
  //UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"boletosPendentes" forIndexPath:indexPath];
  
  UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"boletosPendentes"];
  
  // Configure the cell...
  [cell.textLabel setText: [NSString stringWithFormat:@"%@ \t\t\t\t R$ %@", [[[boletoDataModel boletosPendentes] objectAtIndex:indexPath.row] valueForKey:@"vencimento"], [[[boletoDataModel boletosPendentes] objectAtIndex:indexPath.row] valueForKey:@"valor"]]];
  [cell.detailTextLabel setText:[[[boletoDataModel boletosPendentes] objectAtIndex:indexPath.row] valueForKey:@"codigoBarras"]];

  return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  [boletoDataModel setBoleto:[[boletoDataModel boletosPendentes] objectAtIndex:indexPath.row]];
  [self performSegueWithIdentifier:@"showDetail" sender:self];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)didReceiveBills:(NSNotification *)notification {
  NSLog(@"recebeu lista de pendentes");
  [self.tableView reloadData];
}

- (IBAction)dismiss:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}



@end
