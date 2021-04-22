//
//  AppDelegate.m
//  HTIOSDataTrackKit
//
//  Created by 伟东 on 2020/8/7.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "AppDelegate.h"
#import "HTDataTrackLogger.h"
#import "SensorsAnalyticsSDK.h"

#define SA_SERVER_URL               @"https://sensors.hetao101.com/sa?project=production"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    // 数仓相关设置
    // 是否获取用户定位信息
    [[HTDataTrackLogger shareTrackLogger] enableTrackGPSLocation:NO];
    // 设置用户ID
    [[HTDataTrackLogger shareTrackLogger] setDataTrackUserid:@"9999999"];
    // 设置对应的业务线
    [[HTDataTrackLogger shareTrackLogger] setDataTrackProduct:HTDataTrackProductTypeScratchJr];
    // 设置数据上报的渠道，HTDataTrackLoggerSensorsData  数据只上报神策，HTDataTrackLoggerDatracking 数据只上报数仓，HTDataTrackLoggerAll 神策 数仓 都上报
    [HTDataTrackLogger shareTrackLogger].loggerType = HTDataTrackLoggerAll;
    // 更新每次回话的  SessionId 启动一次就要更新，保证唯一性
    [[HTDataTrackLogger shareTrackLogger] updateDataTrackData];
    // 启动上报数据
    [[HTDataTrackLogger shareTrackLogger] didFinishLaunchingLogStartSend];
    // 设置打印log日志开关，yes关闭，no打开
    [[HTDataTrackLogger shareTrackLogger] setEnableLog:NO];
    
    
    // 神策相关设置
    SAConfigOptions *options = [[SAConfigOptions alloc] initWithServerURL:SA_SERVER_URL launchOptions:launchOptions];
    options.autoTrackEventType = SensorsAnalyticsEventTypeAppStart |
                                 SensorsAnalyticsEventTypeAppEnd |
                                 SensorsAnalyticsEventTypeAppClick |
                                 SensorsAnalyticsEventTypeAppViewScreen;
    options.enableTrackAppCrash = YES;
    [SensorsAnalyticsSDK startWithConfigOptions:options];
    [[SensorsAnalyticsSDK sharedInstance] trackInstallation:@"AppInstall"];
    [[SensorsAnalyticsSDK sharedInstance] enableLog:NO];
    
    
    return YES;
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    // Called when a new scene session is being created.
    // Use this method to select a configuration to create the new scene with.
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    // Called when the user discards a scene session.
    // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
    // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
}


@end
