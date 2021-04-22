//
//  HTTDReachability.m
//  HTIOSFoundationToolKit
//
//  Created by 伟东 on 2020/7/22.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "HTTDReachability.h"
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

NSString * const HTTDReachabilityChangedNotification = @"HTTDReachabilityChangedNotification";

static void HTTDPrintReachabilityFlags(SCNetworkReachabilityFlags    flags, const char* comment)
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

static void HTTDReachabilityCallback(SCNetworkReachabilityRef target, SCNetworkReachabilityFlags flags, void* info)
{
#pragma unused (target, flags)
    NSCAssert(info != NULL, @"info was NULL in ReachabilityCallback");
    NSCAssert([(NSObject*) info isKindOfClass: [HTTDReachability class]], @"info was wrong class in ReachabilityCallback");
    
    //We're on the main RunLoop, so an NSAutoreleasePool is not necessary, but is added defensively
    // in case someon uses the Reachablity object in a different thread.
    NSAutoreleasePool* myPool = [[NSAutoreleasePool alloc] init];
    
    HTTDReachability* noteObject = (HTTDReachability*) info;
    // Post a notification to notify the client that the network reachability changed.
    [[NSNotificationCenter defaultCenter] postNotificationName: HTTDReachabilityChangedNotification object: noteObject];
    
    [myPool release];
}

@interface HTTDReachability ()
{
    BOOL localWiFiRef;
    SCNetworkReachabilityRef reachabilityRef;
    CTTelephonyNetworkInfo *_telephonyNetworkInfo;
}

//reachabilityWithHostName- Use to check the reachability of a particular host name.
- (void)reachabilityWithHostName: (NSString*) hostName;

//reachabilityWithAddress- Use to check the reachability of a particular IP address.
- (void)reachabilityWithAddress: (const struct sockaddr *) hostAddress;

//reachabilityForInternetConnection- checks whether the default route is available.
//  Should be used by applications that do not connect to a particular host
- (void)reachabilityForInternetConnection;

//reachabilityForLocalWiFi- checks whether a local wifi connection is available.
- (void)reachabilityForLocalWiFi;

//Start listening for reachability notifications on the current run loop
- (BOOL)startNotifier;
- (void)stopNotifier;

//WWAN may be available, but not active until a connection has been established.
//WiFi may require a connection for VPN on Demand.
- (BOOL)connectionRequired;

@end


@implementation HTTDReachability

+ (instancetype)sharedReachability
{
    static HTTDReachability *sharedReachability = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedReachability = [HTTDReachability new];
    });
    return sharedReachability;
}

- (instancetype)init
{
    if (self = [super init]) {
        [self p_fire];
    }
    return self;
}

- (void)p_fire
{
    _telephonyNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
    [self reachabilityForInternetConnection];
    [self startNotifier];
}

- (void)dealloc
{
    [_telephonyNetworkInfo release]; _telephonyNetworkInfo = nil;
    [self stopNotifier];
    if(reachabilityRef!= NULL)
    {
        CFRelease(reachabilityRef);
    }
    [super dealloc];
}


- (BOOL)startNotifier
{
    BOOL retVal = NO;
    SCNetworkReachabilityContext    context = {0, self, NULL, NULL, NULL};
    if(SCNetworkReachabilitySetCallback(reachabilityRef, HTTDReachabilityCallback, &context))
    {
        if(SCNetworkReachabilityScheduleWithRunLoop(reachabilityRef, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode))
        {
            retVal = YES;
        }
    }
    return retVal;
}

- (void)stopNotifier
{
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

- (void)reachabilityWithAddress: (const struct sockaddr *) hostAddress;
{
    SCNetworkReachabilityRef reachability = SCNetworkReachabilityCreateWithAddress(kCFAllocatorDefault, (const struct sockaddr*)hostAddress);
    if(reachability!= NULL)
    {
        self->reachabilityRef = reachability;
        self->localWiFiRef = NO;
    }
}

- (void)reachabilityForInternetConnection;
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    [self reachabilityWithAddress: (const struct sockaddr *)&zeroAddress];
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


- (HTTDNetworkStatus)localWiFiStatusForFlags: (SCNetworkReachabilityFlags) flags
{
    HTTDPrintReachabilityFlags(flags, "localWiFiStatusForFlags");
    
    HTTDNetworkStatus retVal = HTTDNotReachable;
    if((flags & kSCNetworkReachabilityFlagsReachable) && (flags & kSCNetworkReachabilityFlagsIsDirect))
    {
        retVal = HTTDReachableViaWiFi;
    }
    return retVal;
}

- (HTTDNetworkStatus)networkStatusForFlags: (SCNetworkReachabilityFlags) flags
{
    HTTDPrintReachabilityFlags(flags, "networkStatusForFlags");
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
    {
        // if target host is not reachable
        return HTTDNotReachable;
    }
    
    HTTDNetworkStatus retVal = HTTDNotReachable;
    
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        // if target host is reachable and no connection is required
        //  then we'll assume (for now) that your on Wi-Fi
        retVal = HTTDReachableViaWiFi;
    }
    
    
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
    {
        // ... and the connection is on-demand (or on-traffic) if the
        //     calling application is using the CFSocketStream or higher APIs
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            // ... and no [user] intervention is needed
            retVal = HTTDReachableViaWiFi;
        }
    }
    
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
    {
        // ... but WWAN connections are OK if the calling application
        //     is using the CFNetwork (CFSocketStream?) APIs.
        retVal = HTTDReachableViaWWAN;
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

- (HTTDNetworkStatus)currentReachabilityStatus
{
    NSAssert(reachabilityRef != NULL, @"currentNetworkStatus called with NULL reachabilityRef");
    HTTDNetworkStatus retVal = HTTDNotReachable;
    SCNetworkReachabilityFlags flags;
    if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags))
    {
        retVal = [self networkStatusForFlags: flags];
    }
    return retVal;
}

- (HTTDNetworkDetailStatus)currentDetailReachabilityStatus
{
    HTTDNetworkDetailStatus status = (HTTDNetworkDetailStatus)[self currentReachabilityStatus];
    NSString *accessTechnology = _telephonyNetworkInfo.currentRadioAccessTechnology;
    if (status == HTTDReachableViaWWAN &&  accessTechnology != nil) {
        if ([accessTechnology isEqualToString:CTRadioAccessTechnologyEdge] ||
            [accessTechnology isEqualToString:CTRadioAccessTechnologyGPRS])
            status = HTTDNetworkDetailStatus2G;
        else if ([accessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA] ||    //3.5G
                 [accessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA] ||    //3G
                 [accessTechnology isEqualToString:CTRadioAccessTechnologyHSUPA] ||
                 [accessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x] ||
                 [accessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] ||
                 [accessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] ||
                 [accessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] ||
                 [accessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD])  //3.75G
            status = HTTDNetworkDetailStatus3G;
        else if ([accessTechnology isEqualToString:CTRadioAccessTechnologyLTE])    //3.9G
            status = HTTDNetworkDetailStatus4G;
    }
    return status;
}

/** Unreachable、WiFi、WWAN、2G、3G、4G、Unknow */
- (NSString *)currentDetailNetString {
    HTTDNetworkDetailStatus status = [[HTTDReachability sharedReachability] currentDetailReachabilityStatus];
    NSString *netStatusStr = @"";

    switch (status) {
        case HTTDNotReachable:
            netStatusStr = @"Unreachable";
            break;
            
        case HTTDReachableViaWiFi:
            netStatusStr = @"WiFi";
            break;
            
        case HTTDReachableViaWWAN:
            netStatusStr = @"WWAN";
            break;
            
        case HTTDNetworkDetailStatus2G:
            netStatusStr = @"2G";
            break;
            
        case HTTDNetworkDetailStatus3G:
            netStatusStr = @"3G";
            break;
            
        case HTTDNetworkDetailStatus4G:
            netStatusStr = @"4G";
            break;
            
        default:
            netStatusStr = @"Unknow";
            break;
    }
    
    return netStatusStr;
}

- (HTTDMobileISPType)currentMoblieISPType
{
    CTCarrier *carrier = _telephonyNetworkInfo.subscriberCellularProvider;
    NSInteger mcc = [carrier.mobileCountryCode integerValue];
    NSInteger mnc = [carrier.mobileNetworkCode integerValue];
    
    HTTDMobileISPType isp = HTTDMobileISPTypeUnknown;
    
    if (mcc == 460) {
        switch (mnc) {
            case 0:
            case 2:
            case 7:
            case 8:
            {
                isp = HTTDMobileISPTypeChinaMobile;
            }
                break;
            case 1:
            case 6:
            case 9:
            {
                isp = HTTDMobileISPTypeChinaUnicom;
            }
                break;
            case 3:
            case 5:
            case 11:
            {
                isp = HTTDMobileISPTypeChinaTelecom;
            }
                break;
            case 20:
            {
                isp = HTTDMobileISPTypeChinaTietong;
            }
                break;
            default:
                break;
        }
    }
    return isp;
}

@end
