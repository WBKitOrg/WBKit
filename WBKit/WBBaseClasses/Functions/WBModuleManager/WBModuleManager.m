//
//  WBModuleManager.m
//  WBKit
//
//  Created by wangbo on 2017/12/27.
//  Copyright © 2017年 wangbo. All rights reserved.
//

#import "WBModuleManager.h"
#import "WBModule.h"
#import "WBService.h"

#define PROFILE 1

#if PROFILE
#define PROFILE_TIME_START(which) NSDate *which##Start = [NSDate date];
#define PROFILE_TIME_END(which, msg) \
do {NSTimeInterval which##Duration = [[NSDate date] timeIntervalSinceDate:which##Start]; \
NSLog(@"%@ cost seconds: %@", msg, @(which##Duration)); \
} while(0);
#else
#define PROFILE_TIME_START(which)
#define PROFILE_TIME_END(which, msg)
#endif

@interface WBModuleManager ()

@property (nonatomic, strong) NSMutableDictionary *moduleClasses;
@property (nonatomic, strong) NSMutableDictionary *modules;
@property (nonatomic, strong) NSArray             *sortedModuleClassNames;

@property (nonatomic, strong) NSMutableDictionary *serviceClasses;
@property (nonatomic, strong) NSMutableDictionary *services;
@property (nonatomic, strong) NSArray             *sortedServiceNames;

@property (nonatomic, strong) dispatch_queue_t ioQueue;

@property (nonatomic, strong) NSDate *backgroundTimeStamp;

@end

@implementation WBModuleManager

+ (instancetype)sharedManager
{
    static dispatch_once_t onceToken;
    static WBModuleManager *manager = nil;
    dispatch_once(&onceToken, ^{
        manager = [WBModuleManager new];
    });
    return manager;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.moduleClasses = [NSMutableDictionary dictionaryWithCapacity:20];
        self.modules = [NSMutableDictionary dictionaryWithCapacity:20];
        self.serviceClasses = [NSMutableDictionary dictionaryWithCapacity:20];
        self.services = [NSMutableDictionary dictionaryWithCapacity:20];
        NSString *queueName = @"WBQueueIo";
        self.ioQueue = dispatch_queue_create([queueName cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);
        dispatch_set_target_queue(self.ioQueue, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
        
        NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
        [notificationCenter addObserver:self
                               selector:@selector(appDidEnterBackground)
                                   name:UIApplicationDidEnterBackgroundNotification
                                 object:nil];
        [notificationCenter addObserver:self
                               selector:@selector(appWillEnterForeground)
                                   name:UIApplicationWillEnterForegroundNotification
                                 object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark --lifecycle

- (void)start
{
    PROFILE_TIME_START(MODULES_LOAD)
    
    [self loadModules];
    [self loadGlobalServices];
    
    [self launchModulesInBackgroundCompleteBlock:^{
        [self notifyModulesLaunchFinish];
        PROFILE_TIME_END(MODULES_LOAD, @"ModulesLoad")
    }];
}

- (void)appDidEnterBackground
{
    [self enumberateModules:^(NSString *moduleClassName, id<WBModule> module) {
        if ([module respondsToSelector:@selector(moduleDidEnterBackground:)]) {
            [module moduleDidEnterBackground:self];
        }
    }];
    self.backgroundTimeStamp = [NSDate date];
}

- (void)appWillEnterForeground
{
    NSTimeInterval duration = [[NSDate date] timeIntervalSinceDate:self.backgroundTimeStamp];
    [self enumberateModules:^(NSString *moduleClassName, id<WBModule> module) {
        if ([module respondsToSelector:@selector(moduleWillEnterForeground:invisibleDuration:)]) {
            [module moduleWillEnterForeground:self invisibleDuration:duration];
        }
    }];
}

#pragma mark --modules

- (void)registerModule:(Class)moduleClass
{
    NSParameterAssert(moduleClass && [moduleClass conformsToProtocol:@protocol(WBModule)]);
    
    NSString *moduleClassName = NSStringFromClass(moduleClass);
    Class oldModuleClass = [self.moduleClasses objectForKey:moduleClassName];
    NSAssert(oldModuleClass == nil, @"Duplicate module register");
    
    [self.moduleClasses setObject:moduleClass forKey:moduleClassName];
}

- (id)findModule:(Class)moduleClass
{
    NSString *moduleClassName = NSStringFromClass(moduleClass);
    return [self.modules objectForKey:moduleClassName];
}

- (void)loadModules
{
    //排序Module
    self.sortedModuleClassNames =  [self.moduleClasses keysSortedByValueUsingComparator:^NSComparisonResult(id  value1, id  value2) {
        NSInteger priority1 = [self priorityOfClass:value1];
        NSInteger priority2 = [self priorityOfClass:value2];
        return priority1 == priority2 ?
        NSOrderedSame :
        (priority1 < priority2 ? NSOrderedDescending : NSOrderedAscending);
    }];
    
    //初始化Module对象
    NSInteger count = self.sortedModuleClassNames.count;
    for (NSInteger index = 0; index < count; ++index) {
        NSString *className = self.sortedModuleClassNames[index];
        Class moduleClass = self.moduleClasses[className];
        id<WBModule> moduleInstance = [moduleClass new];
        [self.modules setObject:moduleInstance forKey:className];
    }
    
    //调用moduleDidInit:
    [self enumberateModules:^(NSString *moduleClassName, id<WBModule> module) {
        if ([module respondsToSelector:@selector(moduleDidInit:)]) {
            PROFILE_TIME_START(MODULE_DID_INIT)
            [module moduleDidInit:self];
            NSString *msg = [NSString stringWithFormat:@"moduleDidInit(%@)", moduleClassName];
            PROFILE_TIME_END(MODULE_DID_INIT, msg)
        }
    }];
}

- (void)launchModulesInBackgroundCompleteBlock:(void (^)(void))completeBlock
{
    dispatch_async(self.ioQueue, ^{
        [self enumberateModules:^(NSString *moduleClassName, id<WBModule> moduleInstance) {
            if ([moduleInstance respondsToSelector:@selector(moduleLaunchInBackground:)]) {
                PROFILE_TIME_START(moduleLaunchInBackground)
                [moduleInstance moduleLaunchInBackground:self];
                NSString *msg = [NSString stringWithFormat:@"moduleLaunchInBackground(%@)", moduleClassName];
                PROFILE_TIME_END(moduleLaunchInBackground, msg)
            }
        }];
        if (completeBlock) {
            dispatch_async(dispatch_get_main_queue(), completeBlock);
        }
    });
}

- (void)notifyModulesLaunchFinish
{
    [self enumberateModules:^(NSString *moduleClassName, id<WBModule>module) {
        if ([module respondsToSelector:@selector(moduleDidLaunchFinished:)]) {
            PROFILE_TIME_START(moduleDidLaunchFinished)
            [module moduleDidLaunchFinished:self];
            NSString *msg = [NSString stringWithFormat:@"moduleDidLaunchFinished(%@)", moduleClassName];
            PROFILE_TIME_END(moduleDidLaunchFinished, msg)
        }
    }];
}

- (void)enumberateModules:(void (^)(NSString *moduleClassName, id<WBModule> module))block
{
    NSInteger count = self.sortedModuleClassNames.count;
    for (NSInteger index = 0; index < count; ++index) {
        NSString *className = self.sortedModuleClassNames[index];
        id<WBModule> moduleInstance = self.modules[className];
        block(className, moduleInstance);
    }
}

- (NSInteger)priorityOfClass:(Class)moduleClass
{
    if ([moduleClass respondsToSelector:@selector(priority)]) {
        return [moduleClass priority];
    }
    return WBModulePriorityDefault;
}


#pragma mark --Services

- (void)registerService:(Protocol *)service withClass:(Class)serviceClass;
{
    NSParameterAssert(service != nil && serviceClass != nil);
    NSString *serviceProtocolName = NSStringFromProtocol(service);
    Class oldServiceClass = [self.serviceClasses objectForKey:serviceProtocolName];
    NSAssert(oldServiceClass == nil, @"Duplicate register seervice");
    
    [self.serviceClasses setObject:serviceClass forKey:serviceProtocolName];
}

- (id)findService:(Protocol *)protocol
{
    NSString *protocolName = NSStringFromProtocol(protocol);
    return [self findServiceByName:protocolName];
}

- (id)findServiceByName:(NSString *)protocolName
{
    id<WBService> service = [self.services objectForKey:protocolName];
    if (!service) {
        Class serviceClass = [self.serviceClasses objectForKey:protocolName];
        NSAssert(serviceClass != nil, @"Cannot found service: %@, forgot register?", protocolName);
        service = [serviceClass new];
    }
    return service;
}

- (void)loadGlobalServices
{
    self.sortedServiceNames = [self.serviceClasses allKeys];//暂时不排序
    [self.sortedServiceNames enumerateObjectsUsingBlock:^(NSString *serviceName, NSUInteger idx, BOOL * _Nonnull stop) {
        Class serviceClass = [self.serviceClasses objectForKey:serviceName];
        BOOL isGlobal = NO;
        if ([serviceClass respondsToSelector:@selector(isGlobal)]) {
            isGlobal = [serviceClass isGlobal];
        }
        if (isGlobal) {
            id<WBService> service = [serviceClass new];
            [self.services setObject:service forKey:serviceName];
        }
    }];
}


@end
