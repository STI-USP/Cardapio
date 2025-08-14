//
//  MainViewController.m
//  Cardapio USP
//
//  Created by Vagner Machado on 14/08/25.
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

@interface MenuViewController () <DKScrollingTabControllerDelegate, SWRevealViewControllerDelegate> {
  RestaurantDataModel *_restaurantDataModel;
  MenuDataModel *_menuDataModel;
  DataModel *dataModel;

  NSMutableArray<Menu *> *menuArray;
  Menu *menu;
  int diaDaSemana;
  NSMutableString *stringForLunch;

  OAuthUSP *oauth;
  LoginWebViewController *loginViewController;
  CreditsViewController *creditsViewController;
  BoletoViewController *boletoViewController;
}

// UI
//@property (nonatomic, strong) DKScrollingTabController *dateTabController;
//@property (nonatomic, strong) UIButton *infoButton;

@end

@implementation MenuViewController

@synthesize diaDaSemanaLabel;

#pragma mark - Helpers (semana fixa + merge)

/// Cria 7 menus vazios (SEG–DOM) da semana corrente, datas em "dd/MM/yyyy".
static NSArray<Menu *> *ScaffoldSemanaVazia(void) {
  NSMutableArray *semana = [NSMutableArray arrayWithCapacity:7];

  NSCalendar *greg = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  greg.firstWeekday = 2; // segunda
  NSDate *hoje = [NSDate date];

  NSDateComponents *comps = [greg components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday) fromDate:hoje];
  NSInteger weekday = comps.weekday; // 1=domingo ... 7=sábado
  NSInteger offsetToMonday = (weekday == 1) ? -6 : (2 - weekday);
  NSDate *segunda = [greg dateByAddingUnit:NSCalendarUnitDay value:offsetToMonday toDate:hoje options:0];

  NSDateFormatter *fmt = [NSDateFormatter new];
  fmt.dateFormat = @"dd/MM/yyyy";
  fmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"];

  for (int i=0; i<7; i++) {
    NSDate *dia = [greg dateByAddingUnit:NSCalendarUnitDay value:i toDate:segunda options:0];
    NSString *dataStr = [fmt stringFromDate:dia];

    NSMutableArray *periods = [NSMutableArray arrayWithCapacity:2];
    [periods addObject:[[Period alloc] initWithPeriod:@"lunch"  andMenu:@"" andCalories:@"0"]];
    [periods addObject:[[Period alloc] initWithPeriod:@"dinner" andMenu:@"" andCalories:@"0"]];

    Menu *m = [[Menu alloc] initWithDate:dataStr andPeriod:periods];
    [semana addObject:m];
  }
  return semana;
}

/// Junta o que veio do servidor (se existir) dentro do scaffold, casando por data.
static NSArray<Menu *> *MergeSemana(NSArray<Menu *> *scaffold, NSArray<Menu *> *server) {
  if (server.count == 0) return scaffold;

  NSMutableDictionary<NSString*, Menu*> *porData = [NSMutableDictionary dictionaryWithCapacity:server.count];
  for (Menu *m in server) { if (m.date.length) porData[m.date] = m; }

  NSMutableArray<Menu *> *saida = [NSMutableArray arrayWithCapacity:7];
  for (Menu *base in scaffold) {
    Menu *srv = porData[base.date];
    [saida addObject:(srv ?: base)];
  }
  return saida;
}

static UIColor *SecondaryLabelColor(void) {
  if (@available(iOS 13.0, *)) return [UIColor secondaryLabelColor];
  return [UIColor grayColor];
}

#pragma mark - Lifecycle

- (void)viewDidLoad {
  [super viewDidLoad];

  dataModel = [DataModel getInstance];
  oauth = [OAuthUSP sharedInstance];
  stringForLunch = [NSMutableString stringWithFormat:@""];

  [self setupDKScrollingTabController];
  self.tableView.contentInset = UIEdgeInsetsMake(8, 0, 0, 0);

  // Notifications
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeRestaurant:) name:@"DidChangeRestaurant" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveMenu:) name:@"DidReceiveMenu" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRecieveUserData:) name:@"DidRecieveUserData" object:nil];
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveBill:) name:@"DidReceiveBill" object:nil];

  // Filtro & Info
  [self setupFilterButton];
  [self setupInfoButton];
}

- (void)viewSafeAreaInsetsDidChange {
  [super viewSafeAreaInsetsDidChange];
  [self setupInfoButton];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  NSString *name = [[dataModel currentRestaurant] valueForKey:@"name"];
  [self.navigationItem setTitle:(name ?: @"")];

  // Busca o menu; UI já é robusta para estado vazio.
  [dataModel getMenu];
}

- (void)viewWillDisappear:(BOOL)animated {
  [super viewWillDisappear:animated];
  if ([self isMovingFromParentViewController]) {
    NSLog(@"View controller was popped");
  }
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - DKScrollingTabController

- (void)setupDKScrollingTabController {
  self.dateTabController = [[DKScrollingTabController alloc] init];
  [self addChildViewController:self.dateTabController];
  [self.dateTabController didMoveToParentViewController:self];
  [self.view addSubview:self.dateTabController.view];

  CGFloat topPadding = 0.0;
  if (@available(iOS 11.0, *)) {
    UIWindow *window = UIApplication.sharedApplication.windows.firstObject;
    topPadding = window.safeAreaInsets.top;
    self.dateTabController.view.frame = CGRectMake(0, topPadding+40., CGRectGetWidth(self.view.bounds), 56);
  } else {
    self.dateTabController.view.frame = CGRectMake(0, 40., CGRectGetWidth(self.view.bounds), 56);
  }

  if (@available(iOS 13.0, *)) {
    self.dateTabController.view.backgroundColor = [UIColor systemGroupedBackgroundColor];
  } else {
    self.dateTabController.view.backgroundColor = [UIColor lightTextColor];
  }

  if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat screenWidth  = [UIScreen mainScreen].bounds.size.width;
    if (screenHeight < screenWidth) screenHeight = screenWidth;

    if (screenHeight > 480 && screenHeight < 667) {
      self.dateTabController.buttonPadding = 4.2;
    } else if (screenHeight > 480 && screenHeight < 736) {
      self.dateTabController.buttonPadding = 8.2;
    } else if (screenHeight > 480 && screenHeight < 812) {
      self.dateTabController.buttonPadding = 11;
    } else if (screenHeight > 480 && screenHeight < 896) {
      self.dateTabController.buttonPadding = 8.2;
    } else if (screenHeight > 480) {
      self.dateTabController.buttonPadding = 11;
    } else {
      self.dateTabController.buttonPadding = 3.2;
    }
  }

  self.dateTabController.underlineIndicator = YES;
  self.dateTabController.underlineIndicatorColor = [UIColor colorNamed:@"usp_orange"];
  self.dateTabController.buttonsScrollView.showsHorizontalScrollIndicator = NO;
  self.dateTabController.selectedBackgroundColor = [UIColor clearColor];
  if (@available(iOS 13.0, *)) {
    self.dateTabController.selectedTextColor = [UIColor labelColor];
  } else {
    self.dateTabController.selectedTextColor = [UIColor blackColor];
  }
  self.dateTabController.unselectedTextColor = [UIColor grayColor];
  self.dateTabController.unselectedBackgroundColor = [UIColor clearColor];
  self.dateTabController.selection = @[@"           \n0",
                                       @"           \n0",
                                       @"           \n0",
                                       @"           \n0",
                                       @"           \n0",
                                       @"           \n0",
                                       @"           \n0"];
  self.dateTabController.delegate = self;
}

#pragma mark - Botões (Filtro / Info)

- (void)setupFilterButton {
  UIBarButtonItem *filterButton = [[UIBarButtonItem alloc] initWithImage:[UIImage systemImageNamed:@"slider.horizontal.3"] style:UIBarButtonItemStylePlain target:self action:@selector(showRestaurantsFilter)];
  self.navigationItem.rightBarButtonItem = filterButton;
}

- (void)setupInfoButton {
  CGFloat buttonSize = 40;
  CGFloat padding = 20;

  if (!self.infoButton) {
    self.infoButton = [UIButton buttonWithType:UIButtonTypeCustom];

    self.infoButton.layer.cornerRadius = buttonSize / 2;
    self.infoButton.backgroundColor = [UIColor colorNamed:@"usp_green"];
    self.infoButton.tintColor = [UIColor whiteColor];

    self.infoButton.layer.shadowColor = [UIColor blackColor].CGColor;
    self.infoButton.layer.shadowOpacity = 0.2;
    self.infoButton.layer.shadowOffset = CGSizeMake(0, 2);
    self.infoButton.layer.shadowRadius = 4;

    // OK usar contentEdgeInsets aqui (botão custom sem configuration)
    self.infoButton.contentEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);

    [self.infoButton addTarget:self action:@selector(showInfo) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.infoButton];
  }

  UIEdgeInsets safeAreaInsets = self.view.safeAreaInsets;
  CGFloat x = CGRectGetWidth(self.view.bounds) - buttonSize - safeAreaInsets.right - padding;
  CGFloat y = CGRectGetHeight(self.view.bounds) - buttonSize - safeAreaInsets.bottom - padding;
  self.infoButton.frame = CGRectMake(x, y, buttonSize, buttonSize);

  UIImage *infoImage = nil;
  if (@available(iOS 13.0, *)) {
    infoImage = [UIImage systemImageNamed:@"info.circle"];
  } else {
    infoImage = [UIImage imageNamed:@"info"];
  }
  [self.infoButton setImage:infoImage forState:UIControlStateNormal];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
  [super traitCollectionDidChange:previousTraitCollection];
  if (@available(iOS 13.0, *)) {
    if ([self.traitCollection userInterfaceStyle] != [previousTraitCollection userInterfaceStyle]) {
      [self setupInfoButton];
    }
  }
}

- (void)showRestaurantsFilter {
  UIViewController *filterVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RestaurantsFilterController"];
  filterVC.modalPresentationStyle = UIModalPresentationPageSheet;
  [self presentViewController:filterVC animated:YES completion:nil];
}

- (void)showInfo {
  [SVProgressHUD show];
  [self performSegueWithIdentifier:@"showInfo" sender:self];
}

#pragma mark - Semana / Tabs

- (void)setupWeekView:(NSArray<Menu *> *)weekMenu {
  // Define o dia atual da semana (segunda = 0)
  NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  gregorian.firstWeekday = 2;
  NSDateComponents *weekdayComponents = [gregorian components:NSCalendarUnitWeekday fromDate:[NSDate date]];
  NSInteger weekday = [weekdayComponents weekday] - 2;
  diaDaSemana = (weekday == -1) ? 6 : (int)weekday;

  NSArray *diasAbreviados = @[@"SEG", @"TER", @"QUA", @"QUI", @"SEX", @"SÁB", @"DOM"];

  NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
  inputFormatter.dateFormat = @"dd/MM/yyyy";
  inputFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"];

  NSDateFormatter *diaFormatter = [[NSDateFormatter alloc] init];
  diaFormatter.dateFormat = @"dd";
  diaFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"];

  for (int i = 0; i < 7; i++) {
    NSString *dateString = [[weekMenu objectAtIndex:i] date];
    NSDate *date = [inputFormatter dateFromString:dateString];
    if (!date) continue;

    NSString *diaNumero = [diaFormatter stringFromDate:date];
    NSString *titulo = [NSString stringWithFormat:@"%@\n%@", diasAbreviados[i], diaNumero];
    [self.dateTabController setButtonName:titulo atIndex:i];
  }

  [self.dateTabController.buttons enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
    UIButton *button = obj;
    button.titleLabel.numberOfLines = 2;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;

    NSString *titulo = button.titleLabel.text;
    NSArray *linhas = [titulo componentsSeparatedByString:@"\n"];
    if (linhas.count != 2) return;

    NSString *linha1 = linhas[0];
    NSString *linha2 = linhas[1];

    BOOL isSelecionado = (idx == diaDaSemana);

    UIFont *fontDia = isSelecionado ? [UIFont boldSystemFontOfSize:12] : [UIFont systemFontOfSize:12];
    UIFont *fontNumero = isSelecionado ? [UIFont boldSystemFontOfSize:14] : [UIFont systemFontOfSize:14];
    UIColor *corTexto = isSelecionado ? ([UIColor respondsToSelector:@selector(labelColor)] ? [UIColor labelColor] : [UIColor blackColor]) : [UIColor grayColor];

    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:titulo];
    [attributed addAttribute:NSFontAttributeName value:fontDia range:NSMakeRange(0, linha1.length)];
    [attributed addAttribute:NSFontAttributeName value:fontNumero range:NSMakeRange(linha1.length + 1, linha2.length)];
    [attributed addAttribute:NSForegroundColorAttributeName value:corTexto range:NSMakeRange(0, titulo.length)];

    [button setTitle:@"" forState:UIControlStateNormal];
    [button setAttributedTitle:attributed forState:UIControlStateNormal];
  }];

  self.dateTabController.buttonPadding = 12;
  self.dateTabController.underlineIndicator = YES;
  self.dateTabController.underlineIndicatorColor = [UIColor colorNamed:@"usp_orange"];
  self.dateTabController.delegate = self;

  [self.dateTabController selectButtonWithIndex:diaDaSemana];
}

- (void)setupDayLabel:(int)dia {
  if (menuArray.count == 0 || dia < 0 || dia >= menuArray.count) return;

  NSString *diaSemana = @"";
  switch (dia) {
    case 0: diaSemana = @"Segunda-feira"; break;
    case 1: diaSemana = @"Terça-feira";   break;
    case 2: diaSemana = @"Quarta-feira";  break;
    case 3: diaSemana = @"Quinta-feira";  break;
    case 4: diaSemana = @"Sexta-feira";   break;
    case 5: diaSemana = @"Sábado";        break;
    case 6: diaSemana = @"Domingo";       break;
    default: break;
  }

  NSString *strData = [NSString stringWithFormat:@"%@", [[menuArray objectAtIndex:dia] date]];
  if (strData.length >= 10) {
    NSString *strDay   = [strData substringToIndex:2];
    NSString *strMonth = [self dayToString:[NSString stringWithFormat:@"%@", [[strData substringFromIndex:3] substringToIndex:2]]];
    NSString *strYear  = [NSString stringWithFormat:@"%@", [strData substringFromIndex:6]];
    [diaDaSemanaLabel setText:[NSString stringWithFormat:@"%@, %@ de %@ de %@", diaSemana, strDay, strMonth, strYear]];
  } else {
    [diaDaSemanaLabel setText:diaSemana];
  }

  [[self tableView] reloadData];
}

- (NSString *)dayToString:(NSString *)strMonth {
  switch ([strMonth intValue]) {
    case 1:  return @"Janeiro";
    case 2:  return @"Fevereiro";
    case 3:  return @"Março";
    case 4:  return @"Abril";
    case 5:  return @"Maio";
    case 6:  return @"Junho";
    case 7:  return @"Julho";
    case 8:  return @"Agosto";
    case 9:  return @"Setembro";
    case 10: return @"Outubro";
    case 11: return @"Novembro";
    case 12: return @"Dezembro";
    default: return @"";
  }
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  BOOL temObs = (dataModel.observation.length > 0);
  return 2 + (temObs ? 1 : 0); // 0=Almoço, 1=Jantar, 2=Observação (opcional)
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  return 26;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  CGFloat height = 26, imageSize = 18, padding = 0;

  UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, height)];
  view.backgroundColor = [UIColor clearColor];

  UILabel *label = [[UILabel alloc] init];
  label.font = [UIFont boldSystemFontOfSize:15];
  label.textColor = [UIColor grayColor];

  UIImageView *imageView = nil;
  switch (section) {
    case 0: label.text = @"ALMOÇO"; imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"almoco"]]; break;
    case 1: label.text = @"JANTAR"; imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jantar"]]; break;
    case 2: label.text = @"OBSERVAÇÃO"; break;
    default: break;
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
  if (!menu || section > 1 || menu.period.count <= section) return @"";
  NSString *kcal = [menu.period[section] calories];
  return (kcal.length && ![kcal isEqualToString:@"0"])
  ? [NSString stringWithFormat:@"Valor calórico para uma refeição: %@ kcal", kcal]
  : @"";
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MenuCell" forIndexPath:indexPath];
  self.tableView.estimatedRowHeight = 150.;

  if (!menu) { cell.textLabel.text = @""; return cell; }

  if (indexPath.section <= 1) {
    // 0 = almoço, 1 = jantar
    if (menu.period.count <= indexPath.section) {
      cell.textLabel.text = @"Sem cardápio publicado";
      cell.textLabel.textColor = SecondaryLabelColor();
      cell.textLabel.font = [UIFont systemFontOfSize:15];
      cell.backgroundColor = [UIColor systemBackgroundColor];
      return cell;
    }
    Period *p = menu.period[indexPath.section];
    NSString *texto = (p.menu.length ? p.menu : @"Sem cardápio publicado");
    cell.textLabel.text = texto;
    cell.textLabel.textColor = (p.menu.length ? ([UIColor respondsToSelector:@selector(labelColor)] ? [UIColor labelColor] : [UIColor blackColor]) : SecondaryLabelColor());
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.backgroundColor = [UIColor systemBackgroundColor];
  } else {
    // Observação (opcional)
    cell.textLabel.text = dataModel.observation ?: @"";
    cell.textLabel.textColor = [UIColor grayColor];
    cell.textLabel.font = [UIFont systemFontOfSize:14];
    cell.backgroundColor = [UIColor systemGroupedBackgroundColor];
  }
  return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  return UITableViewAutomaticDimension;
}

#pragma mark - Ações

- (IBAction)showRestaurantSelector:(id)sender {
  [self showRestaurantsFilter];
}

- (IBAction)showCredits:(id)sender {
  creditsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"creditsViewController"];

  if (![oauth isLoggedIn]) {
    loginViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"loginWebViewController"];
    [self presentViewController:loginViewController animated:YES completion:nil];
  } else {
    [dataModel getCreditoRUCard];
    CreditsNavigationViewController *navController = [self.storyboard instantiateViewControllerWithIdentifier:@"navController"];
    [self presentViewController:navController animated:YES completion:nil];
  }
}

#pragma mark - DKScrollingTabControllerDelegate

- (void)ScrollingTabController:(DKScrollingTabController *)controller selection:(NSUInteger)selection {
  if (selection >= menuArray.count) return;

  menu = [menuArray objectAtIndex:selection];
  [self setupDayLabel:(int)selection];

  // Atualiza o estilo dos botões conforme seleção
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
    UIColor *corTexto = isSelecionado ? ([UIColor respondsToSelector:@selector(labelColor)] ? [UIColor labelColor] : [UIColor blackColor]) : [UIColor grayColor];

    NSMutableAttributedString *attributed = [[NSMutableAttributedString alloc] initWithString:titulo];
    [attributed addAttribute:NSFontAttributeName value:fontDia range:NSMakeRange(0, linha1.length)];
    [attributed addAttribute:NSFontAttributeName value:fontNumero range:NSMakeRange(linha1.length + 1, linha2.length)];
    [attributed addAttribute:NSForegroundColorAttributeName value:corTexto range:NSMakeRange(0, titulo.length)];

    [button setAttributedTitle:attributed forState:UIControlStateNormal];
  }
}

#pragma mark - Model Notifications

- (void)didChangeRestaurant:(NSNotification *)notification {
  [dataModel getMenu];
  [self.navigationItem setTitle:[[dataModel currentRestaurant] valueForKey:@"name"]];
}

// Sempre monta 7 dias (com ou sem dados do servidor)
- (void)didReceiveMenu:(NSNotification *)notification {
  NSArray<Menu *> *serverWeek = [dataModel menuArray];
  NSArray<Menu *> *scaffold   = ScaffoldSemanaVazia();
  menuArray = [[NSMutableArray alloc] initWithArray:MergeSemana(scaffold, serverWeek)];

  [self setupWeekView:menuArray];

  menu = [menuArray objectAtIndex:diaDaSemana];
  [self setupDayLabel:diaDaSemana];

  if (serverWeek.count == 0) {
    [SVProgressHUD showInfoWithStatus:@"Sem cardápio publicado para essa semana."];
  }
  stringForLunch = [NSMutableString stringWithFormat:@"ALMOÇO"];
  [self.tableView reloadData];
}

- (void)didRecieveUserData:(NSNotification *)notification {
  [self presentViewController:creditsViewController animated:YES completion:nil];
}

- (void)didReceiveBill:(NSNotification *)notification {
  boletoViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"boletoViewController"];
  [self presentViewController:boletoViewController animated:YES completion:nil];
}

#pragma mark - Fechamento RU

- (BOOL)isClosed {
  if (!menu || menu.period.count < 2) return NO;

  NSString *strLunch  = [[[[NSString stringWithFormat:@"%@", [menu.period[0] menu]] capitalizedString] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""];
  NSString *strDinner = [[[[NSString stringWithFormat:@"%@", [menu.period[1] menu]] capitalizedString] stringByReplacingOccurrencesOfString:@" " withString:@""] stringByReplacingOccurrencesOfString:@"." withString:@""];

  if ([strLunch isEqualToString:@"Fechado"] || [strLunch isEqualToString:@""]) {
    if ([strDinner isEqualToString:@"Fechado"] || [strDinner isEqualToString:@""]) {
      return YES;
    }
  }
  return NO;
}

#pragma mark - SWRevealViewControllerDelegate

- (void)revealController:(SWRevealViewController *)revealController willMoveToPosition:(FrontViewPosition)position {
  if (position == 2) {
    [self.infoButton setHidden:YES];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
      self.navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
  } else {
    [self.infoButton setHidden:NO];
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
      self.navigationController.interactivePopGestureRecognizer.enabled = YES;
    }
  }
}

@end
