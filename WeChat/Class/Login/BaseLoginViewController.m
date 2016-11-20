//
//  BaseLoginViewController.m
//  WeChat
//
//  Created by FuHang on 16/10/24.
//  Copyright © 2016年 付航. All rights reserved.
//

#import "BaseLoginViewController.h"

@interface BaseLoginViewController ()

@end

@implementation BaseLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)login {
    [self.view endEditing:YES];
    [MBProgressHUD showMessage:@"正在登录中..." toView:self.view];
    XMPPTool *tool = [XMPPTool shareXMPPTool];
    tool.registerOperation = NO;
    __weak typeof(self) weakSelf = self;
    [tool xmppUserLogin:^(XMPPResultType type) {
        
        [weakSelf handleResultType:type];
    }];
    
}
- (void)handleResultType: (XMPPResultType)type {
    dispatch_async(dispatch_get_main_queue(), ^{
        [MBProgressHUD hideHUDForView:self.view];
        switch (type) {
            case XMPPResultTypeLoginSuccess:
            {
                WCLog(@"登录成功");
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:IsLogin];
                [[NSUserDefaults standardUserDefaults] synchronize];
                // 隐藏模态窗口
                [self dismissViewControllerAnimated:NO completion:^{
                    
                }];
                UIStoryboard *storyborad = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                AppDelegate *app = (AppDelegate *)[UIApplication sharedApplication].delegate;
                app.window.rootViewController = storyborad.instantiateInitialViewController;
                break;
            }
            case XMPPResultTypeLoginFailure:
            {
                [MBProgressHUD showError:@"用户名或密码错误" toView:self.view];
                WCLog(@"登录失败");
                break;
            }
            case XMPPResultTypeNetError:
            {
                [MBProgressHUD showError:@"网络连接超时" toView:self.view];
            }
            default:
                break;
        }
    });
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
