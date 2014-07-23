//
//  WeeklyPeriod.m
//  Cardapio USP
//
//  Created by Alessandro Souzadidier on 28/05/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import "WeeklyPeriod.h"

@implementation WeeklyPeriod
@synthesize period, breakfast, lunch, dinner;

-(id)initWithWeeklyPeriod:(NSString *)_period andBreakfast:(NSString *)_breakfast andLunch:(NSString *)_lunch andDinner:(NSString *)_dinner
{
    if(self == [super init]){
        self.period = _period;
        self.breakfast = _breakfast;
        self.lunch = _lunch;
        self.dinner = _dinner;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)decoder {
    if(self == [super init]){
        self.period = [decoder decodeObjectForKey:@"weeklyperiod_period"];
        self.breakfast = [decoder decodeObjectForKey:@"weeklyperiod_breakfast"];
        self.lunch = [decoder decodeObjectForKey:@"weeklyperiod_lunch"];
        self.dinner = [decoder decodeObjectForKey:@"weeklyperiod_dinner"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.period forKey:@"weeklyperiod_period"];
    [coder encodeObject:self.breakfast forKey:@"weeklyperiod_breakfast"];
    [coder encodeObject:self.lunch forKey:@"weeklyperiod_lunch"];
    [coder encodeObject:self.dinner forKey:@"weeklyperiod_dinner"];
}
@end
