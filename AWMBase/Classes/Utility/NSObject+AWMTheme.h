//
//  NSObject+AWMTheme.h
//
//
//  Created by 殷凡 on 2018/8/7.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface NSObject (AWMTheme)
//控件加入缓存池. propertyName：属性名字
- (void)addToThemeColorPool:(NSString *)propertyName;
//设置主题颜色
- (void)setThemeColor:(UIColor *)color;
@end
