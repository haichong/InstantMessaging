//
//  EditInfoTableViewController.h
//  WeChat
//
//  Created by FuHang on 16/10/26.
//  Copyright © 2016年 付航. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol EditInfoTableViewControllerDelegate <NSObject>

- (void)editInfoTableViewControllerDidSave;

@end

@interface EditInfoTableViewController : UITableViewController

@property (nonatomic, strong)UITableViewCell *cell;
@property (nonatomic, strong) id<EditInfoTableViewControllerDelegate>delegate;
@end
