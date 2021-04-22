//
//  HTOpenUDID.h
//  HTIOSFoundationToolKit
//
//  Created by 伟东 on 2020/7/22.
//  Copyright © 2020 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>

#define kYXOpenUDIDErrorNone          0
#define kYXOpenUDIDErrorOptedOut      1
#define kYXOpenUDIDErrorCompromised   2

NS_ASSUME_NONNULL_BEGIN

@interface HTOpenUDID : NSObject
+ (NSString *)value;
+ (NSString *)valueWithError:(NSError **)error;
+ (void)setOptOut:(BOOL)optOutValue;
@end

NS_ASSUME_NONNULL_END
