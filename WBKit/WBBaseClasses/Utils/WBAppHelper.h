//
//  WBAppHelper.h
//  FlyClip
//
//  Created by wangbo on 2017/5/4.
//  Copyright © 2017年 tongboshu. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WBAppHelper : NSObject

+ (NSString*)getLocalAppVersion;
+ (NSString*)getBundleID;
+ (NSString*)getAppName;

@end
