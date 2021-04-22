//
//  NSString+HTString.h
//  cocos2d_libs
//
//  Created by 伟东 on 2020/7/21.
//



#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@interface NSString (HTString)

/**
 *  字符串字数
 *  中文为 1 位，英文为 0.5 个
 *
 *  @return 字符串字数
 */
- (NSInteger)ht_stringCount;

/// 截取一定长度的字符串
/// @param length 特定长度
- (NSString *)ht_interceptionByGBK:(int)length;

/// 判断是否是在 len < 4 || len >30 的字符串
- (BOOL)ht_isValidNickname;

/// 判断字符是否在 len >36 的字符串
- (BOOL)ht_isValiddDesc;

/// 是否是电话号码
- (BOOL)ht_isPhoneNumber;

/// 是否是邮箱地址格式
- (BOOL)ht_isEmail;

/// 是否是 6-16位 之间的密码
- (BOOL)ht_isPassword;

/// 是否是 中国移动、中国联通、中国电信、大陆地区固话及小灵通
- (BOOL)ht_isMobileNumber;

/// MD5加密
- (NSString *)ht_MD5String;

/// 转json
- (id)ht_JSONValue;

/// 汉子首字母
- (NSString *)ht_getChineseCaptialChar;

/// @"89000" 字符串转换为秒数的结构
- (NSString *)ht_second2String;

/// urlEncode
- (NSString *)ht_urlEncode;
- (NSString *)ht_urlEncodeUsingEncoding:(NSStringEncoding)encoding;

/// urlDecode
- (NSString *)ht_urlDecode;
- (NSString *)ht_urlDecodeUsingEncoding:(NSStringEncoding)encoding;

- (NSString *)absoluteString;

/// url 参数转化为字典
- (NSDictionary*)ht_parseQuery;

/// 首字母大写
- (NSString *)ht_firstPYString;

/// 是否包括 emoji 表情符
/// @param string string description
+ (BOOL)ht_stringContainsEmoji:(NSString *)string;

//emoji按照一个character计算
- (NSUInteger)ht_realLength;

//获取指定长度字体的压缩字符串，性能不保证，不建议在高频计算中使用
- (NSString*)ht_limitStringWithFont:(UIFont*)font length:(CGFloat)length;

/// 字符串中有多少个对于 字符的个数
/// @param str 判断有多少个的字符
- (NSInteger)ht_calculateSubStringCount:(NSString*)str;

/**
 返回label可显示的合适字符串
 【解决表情字符只截一段问题】

 @param labelSize label的宽高
 @param font 字体
 @return 新得字符串
 */
- (NSString *)ht_clipFitStringForLabel:(CGSize)labelSize font:(UIFont *)font;

/**
 返回字符串对应字体下单行宽度

 @param font 字体大小
 @return 宽度
 */
- (CGFloat)ht_singleLineWidthWithFont:(UIFont*)font;
@end
