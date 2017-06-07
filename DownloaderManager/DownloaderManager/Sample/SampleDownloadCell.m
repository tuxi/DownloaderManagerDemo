//
//  SampleDownloadCell.m
//  DownloaderManager
//
//  Created by xiaoyuan on 2017/6/5.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "SampleDownloadCell.h"
#import "SampleDownloadItem.h"
#import "AppDelegate.h"
#import "OSDownloaderManager.h"

@interface SampleDownloadCell ()

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


@end

@implementation SampleDownloadCell

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~ initialize ~~~~~~~~~~~~~~~~~~~~~~

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self setup];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}

- (void)setup {
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_0) {
        [self.cityAllCityLabel setFont:[UIFont monospacedDigitSystemFontOfSize:10.0 weight:UIFontWeightRegular]];
        [self.currentMapLabel setFont:[UIFont monospacedDigitSystemFontOfSize:13.0 weight:UIFontWeightRegular]];
    }
    
    self.downloadStatusView.userInteractionEnabled = YES;
    [self.downloadStatusView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnDownloadView:)]];
    [self.iconView setImage:[UIImage imageNamed:@"icon_downloaded"]];
}

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~ update subviews ~~~~~~~~~~~~~~~~~~~~~~
- (void)setDownloadItem:(SampleDownloadItem *)downloadItem {
    _downloadItem = downloadItem;
    
    self.cityAllCityLabel.text = downloadItem.remoteURL.absoluteString;
    
    [self setDownloadViewByStatus:downloadItem.status];
    
    [self setProgress];
    
    
}

- (void)setDownloadViewByStatus:(SampleDownloadStatus)aStatus {
    
    self.downloadStatusView.userInteractionEnabled = YES;
    NSString *downloadStatusIconName = nil;
    switch (aStatus) {
            
        case SampleDownloadStatusNotStarted:
            downloadStatusIconName = @"download_start_b";
            self.downloadStatusView.image = [UIImage imageNamed:downloadStatusIconName];
            break;
            
        case SampleDownloadStatusStarted:
            downloadStatusIconName = @"download_start_b";
            self.downloadStatusView.image = [UIImage imageNamed:downloadStatusIconName];
            break;
        case SampleDownloadStatusPaused:
            downloadStatusIconName = @"download_start_b";
            self.downloadStatusView.image = [UIImage imageNamed:downloadStatusIconName];
            break;
            
        case SampleDownloadStatusSuccess:
            
            if (self.downloadItem.localFileURL) {
                NSData *data = [NSData dataWithContentsOfURL:self.downloadItem.localFileURL];
                if ([self.downloadItem.localFileURL.lastPathComponent containsString:@".png"] || [self.downloadItem.localFileURL.lastPathComponent containsString:@".jpg"]) {
                    UIImage *image = [UIImage imageWithData:data];
                    self.iconView.image = image;
                } else {
                    downloadStatusIconName = @"download_finish";
                    self.downloadStatusView.image = [UIImage imageNamed:downloadStatusIconName];
                }
            } else {
                downloadStatusIconName = @"download_finish";
                self.downloadStatusView.image = [UIImage imageNamed:downloadStatusIconName];
            }
            self.downloadStatusView.userInteractionEnabled = NO;
            break;
            
        case SampleDownloadStatusCancelled:
            downloadStatusIconName = @"download_start_b";
            self.downloadStatusView.image = [UIImage imageNamed:downloadStatusIconName];
            break;
            
        case SampleDownloadStatusFailure:
        case SampleDownloadStatusInterrupted:
            downloadStatusIconName = @"download_start_b";
            self.downloadStatusView.image = [UIImage imageNamed:downloadStatusIconName];
            break;
            
        default:
            break;
    }
    
    
}

- (void)setProgress {
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    OSDownloadProgress *progress = [delegate.downloadManager downloadProgressByDownloadToken:self.downloadItem.downloadIdentifier];
    if (progress) {
        self.progressView.progress = progress.nativeProgress.fractionCompleted;
    } else {
        if (self.downloadItem.status == SampleDownloadStatusSuccess) {
            self.progressView.progress = 1.0;
        } else {
            self.progressView.progress = 0.0;
        }
    }
    NSString *receivedFileSize = [NSString transformedFileSizeValue:@(self.downloadItem.progressObj.receivedFileSize)];
    [self.sizeLabel setText:receivedFileSize];
    NSString *expectedFileTotalSize = [NSString transformedFileSizeValue:@(self.downloadItem.progressObj.expectedFileTotalSize)];
    [self.totalSizeLabel setText:expectedFileTotalSize];
    
    [self.remainTimeLabe setText:[NSString stringWithRemainingTime:self.downloadItem.progressObj.estimatedRemainingTime]];
    
}

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~ Actions ~~~~~~~~~~~~~~~~~~~~~~

- (void)tapOnDownloadView:(UITapGestureRecognizer *)tap {
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    switch (self.downloadItem.status) {
            
        case SampleDownloadStatusNotStarted:
        {
            [delegate.downloadModule start:self.downloadItem];
        }
            break;
            
        case SampleDownloadStatusStarted:
        {
            [self pause:self.downloadItem.downloadIdentifier];
        }
            break;
        case SampleDownloadStatusPaused:
        {
            [self resume:self.downloadItem.downloadIdentifier];
        }
            break;
            
        case SampleDownloadStatusSuccess:
        {
            
        }
            break;
            
        case SampleDownloadStatusCancelled:
        {
            [delegate.downloadModule cancel:self.downloadItem.downloadIdentifier];
        }
            break;
            
        case SampleDownloadStatusFailure:
        case SampleDownloadStatusInterrupted:
        {
            [delegate.downloadModule start:self.downloadItem];
        }
            break;
            
        default:
            break;
    }
    
    [delegate.downloadModule start:self.downloadItem];
}
- (void)pause:(NSString *)downloadIdentifier {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.downloadModule pause:downloadIdentifier];

}

- (void)resume:(NSString *)downloadIdentifier {
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.downloadModule resume:downloadIdentifier];
}

@end

@implementation NSString (DownloadUtils)

// 转换文件的字节数
+ (NSString *)transformedFileSizeValue:(NSNumber *)value {
    
    double convertedValue = [value doubleValue];
    int multiplyFactor = 0;
    
    NSArray *tokens = [NSArray arrayWithObjects:@"bytes",@"KB",@"MB",@"GB",@"TB",@"PB", @"EB", @"ZB", @"YB",nil];
    
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
