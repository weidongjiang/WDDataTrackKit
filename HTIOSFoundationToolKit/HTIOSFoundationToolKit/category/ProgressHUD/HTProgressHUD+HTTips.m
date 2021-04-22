//
//  HTProgressHUD+HTTips.m
//  cocos2d_libs
//
//  Created by 伟东 on 2020/7/6.
//

#import "HTProgressHUD+HTTips.h"

static NSString *const kMPTFontName = @"HYQiHei-EZJ";

@implementation HTProgressHUD (HTTips)
+ (HTProgressHUD *)showLoadingTips:(NSString *)title {
    UIView *view = [UIApplication sharedApplication].keyWindow;
    [HTProgressHUD hide:NO inView:view];
    HTProgressHUD *hud = [HTProgressHUD showHUDAddedTo:view animated:YES];
    hud.label.text = title;
    return hud;
}

+ (void)hide:(BOOL)animate {
    UIView *view = [UIApplication sharedApplication].keyWindow;
    [HTProgressHUD hide:animate inView:view];
}
+ (void)hide:(BOOL)animate inView:(UIView *)view {
    [HTProgressHUD hideHUDForView:view animated:animate];
}

+ (HTProgressHUD *)showText:(NSString *)title inView:(UIView *)view {
    [HTProgressHUD hide:NO inView:view];
    HTProgressHUD *HUbview = [HTProgressHUD showHUDAddedTo:view animated:YES];
    HUbview.label.text = title;
    HUbview.mode = HTProgressHUDModeText;
    HUbview.userInteractionEnabled = NO;
    HUbview.removeFromSuperViewOnHide = true;
    [HUbview hideAnimated:YES afterDelay:2];
    return HUbview;
}


+ (void)showTips:(NSString *)title duration:(CGFloat)duration {
    [[self class] showTips:title yOffset:0 duration:duration];
}

+ (void)showTips:(NSString *)title yOffset:(CGFloat)yOffset duration:(CGFloat)duration {
    UIView *view = [UIApplication sharedApplication].keyWindow;
    [HTProgressHUD hide:NO inView:view];
    HTProgressHUD *hud = [HTProgressHUD showHUDAddedTo:view animated:YES];
    hud.contentColor = [UIColor whiteColor];
    hud.bezelView.style = HTProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.8];
    hud.label.text = title;
    hud.mode = HTProgressHUDModeText;
    hud.offset = CGPointMake(0, yOffset);
    [hud hideAnimated:YES afterDelay:duration];
}

+ (void)showTips:(NSString *)title image:(UIImage *)image duration:(CGFloat)duration {
    UIView *view = [UIApplication sharedApplication].keyWindow;
    [HTProgressHUD hide:NO inView:view];
    HTProgressHUD *hud = [HTProgressHUD showHUDAddedTo:view animated:YES];
    hud.customView = [[UIImageView alloc] initWithImage:image];
    hud.label.text = title;
    hud.mode = HTProgressHUDModeCustomView;
    hud.bezelView.style = HTProgressHUDBackgroundStyleSolidColor;
    hud.bezelView.color = [UIColor colorWithWhite:0 alpha:0.8];
    hud.bezelView.layer.cornerRadius = 8;
    hud.contentColor = [UIColor whiteColor];
    [hud hideAnimated:YES afterDelay:2.f];
}
+ (void)showTips:(NSString *)title subTitle:(NSString*)subTitle image:(UIImage *)image duration:(CGFloat)duration {

    UIView *view = [UIApplication sharedApplication].keyWindow;
    [HTProgressHUD hide:NO inView:view];
    HTProgressHUD *hud = [HTProgressHUD showHUDAddedTo:view animated:YES];
    hud.customView = [[UIImageView alloc] initWithImage:image ];
    hud.label.text = title;
    hud.detailsLabel.text = subTitle;
    hud.opacity = 1;
    hud.activityIndicatorColor = [UIColor blackColor];
    hud.bezelView.color = [UIColor blackColor];
    [hud hideAnimated:YES afterDelay:2.f];
}


+ (void)showTipsView:(UIView *)customView duration:(CGFloat)duration {
    UIView *view = [UIApplication sharedApplication].keyWindow;
    [HTProgressHUD hide:NO inView:view];
    HTProgressHUD *hud = [HTProgressHUD showHUDAddedTo:view animated:YES];
    hud.customView = customView;
    hud.mode = HTProgressHUDModeCustomView;
    [hud hideAnimated:YES afterDelay:2.f];
}

//可显示多行
+ (void)showText:(NSString *)text image:(UIImage *)image duration:(CGFloat)duration {
    UIView *view = [UIApplication sharedApplication].keyWindow;
    [HTProgressHUD hide:NO inView:view];
    HTProgressHUD *hud = [HTProgressHUD showHUDAddedTo:view animated:YES];
    hud.customView = [[UIImageView alloc] initWithImage:image];
    hud.detailsLabelText = text;
    hud.detailsLabelFont = [HTProgressHUD HTBoldFontOfSize:15];
    hud.mode = HTProgressHUDModeCustomView;
    [hud hideAnimated:YES afterDelay:2.f];
}

+ (UIFont *)HTBoldFontOfSize:(CGFloat)size
{
    UIFont *font = [UIFont fontWithName:kMPTFontName size:size];
    if(font==nil)
    {
        font = [UIFont boldSystemFontOfSize:size];
    }
    return font;
}
@end
