//
//  AppDelegate.m
//  DownloaderManager
//
//  Created by Ossey on 2017/6/4.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "AppDelegate.h"
#import "OSDownloaderManager.h"
#import "SampleHomeViewController.h"
#import "SampleDownloadModule.h"

@interface AppDelegate ()

@property (nonatomic, strong) OSDownloaderManager *downloadManager;
@property (nonatomic, strong) SampleDownloadModule *downloadModule;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    
    SampleHomeViewController *vc = [SampleHomeViewController new];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    [self configBackgroundSession];
    
    return YES;
}

- (void)configBackgroundSession {
    
    self.downloadModule = [SampleDownloadModule new];
    self.downloadManager = [[OSDownloaderManager alloc] initWithDelegate:(id<OSDownloadProtocol>)self.downloadModule];
    [self.downloadManager setCompletionHandler:nil];
}


/*
 iOS7以后后台会话:
 当加入了多个Task，程序切到后台，所有Task都完成下载。
 在切到后台之后，Session的Delegate不会再收到，Task相关的消息，直到所有Task全都完成后，系统会调用ApplicationDelegate的application:handleEventsForBackgroundURLSession:completionHandler:回调，之后“汇报”下载工作，对于每一个后台下载的Task调用Session的Delegate中的URLSession:downloadTask:didFinishDownloadingToURL:（成功的话）和URLSession:task:didCompleteWithError:（成功或者失败都会调用）
 */
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier completionHandler:(void (^)())completionHandler {
    [self.downloadManager setBackgroundSessionCompletionHandler:completionHandler];
}



@end
