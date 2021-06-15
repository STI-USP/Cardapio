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

#define kWIDTH UIScreen.mainScreen.bounds.size.width

@interface MainViewController () {
  RestaurantDataModel *_restaurantDataModel;
  MenuDataModel *_menuDataModel;
  DataModel *dataModel;
  OAuthUSP *oauth;
  
  NSMutableArray *menuArray;
  Menu *mainMenu;
  Period *period;
  int diaDaSemana;

  CGFloat originalMenuHeight;
  NSLayoutConstraint *newHeightConstraint;

  UIVisualEffectView *blurEffectView;

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
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeRestaurant:) name:@"DidChangeRestaurant" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecieveCreditsError:) name:@"DidReceiveCreditsError" object:nil];
  
  
  //Reveal View Controller ----------------
  SWRevealViewController *revealViewController = self.revealViewController;
  if (revealViewController) {
    revealViewController.rightViewRevealWidth = kWIDTH - 60;
    revealViewController.rightViewRevealOverdraw = 0;
      
    [self.revealViewController panGestureRecognizer];
    [self.revealViewController tapGestureRecognizer];
    self.revealViewController.delegate = self;
  }
  
  //Animate View
  UILongPressGestureRecognizer *recoginzer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onPress:)];
  [_menuButton addGestureRecognizer:recoginzer];
  
}

- (void)viewWillAppear:(BOOL)animated {
  
  [super viewWillAppear:animated];
  self.revealViewController.delegate = self;

  [_expandMenuView setHidden:YES];
  
  [dataModel getMenu];
  NSString *name;
  name = [[dataModel currentRestaurant] valueForKey:@"name"];
  [self.navigationController.navigationItem setTitle: name];
  
  if ([oauth isLoggedIn])
    [dataModel getCreditoRUCard];
  else
    [_saldo setText:@"R$ --,--"];
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}


//expande menu e adiciona transparencia
- (void)onPress:(UILongPressGestureRecognizer*)longpress {

  if (longpress.state == UIGestureRecognizerStateBegan) {

    /*
    //verifica se texto está truncado
    CGSize size = [_cardapioAtual.text sizeWithAttributes:@{NSFontAttributeName:_cardapioAtual.font}];
    if (size.height > _cardapioAtual.bounds.size.height) {
    }
     */

    //only apply the blur if the user hasn't disabled transparency effects
    if (!UIAccessibilityIsReduceTransparencyEnabled()) {

      UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemMaterial];
      blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
      blurEffectView.frame = self.view.bounds;
      blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

      [self.view insertSubview:blurEffectView atIndex:18];
    }
    
    [_expandMenuView setHidden:NO];
    
    
    //feedback haptico
    UIImpactFeedbackGenerator *gen = [[UIImpactFeedbackGenerator alloc] initWithStyle:(UIImpactFeedbackStyleMedium)];
    [gen impactOccurred];
    gen = NULL;
    

    //NSLog(@"Long press");
  } else if (longpress.state == UIGestureRecognizerStateEnded || longpress.state == UIGestureRecognizerStateCancelled || longpress.state == UIGestureRecognizerStateFailed) {
    //NSLog(@"long press done");
  }
}

//recolhe menu expandido e retira transparencia
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {

  [blurEffectView removeFromSuperview];
  
  UITouch *touch = [touches anyObject];
  if(touch.view != self.expandMenuView)
    [_expandMenuView setHidden:YES];
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
      case 0: //RUCard
        break;

      case 1:
        title = @"Apoio Institucional";
        urlString = @"https://sites.usp.br/sas/";
        break;

      case 2:
        title = @"Transporte";
        urlString = @"https://sites.usp.br/sas/passe-escolar/";
        break;

      case 3:
        title = @"Avisos";
        urlString = @"https://sites.usp.br/sas/avisos-gerais/";
        break;

      case 4:
        title = @"Saúde Mental";
        urlString = @"https://sites.usp.br/sas/";
        break;

      case 5:
        title = @"Moradia";
        urlString = @"https://sites.usp.br/sas/moradia/";
        break;

      case 6:
        title = @"Creche";
        urlString = @"https://sites.usp.br/sas/";
        break;

      case 7:
        title = @"Serviço Social";
        urlString = @"https://sites.usp.br/sas/";
        break;

      case 8:
        title = @"Acolhe USP";
        urlString = @"https://sites.usp.br/sas/acolhe-usp-2/";
        break;

      default:
        urlString = @"https://sites.usp.br/sas/";
        break;
    }
    
    WebViewController *webViewController = (WebViewController *)[segue destinationViewController];
    webViewController.urlString = urlString;
    webViewController.navTitle = title;
    
  } else if ([[segue identifier] isEqualToString:@"showWeekMenu"]) {
    [blurEffectView removeFromSuperview];
    [_expandMenuView setHidden:YES];
  }
}


static void setupView(MainViewController *object) {

  //Nome do restaurante
  if (object->dataModel.currentRestaurant) {
    [object->_restaurante setText:[(NSString *)[object->dataModel.currentRestaurant valueForKey:@"name"] uppercaseString]];
    [object->_restauranteExp setText:[(NSString *)[object->dataModel.currentRestaurant valueForKey:@"name"] uppercaseString]];
  } else if (object->dataModel.preferredRestaurant) {
    [object->_restaurante setText:[(NSString *)[object->dataModel.preferredRestaurant valueForKey:@"name"] uppercaseString]];
    [object->_restauranteExp setText:[(NSString *)[object->dataModel.preferredRestaurant valueForKey:@"name"] uppercaseString]];
  } else {
    [object->_restaurante setText:@"CENTRAL"];
    [object->_restauranteExp setText:@"CENTRAL"];
  }
  
  //Periodo
  [object->_tipoRefeicao setText:[object period]];
  [object->_tipoRefeicaoExp setText:[object period]];

  //Refeição
  [object setupMenuView];
  
  object->originalMenuHeight = object->_menuView.frame.size.height;
}

- (void)didReceiveMenu:(NSNotification *)notification {
  setupView(self);
}


- (void)didRecieveCredits:(NSNotification *)notification {
  [_saldo setText:[NSString stringWithFormat:@"R$ %@", [dataModel ruCardCredit]]];
  [_saldoExp setText:[NSString stringWithFormat:@"R$ %@", [dataModel ruCardCredit]]];
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
  [_dataExp setText:[NSString stringWithFormat:@"%@/%@/%@", strDay, strMonth, strYear]];

  if ([menuArray count] > 0) {
    mainMenu = [menuArray objectAtIndex:diaDaSemana];
    if ([[self period] isEqualToString:@"almoço"]) {
      NSString *lunch = [[[mainMenu period] objectAtIndex:0] menu];
      if ([lunch isEqualToString:@""]) {
        [_cardapioAtual setText:@"Fechado"];
        [_cardapioAtualExp setText:@"Fechado"];
      } else {
        [_cardapioAtual setText:lunch];
        [_cardapioAtualExp setText:lunch];
      }
    } else {
      NSString *dinner = [[[mainMenu period] objectAtIndex:1] menu];
      if ([dinner isEqualToString:@""]) {
        [_cardapioAtual setText:@"Fechado"];
        [_cardapioAtualExp setText:@"Fechado"];
      } else {
        [_cardapioAtual setText:dinner];
        [_cardapioAtualExp setText:dinner];
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

- (void)didChangeRestaurant:(NSNotification *)notification {
  [dataModel getMenu];
}


#pragma mark - SWRevealViewControllerDelegate


// Implement this to return NO when you want the pan gesture recognizer to be ignored
- (BOOL)revealControllerPanGestureShouldBegin:(SWRevealViewController *)revealController {
  if ([self.navigationController.topViewController isKindOfClass:self.class]) {
    return NO;
  } else {
    return YES;
  }
}


// The following delegate methods will be called before and after the front view moves to a position
- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position {
  if (position == 2) {

    //desabilita botão do cardapio
    [_menuButton setEnabled:NO];

    //desabilita swipe na tela
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
      self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
  }
  else {

    //habilita botão do cardapio
    [_menuButton setEnabled:YES];

    //habilita swipe na tela
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
      self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
  }
}

- (IBAction)menuBtnExpClicked:(id)sender {
}
@end
