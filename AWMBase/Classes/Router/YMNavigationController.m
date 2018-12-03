//
//  YMNavigationController.m
//  ymbl
//
//  Created by hugo on 2017/9/29.
//  Copyright © 2017年 Luochen Culture Media Co., Ltd. All rights reserved.
//

#import "YMNavigationController.h"

@interface YMNavigationController () <UINavigationControllerDelegate>

@end

@implementation YMNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.delegate = self;
    [self setNavigationBarHidden:YES];
}

//push时隐藏tabbar
- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if (self.viewControllers.count > 0) {
        viewController.hidesBottomBarWhenPushed = YES;
    }
    [super pushViewController:viewController animated:animated];
//    // 修改tabBra的frame
//    CGRect frame = self.tabBarController.tabBar.frame;
//    frame.origin.y = [UIScreen mainScreen].bounds.size.height - frame.size.height;
//    self.tabBarController.tabBar.frame = frame;
}

- (BOOL)shouldAutorotate {
    return [self.topViewController shouldAutorotate];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return [self.topViewController supportedInterfaceOrientations];
}

@end

