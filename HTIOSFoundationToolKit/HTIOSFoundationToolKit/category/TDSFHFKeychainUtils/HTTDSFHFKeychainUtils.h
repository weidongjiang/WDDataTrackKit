//
//  HTTDSFHFKeychainUtils.h
//  HTIOSFoundationToolKit
//
//  Created by 伟东 on 2020/7/23.
//  Copyright © 2020 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HTTDSFHFKeychainUtils : NSObject

+ (NSString *)getPasswordForUsername:(NSString *)username
                       andServiceName:(NSString *)serviceName
                                error:(NSError **)error;


+ (BOOL)storeUsername:(NSString *)username
           andPassword:(NSString *)password
        forServiceName:(NSString *)serviceName
        updateExisting:(BOOL)updateExisting
                 error:(NSError **)error;


+ (BOOL)deleteItemForUsername:(NSString *)username
                andServiceName:(NSString *)serviceName
                         error:(NSError **)error;
@end

NS_ASSUME_NONNULL_END
