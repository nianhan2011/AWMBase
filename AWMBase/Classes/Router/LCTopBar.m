//
//  LCRTopBar.m
//  Pods
//
//  Created by hugo on 2017/4/10.
//
//

#import <Masonry/Masonry.h>
#import "LCTopBar.h"
#import "UIColor+YYAdd.h"

@interface LCTopBar()

@end

@implementation LCTopBar

- (instancetype)init {
    self = [super init];
    if (self) {
        self.backgroundColor = [UIColor colorWithHexString:@"F4F5F6"];
        self.navigationBar = [UINavigationBar new];
        [self.navigationBar setBackgroundImage:[UIImage new]
                                 forBarMetrics:UIBarMetricsDefault];
        self.navigationBar.shadowImage = [UIImage new];
        self.navigationBar.translucent = YES;
        [self addSubview:self.navigationBar];
        
        [_navigationBar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-1);
            make.leading.mas_equalTo(0);
            make.trailing.mas_equalTo(0);
            make.height.mas_equalTo(44);
        }];
        
//        self.separateLine = [UIView new];
//        self.separateLine.backgroundColor = [UIColor colorWithHexString:@"E5E5E5"];
//        [self addSubview:self.separateLine];
//        [self.separateLine mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.leading.mas_equalTo(0);
//            make.trailing.mas_equalTo(0);
//            make.bottom.mas_equalTo(0);
//            make.height.mas_equalTo(1/UIScreen.mainScreen.scale);
//        }];
    }
    return self;
}

- (void)setNavigationItem:(UINavigationItem *)navigationItem {
    _navigationItem = navigationItem;
    [self.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont fontWithName:@"PingFang-SC-Regular" size:15], NSForegroundColorAttributeName : [UIColor colorWithHexString:@"333333"]}];
    self.navigationBar.items = @[navigationItem];
}

@end
