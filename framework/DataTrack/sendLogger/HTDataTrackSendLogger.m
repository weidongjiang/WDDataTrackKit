//
//  HTDataTrackSendLogger.m
//  HTIOSDataTrackKit
//
//  Created by 伟东 on 2020/8/28.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "HTDataTrackSendLogger.h"
#import "HTDataTrackDefine.h"
#import "HTDataTrackDatabaseMgr.h"
#import "HTCategoryTools.h"
#import "HTDataTrackReachability.h"
#import "HTDataTrackRequest.h"


@interface HTDataTrackSendLogger ()

@property (nonatomic, strong) NSTimer  *reportTimer;
@property (nonatomic, strong) HTDataTrackRequest *sendRequest;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@property (nonatomic, strong) dispatch_queue_t sendQueue;
@property (nonatomic, assign) BOOL isSending;
@end

@implementation HTDataTrackSendLogger
- (instancetype)init {
    if (self = [super init]) {
        _isSending = NO;
    }
    return self;
}

- (void)startSend {
     [self _dispatch_async_sendLoggerLimit:HTDataTrackGetSendDataMaxlimit];
}

- (void)startReportTime {

    if ([self isTimering]) {
        HTDTLog(@"Logger:sendLogger: timer startReportTime isTimering=YES");
        return;
    }

    [self stopReportTime];
    self.reportTimer = [NSTimer timerWithTimeInterval:HTDataTrackSendTimer target:self selector:@selector(checkSendLogger) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.reportTimer forMode:NSRunLoopCommonModes];
    HTDTLog(@"Logger:sendLogger: timer startReportTime reportTimer init");
}

- (BOOL)isTimering {
    if (self.reportTimer) {
        return YES;
    }
    return NO;
}

- (void)stopReportTime {
    if (!self.reportTimer) {
        return;
    }
    HTDTLog(@"Logger:sendLogger: timer stopReportTime reportTimer invalidate nil");
    [self.reportTimer invalidate];
    self.reportTimer = nil;
}

- (void)immediatelySend {
    [self _dispatch_async_sendLoggerLimit:HTDataTrackUnSendDataMaxCount];
}

- (void)checkSendLogger {
    HTDTLog(@"Logger:sendLogger: timer checkSendLogger loop");
    [self _dispatch_async_sendLoggerLimit:HTDataTrackGetSendDataMaxlimit];
}

- (void)_dispatch_async_sendLoggerLimit:(NSInteger)limit {
    dispatch_async(self.sendQueue, ^{
        [self _sendLoggerLimit:limit];
    });
}

- (void)_sendLoggerLimit:(NSInteger)limit {
    
    if (self.isSending) {
        HTDTLog(@"Logger:sendLogger: timer checkSendLogger loop _sendLoggerLimit isSending=yes");
        return;
    }
    
    
    HTNetworkDetailStatus status = [[HTDataTrackReachability shareInstance] currentDetailReachabilityStatus];

    if (!(status == HTNetworkDetailStatusWifi || status == HTNetworkDetailStatus4G)) {
        HTDTLog(@"Logger:sendLogger: timer checkSendLogger loop !HTNetworkDetailStatusWifi  !HTNetworkDetailStatus4G");
        return;
    }

    NSArray *dataArray = [[HTDataTrackDatabaseMgr shareInatace] getSendDataArrayOffset:0 limit:limit];
    // 数据库暂时没有数据就停止定时器
    if (!dataArray.count) {
        [self stopReportTime];
        HTDTLog(@"Logger:sendLogger: timer stopReportTime dataArray.count=0");
        return;
    }
    
    // 转化发生的数据
    NSString *_generateNO = __generateNO(9);
    NSMutableArray *array = [NSMutableArray array];
    for (int i=0; i < dataArray.count; i++) {
        HTDataTrackModel *_model = [dataArray htdt_unknownObjectAtIndex:i];
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[_model.dataString dataUsingEncoding:NSUTF8StringEncoding] options:kNilOptions error:nil];
        NSMutableDictionary *_dict = [NSMutableDictionary dictionaryWithDictionary:dict];
        [_dict htdt_setSafeObject:_generateNO forKey:@"data_id"];
        [array addObject:_dict];
    }
    NSData *data = [[array htdt_toJSONStringWithSortedKeyAsc] dataUsingEncoding:NSUTF8StringEncoding];
    [self _sendData:data dataArray:dataArray];
    HTDTLog(@"Logger:sendLogger:--array--%@",array);
}

// 8位随机数
NSString *__generateNO(NSInteger kNumber){
    if (kNumber <= 0) return @"";
    
    NSString *sourceStr = @"0123456789";
    NSMutableString *resultStr = [[NSMutableString alloc] init];
    for (int i = 0; i < kNumber; i++){
        unsigned index = arc4random() % [sourceStr length];
        NSString *oneStr = [sourceStr substringWithRange:NSMakeRange(index, 1)];
        [resultStr appendString:oneStr];
    }
    return resultStr;
}


- (void)_sendData:(NSData *)sendData dataArray:(NSArray *)dataArray {
    
    long long length = sendData.length;
    CGFloat length_k = length/1024;
    
    HTDTLog(@"Logger:sendLogger:----Limit:%lu-----length:%lld-----length-k:%f",(unsigned long)dataArray.count,length,length_k);

    dispatch_semaphore_wait(self.semaphore, DISPATCH_TIME_FOREVER);
    self.isSending = YES;
    HTDTLog(@"Logger:sendLogger: timer _sendData isSending=yes");
    self.sendRequest.rawData = sendData;
    [self.sendRequest startWithCompletionBlockWithSuccess:^(HTDTBaseRequest *request) {
        dispatch_async(self.sendQueue, ^{
            NSDictionary *dict = (NSDictionary *)request.responseObject;
            NSDictionary *info = [dict htdt_dictForKey:@"info"];
            NSInteger status_code = [info htdt_integerForKey:@"status_code"];
            HTDTLog(@"Logger:sendLogger:--success-code:%ld",(long)status_code);
            if (status_code == 200) {
                // 发送成功删除对应的数据
                NSString *dataid = @"";
                for (int i=0; i < dataArray.count; i++) {
                    HTDataTrackModel *_model = [dataArray htdt_unknownObjectAtIndex:i];
                    BOOL isdelete = [[HTDataTrackDatabaseMgr shareInatace] deleteTraceDataWithModel:_model];
                    dataid = [dataid stringByAppendingString:[NSString stringWithFormat:@"%ld=%d_",(long)_model.dataid,isdelete?1:0]];
                    HTDTLog(@"Logger:sendLogger:delete---dataid-:%ld---dataString--%@",(long)_model.dataid,_model.dataString);
                }
                HTDTLog(@"Logger:sendLogger:delete---dataid-:%@",dataid);
            }
            self.isSending = NO;
            HTDTLog(@"Logger:sendLogger: timer _sendData Success isSending=no");
        });
        dispatch_semaphore_signal(self.semaphore);
    } failure:^(HTDTBaseRequest *request) {
        self.isSending = NO;
        HTDTLog(@"Logger:sendLogger: timer _sendData failure isSending=no");
        HTDTLog(@"Logger:sendLogger:--failure:error:%@",request.error);
        dispatch_semaphore_signal(self.semaphore);
    }];

}


- (HTDataTrackRequest *)sendRequest {
    if (!_sendRequest) {
        _sendRequest = [[HTDataTrackRequest alloc] init];
    }
    return _sendRequest;
}

- (dispatch_semaphore_t)semaphore {
    if (!_semaphore) {
        _semaphore=dispatch_semaphore_create(1);
    }
    return _semaphore;
}
- (dispatch_queue_t)sendQueue {
    if (!_sendQueue) {
        _sendQueue = dispatch_queue_create("com.trackLogger.sendQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _sendQueue;
}
@end
