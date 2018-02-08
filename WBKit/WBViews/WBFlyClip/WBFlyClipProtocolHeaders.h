//
//  WBFlyClipProtocolHeaders.h
//  WBKit
//
//  Created by wangbo on 2018/2/8.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#ifndef WBFlyClipProtocolHeaders_h
#define WBFlyClipProtocolHeaders_h

#import <UIKit/UIKit.h>

typedef enum{
    WBViewControllerAppearModal = 0,
    WBViewControllerAppearPush,
}WBViewControllerAppear;

@protocol WBFlyClipNodeGestureHandler <NSObject>
@optional
@property (copy) void (^panGestureHandler)(UIPanGestureRecognizer *pan);
@property (copy) void (^tapGestureHandler)(UITapGestureRecognizer *tap);

@end


#endif /* WBFlyClipProtocolHeaders_h */
