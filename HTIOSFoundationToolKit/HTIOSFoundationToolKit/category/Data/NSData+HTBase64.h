//
//  NSData+HTBase64.h
//  HTIOSFoundationToolKit
//
//  Created by 伟东 on 2020/7/22.
//  Copyright © 2020 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (HTBase64)

+ (NSData *)dataFromBase64String:(NSString *)base64String;

- (id)initWithBase64String:(NSString *)base64String;

- (NSString *)ht_base64EncodedString;

@end

NS_ASSUME_NONNULL_END
