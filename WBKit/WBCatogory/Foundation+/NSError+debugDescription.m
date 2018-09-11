//
//  NSError+debugDescription.m
//  WBKit
//
//  Created by uknow on 2018/9/11.
//  Copyright © 2018年 wangbo. All rights reserved.
//

#import "NSError+debugDescription.h"

@implementation NSError (debugDescription)

- (NSString *)debugDescription {
    
    NSMutableString *desc = [NSMutableString string];
    
    NSData *errorData = self.userInfo[@"com.alamofire.serialization.response.error.data"];
    if (errorData != nil) {
        NSDictionary *serializedData = [NSJSONSerialization JSONObjectWithData: errorData options:kNilOptions error:nil];
        [serializedData.allKeys enumerateObjectsUsingBlock:^(id  _Nonnull key, NSUInteger idx, BOOL * _Nonnull stop) {
            id obj = [serializedData objectForKey:key];
            [desc appendFormat:@"👉 %@ = %@,\n", key, obj];
        }];
        
    }
    return desc;
}


@end
