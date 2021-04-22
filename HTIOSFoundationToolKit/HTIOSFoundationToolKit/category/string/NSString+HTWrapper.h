//
//  NSString+HTWrapper.h
//  cocos2d_libs
//
//  Created by 伟东 on 2020/7/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (HTWrapper)

/// 获取字符串中对应索引下的字符
/// @param index index description
- (unichar)ht_charAt:(int)index;

/// 比较两个字符串的大小
/// @param anotherString anotherString description
- (NSComparisonResult)ht_compareTo:(NSString *)anotherString;

/// 不区分大小写的比较两个字符串
/// @param str str description
- (NSComparisonResult)ht_compareToIgnoreCase:(NSString *)str;

/// 是否包含该字符串
/// @param str str description
- (BOOL)ht_contains:(NSString *)str;

/// 该字符串是否是以 prefix 开头的
/// @param prefix prefix description
- (BOOL)ht_startsWith:(NSString *)prefix;

/// 该字符串是否是以 suffix 结尾的
/// @param suffix suffix description
- (BOOL)ht_endsWith:(NSString *)suffix;

/// 两个字符串是否相等
/// @param anotherString anotherString description
- (BOOL)ht_equals:(NSString *)anotherString;

/// 字符串全部转化为小写 比较两个字符串是否相等
/// @param anotherString anotherString description
- (BOOL)ht_equalsIgnoreCase:(NSString *)anotherString;

/// 获取该字符 在字符串中的位置
/// @param ch ch description
- (int)ht_indexOfChar:(unichar)ch;

/// 从哪一个位置开始 检索字符在字符串中的位置
/// @param ch ch description
/// @param index index description
- (int)ht_indexOfChar:(unichar)ch fromIndex:(int)index;

/// 获取字符串 的位置
/// @param str str description
- (int)ht_indexOfString:(NSString *)str;

/// 获取从哪一个位置开始 字符串的位置
/// @param str str description
/// @param index index description
- (int)ht_indexOfString:(NSString *)str fromIndex:(int)index;

/// 从后面开始检索 字符在字符中的位置
/// @param ch ch description
- (int)ht_lastIndexOfChar:(unichar)ch;

/// 从哪个位置开始 从后面依次检索 字符在字符串中的位置
/// @param ch str description
/// @param index index description
- (int)ht_lastIndexOfChar:(unichar)ch fromIndex:(int)index;

/// 从后面开始检索字符串 的位置
/// @param str str description
- (int)ht_lastIndexOfString:(NSString *)str;

/// 从哪个位置开始 从后面依次检索 字符串在字符串中的位置
/// @param str str description
/// @param index index description
- (int)ht_lastIndexOfString:(NSString *)str fromIndex:(int)index;

/// 从哪个位置开始 哪个位置结束 截取字符串
/// @param beginIndex 开始位置
/// @param endIndex 结束位置
- (NSString *)ht_substringFromIndex:(int)beginIndex toIndex:(int)endIndex;

/// 全部转化为小写
- (NSString *)ht_toLowerCase;

/// 全部转化为大写
- (NSString *)ht_toUpperCase;

/// 去掉字符串两端的空格
- (NSString *)ht_trim;

/// 用 replacement 替换 origin
/// @param origin origin description
/// @param replacement replacement description
- (NSString *)ht_replaceAll:(NSString *)origin with:(NSString *)replacement;

/// 以哪一个字符串分割字符串为数组
/// @param separator separator description
- (NSArray *)ht_split:(NSString *)separator;

/// 是否是手机号
- (BOOL)ht_isPhoneNumber;

/// 是否是6-20位的密码
- (BOOL)ht_isPassword;

/// 是否是邮箱格式
- (BOOL)ht_isEmail;

/// MD5加密
- (NSString *)ht_MD5String;

/// 转化为国标码
- (NSInteger)ht_StringCount;

/// 是否是合法的字符串
/// @param string yes 不合法 no合法
+ (BOOL)ht_isBlankString:(NSString *)string;

@end

NS_ASSUME_NONNULL_END
