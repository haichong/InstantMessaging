// 
// Core classes
// 
// 提供了一个不可变JID的实现，遵守NSCopying和NSCoding协议
#import "XMPPJID.h"
// 开发过程中最主要的交互的类，所有扩展和自定义代码均要基于此类进行
#import "XMPPStream.h"
// XMPPElement、XMPPIQ、XMPPMessage的基类
#import "XMPPElement.h"
// 请求
#import "XMPPIQ.h"
// 消息
#import "XMPPMessage.h"
// 出席
#import "XMPPPresence.h"
// 开发XMPP扩展时使用
#import "XMPPModule.h"
/*
 XMPPLogging:XMPP的日志框架
 XMPPInternal：整个XMPP框架内部使用的核心和高级底层内容
 XMPPParser：提供XMPPStream的解析作用
 **/
// 
// Authentication
// 

#import "XMPPSASLAuthentication.h"
#import "XMPPDigestMD5Authentication.h"
#import "XMPPPlainAuthentication.h"
#import "XMPPXFacebookPlatformAuthentication.h"
#import "XMPPAnonymousAuthentication.h"
#import "XMPPDeprecatedPlainAuthentication.h"
#import "XMPPDeprecatedDigestAuthentication.h"

// 
// Categories
// 

#import "NSXMLElement+XMPP.h"
