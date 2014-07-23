//
//  Cash.h
//  Cardapio USP
//
//  Created by Alessandro Souzadidier on 29/05/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cash : NSObject{
    
}
@property (nonatomic, retain) NSString *workinghours;
@property (nonatomic, retain) NSMutableArray *items;

/**
 * Construtor da classe cash
 *
 */

-(id)initWithMenu:(NSString *)_workinghours andItems:(NSMutableArray *)_items;
@end
