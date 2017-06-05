//
//  OSDownloadItem.m
//  DownloaderManager
//
//  Created by Ossey on 2017/6/4.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "OSDownloadItem.h"

@interface OSDownloadItem ()

@property (nonatomic, copy) NSString *downloadToken;
@property (nonatomic, strong) NSURLSessionDownloadTask *sessionDownloadTask;
@property (nonatomic, strong) NSProgress *naviteProgress;

@end

@implementation OSDownloadItem

#pragma mark - initialize

- (instancetype)init {
    
    NSAssert(NO, @"use initWithDownloadProgress:expectedFileSize:receivedFileSize:estimatedRemainingTime:bytesPerSecondSpeed:nativeProgress:");
    @throw nil;
}
+ (instancetype)new {
    NSAssert(NO, @"use initWithDownloadProgress:expectedFileSize:receivedFileSize:estimatedRemainingTime:bytesPerSecondSpeed:nativeProgress:");
    @throw nil;
}

- (instancetype)initWithDownloadToken:(NSString *)downloadToken
                  sessionDownloadTask:(NSURLSessionDownloadTask *)sessionDownloadTask {
    if (self = [super init]) {
        self.downloadToken = downloadToken;
        self.sessionDownloadTask = sessionDownloadTask;
        self.receivedFileSize = 0;
        self.expectedFileTotalSize = 0;
        self.bytesPerSecondSpeed = 0;
        self.resumedFileSizeInBytes = 0;
        self.lastHttpStatusCode = 0;
        
        self.naviteProgress = [[NSProgress alloc] initWithParent:[NSProgress currentProgress] userInfo:nil];
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            self.naviteProgress.kind = NSProgressKindFile;
            [self.naviteProgress setUserInfoObject:NSProgressFileOperationKindKey forKey:NSProgressFileOperationKindDownloading];
            [self.naviteProgress setUserInfoObject:downloadToken forKey:@"downloadToken"];
            self.naviteProgress.cancellable = YES;
            self.naviteProgress.pausable = YES;
            self.naviteProgress.totalUnitCount = NSURLSessionTransferSizeUnknown;
            self.naviteProgress.completedUnitCount = 0;
        }
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        
    }
    return self;
}


#pragma mark - set

- (void)setExpectedFileTotalSize:(int64_t)expectedFileTotalSize {
    
    _expectedFileTotalSize = expectedFileTotalSize;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        if (expectedFileTotalSize > 0) {
            self.naviteProgress.totalUnitCount = expectedFileTotalSize;
        }
    }
}

- (void)setReceivedFileSize:(int64_t)receivedFileSize {
    
    _receivedFileSize = receivedFileSize;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        if (receivedFileSize > 0) {
            if (self.expectedFileTotalSize > 0) {
                self.naviteProgress.completedUnitCount = receivedFileSize;
            }
        }
    }
}


#pragma mark - description


- (NSString *)description {
    
    NSMutableDictionary *aDescriptionDict = [NSMutableDictionary dictionary];
    [aDescriptionDict setObject:@(self.receivedFileSize) forKey:@"receivedFileSize"];
    [aDescriptionDict setObject:@(self.expectedFileTotalSize) forKey:@"expectedFileTotalSize"];
    [aDescriptionDict setObject:@(self.bytesPerSecondSpeed) forKey:@"bytesPerSecondSpeed"];
    [aDescriptionDict setObject:self.downloadToken forKey:@"downloadToken"];
    [aDescriptionDict setObject:self.naviteProgress forKey:@"naviteProgress"];
    if (self.sessionDownloadTask) {
        [aDescriptionDict setObject:@(YES) forKey:@"hasSessionDownloadTask"];
    }
    NSString *aDescriptionString = [NSString stringWithFormat:@"%@", aDescriptionDict];
    
    return aDescriptionString;
}

@end
