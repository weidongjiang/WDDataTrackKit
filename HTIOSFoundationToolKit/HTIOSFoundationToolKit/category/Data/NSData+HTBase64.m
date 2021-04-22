//
//  NSData+HTBase64.m
//  HTIOSFoundationToolKit
//
//  Created by 伟东 on 2020/7/22.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "NSData+HTBase64.h"

@implementation NSData (HTBase64)
+ (NSData *)dataFromBase64String:(NSString *)base64String {
    return ([[self alloc] initWithBase64String:base64String]);
}
- (id)initWithBase64String:(NSString *)base64String {
    return [base64String dataUsingEncoding:NSUTF8StringEncoding];
}
- (NSString *)ht_base64EncodedString {
    NSString *resultString = [self base64EncodedStringWithOptions:0];
    return [resultString stringByReplacingOccurrencesOfString:@"\r\n" withString:@""];
}
@end
