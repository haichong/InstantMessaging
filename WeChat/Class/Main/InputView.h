//
//  InputView.h
//  WeChat
//
//  Created by FuHang on 16/10/27.
//  Copyright © 2016年 付航. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InputView : UIView


@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *addButton;

+(instancetype)inputView;
@end
