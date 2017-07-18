//
//  SampleDownloadController.m
//  DownloaderManager
//
//  Created by Ossey on 2017/6/4.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "SampleDownloadController.h"
#import "SampleDownloadCell.h"
#import "AppDelegate.h"
#import "NetworkTypeUtils.h"
#import "NSObject+XYHUD.h"

#pragma clang diagnostic ignored "-Wundeclared-selector"

static NSString * const SampleDownloadCellIdentifierKey = @"SampleDownloadCell";

@interface SampleDownloadController ()

@end

@implementation SampleDownloadController

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~ life cycle ~~~~~~~~~~~~~~~~~~~~~~~


- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self setup];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~ initialize ~~~~~~~~~~~~~~~~~~~~~~~


- (void)setup {
    
    self.title = NSStringFromClass([self class]);
    
    
    UIBarButtonItem *reloadDownloads = [[UIBarButtonItem alloc] initWithTitle:@"重新加载下载项" style:UIBarButtonItemStylePlain target:self action:@selector(reloadAllDownloads)];
    UIBarButtonItem *clearDownloads = [[UIBarButtonItem alloc] initWithTitle:@"清空下载项" style:UIBarButtonItemStylePlain target:self action:@selector(clearDownloads)];
    self.navigationItem.rightBarButtonItems = @[reloadDownloads, clearDownloads];
    
    [self initTableView];
    [self addObservers];
}

- (void)initTableView {
    
    UINib *nib = [UINib nibWithNibName:@"SampleDownloadCell" bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:SampleDownloadCellIdentifierKey];
}

- (void)addObservers {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadSuccess:) name:OSFileDownloadSussessNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadFailure:) name:OSFileDownloadFailureNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadProgressChange:) name:OSFileDownloadProgressChangeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(downloadCanceld) name:OSFileDownloadCanceldNotification object:nil];
}


#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~ Actions ~~~~~~~~~~~~~~~~~~~~~~~

- (void)reloadAllDownloads {
    
    [[OSDownloaderModule sharedInstance] performSelector:@selector(_addDownloadTaskFromDataSource) withObject:nil];
    [self.tableView reloadData];
}

- (void)clearDownloads {
    [[OSDownloaderModule sharedInstance] clearAllDownloadTask];
    [self.tableView reloadData];
}

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~ Table view data source ~~~~~~~~~~~~~~~~~~~~~~~


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return [OSDownloaderModule sharedInstance].downloadItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    SampleDownloadCell *cell = [tableView dequeueReusableCellWithIdentifier:SampleDownloadCellIdentifierKey forIndexPath:indexPath];
    
    cell.downloadItem = [OSDownloaderModule sharedInstance].downloadItems[indexPath.row];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    return 88;
}

#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~ notifiy events ~~~~~~~~~~~~~~~~~~~~~~~


- (void)downloadSuccess:(NSNotification *)note {
    [self.tableView reloadData];
}

- (void)downloadFailure:(NSNotification *)note {
    [self.tableView reloadData];
}

- (void)downloadProgressChange:(NSNotification *)note {
    
    [self.tableView reloadData];
    
}

- (void)downloadCanceld {
    [self.tableView reloadData];
}


#pragma mark - ~~~~~~~~~~~~~~~~~~~~~~~ Other ~~~~~~~~~~~~~~~~~~~~~~~


- (void)dealloc {
    
    NSLog(@"%s", __FUNCTION__);
}

@end
