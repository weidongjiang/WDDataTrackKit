//
//  NSFileManager+HTUtilities.m
//  libcocos2d Mac
//
//  Created by 伟东 on 2020/7/21.
//

#import "NSFileManager+HTUtilities.h"
#include <CommonCrypto/CommonDigest.h>
#include <CommonCrypto/CommonHMAC.h>


#define FileHashDefaultChunkSizeForReadingData 4096

NSString *ht_NSDocumentsFolder(void)
{
    static NSString *documentFolder = nil;
    if (documentFolder == nil)
    {
        documentFolder = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];// retain];
    }
    return documentFolder;
}

NSString *ht_NSLibraryFolder(void)
{
    static NSString *libraryFolder = nil;
    if (libraryFolder == nil)
    {
        libraryFolder = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0] ;//retain];
    }
    return libraryFolder;
}

NSString *ht_NSBundleFolder(void)
{
    return [[NSBundle mainBundle] bundlePath];
}

NSString *ht_NSResourcePath(void)
{
    return [[NSBundle mainBundle] resourcePath];
}

NSString *ht_NSCacheFolder(void)
{
    static NSString *cacheFolder = nil;
    if (cacheFolder == nil) {
        cacheFolder = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] ;//retain];
    }
    return cacheFolder;
}

NSString *ht_TempFileWithName(NSString *name)
{
    return [NSTemporaryDirectory() stringByAppendingPathComponent:name];
}

NSString *ht_DocumentFileWithName(NSString *name)
{
    return [ht_NSDocumentsFolder() stringByAppendingPathComponent:name];
}

NSString *ht_LibraryFilePath(void)
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    return [paths objectAtIndex:0];
}

NSString *ht_LibraryFileWithName(NSString *name)
{
    return [ht_NSLibraryFolder() stringByAppendingPathComponent:name];
}

NSString *ht_ResourceWithName(NSString *name)
{
    return [ht_NSResourcePath() stringByAppendingPathComponent:name];
}

NSString *ht_CacheFileWithName(NSString *name)
{
    return [ht_NSCacheFolder() stringByAppendingPathComponent:name];
}

NSString *HetaoCacheFolder(void)
{
    return ht_LibraryFileWithName(@"HetaoCache");
}

NSString *HetaoCacheItemWithName(NSString *name)
{
    return [HetaoCacheFolder() stringByAppendingPathComponent:name];
}

long ht_getDiskFreeSize()
{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    id obj = [fattributes objectForKey:NSFileSystemFreeSize];
    if ([obj respondsToSelector:@selector(longValue)])
    {
        return [obj longValue];
    }
    return -1;
}

@implementation NSFileManager(HTFileManagerUtilities)

+ (BOOL)ht_removeItemAtPath:(NSString*)path
{
    if (!path)
        return NO;
    
    NSFileManager *fm = FILEMANAGER;
    NSError *error = nil;
    [fm removeItemAtPath:path error:&error];
    
    return (error == nil);
}

+ (NSData*)ht_dataOfFile:(NSString*)filePath offset:(unsigned long long)offset length:(unsigned long long)length
{
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingAtPath:filePath];
    if (!fileHandle) return nil;
    
    NSError *error = nil;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    NSDictionary *stat = [fileManager attributesOfItemAtPath:filePath error:&error];
    
    if (error != nil) return nil;
    
    unsigned long long totalLength = [stat fileSize];
    
    if (length <= 0 || offset + length > totalLength)
    {
        length = totalLength - offset;
    }
    
    [fileHandle seekToFileOffset:offset];
    return [fileHandle readDataOfLength:(NSUInteger)length];
}

+ (BOOL)ht_copyItemAtPath:(NSString*)fromPath toPath:(NSString*)toPath overWrite:(BOOL)overWrite
{
    if ([fromPath length] == 0 || [toPath length] == 0)
        return NO;
    
    NSFileManager *fm = FILEMANAGER;
    NSError* _error = nil;
    if (overWrite)
    {
        [fm removeItemAtPath:toPath error:&_error];
        _error = nil;
    }
    
    [fm copyItemAtPath:fromPath toPath:toPath error:&_error];
    return (_error == nil);
}

+ (BOOL)ht_asyncCopyImageItemFromURL:(NSURL*)fromURL
                               toPath:(NSString*)toPath
                            overWrite:(BOOL)overWrite
                         successBlock:(ALAssetsLibraryAssetForURLResultBlock)successBlock
                          failedBlock:(ALAssetsLibraryAccessFailureBlock)failedBlock
{
    if (!fromURL || [toPath length] == 0)
        return NO;
    
    NSFileManager *fm = [[NSFileManager alloc] init];
    __block NSError *_error = nil;
    
    if (overWrite)
    {
        [fm removeItemAtPath:toPath error:&_error];
    }
    
    
    ALAssetsLibrary *lib = [ALAssetsLibrary new];
    [lib assetForURL:fromURL resultBlock:^(ALAsset *asset) {
        //            ALAssetRepresentation *repr = [asset defaultRepresentation];
        //            CGImageRef cgImg = [repr fullResolutionImage];
        //            UIImage *img = [UIImage imageWithCGImage:cgImg];
        //            NSData *data = UIImagePNGRepresentation(img);
        //            [data writeToFile:toPath atomically:YES];
        successBlock(asset);
    } failureBlock:^(NSError *error) {
        failedBlock(error);
    }];
    
    
    return (_error == nil);
}

+ (BOOL)ht_saveDataObject:(id)dataObject
         documentsFilePath:(NSString *)filePath
{
    NSString *docPath = ht_DocumentFileWithName(filePath);
    
    if ([dataObject isKindOfClass:NSArray.class])
    {
        return [(NSArray *)dataObject writeToFile:docPath atomically:NO];
    }
    else if([dataObject isKindOfClass:NSDictionary.class])
    {
        return [(NSDictionary *)dataObject writeToFile:docPath atomically:NO];
    }
    
    NSLog(@"saveDataObject:documentsFilePath Error : DataObject should be NSArray or NSDictionary, got %@", NSStringFromClass([dataObject class]));
    return NO;
}

+ (BOOL)ht_archiverDataObject:(id)dataObject
                      filePath:(NSString *)filePath
{
    // 使用NSKeyedArchiver避免Dict的值包含NSNull导致写入失败的情况
    NSData * data = [NSKeyedArchiver archivedDataWithRootObject:dataObject];
    return [data writeToFile:filePath atomically:YES];
}

+ (id)ht_loadArchiverObjectFromFilePath:(NSString *)filePath
{
    NSFileManager *fileManager= [[NSFileManager alloc] init] ;//autorelease];
    if (filePath && [fileManager fileExistsAtPath:filePath])
    {
        NSData * data = [NSData dataWithContentsOfFile:filePath];
        id  object;
        @try {
            
            object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            
        } @catch (NSException *exception) {
            
            
        } @finally {
        }
        return object;
    }
    return nil;
}

@end

@implementation NSFileManager(HTFileExist)

+ (BOOL)ht_createDirectoryIfNotExist:(NSString *)directory
{
    NSFileManager *fileManager = FILEMANAGER;
    
    BOOL isDir = NO;
    BOOL isExists = [fileManager fileExistsAtPath:directory isDirectory:&isDir];
    
    if (!(isExists && isDir)) {
        
        BOOL result = [fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
        
        return result;
    }
    
    return YES;
    
}

+ (BOOL)ht_existItemAtPath:(NSString*)path
{
    if ([path length] == 0)
        return NO;
    
    NSFileManager *fm = FILEMANAGER;
    
    BOOL result = [fm fileExistsAtPath:path];
    
    return result;
}


- (BOOL)ht_buildFolderPath:(NSString *)path error:(NSError **)error
{
    BOOL isDirectory = NO;
    BOOL exists = [FILEMANAGER fileExistsAtPath:path isDirectory:&isDirectory];
    if (exists)
    {
        if (!isDirectory)
        {
            [FILEMANAGER removeItemAtPath:path error:NULL];
            return [FILEMANAGER createDirectoryAtPath:path
                          withIntermediateDirectories:NO
                                           attributes:nil
                                                error:error];
        }
        else
        {
            return YES;
        }
    }
    else
    {
        NSString *parent = [path stringByDeletingLastPathComponent];
        if ([self ht_buildFolderPath:parent error:error])
        {
            return [FILEMANAGER createDirectoryAtPath:path
                          withIntermediateDirectories:NO
                                           attributes:nil
                                                error:error];
        }
    }
    return NO;
}


+ (NSString *) ht_pathForItemNamed: (NSString *) fname inFolder: (NSString *) path
{
    NSString *itemPath = [path stringByAppendingPathComponent:fname];
    if (![FILEMANAGER fileExistsAtPath:itemPath])
    {
        return nil;
    }
    return itemPath;
    
    
    NSString *file = nil;
    NSDirectoryEnumerator *dirEnum = [[NSFileManager defaultManager] enumeratorAtPath:path];
    while ((file = [dirEnum nextObject]))
    {
        if ([[file lastPathComponent] isEqualToString:fname])
        {
            return [path stringByAppendingPathComponent:file];
        }
    }
    return nil;
}

+ (NSString *) ht_pathForDocumentNamed: (NSString *) fname
{
    return [NSFileManager ht_pathForItemNamed:fname inFolder:ht_NSDocumentsFolder()];
}

+ (NSString *) ht_pathForBundleDocumentNamed: (NSString *) fname
{
    return [NSFileManager ht_pathForItemNamed:fname inFolder:ht_NSBundleFolder()];
}

+ (NSArray *) ht_filesInFolder: (NSString *) path
{
    NSString *file;
    NSMutableArray *results = [NSMutableArray array];
    NSDirectoryEnumerator *dirEnum = [FILEMANAGER enumeratorAtPath:path];
    while ((file = [dirEnum nextObject]))
    {
        BOOL isDir;
        [[NSFileManager defaultManager] fileExistsAtPath:[path stringByAppendingPathComponent:file] isDirectory: &isDir];
        if (!isDir)
        {
            [results addObject:file];
        }
    }
    return results;
}

// Case insensitive compare, with deep enumeration
+ (NSArray *) ht_pathsForItemsMatchingExtension: (NSString *) ext inFolder: (NSString *) path
{
    NSString *file;
    NSMutableArray *results = [NSMutableArray array];
    NSDirectoryEnumerator *dirEnum = [FILEMANAGER enumeratorAtPath:path];
    while ((file = [dirEnum nextObject]))
    {
        if ([[file pathExtension] caseInsensitiveCompare:ext] == NSOrderedSame)
        {
            [results addObject:[path stringByAppendingPathComponent:file]];
        }
    }
    return results;
}

+ (NSArray *) ht_pathsForDocumentsMatchingExtension: (NSString *) ext
{
    return [NSFileManager ht_pathsForItemsMatchingExtension:ext inFolder:ht_NSDocumentsFolder()];
}

// Case insensitive compare
+ (NSArray *) ht_pathsForBundleDocumentsMatchingExtension: (NSString *) ext
{
    return [NSFileManager ht_pathsForItemsMatchingExtension:ext inFolder:ht_NSBundleFolder()];
}
@end

@implementation NSFileManager (HTCrypto)
+ (NSString *)ht_fileMD5HashCreateWithPath:(NSString*)filePath
{
    return [self ht_fileMD5HashCreateWithPath:(CFStringRef)filePath ChunkSize:FileHashDefaultChunkSizeForReadingData];
}

+ (NSString *)ht_fileMD5HashCreateWithPath:(CFStringRef)filePath ChunkSize:(size_t)chunkSizeForReadingData {
    
    // Declare needed variables
    NSString *result = nil;
    CFReadStreamRef readStream = nil;
    
    // Get the file URL
    CFURLRef fileURL =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)filePath,
                                  kCFURLPOSIXPathStyle,
                                  (Boolean)false);
    if (!fileURL) goto done;
    
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }
    
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,
                                                  (UInt8 *)buffer,
                                                  (CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject,
                      (const void *)buffer,
                      (CC_LONG)readBytesCount);
    }
    
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    /*
     result = CFStringCreateWithCString(kCFAllocatorDefault,
     (const char *)hash,
     kCFStringEncodingUTF8);
     */
    
    result = [NSString stringWithUTF8String:hash];
    
done:
    
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    return result;
}
+ (NSString *)ht_fileSHA1HashCreateWithPath:(NSString*)filePath
{
    return [self ht_fileSHA1HashCreateWithPath:(CFStringRef)filePath ChunkSize:FileHashDefaultChunkSizeForReadingData];
}

// sha1_file stream
+ (NSString *)ht_fileSHA1HashCreateWithPath:(CFStringRef)filePath ChunkSize:(size_t)chunkSizeForReadingData {
    
    // Declare needed variables
    NSString *result = nil;
    CFReadStreamRef readStream = nil;
    
    // Get the file URL
    CFURLRef fileURL =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)filePath,
                                  kCFURLPOSIXPathStyle,
                                  (Boolean)false);
    if (!fileURL) goto done;
    
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    
    // Initialize the hash object
    CC_SHA1_CTX hashObject;
    CC_SHA1_Init(&hashObject);
    
    // Make sure chunkSizeForReadingData is valid
    if (!chunkSizeForReadingData) {
        chunkSizeForReadingData = FileHashDefaultChunkSizeForReadingData;
    }
    
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[chunkSizeForReadingData];
        CFIndex readBytesCount = CFReadStreamRead(readStream,
                                                  (UInt8 *)buffer,
                                                  (CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_SHA1_Update(&hashObject,
                       (const void *)buffer,
                       (CC_LONG)readBytesCount);
    }
    
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    
    // Compute the hash digest
    unsigned char digest[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1_Final(digest, &hashObject);
    
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    /*
     result = CFStringCreateWithCString(kCFAllocatorDefault,
     (const char *)hash,
     kCFStringEncodingUTF8);
     */
    
    result = [NSString stringWithUTF8String:hash];
    
done:
    
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    return result;
}


@end
