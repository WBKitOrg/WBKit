//
//  WBMessageTransferStation.m
//  xuxian
//
//  Created by wangbo on 16/11/10.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "WBMessageTransferStation.h"
#import "NSObject+MessageRequest.h"

@interface WBMessageTransferStation ()
@property (nonatomic , retain)NSMutableDictionary *registedRecievers;
@end


@implementation WBMessageTransferStation

static WBMessageTransferStation * _sharedStation;
+ (WBMessageTransferStation *) sharedStation{
    if (!_sharedStation) {
        _sharedStation = [[WBMessageTransferStation alloc] init];
    }
    return _sharedStation;
}

-(BOOL)registe:(id)listenner WithIdurl:(NSString *)url{
    if ([[self.registedRecievers allKeys] containsObject:url]) {
        if ([[self.registedRecievers valueForKey:url] isEqual:listenner]) {
            //已经包含url并且有另外的实例使用这个url，注册失败
            return NO;
        }
        //已经包含url但是没有另外实例，表示该实例已经用这个url注册过了
        return YES;
    }else{
        //未注册过的实例，使用弱引用注册进registedRecievers
        NSValue *value = [NSValue valueWithNonretainedObject:listenner];
        [self.registedRecievers setObject:value forKey:url];
        return YES;
    }
}

-(BOOL)remove:(id)listenner ForUrl:(NSString *)url{
    //注销监听对象
    if ([self.registedRecievers objectForKey:url]) {
        [self.registedRecievers removeObjectForKey:url];
        return YES;
    }
    NSLog(@"WBMessageTransferStation: Has no listenner with url:%@!",url);
    return NO;
}


-(void)postMessage:(id)message from:(NSString *)fromUrl to:(NSString *)toUrl{
    
    for (NSString *respUrlStr in _registedRecievers.allKeys) {
        NSURL *respUrl = [NSURL URLWithString:respUrlStr];
        if ([respUrl.host isEqualToString:[NSURL URLWithString:toUrl].host]) {
            NSObject<WBMessageRequestCallbackDelegate> *req = [[_registedRecievers objectForKey:fromUrl] nonretainedObjectValue];
            NSObject<WBMessageRequestListener> *resp = [[_registedRecievers objectForKey:respUrlStr] nonretainedObjectValue];
            //是一个类,则发送消息
            __strong NSObject<WBMessageRequestCallbackDelegate> *reqer = req;
            __strong NSObject<WBMessageRequestListener> *resper = resp;
            
            if (reqer && resper) {
                if ([reqer WB_NeedCompish]) {
                    if ([resper respondsToSelector:@selector(WB_listenRequest:response:)]) {
                        [resper WB_listenRequest:message response:[reqer WB_NeedCompish]];
                    }else{
                        NSLog(@"WBMessageTransferStation: The calling responser does not listen request!");
                    }
                    //回调后取消callback,确保只回调一次
                    [reqer setWB_NeedCompish:nil];
                }
                else{
                    if ([resper respondsToSelector:@selector(WB_listenRequest:response:)]) {
                        [resper WB_listenRequest:message response:^(id responseParams) {
                            NSLog(@"WBMessageTransferStation: The requster does not responds callback!");
                        }];
                    }
                }
            }else{
                NSLog(@"WBMessageTransferStation: An error accoured with requester:%@ , responser:%@",reqer,resper);
            }
            
        }
    }
    
}



//_registedRecievers懒加载
-(NSMutableDictionary *)registedRecievers{
    if (!_registedRecievers) {
        _registedRecievers = [NSMutableDictionary dictionary];
    }
    return _registedRecievers;
}


@end
