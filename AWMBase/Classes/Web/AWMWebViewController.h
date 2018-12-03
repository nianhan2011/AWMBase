//
//  LCUIWebViewController.h
//  Pods
//
//  Created by hugo on 2017/6/22.
//
//

#import <UIKit/UIKit.h>
#import "LCBaseViewController.h"

@interface LCUIWebViewController : LCBaseViewController

@property (strong, nonatomic) NSString *URLString;
@property (strong, nonatomic) NSString *navTitle;
@property (assign, nonatomic) BOOL showNavigationBar; //YES: show NO: hide
@end
