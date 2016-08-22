//
//  ViewController.m
//  PZXAlertView
//
//  Created by pzx on 16/8/22.
//  Copyright © 2016年 pzx. All rights reserved.
//

#import "ViewController.h"
#import "PZXAlertView.h"
@interface ViewController ()

- (IBAction)buttonPressed:(UIButton *)sender;
@property (strong,nonatomic)PZXAlertView *pzxAlertView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor cyanColor];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonPressed:(UIButton *)sender {
    
    NSLog(@"...");
    //调用方法
    [PZXAlertView showWithTitle:@"测试" message:@"测试" actionButtons:@[@"1",@"2"] clickedCompletion:^(NSInteger index) {
        if (index ==0 ) {
            NSLog(@"1");
        }else if (index == 1){
            NSLog(@"2");
        }
    }];
}
@end
