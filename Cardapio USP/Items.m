//
//  items.m
//  Cardapio USP
//
//  Created by Alessandro Souzadidier on 29/05/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import "Items.h"

@implementation Items
@synthesize category, price;

-(id)initWithItems:(NSString *) _category Price:(NSString *) _price
{
    
    if(self == [super init]){
        self.category = _category;
        self.price = _price;
    }
    return self;
}
@end
