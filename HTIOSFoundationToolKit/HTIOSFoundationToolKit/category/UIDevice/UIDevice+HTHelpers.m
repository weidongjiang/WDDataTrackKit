//
//  UIDevice+HTHelpers.m
//  HTIOSFoundationToolKit
//
//  Created by 伟东 on 2020/7/22.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "UIDevice+HTHelpers.h"

#import <MessageUI/MessageUI.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <AVFoundation/AVFoundation.h>
#import "UIDevice+HTMachInfo.h"
#import <PhotosUI/PhotosUI.h>
#import <objc/runtime.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <CoreTelephony/CTCellularData.h>
#import <CoreLocation/CoreLocation.h>
#import <Contacts/Contacts.h>
#import <AddressBook/AddressBook.h>
#import <SystemConfiguration/CaptiveNetwork.h>

#import  <sys/utsname.h>
#include <sys/types.h>
#include <sys/sysctl.h>
#include <sys/socket.h>
#include <net/if.h>
#include <net/if_dl.h>
#import <mach/mach.h>
#import <ifaddrs.h>
#import <arpa/inet.h>
#import <resolv.h>
#import <dns.h>
#import "route.h"

#import "NSDictionary+HTKeyValue.h"
#import "NSDictionary+HTTypeCast.h"
#import "HTTDReachability.h"

#import <AdSupport/AdSupport.h>
#import "HTGetDeviceIdSDK.h"
#import "NSString+HTUtilities.h"
#import "NSUserDefaults+HTTypeCast.h"
#import "NSString+HTString.h"
#import "HTRSABase.h"
#import "HTTDSFHFKeychainUtils.h"
#import "HTOpenUDID.h"
#import "HTAppInfo.h"


#define kKeyAppWmForHeTao   @"app store"

#define CTL_NET         4               /* network, see socket.h */

#define ROUNDUP(a) \
((a) > 0 ? (1 + (((a) - 1) | (sizeof(long) - 1))) : sizeof(long))
#define ARRAY_SIZE(a) sizeof(a)/sizeof(a[0])

static BOOL cellularDataAuthor = NO;

@implementation UIDevice (HTHelpers)


const char* jailbreak_tool_pathes[] = {
    "/Applications/Cydia.app",
    "/Library/MobileSubstrate/MobileSubstrate.dylib",
    "/bin/bash",
    "/usr/sbin/sshd",
    "/etc/apt"
};

+ (CGFloat)portraitWidthWithOffset:(BOOL)needOffset;
{
    if (needOffset && [[UIDevice currentDevice] ht_isUIUserInterfaceIdiomPad])
    {
        return (MIN(HTCurrentWindow.bounds.size.width,HTCurrentWindow.bounds.size.height)) - HTKeyWindowPortraitWidthOffset;
    }
    return (MIN(HTCurrentWindow.bounds.size.width,HTCurrentWindow.bounds.size.height));
}

- (ht_ScreenType)screenType
{
    static ht_ScreenType screenType = ht_ScreenTypeUndefined;
    if (screenType == ht_ScreenTypeUndefined) {
        CGRect screenBounds = [[UIScreen mainScreen] bounds];
        int height = MAX(screenBounds.size.width, screenBounds.size.height);
        int width = MIN(screenBounds.size.width, screenBounds.size.height);

        int scale = [[UIScreen mainScreen] scale];

        if (height == 480 && width == 320) {
            if (scale == 1) {
                screenType = ht_ScreenTypeClassic;
            } else if (scale == 2){
                screenType = ht_ScreenTypeRetina;
            }
        } else if (height == 568 && width == 320){
            screenType = ht_ScreenType4InchRetina;
        } else if (height == 667 && width == 375){
            screenType = ht_ScreenType6;
        } else if (height == 812 && width == 375) {
            screenType = ht_ScreenTypeX;
        } else if (height == 736 && width == 414){
            screenType = ht_ScreenType6Plus;
        } else if (height == 1024 && width == 768) {
            if (scale == 1){
                screenType = ht_ScreenTypeIpadClassic;
            } else if (scale == 2) {
                screenType = ht_ScreenTypeIpadRetina;
            }
        } else if (height == 1366 && width == 1024) {
            screenType = ht_ScreenTypeIpadPro;
        } else if (height == 896 && width == 414){
            if (scale == 2){
                screenType = ht_ScreenTypeXR;
            } else if (scale == 3){
                screenType = ht_ScreenTypeXS_Max;
            }
        } else if (height == 896 && width == 414) {
            if (scale == 2){//11
                screenType = ht_ScreenType11;
            } else if (scale == 3){//11 pro max
                screenType = ht_ScreenType11ProMax;
            }
        }else if (height == 812 && width == 375) {// 11 pro
            screenType = ht_ScreenType11Pro;
        }
    }
    return screenType;
}

- (BOOL)ht_isRetinaDisplay
{
    if ([[UIScreen mainScreen] scale] > 1.0)
    {
        return YES;
    }

    return NO;
}

- (BOOL)ht_is4InchRetinaDisplay
{
    return [self screenType] == ht_ScreenType4InchRetina;
}

- (BOOL)ht_is4InchRetinaDisplay_old
{
    return [self ht_isLongScreen];
}

- (BOOL)ht_isLongScreen
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    return MAX(screenBounds.size.width, screenBounds.size.height) > 480;
}

- (BOOL)ht_is5InchRetinaLongScreen// 大于667的4.7英寸的，也就是5英寸的以上
{
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    return MAX(screenBounds.size.width, screenBounds.size.height) > 667;
}

- (BOOL)ht_isIPhone6Plus
{
    return [self screenType] == ht_ScreenType6Plus;
}

- (BOOL)ht_isIPhone6
{
    return [self screenType] == ht_ScreenType6;
}

-(BOOL)ht_isIPhoneX
{
    return [self screenType] == ht_ScreenTypeX;
}

- (BOOL)ht_isIPhoneXR{
    return [self screenType] == ht_ScreenTypeXR;
}

- (BOOL)ht_isIPhoneXS_Max{
    return [self screenType] == ht_ScreenTypeXS_Max;
}

- (BOOL)ht_isIPhone_fullScreen{
    return [self ht_isIPhoneX] || [self ht_isIPhoneXR] || [self ht_isIPhoneXS_Max];
}

- (BOOL)ht_isIPad
{
//    if (kSupportUniversal)
//    {
    return ([self ht_isIPadClassic] || [self ht_isIPadRetina] || [self ht_isIPadPro]);
//    }
//    return NO;
}


- (BOOL)ht_isIPadClassic
{
    return [self screenType] == ht_ScreenTypeIpadClassic;
}

- (BOOL)ht_isIPadRetina
{
    return [self screenType] == ht_ScreenTypeIpadRetina;
}

- (BOOL)ht_isIPadPro
{
    return [self screenType] == ht_ScreenTypeIpadPro;
}


//- (BOOL)ht_shouldApplyiOS7Appearence
//{
//    IF_IOS7_OR_GREATER({
//        return YES;
//    })
//    return NO;
//}

static int systemMainVersion = 0;
- (int)ht_systemMainVersion
{
    if (systemMainVersion > 0) {
        return systemMainVersion;
    }
    systemMainVersion = [self systemVersion].intValue;
    return systemMainVersion;
}

- (NSString *)ht_carrierName
{
    // Carrier name.
    // 若有俩卡，返回主卡信息；
    CTTelephonyNetworkInfo *telephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];

    NSDictionary *cellularProviderInfo = nil;
    __block NSString *carrierName = nil;
    if (@available(iOS 12.1, *)) {
        if ([telephonyNetworkInfo respondsToSelector:@selector(serviceSubscriberCellularProviders)]) {
            cellularProviderInfo = [telephonyNetworkInfo serviceSubscriberCellularProviders];
        }
    } else if (@available(iOS 12.0, *)) {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if ([telephonyNetworkInfo respondsToSelector:@selector(serviceSubscriberCellularProvider)]) {
            cellularProviderInfo = [telephonyNetworkInfo performSelector:@selector(serviceSubscriberCellularProvider)];
        }
        #pragma clang diagnostic pop
    }
    if (cellularProviderInfo) {
        [cellularProviderInfo ht_enumerateKeysAndUnknownObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            CTCarrier *carrier = (CTCarrier *)obj;
            if (carrier.carrierName && carrier.isoCountryCode){
                if (!carrierName){
                    carrierName = carrier.carrierName;
                } else { //说明有两张卡
                    if ([key isEqualToString:@"0000000100000001"]){
                        carrierName = carrier.carrierName;
                    }
                }
            }
        }];
    } else {
        carrierName = [[telephonyNetworkInfo subscriberCellularProvider] carrierName];
    }
    return carrierName;
}

-(NSString *)ht_countryISO
{
    CTTelephonyNetworkInfo *telephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];

    __block NSString *countryIso = nil;
    NSDictionary *cellularProviderInfo = nil;
    if (@available(iOS 12.1, *)) {
        if ([telephonyNetworkInfo respondsToSelector:@selector(serviceSubscriberCellularProviders)]) {
            cellularProviderInfo = [telephonyNetworkInfo serviceSubscriberCellularProviders];
        }
    } else if (@available(iOS 12.0, *)) { //解决12.0bug
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if ([telephonyNetworkInfo respondsToSelector:@selector(serviceSubscriberCellularProvider)]) {
            cellularProviderInfo = [telephonyNetworkInfo performSelector:@selector(serviceSubscriberCellularProvider)];
        }
#pragma clang diagnostic pop
    }
    if (cellularProviderInfo) {
        [cellularProviderInfo ht_enumerateKeysAndUnknownObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            CTCarrier *carrier = (CTCarrier *)obj;
            if (carrier.carrierName && carrier.isoCountryCode){
                if (!countryIso){
                    countryIso = carrier.isoCountryCode;
                } else { //说明有两张卡
                    if ([key isEqualToString:@"0000000100000001"]){
                        countryIso = carrier.isoCountryCode;
                    }
                }
            }
        }];
    } else {
        countryIso = [telephonyNetworkInfo subscriberCellularProvider].isoCountryCode;
    }
    return countryIso;
}

+ (NSString*)ht_systemName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *systemName = [NSString stringWithCString:systemInfo.sysname encoding:NSUTF8StringEncoding];
    return systemName;
}

+ (long long)ht_getMemoryInfo
{
    long long total = [NSProcessInfo processInfo].physicalMemory;
    return total;
}

+ (long long)ht_getUsedMemory
{
    struct mach_task_basic_info info;
    mach_msg_type_number_t size = MACH_TASK_BASIC_INFO_COUNT;

    int r = task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)& info, & size);
    if (r == KERN_SUCCESS)
    {
        NSLog(@"policy %d vm %f",info.policy,info.virtual_size / 1024.0 /1024.0);
        return info.resident_size;
    }
    else
    {
        return -1;
    }
}

+ (long long)ht_availableMemory
{
    vm_statistics64_data_t vmStats;
    mach_msg_type_number_t infoCount = HOST_VM_INFO_COUNT;
    kern_return_t kernReturn = host_statistics(mach_host_self(),
                                               HOST_VM_INFO,
                                               (host_info_t)&vmStats,
                                               &infoCount);

    if (kernReturn != KERN_SUCCESS) {
        return NSNotFound;
    }

    return vm_page_size * (vmStats.free_count + vmStats.inactive_count);
}

+ (long long)ht_deviceUsedMemory
{
    size_t length = 0;
    int mib[6] = {0};

    int pagesize = 0;
    mib[0] = CTL_HW;
    mib[1] = HW_PAGESIZE;
    length = sizeof(pagesize);
    if (sysctl(mib, 2, &pagesize, &length, NULL, 0) < 0)
    {
        return 0;
    }

    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;

    vm_statistics_data_t vmstat;

    if (host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmstat, &count) != KERN_SUCCESS)
    {
        return 0;
    }

    int wireMem = vmstat.wire_count * pagesize;
    int activeMem = vmstat.active_count * pagesize;
    return wireMem + activeMem;
}

+ (long long)ht_getVirtulMemory
{
    struct mach_task_basic_info info;
    mach_msg_type_number_t size = MACH_TASK_BASIC_INFO_COUNT;

    int r = task_info(mach_task_self(), MACH_TASK_BASIC_INFO, (task_info_t)& info, & size);
    if (r == KERN_SUCCESS)
    {
        long long vz = info.virtual_size / 1024.0 /1024.0;
        return vz;
    }
    else
    {
        return -1;
    }
}

- (NSString *)ht_mobileCountryCode
{
    CTTelephonyNetworkInfo *telephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];//autorelease];
    return [[telephonyNetworkInfo subscriberCellularProvider] mobileCountryCode];
}
- (NSString *)ht_mobileNetworkCode
{
    CTTelephonyNetworkInfo *telephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];// autorelease];
    return [[telephonyNetworkInfo subscriberCellularProvider] mobileNetworkCode];
}

+(NSDictionary*)ht_getWifiInfo {
    Boolean wifiEnable = false;
    NSString *name = @"null";
    NSString *ssid = @"null";
    NSString *bssid = @"null";

    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();
    for (NSString *ifname in ifs) {
        wifiEnable = true;
        name = ifname;
        NSDictionary *info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifname);
        if (nil == info) {
            continue;
        }
        ssid = [info objectForKey:@"SSID"];
        bssid = [info objectForKey:@"BSSID"];
    }

    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:2];
    if (ssid) {
        [dict setObject:ssid forKey:@"ssid"];
    }
    if (bssid) {
        [dict setObject:bssid forKey:@"bssid"];
    }

    return dict;
}

- (BOOL)ht_canMakeCall
{
    static BOOL checked = NO;
    static BOOL result = NO;

    if (checked == NO)
    {
        result = ([[[UIDevice currentDevice] model] rangeOfString:@"iPhone"].location != NSNotFound);
        checked = YES;
    }

    return result;
}

- (BOOL)ht_canSendText
{
    static BOOL checked = NO;
    static BOOL result = NO;

    if (checked == NO)
    {
        result = [MFMessageComposeViewController canSendText];
        checked = YES;
    }

    return result;
}


+ (NSString *) ht_getStandardPlat
{
    //    return [self getReturnPlat:[self platform]];
    return [self ht_platform];
}

+ (NSString *) ht_platform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    return platform;
}

+ (NSString *)ht_getReturnPlat:(NSString *)platform
{
    if ([platform isEqualToString:@"i386"]) {
        return @"simulator";
    }
    if ([platform isEqualToString:@"iPod1,1"]) {
        return @"ipodtouch1";
    }
    if ([platform isEqualToString:@"iPod2,1"]) {
        return @"ipodtouch2";
    }
    if ([platform isEqualToString:@"iPod3,1"]) {
        return @"ipodtouch3";
    }
    if ([platform isEqualToString:@"iPod4,1"]) {
        return @"ipodtouch4";
    }
    if ([platform isEqualToString:@"iPod5,1"]) {
        return @"ipodtouch5";
    }
    if ([platform isEqualToString:@"iPod7,1"]) {
        return @"ipodtouch6";
    }
    if ([platform isEqualToString:@"iPod9,1"]) {
        return @"ipodtouch7";
    }


    if ([platform isEqualToString:@"iPhone1,1"]) {
        return @"iphone1";
    }
    if ([platform isEqualToString:@"iPhone1,2"]) {
        return @"iphone3g";
    }
    if ([platform isEqualToString:@"iPhone2,1"]) {
        return @"iphone3gs";
    }
    if ([platform isEqualToString:@"iPhone3,1"] || [platform isEqualToString:@"iPhone3,2"] || [platform isEqualToString:@"iPhone3,3"]) {
        return @"iphone4";
    }
    if ([platform isEqualToString:@"iPhone4,1"]) {
        return @"iphone4s";
    }
    if ([platform isEqualToString:@"iPhone5,1"] || [platform isEqualToString:@"iPhone5,2"]) {
        return @"iphone5";
    }
    if ([platform isEqualToString:@"iPhone5,3"] || [platform isEqualToString:@"iPhone5,4"]) {
        return @"iphone5c";
    }
    if ([platform isEqualToString:@"iPhone6,1"] || [platform isEqualToString:@"iPhone6,2"]) {
        return @"iphone5s";
    }
    if ([platform isEqualToString:@"iPhone7,2"]) {
        return @"iphone6";
    }
    if ([platform isEqualToString:@"iPhone7,1"]) {
        return @"iphone6 plus";
    }
    if ([platform isEqualToString:@"iPhone8,1"]) {
        return @"iphone6s";
    }
    if ([platform isEqualToString:@"iPhone8,2"]) {
        return @"iphone6s plus";
    }
    if ([platform isEqualToString:@"iPhone8,4"]) {
        return @"iphone se";
    }
    if ([platform isEqualToString:@"iPhone9,1"] || [platform isEqualToString:@"iPhone9,3"]) {
        return @"iphone7";
    }
    if ([platform isEqualToString:@"iPhone9,2"] || [platform isEqualToString:@"iPhone9,4"]) {
        return @"iphone7 plus";
    }

    if ([platform isEqualToString:@"iPhone10,1"] || [platform isEqualToString:@"iPhone10,4"]) {
        return @"iphone8";
    }

    if ([platform isEqualToString:@"iPhone10,2"] || [platform isEqualToString:@"iPhone10,5"]) {
        return @"iphone8 plus";
    }

    if ([platform isEqualToString:@"iPhone10,3"] || [platform isEqualToString:@"iPhone10,6"]) {
        return @"iphoneX";
    }

    if ([platform isEqualToString:@"iPhone11,2"]) {
        return @"iphoneXS";
    }

    if ([platform isEqualToString:@"iPhone11,4"] || [platform isEqualToString:@"iPhone11,6"]) {
        return @"iphoneXS Max";
    }

    if ([platform isEqualToString:@"iPhone11,8"]) {
        return @"iphoneXR";
    }

    if ([platform isEqualToString:@"iPhone12,1"]) {
        return @"iphone11";
    }

    if ([platform isEqualToString:@"iPhone12,3"]) {
        return @"iphone11Pro";
    }

    if ([platform isEqualToString:@"iPhone12,5"]) {
        return @"iphone11Pro_Max";
    }

    if ([platform isEqualToString:@"iPhone12,8"]) {
        return @"iphone se2";
    }


    if ([platform isEqualToString:@"iPad1,1"]) {
        return @"ipad1";
    }
    if ([platform isEqualToString:@"iPad2,1"] || [platform isEqualToString:@"iPad2,2"] || [platform isEqualToString:@"iPad2,3"] || [platform isEqualToString:@"iPad2,4"]) {
        return @"ipad2";
    }
    if ([platform isEqualToString:@"iPad3,1"] || [platform isEqualToString:@"iPad3,2"] || [platform isEqualToString:@"iPad3,3"]) {
        return @"ipad3";
    }
    if ([platform isEqualToString:@"iPad3,4"] || [platform isEqualToString:@"iPad3,5"] || [platform isEqualToString:@"iPad3,6"]) {
        return @"ipad4";
    }
    if ([platform isEqualToString:@"iPad6,11"] || [platform isEqualToString:@"iPad6,12"]) {
        return @"ipad5";
    }
    if ([platform isEqualToString:@"iPad7,5"] || [platform isEqualToString:@"iPad7,6"]) {
        return @"ipad6";
    }
    if ([platform isEqualToString:@"iPad7,11"] || [platform isEqualToString:@"iPad7,12"]) {
        return @"ipad7";
    }
    if ([platform isEqualToString:@"iPad4,1"] || [platform isEqualToString:@"iPad4,2"] || [platform isEqualToString:@"iPad4,3"]) {
        return @"ipad air";
    }
    if ([platform isEqualToString:@"iPad5,3"] || [platform isEqualToString:@"iPad5,4"]) {
        return @"ipad air 2";
    }
    if ([platform isEqualToString:@"iPad11,3"] || [platform isEqualToString:@"iPad11,4"]) {
        return @"ipad air 3";
    }
    if ([platform isEqualToString:@"iPad6,3"] || [platform isEqualToString:@"iPad6,4"]) {
        return @"ipad Pro 9.7-inch";
    }
    if ([platform isEqualToString:@"iPad6,7"] || [platform isEqualToString:@"iPad6,8"]) {
        return @"ipad Pro 12.9-inch";
    }
    if ([platform isEqualToString:@"iPad7,1"] || [platform isEqualToString:@"iPad7,2"]) {
        return @"ipad Pro 12.9-inch 2";
    }
    if ([platform isEqualToString:@"iPad7,3"] || [platform isEqualToString:@"iPad7,4"]) {
        return @"ipad Pro 10.5-inch";
    }
    if ([platform isEqualToString:@"iPad8,1"] || [platform isEqualToString:@"iPad8,2"] || [platform isEqualToString:@"iPad8,3"] || [platform isEqualToString:@"iPad8,4"]) {
        return @"ipad Pro 11-inch";
    }
    if ([platform isEqualToString:@"iPad8,5"] || [platform isEqualToString:@"iPad8,6"] || [platform isEqualToString:@"iPad8,7"] || [platform isEqualToString:@"iPad8,8"]) {
        return @"ipad Pro 12.9-inch 3";
    }
    if ([platform isEqualToString:@"iPad8,9"] || [platform isEqualToString:@"iPad8,10"]) {
        return @"ipad Pro 11-inch 2";
    }
    if ([platform isEqualToString:@"iPad8,11"] || [platform isEqualToString:@"iPad8,12"]) {
        return @"ipad Pro 12.9-inch 4";
    }
    if ([platform isEqualToString:@"iPad2,5"] || [platform isEqualToString:@"iPad2,6"] || [platform isEqualToString:@"iPad2,7"]) {
        return @"ipad mini";
    }
    if ([platform isEqualToString:@"iPad4,4"] || [platform isEqualToString:@"iPad4,5"] || [platform isEqualToString:@"iPad4,6"]) {
        return @"ipad mini 2";
    }
    if ([platform isEqualToString:@"iPad4,7"] || [platform isEqualToString:@"iPad4,8"] || [platform isEqualToString:@"iPad4,9"]) {
        return @"ipad mini 3";
    }
    if ([platform isEqualToString:@"iPad5,1"] || [platform isEqualToString:@"iPad5,2"]) {
        return @"ipad mini 4";
    }
    if ([platform isEqualToString:@"iPad11,1"] || [platform isEqualToString:@"iPad11,2"]) {
        return @"ipad mini 5";
    }
    return platform;
}

- (BOOL)ht_hasLedLight
{
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    return [device hasTorch];
}
- (BOOL)ht_isLedLightOn
{
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch])
    {
        return [device torchMode] == AVCaptureTorchModeOn;
    }
    return NO;
}
- (void)ht_turnLedLightTo:(BOOL)on
{
    AVCaptureDevice * device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if ([device hasTorch])
    {
        [device lockForConfiguration:nil];
        [device setTorchMode:on?AVCaptureTorchModeOn:AVCaptureTorchModeOff];
        [device unlockForConfiguration];
    }
}

- (BOOL)ht_cameraAuthorizationStatus
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        return NO;
    } else {
        return YES;
    }
}

-(BOOL)ht_micAuthorizationStatus
{
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];//麦克风权限
    if (authStatus == AVAuthorizationStatusDenied || authStatus == AVAuthorizationStatusRestricted) {
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)ht_albumAuthorizationStatus
{
    ALAuthorizationStatus authStatus = [ALAssetsLibrary authorizationStatus];
    if (authStatus == ALAuthorizationStatusDenied || authStatus == ALAuthorizationStatusRestricted) {
        return NO;
    }else{
        return YES;
    }
}

- (BOOL)ht_cellularDataAuthorizationStatus
{
    CTCellularData *cellularData = [[CTCellularData alloc] init];
    cellularData.cellularDataRestrictionDidUpdateNotifier =  ^(CTCellularDataRestrictedState state){
        //获取联网状态
        switch (state) {
            case kCTCellularDataRestricted:
                cellularDataAuthor = NO;
                break;
            case kCTCellularDataNotRestricted:
                cellularDataAuthor = YES;
                break;
            case kCTCellularDataRestrictedStateUnknown:
                cellularDataAuthor = NO;
                break;
            default:
                cellularDataAuthor = NO;
        };
    };
    return cellularDataAuthor;
}

- (BOOL)ht_locationAuthorizationStatus
{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusRestricted
        || [CLLocationManager authorizationStatus] == kCLAuthorizationStatusNotDetermined) {
        // 没有权限，
        return NO;
    } else {
        return YES;
    }
}

- (BOOL)ht_notificationAuthorizationStatus
{
    UIUserNotificationSettings *settings = [[UIApplication sharedApplication] currentUserNotificationSettings];
    if (settings.types != UIUserNotificationTypeNone) {
        return YES;
    } else {
        return NO;
    }
}

- (BOOL)ht_contactsAuthorizationStatus
{
    if ([self ht_systemMainVersion] > 9) {
        CNAuthorizationStatus status = [CNContactStore authorizationStatusForEntityType:CNEntityTypeContacts];
        switch (status) {
            case CNAuthorizationStatusAuthorized:
                return YES;
            case CNAuthorizationStatusDenied:
            case CNAuthorizationStatusRestricted:
            case CNAuthorizationStatusNotDetermined:
            default:
                return NO;

        }
    } else {
        ABAuthorizationStatus ABstatus = ABAddressBookGetAuthorizationStatus();
        switch (ABstatus) {
            case kABAuthorizationStatusAuthorized:
                return YES;
            case kABAuthorizationStatusDenied:
            case kABAuthorizationStatusNotDetermined:
            case kABAuthorizationStatusRestricted:
            default:
                return NO;
        }
    }

    return NO;
}

-(BOOL)ht_isVPNConnected
{
    if ([self ht_systemMainVersion] > 9) {
        NSDictionary *dict = CFBridgingRelease(CFNetworkCopySystemProxySettings());
        NSArray *keys = [dict[@"__SCOPED__"]allKeys];
        for (NSString *key in keys) {
            if ([key rangeOfString:@"tap"].location != NSNotFound ||
                [key rangeOfString:@"tun"].location != NSNotFound ||
                [key rangeOfString:@"ppp"].location != NSNotFound){
                return YES;
            }
        }
        return NO;
    } else {
        struct ifaddrs *interfaces = NULL;
        struct ifaddrs *temp_addr  = NULL;

        int success = 0;
        // retrieve the current interfaces - returns 0 on success

        success = getifaddrs(&interfaces);

        if (success == 0) {
            // Loop through linked list of interfaces

            temp_addr = interfaces;

            while (temp_addr != NULL) {

                NSString *string = [NSString stringWithFormat:@"%s" , temp_addr->ifa_name];

                if ([string rangeOfString:@"tap"].location != NSNotFound ||

                    [string rangeOfString:@"tun"].location != NSNotFound ||

                    [string rangeOfString:@"ppp"].location != NSNotFound){

                    return YES;

                }

                temp_addr = temp_addr->ifa_next;

            }

        }
        // Free memory

        freeifaddrs(interfaces);

        return NO;
    }

}

- (NSString *)ht_getLocalIPAddress
{
    NSString *address = @"0.0.0.0";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;

    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);

    if (success == 0)
    {
        temp_addr = interfaces;

        while(temp_addr != NULL)
        {
            // check if interface is en0 which is the wifi connection on the iPhone
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }

            temp_addr = temp_addr->ifa_next;
        }
    }

    freeifaddrs(interfaces);

    return address;
}

- (NSString *)ht_getNetMaskAddress
{
    NSString *netMask = @"0.0.0.0";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;

    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);

    if (success == 0)
    {
        temp_addr = interfaces;

        while(temp_addr != NULL)
        {
            // check if interface is en0 which is the wifi connection on the iPhone
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    netMask = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_netmask)->sin_addr)];
                }
            }

            temp_addr = temp_addr->ifa_next;
        }
    }

    freeifaddrs(interfaces);

    return netMask;

}

- (NSString *)ht_getGatewayAddress
{

    NSString *address = nil;
#if !TARGET_IPHONE_SIMULATOR
    /* net.route.0.inet.flags.gateway */
    int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET,
        NET_RT_FLAGS, RTF_GATEWAY};
    size_t l;
    char * buf, * p;
    struct rt_msghdr * rt;
    struct sockaddr * sa;
    struct sockaddr * sa_tab[RTAX_MAX];
    int i;
    int r = -1;

    if(sysctl(mib, sizeof(mib)/sizeof(int), 0, &l, 0, 0) < 0) {
        address = @"192.168.0.1";
    }

    if(l>0) {
        buf = malloc(l);
        if(sysctl(mib, sizeof(mib)/sizeof(int), buf, &l, 0, 0) < 0) {
            address = @"192.168.0.1";
        }

        for(p=buf; p<buf+l; p+=rt->rtm_msglen) {
            rt = (struct rt_msghdr *)p;
            sa = (struct sockaddr *)(rt + 1);
            for(i=0; i<RTAX_MAX; i++)
            {
                if(rt->rtm_addrs & (1 << i)) {
                    sa_tab[i] = sa;
                    sa = (struct sockaddr *)((char *)sa + ROUNDUP(sa->sa_len));
                } else {
                    sa_tab[i] = NULL;
                }
            }

            if( ((rt->rtm_addrs & (RTA_DST|RTA_GATEWAY)) == (RTA_DST|RTA_GATEWAY))
               && sa_tab[RTAX_DST]->sa_family == AF_INET
               && sa_tab[RTAX_GATEWAY]->sa_family == AF_INET) {
                unsigned char octet[4]  = {0,0,0,0};
                int i;
                for (i=0; i<4; i++){
                    octet[i] = ( ((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_addr.s_addr >> (i*8) ) & 0xFF;
                }
                if(((struct sockaddr_in *)sa_tab[RTAX_DST])->sin_addr.s_addr == 0) {
                    in_addr_t addr = ((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_addr.s_addr;
                    r = 0;
                    address = [NSString stringWithFormat:@"%s", inet_ntoa(*((struct in_addr*)&addr))];
                    NSLog(@"\naddress%@",address);
                    break;
                }
            }
        }
        free(buf);
    }
#endif
    return address;
}

- (NSArray *)ht_getLocalDNSAddress
{
    NSMutableArray *addresses = [NSMutableArray array];

    struct __res_state res ;
    res.options &= ~ RES_INIT;

    int result = res_ninit(&res);

    if ( result == 0 )
    {
        for ( int i = 0; i < res.nscount; i++ )
        {
            NSString *s = [NSString stringWithUTF8String :  inet_ntoa(res.nsaddr_list[i].sin_addr)];
            [addresses addObject:s];
            NSLog(@"%@",s);
        }
    }

    res_nclose(&res);

    return addresses;
}

- (BOOL)ht_isUIUserInterfaceIdiomPad
{
//    if (kSupportUniversal) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            return YES;
        }
//    }
    return NO;
}

//根据设备的能力（内存）返回不同分辨率
+ (NSUInteger)ht_assetMaxDimension
{
    unsigned long long totalMemory = [[NSProcessInfo processInfo] physicalMemory];
    unsigned long long baseMemory = 500*1000*1000; //500M -> 300万像素
    CGFloat factor = (CGFloat)totalMemory/(CGFloat)baseMemory;

    if (factor < 1) { //不设上限
        factor = 1;
    }

    return 300 * 10000 * factor;
}

#pragma mark - 判断设备锁屏
- (void)ht_markAsLocked
{
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive)
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kDeviceLockStatusLockedWhileRunning"];
    }
    else
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"kDeviceLockStatusLocked"];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)ht_markAsUnLocked
{
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kDeviceLockStatusLocked"];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"kDeviceLockStatusLockedWhileRunning"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (BOOL)ht_isLocked
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kDeviceLockStatusLocked"];
}

- (BOOL)ht_isLockedWhileRunning
{
    return [[NSUserDefaults standardUserDefaults] boolForKey:@"kDeviceLockStatusLockedWhileRunning"];
}

+ (BOOL) ht_isJailbroken
{
    for (int i = 0; i < ARRAY_SIZE(jailbreak_tool_pathes); i++) {
        if ([[NSFileManager defaultManager] fileExistsAtPath:[NSString stringWithUTF8String:jailbreak_tool_pathes[i]]]) {
            return YES;
        }
    }
    return NO;
}

+ (NSString*) ht_currentCPUArch
{
    return [NSString stringWithUTF8String:ht_w_mach_currentCPUArch()];
}

+ (NSDate*) ht_dateSysctl:(NSString*) name
{
    NSDate* result = nil;

    struct timeval value = ht_w_sysctl_timevalForName([name cStringUsingEncoding:NSUTF8StringEncoding]);
    if(!(value.tv_sec == 0 && value.tv_usec == 0))
    {
        result = [NSDate dateWithTimeIntervalSince1970:(NSTimeInterval)value.tv_sec];
    }

    return result;
}

+ (NSString *)ht_appUUIDWithAppPath:(NSString *)path
{
    if(!path)
    {
        return nil;
    }

    const uint8_t *uuidBytes = ht_w_mach_imageUUID([path UTF8String], true);
    CFUUIDRef uuidRef = CFUUIDCreateFromUUIDBytes(NULL, *((CFUUIDBytes*)uuidBytes));
    NSString* str = (NSString*)CFBridgingRelease(CFUUIDCreateString(NULL, uuidRef));
    CFRelease(uuidRef);
    return str;
}

+ (NSString *)ht_appAddressWithAppPath:(NSString *)path
{
    if (!path)
    {
        return nil;
    }

    const uintptr_t address = ht_w_mach_imageAddress([path UTF8String], true);

    return [NSString stringWithFormat:@"0x%08llX",(long long)address];
}

- (double)ht_appCPUUsage
{
    thread_array_t         threads;
    mach_msg_type_number_t threadCount;
    if (task_threads(mach_task_self(), &threads, &threadCount) != KERN_SUCCESS) {
        return -1;
    }
    double usage = 0;
    for (int i = 0; i < threadCount; i++) {
        thread_info_data_t     threadInfo;
        mach_msg_type_number_t threadInfoCount = THREAD_INFO_MAX;
        if (thread_info(threads[i], THREAD_BASIC_INFO, (thread_info_t) threadInfo, &threadInfoCount) != KERN_SUCCESS) {
            usage = -1;
            break;
        }
        thread_basic_info_t info = (thread_basic_info_t)threadInfo;
        if ((info->flags & TH_FLAGS_IDLE) == 0) {
            usage += (double)(info->cpu_usage) / TH_USAGE_SCALE;
        }
    }
    vm_deallocate(mach_task_self(), (vm_offset_t) threads, threadCount * sizeof(thread_t));
    return usage;
}

- (CGFloat)ht_deviceCPUUsage {
    kern_return_t kr;
    mach_msg_type_number_t count;
    static host_cpu_load_info_data_t previous_info = {0, 0, 0, 0};
    host_cpu_load_info_data_t info;

    count = HOST_CPU_LOAD_INFO_COUNT;

    kr = host_statistics(mach_host_self(), HOST_CPU_LOAD_INFO, (host_info_t)&info, &count);
    if (kr != KERN_SUCCESS) {
        return -1;
    }

    natural_t user   = info.cpu_ticks[CPU_STATE_USER] - previous_info.cpu_ticks[CPU_STATE_USER];
    natural_t nice   = info.cpu_ticks[CPU_STATE_NICE] - previous_info.cpu_ticks[CPU_STATE_NICE];
    natural_t system = info.cpu_ticks[CPU_STATE_SYSTEM] - previous_info.cpu_ticks[CPU_STATE_SYSTEM];
    natural_t idle   = info.cpu_ticks[CPU_STATE_IDLE] - previous_info.cpu_ticks[CPU_STATE_IDLE];
    natural_t total  = user + nice + system + idle;
    previous_info    = info;

    return (user + nice + system) * 100.0 / total;
}

- (int)ht_threadCount
{
    thread_array_t         threads;
    mach_msg_type_number_t threadCount;
    if (task_threads(mach_task_self(), &threads, &threadCount) != KERN_SUCCESS) {
        return -1;
    }

    return threadCount;
}

- (NSDictionary *)ht_runningThreadCount
{
    thread_array_t         threads;
    mach_msg_type_number_t threadCount;
    // 正在running状态的线程数
    mach_msg_type_number_t runningThreadCount = 0;
    if (task_threads(mach_task_self(), &threads, &threadCount) != KERN_SUCCESS) {
        return @{};
    }

    for (int i = 0; i < threadCount; i++) {
        thread_info_data_t     threadInfo;
        mach_msg_type_number_t threadInfoCount = THREAD_INFO_MAX;
        if (thread_info(threads[i], THREAD_BASIC_INFO, (thread_info_t) threadInfo, &threadInfoCount) != KERN_SUCCESS) {
            continue;
        }
        thread_basic_info_t info = (thread_basic_info_t)threadInfo;
        if (info->run_state == TH_STATE_RUNNING) {
            runningThreadCount += 1;
        }
    }
    NSMutableDictionary *threadCountInfo = [[NSMutableDictionary alloc] init];
    [threadCountInfo ht_setSafeObject:@(threadCount) forKey:@"threadCount"];
    [threadCountInfo ht_setSafeObject:@(runningThreadCount) forKey:@"runningThreadCount"];
    return threadCountInfo;
}

+ (CGFloat)ht_diskOfAllSize
{
    uint64_t totalSpace = 0;
//    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];

    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
//        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
//        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
//        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }

    return (totalSpace/1024ll)/1024ll;
}

+(CGFloat)ht_diskOfFreeSize
{
//    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];

    if (dictionary) {
//        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
//        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
//        NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }

    return (totalFreeSpace/1024ll)/1024ll;
}

/*!
 * 获取设备特征字符串
 */
+ (NSString*)ht_getDevicePortrait {

    static NSString* device_portrait_info = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{


        NSString* model = [[self class] ht_platform];
        if (nil == model)
            model = @"<unknown_model>";


        NSString* totalSizeString = nil;
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        if (nil != paths  &&  0 != [paths count]) {

            NSDictionary *dict = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: nil];
            if (nil != dict)
            {
                NSNumber* totalSize = [dict objectForKey:NSFileSystemSize];
                if (nil != totalSize)
                    totalSizeString = [NSString stringWithFormat:@"%@", totalSize];
            }

        }

        if (nil == totalSizeString)
            totalSizeString = @"<unknown_size>";


        device_portrait_info = [NSString stringWithFormat:@"%@-%@", model, totalSizeString];

    });


    return device_portrait_info;

}

- (NSString *)ht_aid
{
    id aidCache = [[NSUserDefaults standardUserDefaults] stringForKey:@"HeTaoSDKAID"];
    if (aidCache) {
        return aidCache;
    }else{
        id aidKeyChainCache = [HTTDSFHFKeychainUtils getPasswordForUsername:KHTAidKeychainUserName
                                                             andServiceName:KHTAidKeychainServiceKey
                                                                      error:nil];
        if (aidKeyChainCache) {
            [[NSUserDefaults standardUserDefaults] setObject:aidKeyChainCache forKey:@"HeTaoSDKAID"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            return aidKeyChainCache;
        }else
        {
            return nil;
        }
    }
}

- (NSArray *)ht_mfp1
{
    NSMutableDictionary* mfpDict = [NSMutableDictionary dictionary];

    UIDevice* currentDevice = [UIDevice currentDevice];

    //1 os
    NSString* os = [NSString stringWithFormat:@"%@,%@", [currentDevice systemName], [currentDevice systemVersion]];
    if (os) {
        [mfpDict setObject:os forKey:@"1"];
    }

    NSString* udid = [self openUniqueIdentifier];
    if (udid) {
        [mfpDict setObject:udid forKey:@"8"];
    }

    NSUUID* adId = [[ASIdentifierManager sharedManager] advertisingIdentifier];
    NSString* udid_string = [adId UUIDString];
    if (udid_string) {
        [mfpDict setObject:udid_string forKey:@"11"];
    }

    //12 idfv
    NSString* idfv = [[currentDevice identifierForVendor] UUIDString];
    if (idfv) {
        [mfpDict setObject:idfv forKey:@"12"];
    }


    //14 Model
    NSString* modelName = [currentDevice model];
    if (modelName) {
        [mfpDict setObject:modelName forKey:@"14"];
    }

    //16 Resolution
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    NSString* resolution = [NSString stringWithFormat:@"%d*%d", (int)screenBounds.size.width, (int)screenBounds.size.height];
    if (resolution) {
        [mfpDict setObject:resolution forKey:@"16"];
    }

    NSString *ssid = [UIDevice ht_getDeviceSSID];
    if (ssid) {
        [mfpDict setObject:ssid forKey:@"17"];
    }

    //18 DeviceName
    NSString* deviceName = [currentDevice name];
    if (deviceName) {
        [mfpDict setObject:deviceName forKey:@"18"];
    }

    //19 ConnectType
    HTTDNetworkStatus hostReachStatus = [[HTTDReachability sharedReachability] currentReachabilityStatus];
    if (hostReachStatus== HTTDReachableViaWiFi) {
        [mfpDict setObject:@"wifi" forKey:@"19"];
    }else{
        [mfpDict setObject:@"mobile" forKey:@"19"];
    }

    NSString *uaString = [self ua];
    if (uaString) {
        [mfpDict setObject:[uaString ht_urlEncode] forKey:@"20"];
    }

    [mfpDict setObject:@"Apple" forKey:@"22"];

    NSString *newUUID = [self plainDeviceID];
    if (newUUID) {
        [mfpDict setObject:newUUID forKey:@"31"];
    }

    NSString *bssid = [UIDevice ht_getDeviceBSSID];
    if (bssid) {
        [mfpDict setObject:bssid forKey:@"51"];
    }

    NSString* jsonString = [mfpDict ht_toJSONStringWithSortedKeyAsc];

    HTRSABase *rsa = [[HTRSABase alloc] initWithPubKeyFilePath:[[NSBundle mainBundle] pathForResource:@"mfp" ofType:@"cer"]];
    NSString* encryptedString = [rsa encrypt:jsonString];

    return @[[NSString stringWithFormat:@"01%@", encryptedString],jsonString];

}

- (NSString*)ht_mfp
{
    NSMutableDictionary* mfpDict = [NSMutableDictionary dictionary];

    UIDevice* currentDevice = [UIDevice currentDevice];

    //1 os
    NSString* os = [NSString stringWithFormat:@"%@,%@", [currentDevice systemName], [currentDevice systemVersion]];
    if (os) {
        [mfpDict setObject:os forKey:@"1"];
    }

    NSString* udid = [self openUniqueIdentifier];
    if (udid) {
        [mfpDict setObject:udid forKey:@"8"];
    }

    NSUUID* adId = [[ASIdentifierManager sharedManager] advertisingIdentifier];
    NSString* udid_string = [adId UUIDString];
    if (udid_string) {
        [mfpDict setObject:udid_string forKey:@"11"];
    }

    //12 idfv
    NSString* idfv = [[currentDevice identifierForVendor] UUIDString];
    if (idfv) {
        [mfpDict setObject:idfv forKey:@"12"];
    }


    //14 Model
    NSString* modelName = [currentDevice model];
    if (modelName) {
        [mfpDict setObject:modelName forKey:@"14"];
    }

    //16 Resolution
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    NSString* resolution = [NSString stringWithFormat:@"%d*%d", (int)screenBounds.size.width, (int)screenBounds.size.height];
    if (resolution) {
        [mfpDict setObject:resolution forKey:@"16"];
    }

    NSString *ssid = [UIDevice ht_getDeviceSSID];
    if (ssid) {
        [mfpDict setObject:ssid forKey:@"17"];
    }

    //18 DeviceName
    NSString* deviceName = [currentDevice name];
    if (deviceName) {
        [mfpDict setObject:deviceName forKey:@"18"];
    }

    //19 ConnectType
    HTTDNetworkStatus hostReachStatus = [[HTTDReachability sharedReachability] currentReachabilityStatus];
    if (hostReachStatus== HTTDReachableViaWiFi) {
        [mfpDict setObject:@"wifi" forKey:@"19"];
    }else{
        [mfpDict setObject:@"mobile" forKey:@"19"];
    }

    NSString *uaString = [self ua];
    if (uaString) {
        [mfpDict setObject:[uaString ht_urlEncode] forKey:@"20"];
    }

    [mfpDict setObject:@"Apple" forKey:@"22"];

    NSString *newUUID = [self plainDeviceID];
    if (newUUID) {
        [mfpDict setObject:newUUID forKey:@"31"];
    }

    NSString *bssid = [UIDevice ht_getDeviceBSSID];
    if (bssid) {
        [mfpDict setObject:bssid forKey:@"51"];
    }

    NSString* jsonString = [mfpDict ht_toJSONStringWithSortedKeyAsc];

    HTRSABase *rsa = [[HTRSABase alloc] initWithPubKeyFilePath:[[NSBundle mainBundle] pathForResource:@"mfp" ofType:@"cer"]];
    NSString* encryptedString = [rsa encrypt:jsonString];

    return [NSString stringWithFormat:@"01%@", encryptedString];

}

+ (NSString *)wm
{
    static NSString *wm = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        wm = [[NSUserDefaults standardUserDefaults] htl_stringForKey:@"kKeyAppWmForHeTao"];
        if (!wm)
        {
            wm = kKeyAppWmForHeTao;
            [[NSUserDefaults standardUserDefaults] setObject:wm forKey:@"kKeyAppWmForHeTao"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }

    });

    return wm;
}

- (NSString *)createKeyAppUA
{
    NSString *uaString = @"HeTao";
    NSString *version = [HTAppInfo sharedInfo].bundleVersion;
    if (version) {
        uaString = [uaString stringByAppendingFormat:@"__%@",version];
    }
    uaString = [uaString stringByAppendingString:@"__iphone"];
    return uaString;
}

- (NSString *)ua
{
    NSString* plat = [[NSUserDefaults standardUserDefaults] htl_stringForKey:@"machinePlatForm"];
    if (plat == nil || [plat ht_isEmptyOrWhitespace])
    {
        plat = [UIDevice ht_getStandardPlat];
        plat = [NSString stringWithFormat:@"%@__%@__os%@",plat,[self createKeyAppUA],[UIDevice currentDevice].systemVersion];

        [[NSUserDefaults standardUserDefaults] setObject:plat forKey:@"machinePlatForm"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    return plat;
}

+ (NSString *)ht_getDeviceBSSID {
    NSString *bssid = @"";

    NSArray *array = CFBridgingRelease(CNCopySupportedInterfaces());
    if (array) {
        for (NSString *s in array) {
            NSDictionary *dict = CFBridgingRelease(CNCopyCurrentNetworkInfo((__bridge CFStringRef)s));
            if (dict) {
                bssid = dict[@"BSSID"] ? dict[@"BSSID"] : @"";
                break;
            }
        }
    }

    return bssid;
}

// 返回明文的 deviceid
- (NSString *)plainDeviceID
{
    return [HTGetDeviceIdSDK getUniqueStrByUUID];
}

+ (NSString *)ht_getDeviceSSID
{
    NSArray *ifs = (__bridge_transfer id)CNCopySupportedInterfaces();

    id info = nil;
    for (NSString *ifnam in ifs) {
        info = (__bridge_transfer id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam);
        if (info && [info count]) {
            break;
        }
    }
    NSDictionary *dctySSID = (NSDictionary *)info;
    NSString *ssid = [[dctySSID objectForKey:@"SSID"] lowercaseString];

    return ssid;

}

//将功能移至SFHFKeychainUtils第三方类库
- (NSString *)openUniqueIdentifier
{
    // 先读keychain里面的值，如果没有则读取openUDID
    static NSString *udid = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{

        udid = [HTTDSFHFKeychainUtils getPasswordForUsername:kKeyChainUDID
                                              andServiceName:kKeyChainAuthService
                                                       error:nil];
        if (!udid)
        {
            udid = [HTOpenUDID value];
        }


        // 将UDID存储到keychain中
        [HTTDSFHFKeychainUtils storeUsername:kKeyChainUDID
                                 andPassword:udid
                              forServiceName:kKeyChainAuthService
                              updateExisting:YES
                                       error:nil];
    });
    return udid;
}




@end




//inline CGRect HTConvertCGRectForDeviceScale(CGRect rect)
//{
//    if (ABS(HTKeyWindowPortraitWidth - 320) < 0.1) {
//        return rect;
//    }
//
//    CGFloat xScale = HTKeyWindowPortraitWidth / 320.0;
//    CGFloat yScale = HTKeyWindowPortraitHeight / 568;
//
//    return CGRectMake(rect.origin.x * xScale, rect.origin.y * yScale, rect.size.width * xScale, rect.size.height*yScale);
//}
//
//inline CGFloat HTConvertHeightForDeviceScale(CGFloat height)
//{
//    if (ABS(HTKeyWindowPortraitWidth - 320) < 0.1) {
//        return height;
//    }
//    CGFloat yScale = HTKeyWindowPortraitHeight / 568;
//    return height * yScale;
//}
//
//inline CGFloat HTConvertWidthForDeviceScale(CGFloat width)
//{
//    if (ABS(HTKeyWindowPortraitWidth - 320) < 0.1) {
//        return width;
//    }
//    CGFloat xScale = HTKeyWindowPortraitWidth / 320.0;
//
//    return xScale * width;
//}
//
//inline  CGFloat HTConvertEdgeForGivenScale(CGFloat width, CGFloat scale)
//{
//    if (ABS(HTKeyWindowPortraitWidth - 320) < 0.1) {
//        return width;
//    }
//
//    return scale * width;
//
//}

typedef NS_ENUM(NSInteger, _HTScaleFactorDevice) {
    _HTScaleFactorDeviceIPhone5 = -1,
    _HTScaleFactorDeviceIPhone6 = 0,
    _HTScaleFactorDeviceIPhone6P = 1,
    _HTScaleFactorDeviceIPad = 2,
};

double _HTScaleDoubleWithOptions(double value, HTScaleOptions options)
{
    static _HTScaleFactorDevice factorDevice = _HTScaleFactorDeviceIPhone5;
    static dispatch_once_t onceToken1;
    dispatch_once(&onceToken1, ^{
        CGSize screenSize = [UIScreen mainScreen].bounds.size;
        double screenWidth = MIN(screenSize.width, screenSize.height);
        if (screenWidth <= 320) {
            factorDevice = _HTScaleFactorDeviceIPhone5;
        } else if (screenWidth <= 375) {
            factorDevice = _HTScaleFactorDeviceIPhone6;
        } else if (screenWidth <= 414) {
            factorDevice = _HTScaleFactorDeviceIPhone6P;
        } else {
            factorDevice = _HTScaleFactorDeviceIPad;
        }
    });

    if (factorDevice == _HTScaleFactorDeviceIPhone5) {
        return value;
    }

    if (options.iphone6 > 1e-6 && factorDevice == _HTScaleFactorDeviceIPhone6) {
        return options.iphone6;
    }

    if (options.iphone6p > 1e-6 && factorDevice == _HTScaleFactorDeviceIPhone6P) {
        return options.iphone6p;
    }

    if (options.ipad > 1e-6 && factorDevice == _HTScaleFactorDeviceIPad) {
        return options.ipad;
    }

    HTScaleFactor factor = HTScaleFactorDefault;
    if (options.factor != HTScaleFactorUseDefault) {
        factor = options.factor;
    }

    static NSDictionary * factorMap = nil;
    static dispatch_once_t onceToken2;
    dispatch_once(&onceToken2, ^{
        factorMap = @{@(HTScaleFactor_106_115_125): @[@1.06, @1.15, @1.25],
                      @(HTScaleFactor_100_106_125): @[@1.00, @1.06, @1.25]};
    });

    double factorValue = 1;
    NSArray * factorArray = factorMap[@(factor)];
    if (factorArray) {
        factorValue = [factorArray[factorDevice] doubleValue];
    }

    return round(value * factorValue);
}
