//
//  Protocols.h
//  Pods
//
//  Created by hugo on 2017/9/7.
//
//

#ifndef Protocols_h
#define Protocols_h

@protocol ILCUserInfo <NSObject>

@property (assign, nonatomic, readonly) NSInteger uid;
@property (strong, nonatomic, readonly) NSString *name;
@property (strong, nonatomic) NSString *token;

- (BOOL)isLogined;

- (void)cleanLoginState;
- (void)openLoginScence;

- (void)updateAccountWithExtcredits2:(NSInteger)ex2 vipMoney:(NSInteger)vipMoney;

@end

#endif /* Protocols_h */
