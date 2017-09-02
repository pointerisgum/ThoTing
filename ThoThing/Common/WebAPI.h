//
//  WebAPI.h
//  Kizzl
//
//  Created by Kim Young-Min on 13. 6. 3..
//  Copyright (c) 2013년 Kim Young-Min. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WebAPI : NSObject
+ (WebAPI *)sharedData;
//- (void)callWebAPI:(NSMutableDictionary *)params withOwner:(id)owner withCompleteMethod:(SEL)selector;
//- (void)callWebAPIBlock:(NSMutableDictionary *)params withBlock:(void(^)(id resulte, NSError *error))completion;
//- (void)callWebAPIBlockNonAlert:(NSMutableDictionary *)params withBlock:(void(^)(id resulte, NSError *error))completion;
//- (void)callNaverAPI:(NSMutableDictionary *)params withOwner:(id)owner withCompleteMethod:(SEL)selector;
//- (void)imageUpload:(NSMutableDictionary *)dataParams withImages:(NSDictionary *)imageParams withBlock:(void(^)(id resulte, NSError *error))completion;
- (NSURL *)getWebViewUrl:(NSMutableDictionary *)params;
- (NSString *)getWebViewUrlString;
- (void)openStore;


//- (void)callWebAPIBlock:(NSString *)path param:(NSMutableDictionary *)params withBlock:(void(^)(id resulte, NSError *error))completion;
- (void)imageUpload:(NSString *)path param:(NSMutableDictionary *)dataParams withImages:(NSDictionary *)imageParams withBlock:(void(^)(id resulte, NSError *error))completion;

//- (void)fileUpload:(NSString *)path;
- (void)fileUpload:(NSString *)path param:(NSMutableDictionary *)dataParams withFileUrl:(NSURL *)url withBlock:(void(^)(id resulte, NSError *error))completion;


////HIM/드림어스 회원인증
//- (void)callHimDreamAuthWebAPIBlock:(NSMutableDictionary *)params withBlock:(void(^)(id resulte, NSError *error))completion;

- (NSURL *)getWebViewUrl:(NSMutableDictionary *)params withUrl:(NSString *)aUrlString;



- (void)callAsyncWebAPIBlock:(NSString *)path param:(NSMutableDictionary *)params withBlock:(void(^)(id resulte, NSError *error))completion;

//파리바게뜨 가맹대표 로그인
- (void)callOwnerLoginWebAPIBlock:(NSMutableDictionary *)params withBlock:(void(^)(id resulte, NSError *error))completion;



//앱 스토어 정보 가져오기
- (void)getAppStoreInfo:(void(^)(id resulte, NSError *error))completion;


- (void)callAsyncWebAPIBlock:(NSString *)path param:(NSMutableDictionary *)params indicatorShow:(BOOL)isIndicatorShow withBlock:(void(^)(id resulte, NSError *error))completion;

- (void)callAsyncWebAPIBlock:(NSString *)path param:(NSMutableDictionary *)params withMethod:(NSString *)aMethod withBlock:(void(^)(id resulte, NSError *error))completion;

- (void)callAsyncWebAPIBlock:(NSString *)path param:(NSMutableDictionary *)params withMethod:(NSString *)aMethod withShowIndicator:(BOOL)isShowIndicato withBlock:(void(^)(id resulte, NSError *error))completion;

//센드버드 api
- (void)callAsyncSendBirdAPIBlock:(NSString *)path param:(NSMutableDictionary *)params withMethod:(NSString *)aMethod withBlock:(void(^)(id resulte, NSError *error))completion;

- (void)callAsyncWebAPIBlock:(NSString *)path param:(NSMutableDictionary *)params withMethod:(NSString *)aMethod withIndicator:(BOOL)isIndicaror withBlock:(void(^)(id resulte, NSError *error))completion;

- (void)cancelMethod:(NSString *)aMethod withPath:(NSString *)aPath;

- (void)callSyncWebAPIBlock:(NSString *)path param:(NSMutableDictionary *)params withMethod:(NSString *)aMethod withBlock:(void(^)(id resulte, NSError *error))completion;

- (void)callPushGCM:(NSString *)path param:(NSMutableDictionary *)params withMethod:(NSString *)aMethod withBlock:(void(^)(id resulte, NSError *error))completion;

@end
