//
//  EPPersistentStore.m
//  AgileToolbox
//
//  Created by Marcin Czenko on 28/01/14.
//
//

#import "EPPersistentStoreHelper.h"

@implementation EPPersistentStoreHelper

+ (NSURL*)persistentStateURLForFile:(NSString*)fileName
{
    NSFileManager* fileManager = [NSFileManager new];
    return [[fileManager URLForDirectory:NSApplicationSupportDirectory
                                inDomain:NSUserDomainMask
                       appropriateForURL:nil
                                  create:YES
                                   error:nil] URLByAppendingPathComponent:fileName];
}

+ (void)storeDictionary:(NSDictionary*)dictionary toFile:(NSString*)fileName
{
    NSURL* questionsDataSourceFileURL = [self persistentStateURLForFile:fileName];
    
    [dictionary writeToURL:questionsDataSourceFileURL atomically:YES];
}

+ (NSDictionary*)readDictionaryFromFile:(NSString*)fileName
{
    NSURL* questionsDataSourceFileURL = [self persistentStateURLForFile:fileName];
    return [[NSDictionary alloc] initWithContentsOfURL:questionsDataSourceFileURL];
}

+ (BOOL)archiveObject:(id)object toFile:(NSString*)fileName
{
    NSURL* fileURL = [self persistentStateURLForFile:fileName];
    return [NSKeyedArchiver archiveRootObject:object toFile:[fileURL path]];
}

+ (id)unarchiveObjectFromFile:(NSString*)fileName
{
    NSURL* fileURL = [self persistentStateURLForFile:fileName];
    
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[fileURL path]];
}

@end
