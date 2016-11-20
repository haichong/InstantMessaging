//
//  PersonInfoTableViewController.m
//  WeChat
//
//  Created by FuHang on 16/10/26.
//  Copyright © 2016年 付航. All rights reserved.
//

#import "PersonInfoTableViewController.h"
#import "XMPPvCardTemp.h"
#import "EditInfoTableViewController.h"

@interface PersonInfoTableViewController ()<UIActionSheetDelegate,UINavigationControllerDelegate, UIImagePickerControllerDelegate, EditInfoTableViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *nickLabel;
@property (weak, nonatomic) IBOutlet UILabel *weChatNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *orgNameLabel; // 公司
@property (weak, nonatomic) IBOutlet UILabel *orgunitLabel; // 部门
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;// 职位
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@end

@implementation PersonInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self loadVCard];
}
// 加载电子名片信息
- (void)loadVCard {
    XMPPvCardTemp *myVCrad =  [XMPPTool shareXMPPTool].vCard.myvCardTemp;
    if (myVCrad.photo) {
        self.icon.image = [UIImage imageWithData:myVCrad.photo];
    }
    self.nickLabel.text = myVCrad.nickname;
    NSString *user = [[NSUserDefaults standardUserDefaults] objectForKey:User];
    self.weChatNumberLabel.text = user;
    self.orgNameLabel.text = myVCrad.orgName;
    if (myVCrad.orgUnits.count > 0) {
        self.orgunitLabel.text = myVCrad.orgUnits[0];
    }
    self.titleLabel.text = myVCrad.title;
    self.phoneLabel.text = myVCrad.note;

#warning telecomsAddresses 这个方法，没有对电子名片信息进行解析
    self.emailLabel.text = myVCrad.note;
    if (myVCrad.emailAddresses.count > 0) {
        self.emailLabel.text = myVCrad.emailAddresses[0];
    }
}
#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSInteger tag = cell.tag;
    if (tag == 2) {
        return;
    }
    if (tag == 0) {
        // 选择图片
        UIActionSheet *sheet = [[UIActionSheet alloc] initWithTitle:@"请选择" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:@"照相" otherButtonTitles:@"图片库", nil];
        [sheet showInView:self.view];
    }else{
        WCLog(@"跳到下一个控制器");
        [self performSegueWithIdentifier:@"EditVCardSegue" sender:cell];
    }
    
}
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    id destVC = segue.destinationViewController;
    if ([destVC isKindOfClass:[EditInfoTableViewController class]]) {
        EditInfoTableViewController *editVC = destVC;
        editVC.delegate = self;
        editVC.cell = sender;
    }
}
#pragma mark - EditInfoTableViewControllerDelegate
- (void)editInfoTableViewControllerDidSave {
    
    XMPPvCardTemp *myVCard = [XMPPTool shareXMPPTool].vCard.myvCardTemp;
    myVCard.nickname = self.nickLabel.text;
    myVCard.orgName = self.orgNameLabel.text;
    if (self.orgunitLabel.text > 0) {
        myVCard.orgUnits = @[self.orgunitLabel.text];
    }
    myVCard.title = self.titleLabel.text;
    // telecomsAddresses 这个方法，没有对电子名片信息进行解析
    myVCard.note = self.phoneLabel.text;
    myVCard.emailAddresses = @[self.emailLabel.text];
    [[XMPPTool shareXMPPTool].vCard updateMyvCardTemp:myVCard];
}
#pragma mark - UIActionSheetDelegate
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 2) {
        // 取消
        return;
    }
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.delegate =self;
    picker.allowsEditing = YES;
    if (buttonIndex == 0) {
        // 照相
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        
    }else {
        // 图片库
        picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;

    }
    [self presentViewController:picker animated:YES completion:^{
        
    }];
}
#pragma mark - 图片选择器的代理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    WCLog(@"%@", info);
    UIImage *image = info[UIImagePickerControllerEditedImage];
    self.icon.image = image;
    XMPPvCardTemp *myVCard = [XMPPTool shareXMPPTool].vCard.myvCardTemp;
    myVCard.photo = UIImagePNGRepresentation(image);
    // 更新 这个方法会实现程序上传到服务器
    [[XMPPTool shareXMPPTool].vCard updateMyvCardTemp:myVCard];
    [self dismissViewControllerAnimated:YES completion:nil];
}
 - (void)didReceiveMemoryWarning {
 [super didReceiveMemoryWarning];
 }

@end
