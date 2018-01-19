//
//  NSObject+PropertyListing.m
//  WBUtil
//
//  Created by Wang Bo. on 14-1-23.
//  Copyright (c) 2014年 Wang Bo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (PropertyListing)

-(BOOL)isKindOfData:(id)classtype;
-(NSArray *)methodList;

/*! @brief 将任何自定义对象转换成字典
 * @note 如果本身已经是基本属性，则返回self
 */
-(id)propertyList;
-(id)initWithDictionary:(NSDictionary *)dictionary;
@end
