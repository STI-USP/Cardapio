//
//  Cash.m
//  Cardapio USP
//
//  Created by Alessandro Souzadidier on 29/05/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import "Cash.h"

@implementation Cash
@synthesize workinghours, items;

-(id)initWithMenu:(NSString *) _workinghours Items:(NSMutableArray *) _items
{
    if(self == [super init]){
        self.workinghours = _workinghours;
        self.items = _items;  
    }
    return self;
}

- (id) initWithCoder:(NSCoder *)decoder {
    if(self == [super init]){
        self.workinghours = [decoder decodeObjectForKey:@"cash_workinghours"];
        self.items = [decoder decodeObjectForKey:@"cash_items"];
    }
    return self;
}
    
- (void) encodeWithCoder:(NSCoder *)coder {
    [coder encodeObject:self.workinghours forKey:@"cash_workinghours"];
    [coder encodeObject:self.items forKey:@"cash_items"];
}
@end
