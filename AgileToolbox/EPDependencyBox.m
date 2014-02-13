//
//  EPDependencyBox.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 24/01/14.
//
//

#import "EPDependencyBox.h"

@interface EPDependencyBox ()

@property (nonatomic,strong) NSMutableDictionary* dependencies;

@end

@implementation EPDependencyBox

- (instancetype)init
{
    if ((self = [super init])) {
        _dependencies = [NSMutableDictionary new];
    }
    return self;
}

- (BOOL)hasDependencies
{
    return (0 < _dependencies.count);
}

- (id)objectForKeyedSubscript:(NSString*)key
{
    return self.dependencies[key];
}

- (void)setObject:(id)obj forKeyedSubscript:(NSString*)key
{
    self.dependencies[key] = obj;
}

- (void)removeDependencyForName:(NSString*)name
{
    [self.dependencies removeObjectForKey:name];
}

@end
