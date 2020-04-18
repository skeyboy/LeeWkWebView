# LeeWkWebView 起因
之前lz公众号写个关于UIWebView的JS与App通信的文章，但是最新iOS审核规定需要替换掉UIWebView使用WKWebView才可以过审。但是之前有大量UIWebView交互的地方，怎么办？
于是根据原有的交互经验抽离出来了LeeWKWebView……当然了希望大家能够喜欢，多多提意见
# 使用

> pod 'LeeWkWebView',:git=>'git@github.com:skeyboy/LeeWkWebView.git'

之前不完善有了简单的介绍，今天就完善一下
为了方便js调用识别我们为我们的句柄起了名字--npc
>    mWbHelper = [[WKWebViewHelper alloc] initHanlerNpc:@"iOSApp" frame:[UIScreen mainScreen].bounds];

## 1 增加Web加载完成时App主动给JS发信息的功能
在做实际项目中web端提了个功能就是，当你App加载资源结束后，你给我web发送些信息---token，App位置信息（经纬度）……
```objective-c
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
```

## 2 App等待接收web通信
这个要说的比较典型的就是有一天，项目突然提了我在加载web资讯的页面也想增加分享---调用App原生进行微信分享。……哈哈，这都什么需求啊，但是咱们还是需要满足的
```
[mWbHelper addAsyncJSHandler:@"shareAction" pramasNames:@[@"title",@"content",@"url"]
                          result:^(NSDictionary * _Nonnull values) {
        
    }];
  
```
再比如说，咱么使用导航push一个页面加载web，需要让web也能通知app进行pop
```

    [mWbHelper addAsyncJSHandler:@"popBack" pramasNames:@[] result:^(NSDictionary * _Nonnull values) {
        
    }];
    ```


## 3 通过人工操作App调用JS
项目中我们除了遇到上面两种被动的，也会遇到需要我么通过触动UI实现App调用web进行通信的情况，此时我们怎么做呢？🌰是我们通过点击button实现了App与JS的通信
```
- (IBAction)manualCallJs:(id)sender {
    
    
           WKActionHandler * tokenHandler = [[WKActionHandler alloc] init];
           tokenHandler.name = @"getToken";
           tokenHandler.actionParamsName = @[@"2345dcddd",[NSString stringWithFormat:@"%s",__func__]];
           tokenHandler.action = ^(NSDictionary * _Nonnull vales) {
               
           };
    [mWbHelper manualAppCallJS:tokenHandler];
    
}
```
## 4 最后是加载web对应的url啦
我们以加载本的一个HTML为例
```
    NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    WKWebView * webView =  [mWbHelper buildWithurl:[NSURL fileURLWithPath:path]];
```
![w](https://mmbiz.qpic.cn/mmbiz_gif/ic94zQJB2GfmkfkDqyleWPQz92vsWLnYXe5UKeKycbEPRCoEW50ye9LZoyibHtGVFjOn2tNic2X8U4GGbedic5TMFQ/640?wx_fmt=gif&wxfrom=5&wx_lazy=1)
