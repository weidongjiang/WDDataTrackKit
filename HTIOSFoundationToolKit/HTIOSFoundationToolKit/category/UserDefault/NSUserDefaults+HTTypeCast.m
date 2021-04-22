//
//  NSUserDefaults+HTTypeCast.m
//  HTIOSFoundationToolKit
//
//  Created by 伟东 on 2020/7/22.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "NSUserDefaults+HTTypeCast.h"
#import "HTLTypeCastUtil.h"


#define OFK [self objectForKey:key]

@implementation NSUserDefaults (HTTypeCast)

- (BOOL)htl_hasKey:(NSString *)key
{
    return (OFK != nil);
}

#pragma mark - NSObject

- (id)htl_objectForKey:(NSString *)key __attribute__((deprecated))
{
    return OFK;
}

- (id)htl_unknownObjectForKey:(NSString *)key
{
    return OFK;
}

- (id)htl_objectForKey:(NSString *)key class:(Class)clazz
{
    id obj = OFK;
    if ([obj isKindOfClass:clazz])
    {
        return obj;
    }
    
    return nil;
}

#pragma mark - NSArray

- (NSArray *)htl_arrayForKey:(NSString *)key defaultValue:(NSArray *)defaultValue
{
    // htl_arrayOfValue 已实现判断
    return htl_arrayOfValue(OFK, defaultValue);
}

/// -arrayForKey: is equivalent to -objectForKey:, except that it will return nil if the value is not an NSArray.
- (NSArray *)htl_arrayForKey:(NSString *)key
{
    return [self htl_arrayForKey:key defaultValue:nil];
}

#pragma mark - BOOL

- (BOOL)htl_boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue
{
    if ([OFK isKindOfClass:[NSNumber class]])
    {
        return [OFK boolValue];
    }
    else if ([OFK isKindOfClass:[NSString class]])
    {
        if ([OFK isEqualToString:@"YES"])
        {
            return YES;
        }
        else return NO;
    }
    
    return htl_boolOfValue(OFK, defaultValue);
}

/*!
 -boolForKey: is equivalent to -objectForKey:, except that it converts the returned value to a BOOL. If the value is an NSNumber, NO will be returned if the value is 0, YES otherwise. If the value is an NSString, values of "YES" or "1" will return YES, and values of "NO", "0", or any other string will return NO. If the value is absent or can't be converted to a BOOL, NO will be returned.
 
 */
- (BOOL)htl_boolForKey:(NSString *)key
{
    return [self htl_boolForKey:key defaultValue:NO];
}

#pragma mark - NSDictionary

- (NSDictionary *)htl_dictionaryForKey:(NSString *)key defaultValue:(NSDictionary *)defaultValue
{
    // htl_dictOfValue 已实现判断
    return htl_dictOfValue(OFK, defaultValue);
}

/// -dictionaryForKey: is equivalent to -objectForKey:, except that it will return nil if the value is not an NSDictionary.
- (NSDictionary *)htl_dictionaryForKey:(NSString *)key
{
    return [self htl_dictionaryForKey:key defaultValue:nil];
}

#pragma mark - float

- (float)htl_floatForKey:(NSString *)key defaultValue:(float)defaultValue
{
    if ([OFK isKindOfClass:[NSNumber class]])
    {
        return [OFK floatValue];
    }
    else if ([OFK isKindOfClass:[NSString class]])
    {
        return [OFK floatValue];
    }
    return htl_floatOfValue(OFK, defaultValue);
}

/// -floatForKey: is similar to -integerForKey:, except that it returns a float, and boolean values will not be converted.
- (float)htl_floatForKey:(NSString *)key
{
    return [self htl_floatForKey:key defaultValue:0];
}

#pragma mark - double

- (double)htl_doubleForKey:(NSString *)key defaultValue:(double)defaultValue
{
    if ([OFK isKindOfClass:[NSNumber class]])
    {
        return [OFK doubleValue];
    }
    else if ([OFK isKindOfClass:[NSString class]])
    {
        return [OFK doubleValue];
    }
    return htl_doubleOfValue(OFK, defaultValue);
}

/// -doubleForKey: is similar to -doubleForKey:, except that it returns a double, and boolean values will not be converted.
- (double)htl_doubleForKey:(NSString *)key
{
    return [self htl_doubleForKey:key defaultValue:0];
}

#pragma mark - NSInteger

- (NSInteger)htl_integerForKey:(NSString *)key defaultValue:(NSInteger)defaultValue
{
    if ([OFK isKindOfClass:[NSNumber class]])
    {
        return [OFK integerValue];
    }
    else if ([OFK isKindOfClass:[NSString class]])
    {
        return [OFK integerValue];
    }
    
    return htl_integerOfValue(OFK, defaultValue);
}

/*!
 -integerForKey: is equivalent to -objectForKey:, except that it converts the returned value to an NSInteger. If the value is an NSNumber, the result of -integerValue will be returned. If the value is an NSString, it will be converted to NSInteger if possible. If the value is a boolean, it will be converted to either 1 for YES or 0 for NO. If the value is absent or can't be converted to an integer, 0 will be returned.
 */
- (NSInteger)htl_integerForKey:(NSString *)key
{
    return [self htl_integerForKey:key defaultValue:0];
}

#pragma mark - NSArray of NSString

- (NSArray *)htl_stringArrayForKey:(NSString *)key defaultValue:(NSArray *)defaultValue
{
    // htl_stringArrayOfValue 已实现判断
    return htl_stringArrayOfValue(OFK, defaultValue);
}

/// -stringForKey: is equivalent to -objectForKey:, except that it will return nil if the value is not an NSArray<NSString *>. Note that unlike -stringForKey:, NSNumbers are not converted to NSStrings.
- (NSArray *)htl_stringArrayForKey:(NSString *)key
{
    return [self htl_stringArrayForKey:key defaultValue:nil];
}

#pragma mark - NSString

- (NSString *)htl_stringForKey:(NSString *)key defaultValue:(NSString *)defaultValue
{
    if ([OFK isKindOfClass:[NSNumber class]])
    {
        return [OFK stringValue];
    }
    else if ([OFK isKindOfClass:[NSString class]])
    {
        return OFK;
    }
    
    return htl_stringOfValue(OFK, defaultValue);
}

/// -stringForKey: is equivalent to -objectForKey:, except that it will convert NSNumber values to their NSString representation. If a non-string non-number value is found, nil will be returned.
- (NSString *)htl_stringForKey:(NSString *)key
{
    return [self htl_stringForKey:key defaultValue:nil];
}

#pragma mark - NSURL

- (NSURL *)htl_urlForKey:(NSString *)key defaultValue:(NSURL *)defaultValue
{
    return htl_urlOfValue(OFK, defaultValue);
}

/*!
 -URLForKey: is equivalent to -objectForKey: except that it converts the returned value to an NSURL. If the value is an NSString path, then it will construct a file URL to that path. If the value is an archived URL from -setURL:forKey: it will be unarchived. If the value is absent or can't be converted to an NSURL, nil will be returned.
 */
- (NSURL *)htl_urlForKey:(NSString *)key
{
    return [self htl_urlForKey:key defaultValue:nil];
}

#pragma mark - NSData

- (NSData *)htl_dataForKey:(NSString *)key defaultValue:(NSData *)defaultValue
{
    // htl_dataOfValue 已实现判断，并且根据需要增加了对 NSString 的判断
    return htl_dataOfValue(OFK, defaultValue);
}

/// -dataForKey: is equivalent to -objectForKey:, except that it will return nil if the value is not an NSData.
- (NSData *)htl_dataForKey:(NSString *)key
{
    return [self htl_dataForKey:key defaultValue:nil];
}

#pragma mark - NSDate

- (NSDate *)htl_dateForKey:(NSString *)key defaultValue:(NSDate *)defaultValue
{
    if ([OFK isKindOfClass:[NSDate class]])
    {
        return OFK;
    }
    
    return htl_dateOfValue(OFK);
}

- (NSDate *)htl_dateForKey:(NSString *)key
{
    return [self htl_dateForKey:key defaultValue:nil];
}

#pragma mark - NSNumber

- (NSNumber *)htl_numberForKey:(NSString *)key defaultValue:(NSNumber *)defaultValue
{
    if ([OFK isKindOfClass:[NSNumber class]])
    {
        return OFK;
    }
    
    return defaultValue;
}

- (NSNumber *)htl_numberForKey:(NSString *)key
{
    return [self htl_numberForKey:key defaultValue:nil];
}

#pragma mark - unsigned long long int
- (unsigned long long int)htl_unsiginedlonglongvalueForKey:(NSString *)key defaultValue:(unsigned long long int)defaultValue
{
    return htl_unsignedLongLongOfValue(OFK, defaultValue);
}

- (unsigned long long int)htl_unsiginedlonglongvalueForKey:(NSString *)key
{
    return [self htl_unsiginedlonglongvalueForKey:key defaultValue:0];
}

#pragma mark - NSUInteger
- (NSUInteger)htl_unsiginedIntegerForKey:(NSString *)key defaultValue:(NSUInteger)defaultValue
{
    return htl_unsignedIntegerOfValue(OFK, defaultValue);
}

- (NSUInteger)htl_unsiginedIntegerForKey:(NSString *)key
{
    return [self htl_unsiginedIntegerForKey:key defaultValue:0];
}

@end
