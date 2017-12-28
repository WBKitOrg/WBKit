//
//  WBModuleManager.h
//  WBKit
//
//  Created by wangbo on 2017/12/27.
//  Copyright © 2017年 wangbo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define REGISTER_MODULE \
+(void)load \
{[[WBModuleManager sharedManager] registerModule:[self class]];}

#define REGISTER_SERVICE(serviceProtocol) \
+(void)load \
{[[WBModuleManager sharedManager] registerService:@protocol(serviceProtocol) withClass:[self class]];}

#define SERVICE(serviceProtocol) \
[[WBModuleManager sharedManager] findService:@protocol(serviceProtocol)]

@interface WBModuleManager : NSObject

+ (instancetype)sharedManager;

- (void)start;

- (void)registerModule:(Class)moduleClass;
- (id)findModule:(Class)moduleClass;

- (void)registerService:(Protocol *)service withClass:(Class)serviceClass;
- (id)findService:(Protocol *)protocol;
- (id)findServiceByName:(NSString *)protocolName;

@end
