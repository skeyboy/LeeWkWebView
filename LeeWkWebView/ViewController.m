//
//  ViewController.m
//  LeeWkWebView
//
//  Created by 李雨龙 on 2020/4/15.
//  Copyright © 2020 李雨龙. All rights reserved.
//

#import "ViewController.h"
#import "WKWebViewHelper.h"
#import <WebKit/WebKit.h>
@interface ViewController ()
{
    WKWebViewHelper *mWbHelper;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    
    /**
     
    通过构建移动JS 回调 Native App
     
     */
    mWbHelper = [[WKWebViewHelper alloc] initHanlerNpc:@"iOSApp" frame:[UIScreen mainScreen].bounds];
    
    //加载完成后通知JS发送一些消息
    mWbHelper.didFinishNavigationHook = ^NSArray<WKActionHandler *> * _Nullable{
        
        
        NSData * values = [NSJSONSerialization dataWithJSONObject:@{@"token":@"12345"} options:NSJSONWritingFragmentsAllowed
                                            error:nil];
          NSString *other = [[NSString alloc] initWithData:values encoding:NSUTF8StringEncoding];
          
        
        WKActionHandler * tokenHandler = [[WKActionHandler alloc] init];
        tokenHandler.name = @"getToken";
        tokenHandler.actionParamsName = @[@"2345dcddd",other];
        tokenHandler.action = ^(NSDictionary * _Nonnull vales) {
            
        };
        
        return @[
            tokenHandler
      ];
    };
    
    [mWbHelper addAsyncJSHandler:@"shareAction" pramasNames:@[@"title",@"content",@"url"]
                          result:^(NSDictionary * _Nonnull values) {
        
    }];
  
   
    [mWbHelper addAsyncJSHandler:@"popBack" pramasNames:@[] result:^(NSDictionary * _Nonnull values) {
        
    }];
  
    NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    WKWebView * webView =  [mWbHelper buildWithurl:[NSURL fileURLWithPath:path]];
   
      [self.view addSubview:webView];
}


@end
