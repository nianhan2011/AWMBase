//
//  LCUIBaseViewController.h
//  Pods
//
//  Created by hugo on 2017/5/8.
//
//

#import <UIKit/UIKit.h>
#import "LCTopBar.h"

@interface LCBaseViewController : UIViewController

@property (strong, nonatomic) LCTopBar *topBar;
@property (strong, nonatomic) NSDictionary *param;

//isSingleMode是YES则为单例模式
@property (assign, nonatomic) BOOL isSingleMode;

@property (strong, nonatomic) NSString *pageName;

@property (strong, nonatomic) UIView *placeHolderView;

@property (nonatomic, strong) UITableView * tableView;
@property (nonatomic, strong) UICollectionView * collectionView;

- (void)setupBackButton;

#pragma mark - Protected
- (void)onBackButtonClicked:(id)sender;

@end
