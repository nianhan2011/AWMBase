//
//  LCUIService.h
//  Pods
//
//  Created by hugo on 2017/5/31.
//
//

#import <Foundation/Foundation.h>
#import "SynthsizeSingleton.h"

@interface LCRouter : NSObject
LCR_DECLARE_SINGLETON_FOR_CLASS(LCRouter);

//最上层Controller
- (UIViewController *)topViewController;
//非严格意义上的最下层Controller, 一般是指架构中的tab controller
- (UIViewController *)bottomViewController NS_DEPRECATED_IOS(0.1.0, 0.2.0);
- (UIViewController *)firstController NS_AVAILABLE_IOS(0.2.0);
- (UIViewController *)tabController NS_AVAILABLE_IOS(0.2.0);;

- (void)show:(UIViewController *)viewController;
- (void)replace:(UIViewController *)viewController;
- (void)present:(UIViewController *)viewController;
- (void)dismiss;

// appschema:///module/vc?a=&b=&c=
- (void)goToURL:(NSString *)URLString;
- (void)goToURL:(NSString *)URLString param:(NSDictionary *)param;
- (void)goToURL:(NSString *)URLString param:(NSDictionary *)param replace:(BOOL)replace;

- (void)presentToURL:(NSString *)URLString param:(NSDictionary *)param;

- (void)registerViewControllerClass:(Class)vcClass resourcePath:(NSString *)resourcePath;

/**
 注册处理path的闭包

 @param path path
 @param handle handel
 */
- (void)registerPath:(NSString *)path handle:(void (^)(NSString *path, id param))handle;

@end

#define SHOW(viewController) [LCRouter.sharedLCRouter show:(viewController)]
#define REPLACE(viewController) [LCRouter.sharedLCRouter replace:(viewController)]
#define PRESENT(viewController) [LCRouter.sharedLCRouter present:(viewController)]
#define DISMISS() [LCRouter.sharedLCRouter dismiss]
#define TOP_VIEW_CONTROLLER [LCRouter.sharedLCRouter topViewController]
#define BOTTOM_VIEW_CONTROLLER [LCRouter.sharedLCRouter bottomViewController]

#define LC_REGISTE_VIEWCONTROLLER_PATH(cls_name, path)                                         \
@implementation cls_name (RegisterResourcePath)                                                \
                                                                                               \
+ (void)load {                                                                                 \
    [LCRouter.sharedLCRouter registerViewControllerClass:self.class resourcePath:path];  \
}                                                                                              \
@end                                                                                           \

#define LC_GO_TO_URL(path) \
[LCRouter.sharedLCRouter goToURL:path]

#define LC_GO_TO_URL_PARAM(_path, _param) \
[LCRouter.sharedLCRouter goToURL:_path param:_param]

#define LC_REPLACE_GO_TO_URL_PARAM(_path, _param) \
[LCRouter.sharedLCRouter goToURL:_path param:_param replace:YES]

#define LC_PRESENT_TO_URL_PARAM(_path, _param) \
[LCRouter.sharedLCRouter presentToURL:_path param:_param]
