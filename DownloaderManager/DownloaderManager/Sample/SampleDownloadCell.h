//
//  SampleDownloadCell.h
//  DownloaderManager
//
//  Created by xiaoyuan on 2017/6/5.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OSDownloaderModule.h"

@interface SampleDownloadCell : UITableViewCell

@property (nonatomic, strong) id<OSDownloadFileItemProtocol> downloadItem;

- (void)setLongPressGestureRecognizer:(void (^)(UILongPressGestureRecognizer *longPres))block;

@end

@interface NSString (DownloadUtils)

+ (NSString *)transformedFileSizeValue:(NSNumber *)value;
+ (NSString *)stringWithRemainingTime:(NSTimeInterval)remainingTime;
@end
