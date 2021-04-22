//
//  HTDataTrackConsoleLog.h
//  HTIOSDataTrackKit
//
//  Created by 伟东 on 2020/8/24.
//  Copyright © 2020 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HTDataTrackConsoleLog.h"

#ifdef DEBUG // 调试状态, 打开LOG功能
#define HTDTLog(format, ...) ![HTDataTrackConsoleLog getIsEnableLog]?printf(""):printf("HTDataTrackLogger class: < %s:(%d行) > method: %s \n%s\n", [[[NSString stringWithUTF8String:__FILE__] lastPathComponent] UTF8String], __LINE__, __PRETTY_FUNCTION__,[[NSString stringWithFormat:(format), ##__VA_ARGS__] UTF8String] );
#else// 发布状态, 关闭LOG功能
#define HTDTLog( s, ... )
#endif

@interface HTDataTrackConsoleLog : NSObject
+ (BOOL)getIsEnableLog;

@end
