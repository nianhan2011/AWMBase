//
//  LCUIWebViewController.m
//  Pods
//
//  Created by hugo on 2017/6/22.
//
//

#import <WebKit/WebKit.h>
#import <Masonry/Masonry.h>
#import <MBProgressHUD/MBProgressHUD.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <WebViewJavascriptBridge/WKWebViewJavascriptBridge.h>
#import <MJRefresh/MJRefresh.h>
#import "AWMWebViewController.h"
#import "LCRouter.h"
#import <AWMBaseMacros.h>
@interface LCUIWebViewController ()<WKNavigationDelegate, WKUIDelegate>

@property (strong, nonatomic) WKWebView *webView;
@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) WKWebViewJavascriptBridge *bridge;
@end

@implementation LCUIWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.topBar.hidden = !self.showNavigationBar;
//    [self setupBackButton];
    
    WKUserContentController* userContentController = WKUserContentController.new;
//    NSString *source = [self cookie];
//    WKUserScript *cookieScript = [[WKUserScript alloc] initWithSource:source
//                                                        injectionTime:WKUserScriptInjectionTimeAtDocumentStart
//                                                     forMainFrameOnly:NO];
//
//    [userContentController addUserScript:cookieScript];
    WKWebViewConfiguration* webViewConfig = WKWebViewConfiguration.new;
    webViewConfig.preferences = [[WKPreferences alloc] init];
    webViewConfig.preferences.javaScriptEnabled = YES;
    webViewConfig.userContentController = userContentController;
    
    self.webView = [[WKWebView alloc] initWithFrame:self.view.bounds configuration:webViewConfig];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate =self;
    
    if (@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    } else {
        // Fallback on earlier versions
    }
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        if (self.topBar.hidden) {
//            make.top.mas_equalTo(20 + Safe_Top);
            make.top.mas_equalTo(0);
        } else {
            make.top.mas_equalTo(TopBarHeight);
        }
        make.leading.equalTo(self.webView.superview);
        make.trailing.equalTo(self.webView.superview);
//        make.bottom.equalTo(self.webView.superview);
        make.height.mas_equalTo(SCREENH_HEIGHT - TabBar_Height);
    }];
    
    _bridge = [WKWebViewJavascriptBridge bridgeForWebView:self.webView];
    [_bridge setWebViewDelegate:self];
    [self registerMethods];
    
    [self setupProgressView];
    
    self.navigationItem.title = self.navTitle;
    [self handleWebViewLoad];
    
    //refresh
//    self.webView.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refresh)];
}

- (void)dealloc {
    [self.webView removeObserver:self forKeyPath:@"estimatedProgress"];
}

#pragma mark - Action
- (void)refresh {
    [self.webView reload];
}

#pragma mark - Observer
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"estimatedProgress"]) {
        [self.progressView setProgress:self.webView.estimatedProgress animated:YES];
    }else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

#pragma mark - Private
#if 0
- (NSString *)cookie {
    NSMutableDictionary *cookieDic = [NSMutableDictionary dictionary];
    NSMutableString *cookieValue = [NSMutableString stringWithFormat:@""];
    NSHTTPCookieStorage *cookieJar = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [cookieJar cookies]) {
        [cookieDic setObject:cookie.value forKey:cookie.name];
    }
    
    //拼接基础参数
    NSDictionary *baseParam = [LCHttpManager parameterWithBaseParam:nil];
    if (baseParam.count > 0) {
        [cookieDic addEntriesFromDictionary:baseParam];
        [cookieDic removeObjectForKey:@"sign"];
    }

    // cookie重复，先放到字典进行去重，再进行拼接
    for (NSString *key in cookieDic) {
        NSString *appendString = [NSString stringWithFormat:@"document.cookie='%@=%@';", key, [cookieDic valueForKey:key]];
        [cookieValue appendString:appendString];
    }
    return cookieValue;
}
#endif

- (void)handleWebViewLoad {
    
    NSMutableURLRequest * request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.URLString]];
//    [request setValue:[self cookie] forHTTPHeaderField:@"Cookie"];
    [self.webView loadRequest:request];
}

- (void)registerMethods {
    [self.bridge registerHandler:@"back" handler:^(id data, WVJBResponseCallback responseCallback) {
        DISMISS();
    }];
    
    if (![self.URLString isEqualToString:@"http://test.duanwen.iymbl.com/aqq"]) {
        [self.bridge registerHandler:@"statusBarHeight" handler:^(id data, WVJBResponseCallback responseCallback) {
            responseCallback(@(20 + Safe_Top));
        }];
    }

    
}

- (void)setupProgressView {
    self.progressView = [[UIProgressView alloc] init];
    self.progressView.trackTintColor = [UIColor clearColor];
    [self.view addSubview:self.progressView];
    [self.progressView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(1);
        make.width.equalTo(self.progressView.superview);
    }];
    [self.webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
}

#pragma mark - WKUIDelegate
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"知道了"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler();
                                                      }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler {
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message
                                                                             message:nil
                                                                      preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定"
                                                        style:UIAlertActionStyleDefault
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler(YES);
                                                      }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消"
                                                        style:UIAlertActionStyleCancel
                                                      handler:^(UIAlertAction *action) {
                                                          completionHandler(NO);
                                                      }]];
    [self presentViewController:alertController animated:YES completion:^{}];
}

#pragma mark - WKNavigationDelegate
//开始加载
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    NSLog(@"开始加载网页");
    //开始加载网页时展示出progressView
    self.progressView.hidden = NO;
    //防止progressView被网页挡住
    [self.view bringSubviewToFront:self.progressView];
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.webView animated:YES];
    hud.label.text = @"加载中";
}

//加载失败
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    //加载失败同样需要隐藏progressView
    self.progressView.hidden = YES;
    [MBProgressHUD hideHUDForView:self.webView animated:YES];
    [self.webView.scrollView.mj_header endRefreshing];
}


//加载完成
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    //加载完成后隐藏progressView
    self.progressView.hidden = YES;
    [MBProgressHUD hideHUDForView:self.webView animated:YES];
    [self.webView.scrollView.mj_header endRefreshing];
    
    if (self.navTitle.length == 0) {
        @weakify(self);
        [webView evaluateJavaScript:@"document.title" completionHandler:^(id _Nullable title, NSError * _Nullable error) {
            @strongify(self);
            self.navigationItem.title = title;
        }];
    }
}

- (void)webView:(WKWebView *)webView didFailNavigation:(null_unspecified WKNavigation *)navigation withError:(NSError *)error {
    self.progressView.hidden = YES;
    [MBProgressHUD hideHUDForView:self.webView animated:YES];
    [self.webView.scrollView.mj_header endRefreshing];
}
@end
LC_REGISTE_VIEWCONTROLLER_PATH(LCUIWebViewController, @"/webview")

