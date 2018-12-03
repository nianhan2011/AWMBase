//
//  LCUIToastView.h
//  Pods
//
//  Created by hugo on 2017/5/10.
//
//

#import <UIKit/UIKit.h>

@interface LCUIToastView : UIView

/**
 显示提示信息

 @param toast 在屏幕上显示的文本信息
 @param view 默认在屏幕中心显示文本
 @param offset 文本显示的偏移量
 */
+ (void)showToast:(NSString *)toast inView:(UIView *)view offset:(CGPoint)offset;

+ (void)showError:(NSError *)error inView:(UIView *)view offset:(CGPoint)offset;

+ (void)showLoadingInView:(UIView *)view offset:(CGPoint)offset;
@end
