//
//  LCAppInfo.m
//  Pods
//
//  Created by hugo on 2017/9/7.
//
//

#import "LCAppInfo.h"

@implementation LCAppInfo
LCR_SYNTHESIZE_SINGLETON_FOR_CLASS(LCAppInfo);

- (instancetype)init {
    self = [super init];
    if (self) {
        _isReviewing = YES;
        _channelID = @"1";
    }
    return self;
}

- (NSArray *)mapToNumberArray:(NSArray *)items {
    NSMutableArray *array = [NSMutableArray arrayWithCapacity:items.count];
    [items enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [array addObject:@([obj integerValue])];
    }];
    return array;
}

- (NSComparisonResult)compareServerVersion:(NSString *)serverVersion localVersion:(NSString *)localVersion {
    NSArray *localComponents = [self mapToNumberArray:[localVersion componentsSeparatedByString:@"."]];
    NSArray *serverComponents = [self mapToNumberArray:[serverVersion componentsSeparatedByString:@"."]];
    
    for (NSInteger i = 0; i<serverComponents.count; i++) {
        NSNumber *serverVersion = serverComponents[i];
        NSNumber *localVersion = nil;
        if (i < localComponents.count) {
            localVersion = localComponents[i];
        } else {
            return NSOrderedDescending;
        }
        
        NSComparisonResult rst = [serverVersion compare:localVersion];
        if (NSOrderedSame != rst) {
            return rst;
        }
    }
    return NSOrderedSame;
}

- (NSString *)appVersion {
    if (nil == _appVersion) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        _appVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    }
    return _appVersion;
}

- (NSString *)bundleVersion {
    if (nil == _bundleVersion) {
        NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
        _bundleVersion = [infoDictionary objectForKey:@"CFBundleVersion"];
    }
    return _bundleVersion;
}

- (void)setServerAppVersion:(NSString *)serverAppVersion {
    if (![serverAppVersion isEqualToString:_serverAppVersion]) {
        _serverAppVersion = serverAppVersion;
        if (self.serverAppVersion.length == 0) {
            self.isReviewing = YES;
        } else {
            self.isReviewing = [self compareServerVersion:self.serverAppVersion localVersion:self.appVersion] == NSOrderedAscending;
        }
    }
}

#pragma mark - Getter
- (BOOL)isReviewing {
    NSString *debugVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"debug.server.app.version"];
    if (debugVersion.length > 0) {
        return [self compareServerVersion:debugVersion localVersion:self.appVersion] == NSOrderedAscending;
    } else {
        return _isReviewing;
    }
}

@end
