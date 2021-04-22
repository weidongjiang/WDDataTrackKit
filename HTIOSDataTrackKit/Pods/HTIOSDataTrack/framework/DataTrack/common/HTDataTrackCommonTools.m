//
//  HTDataTrackCommonTools.m
//  HTIOSDataTrackKit
//
//  Created by 伟东 on 2020/9/9.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "HTDataTrackCommonTools.h"
#import "HTDataTrackConsoleLog.h"

@implementation HTDataTrackCommonTools

+ (float)getPhoneMemeryTotalsize {
    /// 总大小
    float totalsize = 0.0;
    
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    if (dictionary) {
        NSNumber *_total = [dictionary objectForKey:NSFileSystemSize];
        totalsize = [_total unsignedLongLongValue]*1.0/(1024);
    }else {
        HTDTLog(@"Logger:Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    return totalsize;
}

+ (float)getPhoneMemeryFreesize {
    /// 剩余大小
    float freesize = 0.0;

    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    if (dictionary) {
        NSNumber *_free = [dictionary objectForKey:NSFileSystemFreeSize];
        freesize = [_free unsignedLongLongValue]*1.0/(1024);
    }else {
        HTDTLog(@"Logger:Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    return freesize;
}

@end
