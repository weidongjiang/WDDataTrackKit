//
//  HTTDReachability.h
//  HTIOSFoundationToolKit
//
//  Created by 伟东 on 2020/7/22.
//  Copyright © 2020 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>

typedef NS_ENUM(NSUInteger, HTTDNetworkStatus){
    HTTDNotReachable = 0,
    HTTDReachableViaWiFi,
    HTTDReachableViaWWAN
};

typedef NS_ENUM(NSUInteger, HTTDNetworkDetailStatus){
    HTTDNetworkDetailStatusUnable = HTTDNotReachable,
    HTTDNetworkDetailStatusWifi = HTTDReachableViaWiFi,
    HTTDNetworkDetailStatusWWAN = HTTDReachableViaWWAN,
    HTTDNetworkDetailStatus2G,
    HTTDNetworkDetailStatus3G,
    HTTDNetworkDetailStatus4G
};

typedef NS_ENUM(NSUInteger, HTTDMobileISPType) {
    HTTDMobileISPTypeUnknown = 0,
    HTTDMobileISPTypeChinaMobile = 1,
    HTTDMobileISPTypeChinaUnicom = 2,
    HTTDMobileISPTypeChinaTelecom = 3,
    HTTDMobileISPTypeChinaTietong = 4,
};

extern NSString * _Nullable const HTTDReachabilityChangedNotification;

NS_ASSUME_NONNULL_BEGIN

@interface HTTDReachability : NSObject

+ (instancetype)sharedReachability;
- (HTTDNetworkStatus)currentReachabilityStatus;
- (HTTDNetworkDetailStatus)currentDetailReachabilityStatus;
- (HTTDMobileISPType)currentMoblieISPType;

/** Unreachable、WiFi、WWAN、2G、3G、4G、Unknow */
- (NSString *)currentDetailNetString;

@end

NS_ASSUME_NONNULL_END
