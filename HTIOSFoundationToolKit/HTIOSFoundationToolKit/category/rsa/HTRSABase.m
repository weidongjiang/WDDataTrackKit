//
//  HTRSABase.m
//  HTIOSFoundationToolKit
//
//  Created by 伟东 on 2020/7/22.
//  Copyright © 2020 伟东. All rights reserved.
//

#import "HTRSABase.h"
#import "NSData+HTBase64.h"
#import <CommonCrypto/CommonDigest.h>

@implementation HTRSABase

- (instancetype)init
{
    if ([self isMemberOfClass:[HTRSABase class]]) {
        @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"please do not directly call init method in HTRSABase class, please call its subclass's initWithPubKeyFilePath or init method instead" userInfo:nil];
    }else {
        self = [super init];
        return self;
    }
}

- (instancetype)initWithPubKeyFilePath:(NSString *)pubKeyFilePath
{
    NSAssert(pubKeyFilePath, @"pubKeyFilePath can not be nil");
    
    if (self = [super init])
    {
        _pubKeyFilePath = pubKeyFilePath;
    }
    return self;
}

- (void)dealloc
{
    _pubKeyFilePath = nil;
}


- (SecKeyRef)copyPublicKey
{
    // 公钥文件
    
    SecCertificateRef myCertificate = nil;
    
    NSData *certificateData = [[NSData alloc] initWithContentsOfFile:_pubKeyFilePath] ;
    
    myCertificate = SecCertificateCreateWithData(kCFAllocatorDefault, (__bridge CFDataRef)certificateData);
    
    SecPolicyRef myPolicy = SecPolicyCreateBasicX509();
    
    SecTrustRef myTrust;
    
    // iOS 3.x workaround.
    // Originally: OSStatus status = SecTrustCreateWithCertificates(myCertificate, myPolicy, &myTrust);
    // Reference: http://stackoverflow.com/questions/3996658/sectrustcreatewithcertificates-crashes-on-ipad
    SecCertificateRef certs[1] = { myCertificate };
    CFArrayRef certificates = CFArrayCreate(NULL, (const void **)certs, 1, NULL);
    OSStatus status = SecTrustCreateWithCertificates(certificates, myPolicy, &myTrust);
    CFRelease(certificates);
    
    SecTrustResultType trustResult;
    
    if (status == noErr)
    {
        status = SecTrustEvaluate(myTrust, &trustResult);
    }
    SecKeyRef myKey = SecTrustCopyPublicKey(myTrust);
    CFRelease(myCertificate);
    CFRelease(myPolicy);
    CFRelease(myTrust);
    
    return myKey;
    
}

- (NSData *)decrypt:(NSString *)encryptedText usingKey:(SecKeyRef)key error:(NSError **)err
{
    size_t cipherBufferSize = SecKeyGetBlockSize(key);
    
    uint8_t *cipherBuffer = NULL;
    
    cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
    
    memset((void *)cipherBuffer, 0*0, cipherBufferSize);
    
    NSData *encryptedTextBytes = [encryptedText dataUsingEncoding:NSUTF8StringEncoding];
    unsigned long blockSize = cipherBufferSize;
    
    int numBlock = (int)ceil([encryptedTextBytes length] / (double)blockSize);
    
    NSMutableData *decryptedData = [[NSMutableData alloc] init];
    
    for (int i=0; i<numBlock; i++) {
        
        int bufferSize = (int)blockSize;
        
        NSData *buffer = [encryptedTextBytes subdataWithRange:NSMakeRange(i * blockSize, bufferSize)];
        
        OSStatus status = SecKeyDecrypt(key, kSecPaddingPKCS1,
                                        (const uint8_t *)[buffer bytes],
                                        [buffer length],
                                        cipherBuffer,
                                        &cipherBufferSize);
        
        if (status == noErr)
            
        {
            
            NSData *decryptedBytes = [[NSData alloc]
                                       
                                       initWithBytes:(const void *)cipherBuffer
                                       
                                       length:cipherBufferSize];
            
            [decryptedData appendData:decryptedBytes];
            
        }
        
        else
            
        {
            if (err)
            {
                *err = [NSError errorWithDomain:@"errorDomain" code:status userInfo:nil];
            }
            
            //NSLog(@"encrypt:usingKey: Error: %ld", status);
            free(cipherBuffer);
            return nil;
            
        }
        
    }
    
    if (cipherBuffer)
        
    {
        
        free(cipherBuffer);
        
    }
    
    //NSLog(@"Encrypted text (%d bytes): %@", [encryptedData length], [encryptedData description]);
    
    return decryptedData;
}

- (NSData *)encrypt:(NSString *)plainText usingKey:(SecKeyRef)key error:(NSError **)err
{
    
    size_t cipherBufferSize = SecKeyGetBlockSize(key);
    
    uint8_t *cipherBuffer = NULL;
    
    cipherBuffer = malloc(cipherBufferSize * sizeof(uint8_t));
    
    memset((void *)cipherBuffer, 0*0, cipherBufferSize);
    
    NSData *plainTextBytes = [plainText dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned long blockSize = cipherBufferSize - 12;
    
    int numBlock = (int)ceil([plainTextBytes length] / (double)blockSize);
    
    NSMutableData *encryptedData = [[NSMutableData alloc] init];
    
    for (int i=0; i<numBlock; i++) {
        
        unsigned long bufferSize = MIN(blockSize,[plainTextBytes length] - i * blockSize);
        
        NSData *buffer = [plainTextBytes subdataWithRange:NSMakeRange(i * blockSize, bufferSize)];
        
        OSStatus status = SecKeyEncrypt(key, kSecPaddingPKCS1,
                                        
                                        (const uint8_t *)[buffer bytes],
                                        
                                        [buffer length], cipherBuffer,
                                        
                                        &cipherBufferSize);
        
        if (status == noErr)
            
        {
            
            NSData *encryptedBytes = [[NSData alloc]
                                       
                                       initWithBytes:(const void *)cipherBuffer
                                       
                                      length:cipherBufferSize];
            
            [encryptedData appendData:encryptedBytes];
            
        }
        
        else
            
        {
            if (err)
            {
                *err = [NSError errorWithDomain:@"errorDomain" code:status userInfo:nil];
            }
            
            //NSLog(@"encrypt:usingKey: Error: %ld", status);
            free(cipherBuffer);
            return nil;
            
        }
        
    }
    
    if (cipherBuffer)
        
    {
        
        free(cipherBuffer);
        
    }
    
    //NSLog(@"Encrypted text (%d bytes): %@", [encryptedData length], [encryptedData description]);
    
    return encryptedData;
    
}

- (NSString *)encrypt:(NSString *)plainText
{
    SecKeyRef key = [self copyPublicKey];
    NSData *encryptedText = [self encrypt:plainText usingKey:key error:nil];
    CFRelease(key);
    
    return [encryptedText ht_base64EncodedString];
}

- (NSData *)getHashBytes:(NSData *)plainText {
    CC_SHA1_CTX ctx;
    uint8_t * hashBytes = NULL;
    NSData * hash = nil;
    
    // Malloc a buffer to hold hash.
    hashBytes = malloc( kChosenDigestLength * sizeof(uint8_t) );
    memset((void *)hashBytes, 0x0, kChosenDigestLength);
    // Initialize the context.
    CC_SHA1_Init(&ctx);
    // Perform the hash.
    CC_SHA1_Update(&ctx, (void *)[plainText bytes], (int)[plainText length]);
    // Finalize the output.
    CC_SHA1_Final(hashBytes, &ctx);
    
    // Build up the SHA1 blob.
    hash = [NSData dataWithBytes:(const void *)hashBytes length:(NSUInteger)kChosenDigestLength];
    if (hashBytes) free(hashBytes);
    
    return hash;
}

-(BOOL)verifyTheDataSHA1WithRSA:(NSData *)signature andplainText:(NSString*)plainText
{
    NSData *sigdata = signature;
    SecKeyRef publicKeyRef= [self copyPublicKey];
    size_t signedBytesSize = SecKeyGetBlockSize(publicKeyRef);
    
    OSStatus status = SecKeyRawVerify(publicKeyRef, kSecPaddingPKCS1SHA1,
                                      (const uint8_t *)[[self getHashBytes:[plainText dataUsingEncoding:NSUTF8StringEncoding]] bytes],
                                      kChosenDigestLength,
                                      (const unsigned char *)[sigdata bytes],
                                      signedBytesSize);
    CFRelease(publicKeyRef);
    
    return status == noErr;
}

@end
