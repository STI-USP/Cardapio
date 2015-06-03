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
#import "DataModel.h"


@interface InfoViewController () {
  DataModel *dataModel;
}

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

  dataModel = [DataModel getInstance];

  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRestaurants) name:@"DidReceiveRestaurants" object:nil];
}


-(void)viewWillAppear:(BOOL)animated {
  [super viewDidAppear:YES];
  if ([[dataModel restaurants] count] == 0) {
    [dataModel getRestaurants];
  } else {
    [self setupView];
  }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)setupView{

  [self setTitle:@"Informações gerais"];

  _restaurantDc = [dataModel currentRestaurant];
  
  _restImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[_restaurantDc valueForKey:@"photourl"]]]];
  
  [_restaurantName setText: [_restaurantDc valueForKey:@"name"]];
  [_restaurantName setNumberOfLines:0];
  [_restaurantName setBackgroundColor:[UIColor clearColor]];
  [_restaurantName setTextColor:[UIColor whiteColor]];
  [_restaurantName setFont:[UIFont systemFontOfSize:14]];
  [_restaurantName setShadowColor:[UIColor blackColor]];
  [_restaurantName setShadowOffset:CGSizeMake(1, 1)];
  [_restaurantName setTextAlignment:NSTextAlignmentCenter];
  
  [_restaurantNameOverlay setText: [_restaurantDc valueForKey:@"name"]];
  [_restaurantNameOverlay setNumberOfLines:0];
  [_restaurantNameOverlay setBackgroundColor:[UIColor clearColor]];
  [_restaurantNameOverlay setTextColor:[UIColor blackColor]];
  [_restaurantNameOverlay setFont:[UIFont systemFontOfSize:14]];
  [_restaurantNameOverlay setShadowColor:[UIColor blackColor]];
  [_restaurantNameOverlay setShadowOffset:CGSizeMake(1, 1)];
  [_restaurantNameOverlay setAlpha:0.4];
  [_restaurantNameOverlay setTextAlignment:NSTextAlignmentCenter];
  
  _address.text = [NSString stringWithFormat:@"%@", [_restaurantDc valueForKey:@"address"]];
  
  //telefone
  NSMutableString *telephones = [[NSMutableString alloc] init];
  if ([[_restaurantDc objectForKey:@"phones"] isKindOfClass:[NSString class]]) {
    telephones = [_restaurantDc valueForKey:@"phones"];
  } else {
    for (NSString *tel in [_restaurantDc valueForKey:@"phones"])
      [telephones appendString:[NSString stringWithFormat:@"%@\n", tel]];

      if (telephones.length >=1 ) { // se tiver mais de um caracater no string vai ter um \n no final
      [telephones deleteCharactersInRange:NSMakeRange(telephones.length - 1, 1)]; // retira último \n
    }
    
  }
  _phone.text = telephones;
  
  //horario de funcionamento
  NSMutableString *workingHours = [[NSMutableString alloc] init];
  
  //dia de semana
  [workingHours appendString:@"Segundas as sextas-feiras \n"];
  //café da manha
  NSString *weekdayBreakfest = [[[_restaurantDc valueForKey:@"workinghours"] valueForKey:@"weekdays"]valueForKey:@"breakfest"];
  if (weekdayBreakfest) {
    [workingHours appendString:[NSString stringWithFormat:@"Café da manhã: %@\n", weekdayBreakfest]];
  }
  
  //almoço
  NSString *weekdayLunch = [[[_restaurantDc valueForKey:@"workinghours"] valueForKey:@"weekdays"]valueForKey:@"lunch"];
  if (weekdayLunch) {
    [workingHours appendString:[NSString stringWithFormat:@"Almoço: %@\n", weekdayLunch]];
  }
  
  //janta
  NSString *weekdayDinner = [[[_restaurantDc valueForKey:@"workinghours"] valueForKey:@"weekdays"]valueForKey:@"dinner"];
  if (weekdayDinner) {
    [workingHours appendString:[NSString stringWithFormat:@"Jantar: %@\n", weekdayDinner]];
  }
  
  //sabado
  [workingHours appendString:@"\nSábado \n"];
  //cafe da manha
  NSString *saturdayBreakfest = [[[_restaurantDc valueForKey:@"workinghours"] valueForKey:@"saturday"]valueForKey:@"breakfest"];
  if (saturdayBreakfest) {
    [workingHours appendString:[NSString stringWithFormat:@"Café da manhã: %@\n", saturdayBreakfest]];
  }
  
  //almoço
  NSString *saturdayLunch = [[[_restaurantDc valueForKey:@"workinghours"] valueForKey:@"saturday"]valueForKey:@"lunch"];
  if (saturdayLunch) {
    [workingHours appendString:[NSString stringWithFormat:@"Almoço: %@\n", saturdayLunch]];
  }
  
  //domingo
  [workingHours appendString:@"\nDomingo \n"];
  //cafe da manha
  NSString *sundayBreakfest = [[[_restaurantDc valueForKey:@"workinghours"] valueForKey:@"sunday"]valueForKey:@"breakfest"];
  if (sundayBreakfest) {
    [workingHours appendString:[NSString stringWithFormat:@"Café da manhã: %@\n", sundayBreakfest]];
  }
  
  //almoço
  NSString *sundayLunch = [[[_restaurantDc valueForKey:@"workinghours"] valueForKey:@"sunday"]valueForKey:@"lunch"];
  if (sundayLunch) {
    [workingHours appendString:[NSString stringWithFormat:@"Almoço: %@\n", sundayLunch]];
  }
  
  _weeklyperiod.text = workingHours;
  
  /*
   Cash *cash = [_model cash];
   NSLog(@"CASH %@ ",[cash workinghours]);
   _workinghours.text = [NSString stringWithFormat:@"%@", [cash workinghours]];
   NSString *i = @"";
   for (Items *item in [cash items]) {
   i = [i stringByAppendingString:[NSString stringWithFormat:@"%@: %@\n", [item category], [item price]]];
   }
   _priceItens.text = i;
   */
  _priceItens.text = @"";
  
  [self reloadInputViews];
}

- (void)doneButtonTapped:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveRestaurants{
  [self setupView];
}

-(IBAction)setPreferred:(id)sender{
  [dataModel setPreferredRestaurant:_restaurantDc];
}

@end
