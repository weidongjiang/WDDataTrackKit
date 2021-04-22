//
//  HTDataTrackLogger.h
//  HTIOSDataTrackKit
//
//  Created by 伟东 on 2020/8/17.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "HTDataTrackCommonLogger.h"
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, HTDataTrackLoggerType) {
    HTDataTrackLoggerSensorsData = 1,// 数据只上报 神策
    HTDataTrackLoggerDatracking = 2,// 数据只上报 数仓
    HTDataTrackLoggerAll = 3 //神策 数仓 都上报
};


@interface HTDataTrackLogger : HTDataTrackCommonLogger

+ (instancetype)shareTrackLogger;

/// 设置上报数据的渠道，默认 HTDataTrackLoggerAll
@property (nonatomic, assign) HTDataTrackLoggerType          loggerType;

/// 获取原生当前的viewController
@property (nonatomic, weak, readonly) UIViewController       *currentVC;


/// 日志调用 没有pvSrting参数
/// @param event 日志事件name 不能为空
/// @param extraParameters 业务方日志埋点数据，如果没有数据可以传null
- (void)logWithEvent:(nonnull NSString *)event
     extraParameters:(nullable NSDictionary *)extraParameters;

/// 日志调用
/// @param event 日志事件name 不能为空
/// @param pvSrting 页面pv标识,如果没有，可以传nil 。默认为原生当前的viewController 类名
/// @param extraParameters 业务方日志埋点数据，如果没有数据可以传null
- (void)logWithEvent:(nonnull NSString *)event
            pvSrting:(nullable NSString *)pvSrting
     extraParameters:(nullable NSDictionary *)extraParameters;


/// 回到前台触发发送日志逻辑
- (void)didFinishLaunchingLogStartSend;


@end


NS_ASSUME_NONNULL_END

