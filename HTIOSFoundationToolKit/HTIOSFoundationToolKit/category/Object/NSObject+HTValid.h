//
//  NSObject+HTValid.h
//  HTIOSFoundationToolKit
//
//  Created by 伟东 on 2020/7/21.
//  Copyright © 2020 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (HTValid)

/// 是否是nil  null 等的空的对象
- (BOOL)ht_isValid;

/// Class对象是否相等
/// @param aClass aClass description
- (BOOL)ht_isValidWithClass:(Class)aClass;

@end

NS_ASSUME_NONNULL_END
