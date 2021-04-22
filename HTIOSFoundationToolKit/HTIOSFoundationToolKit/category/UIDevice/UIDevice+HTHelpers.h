//
//  UIDevice+HTHelpers.h
//  HTIOSFoundationToolKit
//
//  Created by 伟东 on 2020/7/22.
//  Copyright © 2020 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

// iOS9_pre_fit 用于兼容iOS9pad上分屏做了特殊处理
#define HTKeyWindowPortraitWidth \
({\
CGFloat portraitWidth = 0.; \
CGFloat realWidth = HTKeyWindowRealWidth; \
if(realWidth < 768){ \
portraitWidth = realWidth;\
}else{\
portraitWidth = ([UIDevice portraitWidthWithOffset:YES]);\
}\
portraitWidth;\
})

// iOS9_pre_fit 用于兼容iOS9pad上分屏做了特殊处理
#define HTKeyWindowPortraitHeight \
({\
CGFloat portraitHeight = 0.; \
CGFloat realWidth = HTKeyWindowRealWidth; \
if(realWidth < 768){ \
portraitHeight = realWidth;\
}else if ([[UIDevice currentDevice] screenType] == ht_ScreenTypeIpadPro){\
UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;\
if (UIInterfaceOrientationIsLandscape(orientation))\
{\
portraitHeight = realWidth;\
}\
else {\
portraitHeight = HTKeyWindowRealHeight;\
}\
} else {\
portraitHeight = MAX(HTCurrentWindow.bounds.size.width,HTCurrentWindow.bounds.size.height);\
}\
portraitHeight;\
})

#define HTKeyWindowPortraitWidthOffset 80

#define HTCurrentWindow ((UIWindow*)([[UIApplication sharedApplication].delegate performSelector:@selector(window)]))

#define HTKeyWindowRealWidth \
({\
CGFloat realWidth = HTCurrentWindow.bounds.size.width; \
if([[[UIDevice currentDevice]systemVersion]integerValue]>=8){ \
realWidth=HTCurrentWindow.bounds.size.width;\
}else{\
UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;\
if (UIInterfaceOrientationIsLandscape(orientation))\
{\
realWidth = HTCurrentWindow.bounds.size.height;\
}\
}\
realWidth;\
})

#define HTKeyWindowRealHeight \
({\
CGFloat realHeight = HTCurrentWindow.bounds.size.height; \
if([[[UIDevice currentDevice] systemVersion]integerValue]>=8){ \
realHeight=HTCurrentWindow.bounds.size.height;\
}else{\
UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;\
if (UIInterfaceOrientationIsLandscape(orientation))\
{\
realHeight = HTCurrentWindow.bounds.size.width;\
}\
}\
realHeight;\
})

#define HTPortraitWidthScale (CGFloat)HTKeyWindowPortraitWidth/(CGFloat)320

#define HTBackgroundPortraitWidthScale (CGFloat)([UIDevice portraitWidthWithOffset:NO])/(CGFloat)320

#define HTRoundfScaleValue(value) (roundf(value*HTHightScale))

#define HTHightScale \
({\
CGFloat hightScale = 1.0; \
if([[UIDevice currentDevice] ht_isIPhone6Plus]){ \
hightScale = 1.06;\
}else if([[UIDevice currentDevice] ht_isIPhone6]){ \
hightScale = 1.0;\
}else if([[UIDevice currentDevice] ht_isIPad]){ \
hightScale = 1.25;\
}\
hightScale;\
})

#define HTWidthScale \
({\
CGFloat widthScale = 1.0; \
if([[UIDevice currentDevice] ht_isIPhone6Plus]){ \
widthScale = 1.29;\
}else if([[UIDevice currentDevice] ht_isIPhone6]){ \
widthScale = 1.17;\
}else if([[UIDevice currentDevice] ht_isIPad]){ \
widthScale = HTKeyWindowPortraitWidth / 320.f;\
}\
widthScale;\
})

#define HTGetScaleValueFitForMultiscreen(value) \
({\
CGFloat returnValue = value; \
if([[UIDevice currentDevice] ht_isIPad]){ \
returnValue = HTKeyWindowPortraitWidth / (668) * value; \
}\
returnValue;\
})

#define HTGetScaleValue(value) roundf((value) * HTHightScale)
#define HTGetWidthScaleValue(value) roundf((value) * HTWidthScale)
//根据需求universal适配时左图右文类型card文字，6&6+文字大小相同
#define HTGetTextFontScaleValue6And6PlusEqual(value) \
({float rValue = 1.0; \
if ([[UIDevice currentDevice] ht_isIPhone6Plus]){rValue = roundf((value) * 1.06);} \
else{rValue =roundf((value) * HTHightScale);}rValue;})
//根据需求universal适配时左图右文类型card文字，5&6文字大小相同，6
#define HTGetTextFontScaleValue5And6Equal(value) \
({float rValue = 1.0; \
if ([[UIDevice currentDevice] ht_isIPhone6]){rValue = roundf(value);} \
else if([[UIDevice currentDevice] ht_isIPhone6Plus]){rValue =roundf((value) + 1);}\
else{rValue =roundf((value) * HTHightScale);}rValue;})
//根据需求universal适配部分pad需要做单独处理
#define HTPageCardGetScaleValueAndPadSpecialScale(value,padScale)  \
({float rValue = 1.0; \
if ([[UIDevice currentDevice] ht_isIPad] && (padScale) > HTHightScale) {rValue = roundf((value) * (padScale));} \
else{rValue = roundf((value) * HTHightScale);} rValue;})
//部分需要只对pad进行Unversal适配
#define HTPageCardGetScaleValueJustPadSpecialScale(value)  \
({float rValue = 1.0; \
if ([[UIDevice currentDevice] ht_isIPad]) {rValue = roundf((value) * (HTHightScale));} \
else{rValue = (value);} rValue;})

/*
 对应于美工给的数值适配表
 val   : 4/5 的数值
 返回值 : 返回适配后的数值(4/5, 6, 6+)

 Todo: 之前很多地方使用了本地的宏，要统一替换
 */
#define HTTimelineAdaptiveValue(val) ( (CGFloat) ((int)(((val)*HTHightScale) + 0.5f )) )

#define kKeyChainUDID                               @"kKeyChainUDID"
#define kKeyChainAuthService                        @"kKeyChainAuthService"
#define KHTAidKeychainUserName                      @"KHTAidKeychainUserName"
#define KHTAidKeychainServiceKey                    @"KHTAidKeychainServiceKey"

NS_ASSUME_NONNULL_BEGIN

/*!
 *  主要用来判断分辨率来做布局处理，scale可能不同
 */
typedef NS_ENUM(NSUInteger, ht_ScreenType)
{
    ht_ScreenTypeUndefined = 0,
    ht_ScreenTypeClassic = 1,//3gs及以下
    ht_ScreenTypeRetina = 2,//4&4s
    ht_ScreenType4InchRetina = 3,//5&5s&5c
    ht_ScreenType6 = 4,//6或者6+放大模式
    ht_ScreenType6Plus = 5,//6+
    ht_ScreenTypeIpadClassic = 6,//iPad 1,2,mini
    ht_ScreenTypeIpadRetina = 7,//iPad 3以上,mini2以上
    ht_ScreenTypeIpadPro = 8,//iPad Pro
    ht_ScreenTypeX = 9,        //iPhone X
    ht_ScreenTypeXR = 10,      //iPhone XR
    ht_ScreenTypeXS_Max = 11,  //iPhone XS Max
    ht_ScreenType11 = 12,  //iPhone 11
    ht_ScreenType11Pro = 13,  //iPhone 11 pro
    ht_ScreenType11ProMax = 14,  //iPhone 11 pro max
};

extern  CGRect HTConvertCGRectForDeviceScale(CGRect rect);
extern  CGFloat HTConvertHeightForDeviceScale(CGFloat height);
extern  CGFloat HTConvertWidthForDeviceScale(CGFloat width);
extern  CGFloat HTConvertEdgeForGivenScale(CGFloat width, CGFloat scale);

typedef NS_ENUM(NSInteger, HTScaleFactor) {
    // use HTScaleFactorDefault
    HTScaleFactorUseDefault = 0,
    // iphone6  = 1.06 * iphone5
    // iphone6p = 1.15 * iphone5
    // ipad     = 1.25 * iphone5
    HTScaleFactor_106_115_125 = 1,

    // iphone6  = 1.00 * iphone5
    // iphone6p = 1.06 * iphone5
    // ipad     = 1.25 * iphone5
    HTScaleFactor_100_106_125 = 2,

    HTScaleFactorDefault = HTScaleFactor_100_106_125
};

typedef struct {
    // scale factor group
    HTScaleFactor factor;

    // overrides for specific device
    double iphone6;
    double iphone6p;
    double ipad;
} HTScaleOptions;

extern double _HTScaleDoubleWithOptions(double value, HTScaleOptions options);

#define HTScaleWithOptions(iphone5, options...) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wgnu-designator\"")\
_HTScaleDoubleWithOptions(iphone5, (HTScaleOptions)options)\
_Pragma("clang diagnostic pop")

#define HTScaleWithDefaultOptions(iphone5) HTScaleWithOptions(iphone5, {})

@interface UIDevice (HTHelpers)


+ (CGFloat)portraitWidthWithOffset:(BOOL)needOffset;

/*!
 *  判断当前屏幕类型（按分辨率分类）
 *
 *
 */
- (ht_ScreenType)screenType;

/*!
 *  判断当前手机是否为高清屏
 *
 *  @return ,返回值YES代表是高清屏，NO代表不是高清屏
 */
- (BOOL)ht_isRetinaDisplay;

/*!
 *  判断当前UIScreen的frame是否iPhone5分辨率
 *
 *
 */
- (BOOL)ht_is4InchRetinaDisplay;

/*!
 *  判断当前UIScreen的frame是否时480以上
 *
 *  使用ht_isLongScreen
 */
- (BOOL)ht_is4InchRetinaDisplay_old __attribute__((deprecated));

/*!
*  判断当前UIScreen的frame是否时667以上
*
*  使用ht_is5InchRetinaLongScreen
*/
- (BOOL)ht_is5InchRetinaLongScreen;

/*!
 *  判断当前UIScreen的frame是否时480以上
 *
 *
 */
- (BOOL)ht_isLongScreen;

/**
 判断当前是否为iPhone X
 *  @discussion 布局时请尽量避免使用此方法。好的布局应当能自动适配任何屏幕宽度，而不是针对 iPhone X 作特殊X处理。此方法通过以下条件判断：1.设备是iPhone; 2.nativeScale > 2.1; 3.屏幕高度为 736。这个判断可能在苹果发布新设备后失效
 @return bool
 */
- (BOOL)ht_isIPhoneX;

/**
 判断是否是iPhone XR

 @return bool值
 */
- (BOOL)ht_isIPhoneXR;

/**
 判断是否是iPhone XS Max

 @return bool值
 */
- (BOOL)ht_isIPhoneXS_Max;

/**
 判断是否是全面屏
 当前包括：X/XS、XR、XS Max四种机型

 @return bool值
 */
- (BOOL)ht_isIPhone_fullScreen;
/*!
 *  判断当前是否为 iPhone 6
 *
 *  @discussion 布局时请尽量避免使用此方法。好的布局应当能自动适配任何屏幕宽度，而不是针对 iPhone 6 作特殊处理。此方法通过以下条件判断：1.设备是iPhone; 2.nativeScale > 2.1; 3.屏幕高度为 736。这个判断可能在苹果发布新设备后失效
 *
 *  @return bool
 */
- (BOOL)ht_isIPhone6;

/*!
 *  判断当前是否为 iPhone 6 Plus
 *
 *  @discussion 布局时请尽量避免使用此方法。好的布局应当能自动适配任何屏幕宽度，而不是针对 iPhone 6 Plus 作特殊处理。此方法通过以下条件判断：1.设备是iPhone; 2.nativeScale > 2.1; 3.屏幕高度为 736。这个判断可能在苹果发布新设备后失效
 *
 *  @return bool
 */
- (BOOL)ht_isIPhone6Plus;

/*!
 *  判断当前是否为 iPad
 *
 *  @discussion 布局时请尽量避免使用此方法。好的布局应当能自动适配任何屏幕宽度，而不是针对 iPhone 6 Plus 作特殊处理。此方法通过以下条件判断：1.设备是iPhone; 2.nativeScale > 2.1; 3.屏幕高度为 736。这个判断可能在苹果发布新设备后失效
 *
 *  @return bool
 */
- (BOOL)ht_isIPad;

/*!
 *  判断当前是否为 iPadClassic
 *
 *  @discussion 布局时请尽量避免使用此方法。好的布局应当能自动适配任何屏幕宽度，而不是针对 iPhone 6 Plus 作特殊处理。此方法通过以下条件判断：1.设备是iPhone; 2.nativeScale  == 1; 3.屏幕高度为 768, 宽度为1024。这个判断可能在苹果发布新设备后失效
 *
 *  @return bool
 */
- (BOOL)ht_isIPadClassic;

/*!
 *  判断当前是否为 iPadRetina
 *
 *  @discussion 布局时请尽量避免使用此方法。好的布局应当能自动适配任何屏幕宽度，而不是针对 iPhone 6 Plus 作特殊处理。此方法通过以下条件判断：1.设备是iPhone; 2.nativeScale > 2; 3.屏幕高度为 768。宽度为1024 这个判断可能在苹果发布新设备后失效
 *
 *  @return bool
 */
- (BOOL)ht_isIPadRetina;

/*!
 *  返回当前系统版本号
 */
- (int)ht_systemMainVersion;

/*!
 *  获取当前运营商信息
 */
- (NSString *)ht_carrierName;

/**
 获取设备内存大小
 */
+ (long long)ht_getMemoryInfo;

/**
 获取当前内存大小
 */
+(long long)ht_getUsedMemory;

//设备可用内存
+ (long long)ht_availableMemory;

//设备已用内存
+ (long long)ht_deviceUsedMemory;

/**
 获取虚拟内存大小
 */
+ (long long)ht_getVirtulMemory;

/**
 获取当前设备网络提供商的国家代码，符合ISO 3166-1标准
 */
- (NSString*)ht_countryISO;

/*!
 *  获取返回当前手机运营商国家的代码信息
 */
- (NSString *)ht_mobileCountryCode;

/*!
 *  获取移动设备的网络代码信息（以用来表示唯一一个的移动设备的网络运营商）
 */
- (NSString *)ht_mobileNetworkCode;


/**
 系统名称
 */
+ (NSString*)ht_systemName;

/*!
 *  判断当前设备是否能打电话
 *
 *  @return YES表示可以，NO表示不可以
 */
- (BOOL)ht_canMakeCall;

/*!
 *  判断当前设备是否能发短信
 *
 *  @return YES表示可以，NO表示不可以
 */
- (BOOL)ht_canSendText;

/*!
 *  获取当前设备型号信息
 *
 */
+ (NSString *)ht_getStandardPlat;

/*!
 *  获取当前设备型号信息
 *
 */
+ (NSString *)ht_platform;

/*!
 *  返回一个当前设备型号信息对应的字符串，例如iPhone1,2对应iphone3g等
 *
 *  @param platform 系统设备型号信息，例如“iPhone1,2，iPod2,1,iPad1,1"等
 *
 *  @return 返回一个设备的通用叫法，例如“ipodtouch1,iphone4”等
 */
+ (NSString *)ht_getReturnPlat:(NSString *)platform;

/*!
 *  判断当前设备是否支持闪光灯
 *
 *  @return 返回YES表示支持，NO不支持
 */
- (BOOL)ht_hasLedLight;

/*!
 *  判断当前设备是否打开了闪光
 *
 *  @return 返回YES表示打开，NO没打开
 */
- (BOOL)ht_isLedLightOn;

/*!
 *  设置是闪光灯属性
 *
 *  @param on 返回YES打开闪光灯，NO不打开闪光灯
 */
- (void)ht_turnLedLightTo:(BOOL)on;

/*!
 *  相机权限判断
 *
 *  @return 返回YES表示有权限，NO表示没有权限或者被限制
 */
- (BOOL)ht_cameraAuthorizationStatus;

/*!
 *  麦克风权限判断
 *
 *  @return 返回YES表示有权限，NO表示没有权限或者被限制
 */
- (BOOL)ht_micAuthorizationStatus;

/*!
 *  相册访问权限判断
 *
 *  @return 返回YES表示有权限，NO表示没有权限或者被限制
 */
- (BOOL)ht_albumAuthorizationStatus;


/*!
 *  联网权限判断
 *
 *  @return 返回YES表示有权限，NO表示没有权限或者被限制
 */
- (BOOL)ht_cellularDataAuthorizationStatus;


/*!
 *  定位权限判断
 *
 *  @return 返回YES表示有权限，NO表示没有权限或者被限制
 */
- (BOOL)ht_locationAuthorizationStatus;

/*!
 *  推送权限判断
 *
 *  @return 返回YES表示有权限，NO表示没有权限或者被限制
 */
- (BOOL)ht_notificationAuthorizationStatus;

/*!
 *  通讯录权限判断
 *
 *  @return 返回YES表示有权限，NO表示没有权限或者被限制
 */
- (BOOL)ht_contactsAuthorizationStatus;

/*!
 *  判断是否开启VPN
 *
 *  @return 返回YES表示开启，NO表示没有开启
 */
- (BOOL)ht_isVPNConnected;

/*!
 *  本地IP地址
 *
 *  @return IP地址
 */
- (NSString*)ht_getLocalIPAddress;

/*!
 *  SSID，即wifi名称

 *
 *  @return SSID
 */
+ (NSString *)ht_getDeviceSSID;

/*!
 *  子网掩码地址
 *
 *  @return 子网掩码
 */
- (NSString*)ht_getNetMaskAddress;

/*!
 *  网关地址
 *
 *  @return 网关地址
 */
- (NSString*)ht_getGatewayAddress;

/*!
 *  local DNS地址
 *
 *  @return DNS地址数组
 */
- (NSArray*)ht_getLocalDNSAddress;

/*!
 *  是否是iPad布局
 *
 *  只有当工程为iPad Only或者或者Universal时候在iPad设备上才会返回YES
 *  当工程为iPhone Only在iPad设备上时，返回NO。
 *
 *
 *  @return 返回YES表示是，NO不是（是iPhone或iPod布局）
 */
- (BOOL)ht_isUIUserInterfaceIdiomPad;

/*!
 *  根据设备的能力（内存）返回不同分辨率
 *
 */
+ (NSUInteger)ht_assetMaxDimension;

// 判断设备锁屏
//+ (void)ht_registerLockEventListener;
- (void)ht_markAsLocked;
- (void)ht_markAsUnLocked;
- (BOOL)ht_isLocked;
- (BOOL)ht_isLockedWhileRunning;


+ (BOOL)ht_isJailbroken;
+ (NSString*)ht_currentCPUArch;
+ (NSDate*)ht_dateSysctl:(NSString*)name;
+ (NSString *)ht_appUUIDWithAppPath:(NSString *)path;
+ (NSString *)ht_appAddressWithAppPath:(NSString *)path;

+ (CGFloat)ht_diskOfAllSize;
+ (CGFloat)ht_diskOfFreeSize;
+(NSDictionary*)ht_getWifiInfo;
/// 当前app的cpu占用率
- (double)ht_appCPUUsage;
//当前设备的CPU使用率
- (CGFloat)ht_deviceCPUUsage;
/// 当前app线程总数
- (int)ht_threadCount;
// 当前app线程数以及running状态的线程数
- (NSDictionary *)ht_runningThreadCount;
// 获取设备特征字符串
+ (NSString*)ht_getDevicePortrait;
// 生成设备指纹
- (NSString*)ht_mfp;
- (NSArray *)ht_mfp1;
// aid
- (NSString *)ht_aid;

+ (NSString *)wm;

@end

NS_ASSUME_NONNULL_END
