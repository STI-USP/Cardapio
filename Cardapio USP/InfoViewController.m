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
#import "DetailCell.h"
#import "ImageCell.h"
#import "PreferredCell.h"
#import "ThumbnailViewImageProxy.h"
#import "MapViewController.h"
#import "TelephoneUtils.h"
#import "SVProgressHUD.h"

#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>


#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


@interface InfoViewController () {
  DataModel *dataModel;
  PreferredCell *prefCell;
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
  
  self.tableView.estimatedRowHeight = 44.0;
  self.tableView.rowHeight = UITableViewAutomaticDimension;
  [[UITableViewCell appearance] setTintColor:[UIColor colorNamed:@"usp_green"]];
  dataModel = [DataModel getInstance];
  
  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRestaurants) name:@"DidReceiveRestaurants" object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewDidAppear:YES];
  if ([[dataModel restaurants] count] == 0) {
    [dataModel getRestaurantList];
  }
  
  _restaurantDc = [dataModel currentRestaurant];
  
  
  
  [self setHeaderView];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  switch (section) {
    case 0:
      return 5;
      break;
    case 1:
      return 1;
      break;
      
    default:
      return 0;
      break;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
    return UITableViewAutomaticDimension;
  } else {
    return [self heightForBasicCellAtIndexPath:indexPath];
  }
}

- (CGFloat)heightForBasicCellAtIndexPath:(NSIndexPath *)indexPath {
  static DetailCell *sizingCell = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    sizingCell = [self.tableView dequeueReusableCellWithIdentifier:@"RestaurantDetailCell"];
  });
  
  [self configureBasicCell:sizingCell atIndexPath:indexPath];
  
  if ([indexPath section] == 0) {
    int cellHeight = (int) [self calculateHeightForConfiguredSizingCell:sizingCell];
    if (cellHeight < 44) {
      return 44;
    } else {
      return cellHeight;
    }
  } else {
    return 44;
  }
}


- (CGFloat)calculateHeightForConfiguredSizingCell:(DetailCell *)sizingCell {
  
  [sizingCell setNeedsUpdateConstraints];
  [sizingCell updateConstraintsIfNeeded];
  
  sizingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tableView.bounds), CGRectGetHeight(sizingCell.bounds));
  
  [sizingCell setNeedsLayout];
  [sizingCell layoutIfNeeded];
  //CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
  CGSize size = [sizingCell.subtitle systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
  return size.height + 20.; // Add 1.0f for the cell separator height
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  return [self basicCellAtIndexPath:indexPath];
}


- (UITableViewCell *)basicCellAtIndexPath:(NSIndexPath *)indexPath {
  
  DetailCell *aCell = nil;
  
  switch (indexPath.section) {
    case 0: {
      switch ([indexPath row]) {
        case 1:
          aCell = [self.tableView dequeueReusableCellWithIdentifier:@"ContactCell" forIndexPath:indexPath];
          break;
          
        default:
          aCell = [self.tableView dequeueReusableCellWithIdentifier:@"RestaurantDetailCell" forIndexPath:indexPath];
          break;
      }
    }
      break;
    case 1: {
      if ([[_restaurantDc valueForKey:@"id"] isEqualToString:[dataModel.preferredRestaurant valueForKey:@"id"]]) {
        aCell = [self.tableView dequeueReusableCellWithIdentifier:@"ResetPreferredCell" forIndexPath:indexPath];
      } else {
        aCell = [self.tableView dequeueReusableCellWithIdentifier:@"SetPreferredCell" forIndexPath:indexPath];
      }
    }
      break;
      
    default:
      break;
  }
  
  [aCell.title setNumberOfLines:0];
  [aCell.title setLineBreakMode:NSLineBreakByWordWrapping];
  [aCell.title setTranslatesAutoresizingMaskIntoConstraints:NO];
  
  [aCell.subtitle setNumberOfLines:0];
  [aCell.subtitle setLineBreakMode:NSLineBreakByWordWrapping];
  [aCell.subtitle setTranslatesAutoresizingMaskIntoConstraints:NO];
  
  
  [self configureBasicCell:aCell atIndexPath:indexPath];
  
  [aCell updateConstraintsIfNeeded];
  
  return aCell;
}

- (void)configureBasicCell:(DetailCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  // Configure the cell...
  
  if ([indexPath section] == 0) {
    switch ([indexPath row]) {
      case 0: {
        [cell.title setText: @"Endereço"];
        [cell.subtitle setText: [_restaurantDc valueForKey:@"address"]];
        break;
      }
      case 1: {
        [cell.title setText: @"Telefone(s)"];
        NSString *telephones = [self formattedTelephones];
        [cell.subtitle setText: telephones];
        
        UIButton *button = [self createPhoneButton];
        cell.accessoryView = button;
        break;
      }
      case 2: {
        [cell.title setText: @"Horários"];
        NSString *workingHours = [self formattedWorkingHours];
        [cell.subtitle setText: workingHours];
        break;
      }
      case 3: {
        [cell.title setText: @"Preços"];
        NSString *prices = [self formattedPrices];
        [cell.subtitle setText: prices];
        break;
      }
      case 4: {
        [self configureCashierCell:cell];
        break;
      }
      default:
        break;
    }
  }
}

- (NSString *)formattedTelephones {
  NSMutableString *telephones = [[NSMutableString alloc] init];
  
  id phones = [_restaurantDc valueForKey:@"phones"];
  if ([phones isKindOfClass:[NSString class]]) {
    [telephones appendString:phones];
  } else {
    for (NSString *tel in phones) {
      [telephones appendFormat:@"%@\n", tel];
    }
    if (telephones.length > 0) {
      [telephones deleteCharactersInRange:NSMakeRange(telephones.length - 1, 1)]; // Remove trailing newline
    }
  }
  
  return telephones;
}

- (UIButton *)createPhoneButton {
  UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  button.frame = CGRectMake(0.0, 0.0, 25., 30.);
  [button setImage:[UIImage imageNamed:@"phone.png"] forState:UIControlStateNormal];
  [button setTintColor:[UIColor colorNamed:@"usp_green"]];
  [button addTarget:self action:@selector(callButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
  return button;
}

- (NSString *)formattedWorkingHours {
  NSMutableString *workingHours = [[NSMutableString alloc] init];
  
  // Segunda a sexta
  if ([self hasMealsForDay:@"weekdays"]) {
    [workingHours appendString:@"Segunda à sexta-feira \n"];
    [self appendMealPeriod:@"breakfast" fromDays:@"weekdays" toString:workingHours withLabel:@"Café da manhã"];
    [self appendMealPeriod:@"lunch" fromDays:@"weekdays" toString:workingHours withLabel:@"Almoço"];
    [self appendMealPeriod:@"dinner" fromDays:@"weekdays" toString:workingHours withLabel:@"Jantar"];
  }
  
  // Sábado
  if ([self hasMealsForDay:@"saturday"]) {
    [workingHours appendString:@"\nSábado \n"];
    [self appendMealPeriod:@"breakfast" fromDays:@"saturday" toString:workingHours withLabel:@"Café da manhã"];
    [self appendMealPeriod:@"lunch" fromDays:@"saturday" toString:workingHours withLabel:@"Almoço"];
    [self appendMealPeriod:@"dinner" fromDays:@"saturday" toString:workingHours withLabel:@"Jantar"];
  }
  
  // Domingo
  if ([self hasMealsForDay:@"sunday"]) {
    [workingHours appendString:@"\nDomingo \n"];
    [self appendMealPeriod:@"breakfast" fromDays:@"sunday" toString:workingHours withLabel:@"Café da manhã"];
    [self appendMealPeriod:@"lunch" fromDays:@"sunday" toString:workingHours withLabel:@"Almoço"];
    [self appendMealPeriod:@"dinner" fromDays:@"sunday" toString:workingHours withLabel:@"Jantar"];
  }
  
  return workingHours;
}

- (void)appendMealPeriod:(NSString *)period fromDays:(NSString *)days toString:(NSMutableString *)string withLabel:(NSString *)label {
  NSString *mealTime = [[[_restaurantDc valueForKey:@"workinghours"] valueForKey:days] valueForKey:period];
  if (mealTime && ![mealTime isEqualToString:@""]) {
    [string appendFormat:@"%@: %@\n", label, mealTime];
  }
}

- (BOOL)hasMealsForDay:(NSString *)day {
  NSDictionary *meals = [[_restaurantDc valueForKey:@"workinghours"] valueForKey:day];
  return (meals &&
          (![self isEmptyString:[meals valueForKey:@"breakfast"]] ||
           ![self isEmptyString:[meals valueForKey:@"lunch"]] ||
           ![self isEmptyString:[meals valueForKey:@"dinner"]]));
}

- (BOOL)isEmptyString:(NSString *)string {
  return (string == nil || [string isEqualToString:@""]);
}

- (NSString *)formattedPrices {
  NSMutableString *prices = [[NSMutableString alloc] init];
  if (([[_restaurantDc valueForKey:@"cashiers"] isKindOfClass:[NSArray class]]) && ([[_restaurantDc valueForKey:@"cashiers"] count] > 0)) {
    [prices appendFormat:@"Aluno: R$ %@\n", [[[[[_restaurantDc valueForKey:@"cashiers"] objectAtIndex:0] valueForKey:@"prices"] valueForKey:@"students"] valueForKey:@"lunch"]];
    [prices appendFormat:@"Especial: R$ %@\n", [[[[[_restaurantDc valueForKey:@"cashiers"] objectAtIndex:0] valueForKey:@"prices"] valueForKey:@"special"] valueForKey:@"lunch"]];
    [prices appendFormat:@"Visitante autorizado: R$ %@", [[[[[_restaurantDc valueForKey:@"cashiers"] objectAtIndex:0] valueForKey:@"prices"] valueForKey:@"visiting"] valueForKey:@"lunch"]];
  } else {
    [prices appendString:@"Aluno: R$ 2.00\n"];
    [prices appendString:@"Especial: R$ 10.00\n"];
    [prices appendString:@"Visitante autorizado: R$ 15.00"];
  }
  return prices;
}

- (void)configureCashierCell:(DetailCell *)cell {
  NSArray *cashiers = [_restaurantDc valueForKey:@"cashiers"];
  if ([cashiers count] > 0) {
    if ([cashiers count] == 1) {
      [cell.title setText: @"Ponto de venda"];
      [cell.subtitle setText:[NSString stringWithFormat:@"%@ \n\n%@", [cashiers[0] valueForKey:@"address"], [cashiers[0] valueForKey:@"workinghours"]]];
    } else {
      NSString *rest1 = [NSString stringWithFormat:@"\u2022 %@ \n\n%@", [cashiers[0] valueForKey:@"address"], [cashiers[0] valueForKey:@"workinghours"]];
      NSString *rest2 = [NSString stringWithFormat:@"\u2022 %@ \n\n%@", [cashiers[1] valueForKey:@"address"], [cashiers[1] valueForKey:@"workinghours"]];
      [cell.title setText:@"Pontos de venda"];
      [cell.subtitle setText:[NSString stringWithFormat:@"%@ \n\n\n %@", rest1, rest2]];
    }
  } else {
    [cell.subtitle setText:@""];
    [cell.subtitle setHidden:YES];
  }
}


/// Trata telefone
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0 && indexPath.row == 1) {
    if ([[UIDevice currentDevice].model isEqualToString:@"iPhone"]) {
      
      UIAlertController *telAlert = [UIAlertController alertControllerWithTitle:@"Ligar para restaurante" message:@"" preferredStyle:UIAlertControllerStyleActionSheet];
      
      //telefones da biblioteca
      UIAlertAction *telButton = [UIAlertAction actionWithTitle:[TelephoneUtils telephoneWithCarrierFromString:[_restaurantDc objectForKey:@"phones"]] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [TelephoneUtils dialToTelephone:[TelephoneUtils telephoneWithCarrierFromString:[self->_restaurantDc objectForKey:@"phones"]]];
      }];
      [telAlert addAction:telButton];
      
      //cancelar
      UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleCancel handler:nil];
      [telAlert addAction:cancel];
      
      [self presentViewController:telAlert animated:YES completion:nil];
    }
  }
}

- (void)callButtonTapped:(id)sender event:(id)event {
  NSSet *touches = [event allTouches];
  UITouch *touch = [touches anyObject];
  CGPoint currentTouchPosition = [touch locationInView:self.tableView];
  NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
  
  if (indexPath != nil)
    [self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
}


- (void)setHeaderView{
  
  //TableView Header
  UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.width*9/16 +30)];
  //[headerView setBackgroundColor:[UIColor whiteColor]];
  
  //imagem do restaurante
  UIView *imageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, self.tableView.frame.size.width*9/16 -10)];
  ThumbnailViewImageProxy *imageViewProxy = [[ThumbnailViewImageProxy alloc] init];
  imageViewProxy.aspect = ThumbnailAspectZoom;
  imageViewProxy.hasBorders = NO;
  
  NSString *photoUrl = [_restaurantDc valueForKey:@"photourl"];
  if (photoUrl.length != 0) {
    imageViewProxy.imagePath = photoUrl;
  }
  
  imageView = imageViewProxy;
  
  [imageViewProxy getImageWithCompletionHandler:^(UIImage *image, NSError *error) {
    UIImageView *viewForImage = [[UIImageView alloc] initWithImage:imageViewProxy.image];
    [viewForImage setFrame:CGRectMake(0., 0., self.tableView.frame.size.width, self.tableView.frame.size.width*9/16)];
    [viewForImage setContentMode: UIViewContentModeScaleToFill];
    [imageView addSubview:viewForImage];
  }];
  
  CATextLayer *border = [[CATextLayer alloc] init];
  border.foregroundColor = CFBridgingRetain((__bridge id)[UIColor blackColor].CGColor);
  border.alignmentMode = kCAAlignmentCenter;
  border.font = (__bridge CFTypeRef)(@"HelveticaNeue-Bold");
  border.fontSize = 14.0;
  border.wrapped = YES;
  border.frame = CGRectMake(11.0, 11.0, self.tableView.frame.size.width - 11., 40.0);
  border.string = [_restaurantDc valueForKey:@"name"];
  border.name = @"border";
  [imageView.layer addSublayer:border];
  
  CATextLayer *label = [[CATextLayer alloc] init];
  label.foregroundColor = CFBridgingRetain((__bridge id)[UIColor whiteColor].CGColor);
  label.alignmentMode = kCAAlignmentCenter;
  label.font = (__bridge CFTypeRef)(@"HelveticaNeue-Bold");
  label.fontSize = 14.0;
  label.wrapped = YES;
  label.frame = CGRectMake(10.0, 10.0, self.tableView.frame.size.width - 10., 40.0);
  label.string = [_restaurantDc valueForKey:@"name"];
  label.name = @"text";
  [imageView.layer addSublayer:label];
  [headerView addSubview:imageView];
  
  //View para o mapa
  UIButton *mapButton = [self createMapButton];
  [headerView addSubview:mapButton];
  
  [self.tableView setTableHeaderView: headerView];
  [SVProgressHUD dismiss];
}

// Função para criar o botão do mapa
- (UIButton *)createMapButton {
  // Inicializa o botão com estilo personalizado
  UIButton *mapButton = [UIButton buttonWithType:UIButtonTypeCustom];
  
  // Define o frame do botão
  mapButton.frame = CGRectMake(self.tableView.frame.size.width - 120,
                               self.tableView.frame.size.width * 9 / 16 - 50,
                               80, 80);
  
  // Configurações de layout
  mapButton.layer.cornerRadius = 10;
  mapButton.layer.masksToBounds = YES;
  
  // Cria e configura a UIImageView para ser adicionada ao botão
  UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"mapa"]];
  imageView.contentMode = UIViewContentModeScaleAspectFill;
  imageView.clipsToBounds = YES; // Para garantir que a imagem não ultrapasse as bordas
  
  // Define o frame da imagem para ocupar todo o botão
  imageView.frame = mapButton.bounds;
  
  // Desabilita a interação da imagem para não interferir no toque do botão
  imageView.userInteractionEnabled = NO;
  
  // Adiciona a UIImageView ao botão
  [mapButton addSubview:imageView];
  
  // Adiciona ação para o evento de toque no botão
  [mapButton addTarget:self action:@selector(showMap) forControlEvents:UIControlEventTouchUpInside];
  
  return mapButton;
}


#pragma mark Actions

//- (void)showMap {
//  MapViewController *mapController = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
//  [self.navigationController pushViewController:mapController animated:YES];
//}

- (void)showMap {
  UIAlertController *alert = [UIAlertController alertControllerWithTitle:[_restaurantDc valueForKey:@"name"]  message:[_restaurantDc valueForKey:@"address"] preferredStyle:UIAlertControllerStyleActionSheet];
  
  
  //Maps
  UIAlertAction *mapsButton = [UIAlertAction actionWithTitle:@"Maps" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    
    CLLocationCoordinate2D restaurantLocation = CLLocationCoordinate2DMake([[self->_restaurantDc valueForKey:@"latitude"] doubleValue], [[self->_restaurantDc valueForKey:@"longitude"] doubleValue]);
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithCoordinate:restaurantLocation addressDictionary:nil];
    MKMapItem *mapItem = [[MKMapItem alloc] initWithPlacemark:placemark];
    
    [mapItem setName:[self->_restaurantDc valueForKey:@"name"]];
    NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeDriving};
    [mapItem openInMapsWithLaunchOptions:options];
  }];
  if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"maps://"]])
    [alert addAction:mapsButton];
  
  //Google Maps
  UIAlertAction *googleMapsButton = [UIAlertAction actionWithTitle:@"Google Maps" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?daddr=%f,%f", [[self->_restaurantDc valueForKey:@"latitude"] doubleValue], [[self->_restaurantDc valueForKey:@"longitude"] doubleValue]]] options:@{} completionHandler:nil];
  }];
  if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]])
    [alert addAction:googleMapsButton];
  
  //Waze
  UIAlertAction *wazeButton = [UIAlertAction actionWithTitle:@"Waze" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"waze://?ll=%f,%f&navigate=yes", [[self->_restaurantDc valueForKey:@"latitude"] doubleValue], [[self->_restaurantDc valueForKey:@"longitude"] doubleValue]]] options:@{} completionHandler:nil];
    
  }];
  
  if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"waze://"]]) {
    [alert addAction:wazeButton];
  }
  
  [alert addAction:[UIAlertAction actionWithTitle:@"Cancelar" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
    // Cancel button tappped.
  }]];
  
  [self presentViewController:alert animated:YES completion:nil];
  
}


- (void)doneButtonTapped:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveRestaurants {
  [self.tableView reloadData];
}

- (void)setAsPreferred:(id)sender {
  [dataModel setPreferredRestaurant:_restaurantDc];
  [self.tableView reloadData];
}

- (void)resetPreferred:(id)sender {
  [dataModel setPreferredRestaurant:nil];
  [self.tableView reloadData];
}

@end
