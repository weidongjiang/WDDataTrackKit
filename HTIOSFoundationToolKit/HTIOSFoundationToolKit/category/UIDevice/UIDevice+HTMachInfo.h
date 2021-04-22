//
//  UIDevice+HTMachInfo.h
//  HTIOSFoundationToolKit
//
//  Created by 伟东 on 2020/7/22.
//  Copyright © 2020 伟东. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (HTMachInfo)

/*!
 *  获取当前设备的CPU型号，例如ARM，ppc(PowerPC),I386
 *
 *  @return 返回当前设备的CPU型号，例如ARM，ppc(PowerPC),I386
 */
const char* ht_w_mach_currentCPUArch(void);

/*!
 *  获取当前imageName名称的动态链接库对应的uint32_t类型编号，不存在则返回UINT32_MAX
 *
 *
 *  @param imageName  需要查找的dylib名称
 *  @param exactMatch 一个布尔类型的值，Yes：表示需要查找的库名和所给的完全相等
 *                    No:使用包含所给参数的库名的方式来查找
 *
 *  @return 返回一个uint32_t类型的值
 */
uint32_t ht_w_mach_imageNamed(const char* const imageName, bool exactMatch);

/*!
 *  获取用于标记 dSYM file 的 UUID.
 *
 *
 *  @param imageName  需要查找的dylib名称
 *  @param exactMatch 一个布尔类型的值，Yes：表示需要查找的库名和所给的完全相等
 *                    No:使用包含所给参数的库名的方式来查找
 *
 *  @return 返回用于标记 dSYM file 的 UUID
 */
const uint8_t* ht_w_mach_imageUUID(const char* const imageName, bool exactMatch);

/*!
 *  获取用于mach-O 文件的 mach_header.
 *
 *
 *  @param imageName  需要查找的dylib名称
 *  @param exactMatch 一个布尔类型的值，Yes：表示需要查找的库名和所给的完全相等
 *                    No:使用包含所给参数的库名的方式来查找
 *
 *  @return 返回mach-O 文件的 mach_header
 */
const uintptr_t ht_w_mach_imageAddress(const char* const imageName, bool exactMatch);

/*!
 *  获取当前线程的Index
 *
 *  @return 获取当前线程的Index
 */
unsigned int ht_w_mach_crashedThreadIndex(void);

struct timeval ht_w_sysctl_timevalForName(const char* const name);

@end

NS_ASSUME_NONNULL_END
