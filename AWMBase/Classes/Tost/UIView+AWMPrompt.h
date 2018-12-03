//
//  UIView+GCNoNetWorkShow.h
//  GoldenCloudSDK
//
//  Created by Admin on 2018/11/29.
//  Copyright © 2018年 SuNing. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Masonry.h>

typedef void(^GCNoNetClick)(void);

NS_ASSUME_NONNULL_BEGIN

@interface UIView (GCPrompt)

/**
展示默认的提示界面,没有按钮 buttonTitle传nil

     图片
       |
     文字
       |
     按钮
 */
- (void)AWM_showPromptTitle:(NSString *)title image:(UIImage *)image buttonTitle:(nullable NSString *)buttonTitle ClickBlock:(nullable GCNoNetClick)clickBlock;
//没有网络通用的提示界面
- (void)AWM_showNoNetWithClick:(GCNoNetClick)clickBlock;
//没有数据通用的提示界面
- (void)AWM_showNoData;

/**
 展示自定义的提示界面

 @param view 自定义的视图
 @param block massory布局
 */
- (void)AWM_show:(UIView *)view block:(void(^)(MASConstraintMaker *))block;

//隐藏提示界面
- (void)AWM_hidePrompt;

/**
 弹出框,带黑色背景
 
 @param view 自定义的视图
 @param block massory布局
 */
+ (void)AWM_present:(UIView *)view block:(void(^)(MASConstraintMaker *))block;
//关闭弹出框
+ (void)AWM_dismiss;

@end

NS_ASSUME_NONNULL_END
