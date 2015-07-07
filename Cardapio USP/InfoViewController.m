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
  [workingHours appendString:@"Segunda à sexta-feira \n"];
  //café da manha
  NSString *weekdayBreakfest = [[[_restaurantDc valueForKey:@"workinghours"] valueForKey:@"weekdays"]valueForKey:@"breakfest"];
  if (weekdayBreakfest && ![weekdayBreakfest isEqualToString:@""]) {
    [workingHours appendString:[NSString stringWithFormat:@"Café da manhã: %@\n", weekdayBreakfest]];
  }
  
  //almoço
  NSString *weekdayLunch = [[[_restaurantDc valueForKey:@"workinghours"] valueForKey:@"weekdays"]valueForKey:@"lunch"];
  if (weekdayLunch && ![weekdayLunch isEqualToString:@""]) {
    [workingHours appendString:[NSString stringWithFormat:@"Almoço: %@\n", weekdayLunch]];
  }
  
  //janta
  NSString *weekdayDinner = [[[_restaurantDc valueForKey:@"workinghours"] valueForKey:@"weekdays"]valueForKey:@"dinner"];
  if (weekdayDinner && ![weekdayDinner isEqualToString:@""]) {
    [workingHours appendString:[NSString stringWithFormat:@"Jantar: %@\n", weekdayDinner]];
  }
  
  //sabado
  [workingHours appendString:@"\nSábado \n"];
  //cafe da manha
  NSString *saturdayBreakfest = [[[_restaurantDc valueForKey:@"workinghours"] valueForKey:@"saturday"]valueForKey:@"breakfest"];
  if (saturdayBreakfest && ![saturdayBreakfest isEqualToString:@""]) {
    [workingHours appendString:[NSString stringWithFormat:@"Café da manhã: %@\n", saturdayBreakfest]];
  }
  
  //almoço
  NSString *saturdayLunch = [[[_restaurantDc valueForKey:@"workinghours"] valueForKey:@"saturday"]valueForKey:@"lunch"];
  if (saturdayLunch && ![saturdayLunch isEqualToString:@""]) {
    [workingHours appendString:[NSString stringWithFormat:@"Almoço: %@\n", saturdayLunch]];
  }
  
  //domingo
  [workingHours appendString:@"\nDomingo \n"];
  //cafe da manha
  NSString *sundayBreakfest = [[[_restaurantDc valueForKey:@"workinghours"] valueForKey:@"sunday"]valueForKey:@"breakfest"];
  if (sundayBreakfest && ![sundayBreakfest isEqualToString:@""]) {
    [workingHours appendString:[NSString stringWithFormat:@"Café da manhã: %@\n", sundayBreakfest]];
  }
  
  //almoço
  NSString *sundayLunch = [[[_restaurantDc valueForKey:@"workinghours"] valueForKey:@"sunday"]valueForKey:@"lunch"];
  if (sundayLunch && ![sundayLunch isEqualToString:@""]) {
    [workingHours appendString:[NSString stringWithFormat:@"Almoço: %@\n", sundayLunch]];
  }
  
  _weeklyperiod.text = workingHours;
  
  //preços
  NSMutableString *prices = [[NSMutableString alloc] init];
  [prices appendString:[NSString stringWithFormat:@"Aluno: %@\n", [[[[[_restaurantDc valueForKey:@"cashiers"] objectAtIndex:0] valueForKey:@"prices"] valueForKey:@"students"] valueForKey:@"lunch"]]];
  [prices appendString:[NSString stringWithFormat:@"Especial: %@\n", [[[[[_restaurantDc valueForKey:@"cashiers"] objectAtIndex:0] valueForKey:@"prices"] valueForKey:@"special"] valueForKey:@"lunch"]]];
  [prices appendString:[NSString stringWithFormat:@"Visitante: %@\n", [[[[[_restaurantDc valueForKey:@"cashiers"] objectAtIndex:0] valueForKey:@"prices"] valueForKey:@"visiting"] valueForKey:@"lunch"]]];
  
  [_priceItens setText:prices];

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
