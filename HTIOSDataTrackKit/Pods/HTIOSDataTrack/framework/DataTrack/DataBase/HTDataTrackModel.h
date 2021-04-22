//
//  HTDataTrackModel.h
//  HTIOSDataTrackKit
//
//  Created by 伟东 on 2020/8/10.
//  Copyright © 2020 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HTDataTrackModel : NSObject

@property (nonatomic, assign) NSInteger         dataid; // 数据库中的自增的id
@property (nonatomic, copy) NSString            *dataString; // 需要上报的json串
@property (nonatomic, copy) NSString            *userid;// 登录用户的ID,区分多账号登录的数据
@property (nonatomic, copy) NSString            *time;// 每一条数据插入数据库的时间

@end

NS_ASSUME_NONNULL_END
