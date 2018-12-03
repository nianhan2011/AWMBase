//
//  LCHttpClient.m
//  Pods
//
//  Created by hugo on 2017/9/6.
//
//

#import <AFNetworking/AFNetworking.h>
#import <Objection/Objection.h>
#import "LCAppInfo.h"
#import "LCHttpClient.h"
#import "RACAFNetworking.h"
#import "LCDevice.h"
#import "NSString+YYAdd.h"
#import <Protocols.h>

static AFHTTPSessionManager *staticManager = nil;
@implementation LCHttpClient

+ (AFHTTPSessionManager *)HTTPManager {
    if (nil == staticManager) {
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        configuration.HTTPAdditionalHeaders = @{@"Accept": @"application/json"};
        staticManager = [[AFHTTPSessionManager alloc] initWithBaseURL:nil
                                                 sessionConfiguration:configuration];
    }
    return staticManager;
}

+ (nullable RACSignal *)lc_GET:(nonnull NSString *)path
                         param:(nullable NSDictionary *)param {
    AFHTTPSessionManager *manager = [self HTTPManager];
    @weakify(self);
    return [[[[manager rac_GET:path parameters:[self parameterWithBaseParam:param]] map:^id(id value) {
        return [value first];
    }] doNext:^(id x) {
        @strongify(self);
        [self handleResponse:x];
    }] doError:^(NSError *error) {
        @strongify(self);
        [self handleResponse:error.userInfo];
    }];
}

+ (nullable RACSignal *)lc_POST:(nonnull NSString *)path
                          param:(nullable NSDictionary *)param {
    AFHTTPSessionManager *manager = [self HTTPManager];
    @weakify(self);
    return [[[[manager rac_POST:path parameters:[self parameterWithBaseParam:param]] map:^id(id value) {
        return [value first];
    }] doNext:^(id x) {
        @strongify(self);
        [self handleResponse:x];
    }] doError:^(NSError *error) {
        @strongify(self);
        [self handleResponse:error.userInfo];
    }];
}

//未覆盖测试用例
+ (nullable RACSignal *)lc_upload:(nonnull NSString *)path
                             file:(nonnull NSString *)filePath
                         fileName:(nonnull NSString *)fileName
                            param:(nullable NSDictionary *)param {
    AFHTTPSessionManager *manager = [self HTTPManager];
    @weakify(self);
    return [[[[manager rac_POST:path
                    parameters:[self parameterWithBaseParam:param]
     constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
         [formData appendPartWithFileURL:[NSURL fileURLWithPath:filePath] name:fileName error:nil];
     }] map:^id(id value) {
         return [value first];
     }] doNext:^(id x) {
         @strongify(self);
         [self handleResponse:x];
     }] doError:^(NSError *error) {
         @strongify(self);
         [self handleResponse:error.userInfo];
     }];
}

//未覆盖测试用例
+ (nullable RACSignal *)lc_upload:(nonnull NSString *)path
                         fileData:(nonnull NSData *)data
                             name:(nonnull NSString *)name
                         fileName:(NSString *)fileName
                         mimeType:(NSString *)mimeType
                            param:(nullable NSDictionary *)param {
    AFHTTPSessionManager *manager = [self HTTPManager];
    @weakify(self);
    return [[[[manager rac_POST:path
                    parameters:[self parameterWithBaseParam:param]
     constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
         [formData appendPartWithFileData:data name:name fileName:fileName mimeType:mimeType];
     }] map:^id(id value) {
         return [value first];
     }] doNext:^(id x) {
         @strongify(self);
         [self handleResponse:x];
     }] doError:^(NSError *error) {
         @strongify(self);
         [self handleResponse:error.userInfo];
     }];
}

+ (NSDictionary *)parameterWithBaseParam:(NSDictionary *)param {
    NSString *deviceIDMD5 = [LCDevice deviceId];
    NSString *appVersion = LCAppInfo.sharedLCAppInfo.appVersion ?: @"";
    NSString *channelID = LCAppInfo.sharedLCAppInfo.channelID;
    NSString *ref = [[NSUserDefaults standardUserDefaults] valueForKey:@"ref"] != nil ? [[NSUserDefaults standardUserDefaults] valueForKey:@"ref"] : @"";
    id<ILCUserInfo> userInfo = [[JSObjection defaultInjector] getObject:@protocol(ILCUserInfo)];
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSMutableDictionary *baseParam = [@{@"uid": @(userInfo.uid),
                                        @"token": userInfo.token ?: @"",
                                        @"channel_id": channelID,
                                        @"device_id": deviceIDMD5,
                                        @"timestamp": @((NSUInteger)[[NSDate date] timeIntervalSince1970] * 1000),
                                        @"app_version": appVersion,
                                        @"ref": ref,
                                        @"platform": @"IOS",
                                        @"from" : [infoDictionary objectForKey:@"CFBundleIdentifier"],
                                        } mutableCopy];
    
    NSMutableDictionary *oriParameter = [NSMutableDictionary dictionary];
    if (param.count > 0) {
        [oriParameter addEntriesFromDictionary:param];
    }
    [oriParameter addEntriesFromDictionary:baseParam];
    [oriParameter removeObjectForKey:@"sign"];
    
    NSMutableDictionary *parameter = [NSMutableDictionary dictionary];
    for (NSString *key in oriParameter) {
        NSString *k = [key lowercaseString];
        parameter[k] = oriParameter[key];
    }
    
    //1. 升序排列 2. 拼接字符串 3. 增加 key=accesskey 3. md5
    NSArray *sortKeys = [parameter.allKeys sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return [obj1 compare:obj2];
    }];
    NSMutableArray *sortValues = [NSMutableArray arrayWithCapacity:sortKeys.count];
    [sortKeys enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [sortValues addObject:[NSString stringWithFormat:@"%@=%@", obj, parameter[obj]]];
    }];
    NSMutableString *tosign = [[sortValues componentsJoinedByString:@"&"] mutableCopy];
    NSString *sign = [self signParam:tosign];
    oriParameter[@"sign"] = sign;
    return oriParameter;
}

+ (NSString *)signParam:(NSString *)signString {
    signString = [signString stringByAppendingString:@"&key=PKwUJyO1GGraH7mDhClqWHExSPgGgcq"];
    NSString *sign = [signString md5String];
    sign = [sign md5String];
    return sign;
}

#pragma mark - Private
+ (void)handleResponse:(id)response {
    if (![response isKindOfClass:NSDictionary.class]) {
        return;
    }
    NSString *version = response[@"version"];
    NSString *token = response[@"token"];
    
    if (version) {
        LCAppInfo.sharedLCAppInfo.serverAppVersion = version;
    }
    
    id<ILCUserInfo> userInfo = [[JSObjection defaultInjector] getObject:@protocol(ILCUserInfo)];
    if (token) {
        userInfo.token = token;
    }
    
//     token失效, 接口需要登录
    if ([response[@"code"] integerValue] == 1006) {
        [userInfo cleanLoginState];
        [userInfo openLoginScence];
    }
    
//     token失效, 接口返回正常不需要登录
    if ([response[@"code"] integerValue] == 1005) {
        [userInfo cleanLoginState];
    }
}
@end
