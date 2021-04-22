//
//  NSArray+HTTypeCast.m
//  libcocos2d Mac
//
//  Created by 伟东 on 2020/7/6.
//

#import "NSArray+HTDataTrackTypeCast.h"
#import "HTDataTrackTTypeCastUtil.h"


#define OAI [self htdt_safeObjectAtIndex:index]

@implementation NSArray (HTDataTrackTypeCast)

- (id)htdt_safeObjectAtIndex:(NSUInteger)index
{
    return (index >= self.count) ? nil : [self objectAtIndex:index];
}

#pragma mark - NSObject

- (id)htdt_objectAtIndex:(NSUInteger)index
{
    return OAI;
}

- (id)htdt_unknownObjectAtIndex:(NSUInteger)index
{
    return OAI;
}

#pragma mark - NSNumber

- (NSNumber *)htdt_numberAtIndex:(NSUInteger)index defaultValue:(NSNumber *)defaultValue
{
    return htdt_numberOfValue(OAI, defaultValue);
}

- (NSNumber *)htdt_numberAtIndex:(NSUInteger)index
{
    return [self htdt_numberAtIndex:index defaultValue:nil];
}

#pragma mark - NSString

- (NSString *)htdt_stringAtIndex:(NSUInteger)index defaultValue:(NSString *)defaultValue;
{
    return htdt_stringOfValue(OAI, defaultValue);
}

- (NSString *)htdt_stringAtIndex:(NSUInteger)index;
{
    return [self htdt_stringAtIndex:index defaultValue:nil];
}

- (NSString *)htdt_validStringAtIndex:(NSUInteger)index
{
    NSString *string = [self htdt_stringAtIndex:index];
    if (string.length) {
        return string;
    }
    return nil;
}

#pragma mark - NSArray of NSString

- (NSArray *)htdt_stringArrayAtIndex:(NSUInteger)index defaultValue:(NSArray *)defaultValue
{
    return htdt_stringArrayOfValue(OAI, defaultValue);
}

- (NSArray *)htdt_stringArrayAtIndex:(NSUInteger)index;
{
    return [self htdt_stringArrayAtIndex:index defaultValue:nil];
}

#pragma mark - NSDictionary

- (NSDictionary *)htdt_dictAtIndex:(NSUInteger)index defaultValue:(NSDictionary *)defaultValue
{
    return htdt_dictOfValue(OAI, defaultValue);
}

- (NSDictionary *)htdt_dictAtIndex:(NSUInteger)index
{
    return [self htdt_dictAtIndex:index defaultValue:nil];
}

-(NSDictionary *)htdt_validDictAtIndex:(NSUInteger)index
{
    NSDictionary *dictionary = [self htdt_dictAtIndex:index];
    if (dictionary.count) {
        return dictionary;
    }
    return nil;
}

#pragma mark - NSArray

- (NSArray *)htdt_arrayAtIndex:(NSUInteger)index defaultValue:(NSArray *)defaultValue
{
    return htdt_arrayOfValue(OAI, defaultValue);
}

- (NSArray *)htdt_arrayAtIndex:(NSUInteger)index
{
    return [self htdt_arrayAtIndex:index defaultValue:nil];
}

- (NSArray *)htdt_validArrayAtIndex:(NSUInteger)index
{
    NSArray *array = [self htdt_arrayAtIndex:index];
    if (array.count) {
        return array;
    }
    return nil;
}

#pragma mark - Float

- (float)htdt_floatAtIndex:(NSUInteger)index defaultValue:(float)defaultValue;
{
    return htdt_floatOfValue(OAI, defaultValue);
}

- (float)htdt_floatAtIndex:(NSUInteger)index;
{
    return [self htdt_floatAtIndex:index defaultValue:0.0f];
}

#pragma mark - Double

- (double)htdt_doubleAtIndex:(NSUInteger)index defaultValue:(double)defaultValue;
{
    return htdt_doubleOfValue(OAI, defaultValue);
}

- (double)htdt_doubleAtIndex:(NSUInteger)index;
{
    return [self htdt_doubleAtIndex:index defaultValue:0.0];
}

#pragma mark - CGPoint

- (CGPoint)htdt_pointAtIndex:(NSUInteger)index defaultValue:(CGPoint)defaultValue
{
    return htdt_pointOfValue(OAI, defaultValue);
}

- (CGPoint)htdt_pointAtIndex:(NSUInteger)index;
{
    return [self htdt_pointAtIndex:index defaultValue:HTZeroPoint];
}

#pragma mark - CGSize

- (CGSize)htdt_sizeAtIndex:(NSUInteger)index defaultValue:(CGSize)defaultValue;
{
    return htdt_sizeOfValue(OAI, defaultValue);
}

- (CGSize)htdt_sizeAtIndex:(NSUInteger)index;
{
    return [self htdt_sizeAtIndex:index defaultValue:HTZeroSize];
}

#pragma mark - CGRect

- (CGRect)htdt_rectAtIndex:(NSUInteger)index defaultValue:(CGRect)defaultValue;
{
    return htdt_rectOfValue(OAI, defaultValue);
}

- (CGRect)htdt_rectAtIndex:(NSUInteger)index;
{
    return [self htdt_rectAtIndex:index defaultValue:HTZeroRect];
}

#pragma mark - BOOL

- (BOOL)htdt_boolAtIndex:(NSUInteger)index defaultValue:(BOOL)defaultValue;
{
    return htdt_boolOfValue(OAI, defaultValue);
}

- (BOOL)htdt_boolAtIndex:(NSUInteger)index;
{
    return [self htdt_boolAtIndex:index defaultValue:NO];
}

#pragma mark - Int

- (int)htdt_intAtIndex:(NSUInteger)index defaultValue:(int)defaultValue;
{
    return htdt_intOfValue(OAI, defaultValue);
}

- (int)htdt_intAtIndex:(NSUInteger)index;
{
    return [self htdt_intAtIndex:index defaultValue:0];
}

#pragma mark - Unsigned Int

- (unsigned int)htdt_unsignedIntAtIndex:(NSUInteger)index defaultValue:(unsigned int)defaultValue;
{
    return htdt_unsignedIntOfValue(OAI, defaultValue);
}

- (unsigned int)htdt_unsignedIntAtIndex:(NSUInteger)index;
{
    return [self htdt_unsignedIntAtIndex:index defaultValue:0];
}

#pragma mark - Long Long

- (long long int)htdt_longLongAtIndex:(NSUInteger)index defaultValue:(long long int)defaultValue
{
    return htdt_longLongOfValue(OAI, defaultValue);
}

- (long long int)htdt_longLongAtIndex:(NSUInteger)index
{
    return [self htdt_longLongAtIndex:index defaultValue:0LL];
}

#pragma mark - Unsigned Long Long

- (unsigned long long int)htdt_unsignedLongLongAtIndex:(NSUInteger)index defaultValue:(unsigned long long int)defaultValue;
{
    return htdt_unsignedLongLongOfValue(OAI, defaultValue);
}

- (unsigned long long int)htdt_unsignedLongLongAtIndex:(NSUInteger)index;
{
    return [self htdt_unsignedLongLongAtIndex:index defaultValue:0ULL];
}

#pragma mark - NSInteger

- (NSInteger)htdt_integerAtIndex:(NSUInteger)index defaultValue:(NSInteger)defaultValue;
{
    return htdt_integerOfValue(OAI, defaultValue);
}

- (NSInteger)htdt_integerAtIndex:(NSUInteger)index;
{
    return [self htdt_integerAtIndex:index defaultValue:0];
}

#pragma mark - Unsigned Integer

- (NSUInteger)htdt_unsignedIntegerAtIndex:(NSUInteger)index defaultValue:(NSUInteger)defaultValue
{
    return htdt_unsignedIntegerOfValue(OAI, defaultValue);
}

- (NSUInteger)htdt_unsignedIntegerAtIndex:(NSUInteger)index
{
    return [self htdt_unsignedIntegerAtIndex:index defaultValue:0];
}

#pragma mark - UIImage

- (UIImage *)htdt_imageAtIndex:(NSUInteger)index defaultValue:(UIImage *)defaultValue
{
    return htdt_imageOfValue(OAI, defaultValue);
}

- (UIImage *)htdt_imageAtIndex:(NSUInteger)index
{
    return [self htdt_imageAtIndex:index defaultValue:nil];
}

#pragma mark - UIColor

- (UIColor *)htdt_colorAtIndex:(NSUInteger)index defaultValue:(UIColor *)defaultValue
{
    return htdt_colorOfValue(OAI, defaultValue);
}

- (UIColor *)htdt_colorAtIndex:(NSUInteger)index
{
    return [self htdt_colorAtIndex:index defaultValue:[UIColor whiteColor]];
}

#pragma mark - Time

- (time_t)htdt_timeAtIndex:(NSUInteger)index defaultValue:(time_t)defaultValue
{
    return htdt_timeOfValue(OAI, defaultValue);
}

- (time_t)htdt_timeAtIndex:(NSUInteger)index
{
    time_t defaultValue = [[NSDate date] timeIntervalSince1970];
    return [self htdt_timeAtIndex:index defaultValue:defaultValue];
}

#pragma mark - NSDate

- (NSDate *)htdt_dateAtIndex:(NSUInteger)index
{
    return htdt_dateOfValue(OAI);
}

#pragma mark - NSURL
- (NSURL *)htdt_urlAtIndex:(NSUInteger)index defaultValue:(NSURL *)defaultValue
{
    return htdt_urlOfValue(OAI, defaultValue);
}

- (NSURL *)htdt_urlForKey:(NSUInteger)index
{
    return [self htdt_urlAtIndex:index defaultValue:nil];
}

#pragma mark - Enumerate

- (void)htdt_enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block
{
    [self enumerateObjectsUsingBlock:block];
}

- (void)htdt_enumerateUnknownObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block
{
    [self enumerateObjectsUsingBlock:block];
}

- (void)htdt_enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block withCastFunction:(id (*)(id, id))castFunction
{
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id castedObj = castFunction(obj, nil);
        if (castedObj)
        {
            block(castedObj, idx, stop);
        }
    }];
}

- (void)htdt_enumerateObjectsUsingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block classes:(id)object, ...
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
    
    [self enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
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
            block(obj, idx, stop);
        }
    }];
}

- (void)htdt_enumerateArrayObjectsUsingBlock:(void (^)(NSArray *obj, NSUInteger idx, BOOL *stop))block
{
    [self htdt_enumerateObjectsUsingBlock:block withCastFunction:htdt_arrayOfValue];
}

- (void)htdt_enumerateDictObjectsUsingBlock:(void (^)(NSDictionary *obj, NSUInteger idx, BOOL *stop))block
{
    [self htdt_enumerateObjectsUsingBlock:block withCastFunction:htdt_dictOfValue];
}

- (void)htdt_enumerateStringObjectsUsingBlock:(void (^)(NSString *obj, NSUInteger idx, BOOL *stop))block
{
    [self htdt_enumerateObjectsUsingBlock:block withCastFunction:htdt_stringOfValue];
}

- (void)htdt_enumerateNumberObjectsUsingBlock:(void (^)(NSNumber *obj, NSUInteger idx, BOOL *stop))block
{
    [self htdt_enumerateObjectsUsingBlock:block withCastFunction:htdt_numberOfValue];
}

#pragma mark - Enumerate with Options

- (void)htdt_enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block
{
    [self enumerateObjectsWithOptions:opts usingBlock:block];
}

- (void)htdt_enumerateObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(id obj, NSUInteger idx, BOOL *stop))block withCastFunction:(id (*)(id, id))castFunction
{
    [self enumerateObjectsWithOptions:opts usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        id castedObj = castFunction(obj, nil);
        if (castedObj)
        {
            block(castedObj, idx, stop);
        }
    }];
}

- (void)htdt_enumerateArrayObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(NSArray *obj, NSUInteger idx, BOOL *stop))block
{
    [self htdt_enumerateObjectsWithOptions:opts usingBlock:block withCastFunction:htdt_arrayOfValue];
}

- (void)htdt_enumerateDictObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(NSDictionary *obj, NSUInteger idx, BOOL *stop))block
{
    [self htdt_enumerateObjectsWithOptions:opts usingBlock:block withCastFunction:htdt_dictOfValue];
}

- (void)htdt_enumerateStringObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(NSString *obj, NSUInteger idx, BOOL *stop))block
{
    [self htdt_enumerateObjectsWithOptions:opts usingBlock:block withCastFunction:htdt_stringOfValue];
}

- (void)htdt_enumerateNumberObjectsWithOptions:(NSEnumerationOptions)opts usingBlock:(void (^)(NSNumber *obj, NSUInteger idx, BOOL *stop))block
{
    [self htdt_enumerateObjectsWithOptions:opts usingBlock:block withCastFunction:htdt_numberOfValue];
}

- (NSArray *)htdt_typeCastedObjectsWithCastFunction:(id (*)(id, id))castFunction
{
    NSMutableArray * result = [NSMutableArray array];
    [self htdt_enumerateObjectsWithOptions:0 usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if (obj) {
            [result addObject:obj];
        }
    } withCastFunction:castFunction];
    return result;
}

- (NSArray *)htdt_stringObjects
{
    return [self htdt_typeCastedObjectsWithCastFunction:htdt_stringOfValue];
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
