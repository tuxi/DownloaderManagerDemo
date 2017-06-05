//
//  SampleDownloadModule.h
//  DownloaderManager
//
//  Created by Ossey on 2017/6/4.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSDownloadProtocol.h"

@class OSDownloaderManager;
/*
 此类遵守了OSDownloadProtocol，作为OSDownloaderManager的协议实现类
 主要对下载状态的更新、下载进度的更新、发送通知、下载信息的规则
 */

FOUNDATION_EXTERN NSString * const SampleDownloadProgressChangeNotification;
FOUNDATION_EXTERN NSString * const SampleDownloadSussessNotification;
FOUNDATION_EXTERN NSString * const SampleDownloadFailureNotification;


@class SampleDownloadItem;

@interface SampleDownloadModule : NSObject <OSDownloadProtocol>

@property (nonatomic, strong, readonly) NSMutableArray<SampleDownloadItem *> *downloadItems;

- (void)start:(SampleDownloadItem *)downloadItem;
- (void)cancel:(NSString *)downloadIdentifier;
- (void)resume:(NSString *)downloadIdentifier;
+ (NSArray<SampleDownloadItem *> *)getDownloadItems;
+ (OSDownloaderManager *)getDownloadManager;

@end
