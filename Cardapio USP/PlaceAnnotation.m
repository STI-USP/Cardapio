//
//  PlaceAnnotation.m
//  Mapa USP
//
//  Created by Jun Okamoto Jr. on 25/02/14.
//  Copyright (c) 2014 USP. All rights reserved.
//

#import "PlaceAnnotation.h"

@implementation PlaceAnnotation

- (id)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle andCoordinate:(CLLocationCoordinate2D)coordinate {
  self = [super init];
  if (self) {
    _title = title;
    _subtitle = subtitle;
    _coordinate = coordinate;
  }
  return self;  
}

@end
