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

  dataModel = [DataModel getInstance];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRestaurants) name:@"DidReceiveRestaurants" object:nil];
}

-(void)viewWillAppear:(BOOL)animated {
  [super viewDidAppear:YES];
  if ([[dataModel restaurants] count] == 0) {
    [dataModel getRestaurantList];
  } else {
    //[self setupView];
  }
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
      return 6;
      break;
    case 1:
      return 1;
      break;

    default:
      return 0;
      break;
  }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  
  UIView *imageView = [[UIView alloc] initWithFrame:CGRectMake(0., 0., self.tableView.frame.size.width, 80.)];
  if (section == 0) {
    ThumbnailViewImageProxy *imageViewProxy = [[ThumbnailViewImageProxy alloc] init];
    imageViewProxy.aspect = ThumbnailAspectZoom;
    imageViewProxy.hasBorders = NO;
    NSString *photoUrl = [_restaurantDc valueForKey:@"photourl"];
    if (photoUrl.length != 0) {
      imageViewProxy.imagePath = photoUrl;
    }
    imageView = imageViewProxy;
    
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
    
    // view para o mapa
    UIButton *mapButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    mapButton.frame = CGRectMake(200., 80., 80., 80.);
    [mapButton setBackgroundImage:[UIImage imageNamed:@"mapa.png"] forState:UIControlStateNormal];
    [mapButton addTarget:self action:@selector(showMap) forControlEvents:UIControlEventTouchUpInside];
    [imageView addSubview:mapButton];
    
  } // fim 1a. seção
  return imageView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  if (section == 0) {
    return 130;
  } else {
    return 0;
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  if ([indexPath section]==0 && [indexPath row]==0) {
    return 44;
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
  return [self calculateHeightForConfiguredSizingCell:sizingCell];
}

- (CGFloat)calculateHeightForConfiguredSizingCell:(UITableViewCell *)sizingCell {
  [sizingCell setNeedsLayout];
  [sizingCell layoutIfNeeded];
  
  CGSize size = [sizingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
  return size.height + 1.0f; // Add 1.0f for the cell separator height
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  
  _restaurantDc = [dataModel currentRestaurant];
  
  
      return [self basicCellAtIndexPath:indexPath];
}


- (UITableViewCell *)basicCellAtIndexPath:(NSIndexPath *)indexPath {
  DetailCell *cell = nil;

  switch (indexPath.section) {
    case 0:
      if (indexPath.row == 2) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"ContactCell" forIndexPath:indexPath];
      } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"RestaurantDetailCell" forIndexPath:indexPath];
      }
      break;
    case 1: {
      prefCell = [[PreferredCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
      if ([[_restaurantDc valueForKey:@"id"] isEqualToString:[dataModel.preferredRestaurant valueForKey:@"id"]]) {
        [prefCell.preferredButton setTitle:@"Desmarcar como favorito" forState:UIControlStateNormal];
      } else {
        [prefCell.preferredButton setTitle:@"Marcar como favorito" forState:UIControlStateNormal];
      }
      return prefCell;
    }
      break;
    default:
      break;
  }

  [self configureBasicCell:cell atIndexPath:indexPath];
  return cell;
}

- (void)configureBasicCell:(DetailCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  // Configure the cell...
  [cell.title setNumberOfLines:0];
  [cell.title setLineBreakMode:NSLineBreakByWordWrapping];
  
  [cell.subtitle setNumberOfLines:0];
  [cell.subtitle setLineBreakMode:NSLineBreakByWordWrapping];
  
  
  switch ([indexPath row]) {
      
    case 0: { // espaço para altura do botão de mapas
      [cell.title setText: @" "];
      [cell.subtitle setText: @" "];
      break;
    }
    case 1: {
      [cell.title setText: @"Endereço"];
      [cell.subtitle setText: [_restaurantDc valueForKey:@"address"]];
      break;
    }
    case 2: {
      [cell.title setText: @"Telefone(s)"];
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
      [cell.subtitle setText: telephones];
      
      UIImage *image = [UIImage imageNamed:@"phone.png"];
      UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
      CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
      button.frame = frame;
      [button setBackgroundImage:image forState:UIControlStateNormal];
      [button addTarget:self action:@selector(callButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
      button.backgroundColor = [UIColor clearColor];
      button.tintColor = [UIColor blueColor];
      cell.accessoryView = button;
      break;
    }
      
    case 3:{
      [cell.title setText: @"Horários"];
      NSMutableString *workingHours = [[NSMutableString alloc] init];
      
      //DIA DA SEMANA
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
      
      //SABADO
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
      } else {
        [workingHours appendString:@"Fechado \n"];
      }
      
      //DOMINGO
      [workingHours appendString:@"\nDomingo \n"];
      //cafe da manha
      NSString *sundayBreakfest = [[[_restaurantDc valueForKey:@"workinghours"] valueForKey:@"sunday"]valueForKey:@"breakfest"];
      if (sundayBreakfest && ![sundayBreakfest isEqualToString:@""]) {
        [workingHours appendString:[NSString stringWithFormat:@"Café da manhã: %@\n", sundayBreakfest]];
      }
      
      //almoço
      NSString *sundayLunch = [[[_restaurantDc valueForKey:@"workinghours"] valueForKey:@"sunday"]valueForKey:@"lunch"];
      if (sundayLunch && ![sundayLunch isEqualToString:@""]) {
        [workingHours appendString:[NSString stringWithFormat:@"Almoço: %@", sundayLunch]];
      } else {
        [workingHours appendString:@"Fechado"];
      }
      
      [cell.subtitle setText: workingHours];
      break;
    }
    case 4: {
      [cell.title setText: @"Preços"];
      NSMutableString *prices = [[NSMutableString alloc] init];
      if (([[_restaurantDc valueForKey:@"cashiers"] isKindOfClass:[NSArray class]]) && ([[_restaurantDc valueForKey:@"cashiers"] count] > 0)) {
        [prices appendString:[NSString stringWithFormat:@"Aluno: %@\n", [[[[[_restaurantDc valueForKey:@"cashiers"] objectAtIndex:0] valueForKey:@"prices"] valueForKey:@"students"] valueForKey:@"lunch"]]];
        [prices appendString:[NSString stringWithFormat:@"Especial: %@\n", [[[[[_restaurantDc valueForKey:@"cashiers"] objectAtIndex:0] valueForKey:@"prices"] valueForKey:@"special"] valueForKey:@"lunch"]]];
        [prices appendString:[NSString stringWithFormat:@"Visitante: %@", [[[[[_restaurantDc valueForKey:@"cashiers"] objectAtIndex:0] valueForKey:@"prices"] valueForKey:@"visiting"] valueForKey:@"lunch"]]];
      } else {
        [prices appendString:[NSString stringWithFormat:@"Aluno: 1.90\n"]];
        [prices appendString:[NSString stringWithFormat:@"Especial: 6.00\n"]];
        [prices appendString:[NSString stringWithFormat:@"Visitante: 12.00"]];
      }
      
      [cell.subtitle setText: prices];
      break;
    }
    case 5:
      [cell.title setText: @"Ponto de venda"];
      if ([[_restaurantDc valueForKey:@"cashiers"] count] > 0) {
        [cell.subtitle setText:[NSString stringWithFormat:@"%@ \n\n%@", [[[_restaurantDc valueForKey:@"cashiers"] objectAtIndex:0] valueForKey:@"address"], [[[_restaurantDc valueForKey:@"cashiers"] objectAtIndex:0] valueForKey:@"workinghours"]]];
      } else {
        [cell.subtitle setText: @""];
        [cell.subtitle setHidden:YES];
      }
      break;
    
      
    default:
      break;
  }
}


/// Trata telefone e email
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0 && indexPath.row == 1) {
        if ([[UIDevice currentDevice].model isEqualToString:@"iPhone"]) {
          NSArray *telephoneListToDial = [NSArray arrayWithArray:[_restaurantDc objectForKey:@"phones"]];
          UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
          actionSheet.title =  [NSString stringWithFormat:@"Ligar para restaurante"];
          actionSheet.delegate = self;
          for (NSString *s in telephoneListToDial) {
            [actionSheet addButtonWithTitle:[TelephoneUtils telephoneWithCarrierFromString:s]];
          }
          actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancelar"];
          [[actionSheet viewWithTag:0] setOpaque:NO];
          [[actionSheet viewWithTag:0] setAlpha:0.8];
          [actionSheet showFromTabBar:super.tabBarController.tabBar];
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


#pragma mark - Action Sheet

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
  if ([actionSheet cancelButtonIndex] != buttonIndex) { // se não for o botão cancelar disca o telefone
    [TelephoneUtils dialToTelephone:[actionSheet buttonTitleAtIndex:buttonIndex]];
  }
}


#pragma mark Actions

- (void)showMap{
  MapViewController *mapController = [self.storyboard instantiateViewControllerWithIdentifier:@"MapViewController"];
  [self.navigationController pushViewController:mapController animated:YES];
}

- (void)doneButtonTapped:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveRestaurants{
  //[self setupView];
  [self.tableView reloadData];
}

-(void)setPreferred:(id)sender {
  if ([[_restaurantDc valueForKey:@"id"] isEqualToString:[dataModel.preferredRestaurant valueForKey:@"id"]]) {
    [dataModel setPreferredRestaurant:nil]; // se for igual, está desmarcando como favorito
    [prefCell.preferredButton setTitle:@"Marcar como favorito" forState:UIControlStateNormal];
  } else {
    [dataModel setPreferredRestaurant:_restaurantDc]; // senão, está marcando como favorito
    [prefCell.preferredButton setTitle:@"Desmarcar como favorito" forState:UIControlStateNormal];
  }

  [self reloadInputViews];
}

@end
