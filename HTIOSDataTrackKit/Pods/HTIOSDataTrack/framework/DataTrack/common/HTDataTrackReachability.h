//
//  HTDataTrackReachability.h
//  HTIOSDataTrackKit
//
//  Created by 伟东 on 2020/8/21.
//  Copyright © 2020 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <netinet/in.h>
NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSUInteger, HTNetworkStatus){
    HTNotReachable = 0,
    HTReachableViaWiFi,
    HTReachableViaWWAN
};

typedef NS_ENUM(NSUInteger, HTNetworkDetailStatus){
    HTNetworkDetailStatusUnable = HTNotReachable,
    HTNetworkDetailStatusWifi = HTReachableViaWiFi,
    HTNetworkDetailStatusWWAN = HTReachableViaWWAN,
    HTNetworkDetailStatus2G,
    HTNetworkDetailStatus3G,
    HTNetworkDetailStatus4G
};

typedef NS_ENUM(NSUInteger, HTMobileISPType) {
    HTMobileISPTypeUnknown = 0,
    HTMobileISPTypeChinaMobile = 1,
    HTMobileISPTypeChinaUnicom = 2,
    HTMobileISPTypeChinaTelecom = 3,
    HTMobileISPTypeChinaTietong = 4,
};

@interface HTDataTrackReachability : NSObject

+ (instancetype)shareInstance;

- (HTNetworkStatus)currentReachabilityStatus;
- (HTNetworkDetailStatus)currentDetailReachabilityStatus;
- (HTMobileISPType)currentMoblieISPType;

/** Unreachable、WiFi、WWAN、2G、3G、4G、Unknow */
- (NSString *)currentDetailNetString;


@end

NS_ASSUME_NONNULL_END
