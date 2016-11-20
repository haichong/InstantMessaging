//
//  OtherLoginViewController.m
//  WeChat
//
//  Created by FuHang on 16/10/21.
//  Copyright © 2016年 付航. All rights reserved.
//

#import "OtherLoginViewController.h"

@interface OtherLoginViewController ()

@property (weak, nonatomic) IBOutlet UITextField *userField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;

@end

@implementation OtherLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (IBAction)loginAction:(id)sender {
    [[NSUserDefaults standardUserDefaults] setObject:_userField.text forKey:User];
    [[NSUserDefaults standardUserDefaults] setObject:_pwdField.text forKey:Pwd];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [super login];
}
- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)dealloc {
    WCLog(@"%s",__func__);
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
   
}

@end
