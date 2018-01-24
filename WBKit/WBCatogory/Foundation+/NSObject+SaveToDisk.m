//
//  NSObject+SaveToDisk.m
//  WBKit
//
//  Created by wangbo on 2017/12/18.
//  Copyright © 2017年 wangbo. All rights reserved.
//

#import "NSObject+SaveToDisk.h"
#import "NSObject+PropertyListing.h"

@implementation NSObject (SaveToDisk)

#pragma mark - PublicMothods

- (instancetype)getFromDisk
{
    NSDictionary *dic = [self propertyJSONDictionaryFromDiskWithPath:nil];
    Class selfClass = [self class];
    id model;
    if (dic) {
        model = [[selfClass alloc] initWithDictionary:dic];
    }
    return model;
}

- (void)saveToDisk
{
    [self saveToDiskWithPath:nil];
}

- (void)saveToDiskImmediately
{
    [self saveToDiskImmediatelyWithPath:nil];
}

#pragma mark - save Founctions

//protocal need tobe implement
- (NSString *)saveKey
{
    return NSStringFromClass([self class]);
}

- (NSString *)savePath
{
    NSArray  *searchPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *DocPath = [searchPath objectAtIndex:0];
    return [NSString stringWithFormat:@"%@/%@/%@", DocPath, NSStringFromClass([self class]), [self saveKey]];
}

- (void)saveToDiskWithPath:(NSString *)path
{
    // 延时1秒保存
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(saveToDiskImmediatelyWithPath:) object:path];
    [self performSelector:@selector(saveToDiskImmediatelyWithPath:) withObject:path afterDelay:1];
}

- (void)saveToDiskImmediatelyWithPath:(NSString *)path
{
    if (!path) {
        path = [self savePath];
    }
    
    NSDictionary *contentToSave = [self propertyList];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSData *data = [NSJSONSerialization dataWithJSONObject:contentToSave options:kNilOptions error:nil];
        [fileManager createDirectoryAtPath:[path stringByDeletingLastPathComponent] withIntermediateDirectories:YES attributes:nil error:NULL];
        BOOL ret = [fileManager createFileAtPath:[path stringByAppendingString:@".tmp"]
                                        contents:data
                                      attributes:nil];
        if (!ret) return;
        // 不检测返回值，因为如果没有文件就会失败
        [fileManager removeItemAtPath:path error:NULL];
        ret = [fileManager moveItemAtPath:[path stringByAppendingString:@".tmp"] toPath:path error:nil];
        if (!ret) return;
    });
}

#pragma mark - get Founctions

- (NSDictionary *)propertyJSONDictionaryFromDiskWithPath:(NSString *)path
{
    if (!path) {
        path = [self savePath];
    }
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
        NSData *data = [NSData dataWithContentsOfFile:path];
        return [[self class] dictionaryWithJsonData:data];
    }
    
    return nil;
}

+ (id)dictionaryWithJsonData:(NSData*)data
{
    if(!data)
    {
        NSLog(@"error: data is nil");
        return nil;
    }
    
    NSDictionary *ret = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
    
    if(ret && ![ret isKindOfClass:[NSDictionary class]])
    {
        NSLog(@"error: data not a NSDictionary json");
        return nil;
    }
    
    return ret;
}

@end
