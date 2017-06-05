//
//  AppDelegate.h
//  DownloaderManager
//
//  Created by Ossey on 2017/6/4.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import <UIKit/UIKit.h>

@class OSDownloaderManager, SampleDownloadModule;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (nonatomic, strong, readonly) OSDownloaderManager *downloadManager;
@property (nonatomic, strong, readonly) SampleDownloadModule *downloadModule;

@end

