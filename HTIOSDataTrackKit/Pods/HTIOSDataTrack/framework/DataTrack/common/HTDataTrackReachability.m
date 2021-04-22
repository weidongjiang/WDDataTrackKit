//
//  HTDataTrackReachability.m
//  HTIOSDataTrackKit
//
//  Created by 伟东 on 2020/8/21.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "HTDataTrackReachability.h"
#import <sys/socket.h>
#import <netinet/in.h>
#import <netinet6/in6.h>
#import <arpa/inet.h>
#import <ifaddrs.h>
#import <netdb.h>
#import <CoreFoundation/CoreFoundation.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>

#define kShouldPrintReachabilityFlags 0

NSString * const HTReachabilityChangedNotification = @"HTReachabilityChangedNotification";

static void HTPrintReachabilityFlags(SCNetworkReachabilityFlags    flags, const char* comment)
{
#if kShouldPrintReachabilityFlags
    NSLog(@"Reachability Flag Status: %c%c %c%c%c%c%c%c%c %s\n",
          (flags & kSCNetworkReachabilityFlagsIsWWAN)                  ? 'W' : '-',
          (flags & kSCNetworkReachabilityFlagsReachable)            ? 'R' : '-',
          
          (flags & kSCNetworkReachabilityFlagsTransientConnection)  ? 't' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionRequired)   ? 'c' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic)  ? 'C' : '-',
          (flags & kSCNetworkReachabilityFlagsInterventionRequired) ? 'i' : '-',
          (flags & kSCNetworkReachabilityFlagsConnectionOnDemand)   ? 'D' : '-',
          (flags & kSCNetworkReachabilityFlagsIsLocalAddress)       ? 'l' : '-',
          (flags & kSCNetworkReachabilityFlagsIsDirect)             ? 'd' : '-',
          comment
          );
#endif
}

static void HTReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
#pragma unused (target, flags)
    NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
//    NSCAssert([(NSObject*)info isKindOfClass: [HTDataTrackReachability class]], @"info was wrong class in ReachabilityCallback");
    
    //We're on the main RunLoop, so an NSAutoreleasePool is not necessary, but is added defensively
    // in case someon uses the Reachablity object in a different thread.
    NSAutoreleasePool* myPool = [[NSAutoreleasePool alloc] init];
    
    HTDataTrackReachability* noteObject = (__bridge HTDataTrackReachability*) info;
    // Post a notification to notify the client that the network reachability changed.
    [[NSNotificationCenter defaultCenter] postNotificationName: HTReachabilityChangedNotification object: noteObject];
    
    [myPool release];
}

@interface HTDataTrackReachability ()
{
    BOOL localWiFiRef;
    SCNetworkReachabilityRef reachabilityRef;
    CTTelephonyNetworkInfo *_telephonyNetworkInfo;
}

@end


@implementation HTDataTrackReachability
+ (instancetype)shareInstance {
    static dispatch_once_t onceToken;
    static HTDataTrackReachability *_instance = nil;
    dispatch_once(&onceToken, ^{
        _instance = [[HTDataTrackReachability alloc] init];
    });
    return _instance;
}

- (instancetype)init {
    if (self = [super init]) {
        [self p_fire];
    }
    return self;
}
- (void)dealloc {
    [_telephonyNetworkInfo release];
    _telephonyNetworkInfo = nil;
    [self stopNotifier];
    if(reachabilityRef!= NULL)
    {
        CFRelease(reachabilityRef);
    }
    [super dealloc];
}

- (void)p_fire {
    _telephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
    [self reachabilityForInternetConnection];
    
}

- (void)reachabilityForInternetConnection;
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    [self reachabilityWithAddress:(const struct sockaddr *)&zeroAddress];
}

- (void)reachabilityWithAddress:(const struct sockaddr *) hostAddress;
{
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)hostAddress);
    if(reachability!= NULL)
    {
        self->reachabilityRef = reachability;
        self->localWiFiRef = NO;
    }
}

- (BOOL)startNotifier {
    BOOL retVal = NO;
    SCNetworkReachabilityContext    context = {0, (__bridge void * _Nullable)(self), NULL, NULL, NULL};
    if(SCNetworkReachabilitySetCallback(reachabilityRef, HTReachabilityCallback, &context))
    {
        if(SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
        {
            retVal = YES;
        }
    }
    return retVal;
}

- (void)stopNotifier {
    if(reachabilityRef!= NULL)
    {
        SCNetworkReachabilityUnscheduleFromRunLoop(reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
    }
}

- (void)reachabilityWithHostName: (NSString*) hostName;
{
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithName(NULL, [hostName UTF8String]);
    if(reachability!= NULL)
    {
        self->reachabilityRef = reachability;
        self->localWiFiRef = NO;
    }
}

- (void)reachabilityForLocalWiFi;
{
    struct sockaddr_in localWifiAddress;
    bzero(&localWifiAddress, sizeof(localWifiAddress));
    localWifiAddress.sin_len = sizeof(localWifiAddress);
    localWifiAddress.sin_family = AF_INET;
    // IN_LINKLOCALNETNUM is defined in <netinet/in.h> as 169.254.0.0
    localWifiAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
    [self reachabilityWithAddress: (const struct sockaddr *)&localWifiAddress];
    self->localWiFiRef = YES;
    
}


- (HTNetworkStatus)localWiFiStatusForFlags: (SCNetworkReachabilityFlags) flags
{
    HTPrintReachabilityFlags(flags, "localWiFiStatusForFlags");
    
    HTNetworkStatus retVal = HTNotReachable;
    if((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsDirect))
    {
        retVal = HTReachableViaWiFi;
    }
    return retVal;
}

- (HTNetworkStatus)networkStatusForFlags: (SCNetworkReachabilityFlags) flags
{
    HTPrintReachabilityFlags(flags, "networkStatusForFlags");
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
    {
        // if target host is not reachable
        return HTNotReachable;
    }
    
    HTNetworkStatus retVal = HTNotReachable;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        // if target host is reachable and no connection is required
        //  then we'll assume (for now) that your on Wi-Fi
        retVal = HTReachableViaWiFi;
    }
    
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
        // ... and the connection is on-demand (or on-traffic) if the
        //     calling application is using the CFSocketStream or higher APIs
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            // ... and no [user] intervention is needed
            retVal = HTReachableViaWiFi;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        // ... but WWAN connections are OK if the calling application
        //     is using the CFNetwork (CFSocketStream?) APIs.
        retVal = HTReachableViaWWAN;
    }
    return retVal;
}

- (BOOL)connectionRequired;
{
    NSAssert(reachabilityRef != NULL, @"connectionRequired called with NULL reachabilityRef");
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags))
    {
        return (flags & kSCNetworkReachabilityFlagsConnectionRequired);
    }
    return NO;
}

- (HTNetworkStatus)currentReachabilityStatus
{
    NSAssert(reachabilityRef != NULL, @"currentNetworkStatus called with NULL reachabilityRef");
    HTNetworkStatus retVal = HTNotReachable;
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags))
    {
        retVal = [self networkStatusForFlags: flags];
    }
    return retVal;
}

- (HTNetworkDetailStatus)currentDetailReachabilityStatus
{
    HTNetworkDetailStatus status = (HTNetworkDetailStatus)[self currentReachabilityStatus];
    NSString *accessTechnology = _telephonyNetworkInfo.currentRadioAccessTechnology;
    if (status == HTReachableViaWWAN &&  accessTechnology != nil) {
        if ([accessTechnology isEqualToString:CTRadioAccessTechnologyEdge] ||
            [accessTechnology isEqualToString:CTRadioAccessTechnologyGPRS])
            status = HTNetworkDetailStatus2G;
        else if ([accessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA] ||    //3.5G
                 [accessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA] ||    //3G
                 [accessTechnology isEqualToString:CTRadioAccessTechnologyHSUPA] ||
                 [accessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x] ||
                 [accessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] ||
                 [accessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] ||
                 [accessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] ||
                 [accessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD])  //3.75G
            status = HTNetworkDetailStatus3G;
        else if ([accessTechnology isEqualToString:CTRadioAccessTechnologyLTE])    //3.9G
            status = HTNetworkDetailStatus4G;
    }
    return status;
}

/** Unreachable、WiFi、WWAN、2G、3G、4G、Unknow */
- (NSString *)currentDetailNetString {
    HTNetworkDetailStatus status = [[HTDataTrackReachability shareInstance] currentDetailReachabilityStatus];
    NSString *netStatusStr = @"";

    switch (status) {
        case HTNotReachable:
            netStatusStr = @"Unreachable";
            break;
            
        case HTReachableViaWiFi:
            netStatusStr = @"WiFi";
            break;
            
        case HTReachableViaWWAN:
            netStatusStr = @"WWAN";
            break;
            
        case HTNetworkDetailStatus2G:
            netStatusStr = @"2G";
            break;
            
        case HTNetworkDetailStatus3G:
            netStatusStr = @"3G";
            break;
            
        case HTNetworkDetailStatus4G:
            netStatusStr = @"4G";
            break;
            
        default:
            netStatusStr = @"Unknow";
            break;
    }
    
    return netStatusStr;
}

- (HTMobileISPType)currentMoblieISPType
{
    CTCarrier *carrier = _telephonyNetworkInfo.subscriberCellularProvider;
    NSInteger mcc = [carrier.mobileCountryCode integerValue];
    NSInteger mnc = [carrier.mobileNetworkCode integerValue];
    
    HTMobileISPType isp = HTMobileISPTypeUnknown;
    
    if (mcc == 460) {
        switch (mnc) {
            case 0:
            case 2:
            case 7:
            case 8:
            {
                isp = HTMobileISPTypeChinaMobile;
            }
                break;
            case 1:
            case 6:
            case 9:
            {
                isp = HTMobileISPTypeChinaUnicom;
            }
                break;
            case 3:
            case 5:
            case 11:
            {
                isp = HTMobileISPTypeChinaTelecom;
            }
                break;
            case 20:
            {
                isp = HTMobileISPTypeChinaTietong;
            }
                break;
            default:
                break;
        }
    }
    return isp;
}

@end
