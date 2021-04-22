//
//  HTCategoryTools.h
//  cocos2d_libs
//
//  Created by 伟东 on 2020/7/6.
//

#ifndef HTCategoryTools_h
#define HTCategoryTools_h
// 屏幕判断和全面屏适配数据
#define KSafeAreaOffset 34
//判断iPhoneXK_
#define K_IS_IPHONE_X ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
//判断iPHoneXr
#define K_IS_IPHONE_Xr  ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : NO)
//判断iPhoneXs
#define K_IS_IPHONE_Xs ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
//判断iPhoneXs Max
#define K_IS_IPHONE_Xs_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO)
//判断iPhone11
#define K_IS_IPHONE_11 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(828, 1792), [[UIScreen mainScreen] currentMode].size) : NO)
//判断iPhone11 pro
#define K_IS_IPHONE_11_Pro ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1125, 2436), [[UIScreen mainScreen] currentMode].size) : NO)
//判断iPhone11 pro max
#define K_IS_IPHONE_11_Pro_Max ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(1242, 2688), [[UIScreen mainScreen] currentMode].size) : NO)
// 是否是带刘海的全面屏
#define K_iPhone_FullScreen ((K_IS_IPHONE_X || K_IS_IPHONE_Xr || K_IS_IPHONE_Xs || K_IS_IPHONE_Xs_Max || K_IS_IPHONE_11 || K_IS_IPHONE_11_Pro || K_IS_IPHONE_11_Pro_Max) ? YES : NO)
// 屏幕宽度
#define K_ScreenWidth ([UIScreen mainScreen].bounds.size.width)
// 屏幕高度
#define K_ScreenHeight ([UIScreen mainScreen].bounds.size.height)



#import "NSString+HTDataTrackTSimpleMatching.h"
#import "NSString+HTDataTrackString.h"
#import "NSString+HTDataTrackUtilities.h"
#import "NSString+HTDataTrackWrapper.h"

#import "NSDictionary+HTDataTrackTypeCast.h"
#import "NSDictionary+HTDataTrackKeyValue.h"

#import "NSArray+HTDataTrackUtilities.h"
#import "NSArray+HTDataTrackTypeCast.h"

#import "NSDate+HTDataTrackUtilities.h"

#endif /* HTCategoryTools_h */
