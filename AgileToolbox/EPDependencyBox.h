//
//  EPDependencyBox.h
//  AgileToolbox
//
//  Created by Marcin Czenko on 24/01/14.
//
//

#import <Foundation/Foundation.h>

@interface EPDependencyBox : NSObject

- (BOOL)hasDependencies;

- (id)objectForKeyedSubscript:(NSString*)key;
- (void)setObject:(id)obj forKeyedSubscript:(NSString*)key;

- (void)removeDependencyForName:(NSString*)name;

@end
