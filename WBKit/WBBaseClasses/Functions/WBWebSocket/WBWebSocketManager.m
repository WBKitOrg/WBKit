//
//  WBWebSocketManager.m
//
//  Created by wangbo on 16/9/7.
//  Copyright © 2016年 wangbo. All rights reserved.
//

#import "WBWebSocketManager.h"
#import "XXSocketActionParser.h"

@interface WBWebSocketManager()

///消息队列，在队列中的消息都会在队列中
@property(nonatomic ,retain) NSMutableArray *messageQueue;

@end

@implementation WBWebSocketManager
{
    SRWebSocket *_webSocket;//webSocket实例
    NSURL *_connectionUrl;//链接url
    NSTimer *tickTimer;//心跳包计时器
    
    //私有回调，用于方法全局回调
    //链接成功回调
    void(^ConnectSuccessBlock)(BOOL isconnect);
    //链接失败回调
    void(^ConnectErrorBlock)(NSError *err);
//    //发送成功回调
//    void(^MessageSuccessBlock)(BOOL success);
//    //发送失败回调
//    void(^MessageErrorBlock)(NSError *err);
}


static WBWebSocketManager * _sharedManager;

+ (WBWebSocketManager *) sharedManager{
    if (!_sharedManager) {
        _sharedManager = [[WBWebSocketManager alloc] init];
    }
    return _sharedManager;
}

- (id) init {
    self = [super init];
    if (self) {
        NSLog(@"WBWebSocketManager初始化成功");
    }
    return self;
}


#pragma mark - 外部暴露方法

/**
 *  连接服务器方法
 */
- (void)connectUrl:(NSURL *)url success:(void(^)(BOOL isconnect)) success fail:(void(^)(NSError *err)) error{
    //先断开先前链接
    [self disConnect];
    
    //记录链接地址
    _connectionUrl = url;
    
    //连接websocket
    _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:url]];
    _webSocket.delegate = self;
    [_webSocket open];
    
    //回调block赋值
    ConnectSuccessBlock = success;
    ConnectErrorBlock = error;
}

- (void)reconnect{
    //先断开先前链接
    [self disConnect];

    //三秒之后重连
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //连接websocket
        _webSocket = [[SRWebSocket alloc] initWithURLRequest:[NSURLRequest requestWithURL:_connectionUrl]];
        _webSocket.delegate = self;
        [_webSocket open];
    });

}


/**
 *  断开服务器方法
 */
- (void)disConnect{
    _webSocket.delegate = nil;
    [_webSocket close];
    _webSocket = nil;
}

/**
 *  发送消息方法,这里定义消息标示符“ti”,在接收到数据的时候判断是否存在“ti”标签来判断是否确实收到消息
 */
- (void)sendMessage:(NSDictionary *)params success:(void (^)(id))success fail:(void (^)(NSError *))error{
    if (_webSocket.readyState == SR_OPEN) {
        //时间戳
        NSTimeInterval ti = [[NSDate date] timeIntervalSince1970];
        // 发送数据请求
        NSMutableDictionary *sendData = [NSMutableDictionary dictionaryWithDictionary:params];
        [sendData setValue:[NSNumber numberWithInteger:ti] forKey:@"ti"];
        NSError *err = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:sendData options:NSJSONWritingPrettyPrinted error:&err];
        
        NSString *params = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        //将数据打包成WBWebSocketMessage对象，以便在任意地方回调给每一个message
        WBWebSocketMessage *message = [[WBWebSocketMessage alloc] init];
        message.MessageBody = params;//json格式的数据
        message.timeInterval = ti;
        //回调block赋值
        message.SuccessBlock = success;
        message.ErrorBlcok = error;
        
        //加入消息队列
        //先check当前数组中没用的元素，并移除
        @synchronized (self.messageQueue) {
            for (int i = 0; i<self.messageQueue.count; i++) {
                WBWebSocketMessage *msg = [_messageQueue objectAtIndex:i];
                if (!msg.MessageBody){
                    [_messageQueue removeObjectAtIndex:i];
                    i--;
                }
            }
        }
        
        [self.messageQueue addObject:message];
//        NSLog(@"WebSocket _messageQueue中当前存在%lu条消息",_messageQueue.count);
        
        [_webSocket send:params];//都做完之后发送
        
    }else{
        NSLog(@"WebSocket 状态未连接:%ld", (long)_webSocket.readyState);
        NSError *err = [NSError errorWithDomain:@"Socket未连接" code:(long)_webSocket.readyState userInfo:nil];
        error(err);
    }
}



#pragma mark － 链接回调相关方法，可选

// optional
- (void)webSocketDidOpen:(SRWebSocket *)webSocket
{
    NSLog(@"Websocket 已连接:%ld", (long)_webSocket.readyState);
    if (ConnectSuccessBlock) {
        ConnectSuccessBlock(true);//成功回调
        ConnectSuccessBlock = nil;//回调之后清空，避免二次回调
    }else if (self.DidReconnectSuccess){//重连成功回调
        self.DidReconnectSuccess(true);
    }
    
    //设置定时器向服务器发送心跳消息
    
    tickTimer = [NSTimer scheduledTimerWithTimeInterval:10 target:self selector:@selector(timeTick:) userInfo:nil repeats:YES];
}


- (void)webSocket:(SRWebSocket *)webSocket didFailWithError:(NSError *)error
{
    NSLog(@":( Websocket 失败错误:%@", error);
    if (ConnectErrorBlock) {
        ConnectErrorBlock(error);//失败回调
        ConnectErrorBlock = nil;//回调之后清空，避免二次回调
    }else if (self.DidReconnectError){//重连失败回调
        self.DidReconnectError(error);
    }
    
    //webSocket对象清空
    _webSocket = nil;
    
    if (self.reconnectable) {//  断了之后再连接，保持时时连接socket
        [self reconnect];
    }
    
}


- (void)webSocket:(SRWebSocket *)webSocket didCloseWithCode:(NSInteger)code reason:(NSString *)reason wasClean:(BOOL)wasClean
{
    NSLog(@"WebSocket 关闭:%ld", (long)_webSocket.readyState);
    NSError *error = [NSError errorWithDomain:reason?reason:@"" code:code userInfo:nil];
    if (ConnectErrorBlock) {
        ConnectErrorBlock(error);//失败回调
        ConnectErrorBlock = nil;//回调之后清空，避免二次回调
    }else if (self.DidReconnectError){//重连失败回调
        self.DidReconnectError(error);
    }
    
    _webSocket = nil;
    if (self.reconnectable) {// 断了之后再连接，保持时时连接socket
        [self reconnect];
    }
    
    [tickTimer invalidate];//停止心跳
}

// required
- (void)webSocket:(SRWebSocket *)webSocket didReceiveMessage:(id)message
{
    NSLog(@"WebSocket 收到消息 \"%@\"", message);
    NSData *data = [message dataUsingEncoding:NSUTF8StringEncoding];
    NSError *error = nil;
    id responseObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:&error];
    if ([[responseObject valueForKey:@"type"] intValue]==2 && [responseObject valueForKey:@"ti"]) {//如果是反馈消息，进入反馈消息处理代码，这里“ti”是wb定义，如果以后有需要可以自行替换
        for (int i = 0; i<_messageQueue.count; i++) {
            WBWebSocketMessage *msg = [_messageQueue objectAtIndex:i];
            if (msg.timeInterval == [[responseObject valueForKey:@"ti"] integerValue]) {//判断是否是这条消息
                msg.SuccessBlock(message);
                [msg destory];//成功之后自毁
                [_messageQueue removeObjectAtIndex:i];
                break;
            }
        }

    }else if (self.DidRecieveMessage) {//最后如果判断不是消息反馈信息，再进入这里
        self.DidRecieveMessage(message);
    }
    
    //事件处理器单独处理
    if (!self.delegate) {
        //增加websocket的事件处理器
        self.delegate = [XXSocketActionParser sharedActionParser];
    }
    if ([self.delegate respondsToSelector:@selector(DidMessageNeedParse:)]) {
        [self.delegate DidMessageNeedParse:message];
    }
    
}

#pragma mark - 心跳

// 该方法是接受服务器发送的 pong 消息,其中最后一个是接受 pong 消息的
// 其中最后一个是接受pong消息的，在这里就要提一下心跳包，一般情况下建立长连接都会建立一个心跳包，用于每隔一段时间通知一次服务端，客户端还是在线，这个心跳包其实就是一个ping消息，建立一个定时器，每隔十秒或者十五秒向服务端发送一个ping消息，这个消息可是是空的
- (void)webSocket:(SRWebSocket *)webSocket didReceivePong:(NSData *)pongPayload;
{
    
    NSString *reply = [[NSString alloc] initWithData:pongPayload encoding:NSUTF8StringEncoding];
    NSLog(@"WebSocket 心跳%@",reply);
    
//    [tickTimer fire];
    
}
// 发送心跳消息
- (void)timeTick:(NSTimer*) theTimer
{
    if (_webSocket.readyState == SR_OPEN) {//sendPing方法在readyState != SR_OPEN的时候会报错，这里注意
        NSData * data = [@"IOS" dataUsingEncoding:NSUTF8StringEncoding];
        [_webSocket sendPing:data];
    }
}


#pragma mark - 懒加载
///消息队列的懒加载
-(NSMutableArray *)messageQueue{
    if (!_messageQueue) {
        _messageQueue = [NSMutableArray array];
    }
    return _messageQueue;
}

@end
