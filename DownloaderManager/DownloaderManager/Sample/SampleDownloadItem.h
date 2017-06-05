//
//  SampleDownloadItem.h
//  DownloaderManager
//
//  Created by Ossey on 2017/6/5.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSDownloadProgress.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, SampleDownloadItemStatus) {
    /// 未开始
    SampleDownloadItemStatusNotStarted = 0,
    /// 已经开始
    SampleDownloadItemStatusStarted,
    /// 完成
    SampleDownloadItemStatusCompleted,
    /// 暂停
    SampleDownloadItemStatusPaused,
    /// 已取消
    SampleDownloadItemStatusCancelled,
    /// 终端
    SampleDownloadItemStatusInterrupted,
    /// 失败
    SampleDownloadItemStatusError
};

@interface SampleDownloadItem : NSObject


@property (nonatomic, strong, readonly) NSString *downloadIdentifier;
@property (nonatomic, strong, readonly) NSURL *remoteURL;

@property (nonatomic, strong) NSData *resumeData;
@property (nonatomic, assign) SampleDownloadItemStatus status;

@property (nonatomic, strong) OSDownloadProgress *progressObj;

@property (nonatomic, strong) NSError *downloadError;
@property (nonatomic, strong) NSArray<NSString *> *downloadErrorMessagesStack;
@property (nonatomic, assign) NSInteger lastHttpStatusCode;

- (instancetype)initWithDownloadIdentifier:(NSString *)downloadIdentifier
                                 remoteURL:(NSURL *)remoteURL NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;


@end

NS_ASSUME_NONNULL_END
