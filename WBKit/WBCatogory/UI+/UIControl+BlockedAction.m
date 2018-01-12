//
//  UIControl+BlockedAction.m
//  WBKit
//
//  Created by wangbo on 2018/1/12.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import "UIControl+BlockedAction.h"
#import <objc/runtime.h>

@interface UIControl ()

@property (nonatomic, strong) NSMutableDictionary *actionsForControlEvents;

@end

@implementation UIControl (BlockedAction)

- (void)addAction:(void (^)(void))actionBlock forControlEvents:(UIControlEvents)controlEvents
{
    [self.actionsForControlEvents setObject:actionBlock forKey:@(controlEvents)];
    NSString *methodName = [UIControl eventName:controlEvents];
    [self addTarget:self action:NSSelectorFromString(methodName) forControlEvents:controlEvents];
}

- (void)removeActionForControlEvents:(UIControlEvents)controlEvents
{
    NSString *methodName = [UIControl eventName:controlEvents];
    [self.actionsForControlEvents removeObjectForKey:@(controlEvents)];
    [self removeTarget:self action:NSSelectorFromString(methodName) forControlEvents:controlEvents];
}

-(void)UIControlEventTouchDown{[self callActionBlock:UIControlEventTouchDown];}
-(void)UIControlEventTouchDownRepeat{[self callActionBlock:UIControlEventTouchDownRepeat];}
-(void)UIControlEventTouchDragInside{[self callActionBlock:UIControlEventTouchDragInside];}
-(void)UIControlEventTouchDragOutside{[self callActionBlock:UIControlEventTouchDragOutside];}
-(void)UIControlEventTouchDragEnter{[self callActionBlock:UIControlEventTouchDragEnter];}
-(void)UIControlEventTouchDragExit{[self callActionBlock:UIControlEventTouchDragExit];}
-(void)UIControlEventTouchUpInside{[self callActionBlock:UIControlEventTouchUpInside];}
-(void)UIControlEventTouchUpOutside{[self callActionBlock:UIControlEventTouchUpOutside];}
-(void)UIControlEventTouchCancel{[self callActionBlock:UIControlEventTouchCancel];}
-(void)UIControlEventValueChanged{[self callActionBlock:UIControlEventValueChanged];}
-(void)UIControlEventEditingDidBegin{[self callActionBlock:UIControlEventEditingDidBegin];}
-(void)UIControlEventEditingChanged{[self callActionBlock:UIControlEventEditingChanged];}
-(void)UIControlEventEditingDidEnd{[self callActionBlock:UIControlEventEditingDidEnd];}
-(void)UIControlEventEditingDidEndOnExit{[self callActionBlock:UIControlEventEditingDidEndOnExit];}
-(void)UIControlEventAllTouchEvents{[self callActionBlock:UIControlEventAllTouchEvents];}
-(void)UIControlEventAllEditingEvents{[self callActionBlock:UIControlEventAllEditingEvents];}
-(void)UIControlEventApplicationReserved{[self callActionBlock:UIControlEventApplicationReserved];}
-(void)UIControlEventSystemReserved{[self callActionBlock:UIControlEventSystemReserved];}
-(void)UIControlEventAllEvents{[self callActionBlock:UIControlEventAllEvents];}

- (void)callActionBlock:(UIControlEvents)controlEvents
{
    void (^actionBlock)(void) = [self.actionsForControlEvents objectForKey:@(controlEvents)];
    if (actionBlock) {
        actionBlock();
    }
}

#pragma mark - lazyProperties
static char actionsForControlEventsKey;
- (NSMutableDictionary *)actionsForControlEvents
{
    NSMutableDictionary *actionsForControlEvents = objc_getAssociatedObject(self, &actionsForControlEventsKey);
    if (!actionsForControlEvents) {
        actionsForControlEvents = [NSMutableDictionary dictionary];
        [self setActionsForControlEvents:actionsForControlEvents];
    }
    return actionsForControlEvents;
}

-(void)setActionsForControlEvents:(NSMutableDictionary *)actionsForControlEvents{
    objc_setAssociatedObject(self, &actionsForControlEventsKey, actionsForControlEvents,OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

+(NSString *)eventName:(UIControlEvents)event
{
    switch (event) {
        case UIControlEventTouchDown:          return @"UIControlEventTouchDown";
        case UIControlEventTouchDownRepeat:    return @"UIControlEventTouchDownRepeat";
        case UIControlEventTouchDragInside:    return @"UIControlEventTouchDragInside";
        case UIControlEventTouchDragOutside:   return @"UIControlEventTouchDragOutside";
        case UIControlEventTouchDragEnter:     return @"UIControlEventTouchDragEnter";
        case UIControlEventTouchDragExit:      return @"UIControlEventTouchDragExit";
        case UIControlEventTouchUpInside:      return @"UIControlEventTouchUpInside";
        case UIControlEventTouchUpOutside:     return @"UIControlEventTouchUpOutside";
        case UIControlEventTouchCancel:        return @"UIControlEventTouchCancel";
        case UIControlEventValueChanged:       return @"UIControlEventValueChanged";
        case UIControlEventEditingDidBegin:    return @"UIControlEventEditingDidBegin";
        case UIControlEventEditingChanged:     return @"UIControlEventEditingChanged";
        case UIControlEventEditingDidEnd:      return @"UIControlEventEditingDidEnd";
        case UIControlEventEditingDidEndOnExit:return @"UIControlEventEditingDidEndOnExit";
        case UIControlEventAllTouchEvents:     return @"UIControlEventAllTouchEvents";
        case UIControlEventAllEditingEvents:   return @"UIControlEventAllEditingEvents";
        case UIControlEventApplicationReserved:return @"UIControlEventApplicationReserved";
        case UIControlEventSystemReserved:     return @"UIControlEventSystemReserved";
        case UIControlEventAllEvents:          return @"UIControlEventAllEvents";
        default:
            return @"description";
    }
    return @"description";
}

@end
