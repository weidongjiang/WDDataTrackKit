//
//  HTDataTrackConsoleLog.m
//  HTIOSDataTrackKit
//
//  Created by 伟东 on 2020/8/24.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "HTDataTrackConsoleLog.h"
#import "HTDataTrackLogger.h"

static NSString *HTDataTrackEnableLogKey = @"HTDataTrackEetEnableLogKey";//

@interface HTDataTrackConsoleLog ()

@end

@implementation HTDataTrackConsoleLog

+ (BOOL)getIsEnableLog {
    BOOL enableLog = [[NSUserDefaults standardUserDefaults] boolForKey:HTDataTrackEnableLogKey];
    return enableLog;
}

@end
