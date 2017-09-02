 //
//  AppDelegate.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 6. 22..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "AppDelegate.h"
#import "InputUserInfoViewController.h"
#import <SendBirdSDK/SendBirdSDK.h>
#import "SBJson.h"
//@import SendBirdSDK;
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>
#import "MainChannelViewController.h"
#import "ChatFeedMainViewController.h"

@interface AppDelegate ()
{
    BOOL isBecomForground;      //백그라운드에서 노티를 타고 들어왔을때 체크를 위한 변수
    BOOL isForground;           //포인지 백인지 체크하는 변수 (포일때만 얼렛창 띄우기)
    NSDictionary *dic_PushInfo;
}

@property (nonatomic, strong) UINavigationController *loginNavi;
@property (nonatomic, strong) MainChannelViewController *vc_Channel;

@property(nonatomic, strong) void (^registrationHandler)
(NSString *registrationToken, NSError *error);
@property(nonatomic, assign) BOOL connectedToGCM;
@property(nonatomic, strong) NSString* registrationToken;
@property(nonatomic, assign) BOOL subscribedToTopic;

@end

NSString *const SubscriptionTopic = @"/topics/global";

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url
{
//    if( url )
//    {
//        [self.mainNavi dismissViewControllerAnimated:NO completion:^{
//            
//            [self.mainNavi popToRootViewControllerAnimated:NO];
//        }];
//        
//        [self performSelector:@selector(onInterval:) withObject:url afterDelay:1.0f];
//        
//    }
//    else
//    {
//        //        ALERT(nil, @"없음", nil, @"확인", nil);
//    }
    
    return YES;
}

//- (void)onInterval:(NSURL *)url
//{
//    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    InputQuestionViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"InputQuestionViewController"];
//    //    vc.str_Path = [url absoluteString];
//    
//    [[NSUserDefaults standardUserDefaults] setObject:[url absoluteString] forKey:@"WebUrl"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//    [self.mainNavi pushViewController:vc animated:NO];
//}
//- (void)onTest
//{
//    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"ymtest"];
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"ShareExamNoti" object:dic];
//
//    
//}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch

//    [self performSelector:@selector(onTest) withObject:nil afterDelay:3.0f];
    
    
    [Common removeAllPdfFile];

    isForground = YES;
    
    [Fabric with:@[[Crashlytics class]]];
 
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"alert":@{@"title":@"제목",
                                                                            @"body":@"내용",
                                                                            @"type":@"dash_board"}}
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSLog(@"%@", jsonString);
//    int cacheSizeMemory = 4 * 1024 * 1024;
//    int cacheSizeDisk = 32 * 1024 * 1024;
//
//
//    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:cacheSizeMemory
//                                                            diskCapacity:cacheSizeDisk
//                                                                diskPath:@"nsurlcache"];
//    [NSURLCache setSharedURLCache:sharedCache];

    
//    NSString *str = @"강,건,너-불,구-경";
//    [str strin]
    
    
    
    
    ////////////구글 GCM 코드//////////////
    //{"commandType":"confirmJoin","message":"영어듣기 채널에 회원으로 등록되었습니다." ,"url":"http://ui.thoting.com/Push/message?nId=3"}
    //token = eC9rMOEtetE:APA91bE0p4at8p3K2fmbS5U4wqWKQsuIbNYgxW4sJ-nKnKwGxog6AxPv2U1OJ7-3SRwTl40LD8HpYeMTf33WWKorDPrbsA0wuQb6HhSZxGcWv_vPUTx_dFF3aH1R_4dAOENZLSyl4URy
    //api key : AIzaSyApwZSLlPO_FzYsGf4Y-LQGcerI-7httq8
    //api key : AIzaSyDQhSgx4cYHixYfd8ZNQD0sMI5cexeExsU
    //sender id : 398430121320

    _registrationKey = kRegistrationKey;
    _messageKey = kMessageKey;
    
    // Configure the Google context: parses the GoogleService-Info.plist, and initializes
    // the services that have entries in the file
    NSError* configureError;
    [[GGLContext sharedInstance] configureWithError:&configureError];
    NSAssert(!configureError, @"Error configuring Google services: %@", configureError);
    _gcmSenderID = [[[GGLContext sharedInstance] configuration] gcmSenderID];
    // Register for remote notifications
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1) {
        // iOS 7.1 or earlier
        UIRemoteNotificationType allNotificationTypes =
        (UIRemoteNotificationTypeSound | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge);
        [application registerForRemoteNotificationTypes:allNotificationTypes];
    } else {
        // iOS 8 or later
        // [END_EXCLUDE]
        UIUserNotificationType allNotificationTypes =
        (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
        UIUserNotificationSettings *settings =
        [UIUserNotificationSettings settingsForTypes:allNotificationTypes categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    // [END register_for_remote_notifications]
    // [START start_gcm_service]
    GCMConfig *gcmConfig = [GCMConfig defaultConfig];
    gcmConfig.receiverDelegate = self;
    [[GCMService sharedInstance] startWithConfig:gcmConfig];
    // [END start_gcm_service]
    __weak typeof(self) weakSelf = self;
    // Handler for registration token request
    _registrationHandler = ^(NSString *registrationToken, NSError *error){
        if (registrationToken != nil)
        {
//            ALERT(nil, registrationToken, nil, @"ok", nil);
            
//            [[UIPasteboard generalPasteboard] setString:registrationToken];

            weakSelf.registrationToken = registrationToken;
            NSLog(@"Registration Token: %@", registrationToken);
            [weakSelf subscribeToTopic];
            NSDictionary *userInfo = @{@"registrationToken":registrationToken};
            [[NSNotificationCenter defaultCenter] postNotificationName:weakSelf.registrationKey
                                                                object:nil
                                                              userInfo:userInfo];
            
            [[NSUserDefaults standardUserDefaults] setObject:registrationToken forKey:@"PushToken"];
            [[NSUserDefaults standardUserDefaults] synchronize];

        }
        else
        {
            NSLog(@"Registration to GCM failed with error: %@", error.localizedDescription);
            NSDictionary *userInfo = @{@"error":error.localizedDescription};
            [[NSNotificationCenter defaultCenter] postNotificationName:weakSelf.registrationKey
                                                                object:nil
                                                              userInfo:userInfo];
        }
    };
    ///////////////////////////////////////////////////////////////////////////
    
    
//    [SBDMain initWithApplicationId:kSendBirdAppId];
//    [SendBird initAppId:kSendBirdAppId];
    
    [SBDMain initWithApplicationId:kSendBirdAppId];
    [SBDMain setLogLevel:SBDLogLevelNone];
    [SBDOptions setUseMemberAsMessageSender:YES];

    NSLog(@"%ld", (long)[SBDMain version]);
    
//    NSString *str_UserId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
//    NSString *str_UserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
//    [SendBird loginWithUserId:str_UserId andUserName:str_UserName andUserImageUrl:nil andAccessToken:kSendBirdApiToken];


    if (launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey])
    {
        [self application:application didReceiveRemoteNotification:launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]];
    }

    
    
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    if( ![[NSUserDefaults standardUserDefaults] valueForKey:@"FirstBoot"] )
    {
        NSMutableArray *arM = [NSMutableArray array];
        [[NSUserDefaults standardUserDefaults] setObject:arM forKey:@"OfflineCall"];
        
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"email"];
        [[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"password"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"IsLogin"];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"IsUserInfo"];
        [[NSUserDefaults standardUserDefaults] setObject:@"NO" forKey:@"FirstBoot"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    [self updateCheck];
    
    BOOL isLogin = [[[NSUserDefaults standardUserDefaults] objectForKey:@"IsLogin"] boolValue];
    if( isLogin )
    {
        //로그인이면 메인
        [self showMainView];
    }
    else
    {
        [self showLoginView];
    }

    return YES;
}

- (void)subscribeToTopic {
    // If the app has a registration token and is connected to GCM, proceed to subscribe to the
    // topic
    if (_registrationToken && _connectedToGCM) {
        [[GCMPubSub sharedInstance] subscribeWithToken:_registrationToken
                                                 topic:SubscriptionTopic
                                               options:nil
                                               handler:^(NSError *error) {
                                                   if (error) {
                                                       // Treat the "already subscribed" error more gently
                                                       if (error.code == 3001) {
                                                           NSLog(@"Already subscribed to %@",
                                                                 SubscriptionTopic);
                                                       } else {
                                                           NSLog(@"Subscription failed: %@",
                                                                 error.localizedDescription);
                                                       }
                                                   } else {
                                                       self.subscribedToTopic = true;
                                                       NSLog(@"Subscribed to %@", SubscriptionTopic);
                                                   }
                                               }];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    isForground = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EnterForegroundNoti" object:nil userInfo:nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatFeedReloadNoti" object:nil];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    [Common removeAllPdfFile];

    isForground = NO;
}

- (void)updateCheck
{
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/iOS/release/info"
                                        param:nil
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                NSDictionary *dic = [resulte objectForKey:@"releaseInfo"];

                                                CGFloat fCurrentVersion = [[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] floatValue];
                                                CGFloat fNewVersion = [[dic objectForKey:@"appVersion"] floatValue];
                                                if( fCurrentVersion < fNewVersion )
                                                {
                                                    NSString *str_ReqYn = [dic objectForKey:@"isRequired"];
                                                    if( [str_ReqYn isEqualToString:@"Y"] )
                                                    {
                                                        //필수 업데이트
                                                        UIAlertView *alert = CREATE_ALERT(nil, @"업데이트 하셔야 이용하실 수 있습니다.", @"업데이트", nil);
                                                        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                            
                                                            NSString *str_Url = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", [dic objectForKey:@"downloadUrl"]];
                                                            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str_Url]];
                                                            exit(0);
                                                        }];
                                                    }
                                                    else
                                                    {
                                                        //선택 업데이트
                                                        UIAlertView *alert = CREATE_ALERT(nil, @"업데이트 내역이 있습니다\n업데이트 하시겠습니까?", @"예", @"아니요");
                                                        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                            
                                                            if( buttonIndex == 0 )
                                                            {
                                                                NSString *str_Url = [NSString stringWithFormat:@"itms-services://?action=download-manifest&url=%@", [dic objectForKey:@"downloadUrl"]];
                                                                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str_Url]];
                                                                exit(0);
                                                            }
                                                        }];
                                                    }
                                                }
                                            }
                                        }
                                    }];
}

- (void)showMainView
{
    self.isChannelMode = NO;
    
    NSString *str_Key = [NSString stringWithFormat:@"DashBoardCount_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSDictionary *dicM = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
    
    if( dicM == nil )
    {
        NSMutableDictionary *dicM_Count = [NSMutableDictionary dictionary];
        [[NSUserDefaults standardUserDefaults] setObject:dicM_Count forKey:str_Key];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    

    __block UIStoryboard *storyboard = self.window.rootViewController.storyboard;
    self.vc_Main = [storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];

    
    //메인화면 보여준 후 로그인을 태운다
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"email"], @"email",
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"password"], @"password",
                                        [Util getUUID], @"uuid",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/signin"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                NSDictionary *dic = [resulte objectForKey:@"result"];
                                                [[NSUserDefaults standardUserDefaults] setObject:[resulte objectForKey:@"apiToken"] forKey:@"apiToken"];
                                                [[NSUserDefaults standardUserDefaults] setObject:[resulte objectForKey:@"secretKey"] forKey:@"secretKey"];
                                                [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey:@"userId"] forKey:@"userId"];
                                                [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey:@"userName"] forKey:@"userName"];
                                                [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey:@"userRole"] forKey:@"userRole"];
                                                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld",
                                                                                                  [[dic objectForKey:@"userSchoolId"] integerValue]] forKey:@"userSchoolId"];
                                                
                                                [[NSUserDefaults standardUserDefaults] setObject:[resulte objectForKey:@"hashtagStr"] forKey:@"hashtagStr"];
                                                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", [resulte objectForKey:@"hashtagChannelId"]] forKey:@"hashtagChannelId"];
                                                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", [resulte objectForKey:@"channelHashTag"]] forKey:@"channelHashTag"];
                                                
                                                NSData *followChannelData = [NSKeyedArchiver archivedDataWithRootObject:[resulte objectForKey:@"followChannelInfo"]];
                                                [[NSUserDefaults standardUserDefaults] setObject:followChannelData forKey:@"followChannelInfo"];
                                                [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey:@"userPic"] forKey:@"userPic"];
                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                
                                                [Common registToken];
                                                [Common logUser];
                                                
                                                NSInteger nSchooldId = [[dic objectForKey:@"userSchoolId"] integerValue];
                                                id Aff = [dic objectForKey:@"userAffiliation"];
                                                NSString *str_Affiliation = @"";
                                                if( [Aff isEqual:[NSNull null]] )
                                                {
                                                    str_Affiliation = @"";
                                                }
                                                else
                                                {
                                                    str_Affiliation = Aff;
                                                }
                                                
                                                if( nSchooldId > 0 || str_Affiliation.length > 0 )
                                                {
                                                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"IsLogin"];
                                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                                    
                                                    NSLog(@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]);
                                                    
                                                    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
                                                    
                                                    self.window.rootViewController = self.vc_Main; 
                                                    [UIView transitionWithView:self.window
                                                                      duration:0.3f
                                                                       options:UIViewAnimationOptionTransitionCrossDissolve
                                                                    animations:^{
                                                                        self.window.rootViewController = self.vc_Main;
                                                                    }completion:nil];


                                                    NSArray *myViewControllers = self.vc_Main.viewControllers;
                                                    for (UINavigationController *navViewController in myViewControllers)
                                                    {
                                                        UIViewController *ctrl = navViewController.topViewController;
                                                        if( [ctrl isKindOfClass:[ChatFeedMainViewController class]] )
                                                        {
                                                            ChatFeedMainViewController *vc_Tmp = (ChatFeedMainViewController *)ctrl;
                                                            [vc_Tmp updateSendBirdDelegate];    //홈화면에서 메인화면으로 전환 후 샌드버드 델리게이트 업데이트
                                                        }
                                                    }

//                                                    self.window.rootViewController = self.vc_Main;
                                                }
                                                else
                                                {
                                                    ALERT(nil, @"학교정보를 입력해 주세요", nil, @"확인", nil);
                                                    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
                                                    self.window.rootViewController = self.loginNavi;
                                                }
                                                
                                                NSString *str_UserId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
                                                NSString *str_UserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
                                                
                                                //v2
//                                                [SendBird loginWithUserId:str_UserId andUserName:str_UserName andUserImageUrl:nil andAccessToken:kSendBirdApiToken];
                                                //v3
                                                
                                                [SBDMain connectWithUserId:str_UserId accessToken:kSendBirdApiToken completionHandler:^(SBDUser * _Nullable user, SBDError * _Nullable error) {
                                                    
                                                    if (error == nil)
                                                    {
                                                        NSLog(@"%@", [SBDMain getPendingPushToken]);
                                                        [SBDMain registerDevicePushToken:[SBDMain getPendingPushToken] unique:YES completionHandler:^(SBDPushTokenRegistrationStatus status, SBDError * _Nullable error) {
                                                            
                                                            if (error == nil)
                                                            {
                                                                NSLog(@"%ld", status);
                                                                if (status == SBDPushTokenRegistrationStatusPending)
                                                                {
                                                                    // Registration is pending.
                                                                    // If you get this status, invoke `+ registerDevicePushToken:unique:completionHandler:` with `[SBDMain getPendingPushToken]` after connection.
                                                                }
                                                                else
                                                                {
                                                                    // Registration succeeded.
                                                                    [SBDMain connectWithUserId:str_UserId accessToken:kSendBirdApiToken completionHandler:^(SBDUser * _Nullable user, SBDError * _Nullable error) {

                                                                    }];
                                                                }
                                                            }
                                                            else
                                                            {
                                                                // Registration failed.
                                                            }
                                                        }];
                                                        
                                                        [SBDMain updateCurrentUserInfoWithNickname:str_UserName
                                                                                        profileUrl:[[NSUserDefaults standardUserDefaults] objectForKey:@"userPic"]
                                                                                 completionHandler:^(SBDError * _Nullable error) {
                                                                                     
                                                                                 }];
                                                    }
                                                }];

                                            }
                                            else
                                            {
                                                //로그인 정보가 이상할시 다시 로그인 화면으로 백
                                                [self showLoginView];

                                                ALERT(nil, @"로그인 정보가 잘못되었습니다\n다시 로그인해 주세요", nil, @"확인", nil);
                                            }

                                        }
                                        else
                                        {
                                            //로그인 정보가 이상할시 다시 로그인 화면으로 백
                                            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
                                            self.window.rootViewController = self.loginNavi;
                                        }
                                    }];
}

- (void)showLoginView
{
    self.isChannelMode = NO;
    
    UIStoryboard *storyboard = self.window.rootViewController.storyboard;
    self.loginNavi = [storyboard instantiateViewControllerWithIdentifier:@"LoginNavi"];

    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    self.window.rootViewController = self.loginNavi;
}

- (void)showChannelView:(NSDictionary *)dic
{
    self.isChannelMode = YES;
    
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UINavigationController *navi = [storyBoard instantiateViewControllerWithIdentifier:@"MainChannelNavi"];
    self.vc_Channel = [navi.viewControllers firstObject];
    self.vc_Channel.dic_ChannelInfo = dic;
    [self.vc_Main presentViewController:navi animated:YES completion:^{
        
    }];
    
//    self.window.rootViewController = self.vc_Channel;
//
//    NSMutableArray *arM = [NSMutableArray array];
////    [arM addObject:[NSNumber numberWithUnsignedInteger:UIViewAnimationOptionTransitionFlipFromLeft]];
////    [arM addObject:[NSNumber numberWithUnsignedInteger:UIViewAnimationOptionTransitionCurlUp]];
//    [arM addObject:[NSNumber numberWithUnsignedInteger:UIViewAnimationOptionTransitionCrossDissolve]];
//
//    NSNumber *num = [arM objectAtIndex:arc4random()%[arM count]];
//    NSLog(@"ani : %lu", (unsigned long)[num unsignedIntegerValue]);
//
//    [UIView transitionWithView:self.window
//                      duration:0.3f
//                       options:[num unsignedIntegerValue]
//                    animations:^{
//                        self.window.rootViewController = self.vc_Channel;
//                    }completion:nil];

    
    
    
//    self.vc_Channel.view.frame = CGRectMake(0, 800, self.vc_Channel.view.frame.size.width, self.vc_Channel.view.frame.size.height);
    
    
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//
//        [UIView transitionWithView:self.window
//                          duration:0.3f
//                           options:[num unsignedIntegerValue]
//                        animations:^{
//                            self.window.rootViewController = self.vc_Channel;
////                            self.vc_Channel.view.frame = CGRectMake(0, 0, self.vc_Channel.view.frame.size.width, self.vc_Channel.view.frame.size.height);
//                        }completion:nil];
//
//    });
    
    

}















- (void)applicationDidBecomeActive:(UIApplication *)application
{
    isForground = YES;
    
    // Connect to the GCM server to receive non-APNS notifications
    [[GCMService sharedInstance] connectWithHandler:^(NSError *error) {
        if (error)
        {
            NSLog(@"Could not connect to GCM: %@", error.localizedDescription);
        }
        else
        {
            //푸시타고 들어왔을때
            _connectedToGCM = true;
            NSLog(@"Connected to GCM");
            // [START_EXCLUDE]
            [self subscribeToTopic];
            // [END_EXCLUDE]
            
            if( isBecomForground )
            {
                isBecomForground = NO;
                
//                UINavigationController *navi = (UINavigationController *)self.window.rootViewController;
//                UIViewController *vc = [navi.viewControllers firstObject];
//                [Common showDetailNoti:vc withInfo:dic_PushInfo];
            }
        }
    }];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"EnterForeground"
                                                        object:nil
                                                      userInfo:nil];

}
// [END connect_gcm_service]

// [START disconnect_gcm_service]
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    isForground = NO;
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentQuestionIdx"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [[GCMService sharedInstance] disconnect];
    // [START_EXCLUDE]
    _connectedToGCM = NO;
    // [END_EXCLUDE]
}
// [END disconnect_gcm_service]

// [START receive_apns_token]
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    // [END receive_apns_token]
    // [START get_gcm_reg_token]
    // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
    GGLInstanceIDConfig *instanceIDConfig = [GGLInstanceIDConfig defaultConfig];
    instanceIDConfig.delegate = self;
    // Start the GGLInstanceID shared instance with the that config and request a registration
    // token to enable reception of notifications
    
    NSNumber *num = @NO;
#ifdef DEBUG
    num = @YES;
#endif
    
    [[GGLInstanceID sharedInstance] startWithConfig:instanceIDConfig];
    _registrationOptions = @{kGGLInstanceIDRegisterAPNSOption:deviceToken,
                             kGGLInstanceIDAPNSServerTypeSandboxOption:num};    //센드박스 모드면 YES, 릴리즈면 NO
    [[GGLInstanceID sharedInstance] tokenWithAuthorizedEntity:_gcmSenderID
                                                        scope:kGGLInstanceIDScopeGCM
                                                      options:_registrationOptions
                                                      handler:_registrationHandler];
//     [END get_gcm_reg_token]
    
    
    
    /*****************SB***************/
    [SBDMain registerDevicePushToken:deviceToken unique:YES completionHandler:^(SBDPushTokenRegistrationStatus status, SBDError * _Nullable error) {
        if (error == nil)
        {
            NSLog(@"%ld", status);
            if (status == SBDPushTokenRegistrationStatusPending)
            {
                // Registration is pending.
                // If you get this status, invoke `+ registerDevicePushToken:unique:completionHandler:` with `[SBDMain getPendingPushToken]` after connection.
            }
            else
            {
                // Registration succeeded.
            }
        }
        else
        {
            // Registration failed.
        }
    }];
    /**********************************/
}

// [START receive_apns_token_error]
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    NSLog(@"Registration for remote notification failed with error: %@", error.localizedDescription);
    // [END receive_apns_token_error]
    NSDictionary *userInfo = @{@"error" :error.localizedDescription};
    [[NSNotificationCenter defaultCenter] postNotificationName:_registrationKey
                                                        object:nil
                                                      userInfo:userInfo];
}

// [START ack_message_reception]
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"Notification received: %@", userInfo);
    // This works only if the app started the GCM service
    [[GCMService sharedInstance] appDidReceiveMessage:userInfo];
    // Handle the received message
    // [START_EXCLUDE]
    
    [[NSNotificationCenter defaultCenter] postNotificationName:_messageKey
                                                        object:nil
                                                      userInfo:userInfo];
    // [END_EXCLUDE]
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))handler
{
    //앱 실행중에 푸시가 왔을때 또는 앱 백그라운드에서 푸시를 타고 들어왔을때

    isBecomForground = YES;

    NSLog(@"Notification received: %@", userInfo);
    


    /*
     aps =     {
     alert =         {
     body = "\Uc601\Uc5b4\Ub4e3\Uae30_\Uae30\Ucd9c \Ucc44\Ub110\Uc5d0 \Ud68c\Uc6d0\Uc73c\Ub85c \Ub4f1\Ub85d\Ub418\Uc5c8\Uc2b5\Ub2c8\Ub2e4.";
     title = "\Ud1a0\Ud305 \Ucc44\Ub110 \Ud68c\Uc6d0\Uc778\Uc99d";
     };
     badge = 1;
     "content-available" = 1;
     sound = default;
     };
     "gcm.message_id" = "0:1471480660510865%9f11556c9f11556c";
     "gcm.notification.commandType" = confirmJoin;
     "gcm.notification.nId" = 67;
     */
    
     // This works only if the app started the GCM service
    [[GCMService sharedInstance] appDidReceiveMessage:userInfo];
    // Handle the received message
    // Invoke the completion handler passing the appropriate UIBackgroundFetchResult value
    // [START_EXCLUDE]
    
//    NSLog(@"%@", [userInfo objectForKey:@"commandType"]);
//    NSLog(@"%@", [userInfo objectForKey:@"url"]);

    
    
    
    
    
    
    
    
    
    
    //푸시타고 왔을때 해당 방으로 이동 또는 해당 방으로 이동 후 해당 문제로 이동하기 (아직 다 구현되진 않음)
    NSDictionary *dic_SBD = userInfo[@"sendbird"];
    if( 0 )
    {
        NSDictionary *dic_Channel = dic_SBD[@"channel"];
        NSString *str_ChannelUrl = dic_Channel[@"channel_url"];
        NSString *str_CustomType = dic_SBD[@"custom_type"];
        if( [str_CustomType isEqualToString:@"shareExam"] || [str_CustomType isEqualToString:@"shareQuestion"] )
        {
            //문제 공유일 경우
            NSString *str_Data = dic_SBD[@"data"];
            NSData *data = [str_Data dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic_Data = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            self.vc_Main.selectedIndex = 1;
            
            NSDictionary *dic_Param = @{@"url":str_ChannelUrl, @"data":dic_Data};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MessagePushNoti" object:dic_Param];
        }
    }
    else
    {
        NSString *str_PushType = userInfo[@"gcm.notification.commandType"];
        NSString *str_ChannelUrl = userInfo[@"gcm.notification.channelUrl"];
        NSString *str_Data = userInfo[@"gcm.notification.data"];

        if( [str_PushType isEqualToString:@"newText"] && str_Data == nil )
        {
            //글에 대한 푸시일때
            self.vc_Main.selectedIndex = 1;
            
            NSDictionary *dic_Param = @{@"url":str_ChannelUrl};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MessagePushNoti" object:dic_Param];
        }
        else if( [str_PushType isEqualToString:@"shareExam"] || [str_PushType isEqualToString:@"shareQuestion"] )
        {
            //문제 공유일 경우
            NSString *str_Data = userInfo[@"gcm.notification.data"];
            NSData *data = [str_Data dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dic_Data = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            self.vc_Main.selectedIndex = 1;
            
            NSDictionary *dic_Param = @{@"url":str_ChannelUrl, @"data":dic_Data};
            [[NSNotificationCenter defaultCenter] postNotificationName:@"MessagePushNoti" object:dic_Param];
        }
    }
    
    
    return;
    
    
    
    
    
    
    NSDictionary *dic_Aps = userInfo[@"aps"];
    id alert = [dic_Aps objectForKey:@"alert"];
    if( [alert isKindOfClass:[NSString class]] )
    {
        
    }
    else
    {
        NSDictionary *dic_Json = [dic_Aps objectForKey:@"alert"];
        
        NSLog(@"==============PUSH DATA================");
        NSArray *ar_AllKeys = dic_Json.allKeys;
        for( NSInteger i = 0; i < ar_AllKeys.count; i++ )
        {
            NSString *str_Key = [ar_AllKeys objectAtIndex:i];
            NSString *str_Val =  [dic_Json objectForKey:str_Key];
            
            NSLog(@"key : %@ // val : %@" ,str_Key, str_Val);
            
            
            //        ALERT(str_Key, str_Val, nil, @"ok", nil);
            
        }
        NSLog(@"======================================");
        
        NSString *str_PushType = userInfo[@"gcm.notification.commandType"];
        //    NSString *str_PushType = [dic_Json objectForKey:@"commandType"];
        
        //    ALERT(@"str_PushType", str_PushType, nil, @"확인", nil);
        
        //    ALERT(@"push", @"푸시받음", nil, @"확인", nil);
        
        if( [str_PushType isEqualToString:@"shareExam"] || [str_PushType isEqualToString:@"shareQuestion"] )
        {
            //        NSError *error;
            //        NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
            //        [dicM setObject:@"share" forKey:@"msgType"];
            //        [dicM setObject:[NSString stringWithFormat:@"%@", @"313"] forKey:@"eId"];
            //        [dicM setObject:[NSString stringWithFormat:@"%@", @"840"] forKey:@"questionId"];
            //
            //        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicM
            //                                                           options:NSJSONWritingPrettyPrinted
            //                                                             error:&error];
            //        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            //        [SendBird sendMessage:@"shareExam" withData:jsonString];
            
            
            //        ALERT(@"질문 공유", @"share", nil, @"확인", nil);
            
            //멀티조인을 싱글로 바꿈으로써 서버로부터 샌드버드를 받을 수 있게 되어 주석처리함 2017.05.10
            //        NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
            //        [dicM setObject:userInfo[@"gcm.notification.rId"] forKey:@"rId"];
            //        [dicM setObject:userInfo[@"gcm.notification.eId"] forKey:@"eId"];
            //        [dicM setObject:userInfo[@"gcm.notification.roomQuestionId"] forKey:@"questionId"];
            //        [dicM setObject:@"cmd" forKey:@"itemType"];
            //
            //        [[NSNotificationCenter defaultCenter] postNotificationName:@"ShareExamNoti" object:dicM];
        }
        else if( [str_PushType isEqualToString:@"directQna"] )
        {
            //title":"\uae40\uc601\ubbfc-iOS\ub2d8\uc774 '333333' 1\ubc88 \ubb38\uc81c\uc5d0 \uc9c8\ubb38\uc744 \ud588\uc2b5\ub2c8\ub2e4.",
            //"body":"[\uae40\uc601\ubbfc-iOS] Dddddd",
            //"sound":"default",
            //"commandType":"directQna",
            //"nId":"23432",
            //"badge":19,
            //"eId":"23432",
            //"replyId":"0",
            //"userId":"138",
            //"rId":"338",
            //"roomQuestionId":"26456"
            
            //        ALERT(@"다이렉트 질문", @"direct", nil, @"확인", nil);
            
            NSString *str_Body = [dic_Json objectForKey_YM:@"body"];
            
            //        ALERT(nil, str_Body, nil, @"ok", nil);
            //        ALERT(nil, userInfo[@"gcm.notification.body"], nil, @"ok", nil);
            
            NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
            [dicM setObject:userInfo[@"gcm.notification.rId"] forKey:@"rId"];
            [dicM setObject:userInfo[@"gcm.notification.eId"] forKey:@"eId"];
            [dicM setObject:userInfo[@"gcm.notification.roomQuestionId"] forKey:@"questionId"];
            [dicM setObject:str_Body forKey:@"body"];
            [dicM setObject:str_PushType forKey:@"itemType"];
            
            //        [[NSUserDefaults standardUserDefaults] setObject:dicM forKey:@"ymtest"];
            //        [[NSUserDefaults standardUserDefaults] synchronize];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ShareExamNoti" object:dicM];
        }
        
        if( [str_PushType isEqualToString:@"viewPage"] || [str_PushType isEqualToString:@"newText"] || [str_PushType isEqualToString:@"shareQuestion"] ||
           [str_PushType isEqualToString:@"invite"] || [str_PushType isEqualToString:@"shareExam"] )
        {
            //대시보드 업데이트
            [[NSNotificationCenter defaultCenter] postNotificationName:@"DashBoardUpdate" object:nil];
        }
        
        NSString *str_Title = [dic_Json objectForKey_YM:@"title"];
        NSString *str_Body = [dic_Json objectForKey_YM:@"body"];
        
        if( isForground == NO )
        {
            if( str_Body.length > 0 )
            {
                NSInteger nMyId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue];
                NSInteger nTargetId = [userInfo[@"gcm.notification.userId"] integerValue];
                if( nMyId != nTargetId )
                {
                    ALERT(str_Title, str_Body, nil, @"확인", nil);
                }
            }
        }
    }
    

    

    
//    NSDictionary *dic_Alert = [dic_Aps objectForKey:@"alert"];

//    NSString *str_Title = [dic_Alert objectForKey_YM:@"title"];
//    NSString *str_Body = [dic_Alert objectForKey_YM:@"body"];
    
//    ALERT(str_Title, [dic_Body objectForKey:@"message"], nil, @"ok", nil);
    
    [[NSNotificationCenter defaultCenter] postNotificationName:_messageKey
                                                        object:nil
                                                      userInfo:userInfo];
    handler(UIBackgroundFetchResultNoData);
    // [END_EXCLUDE]
    
    //이건 채팅 대시보드 리플레쉬 하는거!
//    [[NSNotificationCenter defaultCenter] postNotificationName:@"ChatFeedReloadNoti" object:nil];

    
    dic_PushInfo = [NSDictionary dictionaryWithDictionary:userInfo];
    
    [self performSelector:@selector(onRemoveForgroundStatus) withObject:nil afterDelay:1.0f];
    
    
    
    
//    /****************SB****************/
//    NSString *alertMsg = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
//    NSDictionary *payload = [userInfo objectForKey:@"sendbird"];
//    
//    // Your custom way to parse data
//    handler(UIBackgroundFetchResultNewData);
//    /**********************************/

}

// [END ack_message_reception]

// [START on_token_refresh]
- (void)onTokenRefresh
{
    // A rotation of the registration tokens is happening, so the app needs to request a new token.
    NSLog(@"The GCM registration token needs to be changed.");
    [[GGLInstanceID sharedInstance] tokenWithAuthorizedEntity:_gcmSenderID
                                                        scope:kGGLInstanceIDScopeGCM
                                                      options:_registrationOptions
                                                      handler:_registrationHandler];
}
// [END on_token_refresh]

// [START upstream_callbacks]
- (void)willSendDataMessageWithID:(NSString *)messageID error:(NSError *)error
{
    if (error)
    {
        // Failed to send the message.
    }
    else
    {
        // Will send message, you can save the messageID to track the message
    }
}

- (void)didSendDataMessageWithID:(NSString *)messageID
{
    // Did successfully send message identified by messageID
}
// [END upstream_callbacks]

- (void)didDeleteMessagesOnServer {
    // Some messages sent to this device were deleted on the GCM server before reception, likely
    // because the TTL expired. The client should notify the app server of this, so that the app
    // server can resend those messages.
}


- (void)onRemoveForgroundStatus
{
    isBecomForground = NO;
}

@end
