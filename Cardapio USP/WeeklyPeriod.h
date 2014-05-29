//
//  WeeklyPeriod.h
//  Cardapio USP
//
//  Created by Alessandro Souzadidier on 28/05/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WeeklyPeriod : NSObject{
    
}

@property (nonatomic, retain) NSString * period;
@property (nonatomic, retain) NSString * breakfast;
@property (nonatomic, retain) NSString * lunch;
@property (nonatomic, retain) NSString * dinner;

/**
 * Construtor da classe WeeklyPeriod
 *
 */

-(id)initWithWeeklyPeriod:(NSString *) _period Breakfast:(NSString *) _breakfast Lunch:(NSString *) _lunch Dinner:(NSString *) _dinner;
@end
