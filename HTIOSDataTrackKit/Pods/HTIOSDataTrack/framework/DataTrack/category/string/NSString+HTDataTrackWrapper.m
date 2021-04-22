//
//  NSString+HTWrapper.m
//  cocos2d_libs
//
//  Created by 伟东 on 2020/7/21.
//

#import "NSString+HTDataTrackWrapper.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (HTDataTrackWrapper)

#define JavaNotFound -1

- (unichar) htdt_charAt:(int)index {
    return [self characterAtIndex:index];
}

- (int) htdt_compareTo:(NSString*) anotherString {
    return [self compare:anotherString];
}

/** Java-like method. Compares two strings lexicographically, ignoring case differences. */
- (int) htdt_compareToIgnoreCase:(NSString*) str {
    return [self compare:str options:NSCaseInsensitiveSearch];
}

/** Java-like method. Returns true if and only if this string contains the specified sequence of char values. */
- (BOOL) htdt_contains:(NSString*) str {
    NSRange range = [self rangeOfString:str];
    return (range.location != NSNotFound);
}

- (BOOL) htdt_startsWith:(NSString*)prefix {
    return [self hasPrefix:prefix];
}

- (BOOL) htdt_endsWith:(NSString*)suffix {
    return [self hasSuffix:suffix];
}

- (BOOL) htdt_equals:(NSString*) anotherString {
    return [self isEqualToString:anotherString];
}

- (BOOL) htdt_equalsIgnoreCase:(NSString*) anotherString {
    return [[self htdt_toLowerCase] htdt_equals:[anotherString htdt_toLowerCase]];
}

- (int) htdt_indexOfChar:(unichar)ch{
    return [self htdt_indexOfChar:ch fromIndex:0];
}

- (int) htdt_indexOfChar:(unichar)ch fromIndex:(int)index{
    int len = (int)self.length;
    for (int i = index; i < len; ++i) {
        if (ch == [self htdt_charAt:i]) {
            return i;
        }
    }
    return JavaNotFound;
}

- (int) htdt_indexOfString:(NSString*)str {
    NSRange range = [self rangeOfString:str];
    if (range.location == NSNotFound) {
        return JavaNotFound;
    }
    return (int)range.location;
}

- (int) htdt_indexOfString:(NSString*)str fromIndex:(int)index {
    NSRange fromRange = NSMakeRange(index, self.length - index);
    NSRange range = [self rangeOfString:str options:NSLiteralSearch range:fromRange];
    if (range.location == NSNotFound) {
        return JavaNotFound;
    }
    return (int)range.location;
}

- (int) htdt_lastIndexOfChar:(unichar)ch {
    int len = (int)self.length;
    for (int i = len-1; i >=0; --i) {
        if ([self htdt_charAt:i] == ch) {
            return i;
        }
    }
    return JavaNotFound;
}

- (int) htdt_lastIndexOfChar:(unichar)ch fromIndex:(int)index {
    int len = (int)self.length;
    if (index >= len) {
        index = len - 1;
    }
    for (int i = index; i >= 0; --i) {
        if ([self htdt_charAt:i] == ch) {
            return index;
        }
    }
    return JavaNotFound;
}

- (int) htdt_lastIndexOfString:(NSString*)str {
    NSRange range = [self rangeOfString:str options:NSBackwardsSearch];
    if (range.location == NSNotFound) {
        return JavaNotFound;
    }
    return (int)range.location;
}

- (int) htdt_lastIndexOfString:(NSString*)str fromIndex:(int)index {
    NSRange fromRange = NSMakeRange(0, index);
    NSRange range = [self rangeOfString:str options:NSBackwardsSearch range:fromRange];
    if (range.location == NSNotFound) {
        return JavaNotFound;
    }
    return (int)range.location;
}

- (NSString *) htdt_substringFromIndex:(int)beginIndex toIndex:(int)endIndex {
    if (endIndex <= beginIndex) {
        return @"";
    }
    NSRange range = NSMakeRange(beginIndex, endIndex - beginIndex);
    return [self substringWithRange:range];
}

- (NSString *) htdt_toLowerCase {
    return [self lowercaseString];
}

- (NSString *) htdt_toUpperCase {
    return [self uppercaseString];
}

- (NSString *) htdt_trim {
    if (self == nil || (NSNull*)self == [NSNull null]) {
        return @"";
    }
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSString *) htdt_replaceAll:(NSString*)origin with:(NSString*)replacement {
    return [self stringByReplacingOccurrencesOfString:origin withString:replacement];
}

- (NSArray *) htdt_split:(NSString*) separator {
    return [self componentsSeparatedByString:separator];
}

#pragma mark - mine


- (BOOL)htdt_isNick
{
    NSInteger count = [self lengthOfBytesUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
    if (count<4 || count>32) {
        return NO;
    }
    NSString *passwordRegex = @"^([\u4e00-\u9fa5]|[a-zA-Z0-9_]|-)+$";
    NSPredicate *passwordTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", passwordRegex];
    if(![passwordTest evaluateWithObject:self]){
        return NO;
    } else {
        return YES;
    }
}


- (BOOL)htdt_isIdentityNO
{
    if (self.length != 18) {
        return  NO;
    }
    NSArray* codeArray = [NSArray arrayWithObjects:@"7",@"9",@"10",@"5",@"8",@"4",@"2",@"1",@"6",@"3",@"7",@"9",@"10",@"5",@"8",@"4",@"2", nil];
    NSDictionary* checkCodeDic = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"1",@"0",@"X",@"9",@"8",@"7",@"6",@"5",@"4",@"3",@"2", nil]  forKeys:[NSArray arrayWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10", nil]];
    
    NSScanner* scan = [NSScanner scannerWithString:[self substringToIndex:17]];
    
    int val;
    BOOL isNum = [scan scanInt:&val] && [scan isAtEnd];
    if (!isNum) {
        return NO;
    }
    int sumValue = 0;
    
    for (int i =0; i<17; i++) {
        sumValue+=[[self substringWithRange:NSMakeRange(i , 1) ] intValue]* [[codeArray objectAtIndex:i] intValue];
    }
    
    NSString* strlast = [checkCodeDic objectForKey:[NSString stringWithFormat:@"%d",sumValue%11]];
    
    if ([strlast isEqualToString: [[self substringWithRange:NSMakeRange(17, 1)]uppercaseString]]) {
        return YES;
    }
    return  NO;
}


+ (BOOL)htdt_isBlankString:(NSString *)string
{
    
    if (string == nil) {
        return YES;
    }
    if (string == NULL) {
        return YES;
    }
    if (    [string isEqual:nil]
        ||  [string isEqual:Nil]){
        return YES;
    }
    if (![string isKindOfClass:[NSString class]]) {
        return YES;
    }
    if (0 == [string length]){
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    if([string isEqualToString:@"(null)"]){
        return YES;
    }
    
    return NO;
    
}


@end
