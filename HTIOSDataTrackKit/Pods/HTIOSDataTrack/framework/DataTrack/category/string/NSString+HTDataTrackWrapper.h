//
//  NSString+HTWrapper.h
//  cocos2d_libs
//
//  Created by 伟东 on 2020/7/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (HTDataTrackWrapper)

- (unichar) htdt_charAt:(int)index;

- (int) htdt_compareTo:(NSString*) anotherString;

- (int) htdt_compareToIgnoreCase:(NSString*) str;

- (BOOL) htdt_contains:(NSString*) str;

- (BOOL) htdt_startsWith:(NSString*)prefix;

- (BOOL) htdt_endsWith:(NSString*)suffix;

- (BOOL) htdt_equals:(NSString*) anotherString;

- (BOOL) htdt_equalsIgnoreCase:(NSString*) anotherString;

- (int) htdt_indexOfChar:(unichar)ch;

- (int) htdt_indexOfChar:(unichar)ch fromIndex:(int)index;

- (int) htdt_indexOfString:(NSString*)str;

- (int) htdt_indexOfString:(NSString*)str fromIndex:(int)index;

- (int) htdt_lastIndexOfChar:(unichar)ch;

- (int) htdt_lastIndexOfChar:(unichar)ch fromIndex:(int)index;

- (int) htdt_lastIndexOfString:(NSString*)str;

- (int) htdt_lastIndexOfString:(NSString*)str fromIndex:(int)index;

- (NSString *) htdt_substringFromIndex:(int)beginIndex toIndex:(int)endIndex;

- (NSString *) htdt_toLowerCase;

- (NSString *) htdt_toUpperCase;

- (NSString *) htdt_trim;

- (NSString *) htdt_replaceAll:(NSString*)origin with:(NSString*)replacement;

- (NSArray *) htdt_split:(NSString*) separator;

#pragma mark - mine
- (BOOL)htdt_isNick;
- (BOOL)htdt_isIdentityNO;
+ (BOOL)htdt_isBlankString:(NSString *)string;
@end

NS_ASSUME_NONNULL_END
