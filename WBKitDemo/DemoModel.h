//
//  DemoModel.h
//  WBKitDemo
//
//  Created by wangbo on 2018/1/18.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DemoSubModel : NSObject

@property (nonatomic, strong) NSString *propertyString;
@property (nonatomic, assign) NSInteger propertyInt;

@end

@interface DemoModel : NSObject

@property (nonatomic        ) NSInteger ID;
@property (nonatomic, strong) DemoSubModel *propertySubModel;
@property (nonatomic, strong) NSNumber *propertyNumber;

@end
