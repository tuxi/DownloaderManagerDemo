//
//  OSDownloaderManager.h
//  DownloaderManager
//
//  Created by Ossey on 2017/6/4.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSDownloadProtocol.h"
#import "OSDownloadProgress.h"

typedef void(^OSBackgroundSessionCompletionHandler)();
typedef void (^OSDownloaderPauseResumeDataHandler)(NSData * aResumeData);

@interface OSDownloaderManager : NSObject

#pragma mark - initialize

/// 初始化OSDownloaderManager
/// @param aDelegate 下载事件的代理对象，需遵守OSDownloadProtocol协议
/// @return OSDownloaderManager初始化的对象
- (instancetype)initWithDelegate:(id<OSDownloadProtocol>)aDelegate;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;

/// 初始化OSDownloaderManager
/// @param aDelegate 下载事件的代理对象，需遵守OSDownloadProtocol协议
/// @param maxConcurrentDownloads 同时并发最大的下载数量，default 没有限制
/// @return OSDownloaderManager初始化的对象
- (instancetype)initWithDelegate:(id<OSDownloadProtocol>)aDelegate
      maxConcurrentDownloadCount:(NSInteger)maxConcurrentDownloads NS_DESIGNATED_INITIALIZER;

/// 设置下载成功的回调
- (void)setCompletionHandler:(void (^)())completionHandler;

#pragma mark - download

/// 调用此方法，执行开始下载任务
/// @param downloadToken 下载任务的唯一标识符
/// @param aRemoteURL 下载任务的服务器url
- (void)startDownloadWithDownloadToken:(NSString *)downloadToken remoteURL:(NSURL *)aRemoteURL;

/// 调用此方法，从之前下载数据继续下载任务
/// @param downloadToken 下载任务的唯一标识符
/// @param aResumeData 之前下载的数据
- (void)startDownloadWithDownloadToken:(NSString *)downloadToken resumeData:(NSData *)aResumeData;

/// 根据是否downloadToken判断正在下载中
/// @param downloadToken 下载任务的唯一标识符
- (BOOL)isDownloadingByDownloadToken:(NSString *)downloadToken;

/// 根据是否downloadToken判断在等待中
/// @param downloadToken 下载任务的唯一标识符
- (BOOL)isWaitingByDownloadToken:(NSString *)downloadToken;

/// 当前是否有任务正在下载中
- (BOOL)hasActiveDownloads;

/// 取消下载
/// @param downloadToken 下载任务的唯一标识符
- (void)cancelWithDownloadToken:(NSString *)downloadToken;

#pragma mark - Background session completionHandler

/// 当完成一个后台任务时回调
- (void)setBackgroundSessionCompletionHandler:(OSBackgroundSessionCompletionHandler)completionHandler;


#pragma mark - Progress

/// 获取下载进度
/// aIdentifier 当前下载任务的唯一标识符
/// @return 下载进度的信息
- (OSDownloadProgress *)downloadProgressByDownloadToken:(NSString *)downloadToken;
@end
