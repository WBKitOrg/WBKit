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

+ (WBMessageTransferStation *) sharedStation{
    static dispatch_once_t onceToken;
    static WBMessageTransferStation * _sharedStation = nil;
    dispatch_once(&onceToken, ^{
        _sharedStation = [[WBMessageTransferStation alloc] init];
    });
    return _sharedStation;
}

-(BOOL)registe:(id)listenner wb_id:(NSString *)identification{
    if ([[self.registedRecievers allKeys] containsObject:identification]) {
        if ([[self.registedRecievers valueForKey:identification] isEqual:listenner]) {
            //已经包含url并且有另外的实例使用这个url，注册失败
            return NO;
        }
        //已经包含url但是没有另外实例，表示该实例已经用这个url注册过了
        return YES;
    }else{
        //未注册过的实例，使用弱引用注册进registedRecievers
        NSValue *value = [NSValue valueWithNonretainedObject:listenner];
        [self.registedRecievers setObject:value forKey:identification];
        return YES;
    }
}

-(BOOL)remove:(id)listenner wb_id:(NSString *)identification{
    //注销监听对象
    if ([self.registedRecievers objectForKey:identification]) {
        [self.registedRecievers removeObjectForKey:identification];
        return YES;
    }
    NSLog(@"WBMessageTransferStation: Has no listenner with id:%@!",identification);
    return NO;
}


-(void)postMessage:(id)message from:(NSString *)fromId to:(NSString *)toId{
    
    for (NSString *respUrlStr in _registedRecievers.allKeys) {
        NSURL *respUrl = [NSURL URLWithString:respUrlStr];
        if ([respUrl.host isEqualToString:[NSURL URLWithString:toId].host]) {
            NSObject<WBMessageRequestCallbackDelegate> *req = [[_registedRecievers objectForKey:fromId] nonretainedObjectValue];
            NSObject<WBMessageRequestListener> *resp = [[_registedRecievers objectForKey:respUrlStr] nonretainedObjectValue];
            //是一个类,则发送消息
            __strong NSObject<WBMessageRequestCallbackDelegate> *reqer = req;
            __strong NSObject<WBMessageRequestListener> *resper = resp;
            
            if (reqer && resper) {
                if ([reqer needComplete]) {
                    if ([resper respondsToSelector:@selector(listenRequest:response:)]) {
                        [resper listenRequest:message response:[reqer needComplete]];
                    }else{
                        NSLog(@"WBMessageTransferStation: The calling responser does not listen request!");
                    }
                    //回调后取消callback,确保只回调一次
                    [reqer setNeedComplete:nil];
                } else {
                    if ([resper respondsToSelector:@selector(listenRequest:response:)]) {
                        [resper listenRequest:message response:^(id responseParams) {
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
