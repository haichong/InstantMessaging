//
//  LoginViewController.m
//  WeChat
//
//  Created by FuHang on 16/10/22.
//  Copyright © 2016年 付航. All rights reserved.
//

#import "LoginViewController.h"
#import "RegisterViewController.h"
#import "CustomNavigationController.h"

@interface LoginViewController ()<RegisterViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *userIcon;
@property (weak, nonatomic) IBOutlet UILabel *userName;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // 设置用户名为上次用户的用户名
    NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:User];
    if (user.length != 0) {
        _userName.hidden = NO;
        _userName.text = user;
    }else {
        _userName.hidden = YES;
    }
}
- (IBAction)loginAction:(id)sender {
    
    NSString *pwd = self.pwdField.text;
    [[NSUserDefaults standardUserDefaults] setObject:pwd forKey:Pwd];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [super login];
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    id destVC = segue.destinationViewController;
    if ([destVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = destVC;
        if ([nav.topViewController isKindOfClass:[RegisterViewController class]]) {
            RegisterViewController *registerVC = (RegisterViewController *)nav.topViewController;
            registerVC.delegate = self;
        }
       
    }
}
- (void)registerViewControllerDidFinishRegister {
    [MBProgressHUD showSuccess:@"请重新输入密码进行登录"];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    self.userName.text = [defaults objectForKey:RegisterUser];
    [defaults setObject:self.userName.text forKey:User];
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
