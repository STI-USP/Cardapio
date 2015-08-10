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
  
  self.tableView.estimatedRowHeight = 44.0; // for example. Set your average height
  self.tableView.rowHeight = UITableViewAutomaticDimension;
  [self.tableView reloadData];
  
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
- (void)setupView{

  [self setTitle:@"Informações gerais"];

  _restaurantDc = [dataModel currentRestaurant];
  
  //Imagem do cabeçalho
  _restImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[_restaurantDc valueForKey:@"photourl"]]]];
  
  //texto da imagem de cabeçalho
  [_restaurantName setText: [_restaurantDc valueForKey:@"name"]];
  [_restaurantName setNumberOfLines:0];
  [_restaurantName setBackgroundColor:[UIColor clearColor]];
  [_restaurantName setTextColor:[UIColor whiteColor]];
  [_restaurantName setFont:[UIFont systemFontOfSize:14]];
  [_restaurantName setShadowColor:[UIColor blackColor]];
  [_restaurantName setShadowOffset:CGSizeMake(1, 1)];
  [_restaurantName setTextAlignment:NSTextAlignmentCenter];
  
  //sombra
  [_restaurantNameOverlay setText: [_restaurantDc valueForKey:@"name"]];
  [_restaurantNameOverlay setNumberOfLines:0];
  [_restaurantNameOverlay setBackgroundColor:[UIColor clearColor]];
  [_restaurantNameOverlay setTextColor:[UIColor blackColor]];
  [_restaurantNameOverlay setFont:[UIFont systemFontOfSize:14]];
  [_restaurantNameOverlay setShadowColor:[UIColor blackColor]];
  [_restaurantNameOverlay setShadowOffset:CGSizeMake(1, 1)];
  [_restaurantNameOverlay setAlpha:0.4];
  [_restaurantNameOverlay setTextAlignment:NSTextAlignmentCenter];
  
  
  //endereço
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
    [workingHours appendString:[NSString stringWithFormat:@"Almoço: %@\n", sundayLunch]];
  }
  
  _weeklyperiod.text = workingHours;
  
  
  //preços
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
  
  [_priceItens setText:prices];
  

  //pontos de venda
  [_cashiersTitle setLineBreakMode: NSLineBreakByWordWrapping];
  [_cashiersTitle setNumberOfLines:0];
  if ([[_restaurantDc valueForKey:@"cashiers"] count] > 0) {
    [_cashiers setText:[NSString stringWithFormat:@"%@ \n\n%@", [[[_restaurantDc valueForKey:@"cashiers"] objectAtIndex:0] valueForKey:@"address"], [[[_restaurantDc valueForKey:@"cashiers"] objectAtIndex:0] valueForKey:@"workinghours"]]];
  } else {
    [_cashiers setText: @""];
    [_cashiers setHidden:YES];
  }
  
  if ([[_restaurantDc valueForKey:@"id"] isEqualToString:[dataModel.preferredRestaurant valueForKey:@"id"]]) {
    [self.prefButton setTitle:@"Desmarcar como favorito" forState:UIControlStateNormal];
  } else {
    [self.prefButton setTitle:@"Marcar como favorito" forState:UIControlStateNormal];
  }
  
  [self reloadInputViews];
}
*/

//
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  
  UIView *imageView = [[UIView alloc] initWithFrame:CGRectMake(0., 0., self.tableView.frame.size.width, 80.)];
  if (section == 0) { // a 1a. seção contém as informações da biblioteca
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
    
  } // fim 1a. seção
  return imageView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  CGFloat headerHeight = 22.0; // altura padrão para section header
  if (section == 0) {
    headerHeight = 120.0;
  }
  return headerHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

  _restaurantDc = [dataModel currentRestaurant];
  
  
  switch ([indexPath section]) {
    case 0:{
      DetailCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RestaurantDetailCell" forIndexPath:indexPath];
      // Configure the cell...
      [cell.title setNumberOfLines:0];
      [cell.title setLineBreakMode:NSLineBreakByWordWrapping];
      
      [cell.subtitle setNumberOfLines:0];
      [cell.subtitle setLineBreakMode:NSLineBreakByWordWrapping];

      
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
          break;
        }

        case 2:{
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
            [workingHours appendString:@"Fechado"];
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
            [workingHours appendString:[NSString stringWithFormat:@"Almoço: %@\n", sundayLunch]];
          } else {
            [workingHours appendString:@"Fechado"];
          }
          
          [cell.subtitle setText: workingHours];
        }
          break;
          
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
      return cell;
      break;
    }
      
    case 1: {
      prefCell = [tableView dequeueReusableCellWithIdentifier:@"PreferredCell" forIndexPath:indexPath];
      if ([[_restaurantDc valueForKey:@"id"] isEqualToString:[dataModel.preferredRestaurant valueForKey:@"id"]]) {
        [prefCell.preferredButton setTitle:@"Desmarcar como favorito" forState:UIControlStateNormal];
      } else {
        [prefCell.preferredButton setTitle:@"Marcar como favorito" forState:UIControlStateNormal];
      }

      return prefCell;
      break;

    }
      
    default:
      break;
    
  }
  return nil;
}

/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
  if ([indexPath section]==0) {
    if ([indexPath row]==0) {
      return 170;
    }
  } else {
    return UITableViewAutomaticDimension;
  }
  return UITableViewAutomaticDimension;
}
 */

//

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
