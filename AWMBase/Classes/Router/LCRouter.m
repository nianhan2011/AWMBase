//
//  LCUIService.m
//  Pods
//
//  Created by hugo on 2017/5/31.
//
//

#import "LCRouter.h"
#import "LCBaseViewController.h"
#import "YMNavigationController.h"
#import <Masonry/Masonry.h>
@interface LCRouter()

@property (strong, nonatomic) NSMutableArray *topViewControllers;
@property (strong, nonatomic) NSMutableDictionary *resourceMap;
@property (strong, nonatomic) NSMutableDictionary *resourceBlockMap;

@end

@implementation LCRouter
LCR_SYNTHESIZE_SINGLETON_FOR_CLASS(LCRouter);

- (void)show:(UIViewController *)viewController {
    UIViewController *lastViewController = self.topViewControllers.lastObject;
    if ([lastViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (id)lastViewController;
        [nav pushViewController:viewController animated:YES];
        
        if ([viewController isKindOfClass:[LCBaseViewController class]]) {
            LCBaseViewController *baseVC = (id)viewController;
            if (baseVC.isSingleMode) {
                //FIXED: pushing same view controller twice
                NSArray *findVcs = [nav.viewControllers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                    return [evaluatedObject isKindOfClass:[viewController class]];
                }]];
                if (findVcs.count < 2) {
                    return;
                }
                
                //移除掉栈中的实例
                id vcs = [nav.viewControllers filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id  _Nullable evaluatedObject, NSDictionary<NSString *,id> * _Nullable bindings) {
                    return ![evaluatedObject isKindOfClass:[viewController class]];
                }]];
                NSMutableArray *allVCs = [NSMutableArray arrayWithArray:vcs];
                [allVCs addObject:viewController];
                [nav setViewControllers:allVCs animated:NO];
            }
        }
    } else {
        PRESENT(viewController);
    }
}

- (void)replace:(UIViewController *)viewController {
    NSArray *topViewControllers = self.topViewControllers;
    BOOL processed = NO;
    if ([topViewControllers.lastObject isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = (id)topViewControllers.lastObject;
        for (UIViewController *vc in nav.viewControllers.reverseObjectEnumerator) {
            if ([NSStringFromClass(vc.class) isEqualToString:NSStringFromClass(viewController.class)]) {
                NSInteger index = [nav.viewControllers indexOfObject:vc];
                if (NSNotFound != index && index - 1 >= 0) {
                    [nav popToViewController:nav.viewControllers[index - 1] animated:NO];
                }
                [nav pushViewController:viewController animated:YES];
                processed = YES;
                break;
            }
        }
    } else {
        for (UIViewController *topVC in topViewControllers.reverseObjectEnumerator) {
            if ([NSStringFromClass(topVC.class) isEqualToString:NSStringFromClass(viewController.class)]) {
                UIViewController *parent = topVC.presentingViewController;
                [topVC dismissViewControllerAnimated:NO completion:nil];
                [parent presentViewController:viewController animated:YES completion:nil];
                processed = YES;
                break;
            }
        }
    }
    
    if (!processed) {
        SHOW(viewController);
    }
}

- (void)present:(UIViewController *)viewController {
    UIViewController *nav = viewController;
    NSMutableArray *topViewControllers = self.topViewControllers;
    
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        nav = (id)viewController;
    } else if ([viewController isKindOfClass:[LCBaseViewController class]]) {
        LCBaseViewController *baseVC = (id)viewController;
        nav = [[YMNavigationController alloc] initWithRootViewController:viewController];
        ((YMNavigationController *)nav).navigationBarHidden = YES;
        
        if (baseVC.isSingleMode) {
            UIViewController *lastPresentVC = self.topViewControllers.lastObject;
            while (lastPresentVC) {
                if (topViewControllers.count > 1
                    && ([lastPresentVC isKindOfClass:viewController.class]
                        || ([lastPresentVC isKindOfClass:UINavigationController.class]
                            && [((UINavigationController *)lastPresentVC).viewControllers.firstObject isKindOfClass:viewController.class])) ) {
                            
                            [lastPresentVC dismissViewControllerAnimated:NO completion:nil];
                            [topViewControllers removeObject:lastPresentVC];
                }
                lastPresentVC = lastPresentVC.presentingViewController;
            }
        }
    }
    
    [topViewControllers.lastObject presentViewController:nav animated:YES completion:nil];
}

- (void)dismiss {
    NSArray *topViewControllers = self.topViewControllers;
    id lastObject = topViewControllers.lastObject;
    UINavigationController *nav = [lastObject isKindOfClass:[UINavigationController class]] ? lastObject : nil;
    if (nav && nav.viewControllers.count > 1) {
        [nav popViewControllerAnimated:YES];
    } else if (topViewControllers.count > 0){
        [lastObject dismissViewControllerAnimated:YES completion:nil];
    }
}

- (UIViewController *)topViewController {
    id lastViewController = self.topViewControllers.lastObject;
    if ([lastViewController isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = lastViewController;
        return nav.viewControllers.lastObject;
    } else {
        return lastViewController;
    }
}

- (UIViewController *)bottomViewController {
    id firstObject = self.topViewControllers.firstObject;
    if ([firstObject isKindOfClass:[UINavigationController class]]) {
        UINavigationController *nav = firstObject;
        return nav.viewControllers.firstObject;
    } else {
        return firstObject;
    }
}

- (UIViewController *)firstController {
    return self.topViewControllers.firstObject;
}

//TODO: need test
- (UIViewController *)tabController {
    for (id first in [self topViewControllers]) {
        if ([first isKindOfClass:[UITabBarController class]]) {
            return first;
        } else if ([first isKindOfClass:[UINavigationController class]]) {
            UINavigationController *nav = first;
            for (id vc in nav.viewControllers) {
                if ([vc isKindOfClass:[UITabBarController class]]) {
                    return vc;
                }
            }
        }
    }
    return nil;
}

- (void)registerViewControllerClass:(Class)vcClass resourcePath:(NSString *)resourcePath {
    if (nil == resourcePath) {
        return;
    }
    
    self.resourceMap[resourcePath] = vcClass;
}

- (void)goToURL:(NSString *)URLString {
    NSURL *url = [NSURL URLWithString:URLString];
    NSString *path = url.relativePath;
    NSString *query = url.query;
    
    NSMutableDictionary *param = [NSMutableDictionary dictionaryWithCapacity:4];
    if (query.length > 0) {
        NSArray *keyAndValues = [query componentsSeparatedByString:@"&"];
        [keyAndValues enumerateObjectsUsingBlock:^(NSString * _Nonnull keyAndValue, NSUInteger idx, BOOL * _Nonnull stop) {
            NSArray *items = [keyAndValue componentsSeparatedByString:@"="];
            if (items.count > 1) {
                param[items.firstObject] = items.lastObject;
            }
        }];
    }
    [self goToURL:path param:param];
}

- (void)goToURL:(NSString *)URLString param:(NSDictionary *)param {
    [self goToURL:URLString param:param replace:NO];
}

- (void)goToURL:(NSString *)URLString param:(NSDictionary *)param replace:(BOOL)replace {
//    CLS_LOG(@"resource map:\n%@ URLString:%@ param:%@", self.resourceMap, URLString, param);
    
    NSString *path = URLString;
    Class controllerClass = self.resourceMap[path];

    //if did not resigter with class, handle with a block
    if (nil == controllerClass) {
        void (^block)(NSString *path, id param) = self.resourceBlockMap[path];
        if (block) block(path, param);
        return;
    }

    LCBaseViewController *vc = [[controllerClass alloc] init];
    //判断是不是固定的视图控制器，如是则直接跳转
    if ([self isFixedViewController:vc] && [BOTTOM_VIEW_CONTROLLER isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabVC = (id)BOTTOM_VIEW_CONTROLLER;
        NSInteger index = NSNotFound;
        for (NSInteger i=0; i<tabVC.viewControllers.count; i++) {
            id tabSubVC = tabVC.viewControllers[i];
            if ([tabSubVC isKindOfClass:vc.class]) {
                index = i;
                break;
            }
        }
        if (NSNotFound != index) {
            if (BOTTOM_VIEW_CONTROLLER.presentedViewController) {
                [BOTTOM_VIEW_CONTROLLER.presentedViewController dismissViewControllerAnimated:NO completion:nil];
            }
            
            UIViewController *vc = tabVC.viewControllers[index];
            if ([vc isKindOfClass:[LCBaseViewController class]]) {
                ((LCBaseViewController *)vc).param = param;
            }
            [tabVC setSelectedIndex:index];
            if (tabVC.navigationController.viewControllers.count > 1) {
                [tabVC.navigationController popToRootViewControllerAnimated:YES];
            }
        }
    } else {
        if (![vc isKindOfClass:[LCBaseViewController class]]) {
//            CLS_LOG(@"vc 不是LCBaseViewController，不支持跳转");
            return;
        }
        vc.param = param;
        if (replace) {
            REPLACE(vc);
        } else {
            SHOW(vc);
        }
    }
}

- (void)presentToURL:(NSString *)URLString param:(NSDictionary *)param {
//    CLS_LOG(@"resource map:\n%@", self.resourceMap);
    
    NSString *path = URLString;
    Class controllerClass = self.resourceMap[path];

    //if did not resigter with class, handle with a block
    if (nil == controllerClass) {
        void (^block)(NSString *path, id param) = self.resourceBlockMap[path];
        if (block) block(path, param);
        return;
    }

    LCBaseViewController *vc = [[controllerClass alloc] init];
    vc.param = param;
    PRESENT(vc);
}

#pragma mark - Private
- (BOOL)isFixedViewController:(UIViewController *)viewController {
    UIViewController *bottomVC = BOTTOM_VIEW_CONTROLLER;
    BOOL jump = NO;
    if ([bottomVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabVC = (id)bottomVC;
        for (UIViewController *vc in tabVC.viewControllers) {
            if ([vc isKindOfClass:[viewController class]]) {
                jump = YES;
                break;
            }
        }
    }
    return jump;
}

- (UIViewController *)fixedViewControllerOfClass:(Class)class {
    UIViewController *bottomVC = BOTTOM_VIEW_CONTROLLER;
    if ([bottomVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabVC = (id)bottomVC;
        for (UIViewController *vc in tabVC.viewControllers) {
            if ([vc isKindOfClass:class]) {
                return vc;
            }
        }
    }
    return nil;
}

- (void)registerPath:(NSString *)path handle:(void (^)(NSString *path, id param))handle {
    self.resourceBlockMap[path] = handle;
}

#pragma mark - Getter 
- (NSMutableArray *)topViewControllers {
    NSMutableArray *viewcontrollers = [NSMutableArray array];
    UIViewController *rootVC =  UIApplication.sharedApplication.keyWindow.rootViewController;
    [viewcontrollers addObject:rootVC];
    
    UIViewController *vc = rootVC.presentedViewController;
    while (vc) {
        [viewcontrollers addObject:vc];
        
        vc = vc.presentedViewController;
    }
    _topViewControllers = viewcontrollers;
    return _topViewControllers;
}

- (NSMutableDictionary *)resourceMap {
    if (nil == _resourceMap) {
        _resourceMap = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    return _resourceMap;
}

- (NSMutableDictionary *)resourceBlockMap {
    if (nil == _resourceBlockMap) {
        _resourceBlockMap = [[NSMutableDictionary alloc] initWithCapacity:10];
    }
    return _resourceBlockMap;
}

+ (UIViewController *)getRootViewController{
    UIWindow* window = [[[UIApplication sharedApplication] delegate] window];
    NSAssert(window, @"The window is empty");    return window.rootViewController;
}

+ (UIViewController *)getCurrentViewController{
    UIViewController* currentViewController = [self getRootViewController];
    BOOL runLoopFind = YES;
    while (runLoopFind) {
        if (currentViewController.presentedViewController) {
            currentViewController = currentViewController.presentedViewController;
        } else if ([currentViewController isKindOfClass:[UINavigationController class]]) {
            UINavigationController* navigationController = (UINavigationController* )currentViewController;
            currentViewController = [navigationController.childViewControllers lastObject];
        } else if ([currentViewController isKindOfClass:[UITabBarController class]]) {
            UITabBarController* tabBarController = (UITabBarController* )currentViewController;
            currentViewController = tabBarController.selectedViewController;
        } else {
            NSUInteger childViewControllerCount = currentViewController.childViewControllers.count;
            if (childViewControllerCount > 0) {
                currentViewController = currentViewController.childViewControllers.lastObject;
                return currentViewController;
            } else {
                return currentViewController;
            }
        }
    }
    return currentViewController;
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
@end
