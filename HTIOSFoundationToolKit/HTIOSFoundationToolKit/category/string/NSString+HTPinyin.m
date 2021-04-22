//
//  NSString+HTPinyin.m
//  HTIOSFoundationToolKit
//
//  Created by 伟东 on 2020/7/21.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "NSString+HTPinyin.h"

@implementation NSString (HTPinyin)

- (NSString *)ht_pinyin
{
    NSMutableString *str = [self mutableCopy];
    //转拼音
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformMandarinLatin, NO);
    //去音标
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformStripDiacritics, NO);
    
    return [str stringByReplacingOccurrencesOfString:@" " withString:@""];
}

//返回拼音首字母字符串
- (NSString *)ht_pinyinInitial
{
    NSMutableString *str = [self mutableCopy];
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform((CFMutableStringRef)str, NULL, kCFStringTransformStripDiacritics, NO);
    
    NSArray *word = [str componentsSeparatedByString:@" "];
    NSMutableString *initial = [[NSMutableString alloc] initWithCapacity:str.length / 3];
    for (NSString *str in word) {
        [initial appendString:[str substringToIndex:1]];
    }
    
    return initial;
}

@end
