//
//  UIView+Util.h
//  cocos2d_libs
//
//  Created by 伟东 on 2020/7/6.
//

#import <UIKit/UIKit.h>

#define   SWIDTH     [UIScreen mainScreen].bounds.size.width
#define   SHEIGHT    [UIScreen mainScreen].bounds.size.height

#define HTHeight(h) [UIView heightWith6Height:h]
#define HTWidth(w) [UIView widthWith6Width:w]
#define HTLiveViewHeight(h) [UIView heightWith6Height:h]
#define HTLiveViewWidth(w) [UIView widthWith6Width:w]
#define HTLW(w) [UIView autoWidth:w]
#define HTLayoutValue(value) [UIView caculateFrameValueWith6Size:value]

#define HTAllNewLW(w) [UIView autoAllNewWidth:w]

#define HTAllNewLH(h) [UIView autoAllNewHeight:h]

#define HTAllNewWideAndHighContrast(w) [UIView autoAllWideAndHighContrast:w]
NS_ASSUME_NONNULL_BEGIN

@interface UIView (Util)

//+ (CGFloat)heightWith6Height:(CGFloat)h;
//
//+ (CGFloat)widthWith6Width:(CGFloat)w;
//
//+ (CGFloat)caculateFrameValueWith6Size:(CGFloat)value;

+ (CGFloat)autoWidth:(CGFloat)w;

//+ (CGFloat)autoAllNewWidth:(CGFloat)w;
//
//+ (CGFloat)autoAllNewHeight:(CGFloat)h;
//
//+ (CGFloat)autoAllWideAndHighContrast:(CGFloat)w;
//
//- (void)addDefaultBlurEffect;
//
//
//- (void)addBlackBlurEffect;
//
//- (void)addHTLBlurEffectWithColor:(UIColor *)color blurRadius:(CGFloat)radius alpha:(CGFloat)alpha;
//
///**
// 自定义导航栏效果
// */
//-(void)addCustomNavView;


@end

NS_ASSUME_NONNULL_END
