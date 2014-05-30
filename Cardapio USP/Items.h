//
//  items.h
//  Cardapio USP
//
//  Created by Alessandro Souzadidier on 29/05/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Items : NSObject{
    
}
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * price;

/**
 * Construtor da classe items
 *
 */

-(id)initWithItems:(NSString *) _category Price:(NSString *) _price;

@end
