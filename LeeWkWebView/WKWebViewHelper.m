//
//  WKWebViewHelper.m
//  LeeWkWebView
//
//  Created by 李雨龙 on 2020/4/15.
//  Copyright © 2020 李雨龙. All rights reserved.
//

#import "WKWebViewHelper.h"
@interface WKWebViewHelper()<WKScriptMessageHandler,WKUIDelegate,WKNavigationDelegate>
{
    NSString *mNpcName;
    CGRect mFrame;
    WKWebView * mWkWebView;
    BOOL mWKFinishNavigation;
}
@property(strong, nonatomic) NSMutableArray * sycActions;
@property(strong, nonatomic) NSMutableArray * asyncActions;
@end

@implementation WKWebViewHelper
-(instancetype)initHanlerNpc:(NSString *)npcName frame:(CGRect)frame{
    if (self = [super init]) {
        mNpcName = [npcName copy];
        mFrame = frame;
    }
    return self;
}
-(void)addSyncAction:(WKActionHandler *)actionHandler{
    if (self.sycActions == nil) {
        self.sycActions = [NSMutableArray arrayWithCapacity:0];
    }
    NSAssert(![self.sycActions containsObject:actionHandler], @"方法不能重名");

    [self.sycActions addObject:actionHandler];
}
-(void)addAsyncAction:(WKActionHandler *)actionHandler{
    if (self.asyncActions == nil) {
        self.asyncActions = [NSMutableArray arrayWithCapacity:0];
    }
    NSAssert(![self.asyncActions containsObject:actionHandler], @"方法不能重名");
        [self.asyncActions addObject:actionHandler];
}
-(WKWebViewHelper *)addAsyncJSHandler:(NSString *)handelrName
             pramasNames:(NSArray *)paramasName
                  result:(void(^)(NSDictionary * values)) result{
    WKActionHandler * handler = [[WKActionHandler alloc] init];
    handler.actionParamsName = paramasName;
    handler.name = handelrName;
    handler.action = result;
   
    if (![self.asyncActions containsObject:handler]) {
        [self addAsyncAction:handler];
    }
    return self;
}

-(WKWebViewHelper *)addSyncJSHandler:(NSString *)handelrName
             pramasNames:(NSArray *)paramasName
                  result:(void(^)(NSDictionary * values)) result{
    WKActionHandler * handler = [[WKActionHandler alloc] init];
    handler.actionParamsName = paramasName;
    handler.name = handelrName;
    handler.action = result;
    if (![self.sycActions containsObject:handler]) {
        [self addSyncAction:handler];
    }
    return self;
}
-(void)manualAppCallJS:(WKActionHandler *)handler{
    if (mWKFinishNavigation) {
        [self handelAppCallJs:handler];
    }else{
        while (!mWKFinishNavigation) {
            //等待加载完成
        }
        [self manualAppCallJS:handler];
    }
}
-(WKWebView * )buildWithurl:(NSURL *) url{
    WKWebViewConfiguration * config =  [[WKWebViewConfiguration alloc] init];
    config.preferences = [[WKPreferences alloc] init];
    
    config.preferences.javaScriptEnabled = YES;
    config.userContentController = [[WKUserContentController alloc] init];
    if (self.asyncActions.count || self.sycActions.count) {
        //加载是将方法等直接注入其中
  WKUserScript * wkUserScript =      [[WKUserScript alloc] initWithSource:[self createJavaScript]
                               injectionTime:WKUserScriptInjectionTimeAtDocumentStart forMainFrameOnly:YES];
        
        [config.userContentController addUserScript:wkUserScript];
    }
    for (WKActionHandler * action in self.asyncActions) {
        [config.userContentController addScriptMessageHandler:self
                                                         name:action.name];
    }
    mWkWebView = [[WKWebView alloc] initWithFrame:mFrame
                                               configuration:config];
    mWkWebView.UIDelegate = self;
    mWkWebView.navigationDelegate = self;
    
    
    [mWkWebView loadRequest:[NSURLRequest requestWithURL:url]];
    
    return mWkWebView;
}

-(NSString *) createJavaScript{
    NSString * result = [NSString stringWithFormat:@"%@ = {",mNpcName];
    NSMutableArray * actions = [NSMutableArray arrayWithCapacity:0];
    for (WKActionHandler *handler in self.asyncActions) {
        NSString * aAction = [self serialAsync:handler];
        [actions addObject:aAction];
    }
    for (WKActionHandler * handler in self.sycActions) {
        [actions addObject:[self serialSync:handler]];
    }
  result =  [result stringByAppendingFormat:@"%@}",[actions componentsJoinedByString:@","]];
    return result;
}
-(NSString *)serialSync:(WKActionHandler *) handler{
    NSMutableArray * items = [NSMutableArray arrayWithCapacity:0];
    for (NSString *p in handler.actionParamsName) {
        [items addObject:[NSString stringWithFormat:@"`%@`",p]];
    }
    NSString * paramsStr = [items componentsJoinedByString:@","];

    NSString *func = [NSMutableString stringWithFormat:@"%@(%@);",handler.name,paramsStr];
    return func;
}

-(NSString *)serialAsync:(WKActionHandler *) handler{
    
    NSString * paramsStr = [handler.actionParamsName componentsJoinedByString:@","];
  NSString * func =  [NSMutableString stringWithFormat:@"\"%@\":function(%@){window.webkit.messageHandlers.%@.postMessage([%@]);}",handler.name,paramsStr,handler.name,paramsStr];
 return func;
}
-(void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation{
    mWKFinishNavigation = YES;
    if (self.didFinishNavigationHook != nil) {
        for (WKActionHandler * handler in self.didFinishNavigationHook()) {
            [self handelAppCallJs:handler];
        }
    }
}
-(void)handelAppCallJs:(WKActionHandler *) handler{
    NSString * jsAction =   [self serialSync:handler];
               [mWkWebView evaluateJavaScript:jsAction
                         completionHandler:^(id _Nullable value, NSError * _Nullable error) {
                   if (error == nil && value != nil) {
                       handler.action(value);
                   }
               }];
}
- (void)userContentController:(nonnull WKUserContentController *)userContentController didReceiveScriptMessage:(nonnull WKScriptMessage *)message {
    for (WKActionHandler * action in self.asyncActions) {
        if ([action.name isEqualToString:message.name]) {
            NSMutableDictionary * revValues = [NSMutableDictionary dictionary];
            NSArray * messgeValues = message.body;
            NSInteger index = 0;
            NSDictionary * values = messgeValues.firstObject;
           
            for (; index< action.actionParamsName.count; index++   ) {
                NSString *key = action.actionParamsName[index];
                
                revValues[key] = values[key];
                
            }
            action.action(revValues);

            break;
        }
    }
}
-(void)dealloc{
    
}
@end

@implementation WKActionHandler

-(BOOL)isEqual:(WKActionHandler *)object{
    return [self.name isEqualToString:object.name];
}

@end
