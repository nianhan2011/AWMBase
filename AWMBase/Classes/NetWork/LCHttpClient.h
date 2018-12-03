//
//  LCHttpClient.h
//  Pods
//
//  Created by hugo on 2017/9/6.
//
//

#import <ReactiveCocoa/ReactiveCocoa.h>
#import <Foundation/Foundation.h>

@interface LCHttpClient : NSObject

+ (nullable RACSignal *)lc_GET:(nonnull NSString *)path
                         param:(nullable NSDictionary *)param;

+ (nullable RACSignal *)lc_POST:(nonnull NSString *)path
                          param:(nullable NSDictionary *)param;

//未覆盖测试用例
+ (nullable RACSignal *)lc_upload:(nonnull NSString *)path
                             file:(nonnull NSString *)filePath
                         fileName:(nonnull NSString *)fileName
                            param:(nullable NSDictionary *)param;

//未覆盖测试用例
+ (nullable RACSignal *)lc_upload:(nonnull NSString *)path
                         fileData:(nonnull NSData *)data
                             name:(nonnull NSString *)name
                         fileName:(nonnull NSString *)fileName
                         mimeType:(nonnull NSString *)mimeType
                            param:(nullable NSDictionary *)param;

+ (nullable NSDictionary *)parameterWithBaseParam:(nullable NSDictionary *)param;
+ (nullable NSString *)signParam:(nonnull NSString *)signString;

@end
