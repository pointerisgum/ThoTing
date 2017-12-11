//
//  Util.h
//  FoodView
//
//  Created by Kim Young-Min on 13. 3. 13..
//  Copyright (c) 2013년 bencrow. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SendBirdSDK/SendBirdSDK.h>

@interface Util : NSObject

+ (Util *)sharedData;

//인디케이터 띄우기
- (void)addIndicator;

//인디케이터 지우기
- (void)removeIndicator;

//네트워크 체크 + 얼렛
+ (BOOL)isNetworkCheckAlert;

//네트워크 상태 가져오기
+ (NSString *)getNetworkSatatus;

//이미지 라운딩
+ (void)imageRounding:(UIView *)v;
+ (void)imageRoundingAndBorder:(UIView *)v;

//이미지 회전
+ (void)spinLayer:(CALayer *)inLayer duration:(CFTimeInterval)inDuration direction:(int)direction;
+ (void)rotationImage:(UIView *)view withRadian:(int)radian;

//문자열중에서 숫자만 뽑아오기
+ (NSString*)getOnlyNumber:(NSString *)aString;

//폴더 만들기
+ (BOOL)createFolderWithCloudSync:(BOOL)sync;

//파일 만들기
+ (BOOL)createFile:(NSString *)fileName;

//유효한 이메일인지
+ (BOOL)isUsableEmail:(NSString *)str;

//유효한 폰넘버인지 검사
+ (BOOL)isUsablePhoneNumber:(NSString *)str;

//숫자만 있는지 검사
+ (BOOL)isOnlyNumber:(NSString *)str;

//do not backup (iCloud attr)
+ (BOOL)addSkipBackupAttributeToiTemAtURL:(NSURL *)URL;

//동영상 섬네일 가져오기
+ (UIImage *)thumbnailFromVideoAtURL:(NSString *)path;

//원형 이미지 만들기
+ (void)makeCircleImage:(UIView *)iv withBorderWidth:(float)border;

//글자에 음영넣기
+ (void)addTextShodow:(UILabel *)text;

//네비게이션바 타이틀 셋팅하기
+ (UIView *)createNavigationTitleView:(UIView *)view withTitle:(NSString *)title;

//리얼 이미지를 인자로 넘겨주는 사이즈로 섬네일 urlString 만들기
+ (NSString *)makeThumbNailUrlString:(NSString *)aUrlString withSize:(NSString *)aSize;

//해당 스트링에 영문과 숫자만 있는지 체크
+ (BOOL)isStringCheck:(NSString *)aString;

//라운드 입맛에 맛게 주기
+ (void)setRound:(const UIView *)view withCorners:(UIRectCorner)corners;

+ (void)setRound:(const UIView *)view withCornerSize:(CGSize)size;

+ (void)setSearchNaviBar:(UINavigationBar *)naviBar;

//특수문자 검사 (특수문자가 있으면 YES, 없으면 NO)
+ (BOOL)isSpecialCharacter:(NSString *)str;

//네비 타이틀바 바꾸기
+ (void)setMainNaviBar:(UINavigationBar *)naviBar;
+ (void)setLoginNaviBar:(UINavigationBar *)naviBar;

//폰트 사이즈 얻어오기
+ (CGSize)getTextSize:(UILabel *)lb;

+ (CGSize)getTextSize2:(UILabel *)lb;

//+ (CGSize)getTextSize:(NSString *)str withAttr:(NSAttributedString *)attbStr;

+ (void)writeFile:(NSString *)stringToSave;

+ (void)setSvContentsSize:(UIScrollView *)sv withTargetObj:(UIView *)lastObj;

//가로, 세로 맞춰 이미지 리사이징하기
+ (UIImage*)imageWithImage:(UIImage *)image convertToWidth:(float)width covertToHeight:(float)height;

//세로 맞춰 이미지 리사이징하기
+ (UIImage*)imageWithImage:(UIImage *)image convertToHeight:(float)height;

//가로 맞춰 이미지 리사이징하기
+ (UIImage*)imageWithImage:(UIImage *)image convertToWidth:(float)width;

//텍스트뷰 높이 가져오기 (iOS6, iOS7)
+ (CGFloat)getTextViewHeight:(UITextView *)textView;

//빠바 비번체크(문자 숫자 조합 6자리 이상)
+ (BOOL)isPariPwCheck:(NSString *)aString;

+ (BOOL)isOnlyEnglish:(NSString *)str;

//버전 비교 (앞이 현재버전, 뒤가 최신버전 리턴값이 NSOrderedAscending면 업데이트 필요)
+ (NSComparisonResult)compareVersion:(NSString*)versionOne toVersion:(NSString*)versionTwo;

//키보드 악세사리뷰 ( <  >   완료)
+ (UIView *)createKeyboardAccView;

+ (NSString *)getIPAddress;

+ (NSString *)stringByStrippingHTML:(NSString*)str;

+ (void)printDictionaryLog:(NSDictionary *)dic;

+ (NSString *)getUUID;

+ (CGFloat)getTextWith:(UILabel *)lb;

+ (NSString *)getDeviceName;

//토팅전용
+ (NSURL *)createImageUrl:(NSString *)aHeader withFooter:(NSString *)aFooter;

//인트를 스트링으로 변환
+ (NSString *)transIntToString:(id)obj;

+ (UIImage *)makeNinePatchImage:(UIImage *)image;

//+ (void)showToast:(NSString *)aMsg;

+ (NSString *)getDday:(NSString *)aDay;

+ (NSString *)getThotingChatDate:(NSString *)aDay;

+ (NSString *)getMainThotingChatDate:(NSString *)aDay;

+ (void)addChannelUrl:(NSString *)aUrl withRId:(NSString *)aRId;

+ (nullable NSArray<SBDBaseMessage *> *)loadMessagesInChannel:(NSString * _Nonnull)channelUrl;

+ (nonnull NSString *)sha256:(NSString * _Nonnull)src;

+ (void)showToast:(NSString *)aMsg;

+ (NSString *)getDetailDate:(NSString *)aDay;

+ (void)addOpenChannelUrl:(NSString *)aUrl withRId:(NSString *)aRId;

+ (NSString *)contentTypeForImageData:(NSData *)data;   //마인타입 가져오기

+ (NSString *)getSharpName:(NSString *)aName;

@end
