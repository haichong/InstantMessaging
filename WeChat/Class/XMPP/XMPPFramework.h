
//XMPPRoom：提供多用户聊天支持
//XMPPPubSub：发布订阅
//#import "XMPPCapabilities.h"
//#import "XMPPCapabilitiesCoreDataStorage.h"
//#import "XMPPMUC.h"
//#import "XMPPRoomCoreDataStorage.h"
//#import "XMPPRoomHybridStorage.h"
//#import "XMPPRosterMemoryStorage.h"
// 回执
//#import "XMPPMessageDeliveryReceipts.h"
// 判断消息
//#import "XMPPMessage+XEP_0184.h"

/*
 XMPP是基于模块开发
 本工程用到的模块
 1.电子名片模块
 2.头像模块
 3.自动连接模块
 4.花名册模块
 5.消息模块
 **/

// xmpp基础服务类
#import "XMPP.h"
// 自动连接模块 Extensions/Reconnect】
#import "XMPPReconnect.h"
// 电子名片模块【Extensions/XEP-0054】
#import "XMPPvCardTempModule.h"
#import "XMPPvCardCoreDataStorage.h"
// 电子名片头像模块
#import "XMPPvCardAvatarModule.h"
// 花名册模块（好友列表）【Extensions/Roster】
#import "XMPPRoster.h"
// 花名册的数据存储
#import "XMPPRosterCoreDataStorage.h"
// 消息模块【XEP-0136】还有 XMPPMessage;XMPP.h里面已经包含
#import "XMPPMessageArchiving.h"
#import "XMPPMessageArchivingCoreDataStorage.h"

