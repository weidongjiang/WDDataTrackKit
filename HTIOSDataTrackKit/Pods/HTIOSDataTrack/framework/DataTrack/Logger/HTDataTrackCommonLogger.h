//
//  HTDataTrackCommonLogger.h
//  HTIOSDataTrackKit
//
//  Created by 伟东 on 2020/8/17.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "HTDataTrackBaseLogger.h"

// 业务线设置自己的业务 设置
static HTDataTrackProductType _Nullable HTDataTrackProductTypeCoding = @"coding";//coding  编程
static HTDataTrackProductType _Nullable HTDataTrackProductTypeMath = @"math";//math  数学
static HTDataTrackProductType _Nullable HTDataTrackProductTypeParent = @"parent";//parent  核桃家长
static HTDataTrackProductType _Nullable HTDataTrackProductTypeConsole = @"console";//console  后台系统
static HTDataTrackProductType _Nullable HTDataTrackProductTypeMfront = @"mfront";//mfront  市场&增长
static HTDataTrackProductType _Nullable HTDataTrackProductTypeOfficial = @"official";//official  官网
static HTDataTrackProductType _Nullable HTDataTrackProductTypeContest = @"contest";//contest  竞赛
static HTDataTrackProductType _Nullable HTDataTrackProductTypeServer = @"server";//server  服务端"
static HTDataTrackProductType _Nullable HTDataTrackProductTypeScratchJr = @"scratchJr";//scratchJr  低幼

static NSString * _Nullable HTDataTrackPVSeqKey = @"HTDataTrackPVSeqKey";//



NS_ASSUME_NONNULL_BEGIN

@interface HTDataTrackCommonLogger : HTDataTrackBaseLogger

@property (nonatomic, copy, readonly) NSString            *userid;

@property (nonatomic, strong) dispatch_queue_t trackLoggerQueue;


/// 设置用户ID
/// @param userid 登录用户ID
- (void)setDataTrackUserid:(NSString *)userid;

/// 业务线设置自己的业务
/// @param product product description
- (void)setDataTrackProduct:(HTDataTrackProductType)product;

/// 位置信息采集功能开关
/// 根据需要决定是否开启位置采集
//* 默认关闭
/// @param enable YES/NO
- (void)enableTrackGPSLocation:(BOOL)enable;

/// 设置是否关闭打印log的开关
/// @param enable yes打开 no关闭 默认打开
- (void)setEnableLog:(BOOL)enable;

/// 更新每次回话的  更新SessionId 、sessionSeq +1启动一次就要更新、pv=0、eventseq=0
- (void)updateDataTrackData;

/// 每一条数据+1
- (void)updateEventSeq;

/// 给神策添加的字段
- (NSDictionary *)dataSADictionary;
/// basic 字段
- (NSDictionary *)basicDictionary;
/// 当前时间戳
- (NSString *)getCuuentTime;
/// 获取时区
- (NSString *)getTimeZoneName;
// 当前 UIViewControl 的类名
- (NSString *)getCurrrntViewControlString;

/// PVSeq 清0 自动上报的pvSeq统一为0，自动上报之后的埋点pvSeq从1开始累加；每次进入新的页面，触发自动上报，pvSeq清零
- (void)updatePVSeq;

@end

NS_ASSUME_NONNULL_END
