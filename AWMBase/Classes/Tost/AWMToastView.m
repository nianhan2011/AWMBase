//
//  LCUIToastView.m
//  Pods
//
//  Created by hugo on 2017/5/10.
//
//

#import <Masonry/Masonry.h>
#import "AWMToastView.h"
#import "UIColor+YYAdd.h"
@interface LCUIToastView ()
@property (strong, nonatomic) UIView *contentView;
@end

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

+ (void)showLoadingInView:(UIView *)view offset:(CGPoint)offset{
    if (nil == view) {
        view = UIApplication.sharedApplication.keyWindow;
    }
    
    UIView *contentView = [UIView new];
    contentView.layer.cornerRadius = 6;
    contentView.backgroundColor = [[UIColor colorWithHexString:@"333333"] colorWithAlphaComponent:0.9];
    [view addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(view).with.offset(offset.x);
        make.centerY.equalTo(view).with.offset(offset.y);
        make.width.height.mas_equalTo(87);
    }];
    
//    LOTAnimationView *lottieLogo = [LOTAnimationView animationNamed:@"data1"];
//    lottieLogo.contentMode = UIViewContentModeScaleAspectFill;
//    lottieLogo.loopAnimation = YES;
//    lottieLogo.cacheEnable = YES;
//    [contentView addSubview:lottieLogo];
//    [lottieLogo mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.centerX.equalTo(contentView);
//        make.top.mas_equalTo(25);
//        make.width.mas_equalTo(24);
//        make.height.mas_equalTo(18);
//    }];
//    [lottieLogo play];
    
    UILabel *label = [UILabel new];
    label.text = @"正在加载";
    label.numberOfLines = 0;
    label.textColor = [UIColor colorWithHexString:@"FFFFFF"];
    label.font = [UIFont systemFontOfSize:12];
    label.textAlignment = NSTextAlignmentCenter;
    [contentView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.trailing.mas_equalTo(0);
        make.bottom.mas_equalTo(-20);
        make.height.mas_equalTo(12);
    }];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [contentView removeFromSuperview];
    });
}

@end
