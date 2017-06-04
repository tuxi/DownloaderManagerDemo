//
//  SampleDownloadModule.h
//  DownloaderManager
//
//  Created by Ossey on 2017/6/4.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OSDownloadProtocol.h"

/*
 此类遵守了OSDownloadProtocol，作为OSDownloaderManager的代理类
 */

@class SampleDownloadItem;

@interface SampleDownloadModule : NSObject <OSDownloadProtocol>

@property (nonatomic, strong, readonly) NSMutableArray<SampleDownloadItem *> *downloadItems;

- (void)start:(SampleDownloadItem *)downloadItem;
- (void)cancel:(SampleDownloadItem *)downloadItem;
- (void)resume:(SampleDownloadItem *)downloadItem;

@end
