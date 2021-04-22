//
//  NSString+HTPinyin.h
//  HTIOSFoundationToolKit
//
//  Created by 伟东 on 2020/7/21.
//  Copyright © 2020 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (HTPinyin)

/// 汉子转评语 并且去掉音标
- (NSString *)ht_pinyin;

/// 返回拼音首字母字符串
- (NSString *)ht_pinyinInitial;

@end

NS_ASSUME_NONNULL_END
