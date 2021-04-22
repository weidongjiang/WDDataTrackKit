//
//  HTProgressHUD+HTTips.h
//  cocos2d_libs
//
//  Created by 伟东 on 2020/7/6.
//

#import "HTProgressHUD.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTProgressHUD (HTTips)

+ (HTProgressHUD *)showLoadingTips:(NSString *)title;
+ (HTProgressHUD *)showText:(NSString *)title inView:(UIView *)view;
+ (void)hide:(BOOL)animate inView:(UIView *)view;
+ (void)hide:(BOOL)animate;
+ (void)showTips:(NSString *)title duration:(CGFloat)duration ;
+ (void)showTips:(NSString *)title image:(UIImage *)image duration:(CGFloat)duration;
+ (void)showTipsView:(UIView *)customView duration:(CGFloat)duration;
+ (void)showTips:(NSString *)title yOffset:(CGFloat)yOffset duration:(CGFloat)duration;
+ (void)showText:(NSString *)text image:(UIImage *)image duration:(CGFloat)duration;
+ (void)showTips:(NSString *)title subTitle:(NSString*)subTitle image:(UIImage *)image duration:(CGFloat)duration;

@end

NS_ASSUME_NONNULL_END
