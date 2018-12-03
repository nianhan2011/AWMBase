//
//  LCAppInfo.h
//  Pods
//
//  Created by hugo on 2017/9/7.
//
//

#import <Foundation/Foundation.h>
#import "SynthsizeSingleton.h"

@interface LCAppInfo : NSObject
LCR_DECLARE_SINGLETON_FOR_CLASS(LCAppInfo);

@property (strong, nonatomic) NSString *serverAppVersion;
@property (strong, nonatomic) NSString *appstoreAppVersion;
@property (strong, nonatomic) NSString *appVersion;
@property (strong, nonatomic) NSString *bundleVersion;

@property (strong, nonatomic) NSString *channelID; //app启动时注入
@property (strong, nonatomic) NSString *channelName; //app启动时注入

@property (assign, nonatomic) BOOL isReviewing;
@property (nonatomic, assign) BOOL liveConfig;
@end
