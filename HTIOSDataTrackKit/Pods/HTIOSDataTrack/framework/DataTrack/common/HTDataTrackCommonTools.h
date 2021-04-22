//
//  HTDataTrackCommonTools.h
//  HTIOSDataTrackKit
//
//  Created by 伟东 on 2020/9/9.
//  Copyright © 2020 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HTDataTrackCommonTools : NSObject

/// 沙河内存总共大小
+ (float)getPhoneMemeryTotalsize;

/// 沙河剩余内存大小
+ (float)getPhoneMemeryFreesize;

@end

NS_ASSUME_NONNULL_END
