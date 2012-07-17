//
//  QATPostURLRequest.h
//  AgileToolbox
//
//  Created by AtrBea on 7/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface QATJSONPostURLRequest : NSMutableURLRequest

- (id)initWithURL:(NSURL *)URL;
- (id)initWithURL:(NSURL *)URL body:(NSData*)bodyData;

@end