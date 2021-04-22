//
//  HTDataTrackDefine.h
//  HTIOSDataTrackKit
//
//  Created by 伟东 on 2020/8/20.
//  Copyright © 2020 伟东. All rights reserved.
//

#ifndef HTDataTrackDefine_h
#define HTDataTrackDefine_h

#import "HTDataTrackConsoleLog.h"

static NSString * const HTDataTrackLibVersion = @"iOS1.0";// SDK 版本号
static NSString * const HTDataTrackLogVersion = @"1.0";// 日志解析的 版本号 大数据json结构版本
static NSString * const HTDataTrackSASDKVersion = @"1.0";// 神策SDK 版本号

static NSString * const HTDataTrackLoginEventID = @"HTDataTrackLoginEventID";//登录注册 日志ID

static NSUInteger const HTDataTrackSendTimer = 15;// 多少秒轮询一次
static NSUInteger const HTDataTrackUnSendDataMaxCount = 20;// 最大的缓存数
static NSUInteger const HTDataTrackGetSendDataMaxlimit = 20;// 一次获取数据库缓存的条数




#endif /* HTDataTrackDefine_h */
