//
//  SampleDownloadItem.h
//  DownloaderManager
//
//  Created by Ossey on 2017/6/5.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSDownloadProgress.h"

typedef NS_ENUM(NSUInteger, SampleDownloadItemStatus) {
    SampleDownloadItemStatusNotStarted = 0,
    SampleDownloadItemStatusStarted,
    SampleDownloadItemStatusCompleted,
    SampleDownloadItemStatusPaused,
    SampleDownloadItemStatusCancelled,
    SampleDownloadItemStatusInterrupted,
    SampleDownloadItemStatusError
};

@interface SampleDownloadItem : NSObject


@property (nonatomic, strong, readonly) NSString *downloadIdentifier;
@property (nonatomic, strong, readonly) NSURL *remoteURL;

@property (nonatomic, strong) NSData *resumeData;
@property (nonatomic, assign) SampleDownloadItemStatus status;

@property (nonatomic, strong) OSDownloadProgress *progress;

@property (nonatomic, strong) NSError *downloadError;
@property (nonatomic, strong) NSArray<NSString *> *downloadErrorMessagesStack;
@property (nonatomic, assign) NSInteger lastHttpStatusCode;

- (instancetype)initWithDownloadIdentifier:(NSString *)downloadIdentifier
                                 remoteURL:(NSURL *)remoteURL NS_DESIGNATED_INITIALIZER;

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_DESIGNATED_INITIALIZER;


@end
