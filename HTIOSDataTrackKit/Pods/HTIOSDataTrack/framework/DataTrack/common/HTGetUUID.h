//
//  HTGetUUID.h
//  HTIOSDataTrackKit
//
//  Created by 伟东 on 2020/11/3.
//  Copyright © 2020 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

BOOL isValidNSString(id object);

@interface HTGetUUID : NSObject

+ (instancetype)shareInatace;

- (NSString*)getDeviceUUID;

@end

NS_ASSUME_NONNULL_END
