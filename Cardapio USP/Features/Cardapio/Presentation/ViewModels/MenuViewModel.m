//
//  MenuViewModel.m
//  Cardapio USP
//
//  Created by Vagner Machado on 14/08/25.
//  Copyright © 2025 USP. All rights reserved.
//

#import "MenuViewModel.h"
#import "DataModel.h"
#import "Menu.h"
#import "Period.h"

@interface MenuViewModel ()
@property (nonatomic, strong) DataModel *dataModel;
@property (nonatomic, strong, readwrite) NSArray<Menu *> *week;
@property (nonatomic, strong, readwrite) NSArray<NSString *> *tabTitles;
@property (nonatomic, copy,   readwrite) NSString *dayHeaderTitle;
@property (nonatomic, copy,   readwrite) NSString *observation;
@end

@implementation MenuViewModel

- (instancetype)initWithDataModel:(DataModel *)dataModel {
  if (self = [super init]) {
    _dataModel = dataModel;
    _week = @[];
    _tabTitles = @[];
    _selectedIndex = [self currentWeekdayIndex];
    _observation = @"";

    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(didReceiveMenu:) name:@"DidReceiveMenu" object:nil];
    [nc addObserver:self selector:@selector(didChangeRestaurant:) name:@"DidChangeRestaurant" object:nil];
  }
  return self;
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)reloadMenus {
  [self.dataModel getMenu];
}

#pragma mark - Notifications

- (void)didChangeRestaurant:(NSNotification *)n {
  [self reloadMenus];
}

- (void)didReceiveMenu:(NSNotification *)n {
  NSArray<Menu *> *serverWeek = [self.dataModel menuArray] ?: @[];
  NSArray<Menu *> *scaffold   = [self scaffoldEmptyWeek];
  self.week = [self mergeWeek:scaffold withServer:serverWeek];

  self.observation = self.dataModel.observation ?: @"";
  self.tabTitles = [self buildTabTitlesFromWeek:self.week];
  self.selectedIndex = [self currentWeekdayIndex];
  self.dayHeaderTitle = [self buildDayHeaderForIndex:self.selectedIndex];

  if ([self.delegate respondsToSelector:@selector(menuViewModelDidUpdateWeek:)]) {
    [self.delegate menuViewModelDidUpdateWeek:self];
  }
  if ([self.delegate respondsToSelector:@selector(menuViewModelDidUpdateDay:)]) {
    [self.delegate menuViewModelDidUpdateDay:self];
  }
  if (serverWeek.count == 0) {
    if ([self.delegate respondsToSelector:@selector(menuViewModelNoServerMenu:)]) {
      [self.delegate menuViewModelNoServerMenu:self];
    }
  }
}

#pragma mark - Public

- (NSInteger)numberOfSections {
  return 2 + (self.observation.length > 0 ? 1 : 0);
}

- (NSString *)textForSection:(NSInteger)section {
  if (section == 2) {
    return self.observation ?: @"";
  }
  Menu *m = [self safeMenuAt:self.selectedIndex];
  if (!m || [m.period count] <= section) return @"Sem cardápio publicado";

  Period *p = (Period *)[m.period objectAtIndex:section];
  return (p.menu.length ? p.menu : @"Sem cardápio publicado");
}

- (NSString *)footerForSection:(NSInteger)section {
  if (section > 1) return @"";
  Menu *m = [self safeMenuAt:self.selectedIndex];
  if (!m || m.period.count <= section) return @"";

  Period *p = (Period *)[m.period objectAtIndex:section];
  NSString *kcal = p.calories ?: @"";
  if (kcal.length == 0 || [kcal isEqualToString:@"0"]) return @"";
  return [NSString stringWithFormat:@"Valor calórico para uma refeição: %@ kcal", kcal];
}

- (BOOL)isClosed {
  Menu *m = [self safeMenuAt:self.selectedIndex];
  if (!m || m.period.count < 2) return NO;

  Period *lunchP  = (m.period.count > 0) ? (Period *)m.period[0] : nil;
  Period *dinnerP = (m.period.count > 1) ? (Period *)m.period[1] : nil;

  NSString* (^normalize)(NSString *) = ^NSString* (NSString *s) {
    NSString *cap = [[s ?: @"" capitalizedString] stringByReplacingOccurrencesOfString:@" " withString:@""];
    return [cap stringByReplacingOccurrencesOfString:@"." withString:@""];
  };

  NSString *lunch  = normalize(lunchP.menu);
  NSString *dinner = normalize(dinnerP.menu);

  BOOL closedLunch  = (lunch.length == 0 || [lunch isEqualToString:@"Fechado"]);
  BOOL closedDinner = (dinner.length == 0 || [dinner isEqualToString:@"Fechado"]);
  return (closedLunch && closedDinner);
}

#pragma mark - Selected index

- (void)setSelectedIndex:(NSInteger)selectedIndex {
  if (_selectedIndex == selectedIndex) return;
  _selectedIndex = MAX(0, MIN(6, selectedIndex));
  self.dayHeaderTitle = [self buildDayHeaderForIndex:_selectedIndex];

  if ([self.delegate respondsToSelector:@selector(menuViewModelDidUpdateDay:)]) {
    [self.delegate menuViewModelDidUpdateDay:self];
  }
}

#pragma mark - Helpers (week building)

- (NSArray<Menu *> *)scaffoldEmptyWeek {
  NSMutableArray *semana = [NSMutableArray arrayWithCapacity:7];
  NSCalendar *greg = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  greg.firstWeekday = 2; // segunda
  NSDate *hoje = [NSDate date];

  NSDateComponents *comps = [greg components:(NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitWeekday)
                                    fromDate:hoje];
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

- (NSArray<Menu *> *)mergeWeek:(NSArray<Menu *> *)scaffold withServer:(NSArray<Menu *> *)server {
  if (server.count == 0) return scaffold;

  NSMutableDictionary<NSString*, Menu*> *byDate = [NSMutableDictionary dictionaryWithCapacity:server.count];
  for (Menu *m in server) { if (m.date.length) byDate[m.date] = m; }

  NSMutableArray<Menu *> *out = [NSMutableArray arrayWithCapacity:7];
  for (Menu *base in scaffold) {
    Menu *srv = byDate[base.date];
    [out addObject:(srv ?: base)];
  }
  return out;
}

- (NSArray<NSString *> *)buildTabTitlesFromWeek:(NSArray<Menu *> *)week {
  NSArray *dias = @[@"SEG",@"TER",@"QUA",@"QUI",@"SEX",@"SÁB",@"DOM"];
  NSDateFormatter *inFmt = [NSDateFormatter new];
  inFmt.dateFormat = @"dd/MM/yyyy";
  inFmt.locale = [[NSLocale alloc] initWithLocaleIdentifier:@"pt_BR"];

  NSDateFormatter *dayFmt = [NSDateFormatter new];
  dayFmt.dateFormat = @"dd";
  dayFmt.locale = inFmt.locale;

  NSMutableArray *titles = [NSMutableArray arrayWithCapacity:7];
  for (NSInteger i=0; i<7; i++) {
    NSString *d = (i < week.count ? week[i].date : @"");
    NSDate *date = [inFmt dateFromString:d];
    NSString *num = date ? [dayFmt stringFromDate:date] : @"";
    [titles addObject:[NSString stringWithFormat:@"%@\n%@", dias[i], num]];
  }
  return titles;
}

- (NSString *)buildDayHeaderForIndex:(NSInteger)idx {
  if (idx < 0 || idx >= self.week.count) return @"";
  NSString *strDate = self.week[idx].date ?: @"";
  if (strDate.length < 10) return @"";

  NSInteger day = [[strDate substringToIndex:2] integerValue];
  NSInteger month = [[strDate substringWithRange:NSMakeRange(3, 2)] integerValue];
  NSString *year = [strDate substringFromIndex:6];

  NSArray *dias = @[@"Segunda-feira",@"Terça-feira",@"Quarta-feira",@"Quinta-feira",@"Sexta-feira",@"Sábado",@"Domingo"];
  NSString *diaSemana = (idx >=0 && idx < dias.count) ? dias[idx] : @"";

  NSString *mes = [self monthToString:month];
  return [NSString stringWithFormat:@"%@, %ld de %@ de %@", diaSemana, (long)day, mes, year];
}

- (NSString *)monthToString:(NSInteger)month {
  switch (month) {
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

- (NSInteger)currentWeekdayIndex {
  NSCalendar *greg = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
  greg.firstWeekday = 2; // segunda
  NSDateComponents *wd = [greg components:NSCalendarUnitWeekday fromDate:[NSDate date]];
  NSInteger idx = wd.weekday - 2; // seg=0
  return (idx == -1) ? 6 : idx;
}

- (Menu *)safeMenuAt:(NSInteger)idx {
  if (idx < 0 || idx >= self.week.count) return nil;
  return self.week[idx];
}

@end
