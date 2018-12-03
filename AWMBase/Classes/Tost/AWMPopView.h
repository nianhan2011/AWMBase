//
//  AWMPopView.h
//  AFNetworking
//
//  Created by 殷凡 on 2018/8/6.
//

#import <UIKit/UIKit.h>

typedef struct AWMPopEdges{
    CGFloat height;
    CGFloat leding;
} AWMPopEdges;

@interface AWMPopTool : NSObject
+ (void)present:(UIView *)view contentMode:(UIViewContentMode)contentMode popEdges:(AWMPopEdges)popEdges;
+ (void)dismiss;
+ (UIWindow *)frontWindow;
@end
