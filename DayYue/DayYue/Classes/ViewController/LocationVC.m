//
//  LocationVC.m
//  DayYue
//
//  Created by 杨俊 on 2017/10/25.
//  Copyright © 2017年 Lenovo-Apple. All rights reserved.
//

#import "LocationVC.h"
#import "MainViewController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface LocationVC ()<UIWebViewDelegate>
@property (nonatomic, strong) JSContext *context;
@property (nonatomic, strong) UIWebView *webView;
@end

@implementation LocationVC

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = YES;
    [self.view addSubview:self.webView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    NSURL *url = [NSURL URLWithString:LocationService];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [MBProgressHUD showMessage:@"正在加载..."];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView{
    [MBProgressHUD hideHUD];
    self.context = [_webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    WEAK_SELF
    self.context[@"getServerIP"] =  ^(NSString *urlStr){
        STRONG_SELF
        NSLog(@"url is %@",urlStr);
        dispatch_async(dispatch_get_main_queue(), ^{
            [OTSUserDefault setValue:urlStr forKey:Key];
            MainViewController *mainVC = [[MainViewController alloc] init];
            mainVC.urlStr = urlStr;
            [self.navigationController pushViewController:mainVC animated:NO];
        });
    };
    
    self.context.exceptionHandler = ^(JSContext *context, JSValue *exceptionValue){
        context.exception = exceptionValue;
        NSLog(@"exceptionValue is %@", exceptionValue);
    };
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [MBProgressHUD hideHUD];
    [MBProgressHUD showError:@"加载失败!"];
}

- (UIWebView *)webView{
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _webView.delegate = self;
        _webView.backgroundColor = [UIColor whiteColor];
        _webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    }
    return _webView;
}

@end
