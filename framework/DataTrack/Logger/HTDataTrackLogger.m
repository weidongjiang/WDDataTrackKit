//
//  HTDataTrackLogger.m
//  HTIOSDataTrackKit
//
//  Created by 伟东 on 2020/8/17.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "HTDataTrackLogger.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "HTDataTrackDatabaseMgr.h"
#import "HTDataTrackSendLogger.h"
#import "HTDataTrackCommonTools.h"
#import "SensorsAnalyticsSDK.h"

@interface UIViewController (HTDataTrackLogger)
- (void)HTDataTrackLogger_viewDidLoad;
- (void)HTDataTrackLogger_viewWillAppear:(BOOL)animated;
- (void)HTDataTrackLogger_viewWillDisappear:(BOOL)animated;
@end


@interface HTDataTrackLogger ()

@property (nonatomic, weak, readwrite) UIViewController *lastVC;
@property (nonatomic, weak, readwrite) UIViewController *currentVC;
@property (nonatomic, strong) HTDataTrackSendLogger *sendLogger;

@end


@implementation HTDataTrackLogger

+ (void)load {
    
    //viewDidLoad
    Method originalMethod = class_getInstanceMethod(UIViewController.class, @selector(viewDidLoad));
    Method hookedMethod = class_getInstanceMethod(UIViewController.class, @selector(HTDataTrackLogger_viewDidLoad));
    method_exchangeImplementations(originalMethod, hookedMethod);
    
    //viewWillAppear
    originalMethod = class_getInstanceMethod(UIViewController.class, @selector(viewWillAppear:));
    hookedMethod = class_getInstanceMethod(UIViewController.class, @selector(HTDataTrackLogger_viewWillAppear:));
    method_exchangeImplementations(originalMethod, hookedMethod);
    // viewWillDisappear
    originalMethod = class_getInstanceMethod(UIViewController.class, @selector(viewWillDisappear:));
    hookedMethod = class_getInstanceMethod(UIViewController.class, @selector(HTDataTrackLogger_viewWillDisappear:));
    method_exchangeImplementations(originalMethod, hookedMethod);
}

+ (instancetype)shareTrackLogger {
    static dispatch_once_t onceToken;
    static HTDataTrackLogger *_shareLogger = nil;
    dispatch_once(&onceToken, ^{
        _shareLogger = [[HTDataTrackLogger alloc] init];
    });
    return _shareLogger;
}

- (instancetype)init {
    if (self = [super init]) {
        _loggerType = HTDataTrackLoggerAll;
        [self.sendLogger startReportTime];
    }
    return self;
}

- (void)didFinishLaunchingLogStartSend {
    [self checkLogSend];
}

- (void)logWithEvent:(nonnull NSString *)event
     extraParameters:(nullable NSDictionary *)extraParameters {
    [self logWithEvent:event pvSrting:@"-" extraParameters:extraParameters];
}

- (void)logWithEvent:(nonnull NSString *)event
            pvSrting:(nullable NSString *)pvSrting
     extraParameters:(nullable NSDictionary *)extraParameters {
    #if DEBUG
            NSAssert(event.length, @"event 不能为空字符串");
    #endif
    dispatch_async(self.trackLoggerQueue, ^{
        [self updateEventSeq];
        [self _logWithEvent:event pvSrting:pvSrting extraParameters:extraParameters];
    });
    
}

- (void)_logWithEvent:(nonnull NSString *)event
            pvSrting:(nullable NSString *)pvSrting
      extraParameters:(nullable NSDictionary *)extraParameters {
    
    [self checkLogSend];
    
    if (!pvSrting.length) {
        pvSrting = @"-";
    }
    switch (self.loggerType) {
        case HTDataTrackLoggerSensorsData:
            {
                [self _sensorsDatalogWithEvent:event pvSrting:pvSrting extraParameters:extraParameters];
            }
            break;
        case HTDataTrackLoggerDatracking:
            {
                [self _datrackinglogWithEvent:event pvSrting:pvSrting extraParameters:extraParameters];
            }
            break;
        case HTDataTrackLoggerAll:
            {
                [self _sensorsDatalogWithEvent:event pvSrting:pvSrting extraParameters:extraParameters];
                [self _datrackinglogWithEvent:event pvSrting:pvSrting extraParameters:extraParameters];
            }
            break;
            
        default:
            break;
    }
}


- (void)checkLogSend {
    
    dispatch_async(self.trackLoggerQueue, ^{
        [self _checkLogSend];
    });
}

- (void)_checkLogSend {
    HTDTLog(@"Logger:checkLogSend--currentThread--%@",[NSThread currentThread]);
    
    // 检测内存大小
    CGFloat memeryTotalsize = [HTDataTrackCommonTools getPhoneMemeryTotalsize];
    CGFloat memeryFreesize = [HTDataTrackCommonTools getPhoneMemeryFreesize];
    
    HTDTLog(@"Logger:TrackLogger：memeryTotalsize:%f",memeryTotalsize);
    HTDTLog(@"Logger:TrackLogger：memeryFreesize:%f",memeryFreesize);

    // 检测是否超过了 HTDataTrackUnSendDataMaxCount 条，超过了就开始获取上报一次 并且开启定时器
    NSUInteger count = [[HTDataTrackDatabaseMgr shareInatace] getUnSendDataCount];
    if (count >= HTDataTrackUnSendDataMaxCount) {// 立即上报
        [self.sendLogger immediatelySend];
        HTDTLog(@"Logger:TrackLogger：checkLogSend **************** 超过20条")
    }
    if (count > 0) {// 开启定时器
        [self.sendLogger startReportTime];
    }
}


#pragma 神策
- (void)_sensorsDatalogWithEvent:(nonnull NSString *)event
                        pvSrting:(nullable NSString *)pvSrting
                 extraParameters:(nullable NSDictionary *)extraParameters {
    
    NSDictionary *data = [self updateExtraParameters:extraParameters];
    
    NSMutableDictionary *info = [NSMutableDictionary dictionaryWithDictionary:data];
    NSDictionary *dataSADictionary = [self dataSADictionary];
    info = [[info htdt_dictionaryByAddingEntriesFromDictionary:dataSADictionary] mutableCopy];
    
    HTDTLog(@"Logger:TrackLogger：SA--event:%@--extraParameters-%@",event,data);
    HTDTLog(@"Logger:TrackLogger：SA--event:%@--dataSADictionary-%@",event,dataSADictionary);
    HTDTLog(@"Logger:TrackLogger：SA--event:%@--info-%@",event,info);
    
    [[SensorsAnalyticsSDK sharedInstance] track:event withProperties:info];

}

- (NSDictionary *)updateExtraParameters:(NSDictionary *)extraParameters {
    NSMutableString *newKey = [NSMutableString stringWithString:@""];
    NSMutableDictionary *data = [NSMutableDictionary dictionary];
    return [[self _setExtraParameters:extraParameters newKey:newKey data:data] copy];
}

- (NSMutableDictionary *)_setExtraParameters:(NSDictionary *)extraParameters newKey:(NSString *)newKey data:(NSMutableDictionary *)data {
    NSArray *allKeys = extraParameters.allKeys;
    for (int i = 0; i < allKeys.count; i++) {
        NSString *key = [allKeys htdt_unknownObjectAtIndex:i];
        id value = [extraParameters htdt_unknownObjectForKey:key];
        NSString *_key = [NSString stringWithFormat:@"%@_%@",newKey,key];
        if (newKey.length == 0) {
            _key = [NSString stringWithFormat:@"%@",key];
        }
        if ([value isKindOfClass:[NSDictionary class]]) {
            NSMutableDictionary *_parameters = [self _setExtraParameters:value newKey:_key data:data];
            data = [[data htdt_dictionaryByAddingEntriesFromDictionary:_parameters] mutableCopy];
        }else if ([value isKindOfClass:[NSArray class]]) {
            [data htdt_setSafeObject:[value htdt_toJSONStringWithSortedKeyAsc] forKey:_key];
        }else {
            [data htdt_setSafeObject:value forKey:_key];
        }
    }
    return data;
}

#pragma 数仓
- (void)_datrackinglogWithEvent:(nonnull NSString *)event
                       pvSrting:(nullable NSString *)pvSrting
                extraParameters:(nullable NSDictionary *)extraParameters {
    
    NSMutableDictionary *basic = [NSMutableDictionary dictionaryWithDictionary:[self basicDictionary]];
    [basic htdt_setSafeObject:event forKey:@"event"];
    [basic htdt_setSafeObject:pvSrting forKey:@"url"];
    
    NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
    [info htdt_setSafeObject:basic forKey:@"basic"];
    [info htdt_setSafeObject:extraParameters forKey:@"data"];

    NSData *data = [[info htdt_toJSONStringWithSortedKeyAsc] dataUsingEncoding:NSUTF8StringEncoding];
    long long length = data.length;
    CGFloat length_k = length/1024;
    if (length_k >= 10) {
        [basic htdt_setSafeObject:@(1) forKey:@"log_length_warning"];
    }

    HTDataTrackModel *model = [[HTDataTrackModel alloc] init];
    model.dataString = [[info copy] htdt_toJSONStringWithSortedKeyAsc];
    model.userid = self.userid;
    model.time = [self getCuuentTime];
    int64_t num = [[HTDataTrackDatabaseMgr shareInatace] insertTraceData:model];
    HTDTLog(@"Logger:TrackLogger：insertTraceData--dataid--%lld",num);
    NSUInteger count = [[HTDataTrackDatabaseMgr shareInatace] getUnSendDataCount];
    HTDTLog(@"Logger:TrackLogger：unSendDataCount--count--%lu",(unsigned long)count);

    HTDTLog(@"Logger:TrackLogger：DT--event:%@--basic-%@",event,basic);
    HTDTLog(@"Logger:TrackLogger：DT--event:%@--extraParameters-%@",event,extraParameters);
    HTDTLog(@"Logger:TrackLogger：DT--event:%@--info-%@",event,info);
    
}

#pragma getter
- (NSString *)getCurrrntViewControlString {
    NSString *string = NSStringFromClass([self.currentVC class]);
    if (!string.length) {
        return @"-";
    }
    return string;
}

- (HTDataTrackSendLogger *)sendLogger {
    if (!_sendLogger) {
        _sendLogger = [[HTDataTrackSendLogger alloc] init];
    }
    return _sendLogger;
}

@end





#pragma UIViewController (HTDataTrackLogger)

@implementation UIViewController (HTDataTrackLogger)

- (void)HTDataTrackLogger_viewDidLoad {
    BOOL isNavigationController = [self isKindOfClass:UINavigationController.class];
    if (isNavigationController) {
        [self HTDataTrackLogger_viewDidLoad];
        return;
    }
    
    BOOL isTabBarController = [self isKindOfClass:UITabBarController.class];
    if (isTabBarController) {
        [self HTDataTrackLogger_viewDidLoad];
        return;
    }
    
    if (![self isMainWindowViewController]) {
        [self HTDataTrackLogger_viewDidLoad];
        return;
    }

    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [[HTDataTrackLogger shareTrackLogger] updatePVSeq];
    [[HTDataTrackLogger shareTrackLogger] logWithEvent:@"sdk_page_view" pvSrting:NSStringFromClass([self class]) extraParameters:info];
    [self HTDataTrackLogger_viewDidLoad];
}

- (void)HTDataTrackLogger_viewWillAppear:(BOOL)animated {
    
    BOOL isNavigationController = [self isKindOfClass:UINavigationController.class];
    if (isNavigationController) {
        [self HTDataTrackLogger_viewWillAppear:animated];
        return;
    }
    
    BOOL isTabBarController = [self isKindOfClass:UITabBarController.class];
    if (isTabBarController) {
        [self HTDataTrackLogger_viewWillAppear:animated];
        return;
    }
    
    if (![self isMainWindowViewController]) {
        [self HTDataTrackLogger_viewWillAppear:animated];
        return;
    }
    
    [HTDataTrackLogger shareTrackLogger].lastVC = [HTDataTrackLogger shareTrackLogger].currentVC;
    [HTDataTrackLogger shareTrackLogger].currentVC = self;

    [self HTDataTrackLogger_viewWillAppear:animated];
    
}

- (void)HTDataTrackLogger_viewWillDisappear:(BOOL)animated {
    
    if (self == [HTDataTrackLogger shareTrackLogger].currentVC) {
        [HTDataTrackLogger shareTrackLogger].currentVC = [HTDataTrackLogger shareTrackLogger].lastVC;
    }
//    HTDTLog(@"Logger:viewWillDisappear|VC = %@",NSStringFromClass([self class]));
    [self HTDataTrackLogger_viewWillDisappear:animated];
}


- (UIViewController *)rootViewController {
    UIViewController *rootViewController = self;
    while (rootViewController.parentViewController != nil) {
        rootViewController = rootViewController.parentViewController;
    }
    if (rootViewController.presentingViewController) {
        rootViewController = rootViewController.presentingViewController;
    }
    return rootViewController;
}

- (UIViewController *)mainWindowRootViewController {
    return [UIApplication sharedApplication].windows.firstObject.rootViewController;
}

- (BOOL)isMainWindowViewController {
    return [self rootViewController] == [self mainWindowRootViewController];
}

@end
