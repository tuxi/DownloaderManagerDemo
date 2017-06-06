//
//  SampleHomeViewController.m
//  DownloaderManager
//
//  Created by Ossey on 2017/6/6.
//  Copyright © 2017年 Ossey. All rights reserved.
//

#import "SampleHomeViewController.h"
#import "SampleDownloadController.h"

@interface SampleHomeViewController ()
@property (weak, nonatomic) IBOutlet UIButton *btn;

@end

@implementation SampleHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.title = NSStringFromClass([self class]);
    [self.btn.layer setCornerRadius:10];
    [self.btn.layer setMasksToBounds:YES];
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_8_4) {
        [self.btn.titleLabel setFont:[UIFont monospacedDigitSystemFontOfSize:13 weight:UIFontWeightBold]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
- (IBAction)jumpToDownloadPage:(id)sender {
    
    SampleDownloadController *downloadVc = [SampleDownloadController new];
    [self.navigationController pushViewController:downloadVc animated:YES];
}

@end
