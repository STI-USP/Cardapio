//
//  AppDelegate.m
//  Cardapio USP
//
//  Created by Jun Okamoto Jr. on 19/05/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import "AppDelegate.h"
#import "DataModel.h"
#import "Constants.h"
#import "Cardapio_USP-Swift.h"

@import Firebase;

@interface AppDelegate()
@property (nonatomic, strong) DataModel *dataModel;
@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

  [FIRApp configure];
  [Constants class];
  
  _dataModel = [DataModel getInstance];

  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [_dataModel setPreferredRestaurant:[defaults objectForKey:@"preferredRestaurant"]];
  [_dataModel getRestaurantList];
  
  if (_dataModel.currentRestaurant)
    [[RestaurantBridge shared] setCurrentRestaurantFrom:_dataModel.currentRestaurant];
  
  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  self.window.tintColor = [UIColor colorNamed:@"usp_green"];
  [[UINavigationBar appearance] setTintColor:[UIColor colorNamed:@"usp_green"]];

  MainViewController *mainViewController = [AppFactory makeMainViewController];
  UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
  self.window.rootViewController = navController;
  [self.window makeKeyAndVisible];
  
  return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
  // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
  // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
  // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
  // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
  // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
  _dataModel = [DataModel getInstance];
  NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
  [_dataModel setPreferredRestaurant:[defaults objectForKey:@"preferredRestaurant"]];
  [_dataModel getRestaurantList];
  
  if ([_dataModel preferredRestaurant])
    [_dataModel setCurrentRestaurant:_dataModel.preferredRestaurant];
//  [_dataModel getMenu];

  // Propaga o restaurante corrente ao serviço Swift
  if (_dataModel.currentRestaurant)
    [[RestaurantBridge shared] setCurrentRestaurantFrom:_dataModel.currentRestaurant];
}

- (void)applicationWillTerminate:(UIApplication *)application {
  // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
