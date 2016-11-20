//
//  RegisterViewController.h
//  WeChat
//
//  Created by FuHang on 16/10/24.
//  Copyright © 2016年 付航. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RegisterViewControllerDelegate <NSObject>
- (void)registerViewControllerDidFinishRegister;
@end

@interface RegisterViewController : UIViewController
@property (nonatomic, strong)id<RegisterViewControllerDelegate>delegate;
@end
