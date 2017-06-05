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

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_9_0) {
        [self.cityAllCityLabel setFont:[UIFont monospacedDigitSystemFontOfSize:10.0 weight:UIFontWeightRegular]];
        [self.currentMapLabel setFont:[UIFont monospacedDigitSystemFontOfSize:13.0 weight:UIFontWeightRegular]];
    }
    
    self.downloadStatusView.userInteractionEnabled = YES;
    [self.downloadStatusView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOnDownloadView:)]];
    
    self.downloadStatusView.backgroundColor = [UIColor blueColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)setDownloadItem:(SampleDownloadItem *)downloadItem {
    _downloadItem = downloadItem;
    
    self.cityAllCityLabel.text = downloadItem.remoteURL.absoluteString;
    
    [self setDownloadViewByStatus:downloadItem.status];
    
    [self setProgress];
}

- (void)setDownloadViewByStatus:(SampleDownloadItemStatus)aStatus {
    
    switch (aStatus) {
            
        case SampleDownloadItemStatusNotStarted:
        
            break;
            
        case SampleDownloadItemStatusStarted:
        case SampleDownloadItemStatusPaused:
           
            break;
            
        case SampleDownloadItemStatusCompleted:
            
            break;
            
        case SampleDownloadItemStatusCancelled:
            
            break;
            
        case SampleDownloadItemStatusError:
        case SampleDownloadItemStatusInterrupted:
            
            break;
            
        default:
            NSLog(@"ERR: Invalid status %@ (%@, %d)", @(aStatus), [NSString stringWithUTF8String:__FILE__].lastPathComponent, __LINE__);
            break;
    }
}

- (void)setProgress {
   
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    
    OSDownloadProgress *progress = [delegate.downloadManager downloadProgressByDownloadToken:self.downloadItem.downloadIdentifier];
    if (progress) {
        self.progressView.progress = progress.nativeProgress.fractionCompleted;
    } else {
        if (self.downloadItem.status == SampleDownloadItemStatusCompleted) {
            self.progressView.progress = 1.0;
        } else {
            self.progressView.progress = 0.0;
        }
    }
    __weak typeof(self) weakSelf = self;
    self.downloadItem.progressChangeHandler = ^{
        if (progress) {
            weakSelf.progressView.progress = progress.nativeProgress.fractionCompleted;
        } else {
            weakSelf.progressView.progress = 0.0;
        }
    };
   
}

- (void)tapOnDownloadView:(UITapGestureRecognizer *)tap {
    
    AppDelegate *delegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [delegate.downloadModule start:self.downloadItem];
}


@end
