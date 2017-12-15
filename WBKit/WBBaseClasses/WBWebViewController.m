//
//  WBWebViewController.m
//  WBUtilDemoProject
//
//  Created by wangbo on 16/9/21.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "WBWebViewController.h"

@interface WBWebViewController ()<WKUIDelegate,WKNavigationDelegate>
{
    ///设置正在加载，在此期间不可做同类操作，暂时未用到
    BOOL isloading;
}


@end

@implementation WBWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
//    [self loadContext];
    [self loadWebview];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**
 *  这个方法在wkwebview中被移除了，不能用了

-(void)loadContext{
    _context = [self.webView valueForKeyPath:@"documentView.webView.mainFrame.javaScriptContext"];
    __weak typeof(self) weakSelf = self;
    __weak typeof (NSArray) *weakNames = _JSActionNames;
    //无对象，通过默认方式调用方式调用js
    for (int i = 0; i<_JSActionNames.count; i++) {
        _context[[_JSActionNames objectAtIndex:i]] = ^() {
            NSArray *args = [JSContext currentArguments];
            if (weakSelf.JSActionListenner) {
                [weakSelf.JSActionListenner listenFunction:[weakNames objectAtIndex:i] args:args];
            }
        };
    }
}
*/

-(void)loadWebview{
    [self.view addSubview:self.webView];
    self.req = [NSURLRequest requestWithURL:self.url];
    [_webView loadRequest:self.req];
}


#pragma mark - WKNavigationDelegate

/**
 *  页面开始加载时调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 */
- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    
    NSLog(@"%s", __FUNCTION__);
}

/**
 *  当内容开始返回时调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 */
- (void)webView:(WKWebView *)webView didCommitNavigation:(WKNavigation *)navigation {
    
    NSLog(@"%s", __FUNCTION__);
}

/**
 *  页面加载完成之后调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 */
- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    
    NSLog(@"%s", __FUNCTION__);
}

/**
 *  加载失败时调用
 *
 *  @param webView    实现该代理的webview
 *  @param navigation 当前navigation
 *  @param error      错误
 */
- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    
    NSLog(@"%s", __FUNCTION__);
}

/**
 *  接收到服务器跳转请求之后调用
 *
 *  @param webView      实现该代理的webview
 *  @param navigation   当前navigation
 */
- (void)webView:(WKWebView *)webView didReceiveServerRedirectForProvisionalNavigation:(WKNavigation *)navigation {
    
    NSLog(@"%s", __FUNCTION__);
}

/**
 *  在收到响应后，决定是否跳转
 *
 *  @param webView            实现该代理的webview
 *  @param navigationResponse 当前navigation
 *  @param decisionHandler    是否跳转block
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationResponse:(WKNavigationResponse *)navigationResponse decisionHandler:(void (^)(WKNavigationResponsePolicy))decisionHandler {
    
    if (![navigationResponse.response.URL.host.lowercaseString isEqual:self.bandHost]) {
        // 允许跳转
        decisionHandler(WKNavigationResponsePolicyAllow);
        return;
    }
    // 不允许跳转
    decisionHandler(WKNavigationResponsePolicyCancel);
}

/**
 *  在发送请求之前，决定是否跳转
 *
 *  @param webView          实现该代理的webview
 *  @param navigationAction 当前navigation
 *  @param decisionHandler  是否调转block
 */
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
    // 如果请求的是百度地址，则延迟5s以后跳转
    if (![navigationAction.request.URL.host.lowercaseString isEqual:self.bandHost]) {
        // 允许跳转
        decisionHandler(WKNavigationActionPolicyAllow);
        return;
    }
    // 不允许跳转
    decisionHandler(WKNavigationActionPolicyCancel);
}


#pragma mark - WKUIDelegate

/**
 *  web界面中有弹出警告框时调用
 *
 *  @param webView           实现该代理的webview
 *  @param message           警告框中的内容
 *  @param frame             主窗口
 *  @param completionHandler 警告框消失调用
 */

- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL))completionHandler {
    [[[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:nil cancelButtonTitle:@"确认" otherButtonTitles: nil] show];
    completionHandler(YES);
}

- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString *))completionHandler {
    
}

// 从web界面中接收到一个脚本时调用
- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    
    NSLog(@"didReceiveScriptMessage:%@", message);
    if (self.JSActionListenner) {
        [self.JSActionListenner listenFunction:message.name args:message.body];
    }
    
}



#pragma mark - 懒加载 & getter/setter
-(NSURLRequest *)req{
    if (_req == nil) {
        _req = [NSURLRequest requestWithURL:self.url];
    }
    return _req;
}

- (WKWebView *)webView {
    if (_webView == nil) {
        _webView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        // 允许左右划手势导航，默认允许
        _webView.allowsBackForwardNavigationGestures = self.navigationBarUsage;
    }
    
    return _webView;
}

//-(void)setJSActionNames:(NSMutableArray *)JSActionNames{
//    _JSActionNames = JSActionNames;
//    [self loadContext];
//}

@end
