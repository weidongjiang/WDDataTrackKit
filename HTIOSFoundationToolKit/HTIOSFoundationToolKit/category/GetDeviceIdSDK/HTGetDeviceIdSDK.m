//
//  HTGetDeviceIdSDK.m
//  HTIOSFoundationToolKit
//
//  Created by 伟东 on 2020/7/23.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "HTGetDeviceIdSDK.h"
#import "HTOpenUDID.h"
#import "HTTDSFHFKeychainUtils.h"
#import "UIDevice+HTHelpers.h"
#import "NSUserDefaults+HTTypeCast.h"


#define KSinaUDIDKeychainUserName @"kHTSDKKeyChainNEWUDID"  //uuid keychain UserName
#define KSinaUDIDKeychainServiceKey @"kHTSDKKeyChainAuthService" //uuid keychain service
NSString *const KHeTaoSDKUDIDKEY = @"KHeTaoSDKUDIDKEY"; //uuid NSUserDefault key

@interface HTGetDeviceIdSDK ()
+ (NSString*)_generateUDID;
+ (NSString*)_getUniqueStrByUUID_Ex;
@end

@implementation HTGetDeviceIdSDK

+ (NSString *)getUniqueStrByUUID
{
    return [self _getUniqueStrByUUID_Ex];
}

+ (NSString *)getUniqueStrByOpenUDID
{
    NSString* openUDID = [HTOpenUDID value];
    return openUDID;
}

+ (NSString *)md5:(NSString *)str
{
    const char *cStr = [str UTF8String];
    unsigned char result[16];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result);
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];
}

+ (NSString *)getTime
{
    NSDate *  senddate = [NSDate date];
    
    NSDateFormatter  *dateformatter = [[NSDateFormatter alloc] init];
    
    [dateformatter setDateFormat:@"YYYYMMdd"];
    
    NSString *  locationString=[dateformatter stringFromDate:senddate];
    
    return locationString;
}

+ (BOOL)canUseOpenUDID
{
    return NO;
}

+ (NSString *)did
{
    NSString *device = nil;
    if ([self canUseOpenUDID])
    {
        device = [self getUniqueStrByOpenUDID];
    }
    else
    {
        device = [self getUniqueStrByUUID];
    }
    return [self md5:device];
}

+ (NSString *)checkid
{
    return [self md5:[[self did] stringByAppendingString:[[self getTime] stringByAppendingString:@"hongtaok"]]];
}
/*
 获取open udid 或 adid 然后md5生成 32字符串（暂叫：did）。
 
 对这32位字符（did）做校验。
 
 校验方式： （did + 日期 + 密码）做md5生成32位字符串（暂叫：checkid）
 
 最终的deviceid = did + checkid的后8位（共40位的字符串）
 
 */
+ (NSString *)deviceId
{
    return [[self did] stringByAppendingString: [[self checkid] substringFromIndex:24]];
}

+ (NSString *)deviceId64
{
    return  [[self did] stringByAppendingString:[self checkid]];
}

#pragma private

+ (NSString*)_generateUDID{
    
    NSString* udid_string = nil;
    
    /*取adfa*/
    if (YES == [[ASIdentifierManager sharedManager] isAdvertisingTrackingEnabled]) {
        NSUUID* adId = [[ASIdentifierManager sharedManager] advertisingIdentifier];
        
        udid_string = [adId UUIDString];
        assert(NO == [udid_string isEqualToString:@"00000000-0000-0000-0000-000000000000"]);
    }
    
    /*取旧版本保存在keychain中的udid (一段时间后，可以删除这部分代码)*/
    if (nil == udid_string)
    {
        
#define kKeyChainShortDeviceId                      @"kKeyChainShortDeviceId"
#define kKeyChainAuthService                        @"kKeyChainAuthService"
        
        udid_string = [HTTDSFHFKeychainUtils getPasswordForUsername:kKeyChainShortDeviceId
                                                     andServiceName:kKeyChainAuthService
                                                              error:nil];
        
        /*
         旧版本的md5值有可能是 无效值，这里要进行验证一下
         9f89c84a559f573636a47ff8daed0d33 是 00000000-0000-0000-0000-000000000000 的md5值
         */
        if (nil != udid_string)
        {
            if (YES == [udid_string isEqualToString:@"9f89c84a559f573636a47ff8daed0d33"])
            {
                udid_string = nil;
            }
            
            
            /*从keychain中删除这个值，这个值以后不再使用了*/
            [HTTDSFHFKeychainUtils deleteItemForUsername:kKeyChainShortDeviceId andServiceName:kKeyChainAuthService error:nil];
            
        }
    }
    
    
    /*取idfv*/
    if (nil == udid_string) {
        NSUUID* venderid = [[UIDevice currentDevice] identifierForVendor];
        if (nil != venderid)
            udid_string = [venderid UUIDString];
    }
    
    
    /*取uuid*/
    if (nil == udid_string) {
        udid_string = [[NSUUID UUID] UUIDString];
    }
    
    
    return udid_string;

}

+ (NSString*)_getUniqueStrByUUID_Ex{
    
    static dispatch_once_t onceToken;
    static NSString* device_id_string = nil;
    dispatch_once(&onceToken, ^{
        
        NSString* plain_device_id = nil;
        NSString* id_component_string = nil;
        BOOL needSaveUserDefaults = NO;
        BOOL needSaveKeychain = NO;
        
        
        NSString* device_porait = [UIDevice ht_getDevicePortrait];
        
        
        /*尝试从 NSUserDefaults 中取*/
        id_component_string = [[NSUserDefaults standardUserDefaults] htl_stringForKey:KHeTaoSDKUDIDKEY];
        if (0 == [id_component_string length]){
            id_component_string = nil;
            needSaveUserDefaults = YES;
        }
        
        
        /*尝试从keychain中取udid*/
        if (nil == id_component_string){
            id_component_string = [HTTDSFHFKeychainUtils getPasswordForUsername:KSinaUDIDKeychainUserName
                                                                 andServiceName:KSinaUDIDKeychainServiceKey
                                                                          error:nil];
            
            if (0 == [id_component_string length]){
                id_component_string = nil;
                needSaveKeychain = YES;
            }
            
        }
        
        
        
        /*验证设备特征值*/
        if (nil != id_component_string)
        {
            
            NSArray* udid_items = [id_component_string componentsSeparatedByString:@"|"];
            if (nil != udid_items  &&  2 == [udid_items count])
            {
                NSString* old_plain_device_id = [udid_items firstObject]; //device id
                NSString* old_device_porait = [udid_items lastObject]; //device mode info
                
                if (YES == [old_device_porait isEqualToString:device_porait]  &&  0 != [old_plain_device_id length]) {
                    plain_device_id = old_plain_device_id;
                }
            }
            
        }
        
        /*如果没有成功取出plain_device_id, 则重新生成一个*/
        if (nil == plain_device_id)
        {
            plain_device_id = [HTGetDeviceIdSDK _generateUDID];
            
            /*保存重新生成的plain_device_id*/
            if (nil != plain_device_id) {
                
                /*添加设备特征值*/
                id_component_string = [NSString stringWithFormat:@"%@|%@", plain_device_id, device_porait];
                
                needSaveUserDefaults = YES;
                needSaveKeychain = YES;
                
            }
            
        }
        
        /*保存*/
        if (nil != id_component_string  &&  (YES == needSaveUserDefaults  ||  YES == needSaveKeychain) )
        {
            /*保存KeyChain*/
            if (YES == needSaveKeychain)
            {
                [HTTDSFHFKeychainUtils storeUsername:KSinaUDIDKeychainUserName
                                         andPassword:id_component_string
                                      forServiceName:KSinaUDIDKeychainServiceKey
                                      updateExisting:YES
                                               error:nil];
            }
            
            
            /*保存UserDefaults*/
            if (YES == needSaveUserDefaults) {
                [[NSUserDefaults standardUserDefaults] setObject:id_component_string forKey:KHeTaoSDKUDIDKEY];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        
        
        device_id_string = plain_device_id;
        
    });
    
    return device_id_string;
}

@end
