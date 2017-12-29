//
//  WBURLRoute.m
//  FlyClip
//
//  Created by wangbo on 2017/5/4.
//  Copyright © 2017年 tongboshu. All rights reserved.
//

#import "WBURLRoute.h"
#import "NSString+URLHelper.h"

#define kWBRouteCallbackKey  "_WBRouteCallback"

@interface WBURLRoute ()

@property (nonatomic, strong) NSMutableDictionary *routeDic;
@property (nonatomic, strong) NSMutableDictionary *handlerDic;


+ (instancetype)sharedRoute;

@end


@implementation WBURLRoute

+ (instancetype)sharedRoute
{
    static dispatch_once_t onceToken;
    static id instance = nil;
    dispatch_once(&onceToken, ^{
        instance = [self new];
    });
    return instance;
}

+ (void)registerPattern:(NSString *)pattern handler:(WBRouteHandler)handler
{
    NSParameterAssert(handler && pattern.length > 0);
    
    //TODO:暂时routeDic中的内容没用到，是增严格定义时使用的
    [[WBURLRoute sharedRoute].routeDic setObject:[pattern getURLParameters] forKey:[pattern getURLSchemHostPath]];
    [[WBURLRoute sharedRoute].handlerDic setObject:handler forKey:[pattern getURLSchemHostPath]];
}

+ (BOOL)openUrl:(NSString *)url
{
    return [self openUrl:url params:nil callback:nil];
}

+ (BOOL)openUrl:(NSString *)url params:(NSDictionary *)params
{
    return [self openUrl:url params:params callback:nil];
}

+ (BOOL)openUrl:(NSString *)url params:(NSDictionary *)params callback:(WBRouteCallback)callback
{
    NSString *key = [url getURLSchemHostPath];
    
    if ([[WBURLRoute sharedRoute].routeDic valueForKey:key]) {
        
        WBRouteHandler handler = [[WBURLRoute sharedRoute].handlerDic valueForKey:key];
        
        NSMutableDictionary *urlParams = [NSMutableDictionary dictionaryWithDictionary:[url getURLParameters]];
        [urlParams addEntriesFromDictionary:params];
        
        handler(urlParams,callback);
        
        return YES;
    }
    
    return NO;
}

#pragma mark - privateMethods


#pragma mark - lazyloading

- (NSMutableDictionary *)routeDic
{
    if (!_routeDic) {
        _routeDic = [NSMutableDictionary dictionary];
    }
    return _routeDic;
}

- (NSMutableDictionary *)handlerDic
{
    if (!_handlerDic) {
        _handlerDic = [NSMutableDictionary dictionary];
    }
    return _handlerDic;
}

@end

