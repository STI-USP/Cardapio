//
//  STIOauth.h
//  Bibliotecas USP
//
//  Created by Vagner Machado on 4/2/15.
//  Copyright (c) 2015 USP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface STIOauth : NSObject

- (void)registrarToken:(NSString *)token;
- (void)invalidarToken:(NSString *)token;
+ (STIOauth *)sharedInstance;

@property (strong, nonatomic) NSURLSession *session;

@end
