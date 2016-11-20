//
//  InputView.m
//  WeChat
//
//  Created by FuHang on 16/10/27.
//  Copyright © 2016年 付航. All rights reserved.
//

#import "InputView.h"

@implementation InputView

+(instancetype)inputView {
    return [[[NSBundle mainBundle] loadNibNamed:@"InputView" owner:self options:nil] lastObject];
}

@end
