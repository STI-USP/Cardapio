//
//  Restaurant.h
//  Cardapio USP
//
//  Created by Alessandro Souzadidier on 28/05/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Restaurant : NSObject{
    
}
@property (nonatomic, retain) NSString * rid;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * latitude;
@property (nonatomic, retain) NSString * longitude;
@property (nonatomic, retain) NSString * photourl;
@property (nonatomic, retain) NSMutableArray * weeklyperiod;


/*
 * Construtor da classe Restaurant
 *
 */
-(id)initWithRestaurant:(NSString *) _rid Title:(NSString *) _title Name:(NSString *) _name Address:(NSString *) _address Phone:(NSString *) _phone Latitude:(NSString *) _latitude Longitude:(NSString *) _longitude Photourl:(NSString *) _photourl    WeeklyPeriod:(NSMutableArray *) _weeklyperiod;
@end
