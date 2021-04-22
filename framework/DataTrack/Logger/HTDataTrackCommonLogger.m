//
//  HTDataTrackCommonLogger.m
//  HTIOSDataTrackKit
//
//  Created by 伟东 on 2020/8/17.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "HTDataTrackCommonLogger.h"
#import <sys/utsname.h>
#include <UIKit/UIKit.h>
#import <commoncrypto/CommonDigest.h>
#import "HTDataTrackReachability.h"
#import "HTDataTrackLocationManager.h"
#import "HTGetUUID.h"

static NSString *HTDataTrackEnvProduction = @"production";// 生产环境
static NSString *HTDataTrackEnvTesting = @"testing";// 测试环境
static NSString *HTDataTrackStackFrontend = @"frontend";// 前段埋点
static NSString *HTDataTrackStackBackend = @"backend";// 后端埋点
static NSString *HTDataTrackOSiOS = @"ios";// 操作系统

static NSString *HTDataTrackSessionSeqKey = @"HTDataTrackSessionSeqKey";//
static NSString *HTDataTrackEventSeqKey = @"HTDataTrackEventSeqKey";//
static NSString *HTDataTrackEventPvSeqKey = @"HTDataTrackEventPvSeqKey";//


static NSString *HTDataTrackEetEnableLogKey = @"HTDataTrackEetEnableLogKey";//


@interface HTDataTrackCommonLogger ()

@property (nonatomic, copy) NSString            *userid;
@property (nonatomic, copy) NSString            *product;
@property (nonatomic, assign) BOOL              enableGPSLocation;// 默认关闭 NO
@property (nonatomic, strong) HTDataTrackLocationManager *locationManager;
@property (nonatomic, strong) HTDataTrackGPSLocationConfig *locationConfig;
@property (nonatomic, copy) NSString            *sessionId;

@end

@implementation HTDataTrackCommonLogger

- (instancetype)init {
    if (self = [super init]) {
        self.enableGPSLocation = NO;
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:HTDataTrackEetEnableLogKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    return self;
}


- (NSDictionary *)basicDictionary {
    NSMutableDictionary *basic = [NSMutableDictionary dictionary];
    
    [basic htdt_setSafeObject:[self getEventId] forKey:@"eventId"];
    [basic htdt_setSafeObject:[self getCuuentTime] forKey:@"eventTime"];
    [basic htdt_setSafeObject:[self get_userid] forKey:@"userId"];
    [basic htdt_setSafeObject:[self getuuid] forKey:@"uuid"];
    [basic htdt_setSafeObject:[self getdeviceid] forKey:@"deviceId"];
    [basic htdt_setSafeObject:[self getDeviceIsPhoneOrPad] forKey:@"deviceBrand"];
    [basic htdt_setSafeObject:[self getPlatformString] forKey:@"deviceModel"];
    [basic htdt_setSafeObject:[self getenv] forKey:@"env"];
    [basic htdt_setSafeObject:[self getstack] forKey:@"stack"];
    [basic htdt_setSafeObject:[self getos] forKey:@"os"];
    [basic htdt_setSafeObject:[self getOSVersion] forKey:@"osVersion"];
    [basic htdt_setSafeObject:[self getplatform] forKey:@"platform"];
    [basic htdt_setSafeObject:[self getproduct] forKey:@"product"];
    [basic htdt_setSafeObject:[self getlibVersion] forKey:@"libVersion"];
    [basic htdt_setSafeObject:[self getlogVersion] forKey:@"logVersion"];
    [basic htdt_setSafeObject:[self getNetworkType] forKey:@"networkType"];
    [basic htdt_setSafeObject:[self getscreenResolution] forKey:@"screenResolution"];
    [basic htdt_setSafeObject:[self getTimeZoneName] forKey:@"timezone"];
    [basic htdt_setSafeObject:[self getlatitude] forKey:@"latitude"];
    [basic htdt_setSafeObject:[self getlongitude] forKey:@"longitude"];
    [basic htdt_setSafeObject:[self getVersionAndSubVersion] forKey:@"version"];
    [basic htdt_setSafeObject:[self getCurrrntViewControlString] forKey:@"url"];
    [basic htdt_setSafeObject:[self getsessionId] forKey:@"sessionId"];
    [basic htdt_setSafeObject:[self getSessionSeq] forKey:@"sessionSeq"];
    [basic htdt_setSafeObject:[self getPVSeq] forKey:@"pvSeq"];
    [basic htdt_setSafeObject:[self getEventSeq] forKey:@"eventSeq"];
    [basic htdt_setSafeObject:[self getUrl] forKey:@"url"];
    [basic htdt_setSafeObject:[self getreferrer] forKey:@"referrer"];
    [basic htdt_setSafeObject:[self getuserAgent] forKey:@"userAgent"];

    return [basic copy];
}

- (NSDictionary *)dataSADictionary {
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    [data htdt_setSafeObject:[self getenv] forKey:@"env"];
    [data htdt_setSafeObject:[self getproduct] forKey:@"product"];
    [data htdt_setSafeObject:[self getstack] forKey:@"stack"];
    [data htdt_setSafeObject:[self getsessionId] forKey:@"sessionId"];
    [data htdt_setSafeObject:[self getEventSeq] forKey:@"eventSeq"];
    [data htdt_setSafeObject:[self get_userid] forKey:@"userId"];
    [data htdt_setSafeObject:[self getuuid] forKey:@"uuid"];

    return [data copy];
}

- (void)setDataTrackUserid:(NSString *)userid {
    dispatch_async(self.trackLoggerQueue, ^{
        self.userid = userid;
    });
}

- (void)setDataTrackProduct:(NSString *)product {
    dispatch_async(self.trackLoggerQueue, ^{
        self.product = product;
    });
}

- (void)setEnableLog:(BOOL)enable {
    [[NSUserDefaults standardUserDefaults] setBool:enable forKey:HTDataTrackEetEnableLogKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)enableTrackGPSLocation:(BOOL)enableGPSLocation {
    dispatch_block_t block = ^{
        self.locationConfig.enableGPSLocation = enableGPSLocation;
        self.enableGPSLocation = enableGPSLocation;
        if (enableGPSLocation) {
            if (self.locationManager == nil) {
                self.locationManager = [[HTDataTrackLocationManager alloc] init];
                __weak HTDataTrackCommonLogger *weakSelf = self;
                self.locationManager.updateLocationBlock = ^(CLLocation * location, NSError *error) {
                    __strong HTDataTrackCommonLogger *strongSelf = weakSelf;
                    if (location) {
                        strongSelf.locationConfig.coordinate = location.coordinate;
                    }
                    if (error) {
                        HTDTLog(@"Logger:CommonLogger：enableTrackGPSLocation error：%@", error);
                    }
                };
            }
            [self.locationManager startUpdatingLocation];
        } else {
            if (self.locationManager != nil) {
                [self.locationManager stopUpdatingLocation];
            }
        }
    };
    
    if (NSThread.isMainThread) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}

/// 更新每次回话的  SessionId 启动一次就要更新，保证唯一性 此次采用uuid+8位随机数
- (void)updateDataTrackData {
    dispatch_async(self.trackLoggerQueue, ^{
        // 更新SessionId
        [self updateSessionId];
        
        // 更新sessionSeq
        [self updateSessionSeq];
        
        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:HTDataTrackEventPvSeqKey];

        [[NSUserDefaults standardUserDefaults] setInteger:0 forKey:HTDataTrackEventSeqKey];

    });
}

- (NSString *)getuserAgent {
    return @"-";
}

- (void)updateSessionId {
    
    NSString *sessionId = [NSString stringWithFormat:@"%@-%@",[self getuuid],generateNO(8)];
    if (!sessionId.length) {
        sessionId = @"-";
    }
    self.sessionId = sessionId;
}

- (void)updateSessionSeq {
    NSInteger sessionSeq = [[NSUserDefaults standardUserDefaults] integerForKey:HTDataTrackSessionSeqKey];
    sessionSeq++;
    [[NSUserDefaults standardUserDefaults] setInteger:sessionSeq forKey:HTDataTrackSessionSeqKey];
}

- (void)updatePVSeq { 
    NSInteger pvSeq = [[NSUserDefaults standardUserDefaults] integerForKey:HTDataTrackEventPvSeqKey];
    pvSeq++;
    [[NSUserDefaults standardUserDefaults] setInteger:pvSeq forKey:HTDataTrackEventPvSeqKey];
}
#pragma getter

/// 事件请求ID
- (NSString *)getEventId {
    
    // 时间戳-用户ID-随机数  1569496018551-1580188-12451793
    NSString *time = [self getCuuentTime];
    NSString *eventid = [NSString stringWithFormat:@"%@%@%@",time,[self get_userid],generateNO(8)];
    if ([[self get_userid] isEqualToString:@"-1"]) {
        eventid = [NSString stringWithFormat:@"%@%@%@",time,@"9",generateNO(8)];
    }
    
    if (eventid.length <= 0) {
        return @"0";
    }
    return eventid;
}

/// 时间戳
- (NSString *)getCuuentTime {
    UInt64 currentTimestamp = [[NSDate date] timeIntervalSince1970]*1000;
    if (!@(currentTimestamp).stringValue.length) {
        return @"0";
    }
    return @(currentTimestamp).stringValue;
}

/// 用户ID
- (NSString *)get_userid {
    if ([NSString htdt_isEmptyString:self.userid]) { 
        return @"-1";
    }
    return self.userid;
}

// uuid   手机唯一标识
- (NSString *)getuuid {
    NSString *uuid = [[HTGetUUID shareInatace] getDeviceUUID];
    HTDTLog(@"Logger:sendLogger:getuuid--%@",uuid);
    if (!uuid.length) {
        return @"-";
    }
    return uuid;
}

/// 设备唯一标识
- (NSString *)getdeviceid {
    return [self getuuid];
}

/// 设备品牌
- (NSString *)getDeviceIsPhoneOrPad {
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return @"phone";
     } else {
        return @"pad";
     }
}

/// 环境类型
- (NSString *)getenv {
    NSString *env = @"-";
#ifdef DEBUG
    env = HTDataTrackEnvTesting;
#else
    env = HTDataTrackEnvProduction;
#endif
    return env;
}

/// 埋点类型
- (NSString *)getstack {
    return HTDataTrackStackFrontend;
}

/// 操作系统
- (NSString *)getos {
    NSString *os = [[UIDevice currentDevice] systemName];       //ios
    return os;
}

/// 操作系统版本
- (NSString *)getOSVersion {
    NSString *osVersion = [[UIDevice currentDevice] systemVersion]; //11.4
    return osVersion;
}

/// 操作平台
- (NSString *)getplatform {
    return [self getDeviceIsPhoneOrPad];
}

/// 业务线
- (NSString *)getproduct {
    if (!_product.length) {
        return @"-";
    }
    return _product;
}

/// sdk 版本号
- (NSString *)getlibVersion {
    return HTDataTrackLibVersion;
}

/// 日志解析版本号
- (NSString *)getlogVersion {
    return HTDataTrackLogVersion;
}

/// 网络类型
- (NSString *)getNetworkType {
    NSString *currentDetailNetString = [[HTDataTrackReachability shareInstance] currentDetailNetString];
    if (!currentDetailNetString.length) {
        currentDetailNetString = @"-";
    }
    return currentDetailNetString;
}

/// 屏幕分辨率
- (NSString *)getscreenResolution {
    NSString *screenResolution = [NSString stringWithFormat:@"%f*%f",K_ScreenWidth,K_ScreenHeight];
    if (!screenResolution.length) {
        screenResolution = @"-";
    }
    return screenResolution;
}

/// 时区
- (NSString *)getTimeZoneName {
    NSDateFormatter *dateFormatter = [NSDateFormatter htdt_dateFormateterForCurrentThread];
    [dateFormatter setDateFormat:@"zzz"];
    NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];
    return destDateString;
}

/// 纬度信息
- (NSString *)getlatitude {
    if (!self.enableGPSLocation) {
        return @"-";
    }
    return @(self.locationConfig.coordinate.latitude).stringValue;
    
}

///// 经度信息
- (NSString *)getlongitude {
    if (!self.enableGPSLocation) {
        return @"-";
    }
    return @(self.locationConfig.coordinate.longitude).stringValue;
}

- (NSString *)getVersionAndSubVersion {
    NSString *version = [NSString stringWithFormat:@"%@.%@",[self getVersion],[self getsubVersion]];
    if (!version.length) {
        return @"-";
    }
    return version;
}
/// //版本号
- (NSString *)getVersion {
    NSString *version = (NSString *)[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    return version;
}
/// build 号
- (NSString *)getsubVersion {
    NSString *subVersion = (NSString *)[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleVersion"];
    return subVersion;
}
// 当前 UIViewControl 的类名
- (NSString *)getCurrrntViewControlString {
    return @"-";
}

- (NSString *)getsessionId {
    if (!self.sessionId.length) {
        return @"-";
    }
    return self.sessionId;
}

- (NSString *)getSessionSeq {
    NSInteger sessionSeq = [[NSUserDefaults standardUserDefaults] integerForKey:HTDataTrackSessionSeqKey];
    NSString *seq = @(sessionSeq).stringValue;
    if (!seq.length) {
        return @"-1";
    }
    return seq;
}
//当前会话内访问页面序列,只有打卡新页面的时候才会更新
- (NSString *)getPVSeq {
    
    NSInteger _pvSeq = [[NSUserDefaults standardUserDefaults] integerForKey:HTDataTrackEventPvSeqKey];
    NSString *pvSeq = @(_pvSeq).stringValue;
    if (!pvSeq.length) {
        return @"-1";
    }
    return pvSeq;
}

//当前会话内事件序列
- (NSString *)getEventSeq {
    
    NSInteger _eventSeq = [[NSUserDefaults standardUserDefaults] integerForKey:HTDataTrackEventSeqKey];
    NSString *eventSeq = @(_eventSeq).stringValue;
    if (!eventSeq.length) {
        return @"-1";
    }
    HTDTLog(@"eventSeq--%@---_sessionId---%@",eventSeq,self.sessionId);
    return eventSeq;
}

- (void)updateEventSeq {
    
    NSInteger eventSeq = [[NSUserDefaults standardUserDefaults] integerForKey:HTDataTrackEventSeqKey];
    eventSeq++;
    [[NSUserDefaults standardUserDefaults] setInteger:eventSeq forKey:HTDataTrackEventSeqKey];
}

- (NSString *)getUrl {
    return @"-";
}
- (NSString *)getreferrer {
    return @"-";
}
// 定位
- (HTDataTrackGPSLocationConfig *)locationConfig {
    if (!_locationConfig) {
        _locationConfig = [[HTDataTrackGPSLocationConfig alloc] init];
    }
    return _locationConfig;
}

#pragma common
- (NSString *)getMD5String:(NSString *)string {
    
    const char *cStr = [string UTF8String];
    unsigned char result[16];
    
    NSNumber *num = [NSNumber numberWithUnsignedLong:strlen(cStr)];
    CC_MD5( cStr,[num intValue], result );
    
    return [[NSString stringWithFormat:
             @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}

// 8位随机数
NSString *generateNO(NSInteger kNumber){
    if (kNumber <= 0) return @"";
    
    NSString *sourceStr = @"0123456789";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    for (int i = 0; i < kNumber; i++){
        unsigned index = arc4random() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}

//获取ios设备号
- (NSString *)getPlatformString {
    
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *deviceString = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];

    if ([deviceString isEqualToString:@"iPhone3,1"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,2"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone3,3"])    return @"iPhone 4";
    if ([deviceString isEqualToString:@"iPhone4,1"])    return @"iPhone 4S";
    if ([deviceString isEqualToString:@"iPhone5,1"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,2"])    return @"iPhone 5";
    if ([deviceString isEqualToString:@"iPhone5,3"])    return @"iPhone 5c";
    if ([deviceString isEqualToString:@"iPhone5,4"])    return @"iPhone 5c";
    if ([deviceString isEqualToString:@"iPhone6,1"])    return @"iPhone 5s";
    if ([deviceString isEqualToString:@"iPhone6,2"])    return @"iPhone 5s";
    if ([deviceString isEqualToString:@"iPhone7,1"])    return @"iPhone 6 Plus";
    if ([deviceString isEqualToString:@"iPhone7,2"])    return @"iPhone 6";
    if ([deviceString isEqualToString:@"iPhone8,1"])    return @"iPhone 6s";
    if ([deviceString isEqualToString:@"iPhone8,2"])    return @"iPhone 6s Plus";
    if ([deviceString isEqualToString:@"iPhone8,4"])    return @"iPhone SE";
    // 日行两款手机型号均为日本独占，可能使用索尼FeliCa支付方案而不是苹果支付
    if ([deviceString isEqualToString:@"iPhone9,1"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,2"])    return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone9,3"])    return @"iPhone 7";
    if ([deviceString isEqualToString:@"iPhone9,4"])    return @"iPhone 7 Plus";
    if ([deviceString isEqualToString:@"iPhone10,1"])   return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,4"])   return @"iPhone 8";
    if ([deviceString isEqualToString:@"iPhone10,2"])   return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,5"])   return @"iPhone 8 Plus";
    if ([deviceString isEqualToString:@"iPhone10,3"])   return @"iPhone X";
    if ([deviceString isEqualToString:@"iPhone10,6"])   return @"iPhone X";
    if ([deviceString isEqualToString:@"iPhone11,8"])   return @"iPhone XR";
    if ([deviceString isEqualToString:@"iPhone11,2"])   return @"iPhone XS";
    if ([deviceString isEqualToString:@"iPhone11,6"])   return @"iPhone XS Max";
    if ([deviceString isEqualToString:@"iPhone11,4"])   return @"iPhone XS Max";

    if ([deviceString isEqualToString:@"iPhone12,1"])   return @"iPhone 11";
    if ([deviceString isEqualToString:@"iPhone12,3"])   return @"iPhone 11 Pro";
    if ([deviceString isEqualToString:@"iPhone12,5"])   return @"iPhone 11 Pro Max";
    
    if ([deviceString isEqualToString:@"iPhone13,1"])   return @"iPhone 12 mini";
    if ([deviceString isEqualToString:@"iPhone13,2"])   return @"iPhone 12";
    if ([deviceString isEqualToString:@"iPhone13,3"])   return @"iPhone 12 Pro";
    if ([deviceString isEqualToString:@"iPhone13,4"])   return @"iPhone 12 Pro Max";

    
    if ([deviceString isEqualToString:@"iPod1,1"])      return @"iPod Touch 1G";
    if ([deviceString isEqualToString:@"iPod2,1"])      return @"iPod Touch 2G";
    if ([deviceString isEqualToString:@"iPod3,1"])      return @"iPod Touch 3G";
    if ([deviceString isEqualToString:@"iPod4,1"])      return @"iPod Touch 4G";
    if ([deviceString isEqualToString:@"iPod5,1"])      return @"iPod Touch (5 Gen)";

    if ([deviceString isEqualToString:@"iPad1,1"])      return @"iPad";
    if ([deviceString isEqualToString:@"iPad1,2"])      return @"iPad 3G";
    if ([deviceString isEqualToString:@"iPad2,1"])      return @"iPad 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,2"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,3"])      return @"iPad 2 (CDMA)";
    if ([deviceString isEqualToString:@"iPad2,4"])      return @"iPad 2";
    if ([deviceString isEqualToString:@"iPad2,5"])      return @"iPad Mini (WiFi)";
    if ([deviceString isEqualToString:@"iPad2,6"])      return @"iPad Mini";
    if ([deviceString isEqualToString:@"iPad2,7"])      return @"iPad Mini (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,1"])      return @"iPad 3 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,2"])      return @"iPad 3 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad3,3"])      return @"iPad 3";
    if ([deviceString isEqualToString:@"iPad3,4"])      return @"iPad 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad3,5"])      return @"iPad 4";
    if ([deviceString isEqualToString:@"iPad3,6"])      return @"iPad 4 (GSM+CDMA)";
    if ([deviceString isEqualToString:@"iPad4,1"])      return @"iPad Air (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,2"])      return @"iPad Air (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,4"])      return @"iPad Mini 2 (WiFi)";
    if ([deviceString isEqualToString:@"iPad4,5"])      return @"iPad Mini 2 (Cellular)";
    if ([deviceString isEqualToString:@"iPad4,6"])      return @"iPad Mini 2";
    if ([deviceString isEqualToString:@"iPad4,7"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,8"])      return @"iPad Mini 3";
    if ([deviceString isEqualToString:@"iPad4,9"])      return @"iPad Mini 3";
    
    if ([deviceString isEqualToString:@"iPad5,1"])      return @"iPad Mini 4 (WiFi)";
    if ([deviceString isEqualToString:@"iPad5,2"])      return @"iPad Mini 4 (LTE)";
    if ([deviceString isEqualToString:@"iPad5,3"])      return @"iPad Air 2";
    if ([deviceString isEqualToString:@"iPad5,4"])      return @"iPad Air 2";
    
    if ([deviceString isEqualToString:@"iPad6,3"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,4"])      return @"iPad Pro 9.7";
    if ([deviceString isEqualToString:@"iPad6,7"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,8"])      return @"iPad Pro 12.9";
    if ([deviceString isEqualToString:@"iPad6,11"])     return @"iPad (5th generation) WiFi";
    if ([deviceString isEqualToString:@"iPad6,12"])     return @"iPad (5th generation) Wi-Fi + Cellular";
    
    if ([deviceString isEqualToString:@"iPad7,1"])      return @"iPad Pro 12.9 inch 2nd gen (WiFi)";
    if ([deviceString isEqualToString:@"iPad7,2"])      return @"iPad Pro 12.9 inch 2nd gen (Cellular)";
    if ([deviceString isEqualToString:@"iPad7,3"])      return @"iPad Pro 10.5 inch (WiFi)";
    if ([deviceString isEqualToString:@"iPad7,4"])      return @"iPad Pro 10.5 inch (Cellular)";
    if ([deviceString isEqualToString:@"iPad7,11"])      return @"iPad (7th generation)";
    if ([deviceString isEqualToString:@"iPad7,12"])      return @"iPad (7th generation) Wi-Fi + Cellular";

    
    if ([deviceString isEqualToString:@"iPad8,1"] || [deviceString isEqualToString:@"iPad8,2"])    return @"iPad Pro (11-inch) WiFi";
    if ([deviceString isEqualToString:@"iPad8,3"] || [deviceString isEqualToString:@"iPad8,4"])    return @"iPad Pro (11-inch) Wi-Fi + Cellular";
    if ([deviceString isEqualToString:@"iPad8,5"] || [deviceString isEqualToString:@"iPad8,6"])    return @"iPad Pro (12.9-inch) (3rd generation) WiFi";
    if ([deviceString isEqualToString:@"iPad8,7"] || [deviceString isEqualToString:@"iPad8,8"])    return @"iPad Pro (12.9-inch) (3rd generation) Wi-Fi + Cellular";
    if ([deviceString isEqualToString:@"iPad8,9"])      return @"iPad Pro (12.9-inch) (4th generation) WiFi";
    if ([deviceString isEqualToString:@"iPad8,10"])     return @"iPad Pro (12.9-inch) (4th generation) Wi-Fi + Cellular";
    if ([deviceString isEqualToString:@"iPad8,11"])     return @"iPad Pro (11-inch) (2nd generation) WiFi";
    if ([deviceString isEqualToString:@"iPad8,12"])     return @"iPad Pro (11-inch) (2nd generation) Wi-Fi + Cellular";
    if ([deviceString isEqualToString:@"iPad11,1"])     return @"iPad Mini 5 (WiFi)";
    if ([deviceString isEqualToString:@"iPad11,2"])     return @"iPad mini (5th generation) Wi-Fi + Cellular";
    if ([deviceString isEqualToString:@"iPad11,3"])     return @"iPad Air (3rd generation) WiFi";
    if ([deviceString isEqualToString:@"iPad11,4"])     return @"iPad Air (3rd generation) Wi-Fi + Cellular";
    if ([deviceString isEqualToString:@"iPad11,6"])     return @"iPad (8th generation) WiFi";
    if ([deviceString isEqualToString:@"iPad11,7"])     return @"iPad (8th generation) Wi-Fi + Cellular";

    
    if ([deviceString isEqualToString:@"iPad13,1"])     return @"iPad Air (4th generation) WiFi";
    if ([deviceString isEqualToString:@"iPad13,2"])     return @"iPad Air (4th generation) Wi-Fi + Cellular";

    if ([deviceString isEqualToString:@"AppleTV2,1"])   return @"Apple TV 2";
    if ([deviceString isEqualToString:@"AppleTV3,1"])   return @"Apple TV 3";
    if ([deviceString isEqualToString:@"AppleTV3,2"])   return @"Apple TV 3";
    if ([deviceString isEqualToString:@"AppleTV5,3"])   return @"Apple TV 4";
    if ([deviceString isEqualToString:@"i386"])         return @"Simulator";
    if ([deviceString isEqualToString:@"x86_64"])       return @"Simulator";

    return deviceString;
}

- (dispatch_queue_t)trackLoggerQueue {
    if (!_trackLoggerQueue) {
        _trackLoggerQueue = dispatch_queue_create("com.trackLogger.trackLoggerQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _trackLoggerQueue;
}

@end
