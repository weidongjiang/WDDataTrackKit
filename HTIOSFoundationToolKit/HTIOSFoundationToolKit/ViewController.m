//
//  ViewController.m
//  HTIOSFoundationToolKit
//
//  Created by 伟东 on 2020/7/21.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "ViewController.h"
#import "HTCategoryTools.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSMutableArray *array = [NSMutableArray array];
    [array ht_addSafeObject:@"asd"];
    
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [HTProgressHUD showTips:@"HTProgressHUD" duration:2];
    });
    
    NSString *name = @"故居里";
    NSString *pinyin = [name ht_pinyin];
    NSLog(@"pinyin---故居里---%@",pinyin);
    
    NSString *nick = @"hjkj jhhiel cscnri j lkj k";
    NSLog(@"nick---%@",[nick ht_pinyinInitial]);
    
    NSLog(@"ht_getChineseCaptialChar---%@",[@"北京" ht_getChineseCaptialChar]);
    NSLog(@"ht_getChineseCaptialChar---%@",[@"上海" ht_getChineseCaptialChar]);
    NSLog(@"ht_second2String---%@",[@"89000" ht_second2String]);

    NSLog(@"ht_parseQuery----%@",[@"a=1&w=2&e=3" ht_parseQuery]);
    NSLog(@"ht_firstPYString----%@",[@"Fsdfs" ht_firstPYString]);

    BOOL ht_stringContainsEmoji = [NSString ht_stringContainsEmoji:@"hjhsfe[haha]🍆kjhd"];
    
    NSLog(@"ht_calculateSubStringCount--%ld",(long)[@"hdajlhlsajlajlajl" ht_calculateSubStringCount:@"ajl"]);
    
    NSLog(@"ht_charAt---%c",[@"fsfhlsf" ht_charAt:4]);
    
    NSLog(@"ht_compareTo--%ld",(long)[@"hjk" ht_compareTo:@"hjk"]);
    
    NSLog(@"ht_substringFromIndex---%@",[@"健身房厉害了副食店" ht_substringFromIndex:2 toIndex:6]);
    
    NSLog(@"ht_toLowerCase---%@",[@"hjfKKUIUJlkkh" ht_toLowerCase]);
    
    NSLog(@"ht_toUpperCase---%@",[@"hjfKKUIUJlkkh" ht_toUpperCase]);

    NSLog(@"ht_trim---%@",[@" hjfK KUI UJl kkh " ht_trim]);

    NSLog(@"ht_replaceAll---%@",[@"gkasggdagdfefa" ht_replaceAll:@"g" with:@"n"]);
    
    NSData *data = [NSData dataFromBase64String:@"发生非人防"];
    NSString *dataString = [data ht_base64EncodedString];
    NSLog(@"ht_base64EncodedString---%@",dataString);
    
    NSLog(@"ht_convertToDateStringFromTimeInterval---%@",[NSDate ht_convertToDateStringFromTimeInterval:1595019064]);
}


@end
