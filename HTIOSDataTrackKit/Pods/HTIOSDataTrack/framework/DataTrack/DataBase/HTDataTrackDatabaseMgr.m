//
//  HTDataTrackDatabaseMgr.m
//  HTIOSDataTrackKit
//
//  Created by 伟东 on 2020/8/7.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "HTDataTrackDatabaseMgr.h"
#import "FMDB.h"
#import "HTCategoryTools.h"
#import "HTDataTrackConsoleLog.h"

#define KTraceDatabaseVersion @"1.0"
#define KHTDataTraceDatabaseFileName @"HTDataTraceDatabase.sqlite"// 数据库名
#define KHTDataTraceDatabaseMaxRow 20000 // 最大存储数据2000条
#define KHTDataTraceDatabaseDataTable @"htdata_datatrace_datatable"// 表名
#define KHTDataTraceDatabaseTableVersion @"htdata_datatrace_version" // 数据库 版本表

#define HTDataTraceDatabaseCloseDB [self.database close]; // 关闭数据库



@interface HTDataTrackDatabaseMgr ()

@property (nonatomic, strong) FMDatabase *database;
@property (nonatomic, strong) dispatch_semaphore_t semaphore;
@end

@implementation HTDataTrackDatabaseMgr
+ (instancetype)shareInatace {
    static HTDataTrackDatabaseMgr *_shareInatace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _shareInatace = [[HTDataTrackDatabaseMgr alloc] init];
    });
    return _shareInatace;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        // 1.判断数据库是否存在,不存在就创建数据库并创建表
        if (NO == [[NSFileManager defaultManager] fileExistsAtPath:[HTDataTrackDatabaseMgr dbPath]]) {
            FMDatabase *db = [FMDatabase databaseWithPath:[HTDataTrackDatabaseMgr dbPath]];
            self.database = db;
            if (NO == [self createTableAndView]) {
                return nil;
            }else {
                [self addNewVersion:KTraceDatabaseVersion];
            }
            self.database = db;
        }
        
        // 打开数据库
        FMDatabase *db = [FMDatabase databaseWithPath:[HTDataTrackDatabaseMgr dbPath]];
        self.database = db;
        if (NO == [db open]) {
            [db close];
            // 打开数据库失败，反馈出去
            return nil;
        }
        
        // 2.判断数据库是否需要升级
        [self updateDatabase];

        HTDataTraceDatabaseCloseDB
    }
    return self;
}

- (BOOL)createTableAndView {
    
    dispatch_semaphore_wait(self.semaphore,DISPATCH_TIME_FOREVER);
    
    if (NO == [self openDB]) {
        [self closeDB];
        dispatch_semaphore_signal(self.semaphore);
        return NO;
    }
    // 创建版本表
    {
        NSString *sql = [NSString stringWithFormat:@"create table 'htdata_datatrace_version' ('id' INTEGER PRIMARY KEY AUTOINCREMENT,'version' text not null default '0','updateDate' text not null default '')"];
        if (NO == [self.database executeUpdate:sql]) {
            HTDataTraceDatabaseCloseDB
            dispatch_semaphore_signal(self.semaphore);
            return NO;
        }
    }
    
    // 创建用户表
    {
        NSString *sql = @"CREATE TABLE IF NOT EXISTS htdata_datatrace_datatable (dataid INTEGER PRIMARY KEY AUTOINCREMENT, userid TEXT not null default '', datastring TEXT not null default '', time TEXT not null default '', extend TEXT not null default '')";
        if (NO == [self.database executeUpdate:sql]) {
            HTDataTraceDatabaseCloseDB
            dispatch_semaphore_signal(self.semaphore);
            return NO;
        };
    }
    
    dispatch_semaphore_signal(self.semaphore);

    return YES;
}

- (BOOL)addNewVersion:(NSString *)version {
    
    dispatch_semaphore_wait(self.semaphore,DISPATCH_TIME_FOREVER);
    
    if (NO == [self openDB]) {
        [self closeDB];
        dispatch_semaphore_signal(self.semaphore);
        return NO;
    }
    
    NSDateFormatter *dateFormatter = [NSDateFormatter htdt_dateFormateterForCurrentThread];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
    NSString *destDateString = [dateFormatter stringFromDate:[NSDate date]];

    NSString *sql = [NSString stringWithFormat:@"insert into %@ (version,updateDate) values (?,?)",KHTDataTraceDatabaseTableVersion];
    NSString *_version = [NSString stringWithFormat:@"%@",version];
    BOOL isExecuteUpdate = [self.database executeUpdate:sql withArgumentsInArray:@[_version,destDateString]];
    HTDataTraceDatabaseCloseDB
    dispatch_semaphore_signal(self.semaphore);
    
    return  isExecuteUpdate;
    
}

- (void)updateDatabase {
    
    dispatch_semaphore_wait(self.semaphore,DISPATCH_TIME_FOREVER);

    if (NO == [self openDB]) {
        [self closeDB];
        dispatch_semaphore_signal(self.semaphore);
        return;
    }
    
    float lastVersion = -1.f;
    NSString *sql = [NSString stringWithFormat:@"select * from %@ order by id desc limit 0,1",KHTDataTraceDatabaseTableVersion];
    FMResultSet *set = [self.database executeQuery:sql];
    while ([set next]) {
       lastVersion = [[set stringForColumn:@"version"] floatValue];
    }
    NSString *last = [NSString stringWithFormat:@"%.02f",lastVersion];
    lastVersion = [last floatValue];
    NSInteger last_Version = lastVersion * 10;
    float last_1 = last_Version / 10;
    float last_2 = last_Version % 10;
    lastVersion = last_1 + last_2 * 0.1;
    
    HTDataTraceDatabaseCloseDB
    dispatch_semaphore_signal(self.semaphore);
}

- (int64_t)insertTraceData:(HTDataTrackModel *)model {
    dispatch_semaphore_wait(self.semaphore,DISPATCH_TIME_FOREVER);
    
    if (!model.userid.length) {
        dispatch_semaphore_signal(self.semaphore);
        return -1;
    }
    if (!model.dataString.length) {
        model.dataString = @"-";
    }
    if (!model.time.length) {
        model.time = @"-";
    }
    
    if (NO == [self openDB]) {
        [self closeDB];
        dispatch_semaphore_signal(self.semaphore);
        return -1;
    }
    
    NSString *sql = [NSString stringWithFormat:@"insert into %@ (userid,datastring,time) values (?,?,?)",KHTDataTraceDatabaseDataTable];
    BOOL isExecuteUpdate = [self.database executeUpdate:sql withArgumentsInArray:@[model.userid,model.dataString,model.time]];
    NSInteger _lastInsertRowId = -1;
    if(isExecuteUpdate) {
        _lastInsertRowId = self.database.lastInsertRowId;
    }else{
        _lastInsertRowId = -1;
    }
    HTDTLog(@"insert into--_lastInsertRowId--%ld---dataString--%@",(long)_lastInsertRowId,model.dataString);
    HTDataTraceDatabaseCloseDB
    
    dispatch_semaphore_signal(self.semaphore);
    
    return _lastInsertRowId;
}

- (void)_updateEventSeq:(int64_t)eventSeq model:(HTDataTrackModel *)model {
    
    NSData *jsonData = [model.dataString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
    NSDictionary *basic = [dict htdt_dictForKey:@"basic"];
    basic = [basic htdt_dictionaryBySettingObject:@(eventSeq) forKey:@"eventSeq"];
    dict = [dict htdt_dictionaryBySettingObject:basic forKey:@"basic"];
    
    NSString *datastring = [dict htdt_toJSONStringWithSortedKeyAsc];
    NSString *udatesql = [NSString stringWithFormat:@"update %@ set datastring=? where dataid=?",KHTDataTraceDatabaseDataTable];
    BOOL udatesisExecuteUpdate = [self.database executeUpdate:udatesql withArgumentsInArray:@[datastring,@(eventSeq)]];
    
}

/// 获取数据库里面没有上报的条数
- (NSUInteger)getUnSendDataCount {
    dispatch_semaphore_wait(self.semaphore,DISPATCH_TIME_FOREVER);
    
    if (NO == [self openDB]) {
        [self closeDB];
        dispatch_semaphore_signal(self.semaphore);
        return 0;
    }
    
    NSString *sql = [NSString stringWithFormat:@"select * from %@",KHTDataTraceDatabaseDataTable];
    NSMutableArray *mResultArray = [NSMutableArray array];
    FMResultSet *set = [self.database executeQuery:sql];
    while ([set next]) {
        HTDataTrackModel *model = [HTDataTrackModel alloc];
        model.dataid = [set intForColumn:@"dataid"];
        model.dataString = [set stringForColumn:@"datastring"];
        model.userid = [set stringForColumn:@"userid"];
        model.time = [set stringForColumn:@"time"];
        [mResultArray addObject:model];
    }
    HTDataTraceDatabaseCloseDB
    
    dispatch_semaphore_signal(self.semaphore);
    
    return mResultArray.count;

}

- (NSArray<HTDataTrackModel *>*)getSendDataArrayOffset:(NSInteger)offset limit:(NSInteger)limit {
    
    dispatch_semaphore_wait(self.semaphore,DISPATCH_TIME_FOREVER);

    if (NO == [self openDB]) {
        [self closeDB];
        dispatch_semaphore_signal(self.semaphore);
        return nil;
    }
    NSString *sql = [NSString stringWithFormat:@"select * from %@ desc limit %0ld offset %0ld",KHTDataTraceDatabaseDataTable,limit,offset];
    NSMutableArray *mResultArray = [NSMutableArray array];
    FMResultSet *set = [self.database executeQuery:sql];
    while ([set next]) {
        HTDataTrackModel *model = [HTDataTrackModel alloc];
        model.dataid = [set intForColumn:@"dataid"];
        model.dataString = [set stringForColumn:@"datastring"];
        model.userid = [set stringForColumn:@"userid"];
        model.time = [set stringForColumn:@"time"];
        [mResultArray addObject:model];
    }
    HTDataTraceDatabaseCloseDB
    if (mResultArray.count > 0) {
        dispatch_semaphore_signal(self.semaphore);
        return [NSArray arrayWithArray:mResultArray];
    }
    dispatch_semaphore_signal(self.semaphore);
    return nil;

}

- (BOOL)deleteTraceDatalessThanWithModel:(HTDataTrackModel *)model {
    dispatch_semaphore_wait(self.semaphore,DISPATCH_TIME_FOREVER);
    
    if (NO == [self openDB]) {
        [self closeDB];
        dispatch_semaphore_signal(self.semaphore);
        return NO;
    }
    
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where dataid <= %ld",KHTDataTraceDatabaseDataTable,model.dataid];
    BOOL isExecuteUpdate = [self.database executeUpdate:sql];
    HTDataTraceDatabaseCloseDB
    
    dispatch_semaphore_signal(self.semaphore);
    return isExecuteUpdate;
}

- (BOOL)deleteTraceDataWithModel:(HTDataTrackModel *)model {
    
    dispatch_semaphore_wait(self.semaphore,DISPATCH_TIME_FOREVER);

    if (NO == [self openDB]) {
        [self closeDB];
        dispatch_semaphore_signal(self.semaphore);
        return NO;
    }
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where dataid=%ld",KHTDataTraceDatabaseDataTable,model.dataid];
    BOOL isExecuteUpdate = [self.database executeUpdate:sql];
    HTDataTraceDatabaseCloseDB
    dispatch_semaphore_signal(self.semaphore);
    return isExecuteUpdate;
    
}


#pragma mark Public
- (BOOL)openDB {
    return  [self.database open];
}

- (BOOL)closeDB {
    return  [self.database close];
}

+ (NSString *)dbPath {
    NSString *docsdir = [NSSearchPathForDirectoriesInDomains( NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    return [docsdir stringByAppendingPathComponent:KHTDataTraceDatabaseFileName];
}

- (dispatch_semaphore_t)semaphore {
    if (!_semaphore) {
        _semaphore=dispatch_semaphore_create(1);
    }
    return _semaphore;
}

@end
