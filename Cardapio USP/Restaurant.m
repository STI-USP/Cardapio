//
//  Restaurant.m
//  Cardapio USP
//
//  Created by Alessandro Souzadidier on 28/05/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import "Restaurant.h"

@implementation Restaurant
@synthesize rid,title,address,name,phone,latitude,longitude,photourl, weeklyperiod;

/*
 * Construtor da classe Restaurant
 *
 */
-(id)initWithRestaurant:(NSString *) _rid Title:(NSString *) _title Name:(NSString *) _name Address:(NSString *) _address Phone:(NSString *) _phone Latitude:(NSString *) _latitude Longitude:(NSString *) _longitude Photourl:(NSString *) _photourl    WeeklyPeriod:(NSMutableArray *) _weeklyperiod {
    
    if(self == [super init]){
        self.rid = _rid;
        self.title = _title;
        self.name = _name;
        self.address = _address;
        self.phone = _phone;
        self.latitude = _latitude;
        self.longitude = _longitude;
        self.photourl = _photourl;
        self.weeklyperiod = _weeklyperiod;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)decoder {
    if(self == [super init]){
        self.rid = [decoder decodeObjectForKey:@"restaurant_rid"];
        self.title = [decoder decodeObjectForKey:@"restaurant_title"];
        self.name = [decoder decodeObjectForKey:@"restaurant_name"];
        self.address = [decoder decodeObjectForKey:@"restaurant_address"];
        self.phone = [decoder decodeObjectForKey:@"restaurant_phone"];
        self.latitude = [decoder decodeObjectForKey:@"restaurant_latitude"];
        self.longitude = [decoder decodeObjectForKey:@"restaurant_longitude"];
        self.photourl = [decoder decodeObjectForKey:@"restaurant_photourl"];
        self.weeklyperiod = [decoder decodeObjectForKey:@"restaurant_weeklyperiod"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.rid forKey:@"restaurant_rid"];
    [coder encodeObject:self.title forKey:@"restaurant_title"];
    [coder encodeObject:self.name forKey:@"restaurant_name"];
    [coder encodeObject:self.address forKey:@"restaurant_address"];
    [coder encodeObject:self.phone forKey:@"restaurant_phone"];
    [coder encodeObject:self.latitude forKey:@"restaurant_latitude"];
    [coder encodeObject:self.longitude forKey:@"restaurant_longitude"];
    [coder encodeObject:self.photourl forKey:@"restaurant_photourl"];
    [coder encodeObject:self.weeklyperiod forKey:@"restaurant_weeklyperiod"];
}

@end
