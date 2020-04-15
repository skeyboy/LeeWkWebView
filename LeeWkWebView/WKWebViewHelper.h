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
@interface WKWebViewHelper : NSObject
-(instancetype)initHanlerNpc:(NSString *) npcName;



//添加异步和同步调用
-(WKWebViewHelper *)addAsyncJSHandler:(NSString *) handelrName
                          pramasNames:(NSArray *) paramasName
                               result:(void(^)(NSDictionary * values)) result;
-(WKWebViewHelper *)addSyncJSHandler:(NSString *) handelrName
pramasNames:(NSArray *) paramasName
     result:(void(^)(NSDictionary * values)) result;




-(WKWebView * )buildWithurl:(NSURL *) url;


@end
@interface WKActionHandler : NSObject
@property(copy, nonatomic) NSString * name;
@property(nonatomic, copy) NSArray<NSString *>* actionParamsName;
@property(copy, nonatomic) void(^action)(NSDictionary * vales);

@end
NS_ASSUME_NONNULL_END
