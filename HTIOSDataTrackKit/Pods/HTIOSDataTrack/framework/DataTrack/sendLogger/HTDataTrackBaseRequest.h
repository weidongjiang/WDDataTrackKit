//
//  HTDataTrackBaseRequest.h
//  HTIOSDataTrackKit
//
//  Created by 伟东 on 2020/9/7.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "HTDTRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTDataTrackBaseRequest : HTDTRequest

- (NSDictionary<NSString *,NSString *> *)requestHeaderFieldValueDictionary;

@end

NS_ASSUME_NONNULL_END
