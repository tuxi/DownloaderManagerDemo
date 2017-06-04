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
@property (nonatomic, strong) NSProgress *progress;

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
        
        self.progress = [[NSProgress alloc] initWithParent:[NSProgress currentProgress] userInfo:nil];
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
            self.progress.kind = NSProgressKindFile;
            [self.progress setUserInfoObject:NSProgressFileOperationKindKey forKey:NSProgressFileOperationKindDownloading];
            [self.progress setUserInfoObject:downloadToken forKey:@"downloadToken"];
            self.progress.cancellable = YES;
            self.progress.pausable = YES;
            self.progress.totalUnitCount = NSURLSessionTransferSizeUnknown;
            self.progress.completedUnitCount = 0;
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
            self.progress.totalUnitCount = expectedFileTotalSize;
        }
    }
}

- (void)setReceivedFileSize:(int64_t)receivedFileSize {
    
    _receivedFileSize = receivedFileSize;
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1) {
        if (receivedFileSize > 0) {
            if (self.expectedFileTotalSize > 0) {
                self.progress.completedUnitCount = receivedFileSize;
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
    [aDescriptionDict setObject:self.progress forKey:@"progress"];
    if (self.sessionDownloadTask) {
        [aDescriptionDict setObject:@(YES) forKey:@"hasSessionDownloadTask"];
    }
    NSString *aDescriptionString = [NSString stringWithFormat:@"%@", aDescriptionDict];
    
    return aDescriptionString;
}

@end
