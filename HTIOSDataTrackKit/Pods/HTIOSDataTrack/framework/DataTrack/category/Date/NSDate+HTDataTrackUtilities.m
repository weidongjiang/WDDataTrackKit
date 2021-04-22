//
//  NSDate+HTUtilities.m
//  HTIOSFoundationToolKit
//
//  Created by 伟东 on 2020/7/22.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "NSDate+HTDataTrackUtilities.h"
#import "NSDictionary+HTDataTrackKeyValue.h"
#import "NSDictionary+HTDataTrackTypeCast.h"


static NSString * const kThreadDateFormatterKey = @"com.hetao101.thread-dateformatter";
static NSString * const kThreadNSCalendarKey = @"com.hetao101.thread-nscalendar";
@implementation NSDateFormatter (HTDataTrackUtilities)
+ (instancetype)htdt_dateFormateterForCurrentThread {
    NSMutableDictionary *currentThreadDictionary = [[NSThread currentThread] threadDictionary];
    NSDateFormatter *dateFormater = [currentThreadDictionary htdt_unknownObjectForKey:kThreadDateFormatterKey];
    if (!dateFormater) {
        dateFormater = [[NSDateFormatter alloc] init];
        [currentThreadDictionary htdt_setSafeObject:dateFormater forKey:kThreadDateFormatterKey];
    }
    return dateFormater;
}
@end

@implementation NSCalendar (HTDataTrackUtilities)
+ (instancetype)htdt_calenderForCurrentThread {
    NSMutableDictionary *currentThreadDictionary = [[NSThread currentThread] threadDictionary];
    NSCalendar *calendar = [currentThreadDictionary htdt_unknownObjectForKey:kThreadNSCalendarKey];
    if (!calendar) {
        calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        [currentThreadDictionary htdt_setSafeObject:calendar forKey:kThreadNSCalendarKey];
    }
    return calendar;
}
@end



@implementation NSDate (HTDataTrackUtilities)

/*!
 *  根据指定的时间格式字符串，生成并返回一个当前日期的NSString对象
 *
 *  @param formatterString 格式化String
 *
 *  @return 格式化NSDate后的string
 */
- (NSString *)htdt_stringWithFormatter:(NSString *)formatterString {
    NSDateFormatter *dateFormatter = [NSDateFormatter htdt_dateFormateterForCurrentThread];
    [dateFormatter setDateFormat:formatterString];
    NSString *string = [dateFormatter stringFromDate:self];
    return string;
}
/*!
*  根据指定的NSTimeInterval，生成并返回转换成时间格式的NSString对象
*  如  今年： MM-dd HH:mm
*        去年： yyyy-MM-dd HH:mm
*
*  @param t 需要转换的NSTimeInterval
*
*  @return 转换后的NSString
*/
+ (NSString *)htdt_convertToDateStringFromTimeInterval:(NSTimeInterval)t {
    NSString *time;
    NSCalendar *calendar = [NSCalendar htdt_calenderForCurrentThread];
    NSCalendarUnit unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;

    NSDateFormatter *dateFormatter = [NSDateFormatter htdt_dateFormateterForCurrentThread];
    
    NSDate *createdAt = [NSDate dateWithTimeIntervalSince1970:t];
    
    NSDateComponents *nowComponents = [calendar components:unitFlags fromDate:[NSDate date]];
    NSDateComponents *createdComponents = [calendar components:unitFlags fromDate:createdAt];

    if ([nowComponents year] == [createdComponents year] &&
        [nowComponents month] == [createdComponents month] &&
        [nowComponents day] == [createdComponents day]) {// 今天
        [dateFormatter setDateFormat:@"'今天 'HH:mm"];
        time = [dateFormatter stringFromDate:createdAt];
    }else if ([nowComponents year] == [createdComponents year]) {// 今年
        NSLocale *cnLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        [dateFormatter setLocale:cnLocale];
        [dateFormatter setDateFormat:@"MM-dd' 'HH:mm"];
        time = [dateFormatter stringFromDate:createdAt];
    }else {// 去年
        NSLocale *cnLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];
        [dateFormatter setLocale:cnLocale];
        [dateFormatter setDateFormat:@"yyyy-MM-dd' 'HH:mm"];
        time = [dateFormatter stringFromDate:createdAt];
    }
    return time;
}


@end
