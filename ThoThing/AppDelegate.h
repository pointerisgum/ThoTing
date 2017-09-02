//
//  AppDelegate.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 6. 22..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Google/CloudMessaging.h>
#import "MainViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate, GGLInstanceIDDelegate, GCMReceiverDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) MainViewController *vc_Main;
@property (nonatomic, assign) BOOL isChannelMode;
@property(nonatomic, readonly, strong) NSString *registrationKey;
@property(nonatomic, readonly, strong) NSString *messageKey;
@property(nonatomic, readonly, strong) NSString *gcmSenderID;
@property(nonatomic, readonly, strong) NSDictionary *registrationOptions;

- (void)showMainView;
- (void)showLoginView;
- (void)showChannelView:(NSDictionary *)dic;

@end

//용어정리
//피드 , 챗, 라이브러리, MY

//실섭
//kr.bmw.Test
//1.25
//앱 이름 : 토팅

//개발
//kr.bmw.Test2
//1.25
//앱이름 : 토팅 Dev

//PDF 출제 앱
//kr.bmw.Test3
//1.00
//앱이름 : 토팅 PDF
