//
//  NSObject+PropertyListing.m
//  WBUtil
//
//  Created by Wang Bo. on 14-1-23.
//  Copyright (c) 2014年 Wang Bo. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol PropertyRedirect <NSObject>

/*! @brief 例子
 *
 *     + (NSDictionary *)keyNameForPropertyName {
 *         return @{
 *             @"ID": @"id",
 *             @"pointStatus": @"point",
 *             @"starred": @"starred"
 *         };
 *     }
 */
+ (NSDictionary *)keyNameForPropertyName;

@end

@protocol PropertyArrayWithModels <NSObject>

@optional
/*! @brief 数组属性中包含的model类型数组 */
+ (NSArray *)subModelsInArrayPropertis;

@end

@interface NSObject (PropertyListing) <PropertyRedirect, PropertyArrayWithModels>

-(BOOL)isKindOfData:(id)classtype;
-(NSArray *)methodList;

/*! @brief 将任何自定义对象转换成字典
 * @note 如果本身已经是基本属性，则返回self
 */
-(id)propertyList;

/*! @brief 将字典转换成自定义对象
 * @note 如果本身已经是字典，则返回字典
 */
-(id)initWithDictionary:(NSDictionary *)dictionary;
@end
