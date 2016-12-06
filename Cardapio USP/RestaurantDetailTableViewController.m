
//
//  RestaurantDetailTableViewController.m
//  Cardapio USP
//
//  Created by Vagner Machado on 7/14/15.
//  Copyright (c) 2015 EPUSP. All rights reserved.
//

#import "RestaurantDetailTableViewController.h"
#import "DataModel.h"
#import "DetailCell.h"
#import "ThumbnailViewImageProxy.h"

#pragma mark - NSString Category

@interface NSString (LineBreak)

+ (NSString *)stringByReplacingLineBreaks:(NSString *)originalString;

@end

@implementation NSString (LineBreak)

+ (NSString *)stringByReplacingLineBreaks:(NSString *)originalString {
  NSString *newLineString = @"\n";
  NSString *returnString = [originalString stringByReplacingOccurrencesOfString:@"\\n" withString:newLineString];
  returnString = [returnString stringByReplacingOccurrencesOfString:@"\\u000d" withString:newLineString];
  returnString = [returnString stringByReplacingOccurrencesOfString:@"\\r" withString:newLineString];
  return returnString;
}

@end


#define UIColorFromRGB(rgbValue) \
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0x00FF00) >>  8))/255.0 \
blue:((float)((rgbValue & 0x0000FF) >>  0))/255.0 \
alpha:1.0]


#pragma mark - Restaurants Detail View Controller
@interface RestaurantDetailTableViewController () {
  DataModel *dataModel;
}

@end

@implementation RestaurantDetailTableViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  dataModel = [DataModel getInstance];

  [[UITableViewCell appearance] setTintColor:UIColorFromRGB(0x1094AB)];
  [[DetailCell appearance] setTintColor:UIColorFromRGB(0x1094AB)];

  [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveRestaurants) name:@"DidReceiveRestaurants" object:nil];

}

- (void)viewWillAppear:(BOOL)animated {
  if ([[dataModel restaurants] count] == 0) {
    [dataModel getRestaurantList];
  }
  self.restaurant = [dataModel currentRestaurant];
  [self setTitle:@"Informações gerais"];
  
  _restImage.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[self.restaurant valueForKey:@"photourl"]]]];
  
  [_restaurantName setText: [self.restaurant valueForKey:@"name"]];
  [_restaurantName setNumberOfLines:0];
  [_restaurantName setBackgroundColor:[UIColor clearColor]];
  [_restaurantName setTextColor:[UIColor whiteColor]];
  [_restaurantName setFont:[UIFont systemFontOfSize:14]];
  [_restaurantName setShadowColor:[UIColor blackColor]];
  [_restaurantName setShadowOffset:CGSizeMake(1, 1)];
  [_restaurantName setTextAlignment:NSTextAlignmentCenter];
  
  [_restaurantNameOverlay setText: [self.restaurant valueForKey:@"name"]];
  [_restaurantNameOverlay setNumberOfLines:0];
  [_restaurantNameOverlay setBackgroundColor:[UIColor clearColor]];
  [_restaurantNameOverlay setTextColor:[UIColor blackColor]];
  [_restaurantNameOverlay setFont:[UIFont systemFontOfSize:14]];
  [_restaurantNameOverlay setShadowColor:[UIColor blackColor]];
  [_restaurantNameOverlay setShadowOffset:CGSizeMake(1, 1)];
  [_restaurantNameOverlay setAlpha:0.4];
  [_restaurantNameOverlay setTextAlignment:NSTextAlignmentCenter];

}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
  [super viewDidAppear:animated];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  // Return the number of sections.
  return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  // Return the number of rows in the section.
  switch (section) {
    case 0: // info
      return 5; //endereço, telefone, horarios, preços, pontos de venda
      break;
    case 1: // botão "Definir como preferida"
      return 1;
      break;
    default:
      break;
  }
  return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  return  [self cellAtIndexPath:indexPath];
}

- (DetailCell *)cellAtIndexPath:(NSIndexPath *)indexPath {
  DetailCell *cell = nil;
  
  switch (indexPath.section) {
    case 0:
      if (indexPath.row == 1) {
        cell =  (DetailCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ContactCell"];
        //cell = [self.tableView dequeueReusableCellWithIdentifier:@"ContactCell" forIndexPath:indexPath];
      } else {
        cell =  (DetailCell *)[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AboutDetailCell"];
        //cell = [self.tableView dequeueReusableCellWithIdentifier:@"AboutDetailCell" forIndexPath:indexPath];
      }
      break;
    case 1: {
      if ([[self.restaurant objectForKey:@"id"] isEqual: dataModel.preferredRestaurant[@"id"]]) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"ResetPreferredCell" forIndexPath:indexPath];
      } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"SetPreferredCell" forIndexPath:indexPath];
      }
    }
      break;
    default:
      break;
  }
  [self configureCell:cell atIndexPath:indexPath];
  return cell;
}

- (void)configureCell:(DetailCell *)cell atIndexPath:(NSIndexPath *)indexPath {
  
  [cell.title setTintColor:UIColorFromRGB(0x1094AB)];
  
  if (indexPath.section == 0) {
    switch (indexPath.row) {
      case 0: {
        cell.title.text = @"Endereço";
        cell.subtitle.text = [NSString stringByReplacingLineBreaks:self.restaurant[@"address"]];
      }
        break;
      case 1: { // telefone
        if ([self.restaurant[@"phones"] count] == 1) {
          cell.title.text = @"Telefone";
        } else { // mais de 1 telefone
          cell.title.text = @"Telefones";
        }
        NSMutableString *telephones = [[NSMutableString alloc] init];
        for (NSString *t in self.restaurant[@"phones"]) {
          [telephones appendString:[NSString stringWithFormat:@"%@\n", t]];
        }
        if (telephones.length >=1 ) {
          [telephones deleteCharactersInRange:NSMakeRange(telephones.length - 1, 1)];
        }
        cell.subtitle.text = telephones;
        
        UIImage *image = [[UIImage imageNamed:@"phone.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        CGRect frame = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
        button.frame = frame;
        [button setBackgroundImage:image forState:UIControlStateNormal];
        [button addTarget:self action:@selector(checkButtonTapped:event:)  forControlEvents:UIControlEventTouchUpInside];
        button.backgroundColor = [UIColor clearColor];
        [button setTintColor:UIColorFromRGB(0x1094AB)];
        cell.accessoryView = button;
        [cell.accessoryView setTintColor:UIColorFromRGB(0x1094AB)];
      }
        break;
      case 2: {
        cell.title.text = @"Horários";
        NSMutableString *workingHours = [[NSMutableString alloc] init];
        //dia de semana
        [workingHours appendString:@"Segunda à sexta-feira \n"];
        //café da manha
        NSString *weekdayBreakfest = [[[self.restaurant valueForKey:@"workinghours"] valueForKey:@"weekdays"]valueForKey:@"breakfest"];
        if (weekdayBreakfest && ![weekdayBreakfest isEqualToString:@""]) {
          [workingHours appendString:[NSString stringWithFormat:@"Café da manhã: %@\n", weekdayBreakfest]];
        }
        //almoço
        NSString *weekdayLunch = [[[self.restaurant valueForKey:@"workinghours"] valueForKey:@"weekdays"]valueForKey:@"lunch"];
        if (weekdayLunch && ![weekdayLunch isEqualToString:@""]) {
          [workingHours appendString:[NSString stringWithFormat:@"Almoço: %@\n", weekdayLunch]];
        }
        //janta
        NSString *weekdayDinner = [[[self.restaurant valueForKey:@"workinghours"] valueForKey:@"weekdays"]valueForKey:@"dinner"];
        if (weekdayDinner && ![weekdayDinner isEqualToString:@""]) {
          [workingHours appendString:[NSString stringWithFormat:@"Jantar: %@\n", weekdayDinner]];
        }
        //sabado
        [workingHours appendString:@"\nSábado \n"];
        //cafe da manha
        NSString *saturdayBreakfest = [[[self.restaurant valueForKey:@"workinghours"] valueForKey:@"saturday"]valueForKey:@"breakfest"];
        if (saturdayBreakfest && ![saturdayBreakfest isEqualToString:@""]) {
          [workingHours appendString:[NSString stringWithFormat:@"Café da manhã: %@\n", saturdayBreakfest]];
        }
        //almoço
        NSString *saturdayLunch = [[[self.restaurant valueForKey:@"workinghours"] valueForKey:@"saturday"]valueForKey:@"lunch"];
        if (saturdayLunch && ![saturdayLunch isEqualToString:@""]) {
          [workingHours appendString:[NSString stringWithFormat:@"Almoço: %@\n", saturdayLunch]];
        }
        //domingo
        [workingHours appendString:@"\nDomingo \n"];
        //cafe da manha
        NSString *sundayBreakfest = [[[self.restaurant valueForKey:@"workinghours"] valueForKey:@"sunday"]valueForKey:@"breakfest"];
        if (sundayBreakfest && ![sundayBreakfest isEqualToString:@""]) {
          [workingHours appendString:[NSString stringWithFormat:@"Café da manhã: %@\n", sundayBreakfest]];
        }
        //almoço
        NSString *sundayLunch = [[[self.restaurant valueForKey:@"workinghours"] valueForKey:@"sunday"]valueForKey:@"lunch"];
        if (sundayLunch && ![sundayLunch isEqualToString:@""]) {
          [workingHours appendString:[NSString stringWithFormat:@"Almoço: %@\n", sundayLunch]];
        }
        cell.subtitle.text = workingHours;
      }
        break;
      case 3: {
        cell.title.text = @"Preços";
        NSMutableString *prices = [[NSMutableString alloc] init];
        [prices appendString:[NSString stringWithFormat:@"Aluno: %@\n", [[[[[self.restaurant valueForKey:@"cashiers"] objectAtIndex:0] valueForKey:@"prices"] valueForKey:@"students"] valueForKey:@"lunch"]]];
        [prices appendString:[NSString stringWithFormat:@"Especial: %@\n", [[[[[self.restaurant valueForKey:@"cashiers"] objectAtIndex:0] valueForKey:@"prices"] valueForKey:@"special"] valueForKey:@"lunch"]]];
        [prices appendString:[NSString stringWithFormat:@"Visitante: %@\n", [[[[[self.restaurant valueForKey:@"cashiers"] objectAtIndex:0] valueForKey:@"prices"] valueForKey:@"visiting"] valueForKey:@"lunch"]]];

        cell.subtitle.text = prices;
      }
        break;
      case 4:{
        cell.title.text = @"Pontos de venda";
        //cell.subtitle.text = [NSString stringByReplacingLineBreaks:self.library[@"workingHours"]];
      }
        break;
      default:
        break;
    }
  } else if (indexPath.section == 1) {
  
  }
}

#pragma mark - Table View Delegate

- (void)checkButtonTapped:(id)sender event:(id)event {
  NSSet *touches = [event allTouches];
  UITouch *touch = [touches anyObject];
  CGPoint currentTouchPosition = [touch locationInView:self.tableView];
  NSIndexPath *indexPath = [self.tableView indexPathForRowAtPoint: currentTouchPosition];
  
  if (indexPath != nil)
    [self tableView: self.tableView accessoryButtonTappedForRowWithIndexPath: indexPath];
}

/*
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
  
  UIView *imageView = [[UIView alloc] initWithFrame:CGRectMake(0., 0., self.tableView.frame.size.width, 80.)];
  if (section == 0) { // a 1a. seção contém as informações da biblioteca
    // Usa proxy para carregar imagem no background
    ThumbnailViewImageProxy *imageViewProxy = [[ThumbnailViewImageProxy alloc] init];
    imageViewProxy.aspect = ThumbnailAspectZoom;
    imageViewProxy.hasBorders = NO;
    // Verifica se photoUrl é nil, se não for, carrega photoUrl senão carrega imagem padrão
    //    NSLog(@"%@", self.library[@"photoURL"]);
    NSString *photoUrl = self.restaurant[@"photourl"];
    if (photoUrl.length != 0) {
      imageViewProxy.imagePath = photoUrl;
    }
    imageView = imageViewProxy;
    
    CATextLayer *border = [[CATextLayer alloc] init];
    //    border.foregroundColor = (__bridge CGColorRef)[UIColor blackColor]; // [jo:141125] funcoina em iOS 8, mas não iOS 7
    border.foregroundColor = CFBridgingRetain((__bridge id)[UIColor blackColor].CGColor); // [jo:141125] funciona em iOS 8 e iOS 7, apesar do warning
    border.alignmentMode = kCAAlignmentCenter;
    border.font = (__bridge CFTypeRef)(@"HelveticaNeue-Bold");
    border.fontSize = 14.0;
    border.wrapped = YES;
    border.frame = CGRectMake(11.0, 81.0, self.tableView.frame.size.width - 11., 40.0);
    border.string = self.restaurant[@"name"];
    border.name = @"border";
    [imageView.layer addSublayer:border];
    
    // depois carrega em branco e no tamanho certo
    CATextLayer *label = [[CATextLayer alloc] init];
    //    label.foregroundColor = (__bridge CGColorRef)[UIColor whiteColor]; // [jo:141125] funcoina em iOS 8, mas não iOS 7
    label.foregroundColor = CFBridgingRetain((__bridge id)[UIColor whiteColor].CGColor); // [jo:141125] funciona em iOS 8 e iOS 7, apesar do warning
    label.alignmentMode = kCAAlignmentCenter;
    label.font = (__bridge CFTypeRef)(@"HelveticaNeue-Bold");
    label.fontSize = 14.0;
    label.wrapped = YES;
    label.frame = CGRectMake(10.0, 80.0, self.tableView.frame.size.width - 10., 40.0);
    label.string = self.restaurant[@"name"];
    label.name = @"text";
    [imageView.layer addSublayer:label];
    
  }
  return imageView;
}
 */


/*
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
  CGFloat headerHeight = 22.0;
  if (section == 0) {
    headerHeight = 120.0;
  }
  return headerHeight;
}
*/

#pragma mark - Actions

- (void)doneButtonTapped:(id)sender {
  [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)didReceiveRestaurants{
  [self.tableView reloadData];
}

-(IBAction)setAsPreferred:(id)sender{
  [dataModel setPreferredRestaurant:self.restaurant];
  [self.tableView reloadData];
}

-(IBAction)resetPreferred:(id)sender {
  [dataModel setPreferredRestaurant: nil]; // retira preferência
  [self.tableView reloadData];
}

@end
