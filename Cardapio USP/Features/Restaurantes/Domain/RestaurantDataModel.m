//
//  RestaurantDataModel.m
//  Cardapio USP
//
//  Created by Vagner Machado on 7/23/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import "RestaurantDataModel.h"
#import "Restaurant.h"

@interface RestaurantDataModel () {
  NSMutableDictionary *preferences;
}

@property (nonatomic, readonly) NSString *preferencesFile;
@property (nonatomic, readonly) NSString *documentsDirectory;

@end

@implementation RestaurantDataModel

@synthesize restaurantName_ = _restaurant;
@synthesize campusOption = _campusOption;
@synthesize restaurantOption = _restaurantOption;

+(RestaurantDataModel *) getInstance {
    static RestaurantDataModel *instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

-(instancetype) init {

  _campusOption = 0;
  _restaurantOption = 0;
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  if (![fileManager fileExistsAtPath: self.preferencesFile]) {
    preferences = [[NSMutableDictionary alloc] initWithDictionary:@{@"campusOption":[NSNumber numberWithInteger:_campusOption], @"restaurantOption":[NSNumber numberWithInteger: _restaurantOption]}];
    [preferences writeToFile:self.preferencesFile atomically:YES];
  } else {
    preferences = [[NSMutableDictionary alloc] initWithContentsOfFile:self.preferencesFile];
    _campusOption = [preferences[@"campusOption"] integerValue];
    _restaurantOption = [preferences[@"restaurantOption"] integerValue];
  }

  return self;
}

- (NSString *)preferencesFile {
  return [self.documentsDirectory stringByAppendingPathComponent:@"preferences.plist"];
}

- (void)setCampusOption:(NSInteger)campusOption {
  _campusOption = campusOption;
  preferences[@"campusOption"] = [NSNumber numberWithInteger:campusOption];
  [preferences writeToFile:self.preferencesFile atomically:YES];
}

- (void)setRestaurantOption:(NSInteger)restaurantOption {
  _restaurantOption = restaurantOption;
  preferences[@"filterOption"] = [NSNumber numberWithInteger:restaurantOption];
  [preferences writeToFile:self.preferencesFile atomically:YES];
}

@end
