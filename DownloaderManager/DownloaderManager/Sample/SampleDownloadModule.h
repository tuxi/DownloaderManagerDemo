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


@protocol SampleDownloaderDataSource <NSObject>

@optional
/// 需要下载的任务, 默认按照url在数组中的索引顺序下载
/// @return 所有需要下载的url 字符串
- (NSArray<NSString *> *)addDownloadTaskFromRemoteURLs;

@end

@protocol SampleDownloaderDelegate <NSObject>

@optional
/// 下载之前对在当前网络下载的授权，默认为YES, 可在此方法中提示用户当前网络状态
- (BOOL)shouldDownloadTaskInCurrentNetworkWithCompletionHandler:(void (^)(BOOL shouldDownload))completionHandler;

@end

/*
 此类遵守了OSDownloadProtocol，作为OSDownloaderManager的协议实现类
 主要对下载状态的更新、下载进度的更新、发送通知、下载信息的规则
 */

FOUNDATION_EXTERN NSString * const SampleDownloadProgressChangeNotification;
FOUNDATION_EXTERN NSString * const SampleDownloadSussessNotification;
FOUNDATION_EXTERN NSString * const SampleDownloadFailureNotification;
FOUNDATION_EXTERN NSString * const SampleDownloadCanceldNotification;

@class SampleDownloadItem;

@interface SampleDownloadModule : NSObject <OSDownloadProtocol>

@property (nonatomic, strong, readonly) NSMutableArray<SampleDownloadItem *> *downloadItems;

@property (nonatomic, weak) id<SampleDownloaderDataSource> dataSource;
@property (nonatomic, weak) id<SampleDownloaderDelegate> delegate;

- (void)start:(SampleDownloadItem *)downloadItem;
- (void)cancel:(NSString *)url;
- (void)resume:(NSString *)url;
- (void)pause:(NSString *)url;
+ (NSArray<SampleDownloadItem *> *)getDownloadItems;
+ (OSDownloaderManager *)getDownloadManager;
- (void)clearAllDownloadTask;

@end
