//
//  HTDataTrackDatabaseMgr.h
//  HTIOSDataTrackKit
//
//  Created by 伟东 on 2020/8/7.
//  Copyright © 2020 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTDataTrackModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTDataTrackDatabaseMgr : NSObject

+ (instancetype)shareInatace;

/// 插入一条数据缓存，返回插入的dataid
/// @param model model description
- (int64_t)insertTraceData:(HTDataTrackModel *)model;

/// 获取缓存的数据
- (NSArray<HTDataTrackModel *>*)getSendDataArrayOffset:(NSInteger)offset limit:(NSInteger)limit;

/// 获取数据库里面没有上报的条数
- (NSUInteger)getUnSendDataCount;

/// 删除缓存 小于model.dataid的数据
/// @param model model description
- (BOOL)deleteTraceDatalessThanWithModel:(HTDataTrackModel *)model;

/// 删除 model.dataid 对应的一条数据
/// @param model model description
- (BOOL)deleteTraceDataWithModel:(HTDataTrackModel *)model;

@end

NS_ASSUME_NONNULL_END
