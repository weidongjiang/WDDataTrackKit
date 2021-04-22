//
//  HTGetUUID.m
//  HTIOSDataTrackKit
//
//  Created by 伟东 on 2020/11/3.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "HTGetUUID.h"
#import "HTKeychainItemWrapper.h"

#define HTUUID                  @"HTUUID"     // UUID

BOOL isValidNSString(id object)
{
    if (object!=nil && (NSNull *)object != [NSNull null] && [object isKindOfClass:[NSString class]])
    {
        return ((NSString*)object).length>0?YES:NO;
    }
    return NO;
}


@implementation HTGetUUID
+ (instancetype)shareInatace {
    static HTGetUUID *_shareInatace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInatace = [[HTGetUUID alloc] init];
    });
    return _shareInatace;
}

- (NSString*)getDeviceUUID
{
    NSString* value = @"";
    NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
    if (standardUserDefaults) {
        value = [standardUserDefaults objectForKey:HTUUID];
    }
    if (![self yxt_isBlankString:value]) {
        return value;
    }
    //从keychain里获取
    HTKeychainItemWrapper *keychainItem = [[HTKeychainItemWrapper alloc] initWithIdentifier:@"UUID" accessGroup:nil];
    NSString *keyChainUUID = [keychainItem objectForKey:(__bridge id)kSecValueData];
    //都获取不到值的情况，重新创建
    if (!isValidNSString(keyChainUUID))
    {
        CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
        keyChainUUID = (NSString *)CFBridgingRelease(CFUUIDCreateString (kCFAllocatorDefault,uuidRef));
        NSDictionary *dic = [NSDictionary dictionaryWithObjectsAndKeys:@"YZB_CLIENT_UUID",@"YZB_CLIENT_UUID", nil];
//        [keychainItem setObject:dic forKey:(__bridge id)kSecAttrService];
        [keychainItem setObject:keyChainUUID forKey:(__bridge id)kSecValueData];
        
        NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
        if (standardUserDefaults && keyChainUUID != nil) {
            [standardUserDefaults setObject: keyChainUUID forKey:HTUUID];
            [standardUserDefaults synchronize];
        }
    }
    //keychain里的为空，获取default里的
    value = keyChainUUID;
    if ([self yxt_isBlankString:value]) {
        NSUserDefaults* standardUserDefaults = [NSUserDefaults standardUserDefaults];
        if (standardUserDefaults) {
            value = [standardUserDefaults objectForKey:HTUUID];
        }
    }
    return value;
}

- (BOOL)yxt_isBlankString:(NSString *)string
{
    
    if (string == nil) {
        return YES;
    }
    if (string == NULL) {
        return YES;
    }
    if (    [string isEqual:nil]
        ||  [string isEqual:Nil]){
        return YES;
    }
    if (![string isKindOfClass:[NSString class]]) {
        return YES;
    }
    if (0 == [string length]){
        return YES;
    }
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    if([string isEqualToString:@"(null)"]){
        return YES;
    }
    
    return NO;
    
}

@end
