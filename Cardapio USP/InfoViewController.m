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
    
  self.dataModel = [MenuDataModel getInstance];
}


-(void)viewWillAppear:(BOOL)animated {
  [super viewDidAppear:YES];
  self.dataModel.date = @"23/05/2014"; // segunda feira da semana corrente
  
  for (id campus in [self.dataModel restaurantsByCampus]){
    if ([[campus valueForKey:@"name"] isEqualToString:[[self.dataModel campus] valueForKey:@"name"]]){
      for (id restaurant in [campus valueForKey:@"restaurants"]) {
        if ([[restaurant valueForKey:@"name"] isEqualToString:[self.dataModel restaurantName]]){
          _restaurant = restaurant;
        }
      }
    }
  }
  _restImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[_restaurant valueForKey:@"photourl"]]]];
  _address.text = [NSString stringWithFormat:@"%@", [_restaurant valueForKey:@"address"]];
  
  
  //telefone
  NSMutableString *telephones = [[NSMutableString alloc] init];
  for (NSString *t in [_restaurant valueForKey:@"phones"]) {
    [telephones appendString:[NSString stringWithFormat:@"%@\n", t]];
  }
  if (telephones.length >=1 ) { // se tiver mais de um caracater no string vai ter um \n no final
    [telephones deleteCharactersInRange:NSMakeRange(telephones.length - 1, 1)]; // retira último \n
  }
  _phone.text = telephones;
    
  //horario de funcionamento
  NSMutableString *workingHours = [[NSMutableString alloc] init];
  
  //dia de semana
  [workingHours appendString:@"Segundas as sextas-feiras \n"];
  //café da manha
  NSString *weekdayBreakfest = [[[_restaurant valueForKey:@"workinghours"] valueForKey:@"weekdays"]valueForKey:@"breakfest"];
  if (weekdayBreakfest) {
    [workingHours appendString:[NSString stringWithFormat:@"Café da manhã: %@\n", weekdayBreakfest]];
  }

  //almoço
  NSString *weekdayLunch = [[[_restaurant valueForKey:@"workinghours"] valueForKey:@"weekdays"]valueForKey:@"lunch"];
  if (weekdayLunch) {
    [workingHours appendString:[NSString stringWithFormat:@"Almoço: %@\n", weekdayLunch]];
  }

  //janta
  NSString *weekdayDinner = [[[_restaurant valueForKey:@"workinghours"] valueForKey:@"weekdays"]valueForKey:@"dinner"];
  if (weekdayDinner) {
    [workingHours appendString:[NSString stringWithFormat:@"Jantar: %@\n", weekdayDinner]];
  }

  //sabado
  [workingHours appendString:@"\nSábados \n"];
  //cafe da manha
  NSString *saturdayBreakfest = [[[_restaurant valueForKey:@"workinghours"] valueForKey:@"saturday"]valueForKey:@"breakfest"];
  if (saturdayBreakfest) {
    [workingHours appendString:[NSString stringWithFormat:@"Café da manhã: %@\n", saturdayBreakfest]];
  }

  //almoço
  NSString *saturdayLunch = [[[_restaurant valueForKey:@"workinghours"] valueForKey:@"saturday"]valueForKey:@"lunch"];
  if (saturdayLunch) {
    [workingHours appendString:[NSString stringWithFormat:@"Almoço: %@\n", saturdayLunch]];
  }

  //domingo
  [workingHours appendString:@"\nDomingos \n"];
  //cafe da manha
  NSString *sundayBreakfest = [[[_restaurant valueForKey:@"workinghours"] valueForKey:@"sunday"]valueForKey:@"breakfest"];
  if (sundayBreakfest) {
    [workingHours appendString:[NSString stringWithFormat:@"Café da manhã: %@\n", sundayBreakfest]];
  }
  
  //almoço
  NSString *sundayLunch = [[[_restaurant valueForKey:@"workinghours"] valueForKey:@"sunday"]valueForKey:@"lunch"];
  if (sundayLunch) {
    [workingHours appendString:[NSString stringWithFormat:@"Almoço: %@\n", sundayLunch]];
  }
  
  _weeklyperiod.text = workingHours;


  /*
    /
       Informacoes de preco
     /
    Cash *cash = [_model cash];
//    NSLog(@"CASH %@ ",[cash workinghours]);
    _workinghours.text = [NSString stringWithFormat:@"%@", [cash workinghours]];
    NSString *i = @"";
    for (Items *item in [cash items]) {
        i = [i stringByAppendingString:[NSString stringWithFormat:@"%@: %@\n", [item category], [item price]]];
    }   
    _priceItens.text = i;
     */
  _priceItens.text = @"";

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
