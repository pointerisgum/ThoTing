//
//  Common.m
//  Pari
//
//  Created by KimYoung-Min on 2014. 12. 27..
//  Copyright (c) 2014년 KimYoung-Min. All rights reserved.
//

#import "Common.h"
#import "NotiViewController.h"
//#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

static Common *shared = nil;
static NSMutableDictionary *dicM_UserInfo = nil;
static NSMutableArray *arM_Area = nil;      //지역
static NSMutableArray *arM_Style = nil;     //스타일
static NSMutableArray *arM_Interest = nil;  //취미
static NSMutableArray *arM_Faith = nil;     //종교
static NSMutableArray *arM_Charm = nil;     //매력

static ReaderDocument *document = nil;

@implementation Common

+ (void)initialize
{
    NSAssert(self == [Common class], @"Singleton is not designed to be subclassed.");
    shared = [Common new];
    
    arM_Area = [NSMutableArray arrayWithObjects:
                @"서울 강북",
                @"서울 강남",
                @"서울 강동",
                @"서울 강서",
                @"경기북부(일산,의정부)",
                @"경기남부(분당,수원)",
                @"경기동부(남양주,양평)",
                @"경기서부(부천,김포)",
                @"인천",
                @"대전",
                @"대구",
                @"부산",
                @"울산",
                @"광주",
                @"강원도",
                @"충청북도",
                @"충청남도",
                @"경상북도",
                @"경상남도",
                @"전라북도",
                @"전라남도",
                @"제주도",
                @"해외",
                nil];

    arM_Style = [NSMutableArray arrayWithObjects:
                 @"세련된",
                 @"섹시한",
                 @"단아한",
                 @"깔끔한",
                 @"지적인",
                 @"귀여운",
                 @"청순한",
                 @"평범한",
                 @"여성스런",
                 @"남성적인",
                 @"참한",
                 @"단정한",
                 @"도도한",
                 @"동안형",
                 @"듬직한",
                 @"푸근한",
                 @"댄디한",
                 @"훈훈한",
                 @"부드러운",
                 @"강한인상",
                 @"날씬한",
                 @"적당한",
                 @"통통한",
                 @"뚱뚱한",
                 @"키가큰",
                 @"아담한",
                 @"볼륨있는",
                 @"눈웃음",
                 @"카리스마",
                 @"성형안한",
                 @"동양적인",
                 @"서구적인",
                 nil];

    arM_Interest = [NSMutableArray arrayWithObjects:
                     @"영화/공연관람",
                     @"요리",
                     @"여행",
                     @"맛집탐방",
                     @"헬스/요가/수영",
                     @"스키/보드",
                     @"스포츠 관람",
                     @"쇼핑",
                     @"음악감상",
                     @"드라이브",
                     @"악기연주",
                     @"독서",
                     @"커피홀릭",
                     @"사진찍기",
                     @"미술/수공예",
                     @"등산/산책",
                     @"게임",
                     @"SNS/페이스북",
                     @"댄스",
                     @"트래킹",
                     @"노래하기",
                     nil];
    
    arM_Faith = [NSMutableArray arrayWithObjects:
                 @"종교없음",
                 @"기독교",
                 @"불교",
                 @"천주교",
                 @"원불교",
                 @"기타",
                 nil];
    
    arM_Charm = [NSMutableArray arrayWithObjects:
                 @"요리를 즐기고 잘해요",
                 @"감각적인 패셔니스타에요",
                 @"잘 다루는 악기가 있어요",
                 @"몸매 관리를 열심히 합니다",
                 @"맑은 도자기 피부에요",
                 @"공연/영화/문화 관람을 즐겨요",
                 @"마이카를 소유하고 있어요",
                 @"해외에서 취득한 학위가 있어요",
                 @"커피를 즐기는 커피매니아",
                 @"큰키 or 볼륨감의 소유자",
                 @"운동을 좋아하고 즐겨요",
                 @"1개 이상의 외국어를 잘해요",
                 @"의사/변호사/회계사등 전문직",
                 @"명문대 학위가 있어요",
                 @"대기업을 다니고 있어요",
                 @"여행을 좋아하는 여행 매니아",
                 nil];

}

+ (Common *)sharedData
{
    return shared;
}

+ (void)setUserInfo:(NSDictionary *)dic
{
    dicM_UserInfo = [NSMutableDictionary dictionaryWithDictionary:dic];
}

+ (NSDictionary *)getUserInfo
{
    return dicM_UserInfo;
}

+ (void)removeUserInfo
{
    [dicM_UserInfo removeAllObjects];
    dicM_UserInfo = nil;
}

+ (void)setCntButton:(NSString *)aString withObj:(UIButton *)btn
{
    NSInteger cnt = [aString integerValue];
    
    if( cnt > 0 )
    {
        btn.hidden = NO;
        [btn setTitle:[NSString stringWithFormat:@"%ld", (long)cnt] forState:UIControlStateNormal];
    }
    else
    {
        btn.hidden = YES;
    }
}


+ (void)addScrapWithAucId:(NSString *)aAucId withLotNum:(NSString *)aLotNum withBlock:(void(^)(BOOL isSuccess))completion
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        @"Main", @"method",
                                        @"aauc", @"commkind",
                                        @"saveScrapPrdt", @"process_id",
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"], @"mb_id",
                                        aAucId, @"auc_id",
                                        aLotNum, @"lot_num",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"comMain.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"rtnCode"] integerValue];
                                            if( nCode == 0 )
                                            {
                                                completion(YES);
//                                                self.btn_Scrap.selected = YES;
                                            }
                                            else
                                            {
                                                ALERT(nil, [resulte objectForKey_YM:@"rtnMsg"], nil, @"확인", nil);
                                            }
                                        }
                                    }];
}

+ (void)deleteScrapWithAucId:(NSString *)aAucId withLotNum:(NSString *)aLotNum withBlock:(void(^)(BOOL isSuccess))completion
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        @"Main", @"method",
                                        @"aauc", @"commkind",
                                        @"delScrapPrdt", @"process_id",
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"UserId"], @"mb_id",
                                        aAucId, @"auc_id",
                                        aLotNum, @"lot_num",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"comMain.do"
                                        param:dicM_Params
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"rtnCode"] integerValue];
                                            if( nCode == 0 )
                                            {
                                                completion(YES);
//                                                self.btn_Scrap.selected = NO;
                                            }
                                            else
                                            {
                                                ALERT(nil, [resulte objectForKey_YM:@"rtnMsg"], nil, @"확인", nil);
                                            }
                                        }
                                    }];
}

+ (id)getAreaList
{
    return arM_Area;
}

+ (id)getStyleList
{
    return arM_Style;
}

+ (id)getInterestList
{
    return arM_Interest;
}

+ (id)getFaithList
{
    return arM_Faith;
}

+ (id)getCharmList
{
    return arM_Charm;
}


+ (ReaderDocument *)getPdfDocument
{
    return document;
}

+ (void)setPdfDocument:(ReaderDocument *)doc
{
    document = doc;
}

+ (void)registToken
{
    NSString *str_Token = [[NSUserDefaults standardUserDefaults] objectForKey:@"PushToken"];
    
#if TARGET_IPHONE_SIMULATOR
    str_Token = @"fPSwKVXXPRs:APA91bFY_iJqmHcsHIMx_8O1jOmHIeYa8krP0ZPPgqCvu-Okfcp78tMAp1urapdJiPNfc8Qfe-Ya9tR3J_y2hlvxzWW-oKdTi3YL7HEid54r6ncx0EB-azhVv__dRT4dJRFUoHW6_z0T";
#endif
    
    if( str_Token )
    {
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            @"ios", @"deviceOs",
                                            str_Token, @"deviceToken",
                                            nil];
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/device/token"
                                            param:dicM_Params
                                       withMethod:@"POST"
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            if( resulte )
                                            {
                                                NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                if( nCode == 200 )
                                                {
                                                    
                                                }
                                            }
                                            else
                                            {
                                                
                                            }
                                        }];
    }
}

+ (void)showDetailNoti:(UIViewController *)vcParent withInfo:(NSDictionary *)dic
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    NotiViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"NotiViewController"];
    vc.dic_Info = dic;
    [vcParent presentViewController:vc animated:YES completion:^{
        
    }];
}

+ (void)logUser
{
    [CrashlyticsKit setUserIdentifier:[[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"]];
    [CrashlyticsKit setUserEmail:[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    [CrashlyticsKit setUserName:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]];
}

+ (void)removeAllPdfFile
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSFileManager *fileManager = [NSFileManager defaultManager];

    NSError *error;
    NSDirectoryEnumerator* en = [fileManager enumeratorAtPath:documentsDirectory];
    NSString* file;
    while (file = [en nextObject])
    {
//        NSLog(@"%@", file);
        if( [file hasSuffix:@".pdf"] || [file hasSuffix:@".PDF"] )
        {
            NSLog(@"remove %@", file);
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:file]  error:&error];
        }
        else if( [file hasSuffix:@".m4a"] || [file hasSuffix:@".mp3"] )
        {
            NSLog(@"remove %@", file);
            [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:file]  error:&error];
        }
        else if( [file hasSuffix:@".zip"] )
        {
            NSLog(@"remove %@", file);
            NSDictionary* attrs = [fileManager attributesOfItemAtPath:[documentsDirectory stringByAppendingPathComponent:file] error:nil];
            NSDate *createDate = (NSDate*)[attrs objectForKey: NSFileCreationDate];

            NSDateFormatter *format1 = [[NSDateFormatter alloc] init];
            [format1 setDateFormat:@"yyyy-MM-dd HH:mm:ss +0000"];

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
            
            NSTimeInterval diff = [currentTime timeIntervalSinceDate:createDate];
            
            NSTimeInterval nWriteTime = diff;
            if( nWriteTime > ((60 * 60 * 24) * 14) )
            {
                [fileManager removeItemAtPath:[documentsDirectory stringByAppendingPathComponent:file]  error:&error];
            }
        }
    }
}

@end
