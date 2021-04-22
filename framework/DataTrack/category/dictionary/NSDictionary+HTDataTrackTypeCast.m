//
//  NSDictionary+HTTypeCast.m
//  libcocos2d Mac
//
//  Created by 伟东 on 2020/7/6.
//

#import "NSDictionary+HTDataTrackTypeCast.h"
#import "NSString+HTDataTrackTSimpleMatching.h"
#import "HTDataTrackTTypeCastUtil.h"


/**
 *  返回根据所给key值在当前字典对象上对应的值.
 */
#define OFK [self objectForKey:key]

@implementation NSDictionary (HTDataTrackTypeCast)


- (BOOL)htdt_hasKey:(NSString *)key
{
    return (OFK != nil);
}

#pragma mark - NSObject

- (id)htdt_objectForKey:(NSString *)key
{
    return OFK;
}

- (id)htdt_unknownObjectForKey:(NSString*)key
{
    return OFK;
}


- (id)htdt_objectForKey:(NSString *)key class:(Class)clazz
{
    id obj = OFK;
    if ([obj isKindOfClass:clazz])
    {
        return obj;
    }
    
    return nil;
}

#pragma mark - NSNumber

- (NSNumber *)htdt_numberForKey:(NSString *)key defaultValue:(NSNumber *)defaultValue
{
    return htdt_numberOfValue(OFK, defaultValue);
}

- (NSNumber *)htdt_numberForKey:(NSString *)key
{
    return [self htdt_numberForKey:key defaultValue:nil];
}

#pragma mark - NSString

- (NSString *)htdt_stringForKey:(NSString *)key defaultValue:(NSString *)defaultValue;
{
    return htdt_stringOfValue(OFK, defaultValue);
}

- (NSString *)htdt_stringForKey:(NSString *)key;
{
    return [self htdt_stringForKey:key defaultValue:nil];
}


- (NSString *)htdt_validStringForKey:(NSString *)key
{
    NSString *stringValue = [self htdt_stringForKey:key];
    if (stringValue.length) {
        return stringValue;
    }
    return nil;
}

#pragma mark - NSArray of NSString

- (NSArray *)htdt_stringArrayForKey:(NSString *)key defaultValue:(NSArray *)defaultValue
{
    return htdt_stringArrayOfValue(OFK, defaultValue);
}

- (NSArray *)htdt_stringArrayForKey:(NSString *)key;
{
    return [self htdt_stringArrayForKey:key defaultValue:nil];
}

#pragma mark - NSDictionary

- (NSDictionary *)htdt_dictForKey:(NSString *)key defaultValue:(NSDictionary *)defaultValue
{
    return htdt_dictOfValue(OFK, defaultValue);
}

- (NSDictionary *)htdt_dictForKey:(NSString *)key
{
    return [self htdt_dictForKey:key defaultValue:nil];
}

- (NSDictionary *)htdt_validDictForKey:(NSString *)key
{
    NSDictionary *dictionary = [self htdt_dictForKey:key];
    if (dictionary.count) {
        return dictionary;
    }
    return nil;
}

- (NSDictionary *)htdt_dictionaryWithValuesForKeys:(NSArray *)keys
{
    return [self dictionaryWithValuesForKeys:keys];
}

#pragma mark - NSArray

- (NSArray *)htdt_arrayForKey:(NSString *)key defaultValue:(NSArray *)defaultValue
{
    return htdt_arrayOfValue(OFK, defaultValue);
}

- (NSArray *)htdt_arrayForKey:(NSString *)key
{
    return [self htdt_arrayForKey:key defaultValue:nil];
}

-(NSArray *)htdt_validArrayForKey:(NSString *)key
{
    NSArray *array = [self htdt_arrayForKey:key];
    if (array.count) {
        return array;
    }
    return nil;
}

#pragma mark - Float

- (float)htdt_floatForKey:(NSString *)key defaultValue:(float)defaultValue;
{
    return htdt_floatOfValue(OFK, defaultValue);
}

- (float)htdt_floatForKey:(NSString *)key;
{
    return [self htdt_floatForKey:key defaultValue:0.0f];
}

#pragma mark - Double

- (double)htdt_doubleForKey:(NSString *)key defaultValue:(double)defaultValue;
{
    return htdt_doubleOfValue(OFK, defaultValue);
}

- (double)htdt_doubleForKey:(NSString *)key;
{
    return [self htdt_doubleForKey:key defaultValue:0.0];
}

#pragma mark - CGPoint

- (CGPoint)htdt_pointForKey:(NSString *)key defaultValue:(CGPoint)defaultValue
{
    return htdt_pointOfValue(OFK, defaultValue);
}

- (CGPoint)htdt_pointForKey:(NSString *)key;
{
    return [self htdt_pointForKey:key defaultValue:HTZeroPoint];
}

#pragma mark - CGSize

- (CGSize)htdt_sizeForKey:(NSString *)key defaultValue:(CGSize)defaultValue;
{
    return htdt_sizeOfValue(OFK, defaultValue);
}

- (CGSize)htdt_sizeForKey:(NSString *)key;
{
    return [self htdt_sizeForKey:key defaultValue:HTZeroSize];
}

#pragma mark - CGRect

- (CGRect)htdt_rectForKey:(NSString *)key defaultValue:(CGRect)defaultValue;
{
    return htdt_rectOfValue(OFK, defaultValue);
}

- (CGRect)htdt_rectForKey:(NSString *)key;
{
    return [self htdt_rectForKey:key defaultValue:HTZeroRect];
}

#pragma mark - BOOL

- (BOOL)htdt_boolForKey:(NSString *)key defaultValue:(BOOL)defaultValue;
{
    return htdt_boolOfValue(OFK, defaultValue);
}

- (BOOL)htdt_boolForKey:(NSString *)key;
{
    return [self htdt_boolForKey:key defaultValue:NO];
}

#pragma mark - Int

- (int)htdt_intForKey:(NSString *)key defaultValue:(int)defaultValue;
{
    return htdt_intOfValue(OFK, defaultValue);
}

- (int)htdt_intForKey:(NSString *)key;
{
    return [self htdt_intForKey:key defaultValue:0];
}

#pragma mark - Unsigned Int

- (unsigned int)htdt_unsignedIntForKey:(NSString *)key defaultValue:(unsigned int)defaultValue;
{
    return htdt_unsignedIntOfValue(OFK, defaultValue);
}

- (unsigned int)htdt_unsignedIntForKey:(NSString *)key;
{
    return [self htdt_unsignedIntForKey:key defaultValue:0];
}

#pragma mark - Long Long

- (long long int)htdt_longLongForKey:(NSString *)key defaultValue:(long long int)defaultValue
{
    return htdt_longLongOfValue(OFK, defaultValue);
}

- (long long int)htdt_longLongForKey:(NSString *)key;
{
    return [self htdt_longLongForKey:key defaultValue:0LL];
}

#pragma mark - Unsigned Long Long

- (unsigned long long int)htdt_unsignedLongLongForKey:(NSString *)key defaultValue:(unsigned long long int)defaultValue;
{
    return htdt_unsignedLongLongOfValue(OFK, defaultValue);
}

- (unsigned long long int)htdt_unsignedLongLongForKey:(NSString *)key;
{
    return [self htdt_unsignedLongLongForKey:key defaultValue:0ULL];
}

#pragma mark - NSInteger

- (NSInteger)htdt_integerForKey:(NSString *)key defaultValue:(NSInteger)defaultValue;
{
    return htdt_integerOfValue(OFK, defaultValue);
}

- (NSInteger)htdt_integerForKey:(NSString *)key;
{
    return [self htdt_integerForKey:key defaultValue:0];
}

#pragma mark - Unsigned Integer

- (NSUInteger)htdt_unsignedIntegerForKey:(NSString *)key defaultValue:(NSUInteger)defaultValue
{
    return htdt_unsignedIntegerOfValue(OFK, defaultValue);
}

- (NSUInteger)htdt_unsignedIntegerForKey:(NSString *)key
{
    return [self htdt_unsignedIntegerForKey:key defaultValue:0];
}

#pragma mark - UIImage

- (UIImage *)htdt_imageForKey:(NSString *)key defaultValue:(UIImage *)defaultValue
{
    return htdt_imageOfValue(OFK, defaultValue);
}

- (UIImage *)htdt_imageForKey:(NSString *)key
{
    return [self htdt_imageForKey:key defaultValue:nil];
}

#pragma mark - UIColor

- (UIColor *)htdt_colorForKey:(NSString *)key defaultValue:(UIColor *)defaultValue
{
    return htdt_colorOfValue(OFK, defaultValue);
}

- (UIColor *)htdt_colorForKey:(NSString *)key
{
    return [self htdt_colorForKey:key defaultValue:[UIColor whiteColor]];
}

#pragma mark - Time

- (time_t)htdt_timeForKey:(NSString *)key defaultValue:(time_t)defaultValue
{
    return htdt_timeOfValue(OFK, defaultValue);
}

- (time_t)htdt_timeForKey:(NSString *)key
{
    time_t defaultValue = [[NSDate date] timeIntervalSince1970];
    return [self htdt_timeForKey:key defaultValue:defaultValue];
}

#pragma mark - NSDate

- (NSDate *)htdt_dateForKey:(NSString *)key
{
    return htdt_dateOfValue(OFK);
}

#pragma mark - NSURL
- (NSURL *)htdt_urlForKey:(NSString *)key defaultValue:(NSURL *)defaultValue
{
    return htdt_urlOfValue(OFK, defaultValue);
}

- (NSURL *)htdt_urlForKey:(NSString *)key
{
    return [self htdt_urlForKey:key defaultValue:nil];
}

#pragma mark - Enumerate

- (void)htdt_enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block
{
    [self enumerateKeysAndObjectsUsingBlock:block];
}

- (void)htdt_enumerateKeysAndUnknownObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block
{
    [self enumerateKeysAndObjectsUsingBlock:block];
}

- (void)htdt_enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block withCastFunction:(id (*)(id, id))castFunction
{
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        id castedObj = castFunction(obj, nil);
        if (castedObj)
        {
            block(key, castedObj, stop);
        }
    }];
}

- (void)htdt_enumerateKeysAndObjectsUsingBlock:(void (^)(id key, id obj, BOOL *stop))block classes:(id)object, ...
{
    if (!object) return;
    NSMutableArray* classesArray = [NSMutableArray array];
    id paraObj = object;
    va_list objects;
    va_start(objects, object);
    do
    {
        [classesArray addObject:paraObj];
        paraObj = va_arg(objects, id);
    } while (paraObj);
    va_end(objects);
    
    [self enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        BOOL allowBlock = NO;
        for (int i = 0; i < classesArray.count; i++)
        {
            if ([obj isKindOfClass:[classesArray objectAtIndex:i]])
            {
                allowBlock = YES;
                break;
            }
        }
        if (allowBlock)
        {
            block(key, obj, stop);
        }
    }];
}

- (void)htdt_enumerateKeysAndArrayObjectsUsingBlock:(void (^)(id key, NSArray *obj, BOOL *stop))block
{
    [self htdt_enumerateKeysAndObjectsUsingBlock:block withCastFunction:htdt_arrayOfValue];
}

- (void)htdt_enumerateKeysAndDictObjectsUsingBlock:(void (^)(id key, NSDictionary *obj, BOOL *stop))block
{
    [self htdt_enumerateKeysAndObjectsUsingBlock:block withCastFunction:htdt_dictOfValue];
}

- (void)htdt_enumerateKeysAndStringObjectsUsingBlock:(void (^)(id key, NSString *obj, BOOL *stop))block
{
    [self htdt_enumerateKeysAndObjectsUsingBlock:block withCastFunction:htdt_stringOfValue];
}

- (void)htdt_enumerateKeysAndNumberObjectsUsingBlock:(void (^)(id key, NSNumber *obj, BOOL *stop))block
{
    [self htdt_enumerateKeysAndObjectsUsingBlock:block withCastFunction:htdt_numberOfValue];
}

#pragma mark - Enumerate with Options

- (void)htdt_enumerateKeysAndObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id key, id obj, BOOL *stop))block
{
    [self enumerateKeysAndObjectsWithOptions:opts usingBlock:block];
}

- (void)htdt_enumerateKeysAndObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id key, id obj, BOOL *stop))block withCastFunction:(id (*)(id, id))castFunction
{
    [self enumerateKeysAndObjectsWithOptions:opts usingBlock:^(id key, id obj, BOOL *stop) {
        id castedObj = castFunction(obj, nil);
        if (castedObj)
        {
            block(key, castedObj, stop);
        }
    }];
}

- (void)htdt_enumerateKeysAndArrayObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id key, NSArray *obj, BOOL *stop))block
{
    [self htdt_enumerateKeysAndObjectsWithOptions:opts usingBlock:block withCastFunction:htdt_arrayOfValue];
}

- (void)htdt_enumerateKeysAndDictObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id key, NSDictionary *obj, BOOL *stop))block
{
    [self htdt_enumerateKeysAndObjectsWithOptions:opts usingBlock:block withCastFunction:htdt_dictOfValue];
}

- (void)htdt_enumerateKeysAndStringObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id key, NSString *obj, BOOL *stop))block
{
    [self htdt_enumerateKeysAndObjectsWithOptions:opts usingBlock:block withCastFunction:htdt_stringOfValue];
}

- (void)htdt_enumerateKeysAndNumberObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id key, NSNumber *obj, BOOL *stop))block
{
    [self htdt_enumerateKeysAndObjectsWithOptions:opts usingBlock:block withCastFunction:htdt_numberOfValue];
}

- (NSString *)htdt_toJSONStringWithSortedKeyAsc
{
    __block NSString *jsonString = nil;
    NSError *error = nil;
    NSData *httpData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:0
                                                         error:&error];
    jsonString = [[NSString alloc] initWithData:httpData encoding:NSUTF8StringEncoding];
    return jsonString;
}

@end

@implementation NSMutableDictionary (HTDataTrackTypeCast)

- (void)htdt_addEntriesFromDictionary:(NSDictionary *)dictionary classes:(id)object, ...
{
    if (!dictionary.count || !object) return;
    
    NSMutableArray* classesArray = [NSMutableArray array];
    id paraObj = object;
    va_list objects;
    va_start(objects, object);
    do
    {
        [classesArray addObject:paraObj];
        paraObj = va_arg(objects, id);
    } while (paraObj);
    va_end(objects);
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    [dictionary htdt_enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *dictionaryStop) {
        [classesArray enumerateObjectsUsingBlock:^(id clazz, NSUInteger idx, BOOL *classStop) {
            if ([obj isKindOfClass:clazz]) {
                [self setObject:obj forKey:key];
                *classStop = YES;
            }
        }];
    }];
#pragma clang diagnostic pop
}

@end
