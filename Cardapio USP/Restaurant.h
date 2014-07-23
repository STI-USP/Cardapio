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
@property (nonatomic, retain) NSString *rid;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) NSString *phone;
@property (nonatomic, retain) NSString *latitude;
@property (nonatomic, retain) NSString *longitude;
@property (nonatomic, retain) NSString *photourl;
@property (nonatomic, retain) NSMutableArray *weeklyperiod;


/*
 * Construtor da classe Restaurant
 *
 */
-(id)initWithId:(NSString *)_rid andTitle:(NSString *)_title andName:(NSString *)_name andAddress:(NSString *)_address andPhone:(NSString *)_phone andLatitude:(NSString *)_latitude andLongitude:(NSString *)_longitude andPhotoURL:(NSString *)_photoURL andWeeklyPeriod:(NSMutableArray *)_weeklyperiod;
@end
