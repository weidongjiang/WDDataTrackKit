//
//  HTAppInfo.h
//  HTIOSFoundationToolKit
//
//  Created by 伟东 on 2020/7/23.
//  Copyright © 2020 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface HTAppInfo : NSObject

@property (nonatomic, readwrite, strong) NSString   *bundleDisplayName;
@property (nonatomic, readwrite, strong) NSString   *bundleVersion;
@property (nonatomic, readwrite, strong) NSString   *buildVersion;

+ (instancetype)sharedInfo;

@end

NS_ASSUME_NONNULL_END
