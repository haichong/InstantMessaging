//
//  AppDelegate.m
//  WeChat
//
//  Created by FuHang on 16/10/21.
//  Copyright © 2016年 付航. All rights reserved.
//

#import "AppDelegate.h"
#import "CustomNavigationController.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
@interface AppDelegate ()

@end
@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    NSLog(@"path = %@",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]);
    // 打开XMPP的日志
    //[DDLog addLogger:[DDTTYLogger sharedInstance]];
    // 设置导航栏样式
    [CustomNavigationController setupNavTheme];
    BOOL isLogin = [[NSUserDefaults standardUserDefaults] boolForKey:IsLogin];
    if (isLogin) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        self.window.rootViewController = storyboard.instantiateInitialViewController;
        // 自动登录
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [[XMPPTool shareXMPPTool] xmppUserLogin:nil];
        });
    }
    // 注册应用接收通知
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes: UIUserNotificationTypeBadge |
                                            UIUserNotificationTypeSound | UIUserNotificationTypeAlert  categories:nil];
    [application registerUserNotificationSettings:settings];
    return YES;
}
// 远程通知
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    
}
@end
