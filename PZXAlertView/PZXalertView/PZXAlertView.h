//
//  PZXAlertView.h
//  PZXAlertView
//
//  Created by pzx on 16/8/22.
//  Copyright © 2016年 pzx. All rights reserved.
//


/*
* 提示框
*/

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^PZXAlertClickedAtIndex)(NSInteger index);//完成事件的block

@interface PZXAlertView : NSObject


+(instancetype)showWithTitle:(NSString *)title message:(NSString *)message actionButtons:(NSArray *)buttons clickedCompletion:(PZXAlertClickedAtIndex)completed;//便捷初始化方法


@end
