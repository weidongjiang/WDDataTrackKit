//
//  HTImageTool.h
//  HTIOSFoundationToolKit
//
//  Created by 伟东 on 2020/7/22.
//  Copyright © 2020 伟东. All rights reserved.
//

// 主要是获取各种各样的 image

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface HTImageTool : NSObject

///把 theView 转化成 image
/// @param theView theView description
+ (UIImage *)imageFromView:(UIView *)theView;

/// 把 theView 上 r 区域转化成 image
/// @param theView theView description
/// @param r 需要截取出来的区域
+ (UIImage *)imageFromView:(UIView *)theView atFrame:(CGRect)r;

/// 从 img 上截取 partRect 区域的 image
/// @param img img description
/// @param partRect partRect description
+ (UIImage *)getPartOfImage:(UIImage *)img rect:(CGRect)partRect;

/// 从 originalImage 上截取 cropRect 区域的 image
/// @param originalImage originalImage description
/// @param cropRect cropRect description
+ (UIImage *)cropImage:(UIImage *)originalImage cropRect:(CGRect)cropRect;

/// 截屏转化为 image
+ (UIImage*)imageForScreen;

/// 缩放图片大小 得到 image
/// @param img img description
/// @param size size description
+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size;

@end

NS_ASSUME_NONNULL_END
