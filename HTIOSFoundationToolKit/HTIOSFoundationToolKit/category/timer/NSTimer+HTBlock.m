//
//  NSTimer+HTBlock.m
//  HTIOSFoundationToolKit
//
//  Created by 伟东 on 2020/7/22.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "NSTimer+HTBlock.h"

@interface NSTimer (BlocksKitPrivate)
+ (void)ht_executeBlockFromTimer:(NSTimer *)aTimer;
@end

@implementation NSTimer (HTBlock)

+ (id)ht_scheduledTimerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)(NSTimer *timer))block repeats:(BOOL)inRepeats
{
    NSParameterAssert(block != nil);
    return [self scheduledTimerWithTimeInterval:inTimeInterval target:self selector:@selector(ht_executeBlockFromTimer:) userInfo:[block copy] repeats:inRepeats];
}

+ (id)ht_timerWithTimeInterval:(NSTimeInterval)inTimeInterval block:(void (^)(NSTimer *timer))block repeats:(BOOL)inRepeats
{
    NSParameterAssert(block != nil);
    return [self timerWithTimeInterval:inTimeInterval target:self selector:@selector(ht_executeBlockFromTimer:) userInfo:[block copy] repeats:inRepeats];
}

+ (void)ht_executeBlockFromTimer:(NSTimer *)aTimer {
    void (^block)(NSTimer *) = [aTimer userInfo];
    if (block) block(aTimer);
}

@end

