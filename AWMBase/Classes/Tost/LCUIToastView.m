//
//  LCUIToastView.m
//  Pods
//
//  Created by hugo on 2017/5/10.
//
//

#import <Masonry/Masonry.h>
#import "LCUIToastView.h"
#import "UIColor+YYAdd.h"
@implementation LCUIToastView

+ (void)showToast:(NSString *)toast inView:(UIView *)view offset:(CGPoint)offset {
    NSAssert([toast isKindOfClass:[NSString class]], @"");
    if (![toast isKindOfClass:[NSString class]]) {
        return;
    }
    if (nil == view) {
        view = UIApplication.sharedApplication.keyWindow;
    }
    
    UIView *contentView = [UIView new];
    contentView.layer.cornerRadius = 5;
    contentView.backgroundColor = [UIColor colorWithHexString:@"3A3A3A"];
    [view addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view).with.offset(offset.x);
        make.centerY.equalTo(view).with.offset(offset.y);
        make.width.lessThanOrEqualTo(view).multipliedBy(0.8);
    }];
    
    UILabel *label = [UILabel new];
    label.text = toast;
    label.numberOfLines = 0;
    label.textColor = [UIColor colorWithHexString:@"FFFFFF"];
    label.font = [UIFont systemFontOfSize:15];
    [contentView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(UIEdgeInsetsMake(12, 25, 12, 25));
    }];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [contentView removeFromSuperview];
    });
}

+ (void)showError:(NSError *)error inView:(UIView *)view offset:(CGPoint)offset {
    NSString *toast = error.userInfo[@"message"];
    if (nil == toast) {
        toast = error.localizedDescription;
    }
    [self showToast:toast inView:view offset:offset];
}

@end
