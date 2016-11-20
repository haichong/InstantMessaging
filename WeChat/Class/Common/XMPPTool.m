//
//  XMPPTool.m
//  WeChat
//
//  Created by FuHang on 16/10/24.
//  Copyright © 2016年 付航. All rights reserved.
//

#import "XMPPTool.h"
NSString *const LoginStatusNotification = @"LoginStatusNotification";

@implementation XMPPTool

+(XMPPTool *)shareXMPPTool{
    static XMPPTool *tool;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool = [[self alloc] init];
    });
    return tool;
}
#pragma mark - XMPP
/*
 在AppDelegate实现登陆
 **/
//1.初始化XMPPStream类
- (void)setupXMPPStream {
    _xmppStream = [[XMPPStream alloc] init];
    
#warning 每一个模块添加都要激活
    // 自动连接模块
    _reconnect = [[XMPPReconnect alloc] init];
    [_reconnect activate:_xmppStream];
    
    // 添加电子名片模块
    _vCardStorage = [XMPPvCardCoreDataStorage sharedInstance];
    _vCard = [[XMPPvCardTempModule alloc] initWithvCardStorage:_vCardStorage];
    // 激活
    [_vCard activate:_xmppStream];
    
    // 添加头像模块
    _vCardAvatar = [[XMPPvCardAvatarModule alloc] initWithvCardTempModule:_vCard];
    [_vCardAvatar activate:_xmppStream];
    
    // 花名册
    _rosterStorage = [[XMPPRosterCoreDataStorage alloc] init];
    _roster = [[XMPPRoster alloc] initWithRosterStorage:_rosterStorage];
    [_roster activate:_xmppStream];
    
    // 消息模块
    _msgStorage = [XMPPMessageArchivingCoreDataStorage sharedInstance];
    _msgArchiving = [[XMPPMessageArchiving alloc] initWithMessageArchivingStorage:_msgStorage];
    [_msgArchiving activate:_xmppStream];
    // 设置代理
    [_xmppStream addDelegate:self delegateQueue:dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)];
}
#pragma mark - 销毁xmpp
- (void)teardownxmpp{
    // 移除代理
    [_xmppStream removeDelegate:self];
    // 停止模块
    [_reconnect deactivate];
    [_vCard deactivate];
    [_vCardAvatar deactivate];
    [_roster deactivate];
    [_msgArchiving deactivate];
    // 断开连接
    [_xmppStream disconnect];
    // 清空资源
    _reconnect = nil;
    _vCard = nil;
    _vCardAvatar = nil;
    _xmppStream = nil;
    _roster = nil;
    _msgArchiving = nil;
}
//2.连接到服务器：传一个JID
- (void)conneectToHost{
    [self postNotification:XMPPResultTypeConnecting];
    WCLog(@"开始连接到服务器");
    if (!_xmppStream) {
        [self setupXMPPStream];
    }
    // domin：服务器的域名
    // resource 标识客户端设备
    NSString *user;
    if (self.isRegisterOperation) {
        user = [[NSUserDefaults standardUserDefaults] objectForKey:RegisterUser];
    }else{
        user = [[NSUserDefaults standardUserDefaults] objectForKey:User];
        
    }
    XMPPJID *myJID = [XMPPJID jidWithUser:user domain:@"fuhangdemacbook-pro.local" resource:@"iphone"];
    _xmppStream.myJID = myJID;
    // 设置服务器的域名或者IP地址
    _xmppStream.hostName = @"fuhangdemacbook-pro.local";
    // 设置端口
    _xmppStream.hostPort = 5222;
    NSError *err = nil;
    if ([_xmppStream connectWithTimeout:XMPPStreamTimeoutNone error:&err]) {
        
    }else{
        WCLog(@"err=%@",err);
        [self postNotification:XMPPResultTypeNetError];

    }
}
#pragma mark - 通知History控制器
- (void)postNotification: (XMPPResultType)type {
    [[NSNotificationCenter defaultCenter] postNotificationName:LoginStatusNotification object:@(type)];
}
//3.连接到服务器成功后在发送一个密码，进行授权
- (void)sendPwdToHost{
    NSError *err = nil;
    NSString *pwd = [[NSUserDefaults standardUserDefaults] objectForKey:Pwd];
    [_xmppStream authenticateWithPassword:pwd error:&err];
    if (err) {
        WCLog(@"发送密码失败%@",err);
    }else {
        WCLog(@"发送密码成功");
    }
}
// 4.授权成功后，发送"在线"消息
- (void)sendOnlineToHost {
    XMPPPresence *predence = [XMPPPresence presence];
    [_xmppStream sendElement:predence];
}
#pragma mark - XMPPStream的代理
#pragma mark - 与主机连接成功
-(void)xmppStreamDidConnect:(XMPPStream *)sender {
    WCLog(@"与主机连接成功");
    if (self.isRegisterOperation) {
        [_xmppStream registerWithPassword:[[NSUserDefaults standardUserDefaults] objectForKey:RegistPwd] error:nil];
    }else{
        [self sendPwdToHost];
        
    }
}
#pragma mark - 与主机断开连接
- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error{
    if (error && _resultBlock) {
        WCLog(@"与主机连接发生错误%@",error);
        [self postNotification:XMPPResultTypeNetError];
        _resultBlock(XMPPResultTypeNetError);
    }else{
        WCLog(@"与主机断开连接");
    }
}
#pragma mark - 登录授权成功
- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender{
    WCLog(@"授权成功");
    [self postNotification:XMPPResultTypeLoginSuccess];
    [self sendOnlineToHost];
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeLoginSuccess);
    }
}
#pragma mark - 登录授权失败
- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(DDXMLElement *)error{
    if (error) {
        [self postNotification:XMPPResultTypeLoginFailure];
        if (_resultBlock) {
            _resultBlock(XMPPResultTypeLoginFailure);
        }
        WCLog(@"授权失败%@",error);
    }
}
#pragma mark - 注册成功
- (void)xmppStreamDidRegister:(XMPPStream *)sender {
    WCLog(@"注册成功");
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeRegisterSuccess);
    }
}
#pragma mark - 注册失败
- (void)xmppStream:(XMPPStream *)sender didNotRegister:(DDXMLElement *)error{
    WCLog(@"注册失败%@",error);
    if (_resultBlock) {
        _resultBlock(XMPPResultTypeRegisterFailure);
    }
    
}
- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message{
    WCLog(@"%@",message);
    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
        NSLog(@"在后台");
    }
    // 本地通知
    UILocalNotification *localNoti = [UILocalNotification new];
    localNoti.alertBody = [NSString stringWithFormat:@"%@\n%@",message.fromStr,message.body];
    localNoti.fireDate = [NSDate date];
    localNoti.soundName = @"default";
    [[UIApplication sharedApplication] scheduleLocalNotification:localNoti];
}
// 接收好友的在线、离线消息
- (void)xmppStream:(XMPPStream *)sender didSendPresence:(XMPPPresence *)presence {
    //谁发送过来的
//    presence.fromStr;
}
#pragma mark - 登录
- (void)xmppUserLogin:(XMPPResultBlock)resultBlock{
    
    _resultBlock = resultBlock;
    [_xmppStream disconnect];
    [self conneectToHost];
}
#pragma mark - 注销
- (void)xmppUserLogout {
    
    //1.发送“离线”消息
    XMPPPresence *offLine = [XMPPPresence presenceWithType:@"unavailable"];
    [_xmppStream sendElement:offLine];
    //2.与服务器断开连接
    [_xmppStream disconnect];
    // 3.更新用户的登录状态
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IsLogin];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
    [UIApplication sharedApplication].keyWindow.rootViewController = storyboard.instantiateInitialViewController;
}
- (void)xmppUserRegister:(XMPPResultBlock)resultBlock{
    _resultBlock = resultBlock;
    [_xmppStream disconnect];
    [self conneectToHost];
    
}
- (NSString *)jid {
    return [NSString stringWithFormat:@"%@@%@",[[NSUserDefaults standardUserDefaults] objectForKey:User],domin];
}
- (void)dealloc {
    [self teardownxmpp];
}
@end
