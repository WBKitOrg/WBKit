//
//  NSObject+SaveToDisk.h
//  WBKit
//
//  Created by wangbo on 2017/12/18.
//  Copyright © 2017年 wangbo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SaveProtocal <NSObject>

@optional
-(NSString *)saveKey;

@end


@interface NSObject (SaveToDisk) <SaveProtocal>

- (void)saveToDisk;
- (void)saveToDiskImmediately;
- (instancetype)getFromDisk;

@end
