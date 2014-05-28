//
//  Lunch.h
//  Cardapio USP
//
//  Created by Alessandro Souzadidier on 26/05/14.
//  Copyright (c) 2014 EPUSP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Period: NSObject{
       
}

@property (nonatomic, retain) NSString * period;
@property (nonatomic, retain) NSString * menu;
@property (nonatomic, retain) NSString * calories;


/**
 * Construtor da classe Period
 *
 */

-(id)initWithPeriod:(NSString *) _period Menu:(NSString *) _menu Calories:(NSString *) _calories;


@end
