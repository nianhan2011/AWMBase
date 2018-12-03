//
//  LCUIBaseViewController.m
//  Pods
//
//  Created by hugo on 2017/5/8.
//
//

#import "LCBaseViewController.h"
#import "LCRouter.h"
#import <Masonry/Masonry.h>
#import "LCTopBar.h"
#import "UIColor+YYAdd.h"
#import "AFNetworking.h"
#import "AWMBase.h"
#import "MJRefresh.h"
#import "MJExtension.h"
@interface LCBaseViewController ()

@end

@implementation LCBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.edgesForExtendedLayout = UIRectEdgeNone;
//    self.extendedLayoutIncludesOpaqueBars = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.topBar];
    [self.topBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(0);
        make.trailing.mas_equalTo(0);
        make.top.mas_equalTo(0);
        make.height.mas_equalTo(TopBarHeight);
    }];

    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.topBar.navigationItem = self.navigationItem;
//        [self.topBar.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName:[UIColor blackColor],NSFontAttributeName:[UIFont fontWithName:@"PingFang-SC-Medium" size:15]}];
    });
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
//    CLS_LOG(@"scene:%@", NSStringFromClass(self.class));
    
    if (self.pageName.length > 0) {
//        [TalkingData trackPageBegin:self.pageName];
    }

}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}
#if 0
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        switch (status) {
                case AFNetworkReachabilityStatusUnknown:
                AWMLog(@"未识别的网络");
                [self showPlaceHolder];
                break;
                
                case AFNetworkReachabilityStatusNotReachable:
                AWMLog(@"不可达的网络(未连接)");
                [self showPlaceHolder];
                break;
                
                case AFNetworkReachabilityStatusReachableViaWWAN:
                AWMLog(@"2G,3G,4G...的网络");
                [self hidePlaceHolder];
                break;
                
                case AFNetworkReachabilityStatusReachableViaWiFi:
                AWMLog(@"wifi的网络");
                [self hidePlaceHolder];
                break;
            default:
                break;
        }
    }];
    [manager startMonitoring];
}
#endif

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if (self.pageName.length > 0) {
//        [TalkingData trackPageEnd:self.pageName];
    }
}

/**
 *  懒加载UITableView
 *
 *  @return UITableView
 */
- (UITableView *)tableView
{
    if (_tableView == nil) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

        //头部刷新
        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRereshing)];
        header.automaticallyChangeAlpha = YES;
        header.lastUpdatedTimeLabel.hidden = YES;
        _tableView.mj_header = header;
        
        //底部刷新
        _tableView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRereshing)];
        _tableView.backgroundColor = kClearColor;
        _tableView.scrollsToTop = YES;
        _tableView.tableFooterView = [[UIView alloc] init];
    }
    return _tableView;
}

/**
 *  懒加载collectionView
 *
 *  @return collectionView
 */
- (UICollectionView *)collectionView
{
    if (_collectionView == nil) {
        UICollectionViewFlowLayout *flow = [[UICollectionViewFlowLayout alloc] init];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flow];
        _collectionView.backgroundColor = kWhiteColor;
        
//        MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(headerRereshing)];
//        header.automaticallyChangeAlpha = YES;
//        header.lastUpdatedTimeLabel.hidden = YES;
//        header.stateLabel.hidden = YES;
//        _collectionView.mj_header = header;
//
//        //底部刷新
//        _collectionView.mj_footer = [MJRefreshBackNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(footerRereshing)];
//        _collectionView.backgroundColor = kClearColor;
//        _collectionView.scrollsToTop = YES;
    }
    return _collectionView;
}
-(void)headerRereshing{
    
}

-(void)footerRereshing{
    
}

- (void)setupBackButton {
    UIBarButtonItem *leftItem =
    [[UIBarButtonItem alloc] initWithImage:[self lc_imageWithName:@"button_back" inModule:@"AWMBase"]
                                     style:UIBarButtonItemStylePlain
                                    target:self
                                    action:@selector(onBackButtonClicked:)];
    
    self.navigationItem.leftBarButtonItem = leftItem;
}

- (nullable UIImage *)lc_imageWithName:(nonnull NSString *)name inModule:(nonnull NSString *)module {
    NSString *resourcePath = [[NSBundle mainBundle] pathForResource:module ofType:@"bundle"];
    NSBundle *resourceBundle = [NSBundle bundleWithPath:resourcePath];
    __block UIImage *image = [UIImage imageNamed:name inBundle:resourceBundle compatibleWithTraitCollection:nil];
    if (image) {
        return image;
    }
    return [UIImage imageNamed:name];
}
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (id)valueForUndefinedKey:(NSString *)key {
    return nil;
}

- (void)setValue:(id)value forUndefinedKey:(nonnull NSString *)key {
}


#pragma mark - Getter
- (LCTopBar *)topBar {
    if (nil == _topBar) {
        _topBar = [[LCTopBar alloc] init];
//        _topBar.backgroundColor = [UIColor colorWithHexString:@"ffffff"];
        _topBar.tintColor = [UIColor blackColor];
    }
    return _topBar;
}

- (UIView *)placeHolderView {
    if (nil == _placeHolderView) {
        _placeHolderView = InsertView(self.view, CGRectZero, [UIColor grayColor]);
        [_placeHolderView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.topBar.mas_bottom).mas_equalTo(0);
            make.leading.trailing.bottom.mas_offset(0);
        }];
        
    }
    return _placeHolderView;
}

- (void)showPlaceHolder {
    [self.view addSubview:self.placeHolderView];
    [self.view bringSubviewToFront:self.placeHolderView];
    [_placeHolderView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.topBar.mas_bottom).mas_equalTo(0);
        make.leading.trailing.bottom.mas_offset(0);
    }];
}

- (void)hidePlaceHolder {
    [self.placeHolderView removeFromSuperview];
}

#pragma mark - Setter
- (void)setParam:(NSDictionary *)param {
    NSMutableDictionary *localParma = [NSMutableDictionary dictionary];
    [_param enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        id value = [self valueForKey:key];
        if (value) {
            localParma[key] = value;
        }
    }];
    
    if (![param isEqual:localParma]) {
        _param = param;
        [self mj_setKeyValues:param];
    }
}

#pragma mark - Actions
- (void)onBackButtonClicked:(id)sender {
    DISMISS();
}

@end
