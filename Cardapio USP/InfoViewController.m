//
//  MenuDataModel.h
//  Cardapio USP
//
//  Created by Alessandro Souzadidier on 13/06/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import "InfoViewController.h"
#import "MenuDataModel.h"
#import "Restaurant.h"
#import "WeeklyPeriod.h"
#import "Cash.h"
#import "Items.h"
@interface InfoViewController ()

@end

@implementation InfoViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.tableView.allowsSelection = NO;
    
  _model = [MenuDataModel getInstance];

    
}


-(void)viewWillAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    _model.date = @"23/05/2014";
    _model.rest = @"Central";
    _model.campi = @"CUASO";
    
    _restaurant = [_model restaurant];
    
    _address.text = [NSString stringWithFormat:@"%@", [_restaurant address]];
    _phone.text = [NSString stringWithFormat:@"%@", [_restaurant phone]];
    
    NSString *w = @"";
    for (WeeklyPeriod *wp in [_restaurant weeklyperiod]) {
        w = [w stringByAppendingString:[NSString stringWithFormat:@"%@\n%@\n%@\n%@\n", [wp period], [wp breakfast], [wp lunch], [wp dinner]]];
    }
    _weeklyperiod.text = w;
    
    
    /**
     *  Informacoes de preco
     */
    Cash *cash = [_model cash];
//    NSLog(@"CASH %@ ",[cash workinghours]);
    _workinghours.text = [NSString stringWithFormat:@"%@", [cash workinghours]];
    NSString *i = @"";
    for (Items *item in [cash items]) {
        i = [i stringByAppendingString:[NSString stringWithFormat:@"%@: %@\n", [item category], [item price]]];
    }   
    _priceItens.text = i;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)doneButtonTapped:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}
@end
