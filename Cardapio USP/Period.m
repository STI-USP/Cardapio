//
//  Lunch.m
//  Cardapio USP
//
//  Created by Alessandro Souzadidier on 26/05/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import "Period.h"

@implementation Period : NSObject 
@synthesize period, menu, calories;

/*
 * Construtor da classe Period
 *
 */
-(id)initWithPeriod:(NSString *)_period andMenu:(NSString *)_menu andCalories:(NSString *)_calories {
    
    if(self == [super init]){
        self.period = _period;
        self.menu = _menu;
        self.calories = _calories;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)decoder {
    if(self == [super init]){
        self.period = [decoder decodeObjectForKey:@"period_period"];
        self.menu = [decoder decodeObjectForKey:@"period_menu"];
        self.calories = [decoder decodeObjectForKey:@"period_calories"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.period forKey:@"period_period"];
    [coder encodeObject:self.menu forKey:@"period_menu"];
    [coder encodeObject:self.menu forKey:@"period_calories"];
}
@end
