//
//  LCDevice.m
//  LCBase
//
//  Created by hugo on 2018/1/19.
//

#import "LCDevice.h"
#import <AdSupport/AdSupport.h>
#import "NSString+YYAdd.h"

@implementation LCDevice

+ (NSString *)deviceId {
    static NSString *deviceID = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        deviceID = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
        if (deviceID.length == 0 ||
            [deviceID isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
            deviceID = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
        }
        deviceID = [deviceID md5String];
    });

    return deviceID;
}
@end
