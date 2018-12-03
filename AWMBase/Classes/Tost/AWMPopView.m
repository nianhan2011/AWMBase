//
//  AWMPopView.m
//  AFNetworking
//
//  Created by 殷凡 on 2018/8/6.
//

#import "AWMPopView.h"
#import "Masonry.h"
#import "AWMBase.h"

static UIView *_maskView;
static AWMPopEdges _popEdges;
static UIViewContentMode _contentMode;
@implementation AWMPopTool

+ (void)present:(UIView *)view contentMode:(UIViewContentMode)contentMode popEdges:(AWMPopEdges)popEdges {
    [self dismiss];
    view.tag = 1000;
    _popEdges = popEdges;
    _contentMode = contentMode;
    UIWindow *superView = [self frontWindow];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _maskView = [[UIView alloc] initWithFrame:superView.bounds];
        _maskView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5f];
        [_maskView addGestureRecognizer:TapGestureRecognizer(dismiss)];
    });
    [superView addSubview:_maskView];
    [superView addSubview:view];
    
    [self LayOutView:view inSuperView:superView];
}

+ (void)dismiss {
    [_maskView removeFromSuperview];
    UIView *view = [[self frontWindow] viewWithTag:1000];
    if (view) {
        [view removeFromSuperview];
    }
}

+ (void)LayOutView:(UIView *)view inSuperView:(UIView *)superView {
    switch (_contentMode) {
        case UIViewContentModeCenter:
            if (_popEdges.leding) {
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.center.mas_equalTo(superView);
                    make.leading.mas_offset(_popEdges.leding);
                    make.height.mas_equalTo(_popEdges.height);
                }];
            } else {
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.center.mas_equalTo(superView);
                    make.leading.mas_offset(Handle(45));
                    make.height.mas_equalTo(Handle(245));
                }];
            }
            break;
        case UIViewContentModeBottom:
            if (_popEdges.height) {
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(superView);
                    make.leading.mas_offset(_popEdges.leding);
                    make.height.mas_equalTo(_popEdges.height);
                    make.bottom.mas_offset(0);
                }];
            } else {
                [view mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.centerX.mas_equalTo(superView);
                    make.leading.mas_offset(0);
                    make.height.mas_equalTo(300);
                    make.bottom.mas_offset(0);
                }];
            }
        default:
            break;
    }
    
    view.transform = CGAffineTransformMakeTranslation(0,_popEdges.height?:300);
    [UIView animateWithDuration:0.3 animations:^{
        view.transform = CGAffineTransformIdentity;
    }];

}
#pragma mark - FrontWindow
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

@end
