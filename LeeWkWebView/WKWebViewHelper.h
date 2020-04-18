//
//  WKWebViewHelper.h
//  LeeWkWebView
//
//  Created by 李雨龙 on 2020/4/15.
//  Copyright © 2020 李雨龙. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <WebKit/WebKit.h>
NS_ASSUME_NONNULL_BEGIN
@class WKActionHandler;
typedef NSArray<WKActionHandler *>* _Nullable (^DidFinishNavigationHook)(void);
@interface WKWebViewHelper : NSObject
-(instancetype)initHanlerNpc:(NSString *) npcName frame:(CGRect) frame;

/// 当web加载完成后主动发消息给JS
@property(copy, nonatomic) DidFinishNavigationHook didFinishNavigationHook  ;

//添加异步等待JS 调用 App进行通信
-(WKWebViewHelper *)addAsyncJSHandler:(NSString *) handelrName
                          pramasNames:(NSArray *) paramasName
                               result:(void(^)(NSDictionary * values)) result;
-(WKWebViewHelper *)addSyncJSHandler:(NSString *) handelrName
pramasNames:(NSArray *) paramasName
     result:(void(^)(NSDictionary * values)) result;


- (void)manualAppCallJS:(WKActionHandler *) handler;

-(WKWebView * )buildWithurl:(NSURL *) url;


@end
@interface WKActionHandler : NSObject
@property(copy, nonatomic) NSString * name;
@property(nonatomic, copy) NSArray<NSString *>* actionParamsName;
@property(copy, nonatomic) void(^action)(id  vales);

@end
NS_ASSUME_NONNULL_END
