//
//  NSString+HTString.h
//  cocos2d_libs
//
//  Created by 伟东 on 2020/7/21.
//



#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>

@interface NSString (HTDataTrackString)

/**
 *  字符串字数
 *  中文为 1 位，英文为 0.5 个
 *
 *  @return 字符串字数
 */
- (NSInteger)htdt_stringCount;
- (NSString *)htdt_interceptionByGBK:(int)length;

- (BOOL)htdt_isValidNickname;

- (BOOL)htdt_isValiddDesc;

- (BOOL)htdt_isPhoneNumber;

- (BOOL)htdt_isEmail;

- (BOOL)htdt_isPassword;

- (BOOL)htdt_isMobileNumber;

- (id)htdt_JSONValue;

- (NSString *)htdt_getChineseCaptialChar;

- (NSString *)htdt_MD5String;

- (NSString *)htdt_second2String;

- (NSString *)htdt_urlEncode;
- (NSString *)htdt_urlEncodeUsingEncoding:(NSStringEncoding)encoding;

- (NSString *)htdt_urlDecode;
- (NSString *)htdt_urlDecodeUsingEncoding:(NSStringEncoding)encoding;

- (NSString *)htdt_absoluteString;

- (NSDictionary*)htdt_parseQuery;
- (NSString *)htdt_firstPYString;

+ (BOOL)htdt_stringContainsEmoji:(NSString *)string;

//emoji按照一个character计算
- (NSUInteger)htdt_realLength;
//获取指定长度字体的压缩字符串，性能不保证，不建议在高频计算中使用
- (NSString*)htdt_limitStringWithFont:(UIFont*)font length:(CGFloat)length;

- (NSInteger)htdt_calculateSubStringCount:(NSString*)str;


/**
 返回label可显示的合适字符串
 【解决表情字符只截一段问题】

 @param labelSize label的宽高
 @param font 字体
 @return 新得字符串
 */
- (NSString *)htdt_clipFitStringForLabel:(CGSize)labelSize font:(UIFont *)font;

/**
 返回字符串对应字体下单行宽度

 @param font 字体大小
 @return 宽度
 */
- (CGFloat)htdt_singleLineWidthWithFont:(UIFont*)font;
@end
