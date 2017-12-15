//
//  WBURLRoute.h
//  FlyClip
//
//  Created by wangbo on 2017/5/4.
//  Copyright © 2017年 tongboshu. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^WBRouteCallback)(NSDictionary *param);
typedef BOOL (^WBRouteHandler)(NSDictionary *param, WBRouteCallback callback);

@interface WBURLRoute : NSObject

+ (void)registerPattern:(NSString *)pattern handler:(WBRouteHandler)handler;

+ (BOOL)openUrl:(NSString *)url;
+ (BOOL)openUrl:(NSString *)url params:(NSDictionary *)params;
+ (BOOL)openUrl:(NSString *)url params:(NSDictionary *)params callback:(WBRouteCallback)callback;

@end
