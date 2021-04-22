//
//  HTDataTrackRequest.h
//  HTIOSDataTrackKit
//
//  Created by 伟东 on 2020/9/7.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "HTDataTrackBaseRequest.h"

NS_ASSUME_NONNULL_BEGIN

@interface HTDataTrackRequest : HTDataTrackBaseRequest

@property (nonatomic, strong) NSData     *rawData;

@end

NS_ASSUME_NONNULL_END
