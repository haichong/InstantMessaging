//
//  AddFreindTableViewController.m
//  WeChat
//
//  Created by FuHang on 16/10/27.
//  Copyright © 2016年 付航. All rights reserved.
//

#import "AddFreindTableViewController.h"

@interface AddFreindTableViewController ()<UITextFieldDelegate>
@end

@implementation AddFreindTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
}
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    // 添加好友
    NSString *user = textField.text;
    WCLog(@"%@", user);
    NSString *jidStr = [NSString stringWithFormat:@"%@@%@",user,domin];
    XMPPJID *friendJid = [XMPPJID jidWithString:jidStr];
    // 判断是否是自己
    if ([user isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:User]]) {
        [MBProgressHUD showError:@"不能添加自己为好友"];
        return NO;
    }
    // 是否已经是好友
    BOOL isExit = [[XMPPTool shareXMPPTool].rosterStorage userExistsWithJID:friendJid xmppStream:[XMPPTool shareXMPPTool].xmppStream];
    if (isExit) {
        [MBProgressHUD showError:@"当前好友已经存在"];
        return NO;
    }
    // 添加好友
    [[XMPPTool shareXMPPTool].roster subscribePresenceToUser:friendJid];
    [self.view endEditing:YES];
    return YES;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
