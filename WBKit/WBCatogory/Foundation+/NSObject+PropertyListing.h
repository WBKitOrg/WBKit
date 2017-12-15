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

-(NSDictionary *)propertyList;
-(NSArray *)methodList;
-(id)initWithDictionary:(NSDictionary *)dictionary;
@end
