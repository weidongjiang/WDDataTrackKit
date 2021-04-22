//
//  NSDictionary+HTKeyValue.m
//  libcocos2d Mac
//
//  Created by 伟东 on 2020/7/21.
//

#import "NSDictionary+HTDataTrackKeyValue.h"
#import "NSFileManager+HTDataTrackUtilities.h"

@implementation NSDictionary (HTDataTrackUtilities)

- (NSDictionary *)htdt_dictionaryBySettingObject:(id)value forKey:(id<NSCopying>)key
{
    if (!key) {
        return self;
    }
    NSMutableDictionary *new = [NSMutableDictionary dictionaryWithDictionary:self];
    if (value) {
        [new setObject:value forKey:key];
    }else{
        [new removeObjectForKey:key];
    }
    return [NSDictionary dictionaryWithDictionary:new];
}

- (NSDictionary *)htdt_dictionaryByAddingEntriesFromDictionary:(NSDictionary *)dictionary
{
    if (!dictionary) {
        return self;
    }
    NSMutableDictionary *new = [NSMutableDictionary dictionaryWithDictionary:self];
    [new addEntriesFromDictionary:dictionary];
    return [NSDictionary dictionaryWithDictionary:new];
}

- (NSDictionary *)htdt_dictionaryByRemovingNullValues
{
    NSMutableDictionary * result = [NSMutableDictionary dictionary];
    
    NSNull * null = [NSNull null];
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        if (obj == null) {
            return;
        } else if ([obj isKindOfClass:[NSDictionary class]]) {
            [result setObject:[obj htdt_dictionaryByRemovingNullValues] forKey:key];
        } else {
            [result setObject:obj forKey:key];
        }
    }];
    
    return result;
}

@end

@implementation NSMutableDictionary (YXDataTrackTSetValue)

- (void)htdt_removeObjectForKey:(nullable id)aKey
{
    if (aKey == nil)
    {
        return;
    }
    
    [self removeObjectForKey:aKey];
}

- (void)htdt_setSafeObject:(id)obj forKey:(id<NSCopying>)key
{
    if (obj == nil || [obj isKindOfClass:[NSNull class]] || key == nil)
        return;
    
    [self setObject:obj forKey:key];
}

- (void)htdt_setSafeObject:(id)obj forKey:(id<NSCopying>)key defaultObj:(id)defaultObj {
    if (key == nil || (obj == nil && defaultObj == nil)) {
        return;
    }
    
    if ([obj isKindOfClass:[NSNull class]] || [defaultObj isKindOfClass:[NSNull class]]) {
        return;
    }
    
    if (obj == nil && defaultObj) {
        [self setObject:defaultObj forKey:key];
        return;
    }
    
    [self setObject:obj forKey:key];
}

- (void)htdt_setObject:(id)obj forKey:(NSString*)key
{
    if (key == nil)
    {
        return;
    }
    if (!obj)
    {
        [self removeObjectForKey:key];
        return;
    }
    [self setObject:obj forKey:key];
}
@end


@implementation NSDictionary (HTDataTrackExtendedDictionary)

- (BOOL)htdt_saveToDocumentsPathFile:(NSString *)path
{
    if (path)
    {
        return [self writeToFile:htdt_DocumentFileWithName(path) atomically:NO];
    }
    return NO;
}

+ (NSDictionary *)htdt_loadDictioanryFromDocumentsPath:(NSString *)path
{
    if (path)
    {
        return [NSDictionary dictionaryWithContentsOfFile:htdt_DocumentFileWithName(path)];
    }
    return nil;
}

@end
