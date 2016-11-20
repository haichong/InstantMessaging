//
//  EditInfoTableViewController.m
//  WeChat
//
//  Created by FuHang on 16/10/26.
//  Copyright © 2016年 付航. All rights reserved.
//

#import "EditInfoTableViewController.h"

@interface EditInfoTableViewController ()

@property (strong, nonatomic) IBOutlet UITextField *editField;

@end

@implementation EditInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.editField.text = self.cell.detailTextLabel.text;
    self.title = self.cell.textLabel.text;
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"保存" style:UIBarButtonItemStylePlain target:self action:@selector(saveAction)];
}
- (void) saveAction{
    self.cell.detailTextLabel.text = self.editField.text;
    if ([self.delegate respondsToSelector:@selector(editInfoTableViewControllerDidSave)]) {
        [self.delegate editInfoTableViewControllerDidSave];
    }
    [self.navigationController popViewControllerAnimated:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
