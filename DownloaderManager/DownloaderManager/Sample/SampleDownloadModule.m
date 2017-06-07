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
NSString * const SampleDownloadProgressChangeNotification = @"SampleDownloadProgressChangeNotification";
NSString * const SampleDownloadSussessNotification = @"SampleDownloadSussessNotification";
NSString * const SampleDownloadFailureNotification = @"SampleDownloadFailureNotification";

@interface SampleDownloadModule()

@property (nonatomic, assign) NSUInteger networkActivityIndicatorCount;
@property (nonatomic, strong) NSMutableArray<SampleDownloadItem *> *downloadItems;;
@property (nonatomic, strong) NSProgress *progress;

@end


@implementation SampleDownloadModule

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~ initialize ~~~~~~~~~~~~~~~~~~~~~~

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.networkActivityIndicatorCount = 0;
        // 创建任务进度管理对象 UnitCount是一个基于UI上的完整任务的单元数
        // 这个方法创建了一个NSProgress实例作为当前实例的子类，以要执行的任务单元总数来初始化
        self.progress = [NSProgress progressWithTotalUnitCount:0];
        // 对任务进度对象的完成比例进行监听:监听progress的fractionCompleted的改变,
        // NSKeyValueObservingOptionInitial观察最初的值（在注册观察服务时会调用一次触发方法）
        // fractionCompleted的返回值是0到1，显示了任务的整体进度。如果当没有子实例的话，fractionCompleted就是简单的完成任务数除以总得任务数。
        [self.progress addObserver:self
                        forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                           options:NSKeyValueObservingOptionInitial
                           context:ProgressObserverContext];
        
        [self setupDownloadItems];
    }
    return self;
}

- (void)setupDownloadItems {
    self.downloadItems = [self restoredDownloadItems];
    
    /// 设置所有要下载的url,根据url创建SampleDownloadItem
    [[self getImageUrls] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *downloadToken = [NSString stringWithFormat:@"%ld", idx];
        // 下载之前先去downloadItems中查找有没有相同的downloadToken，如果有就是已经添加过的
        NSInteger downloadItemIdx = [self foundItemIndxInDownloadItemsByIdentifier:downloadToken];
        if (downloadItemIdx == NSNotFound) {
            // 之前没下载过
            NSURL *remoteURL = [NSURL URLWithString:obj];
            SampleDownloadItem *downloadItem = [[SampleDownloadItem alloc] initWithDownloadIdentifier:downloadToken remoteURL:remoteURL];
            [self.downloadItems addObject:downloadItem];
        } else {
            // 之前下载过
            SampleDownloadItem *downloadItem = [self.downloadItems objectAtIndex:downloadItemIdx];
            if (downloadItem.status == SampleDownloadStatusStarted) {
                BOOL isDownloading = [[[self class] getDownloadManager] isDownloadingByDownloadToken:downloadItem.downloadIdentifier];
                if (isDownloading == NO) {
                    downloadItem.status = SampleDownloadStatusInterrupted;
                }
            }
            
        }
    }];
    
    [self storedDownloadItems];
    
    // 对downloadItems中的任务进行排序
    self.downloadItems = [[self.downloadItems sortedArrayUsingComparator:^NSComparisonResult(SampleDownloadItem *  _Nonnull obj1, SampleDownloadItem *  _Nonnull obj2) {
        return [obj1.downloadIdentifier compare:obj2.downloadIdentifier options:NSNumericSearch];
    }] mutableCopy];
}




#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Public~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- (void)start:(SampleDownloadItem *)downloadItem {
    
    // 有新的下载任务时重置下载进度
    [self resetProgressIfNoActiveDownloadsRunning];
    
    if ((downloadItem.status != SampleDownloadStatusCancelled) && (downloadItem.status != SampleDownloadStatusSuccess)) {
        BOOL isDownloading = [[[self class] getDownloadManager] isDownloadingByDownloadToken:downloadItem.downloadIdentifier];
        if (isDownloading == NO){
            downloadItem.status = SampleDownloadStatusStarted;
            
            // 开始下载前对所有下载的信息进行归档
            [self storedDownloadItems];
            
            // 开始下载
            if (downloadItem.resumeData.length > 0) {
                // 从上次下载位置继续下载
                [[[self class] getDownloadManager] startDownloadWithDownloadToken:downloadItem.downloadIdentifier resumeData:downloadItem.resumeData];
            } else {
                // 从url下载新的任务
                [[[self class] getDownloadManager] startDownloadWithDownloadToken:downloadItem.downloadIdentifier remoteURL:downloadItem.remoteURL];
            }
        }
    }
}

- (void)cancel:(NSString *)downloadIdentifier {
    /// 根据downloadIdentifier 在self.downloadItems中找到对应的item
    NSUInteger itemIdx = [self foundItemIndxInDownloadItemsByIdentifier:downloadIdentifier];
    if (itemIdx != NSNotFound) {
        // 根据索引在self.downloadItems中取出SampleDownloadItem，修改状态，并进行归档
        SampleDownloadItem *downloadItem = [self.downloadItems objectAtIndex:itemIdx];
        downloadItem.status = SampleDownloadStatusCancelled;
        // 将其从downloadItem中移除，并重新归档
        [self.downloadItems removeObject:downloadItem];
        [self storedDownloadItems];
    }
    else {
        NSLog(@"ERR: Cancelled download item not found (id: %@) (%@, %d)", downloadIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
    }
}

- (void)resume:(NSString *)downloadIdentifier {
    // 重置下载进度
    [self resetProgressIfNoActiveDownloadsRunning];
    
    NSUInteger foundItemIdx = [self foundItemIndxInDownloadItemsByIdentifier:downloadIdentifier];
    if (foundItemIdx != NSNotFound) {
        SampleDownloadItem *downloadItem = [self.downloadItems objectAtIndex:foundItemIdx];
        if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_4) {
            // iOS9以上执行NSProgress 的 resume，resumingHandler会得到回调
            // OSDownloaderManager中已经对其回调时使用了执行了恢复任务
            if (downloadItem.progressObj.nativeProgress) {
                [downloadItem.progressObj.nativeProgress resume];
            } else {
                [self start:downloadItem];
            }
        } else {
            [self start:downloadItem];
        }
    }
    
}

- (void)pause:(NSString *)identifier {
    
    NSUInteger foundItemIdx = [self foundItemIndxInDownloadItemsByIdentifier:identifier];
    if (foundItemIdx != NSNotFound) {
        SampleDownloadItem *downloadItem = [self.downloadItems objectAtIndex:foundItemIdx];
        BOOL isDownloading = [[[self class] getDownloadManager] isDownloadingByDownloadToken:downloadItem.downloadIdentifier];
        if (isDownloading) {
            downloadItem.status = SampleDownloadStatusPaused;
            
            // 暂停前前对所有下载的信息进行归档
            [self storedDownloadItems];
            
            if (downloadItem.progressObj.nativeProgress) {
                [downloadItem.progressObj.nativeProgress pause];
            }
        }
    }
}

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~ <OSDownloadProtocol> ~~~~~~~~~~~~~~~~~~~~~~~


- (void)downloadSuccessnWithIdentifier:(NSString *)aIdentifier finalLocalFileURL:(NSURL *)aFileURL {
    
    // 根据aIdentifier在downloadItems中查找对应的DownloadItem，更改其下载状态，发送通知
    NSUInteger foundItemIdx = [self foundItemIndxInDownloadItemsByIdentifier:aIdentifier];    SampleDownloadItem *downloadItem = nil;
    if (foundItemIdx != NSNotFound) {
        NSLog(@"INFO: Download success (id: %@) (%@, %d)", aIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
        
        downloadItem = [self.downloadItems objectAtIndex:foundItemIdx];
        downloadItem.status = SampleDownloadStatusSuccess;
        downloadItem.localFileURL = aFileURL;
        [self storedDownloadItems];
    } else {
        NSLog(@"Error: Completed download item not found (id: %@) (%@, %d)", aIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SampleDownloadSussessNotification object:downloadItem];
}

- (void)downloadFailureWithIdentifier:(NSString *)aIdentifier error:(NSError *)anError httpStatusCode:(NSInteger)aHttpStatusCode errorMessagesStack:(NSArray<NSString *> *)anErrorMessagesStack resumeData:(NSData *)aResumeData {
    
    // 根据aIdentifier在downloadItems中查找对应的DownloadItem
    NSUInteger foundItemIdx = [self foundItemIndxInDownloadItemsByIdentifier:aIdentifier];
    SampleDownloadItem *downloadItem = nil;
    if (foundItemIdx != NSNotFound) {
        downloadItem = [self.downloadItems objectAtIndex:foundItemIdx];
        downloadItem.lastHttpStatusCode = aHttpStatusCode;
        downloadItem.resumeData = aResumeData;
        downloadItem.downloadError = anError;
        downloadItem.downloadErrorMessagesStack = anErrorMessagesStack;
        
        // 更新此下载失败的item的状态
        if (downloadItem.status != SampleDownloadStatusPaused) {
            if (aResumeData.length > 0)
            {
                downloadItem.status = SampleDownloadStatusInterrupted;
            } else if ([anError.domain isEqualToString:NSURLErrorDomain] && (anError.code == NSURLErrorCancelled))
            {
                downloadItem.status = SampleDownloadStatusCancelled;
            } else
            {
                downloadItem.status = SampleDownloadStatusFailure;
            }
        }
        [self storedDownloadItems];
        
        switch (downloadItem.status) {
            case SampleDownloadStatusFailure:
                NSLog(@"ERR: Download with error %@ (http status: %@) - id: %@ (%@, %d)", @(anError.code), @(aHttpStatusCode), aIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
                break;
            case SampleDownloadStatusInterrupted:
                NSLog(@"ERR: Download interrupted with error %@ - id: %@ (%@, %d)", @(anError.code), aIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
                break;
            case SampleDownloadStatusCancelled:
                NSLog(@"INFO: Download cancelled - id: %@ (%@, %d)", aIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
                break;
            case SampleDownloadStatusPaused:
                NSLog(@"INFO: Download paused - id: %@ (%@, %d)", aIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
                break;
                
            default:
                break;
        }
        
    } else {
        NSLog(@"ERR: Failed download item not found (id: %@) (%@, %d)", aIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
    }
    // 发送失败通知
    [[NSNotificationCenter defaultCenter] postNotificationName:SampleDownloadFailureNotification object:downloadItem];
}

- (void)downloadTaskWillBegin {
    [self toggleNetworkActivityIndicatorVisible:YES];
}

- (void)downloadTaskDidEnd {
    [self toggleNetworkActivityIndicatorVisible:NO];
}

- (void)downloadProgressChangeWithIdentifier:(NSString *)anIdentifier progress:(OSDownloadProgress *)progress {
    
    NSUInteger foundItemIdx = [self foundItemIndxInDownloadItemsByIdentifier:anIdentifier];
    
    SampleDownloadItem *downloadItem = nil;
    if (foundItemIdx != NSNotFound) {
        downloadItem = [self.downloadItems objectAtIndex:foundItemIdx];
        if (progress) {
            downloadItem.progressObj = progress;
            downloadItem.progressObj.lastLocalizedDescription = downloadItem.progressObj.nativeProgress.localizedDescription;
            downloadItem.progressObj.lastLocalizedAdditionalDescription = downloadItem.progressObj.nativeProgress.localizedAdditionalDescription;
        }
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:SampleDownloadProgressChangeNotification object:downloadItem];
}

- (void)downloadPausedWithIdentifier:(NSString *)anIdentifier resumeData:(NSData *)aResumeData {
    
    NSUInteger foundItemIdx = [self foundItemIndxInDownloadItemsByIdentifier:anIdentifier];
    
    if (foundItemIdx != NSNotFound) {
        NSLog(@"INFO: Download paused - id: %@ (%@, %d)", anIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
        
        SampleDownloadItem *downloadItem = [self.downloadItems objectAtIndex:foundItemIdx];
        downloadItem.status = SampleDownloadStatusPaused;
        downloadItem.resumeData = aResumeData;
        [self storedDownloadItems];
    } else {
        NSLog(@"Error: Paused download item not found (id: %@) (%@, %d)", anIdentifier, [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
    }
}

- (void)resumeDownloadWithIdentifier:(NSString *)anIdentifier {
    
    // 根据identifier查找item
    NSUInteger foundItemIdx = [self foundItemIndxInDownloadItemsByIdentifier:anIdentifier];
    
    if (foundItemIdx != NSNotFound) {
        SampleDownloadItem *downloadItem = [self.downloadItems objectAtIndex:foundItemIdx];
        [self start:downloadItem];
    }
}

- (BOOL)downloadFinalLocalFileURL:(NSURL *)aLocalFileURL isVaildByDownloadIdentifier:(NSString *)anIdentifier {
    
    // 检测文件大小,项目中有时需要检测下载的文件的类型是否相匹配，这里就仅仅检测文件大小
    // 根据文件的大小判断下载的文件是否有效,比如可以设定当文件超过多少kb就视为无效
    BOOL isValid = YES;
    
    NSError *error = nil;
    NSDictionary *fileAttritubes = [[NSFileManager defaultManager] attributesOfItemAtPath:aLocalFileURL.path error:&error];
    
    if (error) {
        NSLog(@"Error: Error on getting file size for item at %@: %@ (%@, %d)", aLocalFileURL, error.localizedDescription, [NSString stringWithUTF8String:__FILE__], __LINE__);
        isValid = NO;
    } else {
        unsigned long long fileSize = [fileAttritubes fileSize];
        if (fileSize == 0) {
            isValid = NO;
        }
    }
    return isValid;
}

- (NSProgress *)usingNaviteProgress {
    return self.progress;
}


#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~Private store and reStore ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
            } @catch (NSException *exception) {
                @throw exception;
            } @finally {
                
            }
            if (item) {
                [restoredDownloadItems addObject:item];
            }
        }
        
    }];
    
    return restoredDownloadItems;
}

/// 归档items
- (void)storedDownloadItems {
    
    NSMutableArray<NSData *> *downloadItemsArchiveArray = [NSMutableArray arrayWithCapacity:self.downloadItems.count];
    
    [self.downloadItems enumerateObjectsUsingBlock:^(SampleDownloadItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        NSData *itemData = nil;
        @try {
            itemData = [NSKeyedArchiver archivedDataWithRootObject:obj];
        } @catch (NSException *exception) {
            @throw exception;
        } @finally {
            
        }
        if (itemData) {
            [downloadItemsArchiveArray addObject:itemData];
        }
        
    }];
    
    [[NSUserDefaults standardUserDefaults] setObject:downloadItemsArchiveArray forKey:SampleDownloadItemsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)toggleNetworkActivityIndicatorVisible:(BOOL)visible {
    visible ? self.networkActivityIndicatorCount++ : self.networkActivityIndicatorCount--;
    NSLog(@"INFO: NetworkActivityIndicatorCount: %@", @(self.networkActivityIndicatorCount));
    [UIApplication sharedApplication].networkActivityIndicatorVisible = (self.networkActivityIndicatorCount > 0);
}

#pragma mark - ~~~~~NSProgress~~~~~
#pragma mark - ~~~~~Observer~~~~~

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    
    if (context == ProgressObserverContext) {
        // 取出当前的progress
        NSProgress *progress = object;
        if ([keyPath isEqualToString:NSStringFromSelector(@selector(fractionCompleted))]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:SampleDownloadProgressChangeNotification object:progress];
        } else {
            NSLog(@"ERR: Invalid keyPath (%@, %d)", [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
        }
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
    
}

/// 如果当前没有正在下载中的就重置进度
- (void)resetProgressIfNoActiveDownloadsRunning {
    BOOL hasActiveDownloadsFlag = [[[self class] getDownloadManager] hasActiveDownloads];
    if (hasActiveDownloadsFlag == NO) {
        @try {
            [self.progress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted))];
        } @catch (NSException *exception) {
            NSLog(@"Error: Repeated removeObserver(keyPath = fractionCompleted)");
        } @finally {
            
        }
        
        self.progress = [NSProgress progressWithTotalUnitCount:0];
        [self.progress addObserver:self
                        forKeyPath:NSStringFromSelector(@selector(fractionCompleted))
                           options:NSKeyValueObservingOptionInitial
                           context:ProgressObserverContext];
    }
}


#pragma mark - ~~~~~other~~~~

+ (OSDownloaderManager *)getDownloadManager {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return appDelegate.downloadManager;
}

- (void)dealloc {
    
    [self.progress removeObserver:self forKeyPath:NSStringFromSelector(@selector(fractionCompleted)) context:ProgressObserverContext];
}

// 查找数组中第一个符合条件的对象（代码块过滤），返回对应索引
// 查找downloadToken在downloadItems中对应的OSDownloadItem的索引
- (NSUInteger)foundItemIndxInDownloadItemsByIdentifier:(NSString *)identifier {
    if (!identifier.length) {
        return NSNotFound;
    }
    return [self.downloadItems indexOfObjectPassingTest:^BOOL(SampleDownloadItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        return [identifier isEqualToString:obj.downloadIdentifier];
    }];
}

+ (NSArray<SampleDownloadItem *> *)getDownloadItems {
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    return appDelegate.downloadModule.downloadItems;
}

- (NSArray <NSString *> *)getImageUrls {
    return @[
             @"http://sw.bos.baidu.com/sw-search-sp/software/447feea06f61e/QQ_mac_5.5.1.dmg",
             @"http://sw.bos.baidu.com/sw-search-sp/software/9d93250a5f604/QQMusic_mac_4.2.3.dmg",
             @"http://dlsw.baidu.com/sw-search-sp/soft/b4/25734/itunes12.3.1442478948.dmg",
             @"https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=3494814264,3775539112&fm=21&gp=0.jpg",
             @"https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=1996306967,4057581507&fm=21&gp=0.jpg",
             @"https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=2844924515,1070331860&fm=21&gp=0.jpg",
             @"https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=3978900042,4167838967&fm=21&gp=0.jpg",
             @"https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=516632607,3953515035&fm=21&gp=0.jpg",
             @"https://ss0.bdstatic.com/70cFuHSh_Q1YnxGkpoWK1HF6hhy/it/u=3180500624,3814864146&fm=21&gp=0.jpg",
             @"https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=3335283146,3705352490&fm=21&gp=0.jpg",
             @"https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=4090348863,2338325058&fm=21&gp=0.jpg",
              @"https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=3800219769,1402207302&fm=21&gp=0.jpg",
              @"https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=1534694731,2880365143&fm=21&gp=0.jpg",
              @"https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=1155733552,156192689&fm=21&gp=0.jpg",
              /*@"https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=3325163039,3163028420&fm=21&gp=0.jpg",
              @"https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=2090484547,151176521&fm=21&gp=0.jpg",
              @"https://ss2.bdstatic.com/70cFvnSh_Q1YnxGkpoWK1HF6hhy/it/u=2722857883,3187461130&fm=21&gp=0.jpg",
              @"https://ss1.bdstatic.com/70cFvXSh_Q1YnxGkpoWK1HF6hhy/it/u=3443126769,3454865923&fm=21&gp=0.jpg",
              @"https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=283169269,3942842194&fm=21&gp=0.jpg",
              @"https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=2522613626,1679950899&fm=21&gp=0.jpg",
              @"https://ss0.bdstatic.com/70cFvHSh_Q1YnxGkpoWK1HF6hhy/it/u=2307958387,2904044619&fm=21&gp=0.jpg",*/
             ];
}


@end
