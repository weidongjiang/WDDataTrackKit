//
//  HTTTypeCastUtil.m
//  cocos2d_libs
//
//  Created by 伟东 on 2020/7/6.
//

#import "HTDataTrackTTypeCastUtil.h"
#import "NSString+HTDataTrackTSimpleMatching.h"
#import "NSObject+HTDataTrackTAssociatedObject.h"

id htdt_nonnullValue(id value)
{
    if (nil == value) return nil;
    
    if ([value isKindOfClass:NSDictionary.class])
    {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [(NSDictionary *)value enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            if (obj != [NSNull null]) {
                
                obj = htdt_nonnullValue(obj);
                if (nil != obj)
                {
                    [dict setObject:obj forKey:key];
                }
                
            }
        }];
        
        return dict;
    }
    else if ([value isKindOfClass:NSArray.class])
    {
        NSMutableArray *array = [NSMutableArray array];
        [(NSArray *)value enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (obj != [NSNull null]) {
                
                obj = htdt_nonnullValue(obj);
                if (nil != obj)
                {
                    [array addObject:obj];
                }
                
            }
        }];
        return array;
    }
    else if (value != [NSNull null])
    {
        return value;
    }
    
    return nil;
}

NSNumber *htdt_numberOfValue(id value, NSNumber *defaultValue)
{
    NSNumber *returnValue = defaultValue;
    if (![value isKindOfClass:[NSNumber class]])
    {
        if ([value isKindOfClass:NSString.class])
        {
            NSThread *thread = [NSThread currentThread];
            NSNumberFormatter *formatter = [thread htdt_objectWithAssociatedKey:@"TypeCastUtil.NumberFormatter"];
            if (!formatter)
            {
                formatter = [[NSNumberFormatter alloc] init] ;//autorelease];
                [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
                [thread htdt_setObject:formatter forAssociatedKey:@"TypeCastUtil.NumberFormatter" retained:YES];
            }
            
            returnValue = [formatter numberFromString:(NSString *)value];
        }
    }
    else
    {
        returnValue = value;
    }
    
    return returnValue;
}

NSString *htdt_stringOfValue(id value, NSString *defaultValue)
{
    if (![value isKindOfClass:[NSString class]])
    {
        if ([value isKindOfClass:[NSNumber class]])
        {
            return [value stringValue];
        }
        return defaultValue;
    }
    return value;
}

NSArray *htdt_stringArrayOfValue(id value, NSArray *defaultValue)
{
    if (![value isKindOfClass:[NSArray class]])
        return defaultValue;
    
    for (id item in value) {
        if (![item isKindOfClass:[NSString class]])
            return defaultValue;
    }
    return value;
}

NSDictionary *htdt_dictOfValue(id value, NSDictionary *defaultValue)
{
    if ([value isKindOfClass:[NSDictionary class]])
        return value;
    
    return defaultValue;
}

NSArray *htdt_arrayOfValue(id value ,NSArray *defaultValue)
{
    if ([value isKindOfClass:[NSArray class]])
        return value;
    
    return defaultValue;
}

float htdt_floatOfValue(id value, float defaultValue)
{
    if ([value respondsToSelector:@selector(floatValue)])
        return [value floatValue];
    
    return defaultValue;
}

double htdt_doubleOfValue(id value, double defaultValue)
{
    if ([value respondsToSelector:@selector(doubleValue)])
        return [value doubleValue];
    
    return defaultValue;
}

CGPoint htdt_pointOfValue(id value, CGPoint defaultValue)
{
    if ([value isKindOfClass:[NSString class]] && ![NSString htdt_isEmptyString:value])
        return HTPointFromString(value);
    else if ([value isKindOfClass:[NSValue class]])
        return [value CGPointValue];
    
    return defaultValue;
}

CGSize htdt_sizeOfValue(id value, CGSize defaultValue)
{
    if ([value isKindOfClass:[NSString class]] && ![NSString htdt_isEmptyString:value])
        return HTSizeFromString(value);
    else if ([value isKindOfClass:[NSValue class]])
        return [value CGSizeValue];
    
    return defaultValue;
}

CGRect htdt_rectOfValue(id value, CGRect defaultValue)
{
    if ([value isKindOfClass:[NSString class]] && ![NSString htdt_isEmptyString:value])
        return HTRectFromString(value);
    else if ([value isKindOfClass:[NSValue class]])
        return [value CGRectValue];
    
    return defaultValue;
}

BOOL htdt_boolOfValue(id value, BOOL defaultValue)
{
    if ([value respondsToSelector:@selector(boolValue)])
        return [value boolValue];
    
    return defaultValue;
}

int htdt_intOfValue(id value, int defaultValue)
{
    if ([value respondsToSelector:@selector(intValue)])
        return [value intValue];
    
    return defaultValue;
}

unsigned int htdt_unsignedIntOfValue(id value, unsigned int defaultValue)
{
    if ([value respondsToSelector:@selector(unsignedIntValue)])
        return [value unsignedIntValue];
    
    return defaultValue;
}

long long int htdt_longLongOfValue(id value, long long int defaultValue)
{
    if ([value respondsToSelector:@selector(longLongValue)])
        return [value longLongValue];
    
    return defaultValue;
}

unsigned long long int htdt_unsignedLongLongOfValue(id value, unsigned long long int defaultValue)
{
    if ([value respondsToSelector:@selector(unsignedLongLongValue)])
        return [value unsignedLongLongValue];
    
    return defaultValue;
}

NSInteger htdt_integerOfValue(id value, NSInteger defaultValue)
{
    if ([value respondsToSelector:@selector(integerValue)])
        return [value integerValue];
    
    return defaultValue;
}

NSUInteger htdt_unsignedIntegerOfValue(id value, NSUInteger defaultValue)
{
    if ([value respondsToSelector:@selector(unsignedIntegerValue)])
        return [value unsignedIntegerValue];
    
    return defaultValue;
}

UIImage *htdt_imageOfValue(id value, UIImage *defaultValue)
{
    if ([value isKindOfClass:[UIImage class]])
        return value;
    
    return defaultValue;
}

UIColor *htdt_colorOfValue(id value, UIColor *defaultValue)
{
    if ([value isKindOfClass:[UIColor class]])
        return value;
    
    return defaultValue;
}

time_t htdt_timeOfValue(id value, time_t defaultValue)
{
    NSString *stringTime = htdt_stringOfValue(value, nil);
    
    struct tm created;
    time_t now;
    time(&now);
    
    if (stringTime)
    {
        if (strptime([stringTime UTF8String], "%a %b %d %H:%M:%S %z %Y", &created) == NULL)
        {
            strptime([stringTime UTF8String], "%a, %d %b %Y %H:%M:%S %z", &created);
        }
        return mktime(&created);
    }
    
    return defaultValue;
}

NSDate *htdt_dateOfValue(id value)
{
    if ([value isKindOfClass:[NSNumber class]])
    {
        return [NSDate dateWithTimeIntervalSince1970:[value intValue]];
    }
    else if ([value isKindOfClass:[NSString class]] && [value length] > 0)
    {
        return [NSDate dateWithTimeIntervalSince1970:htdt_timeOfValue(value, [[NSDate date] timeIntervalSince1970])];
    }
    
    return nil;
}

NSURL *htdt_urlOfValue(id value, NSURL *defaultValue)
{
    if ([value isKindOfClass:[NSURL class]])
        return value;
    
    return defaultValue;
}
