//
//  WBMessageTransferStation.h
//  xuxian
//
//  Created by wangbo on 16/11/10.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBMessageTransferStation : NSObject

+ (WBMessageTransferStation *) sharedStation;

-(BOOL)registe:(id)listenner WithIdurl:(NSString *)url;
-(BOOL)remove:(id)listenner ForUrl:(NSString *)url;

-(void)postMessage:(id)message from:(NSString *)fromUrl to:(NSString *)toUrl;

@end
