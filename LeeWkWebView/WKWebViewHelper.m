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
}
@property(strong, nonatomic) NSMutableArray * sycActions;
@property(strong, nonatomic) NSMutableArray * asyncActions;
@end

@implementation WKWebViewHelper
-(instancetype)initHanlerNpc:(NSString *)npcName{
    if (self = [super init]) {
        mNpcName = [npcName copy];
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
        [self.sycActions addObject:handler];
    }
    return self;
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
    WKWebView * wkWebView = [[WKWebView alloc] initWithFrame:[UIScreen mainScreen].bounds
                                               configuration:config];
    wkWebView.UIDelegate = self;
    wkWebView.navigationDelegate = self;
    
    
    [wkWebView loadRequest:[NSURLRequest requestWithURL:url]];
    
    return wkWebView;
}
-(NSString *) createJavaScript{
    NSMutableString * result = [NSMutableString stringWithFormat:@"%@ = {",mNpcName];
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
    NSString * paramsStr = [handler.actionParamsName componentsJoinedByString:@","];

    NSString *func = [NSMutableString stringWithFormat:@"\"%@\":function(){return JSON.stringify(%@);}",handler.name,handler.actionParamsName];
    return func;
}

-(NSString *)serialAsync:(WKActionHandler *) handler{
    
    NSString * paramsStr = [handler.actionParamsName componentsJoinedByString:@","];
  NSString * func =  [NSMutableString stringWithFormat:@"\"%@\":function(%@){window.webkit.messageHandlers.%@.postMessage([%@]);}",handler.name,paramsStr,handler.name,paramsStr];
 return func;
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
