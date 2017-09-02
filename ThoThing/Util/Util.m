//
//  Util.m
//  FoodView
//
//  Created by Kim Young-Min on 13. 3. 13..
//  Copyright (c) 2013년 bencrow. All rights reserved.
//

#import "Util.h"
#import <QuartzCore/QuartzCore.h>
#include <sys/xattr.h>
#import <SystemConfiguration/SystemConfiguration.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <netdb.h>
//#import "UIImageView+AFNetworking.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "Defines.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#import "YM_KeychainItemWrapper.h"
#import <sys/utsname.h>
#import <CommonCrypto/CommonDigest.h>

static Util *shared = nil;
static UIView *v_Indi = nil;

@implementation Util

+ (void)initialize
{
    NSAssert(self == [Util class], @"Singleton is not designed to be subclassed.");
    shared = [Util new];
    
    //로딩용 인디케이터 뷰 만들기
    v_Indi = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    [v_Indi setBackgroundColor:[UIColor clearColor]];
    v_Indi.userInteractionEnabled = YES;
    UIImageView *iv_BG = [[UIImageView alloc]initWithFrame:v_Indi.frame];
    [iv_BG setBackgroundColor:[UIColor blackColor]];
    iv_BG.alpha = 0.6f;
    [v_Indi addSubview:iv_BG];
    
    UIImageView *iv = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 60, 50)];
    iv.center = v_Indi.center;
    [iv setBackgroundColor:[UIColor blackColor]];
    [iv setAlpha:0.7f];
    [Util imageRounding:iv];
    [v_Indi addSubview:iv];
    
    UIActivityIndicatorView *indi = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    indi.center = CGPointMake(v_Indi.frame.size.width/2, v_Indi.frame.size.height/2);
    [indi setHidesWhenStopped:YES];
    [v_Indi addSubview:indi];
}

+ (Util *)sharedData
{
    return shared;
}

- (void)addIndicator
{
    [self performSelectorInBackground:@selector(onAddIndicator) withObject:nil];
}

- (void)onAddIndicator
{
    [v_Indi removeFromSuperview];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    v_Indi.alpha = NO;
    [window addSubview:v_Indi];
    
    for( id subView in [v_Indi subviews] )
    {
        if( [subView isKindOfClass:[UIActivityIndicatorView class]] )
        {
            UIActivityIndicatorView *indi = (UIActivityIndicatorView *)subView;
            [indi startAnimating];
        }
    }
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         v_Indi.alpha = YES;
                     }];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)removeIndicator
{
    if( !v_Indi ) return;
    
    [UIView animateWithDuration:0.3f
                     animations:^{
                         v_Indi.alpha = NO;
                     } completion:^(BOOL finished) {
                         [v_Indi removeFromSuperview];
                     }];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

+ (BOOL)isNetworkCheckAlert
{
    NSString *str_Status = [Util getNetworkSatatus];
    if( str_Status == nil )
    {
//        ALERT(nil, @"네트워크에 접속할 수 없습니다.\n3G 및 Wifi 연결상태를\n확인해주세요.", nil, @"확인", nil);
        return NO;
    }
    
    return YES;
}

+ (NSString *)getNetworkSatatus
{
    NSString *str_ReturnSatatus = nil;
    
    // Create zero addy
	struct sockaddr_in zeroAddress;
	bzero(&zeroAddress, sizeof(zeroAddress));
	zeroAddress.sin_len = sizeof(zeroAddress);
	zeroAddress.sin_family = AF_INET;
	
	// Recover reachability flags
	SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
	SCNetworkReachabilityFlags flags;
	
	BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    
	if (!didRetrieveFlags)
	{
		printf("Error. Could not recover network reachability flags\n");
		return str_ReturnSatatus;
	}
	
	BOOL isReachable = flags & kSCNetworkFlagsReachable;
	BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    
	BOOL isNetworkStatus = (isReachable && !needsConnection) ? YES : NO;
    
	if(!isNetworkStatus)    return str_ReturnSatatus;
	
	zeroAddress.sin_addr.s_addr = htonl(IN_LINKLOCALNETNUM);
	
	SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
	
	CFRelease(defaultRouteReachability);
    
	if( flags & kSCNetworkReachabilityFlagsIsWWAN )
		str_ReturnSatatus = @"3G";
	else
		str_ReturnSatatus = @"Wifi";
    
    return str_ReturnSatatus;
}

+ (void)imageRounding:(UIView *)v
{
    v.layer.cornerRadius = 5.0;
    v.layer.masksToBounds = YES;
}

+ (void)imageRoundingAndBorder:(UIView *)v
{
    v.layer.cornerRadius = 5.0;
    v.layer.masksToBounds = YES;
    v.layer.borderColor = [UIColor colorWithRed:208.0f/255.0f green:180.0f/255.0f blue:216.0f/255.0f alpha:1].CGColor;//[UIColor colorWithRed:211.0f/255.0f green:211.0f/255.0f blue:211.0f/255.0f alpha:1].CGColor;
    v.layer.borderWidth = 1.0;
}

+ (void)spinLayer:(CALayer *)inLayer duration:(CFTimeInterval)inDuration direction:(int)direction
{
    CABasicAnimation* rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.repeatCount = 1;
    rotationAnimation.toValue = [NSNumber numberWithFloat: M_PI * 1 * direction];
    rotationAnimation.duration = inDuration;
    rotationAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    
    [inLayer addAnimation:rotationAnimation forKey:@"rotationAnimation"];
}

+ (void)rotationImage:(UIView *)view withRadian:(int)radian
{
    [UIView animateWithDuration:0.3f
                     animations:^{
                         view.transform = CGAffineTransformMakeRotation(degreesToRadian(radian));
                     }];
}

+ (NSString*)getOnlyNumber:(NSString *)aString
{
	NSMutableString *strippedString = [NSMutableString stringWithCapacity:[aString length]];
	NSScanner *scanner = [NSScanner scannerWithString:aString];
	NSCharacterSet *numbers = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
	
	while ([scanner isAtEnd] == NO)
    {
		NSString *buffer;
		if ([scanner scanCharactersFromSet:numbers intoString:&buffer]) {
			[strippedString appendString:buffer];
		} else {
			[scanner setScanLocation:([scanner scanLocation] + 1)];
		}
	}
	
	return [NSString stringWithString:strippedString];
}

+ (BOOL)createFolderWithCloudSync:(BOOL)sync
{
    //패스 검사후 없으면 파일 만들기
    if( ![[NSFileManager defaultManager] fileExistsAtPath:kFileSavePath] )
    {
        BOOL isSuccess = [[NSFileManager defaultManager] createDirectoryAtPath:kFileSavePath withIntermediateDirectories:NO attributes:nil error:nil];
        if( !isSuccess )
        {
            NSLog(@"Folder Make Fail");
            return NO;
        }
        
        if( !sync )
        {
            [self addSkipBackupAttributeToiTemAtURL:[NSURL fileURLWithPath:kFileSavePath]];
        }
        
        NSLog(@"Make Folder Success");
        return YES;
    }
    
    NSLog(@"Already Has Folder");
    return NO;
}

+ (BOOL)createFile:(NSString *)filePath
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
//    if( [fileManager fileExistsAtPath:filePath] )
//    {
//        [fileManager removeItemAtPath:filePath error:nil];
//    }

    BOOL isSuccess = [fileManager createFileAtPath:filePath contents:[NSData data] attributes:nil];
    if( !isSuccess )
    {
        NSLog(@"File Make Fail");
        return NO;
    }
    
    NSLog(@"Make File Success");
    return YES;
}

+ (BOOL)isUsableEmail:(NSString *)str
{
    //1차로 한글이 있는지 검색
    const char *tmp = [str cStringUsingEncoding:NSUTF8StringEncoding];

    if (str.length != strlen(tmp))
    {
        return NO;
    }

    //2차로 이메일 형식인지 검색
    NSString *check = @"([0-9a-zA-Z_-]+)@([0-9a-zA-Z_-]+)(\\.[0-9a-zA-Z_-]+){1,2}";
    NSRange match = [str rangeOfString:check options:NSRegularExpressionSearch];
    if (NSNotFound == match.location)
    {
        return NO;
    }

    return YES;
}

//+ (BOOL)isUsableEmail:(NSString *)str
//{
//    NSString *ptn = @"^[a-zA-Z0-9]+@[a-zA-Z0-9]+$  or  ^[_0-9a-zA-Z-]+@[0-9a-zA-Z-]+(.[_0-9a-zA-Z-]+)*$";
//    //    NSString *ptn = @"^(?:\\w+\\.?)*\\w+@(?:\\w+\\.)+\\w+$";
//
//    NSRange range = [str rangeOfString:ptn options:NSRegularExpressionSearch];
//    
//    if( (range.length != NSNotFound) && (range.length > 5) )
//    {
//        return YES;
//    }
//    
//    return NO;
//}

+ (BOOL)addSkipBackupAttributeToiTemAtURL:(NSURL *)URL
{
    const char *filePath = [[URL path] fileSystemRepresentation];
    const char *attrName = "com.apple.MobileBackup";
    
    u_int8_t attrValue = 1;
    
    int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
    
    return result == 0;
}

+ (UIImage *)thumbnailFromVideoAtURL:(NSString *)path
{
    UIImage *theImage = nil;
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:[NSURL fileURLWithPath:path] options:nil];
    AVAssetImageGenerator *generator = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    generator.appliesPreferredTrackTransform = YES;
    NSError *err = NULL;
    CMTime time = CMTimeMake(1, 60);
    CGImageRef imgRef = [generator copyCGImageAtTime:time actualTime:NULL error:&err];
    
    theImage = [[UIImage alloc] initWithCGImage:imgRef];
    
    CGImageRelease(imgRef);
    
    return theImage;
}

+ (BOOL)isUsablePhoneNumber:(NSString *)str
{
    str = [str stringByReplacingOccurrencesOfString:@"-" withString:@""];
    
    NSString *ptn = @"(010|011|016|017|018|019)([0-9]{3,4})([0-9]{4})";
    NSRange range = [str rangeOfString:ptn options:NSRegularExpressionSearch];
    
    if( ![str hasPrefix:@"0"] )
    {
        return NO;
    }
    
    if( (range.length != NSNotFound) && (range.length > 8) )
    {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isOnlyNumber:(NSString *)str
{
    NSString *ptn = @"^[0-9]*$";
    NSRange range = [str rangeOfString:ptn options:NSRegularExpressionSearch];

    if( range.length != NSNotFound && (range.length > 0) )
    {
        return YES;
    }
    
    return NO;
}

+ (BOOL)isOnlyEnglish:(NSString *)str
{
    NSString *ptn = @"^[A-Za-z]*$";
    NSRange range = [str rangeOfString:ptn options:NSRegularExpressionSearch];
    
    if( range.length != NSNotFound && (range.length > 0) )
    {
        return YES;
    }
    
    return NO;
}

+ (void)makeCircleImage:(UIView *)iv withBorderWidth:(float)border
{
    iv.layer.cornerRadius = iv.frame.size.width/2;
    iv.layer.masksToBounds = YES;
    iv.layer.borderColor = [UIColor lightGrayColor].CGColor;
    iv.layer.borderWidth = border;
}

+ (void)addTextShodow:(UILabel *)text
{
    text.textColor = [UIColor whiteColor];
    text.layer.shadowOffset = CGSizeMake(0.5f, 0.5f);
    text.layer.shadowOpacity = 1.0f;
    text.layer.shadowRadius = 1.0f;
}

+ (UIView *)createNavigationTitleView:(UIView *)view withTitle:(NSString *)title
{
    UILabel *titleView = (UILabel *)view;
    if (!titleView)
    {
        titleView = [[UILabel alloc] initWithFrame:CGRectZero];
        titleView.backgroundColor = [UIColor clearColor];
        titleView.font = [UIFont boldSystemFontOfSize:20.0];
        titleView.textColor = [UIColor whiteColor];
        titleView.layer.shadowOffset = CGSizeMake(2.0f, 2.0f);
        titleView.layer.shadowOpacity = 0.1f;
        titleView.layer.shadowRadius = 1.0f;
        
        titleView.textColor = [UIColor colorWithRed:115.0f/255.0f green:115.0f/255.0f blue:115.0f/255.0f alpha:1];
        titleView.text = title;
        [titleView sizeToFit];
    }
    
    return titleView;
}

+ (NSString *)makeThumbNailUrlString:(NSString *)aUrlString withSize:(NSString *)aSize;
{
    NSMutableString *strM_ImageUrl = [NSMutableString string];
    NSArray *ar_Sep = [aUrlString componentsSeparatedByString:@"_"];
    for( int i = 0; i < [ar_Sep count] - 1; i++ )
    {
        [strM_ImageUrl appendString:[ar_Sep objectAtIndex:i]];
        [strM_ImageUrl appendString:@"_"];
    }
    
    NSString *str_LastObj = [ar_Sep lastObject];
    NSString *str_Extension = [str_LastObj pathExtension];
    
    NSArray *ar_LastSep = [str_LastObj componentsSeparatedByString:@"."];
    if( [ar_LastSep count] > 1 )
    {
        NSString *str_BeforeSize = [ar_LastSep objectAtIndex:0];
        if( [str_BeforeSize longLongValue] < [aSize longLongValue] || [str_BeforeSize longLongValue] > 1280 )
        {
            //요청 사이즈보다 원본이 작거나 1280보다 클 경우
            return aUrlString;
        }
        else
        {
            [strM_ImageUrl appendString:[NSString stringWithFormat:@"%@.%@", aSize, str_Extension]];
            return strM_ImageUrl;
        }
    }
    else
    {
        return aUrlString;
    }
    
    return nil;
}

+ (BOOL)isStringCheck:(NSString *)aString
{
    NSString *ptn = @"^[A-Za-z0-9]*$";
    NSRange range = [aString rangeOfString:ptn options:NSRegularExpressionSearch];
    if( range.length != NSNotFound && (range.length > 0) )
    {
        return YES;
    }
    
    return NO;
}

//빠바 비번체크(문자 숫자 조합 6자리 이상) //영문과 숫자의 조합
+ (BOOL)isPariPwCheck:(NSString *)aString
{
    //한글은 영문과 특수문자만 입력되게 키보드 설정이 되어 있음. keyboardType = ASKII
    
    if( [Util isOnlyNumber:aString] )
    {
        //숫자만 있다면
        return NO;
    }

    if( [Util isStringCheck:aString] == NO )
    {
        //영문과 숫자외에 다른 케릭터가 들어가 있다면
        return NO;
    }
    
    if( [Util isOnlyEnglish:aString] )
    {
        //영문만 있다면
        return NO;
    }
    
    return YES;
}


+ (void)setRound:(const UIView *)view withCorners:(UIRectCorner)corners
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:corners cornerRadii:CGSizeMake(5.0f, 5.0f)];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}

+ (void)setRound:(const UIView *)view withCornerSize:(CGSize)size
{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:view.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:size];
    CAShapeLayer *maskLayer = [CAShapeLayer layer];
    maskLayer.frame = view.bounds;
    maskLayer.path = maskPath.CGPath;
    view.layer.mask = maskLayer;
}


//특수문자 검사 (특수문자가 있으면 YES, 없으면 NO)
+ (BOOL)isSpecialCharacter:(NSString *)str
{
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *ptn = @"^[ㄱ-힣0-9a-zA-Z]*$";
    NSRange range = [str rangeOfString:ptn options:NSRegularExpressionSearch];
    
    if( range.length != NSNotFound && (range.length > 0) )
    {
        return NO;
    }
    
    return YES;
}

+ (void)setMainNaviBar:(UINavigationBar *)naviBar
{
    [[UINavigationBar appearance] setBackgroundImage:BundleImage(@"navi128.png") forBarMetrics:UIBarMetricsDefault];
    
    [naviBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIColor whiteColor], NSForegroundColorAttributeName,
                                     [UIFont fontWithName:@"Helvetica-bold" size:18], NSFontAttributeName,
                                     nil]];
}

+ (void)setLoginNaviBar:(UINavigationBar *)naviBar
{
    [[UINavigationBar appearance] setBackgroundImage:BundleImage(@"navi_white128.png") forBarMetrics:UIBarMetricsDefault];
//    [[UINavigationBar appearance] setBackgroundColor:[UIColor whiteColor]];
    
    [naviBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIColor blackColor], NSForegroundColorAttributeName,
                                     [UIFont fontWithName:@"Helvetica-bold" size:18], NSFontAttributeName,
                                     nil]];
}

+ (void)setSearchNaviBar:(UINavigationBar *)naviBar
{
//    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    
    [[UINavigationBar appearance] setBackgroundImage:BundleImage(@"searchNavi.png") forBarMetrics:UIBarMetricsDefault];

    [naviBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                     [UIColor whiteColor], NSForegroundColorAttributeName,
                                     [UIFont fontWithName:@"Helvetica-bold" size:18], NSFontAttributeName,
                                     nil]];
}


+ (CGSize)getTextSize:(UILabel *)lb
{
    CGRect textRect = CGRectZero;
    if( IS_IOS7_LATER )
    {
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    lb.font, NSFontAttributeName, nil];

        textRect = [lb.text boundingRectWithSize:CGSizeMake(lb.frame.size.width, FLT_MAX)
                                         options:NSLineBreakByClipping | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attributes
                                         context:nil];
    }
    else
    {
//        textRect.size = [lb.text sizeWithFont:lb.font];

    }

    return textRect.size;
}

//채팅용
+ (CGSize)getTextSize2:(UILabel *)lb
{
    CGRect textRect = CGRectZero;
    if( IS_IOS7_LATER )
    {
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    lb.font, NSFontAttributeName, nil];
        
//        NSLog(@"lb.frame.size.width : %f", lb.frame.size.width);
        
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        textRect = [lb.text boundingRectWithSize:CGSizeMake(window.frame.size.width - 100, FLT_MAX)
                                         options:NSLineBreakByClipping | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attributes
                                         context:nil];
    }
    else
    {
        //        textRect.size = [lb.text sizeWithFont:lb.font];
        
    }
    
    return textRect.size;
}

//Log 파일로 저장하기
+ (void)writeFile:(NSString *)stringToSave
{
    NSString *str_Path = [NSString stringWithFormat:@"%@/log.txt", kFileSavePath];
    [Util createFolderWithCloudSync:NO];
    [Util createFile:[NSString stringWithFormat:@"%@/log.txt", kFileSavePath]];
    [stringToSave writeToFile:str_Path atomically:YES encoding:NSUTF8StringEncoding error:nil];
}


+ (void)setSvContentsSize:(UIScrollView *)sv withTargetObj:(UIView *)lastObj
{
    sv.contentSize = CGSizeMake(sv.contentSize.width, lastObj.frame.origin.y + lastObj.frame.size.height);
}


//가로, 세로 맞춰 이미지 리사이징하기
+ (UIImage*)imageWithImage:(UIImage *)image convertToWidth:(float)width covertToHeight:(float)height
{
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * newimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimage;
}

//세로 맞춰 이미지 리사이징하기
+ (UIImage*)imageWithImage:(UIImage *)image convertToHeight:(float)height
{
    float ratio = image.size.height / height;
    float width = image.size.width / ratio;
    CGSize size = CGSizeMake(width, height);
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * newimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimage;
}

//가로 맞춰 이미지 리사이징하기
+ (UIImage*)imageWithImage:(UIImage *)image convertToWidth:(float)width
{
    float ratio = image.size.width / width;
    float height = image.size.height / ratio;
    CGSize size = CGSizeMake(width, height);
//    UIGraphicsBeginImageContext(size);
    UIGraphicsBeginImageContextWithOptions(size, NO, 0);

    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage * newimage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimage;
}

+ (CGFloat)getTextViewHeight:(UITextView *)textView
{
    if (floor(NSFoundationVersionNumber) > NSFoundationVersionNumber_iOS_6_1)
    {
        // This is the code for iOS 7. contentSize no longer returns the correct value, so
        // we have to calculate it.
        //
        // This is partly borrowed from HPGrowingTextView, but I've replaced the
        // magic fudge factors with the calculated values (having worked out where
        // they came from)

        CGRect frame = textView.bounds;

        // Take account of the padding added around the text.

        UIEdgeInsets textContainerInsets = textView.textContainerInset;
        UIEdgeInsets contentInsets = textView.contentInset;

        CGFloat leftRightPadding = textContainerInsets.left + textContainerInsets.right + textView.textContainer.lineFragmentPadding * 2 + contentInsets.left + contentInsets.right;
        CGFloat topBottomPadding = textContainerInsets.top + textContainerInsets.bottom + contentInsets.top + contentInsets.bottom;

        frame.size.width -= leftRightPadding;
        frame.size.height -= topBottomPadding;

        NSString *textToMeasure = textView.text;
        if ([textToMeasure hasSuffix:@"\n"])
        {
            textToMeasure = [NSString stringWithFormat:@"%@-", textView.text];
        }

        // NSString class method: boundingRectWithSize:options:attributes:context is
        // available only on ios7.0 sdk.

        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        [paragraphStyle setLineBreakMode:NSLineBreakByWordWrapping];

        NSDictionary *attributes = @{ NSFontAttributeName: textView.font, NSParagraphStyleAttributeName : paragraphStyle };

        CGRect size = [textToMeasure boundingRectWithSize:CGSizeMake(CGRectGetWidth(frame), MAXFLOAT)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attributes
                                                  context:nil];

        CGFloat measuredHeight = ceilf(CGRectGetHeight(size) + topBottomPadding);
        return measuredHeight;
    }
    else
    {
        return textView.contentSize.height;
    }
}


//버전 비교 (앞이 현재버전, 뒤가 최신버전 리턴값이 NSOrderedAscending면 업데이트 필요)
+ (NSComparisonResult)compareVersion:(NSString*)versionOne toVersion:(NSString*)versionTwo
{
    NSArray* versionOneComp = [versionOne componentsSeparatedByString:@"."];
    NSArray* versionTwoComp = [versionTwo componentsSeparatedByString:@"."];
    
    NSInteger pos = 0;
    
    while ([versionOneComp count] > pos || [versionTwoComp count] > pos)
    {
        NSInteger v1 = [versionOneComp count] > pos ? [[versionOneComp objectAtIndex:pos] integerValue] : 0;
        NSInteger v2 = [versionTwoComp count] > pos ? [[versionTwoComp objectAtIndex:pos] integerValue] : 0;
        if (v1 < v2)
        {
            return NSOrderedAscending;
        }
        else if (v1 > v2)
        {
            return NSOrderedDescending;
        }
        pos++;
    }
    
    return NSOrderedSame;
}


//+ (CGSize)getTextSize:(NSString *)str withAttr:(NSAttributedString *)attbStr
//{
////    NSAttributedString *at = lb.attributedText;
//    
//}


//NSString *ptn = @"^[0-9]*$";
//
//NSRange range = [str rangeOfString:ptn options:NSRegularExpressionSearch];
//NSRange range1 = [str1 rangeOfString:ptn options:NSRegularExpressionSearch];
//
//NSLog(@"%d, %d", range.length, range1.length); // 4, 0을 출력
//
//
//
//
//2.영문자[특수문자(-,_,&)포함]인지 체크
//NSString *str = @"1234";
//NSString *str1 = @"asdfb-sdf";
//NSString *ptn = @"^[a-zA-Z\-\_\&]*$";
//[출처] ios nsstring 정규식|작성자 Sainteyes


+ (UIView *)createKeyboardAccView
{
    UIBarButtonItem *nilButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIButton *btn_Done = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_Done.frame = CGRectMake(0, 0, 44, 44);
    [btn_Done setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_Done.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
    [btn_Done setTitle:@"완료" forState:UIControlStateNormal];
    [btn_Done addTarget:self action:@selector(onKeyboardDown:) forControlEvents:UIControlEventTouchUpInside];
    
    UIToolbar* keyboardDoneButtonView = [[UIToolbar alloc] init];
    [keyboardDoneButtonView sizeToFit];
    [keyboardDoneButtonView setItems:[NSArray arrayWithObjects:nilButton, [[UIBarButtonItem alloc] initWithCustomView:btn_Done], nil]];
    
    return keyboardDoneButtonView;
}


+ (NSString *)getIPAddress
{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                    
                }
                
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    
#if TARGET_IPHONE_SIMULATOR
    address = @"121.136.77.167";
#endif

    return address;
    
}

+ (NSString *)stringByStrippingHTML:(NSString*)str
{
    NSRange r;
    while ((r = [str rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
    {
        str = [str stringByReplacingCharactersInRange:r withString:@""];
    }
    return str;
}

+ (void)printDictionaryLog:(NSDictionary *)dic
{
    NSArray *ar_AllKeys = dic.allKeys;
    for( NSInteger i = 0; i < ar_AllKeys.count; i++ )
    {
        NSString *str_Key = ar_AllKeys[i];
        NSLog(@"key : %@ // value : %@", str_Key, [dic objectForKey:str_Key]);
    }
}

+ (NSString *)getUUID
{
    NSString *uuid = [YM_KeychainItemWrapper loadValueForKey:@"DeviceId"];

    if( uuid == nil || uuid.length == 0)
    {
        CFUUIDRef uuidRef = CFUUIDCreate(NULL);
        CFStringRef uuidStringRef = CFUUIDCreateString(NULL, uuidRef);
        CFRelease(uuidRef);
        uuid = [NSString stringWithString:(__bridge NSString *) uuidStringRef];
        CFRelease(uuidStringRef);

        [YM_KeychainItemWrapper saveValue:uuid forKey:@"DeviceId"];
    }

    return uuid;
}


+ (CGFloat)getTextWith:(UILabel *)lb
{
    CGRect textRect = CGRectZero;
    if( IS_IOS7_LATER )
    {
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                    lb.font, NSFontAttributeName, nil];
        
        textRect = [lb.text boundingRectWithSize:CGSizeMake(FLT_MAX, lb.frame.size.height)
                                         options:NSLineBreakByClipping | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                      attributes:attributes
                                         context:nil];
    }
    else
    {
        textRect.size = [lb.text sizeWithFont:lb.font];
        
    }
    
    return textRect.size.width;
}

+ (NSString *)getDeviceName
{
    struct utsname systemInfo;
    uname(&systemInfo);
    
    NSString *str_Model = [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding];
    
    if( [str_Model isEqualToString:@"iPhone3,1"] || [str_Model isEqualToString:@"iPhone3,3"] )
    {
        str_Model = @"iPhone4";
    }
    else if( [str_Model isEqualToString:@"iPhone4,1"] )
    {
        str_Model = @"iPhone4s";
    }
    else if( [str_Model isEqualToString:@"iPhone5,1"] || [str_Model isEqualToString:@"iPhone5,2"] )
    {
        str_Model = @"iPhone5";
    }
    else if( [str_Model isEqualToString:@"iPhone5,3"] || [str_Model isEqualToString:@"iPhone5,4"] )
    {
        str_Model = @"iPhone5c";
    }
    else if( [str_Model isEqualToString:@"iPhone6,1"] || [str_Model isEqualToString:@"iPhone6,2"] )
    {
        str_Model = @"iPhone5s";
    }
    else if( [str_Model isEqualToString:@"iPhone7,1"] )
    {
        str_Model = @"iPhone6Plus";
    }
    else if( [str_Model isEqualToString:@"iPhone7,2"] )
    {
        str_Model = @"iPhone6";
    }
    else if( [str_Model isEqualToString:@"iPhone8,1"] )
    {
        str_Model = @"iPhone6S";
    }
    else if( [str_Model isEqualToString:@"iPhone8,2"] )
    {
        str_Model = @"iPhone6SPlus";
    }
    else if( [str_Model isEqualToString:@"iPhone8,4"] )
    {
        str_Model = @"iPhoneSE";
    }
    
    return str_Model;
}

+ (NSURL *)createImageUrl:(NSString *)aHeader withFooter:(NSString *)aFooter
{
    if( [aFooter isKindOfClass:[NSString class]] == NO )
    {
        return [NSURL URLWithString:@""];
    }
    
    if( [aFooter hasPrefix:@"http"] )
    {
        return [NSURL URLWithString:aFooter];
    }
    
    if( aHeader == nil || aHeader.length <= 0 )
    {
        aHeader = [[NSUserDefaults standardUserDefaults] objectForKey:@"img_prefix"];
    }
    
    NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", aHeader, aFooter];
    NSArray *ar_Sep = [str_ImageUrl componentsSeparatedByString:@"://"];
    if( ar_Sep.count > 1 )
    {
        NSString *str_Footer = ar_Sep[1];
        str_Footer = [str_Footer stringByReplacingOccurrencesOfString:@"//" withString:@"/"];
        str_ImageUrl = [NSString stringWithFormat:@"%@://%@", ar_Sep[0], str_Footer];
    }
    
    NSLog(@"str_ImageUrl : %@", str_ImageUrl);
    return [NSURL URLWithString:str_ImageUrl];
}

+ (NSString *)transIntToString:(id)obj
{
    if( [obj isEqual:[NSNull null]] )
    {
        return @"";
    }
    NSInteger nObj = [obj integerValue];
    return [NSString stringWithFormat:@"%ld", nObj];
}

+ (UIImage *)makeNinePatchImage:(UIImage *)image
{
    //Clear the black 9patch regions
    CGRect imageRect = CGRectMake(0.0, 0.0, image.size.width, image.size.height);
    UIGraphicsBeginImageContextWithOptions(image.size, NO, [UIScreen mainScreen].scale);
    [image drawInRect:imageRect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextClearRect(context, CGRectMake(0, 0, image.size.width, 1));
    CGContextClearRect(context, CGRectMake(0, 0, 1, image.size.height));
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIEdgeInsets insets;
    
    //hard coded for now, could easily read the black regions if necessary
    insets.left = insets.right = image.size.width / 2 - 1;
    insets.top = insets.bottom = image.size.height / 2 - 1;
    
    UIImage *nineImage = [image resizableImageWithCapInsets:insets
                                               resizingMode:UIImageResizingModeStretch];
    
    return nineImage;
    
}

//+ (void)showToast:(NSString *)aMsg
//{
//    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
//    [window makeToast:aMsg withPosition:kPositionCenter];
//}

+ (NSString *)getDday:(NSString *)aDay
{
    aDay = [aDay stringByReplacingOccurrencesOfString:@"-" withString:@""];
    aDay = [aDay stringByReplacingOccurrencesOfString:@" " withString:@""];
    aDay = [aDay stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    NSString *str_Year = [aDay substringWithRange:NSMakeRange(0, 4)];
    NSString *str_Month = [aDay substringWithRange:NSMakeRange(4, 2)];
    NSString *str_Day = [aDay substringWithRange:NSMakeRange(6, 2)];
    NSString *str_Hour = [aDay substringWithRange:NSMakeRange(8, 2)];
    NSString *str_Minute = [aDay substringWithRange:NSMakeRange(10, 2)];
    NSString *str_Second = [aDay substringWithRange:NSMakeRange(12, 2)];
    NSString *str_Date = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@", str_Year, str_Month, str_Day, str_Hour, str_Minute, str_Second];
    
    NSDateFormatter *format1 = [[NSDateFormatter alloc] init];
    [format1 setDateFormat:@"yyyy-MM-dd HH:mm:ss +0000"];
    
    NSDate *ddayDate = [format1 dateFromString:str_Date];
    
    NSDate *date = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    NSInteger nYear = [components year];
    NSInteger nMonth = [components month];
    NSInteger nDay = [components day];
    NSInteger nHour = [components hour];
    NSInteger nMinute = [components minute];
    NSInteger nSecond = [components second];
    
    NSDate *currentTime = [format1 dateFromString:[NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld:%02ld", nYear, nMonth, nDay, nHour, nMinute, nSecond]];
    
    NSTimeInterval diff = [currentTime timeIntervalSinceDate:ddayDate];
    
    NSTimeInterval nWriteTime = diff;
    
    if( nWriteTime > (60 * 60 * 24) )
    {
        //        return [NSString stringWithFormat:@"%@-%@-%@", str_Year, str_Month, str_Day];
        return [NSString stringWithFormat:@"%@월 %@일", str_Month, str_Day];
    }
    else
    {
        if( nWriteTime <= 0 )
        {
            return @"1초전";
        }
        else if( nWriteTime < 60 )
        {
            //1분보다 작을 경우
            return [NSString stringWithFormat:@"%.0f초전", nWriteTime];
        }
        else if( nWriteTime < (60 * 60) )
        {
            //1시간보다 작을 경우
            return [NSString stringWithFormat:@"%.0f분전", nWriteTime / 60];
        }
        else
        {
            return [NSString stringWithFormat:@"%.0f시간전", ((nWriteTime / 60) / 60)];
        }
    }
    
    
    return @"";
}

+ (NSString *)getThotingChatDate:(NSString *)aDay
{
    if( aDay.length < 12 )
    {
        return aDay;
    }
    
    NSDate *date = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    NSInteger nYear = [components year];
    NSInteger nMonth = [components month];
    NSInteger nDay = [components day];
    NSInteger nHour = [components hour];
    NSInteger nMinute = [components minute];
    NSInteger nSecond = [components second];
    NSString *str_Current = [NSString stringWithFormat:@"%04ld%02ld%02ld%02ld%02ld%02ld", nYear, nMonth, nDay, nHour, nMinute, nSecond];

    NSString *str_Date = [NSString stringWithFormat:@"%@", aDay];
    NSString *str_Year = [str_Date substringWithRange:NSMakeRange(0, 4)];
    NSString *str_Month = [str_Date substringWithRange:NSMakeRange(4, 2)];
    NSString *str_Day = [str_Date substringWithRange:NSMakeRange(6, 2)];
    
    if( nYear > [str_Year integerValue] )
    {
        return [NSString stringWithFormat:@"%@년 %ld월 %ld일", str_Year, [str_Month integerValue], [str_Day integerValue]];
//        return [NSString stringWithFormat:@"%ld년전", nYear - [str_Year integerValue]];
    }
    else if( nMonth > [str_Month integerValue] )
    {
        return [NSString stringWithFormat:@"%ld월 %ld일", [str_Month integerValue], [str_Day integerValue]];
//        return [NSString stringWithFormat:@"%ld개월전", nMonth - [str_Month integerValue]];
    }
    else if( nDay > [str_Day integerValue] )
    {
        return [NSString stringWithFormat:@"%ld월 %ld일", [str_Month integerValue], [str_Day integerValue]];
//        return [NSString stringWithFormat:@"%ld일전", nDay - [str_Day integerValue]];
    }
    else
    {
        NSString *str_Hour = [str_Date substringWithRange:NSMakeRange(8, 2)];
        NSString *str_Minute = [str_Date substringWithRange:NSMakeRange(10, 2)];
        str_Date = [NSString stringWithFormat:@"%@ %ld:%02ld",
                    [str_Hour integerValue] > 12 ? @"오후" : @"오전",
                    ([str_Hour integerValue] > 12) ? [str_Hour integerValue] - 12 : [str_Hour integerValue] == 0 ? 12 : [str_Hour integerValue], [str_Minute integerValue]];
        
        return str_Date;
    }

    return @"";
}

+ (NSString *)getMainThotingChatDate:(NSString *)aDay
{
    NSDate *date = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    NSInteger nYear = [components year];
    NSInteger nMonth = [components month];
    NSInteger nDay = [components day];
//    NSInteger nHour = [components hour];
//    NSInteger nMinute = [components minute];

    
    
    
    
    
    NSString *str_Date = [NSString stringWithFormat:@"%@", aDay];
    NSString *str_Year = [str_Date substringWithRange:NSMakeRange(0, 4)];
    NSString *str_Month = [str_Date substringWithRange:NSMakeRange(4, 2)];
    NSString *str_Day = [str_Date substringWithRange:NSMakeRange(6, 2)];
    NSString *str_Hour = [str_Date substringWithRange:NSMakeRange(8, 2)];
    NSString *str_Minute = [str_Date substringWithRange:NSMakeRange(10, 2)];
    
    
    
    //오늘자
    NSString *str_Current = [NSString stringWithFormat:@"%04ld%02ld%02ld", nYear, nMonth, nDay];
    NSString *str_Target = [NSString stringWithFormat:@"%04ld%02ld%02ld", [str_Year integerValue], [str_Month integerValue], [str_Day integerValue]];
    if( [str_Current integerValue] == [str_Target integerValue] )
    {
        NSString *str_Time = [NSString stringWithFormat:@"%@ %ld:%02ld",
                              [str_Hour integerValue] > 12 ? @"오후" : @"오전",
                              ([str_Hour integerValue] > 12) ? [str_Hour integerValue] - 12 : [str_Hour integerValue] == 0 ? 12 : [str_Hour integerValue], [str_Minute integerValue]];

        return str_Time;
    }

    //하루가 지난것
    return [NSString stringWithFormat:@"%ld월 %ld일", [str_Month integerValue], [str_Day integerValue]];
}

+ (void)addChannelUrl:(NSString *)aUrl withRId:(NSString *)aRId
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        aUrl, @"channelUrl",
                                        aRId, @"rId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/update/chat/room/channel/url"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {

                                        }
                                    }];
}

+ (nullable NSArray<SBDBaseMessage *> *)loadMessagesInChannel:(NSString * _Nonnull)channelUrl
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *appIdDirectory = [documentsDirectory stringByAppendingPathComponent:[SBDMain getApplicationId]];
    NSString *messageFileNamePrefix = [[self class] sha256:[NSString stringWithFormat:@"%@_%@", [SBDMain getCurrentUser].userId, channelUrl]];
    NSString *dumpFileName = [NSString stringWithFormat:@"%@.data", messageFileNamePrefix];
    NSString *dumpFilePath = [appIdDirectory stringByAppendingPathComponent:dumpFileName];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:dumpFilePath]) {
        return nil;
    }
    
    NSError *errorReadDump;
    NSString *messageDump = [NSString stringWithContentsOfFile:dumpFilePath encoding:NSUTF8StringEncoding error:&errorReadDump];
    
    if (messageDump.length > 0) {
        NSArray *loadMessages = [messageDump componentsSeparatedByString:@"\n"];
        
        if (loadMessages.count > 0) {
            NSMutableArray<SBDBaseMessage *> *messages = [[NSMutableArray alloc] init];
            for (NSString *msgString in loadMessages) {
                NSData *msgData = [[NSData alloc] initWithBase64EncodedString:msgString options:0];
                
                
                SBDBaseMessage *message = [SBDBaseMessage buildFromSerializedData:msgData];
                [messages addObject:message];
            }
            
            return messages;
        }
    }
    
    return nil;
}

+ (nonnull NSString *)sha256:(NSString * _Nonnull)src
{
    const char* str = [src UTF8String];
    unsigned char result[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(str, (uint32_t)strlen(str), result);
    
    NSMutableString *sha256hash = [NSMutableString stringWithCapacity:CC_SHA256_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_SHA256_DIGEST_LENGTH; i++) {
        [sha256hash appendFormat:@"%02x", result[i]];
    }
    
    if (sha256hash == nil) {
        return @"";
    }
    
    return sha256hash;
}

+ (void)showToast:(NSString *)aMsg
{
    [ALToastView toastInView:[UIApplication sharedApplication].keyWindow withText:aMsg];
}

@end
