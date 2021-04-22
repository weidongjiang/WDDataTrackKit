//
//  NSObject+HTValid.m
//  HTIOSFoundationToolKit
//
//  Created by 伟东 on 2020/7/21.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "NSObject+HTValid.h"

@implementation NSObject (HTValid)

- (BOOL)ht_isValid
{
    if (self != nil && (NSNull *)self != [NSNull null]) {
        return YES;
    }
    return NO;
}

- (BOOL)ht_isValidWithClass:(Class)aClass
{
    if ([self ht_isValid] && [self isKindOfClass:aClass]) {
        return YES;
    }
    return NO;
}

@end
