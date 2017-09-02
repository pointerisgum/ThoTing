//
//  Defines.h
//  Kizzl
//
//  Created by Kim Young-Min on 13. 5. 28..
//  Copyright (c) 2013년 Kim Young-Min. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIAlertView+NSCookbook.h"
#import "Util.h"
#import "Toast+UIView.h"
#import "WebAPI.h"
#import "UIViewController+YM.h"
#import "OHActionSheet.h"
#import "UIImageView+AFNetworking.h"
#import "AppDelegate.h"
#import "YmBaseViewController.h"
#import "UserData.h"
#import "UIImageView+AFNetworking.h"
#import <UIKit/UIKit.h>
#import "GMDCircleLoader.h"
#import "DoAlertView.h"
#import "UIColor+expanded.h"
#import "UINavigationBar+Addition.h"
#import "NSDictionary+Extend.h"
#import "Common.h"
#import "TWTSideMenuViewController.h"
#import "UIImageView+WebCache.h"
#import "AppDelegate.h"
#import <SendBirdSDK/SendBirdSDK.h>
#import "SVProgressHUD.h"
#import "MBProgressHUD.h"
#import "ALToastView.h"

#define SYSTEM_VERSION                              ([[UIDevice currentDevice] systemVersion])
#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([SYSTEM_VERSION compare:v options:NSNumericSearch] != NSOrderedAscending)
//#define IS_IOS8_OR_ABOVE                            (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0"))
#define IS_IOS8_OR_ABOVE                            ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)


static NSString const *kAppStoreId = @"973499825";  //스킨푸드 앱스토어 아이디

static NSInteger const kTitleArrowTag = 88;
static NSInteger const kTitleButtonTag = 89;

//#define degreesToRadians(degrees) ((degrees)/180.0 * M_PI)
#define degreesToRadian(x) (M_PI * (x) / 180.0)

//구글 아날리틱스 아이디
static NSString *const kTrackingId = @"UA-61448098-2";
static NSString *const kAllowTracking = @"allowTracking";
static NSString * const kChatPlaceHolder = @"";
static NSString * const kStatusBarTappedNotification = @"statusBarTappedNotification";

static NSInteger const kNaviTitleTag = 5613;

static NSInteger const kInfinityTimeInterval = 5.0f;

static NSInteger kTabBarBadgeIdx = 1;
static NSInteger kTabBarMyIdx = 3;


#define HanLog(string, ...) NSLog(@“%@”,[NSString stringWithCString:[[string description] cStringUsingEncoding:NSASCIIStringEncoding] encoding:NSNonLossyASCIIStringEncoding])


#define NSEUCKREncoding (-2147481280)

//개발
#define kBaseUrl                @"http://dev2.thoting.com"        //개발섭
#define kWebBaseUrl             @"http://ui2.thoting.com"
#define kSendBirdAppId          @"42D36EAA-F2E3-4D3E-B250-D11A91BA18DA"
#define kSendBirdApiToken       @"3b10e442ee85ea4c6cef0b8f123630e9f659bf9f"

//실섭
//#define kBaseUrl                @"http://dev.thoting.com"        //실섭
//#define kWebBaseUrl             @"http://ui.thoting.com"
//#define kSendBirdAppId          @"E69509C1-7B53-4C57-BF34-63E3EB883873"
//#define kSendBirdApiToken       @"3b22f51ea52fff8b8d2103912cd83061be5e4f53"




#define kFeedBoard      [UIStoryboard storyboardWithName:@"Feed" bundle:nil]
#define kMainBoard      [UIStoryboard storyboardWithName:@"Main" bundle:nil]
#define kEtcBoard       [UIStoryboard storyboardWithName:@"Etc" bundle:nil]
#define kChannelBoard   [UIStoryboard storyboardWithName:@"Channel" bundle:nil]
#define kQuestionBoard   [UIStoryboard storyboardWithName:@"Question" bundle:nil]


#define kLocal                  @"http://112.216.0.179:8284"    //Local

//AppStoreUrl
#define kAppStoreURL            @"https://itunes.apple.com/kr/app/seuwiteo-switter/id973499825?mt=8"
#define kMarketURL              @""

#define kMainColor  [UIColor colorWithHexString:@"4285f4"]
#define kMainRedColor  [UIColor colorWithHexString:@"FF5959"]
#define kMainOrangeColor  [UIColor colorWithHexString:@"#F99900"]
#define kMainYellowColor [UIColor colorWithHexString:@"#EDB900"]

#define kRegistrationKey @"onRegistrationCompleted"
#define kMessageKey @"onMessageReceived"

#define kChangeTabBar @"kChangeTabBar"
#define kShowMyPageQuestion @"kShowMyPageQuestion"


//동영상 저장 저장경로
#define kFileSavePath              [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Log"]

//레티나 체크
#define IS_RETINA               ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] && ([UIScreen mainScreen].scale == 2.0))

//iOS7 체크
#define IS_IOS7_LATER           ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7)

//3.5인치 체크
#define IS_3_5Inch              ([UIScreen mainScreen].applicationFrame.size.height < 548.0f)

//4인치 체크
#define IS_4Inch                ([UIScreen mainScreen].applicationFrame.size.height == 568.0f)

//GCD
#define AsyncBlock(block)       dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
#define SyncBlock(block)        dispatch_sync(dispatch_get_main_queue(), block)


#define ALERT(TITLE, MSG, DELEGATE, BTN_TITLE1, BTN_TITLE2){UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:TITLE message:MSG delegate:DELEGATE cancelButtonTitle:nil otherButtonTitles:BTN_TITLE1, BTN_TITLE2, nil];[alertView show];}

#define ALERT_ONE(MSG){UIAlertView *alertView = [[UIAlertView alloc]initWithTitle:nil message:MSG delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];[alertView show];}

#define CREATE_ALERT(TITLE, MSG, BTN_TITLE1, BTN_TITLE2){[[UIAlertView alloc]initWithTitle:TITLE message:MSG delegate:nil cancelButtonTitle:nil otherButtonTitles:BTN_TITLE1, BTN_TITLE2, nil]}

#define BundleImage(IMAGE_NAME) [UIImage imageWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:IMAGE_NAME]]


#define SuppressPerformSelectorLeakWarning(Stuff) \
do { \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
Stuff; \
_Pragma("clang diagnostic pop") \
} while (0)


//#ifdef DEBUG
////#define NSLog(fmt, ...) NSLog((@"%s[Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
//#define NSLog(fmt, ...) NSLog((fmt), ##__VA_ARGS__)
//#else
//#define NSLog(...)
//#endif


#ifndef popover_PopoverViewCompatibility_h
#define popover_PopoverViewCompatibility_h

#ifdef __IPHONE_6_0

#define UITextAlignmentCenter       NSTextAlignmentCenter
#define UITextAlignmentLeft         NSTextAlignmentLeft
#define UITextAlignmentRight        NSTextAlignmentRight
#define UILineBreakModeTailTruncation   NSLineBreakByTruncatingTail
#define UILineBreakModeMiddleTruncation NSLineBreakByTruncatingMiddle
#define UILineBreakModeWordWrap         NSLineBreakByWordWrapping

#endif

#endif

