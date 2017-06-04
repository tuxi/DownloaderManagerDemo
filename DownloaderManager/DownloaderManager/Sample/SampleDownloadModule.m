//
//  SampleDownloadModule.m
//  DownloaderManager
//
//  Created by Ossey on 2017/6/4.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "SampleDownloadModule.h"
#import "SampleDownloadItem.h"
#import "AppDelegate.h"
#import "OSDownloaderManager.h"

static NSString * SampleDownloadItemsKey = @"downloadItems";

static void *ProgressObserverContext = &ProgressObserverContext;

@interface SampleDownloadModule()

@property (nonatomic, assign) NSUInteger networkActivityIndicatorCount;
@property (nonatomic, strong) NSMutableArray<SampleDownloadItem *> *downloadItems;;
@property (nonatomic, strong) NSProgress *progress;
@end


@implementation SampleDownloadModule

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.networkActivityIndicatorCount = 0;
        self.progress = [NSProgress progressWithTotalUnitCount:0];
        [self.progress addObserver:self
                        forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                           options:NSKeyValueObservingOptionNew
                           context:ProgressObserverContext];
        
        [self setupDownloadItems];
    }
    return self;
}

- (void)setupDownloadItems {
    NSMutableArray<SampleDownloadItem *> *downloadItems = [self restoredDownloadItems];
    
    NSInteger maxCount = 11;
    
    for (NSInteger i = 0; i < maxCount; i++) {
        
        NSString *downloadToken = [NSString stringWithFormat:@"%ld", i];
        // 查找数组中第一个符合条件的对象（代码块过滤），返回对应索引
        // 查找downloadToken在downloadItems中对应的OSDownloadItem的索引
        NSInteger downloadItemIdx = [self.downloadItems indexOfObjectPassingTest:^BOOL(SampleDownloadItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj.downloadIdentifier isEqualToString:downloadToken]) {
                return YES;
            }
            return NO;
        }];
        
        if (downloadItemIdx == NSNotFound) {
            NSURL *remoteURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://www.imagomat.de/testimages/%@.tiff", @(i)]];
            if ([downloadToken isEqualToString:@"4"]){
                remoteURL = [NSURL URLWithString:@"http://www.imagomat.de/testimages/900.tiff"];
            }
            SampleDownloadItem *downloadItem = [[SampleDownloadItem alloc] initWithDownloadIdentifier:downloadToken remoteURL:remoteURL];
            [self.downloadItems addObject:downloadItem];
        } else {
            
            SampleDownloadItem *downloadItem = [self.downloadItems objectAtIndex:downloadItemIdx];
            if (downloadItem.status == SampleDownloadItemStatusStarted)
            {
                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                BOOL isDownloading = [appDelegate.downloadManager isDownloadingByDownloadToken:downloadItem.downloadIdentifier];
                if (isDownloading == NO) {
                    downloadItem.status = SampleDownloadItemStatusInterrupted;
                }
            }

        }
    }
    
    [self storedDownloadItems];
    
   self.downloadItems = [[self.downloadItems sortedArrayUsingComparator:^NSComparisonResult(SampleDownloadItem *  _Nonnull obj1, SampleDownloadItem *  _Nonnull obj2) {
        return [obj1.downloadIdentifier compare:obj2.downloadIdentifier options:NSNumericSearch];
    }] mutableCopy];
}

#pragma mark - Private

/// 从本地获取所有的downloadItem
- (NSMutableArray<SampleDownloadItem *> *)restoredDownloadItems {
    
    NSMutableArray<SampleDownloadItem *> *restoredDownloadItems = [NSMutableArray array];
    NSMutableArray<NSData *> *restoredMutableDataArray = [[NSUserDefaults standardUserDefaults] objectForKey:SampleDownloadItemsKey];
    if (!restoredMutableDataArray) {
        restoredMutableDataArray = [NSMutableArray array];
    }
    
    [restoredMutableDataArray enumerateObjectsUsingBlock:^(NSData * _Nonnull data, NSUInteger idx, BOOL * _Nonnull stop) {
        SampleDownloadItem *item = nil;
        if (data) {
            @try {
                // 解档
               item = [NSKeyedUnarchiver unarchiveObjectWithData:data];
            }
            
            @catch (NSException *exception) {
                @throw [NSException exceptionWithName:NSExtensionItemAttachmentsKey reason:@"NSKeyedUnarchiver data is nil" userInfo:nil];
            }
            
            @finally {
            
            }
        }
        if (item) {
            [restoredDownloadItems addObject:item];
        }
       
    }];
    
    return restoredDownloadItems;
}

/// 归档items
- (void)storedDownloadItems {
    
    NSMutableArray<NSData *> *downloadItemsArchiveArray = [NSMutableArray arrayWithCapacity:self.downloadItems.count];
    
    [self.downloadItems enumerateObjectsUsingBlock:^(SampleDownloadItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        NSData *itemData = [NSKeyedArchiver archivedDataWithRootObject:obj];
        if (itemData) {
            [downloadItemsArchiveArray addObject:itemData];
        }
    }];
    
    [[NSUserDefaults standardUserDefaults] setObject:downloadItemsArchiveArray forKey:SampleDownloadItemsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}




@end
