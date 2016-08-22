//
//  PZXAlertView.m
//  PZXAlertView
//
//  Created by pzx on 16/8/22.
//  Copyright © 2016年 pzx. All rights reserved.
//
#define MESSAGELEADING 15.0f
#define TITLEFONT [UIFont boldSystemFontOfSize:17]
#define MESSAGEFONT [UIFont systemFontOfSize:15]
#define BUTTONCOLOR [UIColor cyanColor]
#define BUTTONHEIGHT 45.0f

#import "PZXAlertView.h"

//自己的window
@interface PZXWindow : UIWindow

@end

@implementation PZXWindow

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.windowLevel = UIWindowLevelAlert;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    }
    return self;
}

@end

@interface PZXAlertView (){

    PZXWindow *_alertWindow;
    UIView *_backView;
    UIScrollView *_scrollView;//暂时用不到 如果以后要做滑动效果再用
    UILabel *_messageLabel;
    UILabel *_titleLabel;
    
    //用timer 强制retain 一下
    NSTimer *_showTimer;
    
    //宽度
    CGFloat _width;
    
    //
    NSString *_title;
    NSString *_message;
    NSArray *_buttons;
    PZXAlertClickedAtIndex _completed;
}


@end

@implementation PZXAlertView

+(instancetype)showWithTitle:(NSString *)title message:(NSString *)message actionButtons:(NSArray *)buttons clickedCompletion:(PZXAlertClickedAtIndex)completed{
    //在有window 处于levelAlert 的时候阻止弹出
    for (id object in [UIApplication sharedApplication].windows) {
        if ([object isKindOfClass:[PZXWindow class]]) {
            return nil;//防止出现两个pzxwindow
        }
    }
    return [[PZXAlertView alloc]initWithTitle:title message:message actionButtons:buttons clickedCompletion:completed];

}
- (instancetype)initWithTitle:(NSString *)title message:(NSString *)message actionButtons:(NSArray *)buttons clickedCompletion:(PZXAlertClickedAtIndex)completed{
    self = [super init];
    if (self) {
        //创建timer
        if (!_showTimer) {//也许以后会用到 自己消失的情况
            _showTimer = [NSTimer scheduledTimerWithTimeInterval:100000.0 target:self selector:@selector(justShowTimer) userInfo:nil repeats:YES];
        }
        _title = title;//赋值title
        _message = message;//赋值message
        //创建按钮
        if (buttons) {
            NSMutableArray *vailButtons = [NSMutableArray arrayWithCapacity:buttons.count];
            for (int i = 0; i<buttons.count; i++) {
                id  object = buttons[i];
                if ([object isKindOfClass:[NSString class]]) {
                    [vailButtons addObject:object];
                }
            }//给button数组
            _buttons = vailButtons;
        }
        _completed = completed;
        [self setViews];
    }
    return  self;

}
- (void)setViews {
    if (!_alertWindow) {//没有window创建window
        CGRect frame = [UIScreen mainScreen].bounds;
        _width = 320.0f-40.0f;//frame.size.width-40.0f;
        _alertWindow = [[PZXWindow alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        //        _alertWindow.windowLevel = UIWindowLevelAlert;
        _alertWindow.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
        [_alertWindow makeKeyAndVisible];
    }
    
    if (!_backView) {//创建背景view
        _backView = [UIView new];
        _backView.backgroundColor = [UIColor whiteColor];//背景view的颜色
        _backView.layer.cornerRadius = 8.0f;
        _backView.layer.masksToBounds = YES;
        [_alertWindow addSubview:_backView];
    }
    CGFloat StringWidth = _width-2*MESSAGELEADING;//字符串的宽度
    CGSize titleSize = CGSizeZero;
    
    if (_title && ![_title isEqualToString:@""]) {
        titleSize = [_title boundingRectWithSize:CGSizeMake(StringWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:TITLEFONT} context:nil].size;
        if (!_titleLabel) {//创建titleLabel
            _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(MESSAGELEADING, MESSAGELEADING, titleSize.width, titleSize.height)];
            _titleLabel.font = TITLEFONT;
            _titleLabel.text = _title;
            _titleLabel.numberOfLines = 0;
            //_titleLabel.backgroundColor = [UIColor redColor];
            _titleLabel.textAlignment = NSTextAlignmentCenter;
            [_backView addSubview:_titleLabel];
            _titleLabel.center = CGPointMake(_width/2, _titleLabel.center.y);
        }
    }
    
    CGSize messageSize = CGSizeZero;
    if (_message && ![_message isEqualToString:@""]) {//创建message
        messageSize = [_message boundingRectWithSize:CGSizeMake(StringWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:MESSAGEFONT} context:nil].size;
        if (!_messageLabel) {
            _messageLabel = [[UILabel alloc] initWithFrame:CGRectMake(MESSAGELEADING, MESSAGELEADING+CGRectGetMaxY(_titleLabel.frame), messageSize.width, messageSize.height)];
            _messageLabel.font = MESSAGEFONT;
            _messageLabel.text = _message;
            _messageLabel.numberOfLines = 0;
            //_messageLabel.textAlignment = NSTextAlignmentCenter;
            [_backView addSubview:_messageLabel];
            _messageLabel.center = CGPointMake(_width/2, _messageLabel.center.y);
        }
    }
    CGFloat buttonsHeight = 0;
    CGFloat leadingY = 0;
    if (_title && ![_title isEqualToString:@""]) {//设置title的Y
        leadingY = CGRectGetMaxY(_titleLabel.frame)+MESSAGELEADING;
    }
    if (_message && ![_message isEqualToString:@""]) {//设置message的Y
        leadingY = CGRectGetMaxY(_messageLabel.frame)+MESSAGELEADING;
    }
    
    if (_buttons && _buttons.count!=0) {
        buttonsHeight = _buttons.count>2?BUTTONHEIGHT*_buttons.count:BUTTONHEIGHT;
        NSInteger buttonCount = _buttons.count>=4?4:_buttons.count;
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, leadingY-0.5f, _width, 0.5f)];
        line.backgroundColor = [UIColor groupTableViewBackgroundColor];
        [_backView addSubview:line];
        if (buttonCount<=2) {//按钮小于2就横着并排
            CGFloat buttonWith = (_width+2)/buttonCount;
            for (int i=0; i<buttonCount; i++) {
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(buttonWith*i-1,leadingY,  buttonWith, BUTTONHEIGHT)];
                NSString *title = [NSString stringWithFormat:@"%@",_buttons[i]];
                [button setTitle:title forState:UIControlStateNormal];
                [button setTitleColor:BUTTONCOLOR forState:UIControlStateNormal];
                button.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
                button.layer.borderWidth = .5f;
                [_backView addSubview:button];
                button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
                button.tag = i;
                [button addTarget:self action:@selector(buttonClickedAction:) forControlEvents:UIControlEventTouchUpInside];
            }
        }else {//超过2个就竖着排列
            for (int i=0; i<buttonCount; i++) {
                UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(-1, leadingY+i*BUTTONHEIGHT, _width+2, BUTTONHEIGHT)];
                NSString *title = [NSString stringWithFormat:@"%@",_buttons[i]];
                [button setTitle:title forState:UIControlStateNormal];
                [button setTitleColor:BUTTONCOLOR forState:UIControlStateNormal];
                button.layer.borderColor = [UIColor groupTableViewBackgroundColor].CGColor;
                button.layer.borderWidth = .5f;
                button.titleLabel.font = [UIFont boldSystemFontOfSize:17];
                [_backView addSubview:button];
                button.tag = i;
                [button addTarget:self action:@selector(buttonClickedAction:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
    }
    CGFloat totleheight = leadingY+buttonsHeight;//
    _backView.frame = CGRectMake(_alertWindow.frame.size.width/2-_width/2, _alertWindow.frame.size.height/2-totleheight/2, _width, totleheight);//设置背景view的frame
    
    _backView.transform = CGAffineTransformMakeScale(0.2, 0.2);
    [UIView animateWithDuration:.1 animations:^{//设置动画可以根据自己的需求在这里写不同的动画，我写的最简单的渐变放大
        
        _alertWindow.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
        _backView.transform = CGAffineTransformMakeScale(1, 1);
    }];
    

}

- (void)buttonClickedAction:(UIButton *)button {
    if (_completed) {//走block
        _completed(button.tag);//index传入button的tag
    }
    [self dismiss];
}
- (void)dismiss {//删除view 这里可以写相应的动画
    [UIView animateWithDuration:.1 animations:^{
        
        _alertWindow.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.0];
        _backView.transform = CGAffineTransformMakeScale(0.2, 0.2);
        
    } completion:^(BOOL finished) {
        if (_backView) {
            [_backView removeFromSuperview];
        }
        if (_alertWindow) {
            _alertWindow.hidden = YES;
            _alertWindow = nil;
        }
        [self releaseTimer];
    }];

}
#pragma mark - justShowTimer
- (void)justShowTimer {
   
}

- (void)releaseTimer {
    if (_showTimer) {
        [_showTimer invalidate];
        _showTimer = nil;
    }
}
@end
