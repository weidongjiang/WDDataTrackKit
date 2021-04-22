//
//  HTDataTrackSendLogger.h
//  HTIOSDataTrackKit
//
//  Created by 伟东 on 2020/8/28.
//  Copyright © 2020 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HTDataTrackSendLogger : NSObject


/// 重置定时器
- (void)startReportTime;

/// 立即上报 一次
- (void)immediatelySend;

@end

NS_ASSUME_NONNULL_END
