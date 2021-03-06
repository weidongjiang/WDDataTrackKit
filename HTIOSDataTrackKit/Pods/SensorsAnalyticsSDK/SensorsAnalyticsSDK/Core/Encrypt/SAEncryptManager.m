//
// SAEncryptManager.m
// SensorsAnalyticsSDK
//
// Created by å¼ æè¶ð on 2020/11/25.
// Copyright Â© 2020 Sensors Data Co., Ltd. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#if ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Either turn on ARC for the project or use -fobjc-arc flag on this file.
#endif

#import "SAEncryptManager.h"
#import "SAConfigOptions.h"
#import "SAValidator.h"
#import "SAURLUtils.h"
#import "SAAlertController.h"
#import "SensorsAnalyticsSDK+Private.h"
#import "SAFileStore.h"
#import "SAJSONUtil.h"
#import "SAGzipUtility.h"
#import "SAAESEncryptor.h"
#import "SARSAEncryptor.h"
#import "SAECCEncryptor.h"
#import "SALog.h"

static NSString * const kSAEncryptSecretKey = @"SAEncryptSecretKey";

@interface SAEncryptManager ()

/// æ°æ®å å¯å¨ï¼ä½¿ç¨ AES å å¯æ°æ®ï¼
@property (nonatomic, strong) SAAbstractEncryptor *dataEncryptor;

/// æ°æ®å å¯å¨çåå§å¯é¥ï¼åå§ç AES å¯é¥ï¼
@property (atomic, copy) NSData *originalAESKey;

/// æ°æ®å å¯å¨çå å¯åå¯é¥ï¼å å¯åç AES å¯é¥ï¼
@property (atomic, copy) NSString *encryptedAESKey;

/// å¯é¥å å¯å¨ï¼ä½¿ç¨ RSA/ECC å å¯ AES å¯é¥ï¼
@property (nonatomic, strong) SAAbstractEncryptor *keyEncryptor;

/// å¯é¥å å¯å¨çå¬é¥ï¼RSA/ECC çå¬é¥ï¼
@property (nonatomic, strong) SASecretKey *secretKey;

@end

@implementation SAEncryptManager

#pragma mark - SAModuleProtocol

- (void)setEnable:(BOOL)enable {
    _enable = enable;

    if (enable) {
        [self updateEncryptor];
    }
}

#pragma mark - SAOpenURLProtocol

- (BOOL)canHandleURL:(nonnull NSURL *)url {
    return [url.host isEqualToString:@"encrypt"];
}

- (BOOL)handleURL:(nonnull NSURL *)url {
    NSString *message = @"å½å App æªå¼å¯å å¯ï¼è¯·å¼å¯å å¯ååè¯";

    if (self.enable) {
        NSDictionary *paramDic = [SAURLUtils queryItemsWithURL:url];
        NSString *urlVersion = paramDic[@"v"];
        NSString *urlKey = paramDic[@"key"];

        if ([SAValidator isValidString:urlVersion] && [SAValidator isValidString:urlKey]) {
            SASecretKey *secretKey = [self loadCurrentSecretKey];
            NSString *loadVersion = [@(secretKey.version) stringValue];
            // url ä¸­ç key ä¸º encode ä¹åç
            NSString *loadKey = [secretKey.key stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet alphanumericCharacterSet]];

            if ([loadVersion isEqualToString:urlVersion] && [loadKey isEqualToString:urlKey]) {
                message = @"å¯é¥éªè¯éè¿ï¼æéå¯é¥ä¸ App ç«¯å¯é¥ç¸å";
            } else if (![SAValidator isValidString:loadKey]) {
                message = @"å¯é¥éªè¯ä¸éè¿ï¼App ç«¯å¯é¥ä¸ºç©º";
            } else {
                message = [NSString stringWithFormat:@"å¯é¥éªè¯ä¸éè¿ï¼æéå¯é¥ä¸ App ç«¯å¯é¥ä¸ç¸åãæéå¯é¥çæ¬:%@ï¼App ç«¯å¯é¥çæ¬:%@", urlVersion, loadVersion];
            }
        } else {
            message = @"å¯é¥éªè¯ä¸éè¿ï¼æéå¯é¥æ æ";
        }
    }

    SAAlertController *alertController = [[SAAlertController alloc] initWithTitle:nil message:message preferredStyle:SAAlertControllerStyleAlert];
    [alertController addActionWithTitle:@"ç¡®è®¤" style:SAAlertActionStyleDefault handler:nil];
    [alertController show];
    return YES;
}

#pragma mark - SAEncryptModuleProtocol

- (BOOL)hasSecretKey {
    return self.dataEncryptor && self.keyEncryptor;
}

- (void)handleEncryptWithConfig:(NSDictionary *)encryptConfig {
    if (!encryptConfig) {
        return;
    }

    SASecretKey *secretKey = [[SASecretKey alloc] init];
    NSString *ecKey = encryptConfig[@"key_ec"];
    if ([SAValidator isValidString:ecKey] && NSClassFromString(kSAEncryptECCClassName)) {
        // è·å ECC å¯é¥
        NSData *data = [ecKey dataUsingEncoding:NSUTF8StringEncoding];
        if (!data) {
            return;
        }

        NSDictionary *ecKeyDic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (![SAValidator isValidDictionary:ecKeyDic]) {
            return;
        }

        NSNumber *pkv = ecKeyDic[@"pkv"];
        NSString *type = ecKeyDic[@"type"];
        NSString *publicKey = ecKeyDic[@"public_key"];
        if (!pkv || ![SAValidator isValidString:type] || ![SAValidator isValidString:publicKey]) {
            return;
        }

        secretKey.version = [pkv integerValue];
        secretKey.key = [NSString stringWithFormat:@"%@:%@", type, publicKey];
    } else {
        // è·å RSA å¯é¥
        NSNumber *pkv = encryptConfig[@"pkv"];
        NSString *publicKey = encryptConfig[@"public_key"];
        if (!pkv || ![SAValidator isValidString:publicKey]) {
            return;
        }

        secretKey.version = [pkv integerValue];
        secretKey.key = publicKey;
    }

    // å­å¨è¯·æ±çå¬é¥
    [self saveRequestSecretKey:secretKey];

    // æ´æ°å å¯æé å¨
    [self updateEncryptor];
}

- (NSDictionary *)encryptJSONObject:(id)obj {
    @try {
        if (!obj) {
            SALogDebug(@"Enable encryption but the input obj is invalid!");
            return nil;
        }

        if (![self hasSecretKey]) {
            SALogDebug(@"Enable encryption but the secret key is invalid!");
            return nil;
        }

        if (![self encryptAESKey]) {
            SALogDebug(@"Enable encryption but encrypt AES key is failed!");
            return nil;
        }

        // ä½¿ç¨ gzip è¿è¡åç¼©
        NSData *jsonData = [SAJSONUtil JSONSerializeObject:obj];
        NSString *encodingString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSData *encodingData = [encodingString dataUsingEncoding:NSUTF8StringEncoding];
        NSData *zippedData = [SAGzipUtility gzipData:encodingData];

        // AES128 å å¯æ°æ®
        NSString *encryptedString = [self.dataEncryptor encryptObject:zippedData];
        if (![SAValidator isValidString:encryptedString]) {
            return nil;
        }

        // å°è£å å¯çæ°æ®ç»æ
        NSMutableDictionary *secretObj = [NSMutableDictionary dictionary];
        secretObj[@"pkv"] = @(self.secretKey.version);
        secretObj[@"ekey"] = self.encryptedAESKey;
        secretObj[@"payload"] = encryptedString;
        return [NSDictionary dictionaryWithDictionary:secretObj];
    } @catch (NSException *exception) {
        SALogError(@"%@ error: %@", self, exception);
        return nil;
    }
}

#pragma mark - Private Methods

- (void)saveRequestSecretKey:(SASecretKey *)secretKey {
    if (!secretKey) {
        return;
    }

    void (^saveSecretKey)(SASecretKey *) = self.configOptions.saveSecretKey;
    if (saveSecretKey) {
        // éè¿ç¨æ·çåè°ä¿å­å¬é¥
        saveSecretKey(secretKey);

        [SAFileStore archiveWithFileName:kSAEncryptSecretKey value:nil];

        SALogDebug(@"Save secret key by saveSecretKey callback, pkv : %ld, public_key : %@", (long)secretKey.version, secretKey.key);
    } else {
        // å­å¨å°æ¬å°
        NSData *secretKeyData = [NSKeyedArchiver archivedDataWithRootObject:secretKey];
        [SAFileStore archiveWithFileName:kSAEncryptSecretKey value:secretKeyData];

        SALogDebug(@"Save secret key by localSecretKey, pkv : %ld, public_key : %@", (long)secretKey.version, secretKey.key);
    }
}

- (SASecretKey *)loadCurrentSecretKey {
    SASecretKey *secretKey = nil;

    SASecretKey *(^loadSecretKey)(void) = self.configOptions.loadSecretKey;
    if (loadSecretKey) {
        // éè¿ç¨æ·çåè°è·åå¬é¥
        secretKey = loadSecretKey();

        if (secretKey) {
            SALogDebug(@"Load secret key from loadSecretKey callback, pkv : %ld, public_key : %@", (long)secretKey.version, secretKey.key);
        } else {
            SALogDebug(@"Load secret key from loadSecretKey callback failed!");
        }
    } else {
        // éè¿æ¬å°è·åå¬é¥
        id secretKeyData = [SAFileStore unarchiveWithFileName:kSAEncryptSecretKey];
        if ([SAValidator isValidData:secretKeyData]) {
            secretKey = [NSKeyedUnarchiver unarchiveObjectWithData:secretKeyData];
        }

        if (secretKey) {
            SALogDebug(@"Load secret key from localSecretKey, pkv : %ld, public_key : %@", (long)secretKey.version, secretKey.key);
        } else {
            SALogDebug(@"Load secret key from localSecretKey failed!");
        }
    }

    return secretKey;
}

- (void)updateEncryptor {
    @try {
        SASecretKey *secretKey = [self loadCurrentSecretKey];
        if (![SAValidator isValidString:secretKey.key]) {
            return;
        }

        // è¿åçå¯é¥ä¸å·²æçå¯é¥ä¸æ ·åä¸éè¦æ´æ°
        if ([self.secretKey.key isEqualToString:secretKey.key]) {
            return;
        }

        // æ´æ° AES å¯é¥å å¯å¨
        if ([secretKey.key hasPrefix:kSAEncryptECCPrefix]) {
            if (!NSClassFromString(kSAEncryptECCClassName)) {
                NSAssert(NO, @"\næ¨ä½¿ç¨äº ECC å¯é¥ï¼ä½æ¯å¹¶æ²¡æéæ ECC å å¯åºã\n â¢ å¦æä½¿ç¨æºç éæ ECC å å¯åºï¼è¯·æ£æ¥æ¯å¦åå«åä¸º SAECCEncrypt çæä»¶? \n â¢ å¦æä½¿ç¨ CocoaPods éæ SDKï¼è¯·ä¿®æ¹ Podfile æä»¶å¹¶å¢å  ECC æ¨¡åï¼ä¾å¦ï¼pod 'SensorsAnalyticsEncrypt'ã\n");
                return;
            }

            self.keyEncryptor = [[SAECCEncryptor alloc] initWithSecretKey:secretKey.key];
        } else {
            self.keyEncryptor = [[SARSAEncryptor alloc] initWithSecretKey:secretKey.key];
        }

        // æ´æ°å¯é¥
        self.secretKey = secretKey;

        // æ´æ°åå§ç AES å¯é¥
        self.originalAESKey = self.keyEncryptor.random16ByteData;

        // æ´æ°å å¯åç AES å¯é¥
        self.encryptedAESKey = [self.keyEncryptor encryptObject:self.originalAESKey];

        // æ´æ°æ°æ®å å¯å¨
        self.dataEncryptor = [[SAAESEncryptor alloc] initWithSecretKey:self.originalAESKey];
    } @catch (NSException *exception) {
        SALogError(@"%@ error: %@", self, exception);
    }
}

- (BOOL)encryptAESKey {
    if (self.encryptedAESKey) {
        return YES;
    }

    self.encryptedAESKey = [self.keyEncryptor encryptObject:self.originalAESKey];

    return self.encryptedAESKey != nil;
}

@end
