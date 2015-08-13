//
//  MapViewController.m
//  Bibliotecas USP
//
//  Created by Jun Okamoto Jr. on 23/10/14.
//  Copyright (c) 2014 USP. All rights reserved.
//

#import "MapViewController.h"
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "PlaceAnnotation.h"
#import "DataModel.h"
#import "MDPinAnnotationView.h"

#define kCuasoLatitude -23.56265           // CUASO Lat
#define kCuasoLongitude -46.727943         // CUASO Lon

#define kFmLatitude -23.555274             // Faculdade de Medicina Lat
#define kFmLongitude -46.670212            // Faculdade de Medicina Lon

#define kFauMaranhaoLatitude -23.545596    // FAU Maranhão Lat
#define kFauMaranhaoLongitude -46.653389   // FAU Maranhão Lon

#define kMzLatitude -23.588093             // Museu de Zoologia (Ipiranga) Lat
#define kMzLongitude -46.610253            // Museu de Zoologia (Ipiranga) Lon

#define kEachLatitude -23.483853           // EACH lat
#define kEachLongitude -46.487575          // EACH Lon

#define kEsalqLatitude -22.708482          // ESALQ Lat
#define kEsalqLongitude -47.639143         // ESAQ Lon

#define kScILatitude -22.007895            // São Carlos Campus I Lat
#define kScILongitude -47.896421           // São Carlos Campus I Lon

#define kScIiLatitude -22.000465           // São Carlos Campus II Lat
#define kScIiLongitude -47.93144           // São Carlos Campus II Lon

#define kPirassunungaLatitude -21.982747   // Pirassununga Lat
#define kPirassunungaLongitude -47.429706  // Priassununga Lon

#define kRpLatitude -21.168445             // Ribeirão Preto Lat
#define kRpLongitude -47.854772            // Ribeirão Preto Lon

#define kNear 3000    // considera dentro do campus num raio de 3000 m
#define kRegion 2000  // considera uma região de 2000 m de raio em torno do centro para efeitos de zoom do mapa

@interface MapViewController () <CLLocationManagerDelegate, MKMapViewDelegate>

@property (nonatomic, weak) IBOutlet MKMapView *mapView;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) DataModel *dataModel;
@property (nonatomic, strong) NSDictionary *selectedLibrary;

@property (nonatomic, strong) CLLocation *userLocation; // localização do usuário

@property (nonatomic, strong, readonly) CLLocation *cuaso;       // localização do campus da Cidade Universitária
@property (nonatomic, strong, readonly) CLLocation *fm;          // localização da Faculdade de Medicina
@property (nonatomic, strong, readonly) CLLocation *fauMaranhao; // localização da FAU Maranhão
@property (nonatomic, strong, readonly) CLLocation *mz;          // localização do Museu de Zoologia
@property (nonatomic, strong, readonly) CLLocation *each;        // localização da EACH
@property (nonatomic, strong, readonly) CLLocation *esalq;       // localização da ESALQ
@property (nonatomic, strong, readonly) CLLocation *sci;         // localização de São Carlos Campus I
@property (nonatomic, strong, readonly) CLLocation *scii;        // localização de São Carlos Campus II
@property (nonatomic, strong, readonly) CLLocation *pirassununga;// localização de Pirassununga
@property (nonatomic, strong, readonly) CLLocation *rp;          // localização de Ribeirão Preto

- (void)startUserLocation:(id)sender; // dispara localização do usuário, ligado a Timer para não gastar bateria

@end

@implementation MapViewController

@synthesize cuaso = _cuaso;
@synthesize fm = _fm;
@synthesize fauMaranhao = _fauMaranhao;
@synthesize mz = _mz;
@synthesize each = _each;
@synthesize esalq = _esalq;
@synthesize sci = _sci;
@synthesize scii = _scii;
@synthesize pirassununga = _pirassununga;
@synthesize rp = _rp;

- (void)viewDidLoad {
  [super viewDidLoad];
  // Do any additional setup after loading the view.
  self.dataModel = [DataModel getInstance];
  self.locationManager = [[CLLocationManager alloc] init];
  self.locationManager.delegate = self;
  self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
  self.locationManager.distanceFilter = 50; // distância mínima de deslocamento do usuário antes de disparar update em metros
  if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) { // verifica se pode pedir autorização, para compatibilidade com iOS 8
//    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager requestAlwaysAuthorization]; // [jo:150807]
  }
  [self.locationManager startUpdatingLocation]; // inicia atualização da posição do usuário
  
  self.mapView.delegate = self;
  self.mapView.showsUserLocation = YES; // tem permissão mostrar a localização do usuário, mas não que dizer que vai mostrar
  [NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(startUserLocation:) userInfo:nil repeats:YES];
  
  self.userLocation = nil;
  PlaceAnnotation *annotation = [[PlaceAnnotation alloc] initWithTitle:self.dataModel.currentRestaurant[@"name"] subtitle:self.dataModel.currentRestaurant[@"address"] andCoordinate:CLLocationCoordinate2DMake([self.dataModel.currentRestaurant[@"latitude"] doubleValue], [self.dataModel.currentRestaurant[@"longitude"] doubleValue])];
  //annotation.library = library;
  [self.mapView addAnnotation:annotation];
  
  // Centro do mapa no Restaurante escolhido
  [self.mapView setCenterCoordinate:CLLocationCoordinate2DMake([self.dataModel.currentRestaurant[@"latitude"] doubleValue], [self.dataModel.currentRestaurant[@"longitude"] doubleValue])];
  MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake([self.dataModel.currentRestaurant[@"latitude"] doubleValue], [self.dataModel.currentRestaurant[@"longitude"] doubleValue]), kRegion, kRegion);
  [self.mapView setRegion:region animated:YES]; // ajusta mapa na região em volta do restaurante
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
}

- (void)startUserLocation:(id)sender {
  [_locationManager startUpdatingLocation];
}

#pragma mark - Getters de Localização da USP

- (CLLocation *)cuaso { return (_cuaso == nil ? _cuaso = [[CLLocation alloc] initWithLatitude:kCuasoLatitude longitude:kCuasoLongitude] : _cuaso); }
- (CLLocation *)fm { return (_fm == nil ? _fm = [[CLLocation alloc] initWithLatitude:kFmLatitude longitude:kFmLongitude] : _fm); }
- (CLLocation *)fauMaranhao { return (_fauMaranhao == nil ? _fauMaranhao = [[CLLocation alloc] initWithLatitude:kFauMaranhaoLatitude longitude:kFauMaranhaoLongitude] : _fauMaranhao); }
- (CLLocation *)mz { return (_mz == nil ? _mz = [[CLLocation alloc] initWithLatitude:kMzLatitude longitude:kMzLongitude] : _mz); }
- (CLLocation *)each { return (_each == nil ? _each = [[CLLocation alloc] initWithLatitude:kEachLatitude longitude:kEachLongitude] : _each); }
- (CLLocation *)esalq { return (_esalq == nil ? _esalq = [[CLLocation alloc] initWithLatitude:kEsalqLatitude longitude:kEsalqLongitude] : _esalq); }
- (CLLocation *)sci { return (_sci == nil ? _sci = [[CLLocation alloc] initWithLatitude:kScILatitude longitude:kScILongitude] : _sci); }
- (CLLocation *)scii { return (_scii == nil ? _scii = [[CLLocation alloc] initWithLatitude:kScIiLatitude longitude:kScIiLongitude] : _scii); }
- (CLLocation *)pirassununga { return (_pirassununga == nil ? _pirassununga = [[CLLocation alloc] initWithLatitude:kPirassunungaLatitude longitude:kPirassunungaLongitude] : _pirassununga); }
- (CLLocation *)rp { return (_rp == nil ? _rp = [[CLLocation alloc] initWithLatitude:kRpLatitude longitude:kRpLongitude] : _rp); }

#pragma mark - Location Manager Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
  
  CLLocationCoordinate2D campusLocation = [self.cuaso coordinate]; // default location é o campus CUASO
  self.userLocation = [locations lastObject]; // posição do usuário
  
  // determina em qual campus está o usuário
  if ([self.userLocation distanceFromLocation:self.cuaso] < kNear) { // Cidade Universitária
    campusLocation = [self.cuaso coordinate];
  } else if ([self.userLocation distanceFromLocation:self.fm] < kNear) { // Faculdade de Medicina
    campusLocation = [self.fm coordinate];
  } else if ([self.userLocation distanceFromLocation:self.fauMaranhao] < kNear) { // FAU Maranhão
    campusLocation = [self.fauMaranhao coordinate];
  } else if ([self.userLocation distanceFromLocation:self.mz] < kNear) { // Museu de Zoologia (Ipiranga)
    campusLocation = [self.mz coordinate];
  } else if ([self.userLocation distanceFromLocation:self.each] < kNear) { // EACH
    campusLocation = [self.each coordinate];
  } else if ([self.userLocation distanceFromLocation:self.esalq] < kNear) { // ESALQ
    campusLocation = [self.esalq coordinate];
  } else if ([self.userLocation distanceFromLocation:self.sci] < kNear) { // São Carlos Campus I
    campusLocation = [self.sci coordinate];
  } else if ([self.userLocation distanceFromLocation:self.scii] < kNear) { // São Carlos CampusII
    campusLocation = [self.scii coordinate];
  } else if ([self.userLocation distanceFromLocation:self.pirassununga] < kNear) { // Pirassununga
    campusLocation = [self.pirassununga coordinate];
  } else if ([self.userLocation distanceFromLocation:self.rp] < kNear) { // Ribeirão Preto
    campusLocation = [self.rp coordinate];
  }
  
    // define a região em torno do campus onde se encontra o usuário
    // e só define a região uma vez
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      CLLocation *lastLocation = [locations lastObject];
      CLLocationAccuracy accuracy = [lastLocation horizontalAccuracy];
      if (accuracy < 100.0) { // só se a precisão for melhor do que 100 metros
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(campusLocation, kRegion, kRegion); //  zoom dentro da região do campus
        [self.mapView setRegion:region animated:YES]; // ajusta mapa na região do campus onde está o usuário
      }
    });
  
  [manager stopUpdatingLocation]; // pára de atualizar a localização para economia de bateria
}

#pragma mark - Map Kit Delegate

/// Coloca o botão Detail Disclosure na anotação
- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation {
  
  if (annotation == mapView.userLocation) return nil; // mostra círculo azul se a anotação for localização do usuário
  
  // se for biblioteca, mostra pino e pode mostrar detail discolosure
  MDPinAnnotationView *newAnnotationView = [[MDPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"pinLocation"];
  newAnnotationView.animatesDrop = YES; // anima colocação
  newAnnotationView.pinColor = MKPinAnnotationColorPurple; // usa cor roxa
  newAnnotationView.canShowCallout = YES; // não permite botão
  
  // O comprimento do título da anotação atrapalha a posição do Detail Diclosure Button
  // para acertar isso é necessário alterar a altura da view do botão
  // solução de http://stackoverflow.com/questions/25484608/ios-8-mkannotationview-rightcalloutaccessoryview-misaligned
  //UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
  // N.B. In production code, you would need a more generic way to adjust
  // height values instead of hard-coding values based on NSFoundationVersionNumber...
  //CGFloat height = (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_7_1) ? 55.f : 45.f;
  //detailButton.frame = CGRectMake(0.f, 0.f, 32.f, height);
  //newAnnotationView.rightCalloutAccessoryView = detailButton;
  // fim da solução da posição do Detail Disclosure Button
  
//  newAnnotationView.tag = [self.mapView.annotations indexOfObject:annotation]; // salva o indice da anotação no tag da view
  //PlaceAnnotation *placeAnnotation = (PlaceAnnotation *)annotation;
  //newAnnotationView.library = placeAnnotation.library;

//  [jo:141120] abaixo eu queria mostra a distância do usuário até a biblioteca, mas não dá certo assim
//  porque annotiation.subtitle é readonly. Preciso pensar em outra maneira
//  if (self.userLocation != nil) { // se a localização do usuário for conhecida
//    CLLocationDistance usercuasoDistance = [self.userLocation distanceFromLocation:self.cuaso];
//    NSString *distanceText = [NSString stringWithFormat:@"%f", usercuasoDistance];
//    annotation.subtitle = distanceText; // coloca a distância até a biblioteca no subtítulo
//  }
  return newAnnotationView;
}

/// É chamado quando o botão Detail Disclosure é acionado
- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
//  MDPinAnnotationView *annotationView = (MDPinAnnotationView *)view;
//  PlaceAnnotation *placeAnnotation = (PlaceAnnotation *)(self.mapView.annotations[view.tag]); // pega a anotação pelo indice armazenado no tag da vista
//  NSDictionary *library = placeAnnotation.library; // retira as informações da biblioteca da anotação
  //NSDictionary *library = annotationView.library;
  //self.selectedLibrary = library; // armazena localmente para passar para o controlador que vai entrar
  //[self performSegueWithIdentifier:@"DetailFromMapSegue" sender:self]; // vai para o controlador
}

- (void)locationUpdate:(CLLocation *)location {
  //[self.mapView setCenterCoordinate:location.coordinate];
  if ([self.mapView showsUserLocation] == NO) {
    [self.mapView setShowsUserLocation:YES];
  }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  // Get the new view controller using [segue destinationViewController].
  // Pass the selected object to the new view controller.
  //if ([segue.destinationViewController isKindOfClass:[AboutLibrariesDetailViewController class]]) {
  //  AboutLibrariesDetailViewController *detailViewController = segue.destinationViewController;
  //  detailViewController.library = self.selectedLibrary;
  //}
}

@end
