//
//  NSString+HTUtilities.m
//  cocos2d_libs
//
//  Created by 伟东 on 2020/7/21.
//

#import "NSString+HTDataTrackUtilities.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>
#import <UIKit/UIKit.h>


// http://www.wilshipley.com/blog/2005/10/pimp-my-code-interlude-free-code.html
static inline BOOL htdt_IsEmpty(id thing) {
    return thing == nil ||
    ([thing isEqual:[NSNull null]]) ||
    ([thing respondsToSelector:@selector(length)] && [(NSData *)thing length] == 0) ||
    ([thing respondsToSelector:@selector(count)]  && [(NSArray *)thing count] == 0);
}

@implementation NSString (HTDataTrackNSStringUtils)

- (BOOL)htdt_isWhitespace {
    NSCharacterSet* whitespace = [NSCharacterSet whitespaceAndNewlineCharacterSet];
    for (NSInteger i = 0; i < self.length; ++i) {
        unichar c = [self characterAtIndex:i];
        if (![whitespace characterIsMember:c]) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)htdt_isEmptyOrWhitespace {
    return !self.length ||
    ![self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]].length;
}

- (BOOL)htdt_isEmptyWhitespaceOrNewLines
{
    return !self.length || ![self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length;
}

- (NSString *)htdt_stringWithMaxLength:(NSUInteger)maxLen {
    NSUInteger length = [self length];
    if (length <= maxLen || length <= 3) {
        return self;
    }
    return [NSString stringWithFormat:@"%@...", [self substringToIndex:maxLen - 3]];
}


- (NSString *)htdt_stringByReplacingRange:(NSRange)aRange with:(NSString *)aString {
    NSUInteger bufferSize;
    NSUInteger selfLen = [self length];
    NSUInteger aStringLen = [aString length];
    unichar *buffer;
    NSRange localRange;
    NSString *result;
    
    bufferSize = selfLen + aStringLen - aRange.length;
    buffer = NSAllocateMemoryPages(bufferSize*sizeof(unichar));
    
    /* Get first part into buffer */
    localRange.location = 0;
    localRange.length = aRange.location;
    [self getCharacters:buffer range:localRange];
    
    /* Get middle part into buffer */
    localRange.location = 0;
    localRange.length = aStringLen;
    [aString getCharacters:(buffer+aRange.location) range:localRange];
    
    /* Get last part into buffer */
    localRange.location = aRange.location + aRange.length;
    localRange.length = selfLen - localRange.location;
    [self getCharacters:(buffer+aRange.location+aStringLen) range:localRange];
    
    /* Build output string */
    result = [NSString stringWithCharacters:buffer length:bufferSize];
    
    NSDeallocateMemoryPages(buffer, bufferSize);
    
    return result;
}

- (NSString *)htdt_trimmedString
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

+ (NSString *)htdt_firstNonNsNullStringWithString:(NSString*)string, ...
{
    NSString* result = nil;
    
    id arg = nil;
    va_list argList;
    
    if (string && [string isKindOfClass:[NSString class]])
    {
        return string;
    }
    
    va_start(argList, string);
    while ((arg = va_arg(argList, id)))
    {
        if (arg && [arg isKindOfClass:[NSString class]])
        {
            result = arg;
            break;
        }
    }
    va_end(argList);
    
    
    return result;
}

@end


@implementation NSString  (HTDataTrackCreateUUID)
+ (NSString*) htdt_stringWithUUID {
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    NSString *UUIDstring = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
    CFRelease(uuidObj);
    return UUIDstring;// [UUIDstring autorelease];
}
+ (NSString*)htdt_stringWithNewUUID
{
    // Create a new UUID
    CFUUIDRef uuidObj = CFUUIDCreate(nil);
    
    // Get the string representation of the UUID
    NSString *newUUID = (NSString*)CFBridgingRelease(CFUUIDCreateString(nil, uuidObj));
    CFRelease(uuidObj);
    return newUUID;//[newUUID autorelease];
}
@end

@implementation NSString  (HTDataTrackRangeAvoidance)
- (BOOL) htdt_hasSubstring:(NSString*)substring;
{
    if(htdt_IsEmpty(substring))
        return NO;
    NSRange substringRange = [self rangeOfString:substring];
    return substringRange.location != NSNotFound && substringRange.length > 0;
}

- (NSString*) htdt_substringAfterSubstring:(NSString*)substring;
{
    if([self htdt_hasSubstring:substring])
        return [self substringFromIndex:NSMaxRange([self rangeOfString:substring])];
    return nil;
}

//Note: -isCaseInsensitiveLike should work when avalible!
- (BOOL) htdt_isEqualToStringIgnoringCase:(NSString*)otherString;
{
    if(!otherString)
        return NO;
    return NSOrderedSame == [self compare:otherString options:NSCaseInsensitiveSearch + NSWidthInsensitiveSearch];
}
@end


@implementation NSString (HTDataTrackIndempotentPercentEscapes)
- (NSString*) htdt_stringByReplacingPercentEscapesOnce;
{
    NSString *unescaped = [self stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //self may be a string that looks like an invalidly escaped string,
    //eg @"100%", in that case it clearly wasn't escaped,
    //so we return it as our unescaped string.
    return unescaped ? unescaped : self;
}
- (NSString*) htdt_stringByAddingPercentEscapesOnce;
{
    return [[self htdt_stringByReplacingPercentEscapesOnce] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}
@end

@implementation NSString (HTDataTrackCrypto)
- (NSString *)htdt_stringWithMD5
{
    unsigned char hashedChars[CC_MD5_DIGEST_LENGTH];
    
    const char *cData = [self cStringUsingEncoding:NSUTF8StringEncoding];
    
    CC_MD5(cData, (CC_LONG)strlen(cData), hashedChars);
    
    char hash[2 * sizeof(hashedChars) + 1];
    for (size_t i = 0; i < sizeof(hashedChars); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(hashedChars[i]));
    }
    
    return [NSString stringWithUTF8String:hash];
}

- (NSString *)htdt_stringWithMD5HexDigest
{
    const char* str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]
            ];
}

+ (NSString *)htdt_md5StringWithData:(NSData *)data
{
    unsigned char hashedChars[CC_MD5_DIGEST_LENGTH];
    
    const char *cData = [data bytes];
    
    CC_MD5(cData, (CC_LONG)[data length], hashedChars);
    
    char hash[2 * sizeof(hashedChars) + 1];
    
    for (size_t i = 0; i < sizeof(hashedChars); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(hashedChars[i]));
    }
    
    return [NSString stringWithUTF8String:hash];
}



@end
