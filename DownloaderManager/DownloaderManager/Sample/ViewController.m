//
//  ViewController.m
//  DownloaderManager
//
//  Created by Ossey on 2017/6/4.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "ViewController.h"
#import "OSDownloaderManager.h"

@interface ViewController () <OSDownloadProtocol>
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, strong) OSDownloaderManager *manager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _manager = [[OSDownloaderManager alloc] initWithDelegate:self];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    
    [_manager startDownloadWithDownloadToken:@"123" remoteURL:[NSURL URLWithString:@"http://www.buick.com.cn/img/verano/kv.jpg"]];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/// 一个任务下载成功回调
/// @param aIdentifier 下载任务的标识符
/// @param aFileURL 存放的本地路径
- (void)downloadSuccessnWithIdentifier:(NSString *)aIdentifier finalLocalFileURL:(NSURL *)aFileURL {
    
    NSData *data = [NSData dataWithContentsOfURL:aFileURL];
    UIImage *image = [UIImage imageWithData:data];
    self.imageView.image = image;
}

/// 一个任务下载时候时调用
/// @param aIdentifier 下载任务的标识符
/// @param anError 下载任务失败的错误的信息
/// @param aHttpStatusCode HTTP状态码
/// @param anErrorMessagesStack 错误信息栈(最新的错误信息初入在第一位)
/// @param aResumeData 当前错误前已经下载的数据，当继续下载时可以复用此数据继续之前进度
- (void)downloadFailureWithIdentifier:(NSString *)aIdentifier
                                error:(NSError *)anError
                       httpStatusCode:(NSInteger)aHttpStatusCode
                   errorMessagesStack:(NSArray<NSString *> *)anErrorMessagesStack
                           resumeData:(NSData *)aResumeData {
    
}



/// 开始下载时，当网络活动指示器显示的时候调用
/// 此时应该在此回调中使用 UIApplication's setNetworkActivityIndicatorVisible: 去设置状态栏网络活动的可见性
- (void)incrementNetworkActivityIndicatorActivityCount {

}

/// 当网络活动指示器即将结束的时候调用
/// 此时应该在此回调中使用 UIApplication's setNetworkActivityIndicatorVisible: 去设置状态栏网络活动的可见性
- (void)decrementNetworkActivityIndicatorActivityCount {
    
}


- (void)downloadProgressChangeWithIdentifier:(NSString *)anIdentifier progress:(OSDownloadProgress *)progress {
    
    NSLog(@"%f", progress.estimatedRemainingTime);
}
@end
