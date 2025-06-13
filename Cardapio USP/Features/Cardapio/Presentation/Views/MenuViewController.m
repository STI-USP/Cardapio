//
//  MainViewController.m
//  Cardapio USP
//
//  Created by Jun Okamoto Jr. on 19/05/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import "MenuDataModel.h"
#import "Menu.h"
#import "Period.h"
#import "MenuViewController.h"
#import "REFrostedViewController.h"
#import "DKScrollingTabController.h"
#import "RestaurantDataModel.h"
#import "DataModel.h"
#import "SVProgressHUD.h"
#import "OAuthUSP.h"
#import "LoginWebViewController.h"
#import "CreditsViewController.h"
#import "CreditsNavigationViewController.h"
#import "BoletoViewController.h"

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

#define kWIDTH UIScreen.mainScreen.bounds.size.width


@interface MenuViewController () <DKScrollingTabControllerDelegate> {
  
  //DKScrollingTabController *dateTabController;
  
  RestaurantDataModel *_restaurantDataModel;
  MenuDataModel *_menuDataModel;
  DataModel *dataModel;
  
  NSMutableArray *menuArray;
  Menu *menu;
  Period *period;
  int diaDaSemana;
  NSMutableString *stringForLunch;
  
  OAuthUSP *oauth;
  LoginWebViewController *loginViewController;
  CreditsViewController *creditsViewController;
  BoletoViewController *boletoViewController;
}

@end

@implementation MenuViewController

@synthesize diaDaSemanaLabel;

- (void)viewDidLoad {
  [super viewDidLoad];
  
  dataModel = [DataModel getInstance];
  oauth = [OAuthUSP sharedInstance];
  stringForLunch = [NSMutableString stringWithFormat:@""];
  
  [dataModel getMenu];
  
  self.revealViewController.delegate = self;
  [self.rightButton setAction: @selector(rightRevealToggle:)];
  
  //DKScrollingTabController
  _dateTabController = [[DKScrollingTabController alloc] init];
  [self addChildViewController:_dateTabController];
  [_dateTabController didMoveToParentViewController:self];
  [self.view addSubview:_dateTabController.view];
  
  self.tableView.contentInset = UIEdgeInsetsMake(8, 0, 0, 0);
  
  CGFloat topPadding = 0.0;
  CGFloat bottomPadding = 0.0;
  
  if (@available(iOS 11.0, *)) { //Safe Área
    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
    topPadding = window.safeAreaInsets.top;
    bottomPadding = window.safeAreaInsets.bottom;
    
    _dateTabController.view.frame = CGRectMake(0, topPadding+40., CGRectGetWidth(self.view.bounds), 56);
  }
  
  
  if (@available(iOS 13.0, *)) {
    _dateTabController.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
  } else {
    _dateTabController.view.backgroundColor = [UIColor lightTextColor];
  }
  if( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ){
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    if( screenHeight < screenWidth ){
      screenHeight = screenWidth;
    }
    if( screenHeight > 480 && screenHeight < 667 ){
      _dateTabController.buttonPadding = 4.2;
    } else if ( screenHeight > 480 && screenHeight < 736 ){
      _dateTabController.buttonPadding = 8.2;
    } else if ( screenHeight > 480 && screenHeight < 812 ){
      _dateTabController.buttonPadding = 11;
    } else if ( screenHeight > 480 && screenHeight < 896){
      _dateTabController.buttonPadding = 8.2;
    } else if ( screenHeight > 480 ){
      _dateTabController.buttonPadding = 11;
    } else {
      _dateTabController.buttonPadding = 3.2;
    }
  }
  
  _dateTabController.underlineIndicator = YES;
  _dateTabController.underlineIndicatorColor = [UIColor colorNamed:@"usp_orange"];
  _dateTabController.buttonsScrollView.showsHorizontalScrollIndicator = NO;
  _dateTabController.selectedBackgroundColor = [UIColor clearColor];
  if (@available(iOS 13.0, *)) {
    _dateTabController.selectedTextColor = [UIColor labelColor];
  } else {
    // Fallback on earlier versions
    _dateTabController.selectedTextColor = [UIColor blackColor];
  }
  _dateTabController.unselectedTextColor = [UIColor grayColor];
  _dateTabController.unselectedBackgroundColor = [UIColor clearColor];
  _dateTabController.selection = @[@"           \n0",
                                   @"           \n0",
                                   @"           \n0",
                                   @"           \n0",
                                   @"           \n0",
                                   @"           \n0",
                                   @"           \n0"
  ];
  
  //Notification
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeRestaurant:) name:@"DidChangeRestaurant" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMenu:) name:@"DidReceiveMenu" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecieveUserData:) name:@"DidRecieveUserData" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveBill:) name:@"DidReceiveBill" object:nil];
  
  //Float Button - info
  [self setupInfoButton];
}

// Função para configurar o botão de info
- (void)setupInfoButton {
  CGFloat buttonSize = 40;
  CGFloat padding = 20;

  if (!self.infoButton) {
    self.infoButton = [UIButton buttonWithType:UIButtonTypeCustom];

    // Estilo visual
    self.infoButton.layer.cornerRadius = buttonSize / 2;
    self.infoButton.backgroundColor = [UIColor colorNamed:@"usp_green"];
    self.infoButton.tintColor = [UIColor whiteColor];

    // Sombra para destacar no fundo branco ou escuro
    self.infoButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.infoButton.layer.shadowOpacity = 0.2;
    self.infoButton.layer.shadowOffset = CGSizeMake(0, 2);
    self.infoButton.layer.shadowRadius = 4;

    // Centraliza imagem dentro do botão
    self.infoButton.contentEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);

    [self.infoButton addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchUpInside];

    // Adiciona à hierarquia acima de tudo
    [self.view addSubview:self.infoButton];
  }

  // Usa bounds da view (e não da tela) para calcular posição
  UIEdgeInsets safeAreaInsets = self.view.safeAreaInsets;
  CGFloat x = CGRectGetWidth(self.view.bounds) - buttonSize - safeAreaInsets.right - padding;
  CGFloat y = CGRectGetHeight(self.view.bounds) - buttonSize - safeAreaInsets.bottom - padding;

  self.infoButton.frame = CGRectMake(x, y, buttonSize, buttonSize);

  // Ícone adaptado ao modo claro/escuro
  UIImage *infoImage = nil;
  if (@available(iOS 13.0, *)) {
    infoImage = [UIImage systemImageNamed:@"info.circle"];
  } else {
    infoImage = [UIImage imageNamed:@"info"]; // fallback
  }
  [self.infoButton setImage:infoImage forState:UIControlStateNormal];
}

// Atualiza a imagem do botão e seu posicionamento quando o modo de interface mudar ou a safe area for alterada
- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
  [super traitCollectionDidChange:previousTraitCollection];
  
  // Verifica se houve mudança no tema claro/escuro
  if (@available(iOS 13.0, *)) {
    if ([self.traitCollection userInterfaceStyle] != [previousTraitCollection userInterfaceStyle]) {
      [self setupInfoButton];
    }
  }
}

// Observa mudanças na safe area para reposicionar o botão corretamente
- (void)viewSafeAreaInsetsDidChange {
  [super viewSafeAreaInsetsDidChange];
  [self setupInfoButton];
}


- (void)viewWillAppear:(BOOL)animated {
  NSString *name;
  name = [[dataModel currentRestaurant]valueForKey:@"name"];
  [self.navigationItem setTitle:name];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  
  if ([self isMovingFromParentViewController]) {
    NSLog(@"View controller was popped");
  }
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)setupWeekView:(NSArray *)weekMenu {
  if (weekMenu.count < 7) return;
  
  // Define o dia atual da semana (segunda-feira = 0)
  NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  [gregorian setFirstWeekday:2];
  NSDateComponents *weekdayComponents = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
  NSInteger weekday = [weekdayComponents weekday] - 2;
  diaDaSemana = (weekday == -1) ? 6 : (int)weekday;
  
  // Dias abreviados para exibição
  NSArray *diasAbreviados = @[@"SEG", @"TER", @"QUA", @"QUI", @"SEX", @"SÁB", @"DOM"];
  
  // Formatter para converter string -> NSDate
  NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
  inputFormatter.dateFormat = @"dd/MM/yyyy";
  inputFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"];
  
  // Formatter para extrair o número do dia
  NSDateFormatter *diaFormatter = [[NSDateFormatter alloc] init];
  diaFormatter.dateFormat = @"dd";
  diaFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"];
  
  // Cria os títulos dos botões
  for (int i = 0; i < 7; i++) {
    NSString *dateString = [[weekMenu objectAtIndex:i] date];
    NSDate *date = [inputFormatter dateFromString:dateString];
    if (!date) continue;
    
    NSString *diaNumero = [diaFormatter stringFromDate:date]; // "10", "11", etc.
    NSString *titulo = [NSString stringWithFormat:@"%@\n%@", diasAbreviados[i], diaNumero];
    [_dateTabController setButtonName:titulo atIndex:i];
  }
  
  // Estiliza visualmente os botões
  [_dateTabController.buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    UIButton *button = obj;
    button.titleLabel.numberOfLines = 2;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    NSString *titulo = button.titleLabel.text;
    NSArray *linhas = [titulo componentsSeparatedByString:@"\n"];
    if (linhas.count != 2) return;
    
    NSString *linha1 = linhas[0]; // ex: SEG
    NSString *linha2 = linhas[1]; // ex: 10
    
    BOOL isSelecionado = (idx == diaDaSemana);
    
    UIFont *fontDia = isSelecionado ? [UIFont boldSystemFontOfSize:12] : [UIFont systemFontOfSize:12];
    UIFont *fontNumero = isSelecionado ? [UIFont boldSystemFontOfSize:14] : [UIFont systemFontOfSize:14];
    UIColor *corTexto = isSelecionado ? [UIColor labelColor] : [UIColor grayColor];
    
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:titulo];
    [attributed addAttribute:NSFontAttributeName value:fontDia range:NSMakeRange(0, linha1.length)];
    [attributed addAttribute:NSFontAttributeName value:fontNumero range:NSMakeRange(linha1.length + 1, linha2.length)];
    [attributed addAttribute:NSForegroundColorAttributeName value:corTexto range:NSMakeRange(0, titulo.length)];
    
    [button setTitle:@"" forState:UIControlStateNormal]; // limpa texto antigo
    [button setAttributedTitle:attributed forState:UIControlStateNormal];
  }];
  
  // Configurações visuais adicionais do tab
  _dateTabController.buttonPadding = 12;
  _dateTabController.underlineIndicator = YES;
  _dateTabController.underlineIndicatorColor = [UIColor colorNamed:@"usp_orange"];
  _dateTabController.delegate = self;
  
  // Seleciona o botão do dia atual
  [_dateTabController selectButtonWithIndex:diaDaSemana];
}
- (void)setupDayLabel:(int)dia {
  
  NSString *diaSemana;
  NSString *strData = [NSString stringWithFormat:@"%@", [[menuArray objectAtIndex:dia] date]];
  
  //set weekday
  switch ((int)dia) {
    case 0:
      diaSemana = @"Segunda-feira"; break;
    case 1:
      diaSemana = @"Terça-feira"; break;
    case 2:
      diaSemana = @"Quarta-feira"; break;
    case 3:
      diaSemana = @"Quinta-feira"; break;
    case 4:
      diaSemana = @"Sexta-feira"; break;
    case 5:
      diaSemana = @"Sábado"; break;
    case 6:
      diaSemana = @"Domingo"; break;
      
    default:
      break;
  }
  
  //set date
  NSString *strDay = [NSString stringWithFormat:@"%@", [strData substringToIndex:2]];
  NSString *strMonth = [self dayToString:[NSString stringWithFormat:@"%@", [[strData substringFromIndex:3]substringToIndex:2]]];
  NSString *strYear = [NSString stringWithFormat:@"%@", [strData substringFromIndex:6]];
  //set date label
  [diaDaSemanaLabel setText:[NSString stringWithFormat:@"%@, %@ de %@ de %@", diaSemana, strDay, strMonth, strYear]];
  
  [[self tableView] reloadData];
}

- (NSString *)dayToString: (NSString *)strMonth {
  switch ([strMonth intValue]) {
    case 1:
      return @"Janeiro"; break;
    case 2:
      return @"Fevereiro"; break;
    case 3:
      return @"Março"; break;
    case 4:
      return @"Abril"; break;
    case 5:
      return @"Maio"; break;
    case 6:
      return @"Junho"; break;
    case 7:
      return @"Julho"; break;
    case 8:
      return @"Agosto"; break;
    case 9:
      return @"Setembro"; break;
    case 10:
      return @"Outrubro"; break;
    case 11:
      return @"Novembro"; break;
    case 12:
      return @"Dezembro"; break;
      
    default:
      return @""; break;
  }
}

- (void)showInfo {
  [SVProgressHUD show];
  [self performSegueWithIdentifier:@"showInfo" sender:self];
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  if ([self isClosed]) {
    return [menu.period count];
  } else {
    return [menu.period count] + 1;
  }
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 26;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  CGFloat height = 26;
  CGFloat imageSize = 18;
  CGFloat padding = 0;
  
  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, height)];
  view.backgroundColor = [UIColor clearColor];
  
  UILabel *label = [[UILabel alloc] init];
  label.font = [UIFont boldSystemFontOfSize:15];
  label.textColor = [UIColor grayColor];
  
  UIImageView *imageView = nil;
  
  switch (section) {
    case 0: {
      label.text = stringForLunch;
      imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"almoco"]];
      break;
    }
    case 1: {
      label.text = @"JANTAR";
      imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jantar"]];
      break;
    }
    case 2: {
      label.text = @"OBSERVAÇÃO";
      break;
    }
    default:
      return view;
  }
  
  if (imageView) {
    imageView.tintColor = [UIColor grayColor];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.frame = CGRectMake(padding, (height - imageSize) / 2, imageSize, imageSize);
    [view addSubview:imageView];
    
    label.frame = CGRectMake(CGRectGetMaxX(imageView.frame) + 8, 0, tableView.frame.size.width - padding - imageSize - 8, height);
  } else {
    label.frame = CGRectMake(padding, 0, tableView.frame.size.width - padding * 2, height);
  }
  
  [view addSubview:label];
  return view;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
  if (!menu) return @"";
  
  if (section > 1) return @""; // só trata almoço e jantar (0 e 1)
  
  Period *periodo = menu.period[section];
  NSString *calorias = periodo.calories;
  
  if (calorias.length == 0 || [calorias isEqualToString:@"0"]) {
    return @"";
  }
  
  return [NSString stringWithFormat:@"Valor calórico para uma refeição: %@ kcal", calorias];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell" forIndexPath:indexPath];
  
  self.tableView.estimatedRowHeight = 150.;
  
  if (menu) {
    NSString *menuString = @"";
    switch ([indexPath section]) {
      case 0:
        menuString = [NSString stringWithFormat:@"%@", [[[menu period] objectAtIndex:0] menu]];
        if ([menuString isEqualToString:@""]) {
          cell.textLabel.text = @"Fechado";
        } else {
          cell.textLabel.text = menuString;
        }
        break;
      case 1:
        menuString = [NSString stringWithFormat:@"%@", [[[menu period] objectAtIndex:1] menu]];
        if ([menuString isEqualToString:@""]) {
          cell.textLabel.text = @"Fechado";
        } else {
          cell.textLabel.text = menuString;
        }
        break;
      case 2:
        [cell.textLabel setText:[NSString stringWithFormat:@"%@", dataModel.observation]];
        [cell.textLabel setTextColor:[UIColor grayColor]];
        [cell.textLabel setFont:[UIFont systemFontOfSize:14]];
        [cell setBackgroundColor:[UIColor systemGroupedBackgroundColor]];
        break;
        
      default:
        break;
    }
  }
  return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  switch ([indexPath section]) {
    case 2:
      if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        return UITableViewAutomaticDimension;
      } else {
        return 66.;
      }
      break;
      
    default:
      if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        return UITableViewAutomaticDimension;
      } else {
        return 140.;
      }
      break;
  }
}

#pragma mark - Button

- (IBAction)showRestaurantSelector:(id)sender {
  
}

- (IBAction)showCredits:(id)sender {
  creditsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"creditsViewController"];
  
  
  if (![oauth isLoggedIn]) {
    loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginWebViewController"];
    [self presentViewController:loginViewController animated:YES completion:nil];
  } else {
    [dataModel getCreditoRUCard];
    //[self presentViewController:creditsViewController animated:YES completion:nil];
    CreditsNavigationViewController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"navController"];
    [self presentViewController:navController animated:YES completion:nil];
  }
}

#pragma mark - TabControllerDelegate

- (void)ScrollingTabController:(DKScrollingTabController *)controller selection:(NSUInteger)selection {
  menu = [menuArray objectAtIndex:selection];
  [self setupDayLabel:(int)selection];
  
  // Atualiza o estilo de todos os botões com base no botão selecionado
  for (NSUInteger i = 0; i < controller.buttons.count; i++) {
    UIButton *button = controller.buttons[i];
    NSString *titulo = button.titleLabel.text;
    if (!titulo || [titulo rangeOfString:@"\n"].location == NSNotFound) continue;
    
    NSArray *linhas = [titulo componentsSeparatedByString:@"\n"];
    NSString *linha1 = linhas[0];
    NSString *linha2 = linhas[1];
    
    BOOL isSelecionado = (i == selection);
    UIFont *fontDia = isSelecionado ? [UIFont boldSystemFontOfSize:12] : [UIFont systemFontOfSize:12];
    UIFont *fontNumero = isSelecionado ? [UIFont boldSystemFontOfSize:14] : [UIFont systemFontOfSize:14];
    UIColor *corTexto = isSelecionado ? [UIColor labelColor] : [UIColor grayColor];
    
    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:titulo];
    [attributed addAttribute:NSFontAttributeName value:fontDia range:NSMakeRange(0, linha1.length)];
    [attributed addAttribute:NSFontAttributeName value:fontNumero range:NSMakeRange(linha1.length + 1, linha2.length)];
    [attributed addAttribute:NSForegroundColorAttributeName value:corTexto range:NSMakeRange(0, titulo.length)];
    
    [button setAttributedTitle:attributed forState:UIControlStateNormal];
  }
}

#pragma mark - Model

- (void)didChangeRestaurant:(NSNotification *)notification {
  [dataModel getMenu];
  [self.navigationItem setTitle: [[dataModel currentRestaurant]valueForKey:@"name"]];
}

- (void)didReceiveMenu:(NSNotification *)notification {
  
  menuArray = [dataModel menuArray];
  
  if ([menuArray count] > 0) {
    [self setupWeekView:menuArray];
    [self setupDayLabel:diaDaSemana];
    
    menu = [menuArray objectAtIndex:diaDaSemana];
    
    [self viewDidAppear:YES];
    [self.tableView reloadData];
  } else {
    [SVProgressHUD showInfoWithStatus:@"Não foi possível obter o cardápio. \nTente novamente mais tarde."];
  }
  stringForLunch = [NSMutableString stringWithFormat:@"ALMOÇO"];
  
}

- (void)didRecieveUserData:(NSNotification *)notification {
  [self presentViewController:creditsViewController animated:YES completion:nil];
}

- (void)didReceiveBill:(NSNotification *)notification {
  boletoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"boletoViewController"];
  [self presentViewController:boletoViewController animated:YES completion:nil];
}


- (BOOL)isClosed {
  NSString *strLunch = [[[[NSString stringWithFormat:@"%@", [[[menu period] objectAtIndex:0] menu]] capitalizedString] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""];
  
  NSString *strDinner = [[[[NSString stringWithFormat:@"%@", [[[menu period] objectAtIndex:1] menu]] capitalizedString] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""];
  
  
  if ([strLunch isEqualToString:@"Fechado"] || [strLunch isEqualToString:@""]) {
    if ([strDinner isEqualToString:@"Fechado"] || [strDinner isEqualToString:@""]) {
      return YES;
    }
  }
  return NO;
}

#pragma mark - SWRevealViewControllerDelegate
// The following delegate methods will be called before and after the front view moves to a position
- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position {
  if (position == 2) {
    
    //esconde info
    [_infoButton setHidden:YES];
    
    //desabilita swipe na tela
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
      self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
  }
  else {
    //mostra info
    [_infoButton setHidden:NO];
    
    //habilita swipe na tela
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
      self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
  }
}

@end
