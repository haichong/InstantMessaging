//
//  MyViewController.m
//  WeChat
//
//  Created by FuHang on 16/10/22.
//  Copyright © 2016年 付航. All rights reserved.
//

#import "MyViewController.h"
#import "XMPPvCardTemp.h"

@interface MyViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *nickNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *weChatNumber;

@end

@implementation MyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 获取个人信息
    XMPPvCardTemp *myVCrad =  [XMPPTool shareXMPPTool].vCard.myvCardTemp;
    if (myVCrad.photo) {
        self.icon.image = [UIImage imageWithData:myVCrad.photo];
    }
    self.nickNameLabel.text = myVCrad.nickname;
    NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:User];
    self.weChatNumber.text = [NSString stringWithFormat:@"微信号:%@",user];
}
- (IBAction)logoutAction:(id)sender {
    
    [[XMPPTool shareXMPPTool] xmppUserLogout];
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
