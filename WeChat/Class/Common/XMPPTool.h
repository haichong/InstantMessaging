//
//  XMPPTool.h
//  WeChat
//
//  Created by FuHang on 16/10/24.
//  Copyright © 2016年 付航. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
extern NSString *const LoginStatusNotification;
static NSString *domin = @"fuhangdemacbook-pro.local";

typedef enum {
    XMPPResultTypeConnecting, //连接中...
    XMPPResultTypeLoginSuccess,//登录成功
    XMPPResultTypeLoginFailure, //登录失败
    XMPPResultTypeRegisterSuccess,//注册成功
    XMPPResultTypeRegisterFailure, //注册失败
    XMPPResultTypeNetError,
    
}XMPPResultType;
// 用户结果的回调
typedef void (^XMPPResultBlock)(XMPPResultType type);
@interface XMPPTool : NSObject<XMPPStreamDelegate>
{
    XMPPStream *_xmppStream;
    XMPPResultBlock _resultBlock;
    XMPPReconnect *_reconnect;
    XMPPvCardAvatarModule *_vCardAvatar;   // 电子名片头像
    XMPPvCardCoreDataStorage *_vCardStorage;// 电子名片的数据储存
    XMPPMessageArchiving *_msgArchiving; // 聊天模块
    XMPPMessageArchivingCoreDataStorage *_msgStorage;
}
@property (nonatomic, assign,getter=isRegisterOperation) BOOL registerOperation;
@property (nonatomic,strong,readonly)XMPPStream *xmppStream;
@property (nonatomic,strong,readonly) NSString *jid;
@property (nonatomic, strong,readonly) XMPPvCardTempModule *vCard;// 电子名片
@property (nonatomic, strong,readonly) XMPPRoster *roster;  // 花名册
@property (nonatomic, strong,readonly) XMPPRosterCoreDataStorage *rosterStorage;//花名册的数据存储
@property (nonatomic, strong) XMPPMessageArchivingCoreDataStorage *msgStorage; // 聊天数据储存
+(XMPPTool *)shareXMPPTool;
- (void)xmppUserLogout;
- (void)xmppUserLogin:(XMPPResultBlock)resultBlock;
- (void)xmppUserRegister:(XMPPResultBlock)resultBlock;
@end
