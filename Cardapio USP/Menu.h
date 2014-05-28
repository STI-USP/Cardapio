//
//  Menu.h
//  Menu USP
//
//  Created by Alessandro Souzadidier on 26/05/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Period;    

@interface Menu : NSObject{
    
}
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSMutableArray * period;


/**
 * Construtor da classe Menu
 *
 */

-(id)initWithMenu:(NSString *) _date Period:(NSMutableArray *) _period;

@end
