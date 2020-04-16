# LeeWkWebView
WKWebView与Native App异步通信封装（JS 主动调用App传递参数）
## 对应好的HTML

```
<!DOCTYPE html>
<html>

<head>
    <title>js Bridge demo</title>
    <meta charset="utf-8">
    <script type="text/javascript">
    function btnClick() {
        try {
            iOSApp.shareAction({"title":"分享", "content":"内容", "url":"链接"})
        } catch (err) {
            alert(err)
        }
    }
    
    //App主动调用这个传递token
    function getToken(token){
        alert(token);
        return token;
    }
    //JS 主动点击获取
    function manualGetToken(){
        alert(iOSApp.manualGetToken())
    }
    function shareLocation(){
        alert(App.shareLocation())
    }
    function getAreaID(token){
           alert(token);
           return token;
       }
    function popBack() {
           try {
<!--               window.webkit.messageHandlers.popBack.postMessage([])-->
iOSApp.popBack([])
           } catch (err) {
               alert(err)
           }
       }
    </script>
</head>

<body>
    <h1>js demo test</h1>
    <p style="text-align: center;">
        <button type="button" onclick="btnClick()" style="font-size: 100px;">test JS</button>
    </p>
    <br>
    <p style="text-align: center;">
           <button type="button" onclick="popBack()" style="font-size: 100px;">返回</button>
       </p>
       
       <p style="text-align: center;">
                <button type="button" onclick="manualGetToken()" style="font-size: 100px;">点击显示token</button>
            </p>
       <p style="text-align: center;">
           <button type="button" onclick="shareLocation()" style="font-size: 100px;">显示位置信息</button>
       </p>
</body>

</html>
```
## 使用方法
```
 /**
     
    通过构建移动JS 回调 Native App
     
     */
    mWbHelper = [[WKWebViewHelper alloc] initHanlerNpc:@"iOSApp"];
    
    [mWbHelper addAsyncJSHandler:@"shareAction" pramasNames:@[@"title",@"content",@"url"]
                          result:^(NSDictionary * _Nonnull values) {
        
    }];
    NSData * values = [NSJSONSerialization dataWithJSONObject:@{@"token":@"12345"} options:NSJSONWritingFragmentsAllowed
                                      error:nil];
    NSString *token = [[NSString alloc] initWithData:values encoding:NSUTF8StringEncoding];
    
   
    [mWbHelper addAsyncJSHandler:@"popBack" pramasNames:@[] result:^(NSDictionary * _Nonnull values) {
        
    }];
  
    NSString *path = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    WKWebView * webView =  [mWbHelper buildWithurl:[NSURL fileURLWithPath:path]];
   
      [self.view addSubview:webView];

```
