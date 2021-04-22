//
//  HTGetDeviceIdSDK.h
//  HTIOSFoundationToolKit
//
//  Created by 伟东 on 2020/7/23.
//  Copyright © 2020 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AdSupport/ASIdentifierManager.h>
#import <CommonCrypto/CommonDigest.h>

NS_ASSUME_NONNULL_BEGIN

@interface HTGetDeviceIdSDK : NSObject
+ (NSString *)did;

+ (NSString *)getUniqueStrByUUID;

+ (NSString *)deviceId;

+ (NSString *)deviceId64;

@end

NS_ASSUME_NONNULL_END
