//
//  ViewController.m
//  HTIOSDataTrackKit
//
//  Created by 伟东 on 2020/8/7.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "ViewController.h"
#import "HTDTRequest.h"
#import "HTDataTrackDatabaseMgr.h"
#import "HTDataTrackReachability.h"
#import "HTDataTrackLogger.h"
#import "HTDataTrackConsoleLog.h"

@interface ViewController ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) dispatch_queue_t queue;
@property (nonatomic, strong) dispatch_queue_t queue_logger;

@property (nonatomic, strong) UIButton *sendbtn;

@property (nonatomic, strong) NSTimer *checktimer;
@property (nonatomic, strong) UILabel *tableCountLabel;
@property (nonatomic, assign) NSInteger              datacount;
@property (nonatomic, strong) UIButton *sendbtn_1;
@property (nonatomic, strong) UIButton *sendbtn_2;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
    self.view.backgroundColor = [UIColor grayColor];
    UIButton *sendbtn = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 250, 40)];
    self.sendbtn = sendbtn;
    sendbtn.titleLabel.font = [UIFont systemFontOfSize:14];
    [sendbtn setBackgroundColor:[UIColor yellowColor]];
    [sendbtn setTitle:@"开始：自动插入数据1s/1条" forState:UIControlStateNormal];
    [sendbtn setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [sendbtn addTarget:self action:@selector(sendBtnDid:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendbtn];

    
    UIButton *sendbtn_1 = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 250, 40)];
    self.sendbtn_1 = sendbtn_1;
    sendbtn_1.titleLabel.font = [UIFont systemFontOfSize:14];
    [sendbtn_1 setBackgroundColor:[UIColor yellowColor]];
    [sendbtn_1 setTitle:@"手动1条插入" forState:UIControlStateNormal];
    [sendbtn_1 setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [sendbtn_1 addTarget:self action:@selector(sendbtn_1Did) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:sendbtn_1];
    
    self.tableCountLabel = [[UILabel alloc] initWithFrame:CGRectMake(100, 400, 250, 40)];
    self.tableCountLabel.backgroundColor = [UIColor blackColor];
    self.tableCountLabel.textColor = [UIColor whiteColor];
    self.tableCountLabel.font = [UIFont systemFontOfSize:14];
    [self.view addSubview:self.tableCountLabel];
    

//    self.checktimer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(checkTableCount) userInfo:nil repeats:YES];
//    [[NSRunLoop mainRunLoop] addTimer:self.checktimer forMode:NSRunLoopCommonModes];
}

- (void)sendBtnDid:(UIButton *)btn {
    
    if (btn.isSelected) {
        
        [self.timer invalidate];
        self.timer = nil;
        [btn setSelected:NO];
        NSString *count = [NSString stringWithFormat:@"开始：自动插入数据1s/1条：%ld",(long)self.datacount];
        [self.sendbtn setTitle:count forState:UIControlStateNormal];
        
    }else {

        self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(checkSendLogger) userInfo:nil repeats:YES];
        [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
        [btn setSelected:YES];
        
        NSString *count = [NSString stringWithFormat:@"停止：自动插入数据1s/1条：%ld",(long)self.datacount];
        [self.sendbtn setTitle:count forState:UIControlStateNormal];
    }
    
}

- (void)sendbtn_1Did {
    
    NSMutableDictionary *kk = [NSMutableDictionary dictionary];
    [kk htdt_setSafeObject:@"wwww" forKey:@"ext"];
    [kk htdt_setSafeObject:@"mm" forKey:@"zxc"];
    
    [[HTDataTrackLogger shareTrackLogger] logWithEvent:@"htdata_test_jr" pvSrting:nil extraParameters:kk];
    
    self.datacount++;
    NSString *count = [NSString stringWithFormat:@"手动1条插入：%ld",(long)self.datacount];
    [self.sendbtn_1 setTitle:count forState:UIControlStateNormal];
}


- (void)sendbtn_2Did {
    
    for (int i = 0; i < 10; i++) {
        [[HTDataTrackLogger shareTrackLogger] logWithEvent:@"htdata_test_jr" pvSrting:@"viewdd" extraParameters:[self infoLogger]];
    }
    
    self.datacount++;
    NSString *count = [NSString stringWithFormat:@"手动500条插入：%ld",(long)self.datacount];
    [self.sendbtn_2 setTitle:count forState:UIControlStateNormal];
}


- (void)checkTableCount {
    NSInteger unSendDataCount = [[HTDataTrackDatabaseMgr shareInatace] getUnSendDataCount];
    self.tableCountLabel.text = [NSString stringWithFormat:@"缓存的条数：%ld",(long)unSendDataCount];

}

- (void)checkSendLogger {

    [[HTDataTrackLogger shareTrackLogger] logWithEvent:@"htdata_test_jr" pvSrting:@"viewdd" extraParameters:[self infoLogger]];
    
    self.datacount++;
    NSString *count = [NSString stringWithFormat:@"自动插入数据1s/1条：%ld",(long)self.datacount];
    if (self.sendbtn.isSelected) {
        count = [NSString stringWithFormat:@"停止：自动插入数据1s/1条：%ld",(long)self.datacount];
    }else {
        count = [NSString stringWithFormat:@"开始：自动插入数据1s/1条：%ld",(long)self.datacount];
    }
    [self.sendbtn setTitle:count forState:UIControlStateNormal];
    
    HTDTLog(@"Logger:%@",count);
}


- (NSDictionary *)infoLogger {
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    [info htdt_setSafeObject:@"52853376" forKey:@"offset"];
    [info htdt_setSafeObject:@"101.232.210.146" forKey:@"client_ip"];
    [info htdt_setSafeObject:@(1599375763522) forKey:@"event_time"];
    [info htdt_setSafeObject:@"axios/0.18.1" forKey:@"user_agent"];
    [info htdt_setSafeObject:[self contextLogger] forKey:@"context"];
    return [info copy];
}

- (NSDictionary *)contextLogger {
    NSMutableDictionary *context = [NSMutableDictionary dictionary];
    
    [context htdt_setSafeObject:[self jsonStrLogger] forKey:@"jsonStr"];
    [context htdt_setSafeObject:@"prod" forKey:@"debug_env"];
    [context htdt_setSafeObject:@"3ZmGp576n22yVB5vdrtI25I9cKFgpcu9" forKey:@"serialId"];
    [context htdt_setSafeObject:[self commonLogger] forKey:@"common"];
    [context htdt_setSafeObject:[self classLogger] forKey:@"class"];

    return [context copy];
}

- (NSDictionary *)classLogger {

    NSMutableDictionary *class = [NSMutableDictionary dictionary];
    [class htdt_setSafeObject:@"unit" forKey:@"mode"];
    [class htdt_setSafeObject:@"11225" forKey:@"classId"];
    [class htdt_setSafeObject:@"project" forKey:@"chapterType"];
    [class htdt_setSafeObject:@"215156" forKey:@"chapterId"];
    [class htdt_setSafeObject:@"0" forKey:@"extendedLessonId"];
    [class htdt_setSafeObject:@"u0011u00185" forKey:@"name"];
    [class htdt_setSafeObject:@"6046" forKey:@"unitId"];
    [class htdt_setSafeObject:@"false" forKey:@"finished"];
    [class htdt_setSafeObject:@"0" forKey:@"extendedLessonCategoryId"];
    [class htdt_setSafeObject:@"14" forKey:@"courseId"];
    [class htdt_setSafeObject:@"class" forKey:@"lessonType"];

    
    return [class copy];
}

- (NSDictionary *)commonLogger {
    NSMutableDictionary *common = [NSMutableDictionary dictionary];
    [common htdt_setSafeObject:@"DESKTOP" forKey:@"debug_platform"];
    [common htdt_setSafeObject:@"SCRATCH V1.4.15" forKey:@"clientTypeVersion"];
    [common htdt_setSafeObject:@"2" forKey:@"courseGroup"];

    NSMutableDictionary *subject = [NSMutableDictionary dictionary];
    [subject htdt_setSafeObject:@"true" forKey:@"scratch"];
    [common htdt_setSafeObject:subject forKey:@"subject"];

    NSMutableDictionary *latestUnlockedLevel = [NSMutableDictionary dictionary];
    [latestUnlockedLevel htdt_setSafeObject:@"5" forKey:@"scratch"];
    [common htdt_setSafeObject:latestUnlockedLevel forKey:@"latestUnlockedLevel"];
    
    return [common copy];
}


- (NSDictionary *)jsonStrLogger {
    
    NSMutableDictionary *jsonStr = [NSMutableDictionary dictionary];
    NSMutableDictionary *extension = [NSMutableDictionary dictionary];
    NSMutableArray *chapterInfos = [NSMutableArray array];
//    for (int i = 0; i < 3; i++) {
//    }
    NSMutableDictionary *dict_1 = [NSMutableDictionary dictionary];
    [dict_1 htdt_setSafeObject:@(1599375613130) forKey:@"chapterEnterTime"];
    [dict_1 htdt_setSafeObject:@(292549) forKey:@"chapterId"];
    [chapterInfos htdt_addSafeObject:dict_1];
    [extension htdt_setSafeObject:chapterInfos forKey:@"chapterInfos"];
    
    [jsonStr htdt_setSafeObject:extension forKey:@"extension"];
    [jsonStr htdt_setSafeObject:@"11225" forKey:@"class"];
    [jsonStr htdt_setSafeObject:@"14" forKey:@"course"];
    [jsonStr htdt_setSafeObject:@"6046" forKey:@"unit"];
    [jsonStr htdt_setSafeObject:@"1599375613130" forKey:@"eventTime"];
    [jsonStr htdt_setSafeObject:@"business" forKey:@"business"];
    [jsonStr htdt_setSafeObject:@"chapter" forKey:@"chapter"];

    return [jsonStr copy];
}


- (dispatch_queue_t)queue {
    if (!_queue) {
        _queue = dispatch_queue_create("com.hetao.checkSendLogger", DISPATCH_QUEUE_SERIAL);
    }
    return _queue;
}

- (dispatch_queue_t)queue_logger {
    if (!_queue_logger) {
        _queue_logger = dispatch_queue_create("com.hetao.logger", DISPATCH_QUEUE_SERIAL);
    }
    return _queue_logger;
}

- (void)logger {
    
    NSMutableDictionary *ext = [NSMutableDictionary dictionary];
    [ext htdt_setSafeObject:@"jwd" forKey:@"ext"];
    [ext htdt_setSafeObject:@"hajh" forKey:@"asd"];

    NSMutableDictionary *kk = [NSMutableDictionary dictionary];
    [kk htdt_setSafeObject:ext forKey:@"ext"];
    [kk htdt_setSafeObject:@"mm" forKey:@"zxc"];
    [kk htdt_setSafeObject:@"nn" forKey:@"qwe"];
    [kk htdt_setSafeObject:@"nhfjlshflasdlhflehrin" forKey:@"q"];
    [kk htdt_setSafeObject:@"会尽快发货了乌尔夫人夫人方便你不穿不了如何牛" forKey:@"a"];
    [kk htdt_setSafeObject:@"nhfjlshflasdlhflehrin" forKey:@"w"];
    [kk htdt_setSafeObject:@"会尽快发货了乌尔夫人夫人方便你不穿不了如何牛" forKey:@"s"];
    [kk htdt_setSafeObject:@"nhfjlshflasdlhflehrin" forKey:@"e"];
    [kk htdt_setSafeObject:@"会尽快发货了乌尔夫人夫人方便你不穿不了如何牛" forKey:@"d"];
    [kk htdt_setSafeObject:@"nhfjlshflasdlhflehrin" forKey:@"r"];
    [kk htdt_setSafeObject:@"会尽快发货了乌尔夫人夫人方便你不穿不了如何牛" forKey:@"f"];
    [kk htdt_setSafeObject:@"会尽快发货了乌尔夫人夫人方便你不穿不了如何牛" forKey:@"g"];
    [kk htdt_setSafeObject:@"nhfjlshflasdlhflehrin" forKey:@"t"];
    [kk htdt_setSafeObject:@"会尽快发货了乌尔夫人夫人方便你不穿不了如何牛" forKey:@"h"];
    [kk htdt_setSafeObject:@"nhfjlshflasdlhflehrin" forKey:@"y"];
    [kk htdt_setSafeObject:@"会尽快发货了乌尔夫人夫人方便你不穿不了如何牛" forKey:@"j"];
    [kk htdt_setSafeObject:@"nhfjlshflasdlhflehrin" forKey:@"u"];
    [kk htdt_setSafeObject:@"会尽快发货了乌尔夫人夫人方便你不穿不了如何牛" forKey:@"k"];
    [kk htdt_setSafeObject:@"会尽快发货了乌尔夫人夫人方便你不穿不了如何牛" forKey:@"l"];
    [kk htdt_setSafeObject:@"nhfjlshflasdlhflehrin" forKey:@"i"];
    [kk htdt_setSafeObject:@"会尽快发货了乌尔夫人夫人方便你不穿不了如何牛" forKey:@"z"];
    [kk htdt_setSafeObject:@"nhfjlshflasdlhflehrin" forKey:@"o"];
    [kk htdt_setSafeObject:@"会尽快发货了乌尔夫人夫人方便你不穿不了如何牛" forKey:@"x"];
    [kk htdt_setSafeObject:@"nhfjlshflasdlhflehrin" forKey:@"p"];
    [kk htdt_setSafeObject:@"会尽快发货了乌尔夫人夫人方便你不穿不了如何牛" forKey:@"c"];
    
    [[HTDataTrackLogger shareTrackLogger] logWithEvent:@"htdata_test_jr" pvSrting:@"viewdd" extraParameters:kk];
}
@end
