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

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)


#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]


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
  [[UITableViewCell appearance] setTintColor:UIColorFromRGB(0x1094AB)];

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
  
  if ([indexPath section]==0) {
    switch ([indexPath row]) {
        
      case 0: {
        [cell.title setText: @"Endereço"];
        [cell.subtitle setText: [_restaurantDc valueForKey:@"address"]];
        break;
      }
      case 1: {
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
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        button.frame = CGRectMake(0.0, 0.0, 25., 30.);
        [button setImage:[UIImage imageNamed:@"phone.png"] forState:UIControlStateNormal];
        [button setTintColor:UIColorFromRGB(0x1094AB)];
        [button addTarget:self action:@selector(callButtonTapped:event:) forControlEvents:UIControlEventTouchUpInside];
        cell.accessoryView = button;
        break;
      }
        
      case 2:{
        [cell.title setText: @"Horários"];
        NSMutableString *workingHours = [[NSMutableString alloc] init];
        
        //DIA DA SEMANA
        [workingHours appendString:@"Segunda à sexta-feira \n"];
        //café da manha
        NSString *weekdayBreakfest = [[[_restaurantDc valueForKey:@"workinghours"] valueForKey:@"weekdays"]valueForKey:@"breakfast"];
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
      case 3: {
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
      case 4: {
        [cell.title setText: @"Ponto de venda"];
        if ([[_restaurantDc valueForKey:@"cashiers"] count] > 0) {
          [cell.subtitle setText:[NSString stringWithFormat:@"%@ \n\n%@", [[[_restaurantDc valueForKey:@"cashiers"] objectAtIndex:0] valueForKey:@"address"], [[[_restaurantDc valueForKey:@"cashiers"] objectAtIndex:0] valueForKey:@"workinghours"]]];
        } else {
          [cell.subtitle setText: @""];
          [cell.subtitle setHidden:YES];
        }
        break;
      }
      default:
        break;
    }
  }
}


/// Trata telefone
- (void)tableView:(UITableView *)tableView accessoryButtonTappedForRowWithIndexPath:(NSIndexPath *)indexPath {
  if (indexPath.section == 0 && indexPath.row == 1) {
    if ([[UIDevice currentDevice].model isEqualToString:@"iPhone"]) {
      //NSArray *telephoneListToDial = [NSArray arrayWithArray:[_restaurantDc objectForKey:@"phones"]];
      UIActionSheet *actionSheet = [[UIActionSheet alloc] init];
      actionSheet.title =  [NSString stringWithFormat:@"Ligar para restaurante"];
      actionSheet.delegate = self;
        //for (NSString *s in telephoneListToDial) {
        //  [actionSheet addButtonWithTitle:[TelephoneUtils telephoneWithCarrierFromString:s]];
        // }
      [actionSheet addButtonWithTitle:[TelephoneUtils telephoneWithCarrierFromString:[_restaurantDc objectForKey:@"phones"]]];
        
      actionSheet.cancelButtonIndex = [actionSheet addButtonWithTitle:@"Cancelar"];
      [[actionSheet viewWithTag:0] setOpaque:NO];
      [[actionSheet viewWithTag:0] setAlpha:0.8];
      [actionSheet showInView:self.view];
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
  if ([actionSheet cancelButtonIndex] != buttonIndex) {
    [TelephoneUtils dialToTelephone:[actionSheet buttonTitleAtIndex:buttonIndex]];
  }
}


- (void)setHeaderView{

  //TableView Header
  UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 160)];
  [headerView setBackgroundColor:[UIColor whiteColor]];
  
  //imagem do restaurante
  UIView *imageView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 120)];
  ThumbnailViewImageProxy *imageViewProxy = [[ThumbnailViewImageProxy alloc] init];
  imageViewProxy.aspect = ThumbnailAspectZoom;
  imageViewProxy.hasBorders = NO;

  NSString *photoUrl = [_restaurantDc valueForKey:@"photourl"];
  if (photoUrl.length != 0) {
    imageViewProxy.imagePath = photoUrl;
  }
  
  imageView = imageViewProxy;
  
  UIImageView *viewForImage = [[UIImageView alloc] initWithImage:imageViewProxy.image];
  [viewForImage setFrame:CGRectMake(0., 0., self.tableView.frame.size.width, 130.)];
  //[viewForImage setContentMode: UIViewContentModeScaleAspectFill];
  //[viewForImage setContentMode: UIViewContentModeScaleAspectFit];
  [viewForImage setContentMode: UIViewContentModeScaleToFill];
  [imageView addSubview:viewForImage];
  
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
  UIButton *mapButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
  mapButton.frame = CGRectMake(200., 80., 80., 80.);
  [mapButton setBackgroundImage:[UIImage imageNamed:@"mapa.png"] forState:UIControlStateNormal];
  [mapButton addTarget:self action:@selector(showMap) forControlEvents:UIControlEventTouchUpInside];
  [headerView addSubview:mapButton];
  
  [self.tableView setTableHeaderView: headerView];
  [SVProgressHUD dismiss];
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
