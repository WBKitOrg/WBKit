//
//  NSString+URLHelper.h
//  FlyClip
//
//  Created by wangbo on 2017/5/4.
//  Copyright © 2017年 tongboshu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (URLHelper)

/**
 *  URLSchemHostPath
 */
- (NSString *)getURLSchemHostPath;

/**
 *  URLParameters
 */
- (NSMutableDictionary *)getURLParameters;

/**
 *  URLEncode
 */
- (NSString *)URLEncodedString;

/**
 *  URLDecode
 */
-(NSString *)URLDecodedString;

@end
