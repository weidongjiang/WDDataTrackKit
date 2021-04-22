//
//  HTAppInfo.m
//  HTIOSFoundationToolKit
//
//  Created by 伟东 on 2020/7/23.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "HTAppInfo.h"

@implementation HTAppInfo
static HTAppInfo *_sharedInfo = nil;
+ (instancetype)sharedInfo {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInfo = [[HTAppInfo alloc] init];
    });
    return _sharedInfo;
}

- (instancetype)init {
    if (self = [super init]) {
        NSBundle *bundle = [NSBundle mainBundle];
        NSDictionary *info = [bundle infoDictionary];
        self.bundleDisplayName = [info objectForKey:@"CFBundleDisplayName"];
        self.bundleVersion = [info objectForKey:@"CFBundleShortVersionString"];
        self.buildVersion = [info objectForKey:@"CFBundleVersion"];
    }
    return self;
}
@end
