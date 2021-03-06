//
//  NSString+HTTSimpleMatching.m
//  cocos2d_libs
//
//  Created by 伟东 on 2020/7/6.
//

#import "NSString+HTDataTrackTSimpleMatching.h"

@implementation NSString (HTDataTrackTSimpleMatching)

// Returns YES if the string is nil or equal to @""
+ (BOOL)htdt_isEmptyString:(NSString *)string;
{
    // Note that [string length] == 0 can be false when [string isEqualToString:@""] is true, because these are Unicode strings.
    return string == nil || [string isEqualToString:@""];
}

- (BOOL)htdt_containsCharacterInSet:(NSCharacterSet *)searchSet;
{
    NSRange characterRange = [self rangeOfCharacterFromSet:searchSet];
    return characterRange.length != 0;
}

- (BOOL)htdt_containsString:(NSString *)searchString options:(unsigned int)mask;
{
    return !searchString || [searchString length] == 0 || [self rangeOfString:searchString options:mask].length > 0;
}

- (BOOL)htdt_containsString:(NSString *)searchString;
{
    return !searchString || [searchString length] == 0 || [self rangeOfString:searchString].length > 0;
}

- (BOOL)htdt_hasLeadingWhitespace;
{
    if ([self length] == 0)
        return NO;
    switch ([self characterAtIndex:0]) {
        case ' ':
        case '\t':
        case '\r':
        case '\n':
            return YES;
        default:
            return NO;
    }
}


@end
