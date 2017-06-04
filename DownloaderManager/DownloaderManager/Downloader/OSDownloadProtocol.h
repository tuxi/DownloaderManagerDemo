//
//  OSDownloadProtocol.h
//  DownloaderManager
//
//  Created by Ossey on 2017/6/4.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol OSDownloadProtocol <NSObject>


/// 一个任务下载成功回调
/// @param aIdentifier 下载任务的标识符
/// @param aFileURL 存放的本地路径
- (void)downloadDidCompletionWithIdentifier:(NSString *)aIdentifier localFileURL:(NSURL *)aFileURL;

/// 一个任务下载时候时调用
/// @param aIdentifier 下载任务的标识符
/// @param anError 下载任务失败的错误的信息
/// @param aHttpStatusCode HTTP状态码
/// @param anErrorMessagesStack 错误信息栈(最新的错误信息初入在第一位)
/// @param aResumeData 当前错误前已经下载的数据，当继续下载时可以复用此数据继续之前进度
- (void)downloadFailureWithIdentifier:(NSString *)aIdentifier
                                error:(NSError *)anError
                       httpStatusCode:(NSInteger)aHttpStatusCode
                   errorMessagesStack:(nullable NSArray<NSString *> *)anErrorMessagesStack
                           resumeData:(nullable NSData *)aResumeData;



/// 开始下载时，当网络活动指示器显示的时候调用
/// 此时应该在此回调中使用 UIApplication's setNetworkActivityIndicatorVisible: 去设置状态栏网络活动的可见性
- (void)incrementNetworkActivityIndicatorActivityCount;

/// 当网络活动指示器即将结束的时候调用
/// 此时应该在此回调中使用 UIApplication's setNetworkActivityIndicatorVisible: 去设置状态栏网络活动的可见性
- (void)decrementNetworkActivityIndicatorActivityCount;

@optional

/// 下载进度改变的时候调用
/// @param anIdentifier 当前下载任务的标识符
- (void)downloadProgressChangeWithIdentifier:(NSString *)anIdentifier;

/// 下载暂停时调用
/// @param anIdentifier 当前下载任务的标识符
/// @param aResumeData 当前暂停前已下载的数据，当继续下载时可以复用此数据继续之前进度
- (void)downloadPausedWithIdentifier:(NSString *)anIdentifier resumeData:(NSData *)aResumeData;

/// 恢复下载时调用
/// @param anIdentifier 当前下载任务的标识符
- (void)resumeDownloadWithIdentifier:(NSString *)anIdentifier;

/// 当下载的文件需要存储到本地时调用，并设置本地的路径
/// @param anIdentifier 当前下载任务的标识符
/// @param aRemoteURL 下载文件的服务器地址
/// @return 设置本地存储的路径
/// @discussion 虽然anIdentifier用于识别下载的任务，这里回调aRemoteURL更方便区分
- (NSURL *)localFileURLWithIdentifier:(NSString *)anIdentifier remoteURL:(NSURL *)aRemoteURL;

/// 回调此方法，验证下载数据
/// @param aLocalFileURL 下载文件的本地路径
/// @param anIdentifier 当前下载任务的标识符
/// @return 如果本地文件中下载的数据通过验证测试，则应该renturn YES
/// @discussion 有时下载的数据可能是错误的， 此方法可用于检查下载的数据是否为预期的内容和数据类型，default YES
- (BOOL)downloadAtLocalFileURL:(NSURL *)aLocalFileURL isVaildByDownloadIdentifier:(NSString *)anIdentifier;

/// 回调此方法，验证HTTP 状态码 是否有效
/// @param aHttpStatusCode 当前服务器响应的HTTP 状态码
/// @param anIdentifier 当前下载任务的标识符
/// @return 如果HTTP状态码正确，则应该return YES
/// @discussion 默认范围HTTP状态码从200-299都是正确的，如果默认的范围与公司服务器不符合，可实现此方法设置
- (BOOL)httpStatusCode:(NSInteger)aHttpStatusCode isVaildByDownloadIdentifier:(NSString *)anIdentifier;

/// 回调此方法，进行配置后台会话任务
/// @param aBackgroundConiguration 可以修改的后台会话对象
/// @discussion 可以修改他的timeoutIntervalForRequest, timeoutIntervalForResource, HTTPAdditionalHeaders属性
- (void)customBackgroundSessionConfiguration:(NSURLSessionConfiguration *)aBackgroundConiguration;

/// 根据aRemoteURL创建一个NSURLRequest返回
/// @param aRemoteURL 需要下载的url
/// @retun 一个自定义的NSURLRequest对象
- (NSURLRequest *)URLRequestForRemoteURL:(NSURL *)aRemoteURL;

/// 回调此方法，进行SSL认证的设置
/// @param aChallenge 认证
/// @param anIdentifier 当前下载任务的标识符
/// @param aCompletionHandler 此block用于配置调用完成回调
- (void)authenticationChallenge:(nonnull NSURLAuthenticationChallenge *)aChallenge
               downloadIdentifier:(nonnull NSString *)aDownloadIdentifier
                completionHandler:(void (^ _Nonnull)(NSURLCredential * _Nullable aCredential, NSURLSessionAuthChallengeDisposition disposition))aCompletionHandler;

/// 提供一个下载进度的对象，以记录下载进度
/// @return 下载进度的对象
- (NSProgress *)rootProgress;
@end
