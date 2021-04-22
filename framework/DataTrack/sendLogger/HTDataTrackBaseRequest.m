//
//  HTDataTrackBaseRequest.m
//  HTIOSDataTrackKit
//
//  Created by 伟东 on 2020/9/7.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "HTDataTrackBaseRequest.h"
#import <sys/utsname.h>
#import "HTCategoryTools.h"
#import "HTDataTrackConsoleLog.h"
#import "HTGetUUID.h"

@implementation HTDataTrackBaseRequest

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary {
    
    //APP版本
    NSString *version = (NSString *)[[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"];
    if ([NSString htdt_isEmptyString:version]) {
        version = @"";
    }
    //手机系统版本 ios11.4
    NSString *systemName = [[UIDevice currentDevice] systemName];       //ios
    NSString *systemVersion = [[UIDevice currentDevice] systemVersion]; //11.4
    NSString *pv = [NSString stringWithFormat:@"%@%@",systemName,systemVersion];//ios11.4
    
    //手机唯一标识
    NSString *uuid = [self getuuid];
    
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    [dict htdt_setSafeObject:@"ios" forKey:@"htdt_SYSTEM"];
    [dict htdt_setSafeObject:@"ios" forKey:@"phone_type"];
    [dict htdt_setSafeObject:version forKey:@"htdt_VERSION"];
    [dict htdt_setSafeObject:uuid forKey:@"htdt_DEVICENO"];
    [dict htdt_setSafeObject:pv forKey:@"os_version"];

    return [dict copy];
}

- (NSString *)getuuid {
    NSString *uuid = [[HTGetUUID shareInatace] getDeviceUUID];
    HTDTLog(@"getuuid--uuid---%@",uuid)
    if (!uuid.length) {
        return @"-";
    }
    return uuid;
}

@end
