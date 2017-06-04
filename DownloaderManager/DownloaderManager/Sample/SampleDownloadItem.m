
//
//  SampleDownloadItem.m
//  DownloaderManager
//
//  Created by Ossey on 2017/6/5.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "SampleDownloadItem.h"

@interface SampleDownloadItem() <NSCoding>

@property (nonatomic, strong, readwrite, nonnull) NSString *downloadIdentifier;
@property (nonatomic, strong, readwrite, nonnull) NSURL *remoteURL;
@end


@implementation SampleDownloadItem


- (nullable instancetype)initWithDownloadIdentifier:(NSString *)aDownloadIdentifier
                                          remoteURL:(NSURL *)aRemoteURL {
    self = [super init];
    if (self)
    {
        self.downloadIdentifier = aDownloadIdentifier;
        self.remoteURL = aRemoteURL;
        self.status = SampleDownloadItemStatusNotStarted;
    }
    return self;
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.downloadIdentifier forKey:@"downloadIdentifier"];
    [aCoder encodeObject:self.remoteURL forKey:@"remoteURL"];
    [aCoder encodeObject:@(self.status) forKey:@"status"];
    if (self.resumeData.length > 0)
    {
        [aCoder encodeObject:self.resumeData forKey:@"resumeData"];
    }
    if (self.progress)
    {
        [aCoder encodeObject:self.progress forKey:@"progress"];
    }
    if (self.downloadError)
    {
        [aCoder encodeObject:self.downloadError forKey:@"downloadError"];
    }
    if (self.downloadErrorMessagesStack)
    {
        [aCoder encodeObject:self.downloadErrorMessagesStack forKey:@"downloadErrorMessagesStack"];
    }
    [aCoder encodeObject:@(self.lastHttpStatusCode) forKey:@"lastHttpStatusCode"];
}


- (id)initWithCoder:(NSCoder *)aCoder
{
    self = [super init];
    if (self)
    {
        self.downloadIdentifier = [aCoder decodeObjectForKey:@"downloadIdentifier"];
        self.remoteURL = [aCoder decodeObjectForKey:@"remoteURL"];
        self.status = [[aCoder decodeObjectForKey:@"status"] unsignedIntegerValue];
        self.resumeData = [aCoder decodeObjectForKey:@"resumeData"];
        self.progress = [aCoder decodeObjectForKey:@"progress"];
        self.downloadError = [aCoder decodeObjectForKey:@"downloadError"];
        self.downloadErrorMessagesStack = [aCoder decodeObjectForKey:@"downloadErrorMessagesStack"];
        self.lastHttpStatusCode = [[aCoder decodeObjectForKey:@"lastHttpStatusCode"] integerValue];
    }
    return self;
}


#pragma mark - Description


- (NSString *)description
{
    NSMutableDictionary *aDescriptionDict = [NSMutableDictionary dictionary];
    [aDescriptionDict setObject:self.downloadIdentifier forKey:@"downloadIdentifier"];
    [aDescriptionDict setObject:self.remoteURL forKey:@"remoteURL"];
    [aDescriptionDict setObject:@(self.status) forKey:@"status"];
    if (self.progress)
    {
        [aDescriptionDict setObject:self.progress forKey:@"progress"];
    }
    if (self.resumeData.length > 0)
    {
        [aDescriptionDict setObject:@"hasData" forKey:@"resumeData"];
    }
    
    NSString *aDescriptionString = [NSString stringWithFormat:@"%@", aDescriptionDict];
    
    return aDescriptionString;
}

@end
