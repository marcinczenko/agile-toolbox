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

+ (void)deleteFile:(NSString*)fileName
{
    NSURL* fileURL = [self persistentStateURLForFile:fileName];
    
    NSFileManager* fileManager = [NSFileManager new];
    
    [fileManager removeItemAtURL:fileURL error:nil];
}

+ (void)storeDictionary:(NSDictionary*)dictionary toFile:(NSString*)fileName
{
#ifndef NO_STATE_PRESERVATION
    NSURL* questionsDataSourceFileURL = [self persistentStateURLForFile:fileName];
    
    [dictionary writeToURL:questionsDataSourceFileURL atomically:YES];
#endif
}

+ (NSDictionary*)readDictionaryFromFile:(NSString*)fileName
{
#ifndef NO_STATE_PRESERVATION
    NSURL* questionsDataSourceFileURL = [self persistentStateURLForFile:fileName];
    return [[NSDictionary alloc] initWithContentsOfURL:questionsDataSourceFileURL];
#else
    return nil;
#endif
}

+ (BOOL)archiveObject:(id)object toFile:(NSString*)fileName
{
#ifndef NO_STATE_PRESERVATION
    NSURL* fileURL = [self persistentStateURLForFile:fileName];
    return [NSKeyedArchiver archiveRootObject:object toFile:[fileURL path]];
#else
    return YES;
#endif

}

+ (id)unarchiveObjectFromFile:(NSString*)fileName
{
#ifndef NO_STATE_PRESERVATION
    NSURL* fileURL = [self persistentStateURLForFile:fileName];
    
    return [NSKeyedUnarchiver unarchiveObjectWithFile:[fileURL path]];
#else
    return nil;
#endif
}

@end
