//
//  MainViewController.m
//  Cardapio USP
//
//  Created by Vagner Machado on 14/04/21.
//  Copyright © 2021 USP. All rights reserved.
//

#import "MainViewController.h"
#import "RestaurantDataModel.h"
#import "MenuDataModel.h"
#import "DataModel.h"
#import "OAuthUSP.h"
#import "SVProgressHUD.h"
#import "WebViewController.h"


@interface MainViewController () {
  RestaurantDataModel *_restaurantDataModel;
  MenuDataModel *_menuDataModel;
  DataModel *dataModel;
  OAuthUSP *oauth;
  
  NSMutableArray *menuArray;
  Menu *mainMenu;
  Period *period;
  int diaDaSemana;

}

@end

@implementation MainViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  
  dataModel = [DataModel getInstance];
  oauth = [OAuthUSP sharedInstance];

  if ([dataModel preferredRestaurant]) {
    [dataModel setCurrentRestaurant:[dataModel preferredRestaurant]];
  }

  //Notificacoes
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMenu:) name:@"DidReceiveMenu" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecieveCredits:) name:@"DidReceiveCredits" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecieveCreditsError:) name:@"DidReceiveCreditsError" object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
  [dataModel getMenu];
  NSString *name;
  name = [[dataModel currentRestaurant]valueForKey:@"name"];
  [self.navigationController.navigationItem setTitle: name];
  
  if ([oauth isLoggedIn])
    [dataModel getCreditoRUCard];
  else
    [_saldo setText:@"R$ --,--"];

}


#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  
  //Web Content
  if ([[segue identifier] isEqualToString:@"showWebContent"]) {
    NSString *urlString = @"";
    NSString *title = @"";
    
    UIButton *btn = (UIButton *)sender;
    switch (btn.tag) {
      case 1:
        urlString = @"https://sites.usp.br/sas/";
        title = @"Apoio Institucional";
        break;

      case 2:
        urlString = @"https://sites.usp.br/sas/";
        title = @"Transporte";
        break;

      case 3:
        urlString = @"https://sites.usp.br/sas/";
        title = @"Avisos";
        break;

      case 4:
        urlString = @"https://sites.usp.br/sas/";
        title = @"Saúde Mental";
        break;

      case 5:
        urlString = @"https://sites.usp.br/sas/";
        title = @"Moradia";
        break;

      case 6:
        urlString = @"https://sites.usp.br/sas/";
        title = @"Creche";
        break;

      case 7:
        urlString = @"https://sites.usp.br/sas/";
        title = @"Serviço Social";
        break;

      case 8:
        title = @"Acolhe USP";
        urlString = @"https://sites.usp.br/sas/";
        break;

      default:
        urlString = @"https://sites.usp.br/sas/";
        break;
    }
    
    WebViewController *webViewController = (WebViewController *)[segue destinationViewController];
    webViewController.urlString = urlString;
    webViewController.navTitle = title;
  }
}


- (void)didReceiveMenu:(NSNotification *)notification {

  //Nome do restaurante
  if (dataModel.currentRestaurant) {
    [_restaurante setText:[(NSString *)[dataModel.currentRestaurant valueForKey:@"name"] uppercaseString]];
  } else if (dataModel.preferredRestaurant) {
    [_restaurante setText:[(NSString *)[dataModel.preferredRestaurant valueForKey:@"name"] uppercaseString]];
  } else {
    [_restaurante setText:@"CENTRAL"];
  }

  //Periodo
  [_tipoRefeicao setText:[self period]];

  //Refeição
  [self setupMenuView];
}


- (void)didRecieveCredits:(NSNotification *)notification {
  [_saldo setText:[NSString stringWithFormat:@"R$ %@", [dataModel ruCardCredit]]];
}

- (void)didRecieveCreditsError:(NSNotification *)notification {
  NSString *message = @"Não foi possível obter o saldo. \nTente novamente mais tarde.";
  [SVProgressHUD showErrorWithStatus:message];
}


//UIVIew Helper
- (NSString *)period {
  // For calculating the current date
  NSDate *date = [NSDate date];

  // Make Date Formatter
  NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
  [dateFormatter setDateFormat:@"hh a EEEE"];

  // hh for hour mm for minutes and a will show you AM or PM
  NSString *str = [dateFormatter stringFromDate:date];
  // NSLog(@"%@", str);

  // Sperate str by space i.e. you will get time and AM/PM at index 0 and 1 respectively
  NSArray *array = [str componentsSeparatedByString:@" "];

  // Now you can check it by 12. If < 12 means Its morning > 12 means its evening or night

  NSString *message;
  NSString *timeInHour;
  NSString *am_pm;

  NSString *DayOfWeek;
  if (array.count>2) {
    // am pm case
    timeInHour = array[0];
    am_pm = array[1];
    DayOfWeek  = array[2];
  } else if (array.count>1) {
    // 24 hours case
    timeInHour = array[0];
    DayOfWeek = array[1];
  }

  if (am_pm) {
    if ([timeInHour integerValue]==12 && [am_pm isEqualToString:@"AM"]) {
      message = [NSString stringWithFormat:@"Morning"];
      return @"almoço";
    } else if ([timeInHour integerValue]<=9 && [am_pm isEqualToString:@"AM"]) {
      message = [NSString stringWithFormat:@"Morning"];
      return @"almoço";
    } else if (([timeInHour integerValue]>=10 && [timeInHour integerValue]!=12 && [am_pm isEqualToString:@"AM"]) || (([timeInHour integerValue]<3 || [timeInHour integerValue]==12) && [am_pm isEqualToString:@"PM"])) {
      message = [NSString stringWithFormat:@"Afternoon"];
      return @"almoço";
    } else if ([timeInHour integerValue]>=3 && [timeInHour integerValue]<=9 && [am_pm isEqualToString:@"PM"]) {
      message = [NSString stringWithFormat:@"Evening"];
      return @"jantar";
    } else if (([timeInHour integerValue]>=10 && [timeInHour integerValue]!=12 && [am_pm isEqualToString:@"PM"]) || (( [timeInHour integerValue]<12) && [am_pm isEqualToString:@"AM"])) {
      message = [NSString stringWithFormat:@"Night"];
      return @"jantar";
    }
  } else {
    if ([timeInHour integerValue]>=0 && [timeInHour integerValue]<10) {
      message = [NSString stringWithFormat:@"Morning"];
      return @"almoço";
    } else if ([timeInHour integerValue]>=10 && [timeInHour integerValue]<15) {
      message = [NSString stringWithFormat:@"Afternoon"];
      return @"almoço";
    } else if ([timeInHour integerValue]>=15 && [timeInHour integerValue]<22) {
      message = [NSString stringWithFormat:@"Evening"];
      return @"jantar";
    } else {
      message = [NSString stringWithFormat:@"Night"];
      return @"jantar";
    }
  }

  /*
  if (DayOfWeek) {
    _timeLbl.text=[NSString stringWithFormat:@"%@ %@",DayOfWeek,message];
  }
   */
  return @"almoço";
}

- (void)setupMenuView {
  
  menuArray = [dataModel menuArray];

  NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  [gregorian setFirstWeekday:2];
  NSDateComponents *weekdayComponents = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
  NSInteger weekday = [weekdayComponents weekday] - 2; //para deixar a segunda feira como 0
  
  if ((int)weekday == -1) {
    diaDaSemana = 6;
  } else {
    diaDaSemana = (int)weekday;
  }

  //Data
  NSString *strData = [NSString stringWithFormat:@"%@", [[menuArray objectAtIndex:diaDaSemana] date]];
  NSString *strDay = [NSString stringWithFormat:@"%@", [strData substringToIndex:2]];
  NSString *strMonth = [NSString stringWithFormat:@"%@", [[strData substringFromIndex:3]substringToIndex:2]];
  NSString *strYear = [NSString stringWithFormat:@"%@", [strData substringFromIndex:6]];
  
  [_data setText:[NSString stringWithFormat:@"%@/%@/%@", strDay, strMonth, strYear]];

  if ([menuArray count] > 0) {
    mainMenu = [menuArray objectAtIndex:diaDaSemana];
    if ([[self period] isEqualToString:@"almoço"]) {
      NSString *lunch = [[[mainMenu period] objectAtIndex:0] menu];
      if ([lunch isEqualToString:@""]) {
        [_cardapioAtual setText:@"Fechado"];
      } else {
        [_cardapioAtual setText:lunch];
      }
    } else {
      NSString *dinner = [[[mainMenu period] objectAtIndex:1] menu];
      if ([dinner isEqualToString:@""]) {
        [_cardapioAtual setText:@"Fechado"];
      } else {
        [_cardapioAtual setText:dinner];
      }
    }
  }

}

- (IBAction)showAcolhe:(id)sender {
  
  [self performSegueWithIdentifier:@"showWebContent" sender:(UIButton *)sender];
}

- (IBAction)showServicoSocial:(id)sender {
  [self performSegueWithIdentifier:@"showWebContent" sender:(UIButton *)sender];
}

- (IBAction)showCreche:(id)sender {
  [self performSegueWithIdentifier:@"showWebContent" sender:(UIButton *)sender];
}

- (IBAction)showMoradia:(id)sender {
  [self performSegueWithIdentifier:@"showWebContent" sender:(UIButton *)sender];
}

- (IBAction)showSaudeMental:(id)sender {
  [self performSegueWithIdentifier:@"showWebContent" sender:sender];
}

- (IBAction)showAvisos:(id)sender {
  [self performSegueWithIdentifier:@"showWebContent" sender:sender];
}

- (IBAction)showTransporte:(id)sender {
  [self performSegueWithIdentifier:@"showWebContent" sender:sender];
}

- (IBAction)showInstitucional:(id)sender {
  [self performSegueWithIdentifier:@"showWebContent" sender:sender];
}

@end
