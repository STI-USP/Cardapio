//
//  Menu.m
//  Menu USP
//
//  Created by Alessandro Souzadidier on 26/05/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import "Menu.h"
#import "Period.h"

@implementation Menu

@synthesize date, period;

/*
 * Construtor da classe Menu
 *
 */
-(id)initWithDate:(NSString *)_date andPeriod:(NSMutableArray *)_period {
    
    if(self == [super init]){
        self.date = _date;
        self.period = _period;
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)decoder {
    if(self == [super init]){
        self.date = [decoder decodeObjectForKey:@"menu_date"];
        self.period = [decoder decodeObjectForKey:@"menu_period"];
    }
    return self;
}

- (void) encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.date forKey:@"menu_date"];
    [coder encodeObject:self.period forKey:@"menu_period"];
}







@end
