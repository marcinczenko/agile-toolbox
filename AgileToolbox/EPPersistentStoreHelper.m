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
                                  create:NO
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

@end
