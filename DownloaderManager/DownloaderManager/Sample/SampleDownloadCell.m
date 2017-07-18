//
//  SampleDownloadCell.m
//  DownloaderManager
//
//  Created by xiaoyuan on 2017/6/5.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "SampleDownloadCell.h"
#import "OSFileItem.h"

#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface SampleDownloadCell () <UIAlertViewDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *iconView;
@property (weak, nonatomic) IBOutlet UILabel *downloadStatusLabel;
@property (weak, nonatomic) IBOutlet UILabel *sizeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalSizeLabel;
@property (weak, nonatomic) IBOutlet UIProgressView *progressView;
@property (weak, nonatomic) IBOutlet UIImageView *downloadStatusView;
@property (weak, nonatomic) IBOutlet UIView *cityMapContentView;
@property (weak, nonatomic) IBOutlet UILabel *currentMapLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityAllCityLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainTimeLabe;

@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGes;

@property (nonatomic, copy) void (^longPressGesOnSelfHandlerBlock)(UILongPressGestureRecognizer *longPres);
@property (weak, nonatomic) IBOutlet UILabel *speedLabel;

@end

@implementation SampleDownloadCell

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~ initialize ~~~~~~~~~~~~~~~~~~~~~~

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self setup];
}

- (void)setLongPressGestureRecognizer:(void (^)(UILongPressGestureRecognizer *longPres))block {
    if (!self.longPressGes) {
        self.longPressGes = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGesOnSelfHandler:)];
        [self addGestureRecognizer:self.longPressGes];
    }
    self.longPressGesOnSelfHandlerBlock = nil;
    self.longPressGesOnSelfHandlerBlock = block;
}

- (void)longPressGesOnSelfHandler:(UILongPressGestureRecognizer *)longPress {
    
    [self _longPressGesOnSelfHandler:longPress];
    
    
}

- (void)_longPressGesOnSelfHandler:(UILongPressGestureRecognizer *)longPress {
    if (self.longPressGesOnSelfHandlerBlock) {
        self.longPressGesOnSelfHandlerBlock(longPress);
    }
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setup {
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_0) {
        [self.cityAllCityLabel setFont:[UIFont monospacedDigitSystemFontOfSize:10.0 weight:UIFontWeightRegular]];
        [self.currentMapLabel setFont:[UIFont monospacedDigitSystemFontOfSize:13.0 weight:UIFontWeightRegular]];
        [self.speedLabel setFont:[UIFont monospacedDigitSystemFontOfSize:10.0 weight:UIFontWeightRegular]];
    }
    
    self.downloadStatusView.userInteractionEnabled = YES;
    [self.downloadStatusView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnDownloadView:)]];
    [self.iconView setImage:[UIImage imageNamed:@"icon_downloaded"]];
    
    __weak typeof(self) weakSelf = self;
    [self setLongPressGestureRecognizer:^(UILongPressGestureRecognizer *longPres) {
        if (longPres.state == UIGestureRecognizerStateBegan) {
            [[[UIAlertView alloc] initWithTitle:@"是否删除下载项" message:nil delegate:weakSelf cancelButtonTitle:@"否" otherButtonTitles:@"是", nil] show];
        }
    }];
}

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~ update subviews ~~~~~~~~~~~~~~~~~~~~~~
- (void)setDownloadItem:(id<OSDownloadFileItemProtocol>)downloadItem {
    _downloadItem = downloadItem;
    
    self.cityAllCityLabel.text = downloadItem.urlPath;
    
    [self setDownloadViewByStatus:downloadItem.status];
    
    [self setProgress];
    
    
}

- (void)setDownloadViewByStatus:(OSFileDownloadStatus)aStatus {
    
    self.speedLabel.hidden = NO;
    self.remainTimeLabe.hidden = NO;
    
    self.downloadStatusView.userInteractionEnabled = YES;
    NSString *downloadStatusIconName = @"download_start_b";
    NSString *downloadStatusLabel = @"未开始";
    switch (aStatus) {
            
        case OSFileDownloadStatusNotStarted:
            downloadStatusIconName = @"download_start_b";
            downloadStatusLabel = @"未开始";
            break;
            
        case OSFileDownloadStatusDownloading:
            downloadStatusIconName = @"download_pause";
            downloadStatusLabel = @"下载中";
            break;
        case OSFileDownloadStatusPaused:
            downloadStatusIconName = @"download_start_b";
            downloadStatusLabel = @"已暂停";
            break;
            
        case OSFileDownloadStatusWaiting:
            downloadStatusIconName = @"download_start_b";
            downloadStatusLabel = @"等待中";
            break;
            
        case OSFileDownloadStatusSuccess:
            
            if (self.downloadItem.localFileURL) {
                NSData *data = [NSData dataWithContentsOfURL:self.downloadItem.localFileURL];
                if ([self.downloadItem.localFileURL.lastPathComponent containsString:@".png"] || [self.downloadItem.localFileURL.lastPathComponent containsString:@".jpg"]) {
                    UIImage *image = [UIImage imageWithData:data];
                    self.iconView.image = image;
                }
                
                
            }
            downloadStatusIconName = @"download_finish";
            downloadStatusLabel = @"下载完成";
            self.speedLabel.hidden = YES;
            self.remainTimeLabe.hidden = YES;
            self.downloadStatusView.userInteractionEnabled = NO;
            break;
            
        case OSFileDownloadStatusCancelled:
            downloadStatusIconName = @"download_start_b";
            downloadStatusLabel = @"重新开始";
            break;
            
        case OSFileDownloadStatusFailure:
            downloadStatusIconName = @"download_start_b";
            downloadStatusLabel = @"下载失败";
            break;
        default:
            break;
    }
    self.downloadStatusView.image = [UIImage imageNamed:downloadStatusIconName];
    self.downloadStatusLabel.text = downloadStatusLabel;
}

- (void)setProgress {
    
    OSDownloadProgress *progress = self.downloadItem.progressObj;
    if (progress) {
        self.progressView.progress = progress.progress;
    } else {
        if (self.downloadItem.status == OSFileDownloadStatusSuccess) {
            self.progressView.progress = 1.0;
        } else {
            self.progressView.progress = 0.0;
        }
    }
    NSString *receivedFileSize = [NSString transformedFileSizeValue:@(self.downloadItem.progressObj.receivedFileSize)];
    [self.sizeLabel setText:receivedFileSize];
    NSString *expectedFileTotalSize = [NSString transformedFileSizeValue:@(self.downloadItem.progressObj.expectedFileTotalSize)];
    [self.totalSizeLabel setText:[NSString stringWithFormat:@"/ %@", expectedFileTotalSize]];
    
    [self.remainTimeLabe setText:[NSString stringWithRemainingTime:self.downloadItem.progressObj.estimatedRemainingTime]];
    [self.speedLabel setText:[NSString stringWithFormat:@"%@/s", [NSString transformedFileSizeValue:@(self.downloadItem.progressObj.bytesPerSecondSpeed)]]];
    
}

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~ Actions ~~~~~~~~~~~~~~~~~~~~~~

- (void)tapOnDownloadView:(UITapGestureRecognizer *)tap {
    
    
    switch (self.downloadItem.status) {
            
        case OSFileDownloadStatusNotStarted:
        {
            [self start:self.downloadItem.urlPath];
        }
            break;
            
        case OSFileDownloadStatusDownloading:
        {
            [self pause:self.downloadItem.urlPath];
        }
            break;
        case OSFileDownloadStatusWaiting:
        {
            [self resume:self.downloadItem.urlPath];
        }
            break;
        case OSFileDownloadStatusPaused:
        {
            [self resume:self.downloadItem.urlPath];
        }
            break;
            
        case OSFileDownloadStatusSuccess:
        {
            
        }
            break;
            
        case OSFileDownloadStatusCancelled:
        {
            
        }
            break;
            
        case OSFileDownloadStatusFailure:
        {
            [self resume:self.downloadItem.urlPath];
        }
            break;
            
        default:
            break;
    }
    
}
- (void)pause:(NSString *)urlPath {
    [[OSDownloaderModule sharedInstance] pause:urlPath];
    
}

- (void)resume:(NSString *)urlPath {
    [[OSDownloaderModule sharedInstance]  resume:urlPath];
}

- (void)start:(NSString *)urlPath {
    [[OSDownloaderModule sharedInstance]  start:urlPath];
}

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~ <UIAlertViewDelegate> ~~~~~~~~~~~~~~~~~~~~~~~

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (buttonIndex == 1) {
        // 取消下载，并删除
        [[OSDownloaderModule sharedInstance]  cancel:self.downloadItem.urlPath];
    }
}


@end

@implementation NSString (DownloadUtils)

// 转换文件的字节数
+ (NSString *)transformedFileSizeValue:(NSNumber *)value {
    
    double convertedValue = [value doubleValue];
    int multiplyFactor = 0;
    
    NSArray *tokens = [NSArray arrayWithObjects:@"B",@"KB",@"MB",@"GB",@"TB",@"PB", @"EB", @"ZB", @"YB",nil];
    
    while (convertedValue > 1024) {
        convertedValue /= 1024;
        multiplyFactor++;
    }
    
    return [NSString stringWithFormat:@"%4.2f %@",convertedValue, [tokens objectAtIndex:multiplyFactor]];
}

+ (NSString *)stringWithRemainingTime:(NSTimeInterval)remainingTime {
    NSNumberFormatter *aNumberFormatter = [[NSNumberFormatter alloc] init];
    [aNumberFormatter setNumberStyle:NSNumberFormatterDecimalStyle];
    [aNumberFormatter setMinimumFractionDigits:1];
    [aNumberFormatter setMaximumFractionDigits:1];
    [aNumberFormatter setDecimalSeparator:@"."];
    return [NSString stringWithFormat:@"%@ seconds", [aNumberFormatter stringFromNumber:@(remainingTime)]];
}
@end
