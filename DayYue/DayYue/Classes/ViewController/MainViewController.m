//
//  MainViewController.m
//  DayYue
//
//  Created by 杨俊 on 2017/10/25.
//  Copyright © 2017年 Lenovo-Apple. All rights reserved.
//

#import "MainViewController.h"
#import "MapManager.h"
#import "STQRCodeController.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface MainViewController ()<UIWebViewDelegate,STQRCodeControllerDelegate>
@property (nonatomic, strong) UIWebView *webView;
@property (nonatomic, strong) NSNumber *longitute;
@property (nonatomic, strong) NSNumber *latitude;
@property (nonatomic, assign) BOOL hasLocationed;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBarHidden = YES;
    [self.view addSubview:self.webView];
    
    NSURL *url = [NSURL URLWithString:self.urlStr];
    DLog(@"url ---- %@",url);
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:YES];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:YES];
    self.navigationController.navigationBarHidden = NO;
}

- (void)addCustomActions{
    JSContext *context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    
    context.exceptionHandler =^(JSContext *context, JSValue *exceptionValue){
        context.exception = exceptionValue;
        NSLog(@"exceptionValue is %@", exceptionValue);
    };
    
    WEAK_SELF
    context[@"scanBtnClick"] = ^() {
        [weakSelf scanCode];
    };
    
    context[@"locationBtnClick"] = ^() {
        [weakSelf getCurrentLocation];
    };
    
    context[@"gainURLString"] = ^(NSString *urlString){
        STRONG_SELF
        NSString *resultURLStr = [NSString stringWithFormat:@"%@%@",self.urlStr,urlString];
        DLog(@"urlSting is ------>%@",urlString);
        DLog(@"resultURLStr is ------>%@",resultURLStr);
        NSURL *url = [NSURL URLWithString:resultURLStr];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        [self.webView loadRequest:request];
    };
    
    [self addCleanCacheAndCookieWithContext:context];
}

- (void)addCleanCacheAndCookieWithContext:(JSContext *)context{
    context[@"cleanCacheAndCookie"] = ^(){
        //清除cookies
        NSHTTPCookie *cookie;
        NSHTTPCookieStorage *storage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        for (cookie in [storage cookies]){
            [storage deleteCookie:cookie];
        }
        //清除UIWebView的缓存
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        [[NSURLCache sharedURLCache] setDiskCapacity:0];
        [[NSURLCache sharedURLCache] setMemoryCapacity:0];
        
        [OTSUserDefault setValue:nil forKey:Key];
        dispatch_async(dispatch_get_main_queue(), ^{
            [MBProgressHUD showSuccess:@"已清除"];
        });
    };
}

-(void)scanCode{
    STQRCodeController *codeVC = [[STQRCodeController alloc]init];
    codeVC.delegate = self;
    UINavigationController *navVC = [[UINavigationController alloc] initWithRootViewController:codeVC];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self presentViewController:navVC animated:YES completion:nil];
    });
}

-(void)getCurrentLocation{
    _hasLocationed = NO;
    [[MapManager sharedInstance] startWithCompleteBlock:^(CLPlacemark *mark, NSDictionary *addressDictionary, CLLocation *aLocation) {
        if (aLocation != nil) {
            CLLocationCoordinate2D coordinate = aLocation.coordinate;
            self.longitute = [NSNumber numberWithDouble:coordinate.longitude];
            self.latitude = [NSNumber numberWithDouble:coordinate.latitude];
            NSString *longitudeStr = [NSString stringWithFormat:@"%@",self.longitute];
            NSString *latitudeStr = [NSString stringWithFormat:@"%@",self.latitude];
            if (!_hasLocationed) {
                [self commitResultWithlongitudeStr:longitudeStr latitudeStr:latitudeStr];
            }
        }
    }];
}

- (void)commitResultWithlongitudeStr:(NSString *)longitudeStr latitudeStr:(NSString *)latitudeStr{
    [self.webView stringByEvaluatingJavaScriptFromString:
     @"var script = document.createElement('script');"
     "script.type = 'text/javascript';"
     "script.text = \"function commitResult(longitude, latitude) { "
     "var currentLongitude = longitude * 1;var currentLatitude = latitude * 1;alert('success'+currentLongitude+currentLatitude);deviceCheckStatusService.getDistance(vm.longitude, vm.latitude, currentLongitude, currentLatitude.success(function(data_distance){if (data_distance > 50) {abp.message.warn('GPS位置不正确，请到达该企业后再进行运维！', '错误');return;}else{vm.saveResult();}}));"
     "}\";"
     "document.getElementsByTagName('head')[0].appendChild(script);"];
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"commitResult(%@,%@);",longitudeStr,latitudeStr]];
    _hasLocationed = YES;
}

#pragma mark - --- delegate 视图委托 ---
- (void)qrcodeController:(STQRCodeController *)qrcodeController readerScanResult:(NSString *)readerScanResult type:(STQRCodeResultType)resultType{
    NSLog(@"%s %@", __FUNCTION__, readerScanResult);
    NSLog(@"%s %lu", __FUNCTION__, (unsigned long)resultType);
    
    if ((resultType == STQRCodeResultTypeError) || (resultType == STQRCodeResultTypeNoInfo)) {
        readerScanResult = @"没有扫描到结果";
    }
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"commitQRResult('%@');",readerScanResult]];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView{
    [MBProgressHUD showMessage:@"正在加载..."];
}

#pragma mark - UIWebViewDelegate
- (void)webViewDidFinishLoad:(UIWebView *)webView{
    DLog(@"webViewDidFinishLoad");
    [MBProgressHUD hideHUD];
    [self addCustomActions];
    
    [webView stringByEvaluatingJavaScriptFromString:
     @"var script = document.createElement('script');"
     "script.type = 'text/javascript';"
     "script.text = \"function alertTest() { "
     "$('.app-tips').css('display', 'none');"
     "}\";"
     "document.getElementsByTagName('head')[0].appendChild(script);"];
    [webView stringByEvaluatingJavaScriptFromString:@"alertTest();"];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error{
    [MBProgressHUD hideHUD];
    [MBProgressHUD showError:@"加载失败!"];
}

- (UIWebView *)webView{
    if (!_webView) {
        _webView = [[UIWebView alloc] init];
        _webView.frame = [UIScreen mainScreen].bounds;
        // UIWebView 滚动的比较慢，这里设置为正常速度
        _webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
        _webView.delegate = self;
        _webView.backgroundColor = [UIColor whiteColor];
    }
    return _webView;
}

@end
