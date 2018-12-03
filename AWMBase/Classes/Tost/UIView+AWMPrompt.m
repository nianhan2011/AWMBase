//
//  UIView+GCNoNetWorkShow.m
//  GoldenCloudSDK
//
//  Created by Admin on 2018/11/29.
//  Copyright © 2018年 SuNing. All rights reserved.
//


#import "UIView+AWMPrompt.h"
#import <objc/runtime.h>

#define GCColorFromRGB(rgbValue)\
\
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

static UIView *_maskView;
static const void *__AWM_NoNetWorkView_Key = "__AWM_NoNetWorkView_Key";
static const void *__AWM_NoNetBlock_Key = "__AWM_NoNetBlock_Key";

@implementation UIView (GCPrompt)

#pragma mark - Instance Method
- (void)AWM_showNoNetWithClick:(GCNoNetClick)clickBlock {
    [self AWM_showPromptTitle:@"网络连接异常" image:[self imageNamedFromGCBundle:@"AWM_network_error"] buttonTitle:@"重新加载" ClickBlock:clickBlock];
}

- (void)AWM_showNoData {
    [self AWM_showPromptTitle:@"抱歉，没有找到相关商品" image:[self imageNamedFromGCBundle:@"AWM_default_data"] buttonTitle:nil ClickBlock:nil];
}

- (void)AWM_showPromptTitle:(NSString *)title image:(UIImage *)image buttonTitle:(nullable NSString *)buttonTitle ClickBlock:(nullable GCNoNetClick)clickBlock {
    [self AWM_hidePrompt];
    if (clickBlock) {
        objc_setAssociatedObject(self,
                                 __AWM_NoNetBlock_Key,
                                 clickBlock,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    UIView *noNetWorkView = [self AWM_noNetWorkView];
    [self addSubview:noNetWorkView];
    [noNetWorkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    UIImageView *imgV = [[UIImageView alloc] initWithImage:image];
    [noNetWorkView addSubview:imgV];
    [imgV mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.mas_equalTo(noNetWorkView);
    }];
    
    UILabel *label = [[UILabel alloc] init];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = title;
    label.font = [UIFont systemFontOfSize:16];
    label.textColor = GCColorFromRGB(0x7B7B7B);
    [noNetWorkView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(imgV.mas_bottom).mas_offset(10);
        make.centerX.mas_equalTo(imgV);
    }];
    
    if (buttonTitle.length == 0 || buttonTitle == nil || [buttonTitle isEqualToString:@""]) return;
    
    UIButton *btn = [[UIButton alloc] init];
    [btn setTitle:buttonTitle forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:12];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(reLoad) forControlEvents:UIControlEventTouchUpInside];
    btn.backgroundColor = GCColorFromRGB(0x47A0DB);
    btn.layer.cornerRadius = 15;
    btn.layer.masksToBounds = YES;
    [noNetWorkView addSubview:btn];
    [btn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(label.mas_bottom).mas_offset(10);
        make.centerX.mas_equalTo(label);
        make.size.mas_equalTo(CGSizeMake(120, 30));
    }];
}

- (void)AWM_show:(UIView *)view block:(void(^)(MASConstraintMaker *))block {
    [self AWM_hidePrompt];
    UIView *noNetWorkView = [self AWM_noNetWorkView];
    [self addSubview:noNetWorkView];
    [noNetWorkView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self);
    }];
    [noNetWorkView addSubview:view];
    [view mas_makeConstraints:block];
}

- (void)AWM_hidePrompt {
    UIView *noNetWorkView = objc_getAssociatedObject(self, __AWM_NoNetWorkView_Key);
    if (noNetWorkView) {
        [noNetWorkView removeFromSuperview];
        objc_setAssociatedObject(self,
                                 __AWM_NoNetWorkView_Key,
                                 nil,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    objc_setAssociatedObject(self,
                             __AWM_NoNetBlock_Key,
                             nil,
                             OBJC_ASSOCIATION_RETAIN_NONATOMIC);

}

- (UIImage *)imageNamedFromGCBundle:(NSString *)name {
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"GoldenCloudSDK" ofType:@"bundle"];
    if (bundlePath) {
        NSString *imagePath = [bundlePath stringByAppendingPathComponent:name];
        if (imagePath) {
            UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
            return image;
        }
    } else {
        bundlePath = [[NSBundle mainBundle] pathForResource:@"GoldenCloudSDK" ofType:@"framework" inDirectory:@"Frameworks"];
        bundlePath = [bundlePath stringByAppendingPathComponent:@"GoldenCloudSDK.bundle"];
        NSString *imagePath = [bundlePath stringByAppendingPathComponent:name];
        if (imagePath) {
            UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
            return image;
        }
    }
    return nil;
}


#pragma mark - Class Method
+ (void)AWM_present:(UIView *)view block:(void(^)(MASConstraintMaker *))block {
    [self AWM_dismiss];
    view.tag = 1000;
    UIWindow *superView = [self frontWindow];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _maskView = [[UIView alloc] initWithFrame:superView.bounds];
        _maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5f];
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(AWM_dismiss)];
        [_maskView addGestureRecognizer:gesture];
    });
    [superView addSubview:_maskView];
    [superView addSubview:view];
    [view mas_makeConstraints:block];
    
    view.transform = CGAffineTransformScale(CGAffineTransformIdentity, CGFLOAT_MIN, CGFLOAT_MIN);
    [UIView animateWithDuration:0.3 animations:^{
        view.transform = CGAffineTransformScale(CGAffineTransformIdentity, 1.1, 1.1);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.2 animations:^{
            view.transform = CGAffineTransformIdentity;
        }];
    }];

}

+ (void)AWM_dismiss {
    [_maskView removeFromSuperview];
    UIView *view = [[self frontWindow] viewWithTag:1000];
    if (view) {
        [view removeFromSuperview];
        view = nil;
    }
}

+ (UIWindow *)frontWindow {
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows) {
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelSupported = (window.windowLevel >= UIWindowLevelNormal && window.windowLevel <= UIWindowLevelNormal);
        BOOL windowKeyWindow = window.isKeyWindow;
        if(windowOnMainScreen && windowIsVisible && windowLevelSupported && windowKeyWindow) {
            return window;
        }
    }
    return nil;
}

- (void)reLoad {
    GCNoNetClick noNetClick = objc_getAssociatedObject(self, __AWM_NoNetBlock_Key);
    if (noNetClick) {
        noNetClick();
    }
}

#pragma mark - Getter
- (UIView *)AWM_noNetWorkView {
    UIView *view = objc_getAssociatedObject(self, __AWM_NoNetWorkView_Key);
    if (view == nil) {
        view = [[UIView alloc] init];
        objc_setAssociatedObject(self,
                                 __AWM_NoNetWorkView_Key,
                                 view,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return view;
}



@end
