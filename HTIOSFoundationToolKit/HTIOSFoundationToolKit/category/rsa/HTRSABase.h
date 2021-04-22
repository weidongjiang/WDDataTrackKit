//
//  HTRSABase.h
//  HTIOSFoundationToolKit
//
//  Created by 伟东 on 2020/7/22.
//  Copyright © 2020 伟东. All rights reserved.
//

#import <Foundation/Foundation.h>
#define kChosenDigestLength CC_SHA1_DIGEST_LENGTH

NS_ASSUME_NONNULL_BEGIN

@interface HTRSABase : NSObject
{
@protected
    NSString *_pubKeyFilePath;
}

/*!
 *  用公钥文件的路径初始化HTRSABase
 *
 *  @param pubKeyFilePath 公钥文件路径
 *
 *  @return HTRSABase对象
 */
- (instancetype)initWithPubKeyFilePath:(NSString *)pubKeyFilePath;

/*!
 *  给文本加密
 *
 *  @param plainText 要加密的文本
 *
 *  @return 加密后的字符串
 */
- (NSString *)encrypt:(NSString *)plainText;

-(BOOL)verifyTheDataSHA1WithRSA:(NSData *)signature andplainText:(NSString*)plainText;

@end

NS_ASSUME_NONNULL_END
