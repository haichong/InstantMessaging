//
//  RegisterViewController.m
//  WeChat
//
//  Created by FuHang on 16/10/24.
//  Copyright © 2016年 付航. All rights reserved.
//

#import "RegisterViewController.h"

@interface RegisterViewController ()

@property (weak, nonatomic) IBOutlet UITextField *phoneField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@end

@implementation RegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (IBAction)registerAction:(id)sender {
    
    [self.view endEditing:YES];
    [MBProgressHUD showMessage:@"正在注册..." toView:self.view];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:_phoneField.text forKey:RegisterUser];
    [defaults setObject:_pwdField.text forKey:RegistPwd];
    [defaults synchronize];
    XMPPTool *tool = [XMPPTool shareXMPPTool];
    tool.registerOperation = YES;
    __weak typeof(self) weakSelf = self;
    [tool xmppUserRegister:^(XMPPResultType type) {
        [weakSelf handleResultType:type];
    }];
}
- (void)handleResultType: (XMPPResultType)type{
    dispatch_async(dispatch_get_main_queue(), ^{
       
        [MBProgressHUD hideHUDForView:self.view];
        switch (type) {
            case XMPPResultTypeRegisterSuccess:
            {
                [self cancelAction:nil];
                if ([self.delegate respondsToSelector:@selector(registerViewControllerDidFinishRegister)]) {
                    [self.delegate registerViewControllerDidFinishRegister];
                }
            }
                break;
            case XMPPResultTypeRegisterFailure:
            {
                [MBProgressHUD showError:@"注册失败,用户名重复"];
            }
                break;
            case XMPPResultTypeNetError:
            {
                  [MBProgressHUD showError:@"网络连接超时"];
            }
                break;
            default:
                break;
        }
    });
}
- (IBAction)cancelAction:(id)sender {
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
