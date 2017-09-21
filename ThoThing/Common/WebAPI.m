//
//  WebAPI.m
//  Kizzl
//
//  Created by Kim Young-Min on 13. 6. 3..
//  Copyright (c) 2013년 Kim Young-Min. All rights reserved.
//

#import "WebAPI.h"
#import "AFHTTPClient.h"
#import "AFJSONRequestOperation.h"
#import "SBJson.h"

static WebAPI *shared = nil;
static AFHTTPClient *client = nil;
static AFHTTPClient *appStoreclient = nil;
static AFHTTPClient *sendBirdclient = nil;
static AFHTTPClient *pushClient = nil;
static NSInteger kRetryCount = 3;   //통신 취소하는것 땜시 재시도 안하게 함
static NSInteger nRetry = 3;

typedef void (^WebSuccessBlock)(id resulte, NSError *error);

@implementation WebAPI

+ (void)initialize
{
    NSAssert(self == [WebAPI class], @"Singleton is not designed to be subclassed.");
    shared = [WebAPI new];
    client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:kBaseUrl]];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    sendBirdclient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"https://api.sendbird.com"]];
    [sendBirdclient registerHTTPOperationClass:[AFJSONRequestOperation class]];

    appStoreclient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://itunes.apple.com"]];
    [appStoreclient registerHTTPOperationClass:[AFJSONRequestOperation class]];

    pushClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://www.thoting.com:8888"]];
    [pushClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
}

+ (WebAPI *)sharedData
{
    [Util isNetworkCheckAlert];
    return shared;
  
//    return [Util isNetworkCheckAlert] ? shared : nil;
}

- (void)addDefaultParams:(NSMutableDictionary *)params
{
    NSString *str_Param_C = [params objectForKey:@"c"];
    NSString *str_Param_M = [params objectForKey:@"m"];
    if( [str_Param_C isEqualToString:@"pa_member"] && [str_Param_M isEqualToString:@"addMember"] )
    {
        
    }

//    NSString *str_UserNum = [[UserInfo sharedData] str_UserNum];
    NSString *str_UserNum = @"42";
    
    [params setObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleShortVersionString"] forKey:@"app_ver"];
    [params setObject:@"I" forKey:@"os"];
    [params setObject:[[UIDevice currentDevice] systemVersion] forKey:@"os_ver"];
    if( str_UserNum != nil )
    {
        [params setObject:str_UserNum forKey:@"user_num"];
    }
}

- (NSURL *)getWebViewUrl:(NSMutableDictionary *)params
{
    [self addDefaultParams:params];
    
    NSMutableString *strM_Url = [NSMutableString stringWithString:kBaseUrl];
    [strM_Url appendString:@"/api"];
    
    NSArray *ar_AllKeys = [params allKeys];
    for( int i = 0; i < [ar_AllKeys count]; i++ )
    {
        NSString *str_Key = [ar_AllKeys objectAtIndex:i];
        NSString *str_Value = @"";
        if( [[params objectForKey:str_Key] isKindOfClass:[NSString class]] )
        {
            str_Value = [params objectForKey:str_Key];
        }
        else if( [[params objectForKey:str_Key] isKindOfClass:[NSNumber class]] )
        {
            int nValue = [[params objectForKey:str_Key] intValue];
            str_Value = [NSString stringWithFormat:@"%d", nValue];
        }
        [strM_Url appendString:str_Key];
        [strM_Url appendString:@"="];
        [strM_Url appendString:str_Value];
        [strM_Url appendString:@"&"];
    }
    
    return [NSURL URLWithString:strM_Url];
}

- (NSString *)getWebViewUrlString
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   @"contents", @"c",
                                   @"linkStore", @"m", nil];
    
    [self addDefaultParams:params];
    
    NSMutableString *strM_Url = [NSMutableString stringWithString:kBaseUrl];
    [strM_Url appendString:@"/cont?"];
    
    NSArray *ar_AllKeys = [params allKeys];
    for( int i = 0; i < [ar_AllKeys count]; i++ )
    {
        NSString *str_Key = [ar_AllKeys objectAtIndex:i];
        NSString *str_Value = @"";
        if( [[params objectForKey:str_Key] isKindOfClass:[NSString class]] )
        {
            str_Value = [params objectForKey:str_Key];
        }
        else if( [[params objectForKey:str_Key] isKindOfClass:[NSNumber class]] )
        {
            int nValue = [[params objectForKey:str_Key] intValue];
            str_Value = [NSString stringWithFormat:@"%d", nValue];
        }
        [strM_Url appendString:str_Key];
        [strM_Url appendString:@"="];
        [strM_Url appendString:str_Value];
        [strM_Url appendString:@"&"];
    }
    
    return strM_Url;
}

- (void)openStore
{
    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        @"contents", @"c",
                                        @"linkStore", @"m", nil];
    
    [self addDefaultParams:params];
    
    NSMutableString *strM_Url = [NSMutableString stringWithString:kBaseUrl];
    [strM_Url appendString:@"/cont?"];
    
    NSArray *ar_AllKeys = [params allKeys];
    for( int i = 0; i < [ar_AllKeys count]; i++ )
    {
        NSString *str_Key = [ar_AllKeys objectAtIndex:i];
        NSString *str_Value = @"";
        if( [[params objectForKey:str_Key] isKindOfClass:[NSString class]] )
        {
            str_Value = [params objectForKey:str_Key];
        }
        else if( [[params objectForKey:str_Key] isKindOfClass:[NSNumber class]] )
        {
            int nValue = [[params objectForKey:str_Key] intValue];
            str_Value = [NSString stringWithFormat:@"%d", nValue];
        }
        [strM_Url appendString:str_Key];
        [strM_Url appendString:@"="];
        [strM_Url appendString:str_Value];
        [strM_Url appendString:@"&"];
    }
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:strM_Url]];
}

//- (void)callWebAPIBlock:(NSMutableDictionary *)params withBlock:(void(^)(id resulte, NSError *error))completion
//{ 
//    //    [self addDefaultParams:params];
//    
//    NSString *str_PostPath = [NSString stringWithFormat:@"/API/%@", path];
//    [client postPath:str_PostPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
//        NSMutableDictionary *dicM_Result = (NSMutableDictionary *)[jsonParser objectWithString:dataString];
//        
//        int nRep = [[dicM_Result objectForKey:@"ResultCd"] intValue];
//        if( nRep == 1 )
//        {
//            completion(dicM_Result, nil);
//        }
//        else
//        {
//            //BrandChange
//            
//            //error
//            if( [[dicM_Result objectForKey:@"ResultMsg"] length] > 0 )
//            {
//                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
//                [window makeToast:[dicM_Result objectForKey:@"ResultMsg"] withPosition:kPositionCenter];
//            }
//            
//            completion(nil, nil);
//        }
//    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//        //중복된 팝업을 방지하기 위한 코드
//        static BOOL isNowShowPopup = NO;
//        
//        if( !isNowShowPopup )
//        {
//            isNowShowPopup = YES;
//            
//            UIAlertView *alert = CREATE_ALERT(nil, @"NetworkError", @"확인", nil);
//            [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                if( buttonIndex == 0 )
//                {
//                    isNowShowPopup = NO;
//                }
//            }];
//        }
//        
//        completion(nil, error);
//    }];
//    
//    NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@%@?", kBaseUrl, str_PostPath];
//    NSArray *ar_AllKeys = [params allKeys];
//    for( int i = 0; i < [ar_AllKeys count]; i++ )
//    {
//        NSString *str_Key = [ar_AllKeys objectAtIndex:i];
//        NSString *str_Val = [params objectForKey:str_Key];
//        [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
//    }
//    
//    if( [strM_CallUrl hasSuffix:@"&"] )
//    {
//        [strM_CallUrl deleteCharactersInRange:NSMakeRange([strM_CallUrl length]-1, 1)];
//    }
//    
//    NSLog(@"%@", strM_CallUrl);
//}

//- (void)callWebAPIBlockNonAlert:(NSMutableDictionary *)params withBlock:(void(^)(id resulte, NSError *error))completion
//{
////    [self addDefaultParams:params];
//    
//    
//    
//    [params setObject:@"1.30" forKey:@"app_ver"];
//    [params setObject:@"I" forKey:@"os"];
//    [params setObject:@"7.0.3" forKey:@"os_ver"];
//    [params setObject:@"94" forKey:@"user_num"];
//    
//    NSTimeInterval startTime = [[NSDate date] timeIntervalSince1970];
//
//    
//    [client postPath:@"/cont/" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
//        
//        __block NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
//        
//        NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
//        NSMutableDictionary *dicM_Result = (NSMutableDictionary *)[jsonParser objectWithString:dataString];
//        
//        int nRep = [[[dicM_Result valueForKey:@"ret"] objectForKey:@"resP"] intValue];
//        if( nRep != 0 )
//        {
//            switch ( nRep )
//            {
//                    
//            }
//            
//            completion(nil, nil);
//        }
//        else
//        {
//            //API에 에러코드가 없을시
//            NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@/cont/?", kBaseUrl];
//            NSArray *ar_AllKeys = [params allKeys];
//            for( int i = 0; i < [ar_AllKeys count]; i++ )
//            {
//                NSString *str_Key = [ar_AllKeys objectAtIndex:i];
//                NSString *str_Val = [params objectForKey:str_Key];
//                [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
//            }
//            [strM_CallUrl appendString:@"debug=1"];
//            
//            if( [dicM_Result isEqual:[NSNull null]] || [[dicM_Result valueForKey:@"owner"] isEqual:[NSNull null]] )
//            {
//                completion(nil, nil);
//            }
//            else
//            {
//                completion([dicM_Result valueForKey:@"owner"], nil);
//            }
//        }
//        
//        
//        
//        //API에 에러코드가 없을시
//        NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@/cont/?", kBaseUrl];
//        NSArray *ar_AllKeys = [params allKeys];
//        for( int i = 0; i < [ar_AllKeys count]; i++ )
//        {
//            NSString *str_Key = [ar_AllKeys objectAtIndex:i];
//            NSString *str_Val = [params objectForKey:str_Key];
//            [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
//        }
//        [strM_CallUrl appendString:@"debug=1"];
//
//        NSString *str_Path = [kFileSavePath stringByAppendingPathComponent:@"log.txt"];
//        NSMutableString *strM_Log = [NSMutableString stringWithString:[NSString stringWithContentsOfFile:str_Path encoding:NSUTF8StringEncoding error:nil]];
//        [strM_Log appendString:[NSString stringWithFormat:@"실행시간:%f 쿼리:%@\n", endTime - startTime, strM_CallUrl]];
//        [strM_Log appendString:@"\n"];
//        [Util writeFile:strM_Log];
//
//        
//        
//    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        
//        completion(nil, error);
//    }];
//}


- (void)imageUpload:(NSString *)path param:(NSMutableDictionary *)dataParams withImages:(NSDictionary *)imageParams withBlock:(void(^)(id resulte, NSError *error))completion
{
    [MBProgressHUD show];
    
    NSMutableDictionary *defaultParams = [NSMutableDictionary dictionary];
//    [self addDefaultParams:defaultParams];
    
    [client setParameterEncoding:AFFormURLParameterEncoding];

    NSString *str_PostPath = [NSString stringWithFormat:@"/api/%@", path];

    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:str_PostPath parameters:defaultParams constructingBodyWithBlock: ^(id <AFMultipartFormData>formData) {
        
        NSArray *ar_DataKeys = [dataParams allKeys];
        for( int i = 0; i < [ar_DataKeys count]; i++ )
        {
            NSString *str_Value = [NSString stringWithFormat:@"%@", [dataParams objectForKey:[ar_DataKeys objectAtIndex:i]]];
            [formData appendPartWithFormData:[str_Value dataUsingEncoding:NSUTF8StringEncoding] name:[ar_DataKeys objectAtIndex:i]];
        }
        
        NSArray *ar_FileKeys = [imageParams allKeys];
        for( int i = 0; i < [ar_FileKeys count]; i++ )
        {
            NSString *str_Key = [ar_FileKeys objectAtIndex:i];
            NSData *imageData = [imageParams objectForKey:str_Key];
            
            NSDate *date = [NSDate date];
            NSCalendar* calendar = [NSCalendar currentCalendar];
            NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
            NSInteger nYear = [components year];
            NSInteger nMonth = [components month];
            NSInteger nDay = [components day];
            NSInteger nHour = [components hour];
            NSInteger nMinute = [components minute];
            NSInteger nSecond = [components second];
            double CurrentTime = CACurrentMediaTime();
            NSString *str_MillSec = @"";
            NSString *str_MillSecTmp = [NSString stringWithFormat:@"%f", CurrentTime];
            NSArray *ar_Tmp = [str_MillSecTmp componentsSeparatedByString:@"."];
            if( [ar_Tmp count] > 0 )
            {
                str_MillSec = [ar_Tmp objectAtIndex:1];
            }
            
//            NSString *str_FileName = [NSString stringWithFormat:@"%04ld%02ld%02ld%02ld%02ld%02ld%@.jpg", (long)nYear, (long)nMonth, (long)nDay, (long)nHour, (long)nMinute, (long)nSecond, str_MillSec];
//            NSLog(@"%@", str_FileName);

            NSString *str_FileName = @"";
            NSString *str_MineType = @"";
            NSString *str_Type = [dataParams objectForKey:@"type"];
            if( [str_Type isEqualToString:@"video"] )
            {
                str_MineType = @"video/mp4";
                str_FileName = [NSString stringWithFormat:@"%04ld%02ld%02ld%02ld%02ld%02ld%@.mp4", (long)nYear, (long)nMonth, (long)nDay, (long)nHour, (long)nMinute, (long)nSecond, str_MillSec];
            }
            else if( [str_Type isEqualToString:@"audio"] )
            {
                str_MineType = @"audio/m4a";
                str_FileName = [NSString stringWithFormat:@"%04ld%02ld%02ld%02ld%02ld%02ld%@.m4a", (long)nYear, (long)nMonth, (long)nDay, (long)nHour, (long)nMinute, (long)nSecond, str_MillSec];
            }
            else
            {
                str_MineType = @"image/jpg";
                str_FileName = [NSString stringWithFormat:@"%04ld%02ld%02ld%02ld%02ld%02ld%@.jpg", (long)nYear, (long)nMonth, (long)nDay, (long)nHour, (long)nMinute, (long)nSecond, str_MillSec];
            }
            
            NSLog(@"%@", str_FileName);

            [formData appendPartWithFileData:imageData name:@"file" fileName:str_FileName mimeType:str_MineType];
        }
    }];

    [request setTimeoutInterval:60];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        //        NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //            float fPercent = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
            //            [TWStatus setProgressBarFrame:CGRectMake(0, 0, 320 * fPercent, 20)];
            //            NSLog(@"%f", fPercent);
        });
    }];
    
    
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id  responseObject) {
        
        [MBProgressHUD hide];

        NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        id dicM_Result = [jsonParser objectWithString:dataString];
        
        completion(dicM_Result, nil);
        
        NSLog(@"이미지 업로드 결과 : %@", dicM_Result);
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [MBProgressHUD hide];

         if( operation.cancelled )
         {
             return ;
         }
 
         UIWindow *window = [[UIApplication sharedApplication] keyWindow];
         [window makeToast:@"NetworkError"];
         
         NSLog(@"===============================");
         NSLog(@"error : %@", error);
         NSLog(@"===============================");
         NSLog(@"params : %@", dataParams);
         NSLog(@"===============================");
         
         NSLog(@"error: %@",  operation.responseString);
         completion(nil, nil);
     }];
    
    
    [operation start];
}


- (void)fileUpload:(NSString *)path param:(NSMutableDictionary *)dataParams withFileUrl:(NSURL *)url withBlock:(void(^)(id resulte, NSError *error))completion
{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;

    NSData *videoData = [NSData dataWithContentsOfURL:url];
    
    [client setParameterEncoding:AFFormURLParameterEncoding];
    
//    NSString *str_PostPath = [NSString stringWithFormat:@"/api/%@", path];
    NSMutableURLRequest *request = [client multipartFormRequestWithMethod:@"POST" path:@"http://video.emcast.com:8080/rest/file/upload/8416f34a-f3ac-4081-9102-4b2d17dc9da8;weight=1;promptly=1" parameters:nil constructingBodyWithBlock:^(id <AFMultipartFormData>formData){

        NSArray *ar_DataKeys = [dataParams allKeys];
        for( int i = 0; i < [ar_DataKeys count]; i++ )
        {
            NSString *str_Value = [dataParams objectForKey:[ar_DataKeys objectAtIndex:i]];
            [formData appendPartWithFormData:[str_Value dataUsingEncoding:NSUTF8StringEncoding] name:[ar_DataKeys objectAtIndex:i]];
        }
        
        NSDate *date = [NSDate date];
        NSCalendar* calendar = [NSCalendar currentCalendar];
        NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit|NSHourCalendarUnit|NSMinuteCalendarUnit|NSSecondCalendarUnit fromDate:date];
        NSInteger nYear = [components year];
        NSInteger nMonth = [components month];
        NSInteger nDay = [components day];
        NSInteger nHour = [components hour];
        NSInteger nMinute = [components minute];
        NSInteger nSecond = [components second];
        double CurrentTime = CACurrentMediaTime();
        NSString *str_MillSec = @"";
        NSString *str_MillSecTmp = [NSString stringWithFormat:@"%f", CurrentTime];
        NSArray *ar_Tmp = [str_MillSecTmp componentsSeparatedByString:@"."];
        if( [ar_Tmp count] > 0 )
        {
            str_MillSec = [ar_Tmp objectAtIndex:1];
        }
        NSString *str_FileName = [NSString stringWithFormat:@"%04ld%02ld%02ld%02ld%02ld%02ld.%@.mov", (long)nYear, (long)nMonth, (long)nDay, (long)nHour, (long)nMinute, (long)nSecond, str_MillSec];
        NSLog(@"%@", str_FileName);

        [formData appendPartWithFileData:videoData name:@"file" fileName:str_FileName mimeType:@"video/quicktime"];
    }];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [operation setUploadProgressBlock:^(NSUInteger bytesWritten, long long totalBytesWritten, long long totalBytesExpectedToWrite) {
        //        NSLog(@"Sent %lld of %lld bytes", totalBytesWritten, totalBytesExpectedToWrite);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            //            float fPercent = (float)totalBytesWritten / (float)totalBytesExpectedToWrite;
            //            [TWStatus setProgressBarFrame:CGRectMake(0, 0, 320 * fPercent, 20)];
            //            NSLog(@"%f", fPercent);
        });
    }];
    
    
    [operation  setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id  responseObject) {
        
        NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];

        NSString *str_VideoId = @"";
        NSArray *ar_Sep1 = [dataString componentsSeparatedByString:@"<id>"];
        if( [ar_Sep1 count] > 1 )
        {
            NSString *str_Sep = [ar_Sep1 objectAtIndex:1];
            NSArray *ar_Sep2 = [str_Sep componentsSeparatedByString:@"</id>"];
            if( [ar_Sep2 count] > 1 )
            {
                str_VideoId = [ar_Sep2 objectAtIndex:0];
            }
        }
        
        completion(str_VideoId, nil);

    }failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         [MBProgressHUD hide];

         if( operation.cancelled )
         {
             return ;
         }

         ALERT(nil, @"네트워크에 접속할 수 없습니다.\n3G 및 Wifi 연결상태를\n확인해주세요.", nil, @"확인", nil);
         
         NSLog(@"error: %@",  operation.responseString);
         completion(nil, nil);
     }];
    
    
    [operation start];
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
}
     
- (void)showErrorMSG:(int)errorCode withData:(NSDictionary *)dic
{
    UIAlertView *alert = CREATE_ALERT(nil, [dic objectForKey:@"ResultMsg"], @"확인", nil);
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
    }];

//    switch ( errorCode )
//    {
//            //내부 에러 메세지
//        case 10:
//        {
//            //중복된 팝업을 방지하기 위한 코드
//            static BOOL isNowShowPopup = NO;
//            
//            if( !isNowShowPopup )
//            {
//                isNowShowPopup = YES;
//                
//                UIAlertView *alert = CREATE_ALERT(nil, [[dic valueForKey:@"ret"] objectForKey:@"resMsg"], @"확인", nil);
//                [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                    if( buttonIndex == 0 )
//                    {
//                        isNowShowPopup = NO;
//                    }
//                }];
//            }
//        }
//            break;
//            
//            //로그인 에러 메세지
//        case 11:
//        {
//            UIAlertView *alert = CREATE_ALERT(@"서비스 이용 제한안내", @"죄송합니다. 로그인하신 계정은 ASKing\n서비스 이용이 불가합니다.\n자세한 내용은 운영자에게 문의 주시기\n바랍니다.", @"문의하기", nil);
//            [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                if( buttonIndex == 0 )
//                {
//                    [[NSNotificationCenter defaultCenter] postNotificationName:kShowEmail object:nil];
//                }
//            }];
//        }
//            break;
//            
//            //비밀번호 찾기 에러 메세지
//        case 12:
//        {
////            ALERT(nil, @"해당 이메일로 가입하신 이력이 없습니다.\n확인하신 후에 다시 시도해주세요.", nil, @"확인", nil);
//            UIAlertView *alert = CREATE_ALERT(nil, [[dic valueForKey:@"ret"] objectForKey:@"resMsg"], @"확인", nil);
//            [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                
//            }];
//        }
//            break;
//            
//        default:
//            break;
//    }
}







































- (NSURL *)getWebViewUrl:(NSMutableDictionary *)params withUrl:(NSString *)aUrlString
{
    NSMutableString *strM_Url = [NSMutableString stringWithFormat:@"%@/front/%@?", kBaseUrl, aUrlString];
//    NSMutableString *strM_Url = [NSMutableString stringWithFormat:@"/api/%@", aUrlString];
    NSArray *ar_AllKeys = [params allKeys];
    for( int i = 0; i < [ar_AllKeys count]; i++ )
    {
        NSString *str_Key = [ar_AllKeys objectAtIndex:i];
        NSString *str_Value = @"";
        if( [[params objectForKey:str_Key] isKindOfClass:[NSString class]] )
        {
            str_Value = [params objectForKey:str_Key];
        }
        else if( [[params objectForKey:str_Key] isKindOfClass:[NSNumber class]] )
        {
            int nValue = [[params objectForKey:str_Key] intValue];
            str_Value = [NSString stringWithFormat:@"%d", nValue];
        }
        [strM_Url appendString:str_Key];
        [strM_Url appendString:@"="];
        [strM_Url appendString:str_Value];
        [strM_Url appendString:@"&"];
    }
    
    return [NSURL URLWithString:strM_Url];
}

//파리바게뜨 가맹대표 로그인
- (void)callOwnerLoginWebAPIBlock:(NSMutableDictionary *)params withBlock:(void(^)(id resulte, NSError *error))completion
{
    //http://school.paris.co.kr:8181/API/Code_Select.asp?UpCodeCd=C0000710

    NSString *str_Url = [NSString stringWithFormat:@"http://school.paris.co.kr:8181/API/Code_Select.asp?UpCodeCd=%@&UserId=%@&UserPw=%@&PhoneType=%@",
                         [params objectForKey:@"UpCodeCd"],
                         [params objectForKey:@"userId"],
                         [params objectForKey:@"UserPw"],
                         [params objectForKey:@"PhoneType"]
                         ];
    
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:str_Url]];
    NSURLResponse * response = nil;
    NSError * error = nil;
    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
                                          returningResponse:&response
                                                      error:&error];
    
    if( error )
    {
        completion(nil, error);
    }
    else
    {
        // Parse data here
        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        NSMutableDictionary *dicM_Result = (NSMutableDictionary *)[jsonParser objectWithString:dataString];

        int nRep = [[dicM_Result objectForKey:@"ResultCd"] intValue];
        if( nRep == 1 )
        {
            //BrandChange
            completion(dicM_Result, nil);
        }
        else
        {
            //error
            if( [[dicM_Result objectForKey:@"ResultMsg"] length] > 0 )
            {
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                [window makeToast:[dicM_Result objectForKey:@"ResultMsg"] withPosition:kPositionCenter];
            }
            
            completion(nil, nil);
        }
    }
}

////HIM/드림어스 회원인증
//- (void)callHimDreamAuthWebAPIBlock:(NSMutableDictionary *)params withBlock:(void(^)(id resulte, NSError *error))completion
//{
//    NSString *str_Url = [NSString stringWithFormat:@"http://academy.aritaum.com/library/json/jick_auth.php?gubun=%@&userid=%@&name=%@",
//     [params objectForKey:@"gubun"],
//     [params objectForKey:@"userId"],
//     [params objectForKey:@"name"]];
//    
//    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:str_Url]];
//    NSURLResponse * response = nil;
//    NSError * error = nil;
//    NSData * data = [NSURLConnection sendSynchronousRequest:urlRequest
//                                          returningResponse:&response
//                                                      error:&error];
//    
//    if (error == nil)
//    {
//        // Parse data here
//    }
//
//    
//    //    [self addDefaultParams:params];
//    
////    AFHTTPClient *authClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://academy.aritaum.com/library/json/jick_auth.php"]];
////    [authClient registerHTTPOperationClass:[AFJSONRequestOperation class]];
////
////    [client getPath:@"" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
////        
////        NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
////        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
////        NSMutableDictionary *dicM_Result = (NSMutableDictionary *)[jsonParser objectWithString:dataString];
////        
//////        int nRep = [[dicM_Result objectForKey:@"ResultCd"] intValue];
//////        if( nRep != 1 )
//////        {
//////            if( [path isEqualToString:@"member_userid_select.asp"] )
//////            {
//////                
//////            }
//////            else
//////            {
//////                UIAlertView *alert = CREATE_ALERT(nil, [dicM_Result objectForKey:@"ResultMsg"], @"확인", nil);
//////                [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//////                    
//////                }];
//////            }
//////            
//////            completion(nil, nil);
//////        }
//////        else
//////        {
//////            NSLog(@"%@", [dicM_Result objectForKey:@"ResultMsg"]);
//////            
//////            if( [dicM_Result objectForKey:@"Item"] )
//////            {
//////                completion([dicM_Result objectForKey:@"Item"], nil);
//////            }
//////            else
//////            {
//////                completion([NSArray array], nil);
//////            }
//////        }
//////        //        http://academy.aritaum.com/api/member_login.asp?UserId=test2&UserPw=test2222&PhoneType=IOS&UDID=a092f3aad2d92a4d3749de6189b13df99242c04809441f7715727bd9ee85d445
//////        //API에 에러코드가 없을시
//////        NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@%@?", kBaseUrl, str_PostPath];
//////        NSArray *ar_AllKeys = [params allKeys];
//////        for( int i = 0; i < [ar_AllKeys count]; i++ )
//////        {
//////            NSString *str_Key = [ar_AllKeys objectAtIndex:i];
//////            NSString *str_Val = [params objectForKey:str_Key];
//////            [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
//////        }
//////        //        [strM_CallUrl appendString:@"debug=1"];
//////        
//////        NSLog(@"%@", strM_CallUrl);
////        
////    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
////        
////        ALERT(nil, @"NetworkError", nil, @"확인", nil);
////        
////        completion(nil, error);
////    }];
//}
////http://academy.aritaum.com/library/json/jick_auth.php?gubun=C0000157&userid=test2&name=테스터2
//



- (void)callAsyncWebAPIBlock:(NSString *)path param:(NSMutableDictionary *)params indicatorShow:(BOOL)isIndicatorShow withBlock:(void(^)(id resulte, NSError *error))completion
{
    if( isIndicatorShow )
    {
        [MBProgressHUD show];
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString *str_PostPath = [NSString stringWithFormat:@"/%@", path];
    
    [client postPath:str_PostPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        nRetry = 0;
        
        NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        id dicM_Result = [jsonParser objectWithString:dataString];
        
        completion(dicM_Result, nil);
        
        [MBProgressHUD hide];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        //        int nRep = [[dicM_Result objectForKey:@"ResultCd"] intValue];
        //        if( nRep == 1 )
        //        {
        //            completion(dicM_Result, nil);
        //        }
        //        else
        //        {
        //            //BrandChange
        //
        //            //error
        //            if( [[dicM_Result objectForKey:@"ResultMsg"] length] > 0 )
        //            {
        //                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        //                [window makeToast:[dicM_Result objectForKey:@"ResultMsg"] withPosition:kPositionCenter];
        //            }
        //
        //            completion(nil, nil);
        //        }
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
     
        [MBProgressHUD hide];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

        if( operation.cancelled )
        {
            return ;
        }

        //중복된 팝업을 방지하기 위한 코드
        static BOOL isNowShowPopup = NO;
        
        if( nRetry < kRetryCount )
        {
            NSLog(@"@@@@@@@@@@@RETRY@@@@@@@@@@");
            [self callAsyncWebAPIBlock:path param:params indicatorShow:isIndicatorShow withBlock:^(id resulte, NSError *error) {
                
            }];
        }
        else
        {
            UIWindow *window = [[UIApplication sharedApplication] keyWindow];
            [window makeToast:@"NetworkError"];
            
            if( !isNowShowPopup )
            {
                isNowShowPopup = YES;
                
//                UIAlertView *alert = CREATE_ALERT(nil, [operation.request.URL absoluteString], @"확인", nil);
//                [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                    if( buttonIndex == 0 )
//                    {
//                        isNowShowPopup = NO;
//                    }
//                }];
                
                isNowShowPopup = NO;
            }
            
            completion(nil, error);
            
            nRetry = 0;
        }
        
        nRetry++;
    }];
    
    NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@%@?", kBaseUrl, str_PostPath];
    NSArray *ar_AllKeys = [params allKeys];
    for( int i = 0; i < [ar_AllKeys count]; i++ )
    {
        NSString *str_Key = [ar_AllKeys objectAtIndex:i];
        NSString *str_Val = [params objectForKey:str_Key];
        [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
    }
    
    if( [strM_CallUrl hasSuffix:@"&"] )
    {
        [strM_CallUrl deleteCharactersInRange:NSMakeRange([strM_CallUrl length]-1, 1)];
    }
    
    NSLog(@"%@", strM_CallUrl);
}

- (void)callAsyncWebAPIBlock:(NSString *)path param:(NSMutableDictionary *)params withMethod:(NSString *)aMethod withIndicator:(BOOL)isIndicaror withBlock:(void(^)(id resulte, NSError *error))completion
{
    [MBProgressHUD hide];
    
    if( [aMethod isEqualToString:@"POST"] )
    {
        if( [path isEqualToString:@"v1/add/reply/question"] == NO && [path isEqualToString:@"v1/get/exam/question/files/info"] == NO && [path isEqualToString:@"v1/add/reply/question/and/view"] == NO )
        {
//            [MBProgressHUD show];
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        NSString *str_PostPath = [NSString stringWithFormat:@"/api/%@", path];
        
        [client postPath:str_PostPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            nRetry = 0;
            
            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            id dicM_Result = [jsonParser objectWithString:dataString];
            
            completion(dicM_Result, nil);
            
            [MBProgressHUD hide];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
            [MBProgressHUD hide];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

            if( operation.cancelled )
            {
                return ;
            }

            //중복된 팝업을 방지하기 위한 코드
            static BOOL isNowShowPopup = NO;
            
            if( nRetry < kRetryCount )
            {
                NSLog(@"@@@@@@@@@@@RETRY@@@@@@@@@@");
                [self callAsyncWebAPIBlock:path param:params withMethod:aMethod withBlock:^(id resulte, NSError *error) {
                    
                }];
            }
            else
            {
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                [window makeToast:@"NetworkError"];
                
                if( !isNowShowPopup )
                {
                    isNowShowPopup = YES;
                    
//                    UIAlertView *alert = CREATE_ALERT(nil, [operation.request.URL absoluteString], @"확인", nil);
//                    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                        if( buttonIndex == 0 )
//                        {
//                            isNowShowPopup = NO;
//                        }
//                    }];
                    
                    isNowShowPopup = NO;
                }
                
                completion(nil, error);
                
                nRetry = 0;
            }
            
            nRetry++;
        }];
        
        NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@%@?", kBaseUrl, str_PostPath];
        NSArray *ar_AllKeys = [params allKeys];
        for( int i = 0; i < [ar_AllKeys count]; i++ )
        {
            NSString *str_Key = [ar_AllKeys objectAtIndex:i];
            NSString *str_Val = [params objectForKey:str_Key];
            [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
        }
        
        if( [strM_CallUrl hasSuffix:@"&"] )
        {
            [strM_CallUrl deleteCharactersInRange:NSMakeRange([strM_CallUrl length]-1, 1)];
        }
        
        NSLog(@"%@", strM_CallUrl);
    }
    else if( [aMethod isEqualToString:@"GET"] )
    {
        if( [path isEqualToString:@"v1/add/reply/question"] == NO && [path isEqualToString:@"v1/get/exam/question/files/info"] == NO )
        {
//            [MBProgressHUD show];
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        NSString *str_PostPath = [NSString stringWithFormat:@"/api/%@", path];
        
        [client getPath:str_PostPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            nRetry = 0;

            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            id dicM_Result = [jsonParser objectWithString:dataString];
            
            completion(dicM_Result, nil);
            
            [MBProgressHUD hide];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
            [MBProgressHUD hide];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

            if( operation.cancelled )
            {
                return ;
            }

            //중복된 팝업을 방지하기 위한 코드
            static BOOL isNowShowPopup = NO;
            
            if( nRetry < kRetryCount )
            {
                NSLog(@"@@@@@@@@@@@RETRY@@@@@@@@@@");
                [self callAsyncWebAPIBlock:path param:params withMethod:aMethod withBlock:^(id resulte, NSError *error) {
                    
                }];
            }
            else if( !isNowShowPopup )
            {
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                [window makeToast:@"NetworkError"];
                
                if( !isNowShowPopup )
                {
                    isNowShowPopup = YES;
                    
//                    UIAlertView *alert = CREATE_ALERT(nil, [operation.request.URL absoluteString], @"확인", nil);
//                    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                        if( buttonIndex == 0 )
//                        {
//                            isNowShowPopup = NO;
//                        }
//                    }];
                    
                    isNowShowPopup = NO;
                }
                
                nRetry = 0;
                
                completion(nil, error);
            }
            
            nRetry++;
        }];
        
        NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@%@?", kBaseUrl, str_PostPath];
        NSArray *ar_AllKeys = [params allKeys];
        for( int i = 0; i < [ar_AllKeys count]; i++ )
        {
            NSString *str_Key = [ar_AllKeys objectAtIndex:i];
            NSString *str_Val = [params objectForKey:str_Key];
            [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
        }
        
        if( [strM_CallUrl hasSuffix:@"&"] )
        {
            [strM_CallUrl deleteCharactersInRange:NSMakeRange([strM_CallUrl length]-1, 1)];
        }
        
        NSLog(@"%@", strM_CallUrl);
    }
}

- (void)callAsyncWebAPIBlock:(NSString *)path param:(NSMutableDictionary *)params withMethod:(NSString *)aMethod withBlock:(void(^)(id resulte, NSError *error))completion
{
    //    [self addDefaultParams:params];
    
    NSLog(@"start path : %@", path);
    NSLog(@"getNetworkSatatus : %@", [Util getNetworkSatatus]);

    [MBProgressHUD hide];

    if( [aMethod isEqualToString:@"POST"] )
    {
        if( [path isEqualToString:@"v1/add/reply/question"] == NO && [path isEqualToString:@"v1/get/exam/question/files/info"] == NO && [path isEqualToString:@"v1/add/reply/question/and/view"] == NO )
        {
            [MBProgressHUD show];
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        NSString *str_PostPath = [NSString stringWithFormat:@"/api/%@", path];

        [client postPath:str_PostPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            nRetry = 0;
            
            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            id dicM_Result = [jsonParser objectWithString:dataString];
            
            completion(dicM_Result, nil);
            
            [MBProgressHUD hide];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            NSLog(@"end path : %@", path);
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
            NSLog(@"end path : %@", path);
            
            [MBProgressHUD hide];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

            if( operation.cancelled )
            {
                return ;
            }

//            NSInteger nErrorCode = [operation.response statusCode];

            //중복된 팝업을 방지하기 위한 코드
            static BOOL isNowShowPopup = NO;
            
            if( [path isEqualToString:@"v1/get/dashboard/answer/list"] ||
                [path isEqualToString:@"v1/get/my/manage/channel/list"] ||
               [path isEqualToString:@"v1/get/my/channel/qna/chat/room/list"] ||
               [path isEqualToString:@"v1/get/user/my/upload/exam"] ||
               [path isEqualToString:@"v1/get/exam/question/list"] ||
               [path isEqualToString:@"v1/add/reply/question/and/view"]
               )
            {
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                [window makeToast:@"NetworkError"];
                
                if( !isNowShowPopup )
                {
                    isNowShowPopup = YES;
                    
                    //                    UIAlertView *alert = CREATE_ALERT(nil, [operation.request.URL absoluteString], @"확인", nil);
                    //                    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    //                        if( buttonIndex == 0 )
                    //                        {
                    //                            isNowShowPopup = NO;
                    //                        }
                    //                    }];
                    
                    isNowShowPopup = NO;
                }
                
                nRetry = 0;
                
                completion(nil, error);
                return;
            }
            
            if( nRetry < kRetryCount )
            {
                NSLog(@"@@@@@@@@@@@RETRY@@@@@@@@@@");
                [self callAsyncWebAPIBlock:path param:params withMethod:aMethod withBlock:^(id resulte, NSError *error) {
                    
                }];
            }
            else
            {
                NSLog(@"getNetworkSatatus : %@", [Util getNetworkSatatus]);
                
                NSDictionary *userInfo = [error userInfo];
                NSString *errorString = [[userInfo objectForKey:NSUnderlyingErrorKey] localizedDescription];
                if( [errorString rangeOfString:@"offline"].location != NSNotFound && [Util getNetworkSatatus] == nil )
                {
                    if( [path rangeOfString:@"channel/create"].location != NSNotFound ||
                       [path rangeOfString:@"v1/regist/exam/question/user/answer"].location != NSNotFound )
                    {
                        completion(nil, error);
                        return ;
                    }
                    //오프라인 상태
                    //http://dev2.thoting.com/api/channel/create 채팅방 만들기 (이건 저장 안해도 됨 대신 오프라인에선 쓸 수 없다는 메세지를 보여줘야 할 것 같음)
                    
                    
                    
                    
                    //등록할 것
                    //v1/regist/exam/question/user/answer 사용자가 입력한 답
                    
                    if( [path isEqualToString:@"v1/regist/exam/question/user/answer"] )
                    {
//                        NSMutableDictionary *dicM = [NSMutableDictionary dictionary];
//                        [dicM setObject:aMethod forKey:@"method"];
//                        [dicM setObject:path forKey:@"path"];
//                        [dicM setObject:params forKey:@"params"];
//                        
//                        //                        NSMutableArray *arM = [NSMutableArray array];
//
//                        NSMutableArray *arM = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"OfflineCall"]];
//                        if( arM == nil )
//                        {
//                            arM = [NSMutableArray array];
//                        }
//                        [arM addObject:dicM];
//                        [[NSUserDefaults standardUserDefaults] setObject:arM forKey:@"OfflineCall"];
//                        [[NSUserDefaults standardUserDefaults] synchronize];                        
                    }
                }
                
                
                
                
                
                
                
                
                
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                [window makeToast:@"NetworkError"];
                
                if( !isNowShowPopup )
                {
                    isNowShowPopup = YES;

//                    UIAlertView *alert = CREATE_ALERT(nil, [operation.request.URL absoluteString], @"확인", nil);
//                    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                        if( buttonIndex == 0 )
//                        {
//                            isNowShowPopup = NO;
//                        }
//                    }];
                    
                    isNowShowPopup = NO;
                }
                
                nRetry = 0;
                
                completion(nil, error);
            }
            
            nRetry++;
        }];
        
        NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@%@?", kBaseUrl, str_PostPath];
        NSArray *ar_AllKeys = [params allKeys];
        for( int i = 0; i < [ar_AllKeys count]; i++ )
        {
            NSString *str_Key = [ar_AllKeys objectAtIndex:i];
            NSString *str_Val = [params objectForKey:str_Key];
            [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
        }
        
        if( [strM_CallUrl hasSuffix:@"&"] )
        {
            [strM_CallUrl deleteCharactersInRange:NSMakeRange([strM_CallUrl length]-1, 1)];
        }
        
        NSLog(@"%@", strM_CallUrl);
    }
    else if( [aMethod isEqualToString:@"GET"] )
    {
        if( [path isEqualToString:@"v1/add/reply/question"] == NO && [path isEqualToString:@"v1/get/exam/question/files/info"] == NO &&
           [path isEqualToString:@"v1/get/channel/my"] == NO )
        {
            [MBProgressHUD show];
        }

        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        NSString *str_PostPath = [NSString stringWithFormat:@"/api/%@", path];

        [client getPath:str_PostPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            NSLog(@"end path : %@", path);
            
            nRetry = 0;

            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            id dicM_Result = [jsonParser objectWithString:dataString];
            
            completion(dicM_Result, nil);
            
            [MBProgressHUD hide];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"end path : %@", path);
            
            [MBProgressHUD hide];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

            if( operation.cancelled )
            {
                return ;
            }

            //중복된 팝업을 방지하기 위한 코드
            static BOOL isNowShowPopup = NO;

            if( [path isEqualToString:@"v1/get/dashboard/answer/list"] ||
               [path isEqualToString:@"v1/get/my/manage/channel/list"] ||
               [path isEqualToString:@"v1/get/my/channel/qna/chat/room/list"] ||
               [path isEqualToString:@"v1/get/user/my/upload/exam"] ||
               [path isEqualToString:@"v1/get/exam/question/list"]
               )
            {
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                [window makeToast:@"NetworkError"];
                
                if( !isNowShowPopup )
                {
                    isNowShowPopup = YES;
                    
                    //                    UIAlertView *alert = CREATE_ALERT(nil, [operation.request.URL absoluteString], @"확인", nil);
                    //                    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                    //                        if( buttonIndex == 0 )
                    //                        {
                    //                            isNowShowPopup = NO;
                    //                        }
                    //                    }];
                    
                    isNowShowPopup = NO;
                }
                
                nRetry = 0;
                
                completion(nil, error);
                return;
            }


            if( nRetry < kRetryCount )
            {
                NSLog(@"@@@@@@@@@@@RETRY@@@@@@@@@@");
                [self callAsyncWebAPIBlock:path param:params withMethod:aMethod withBlock:^(id resulte, NSError *error) {
                    
                }];
            }
            else if( !isNowShowPopup )
            {
                
                
                
                
                
                
                
                
                
                
                NSLog(@"getNetworkSatatus : %@", [Util getNetworkSatatus]);
                
                NSDictionary *userInfo = [error userInfo];
                NSString *errorString = [[userInfo objectForKey:NSUnderlyingErrorKey] localizedDescription];
                if( [errorString rangeOfString:@"offline"].location != NSNotFound && [Util getNetworkSatatus] == nil )
                {
                    //오프라인 상태
                    //v1/get/exam/question/explain/list => 문제풀이 리스트 (이건 저장 안해도 됨)
                    //v1/get/channel/user/list => 채널 팔로워, 회원, 관리자 리스트 (이것도 저장 안해도 됨)
                    
                    if( [path rangeOfString:@"v1/get/exam/question/explain/list"].location != NSNotFound ||
                       [path rangeOfString:@"v1/get/channel/user/list"].location != NSNotFound ||
                       [path rangeOfString:@"v1/get/exam/question/qna/list"].location != NSNotFound ||
                       [path rangeOfString:@"v1/get/exam/question/list"].location != NSNotFound
                       )
                    {
                        completion(nil, error);
                        return ;
                    }
                }

                
                
                
                
                
                
                
                
                
                
                
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                [window makeToast:@"NetworkError"];
                
                if( !isNowShowPopup )
                {
                    isNowShowPopup = YES;
                    
//                    UIAlertView *alert = CREATE_ALERT(nil, [operation.request.URL absoluteString], @"확인", nil);
//                    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                        if( buttonIndex == 0 )
//                        {
//                            isNowShowPopup = NO;
//                        }
//                    }];
                    isNowShowPopup = NO;
                }

                nRetry = 0;
                
                completion(nil, error);
            }
            
            nRetry++;
        }];
        
        NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@%@?", kBaseUrl, str_PostPath];
        NSArray *ar_AllKeys = [params allKeys];
        for( int i = 0; i < [ar_AllKeys count]; i++ )
        {
            NSString *str_Key = [ar_AllKeys objectAtIndex:i];
            NSString *str_Val = [params objectForKey:str_Key];
            [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
        }
        
        if( [strM_CallUrl hasSuffix:@"&"] )
        {
            [strM_CallUrl deleteCharactersInRange:NSMakeRange([strM_CallUrl length]-1, 1)];
        }
        
        NSLog(@"%@", strM_CallUrl);
    }
}

- (void)callAsyncSendBirdAPIBlock:(NSString *)path param:(NSMutableDictionary *)params withMethod:(NSString *)aMethod withBlock:(void(^)(id resulte, NSError *error))completion
{
    //    [self addDefaultParams:params];
    
    [MBProgressHUD hide];
    
    if( [aMethod isEqualToString:@"POST"] )
    {
//        [MBProgressHUD show];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        [sendBirdclient postPath:path parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            nRetry = 0;

//            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
//            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
//            id dicM_Result = [jsonParser objectWithString:dataString];
            
            completion(responseObject, nil);
            
            [MBProgressHUD hide];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
            [MBProgressHUD hide];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

            if( operation.cancelled )
            {
                return ;
            }

            //중복된 팝업을 방지하기 위한 코드
            static BOOL isNowShowPopup = NO;
            
//            if( nRetry < kRetryCount )
//            {
//                NSLog(@"@@@@@@@@@@@RETRY@@@@@@@@@@");
//                [self callAsyncWebAPIBlock:path param:params withMethod:aMethod withBlock:^(id resulte, NSError *error) {
//                    
//                }];
//            }
//            else if( !isNowShowPopup )
            if( 1 )
            {
                NSDictionary *userInfo = [error userInfo];
                NSString *errorString = [[userInfo objectForKey:NSUnderlyingErrorKey] localizedDescription];
                if( [errorString rangeOfString:@"offline"].location != NSNotFound && [Util getNetworkSatatus] == nil )
                {
                    //오프라인 상태
                    completion(nil, error);
                    return ;
                }
                
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                [window makeToast:@"NetworkError"];
                
                if( !isNowShowPopup )
                {
                    isNowShowPopup = YES;
                    
//                    UIAlertView *alert = CREATE_ALERT(nil, [operation.request.URL absoluteString], @"확인", nil);
//                    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                        if( buttonIndex == 0 )
//                        {
//                            isNowShowPopup = NO;
//                        }
//                    }];
                    
                    isNowShowPopup = NO;
                }
                
                nRetry = 0;
                
                completion(nil, error);
            }
            
            nRetry++;
        }];
        
        NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@%@?", kBaseUrl, params];
        NSArray *ar_AllKeys = [params allKeys];
        for( int i = 0; i < [ar_AllKeys count]; i++ )
        {
            NSString *str_Key = [ar_AllKeys objectAtIndex:i];
            NSString *str_Val = [params objectForKey:str_Key];
            [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
        }
        
        if( [strM_CallUrl hasSuffix:@"&"] )
        {
            [strM_CallUrl deleteCharactersInRange:NSMakeRange([strM_CallUrl length]-1, 1)];
        }
        
        NSLog(@"%@", strM_CallUrl);
    }
    else if( [aMethod isEqualToString:@"GET"] )
    {
//        [MBProgressHUD show];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        NSString *str_PostPath = [NSString stringWithFormat:@"/api/%@", path];
        
        [sendBirdclient getPath:str_PostPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            nRetry = 0;

            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            id dicM_Result = [jsonParser objectWithString:dataString];
            
            completion(dicM_Result, nil);
            
            [MBProgressHUD hide];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
            [MBProgressHUD hide];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

            if( operation.cancelled )
            {
                return ;
            }

            //중복된 팝업을 방지하기 위한 코드
            static BOOL isNowShowPopup = NO;
            
            if( nRetry < kRetryCount )
            {
                NSLog(@"@@@@@@@@@@@RETRY@@@@@@@@@@");
                [self callAsyncWebAPIBlock:path param:params withMethod:aMethod withBlock:^(id resulte, NSError *error) {
                    
                }];
            }
            else if( !isNowShowPopup )
            {
                NSDictionary *userInfo = [error userInfo];
                NSString *errorString = [[userInfo objectForKey:NSUnderlyingErrorKey] localizedDescription];
                if( [errorString rangeOfString:@"offline"].location != NSNotFound && [Util getNetworkSatatus] == nil )
                {
                    //오프라인 상태
                    completion(nil, error);
                    return ;
                }

                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                [window makeToast:@"NetworkError"];
                
                if( !isNowShowPopup )
                {
                    isNowShowPopup = YES;
                    
//                    UIAlertView *alert = CREATE_ALERT(nil, [operation.request.URL absoluteString], @"확인", nil);
//                    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                        if( buttonIndex == 0 )
//                        {
//                            isNowShowPopup = NO;
//                        }
//                    }];
                    
                    isNowShowPopup = NO;
                }
                
                nRetry = 0;
                
                completion(nil, error);
            }
            
            nRetry++;
        }];
        
        NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"https://api.sendbird.com%@?", str_PostPath];
        NSArray *ar_AllKeys = [params allKeys];
        for( int i = 0; i < [ar_AllKeys count]; i++ )
        {
            NSString *str_Key = [ar_AllKeys objectAtIndex:i];
            NSString *str_Val = [params objectForKey:str_Key];
            [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
        }
        
        if( [strM_CallUrl hasSuffix:@"&"] )
        {
            [strM_CallUrl deleteCharactersInRange:NSMakeRange([strM_CallUrl length]-1, 1)];
        }
        
        NSLog(@"%@", strM_CallUrl);
    }
}

- (void)callAsyncWebAPIBlock:(NSString *)path param:(NSMutableDictionary *)params withMethod:(NSString *)aMethod withShowIndicator:(BOOL)isShowIndicato withBlock:(void(^)(id resulte, NSError *error))completion
{
    //    [self addDefaultParams:params];
    
    [MBProgressHUD hide];
    
    if( [aMethod isEqualToString:@"POST"] )
    {
        if( isShowIndicato )
        {
            [MBProgressHUD show];
        }
        
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        NSString *str_PostPath = [NSString stringWithFormat:@"/api/%@", path];
        
        [client postPath:str_PostPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            nRetry = 0;

            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            id dicM_Result = [jsonParser objectWithString:dataString];
            
            completion(dicM_Result, nil);
            
            [MBProgressHUD hide];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
            [MBProgressHUD hide];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

            if( operation.cancelled )
            {
                return ;
            }

            //중복된 팝업을 방지하기 위한 코드
            static BOOL isNowShowPopup = NO;
            
            if( nRetry < kRetryCount )
            {
                NSLog(@"@@@@@@@@@@@RETRY@@@@@@@@@@");
                [self callAsyncWebAPIBlock:path param:params withMethod:aMethod withBlock:^(id resulte, NSError *error) {
                    
                }];
            }
            else if( !isNowShowPopup )
            {
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                [window makeToast:@"NetworkError"];
                
                if( !isNowShowPopup )
                {
                    isNowShowPopup = YES;
                    
//                    UIAlertView *alert = CREATE_ALERT(nil, [operation.request.URL absoluteString], @"확인", nil);
//                    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                        if( buttonIndex == 0 )
//                        {
//                            isNowShowPopup = NO;
//                        }
//                    }];
                    
                    isNowShowPopup = NO;
                }
                
                nRetry = 0;
                
                completion(nil, error);
            }
            
            nRetry++;
        }];
        
        NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@%@?", kBaseUrl, str_PostPath];
        NSArray *ar_AllKeys = [params allKeys];
        for( int i = 0; i < [ar_AllKeys count]; i++ )
        {
            NSString *str_Key = [ar_AllKeys objectAtIndex:i];
            NSString *str_Val = [params objectForKey:str_Key];
            [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
        }
        
        if( [strM_CallUrl hasSuffix:@"&"] )
        {
            [strM_CallUrl deleteCharactersInRange:NSMakeRange([strM_CallUrl length]-1, 1)];
        }
        
        NSLog(@"%@", strM_CallUrl);
    }
    else if( [aMethod isEqualToString:@"GET"] )
    {
        if( isShowIndicato )
        {
            [MBProgressHUD show];
        }

        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
        
        NSString *str_PostPath = [NSString stringWithFormat:@"/api/%@", path];
        
        [client getPath:str_PostPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            nRetry = 0;

            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            id dicM_Result = [jsonParser objectWithString:dataString];
            
            completion(dicM_Result, nil);
            
            [MBProgressHUD hide];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
            [MBProgressHUD hide];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

            if( operation.cancelled )
            {
                return ;
            }

            //중복된 팝업을 방지하기 위한 코드
            static BOOL isNowShowPopup = NO;
            
            if( nRetry < kRetryCount )
            {
                NSLog(@"@@@@@@@@@@@RETRY@@@@@@@@@@");
                [self callAsyncWebAPIBlock:path param:params withMethod:aMethod withBlock:^(id resulte, NSError *error) {
                    
                }];
            }
            else if( !isNowShowPopup )
            {
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                [window makeToast:@"NetworkError"];
                
                if( !isNowShowPopup )
                {
                    isNowShowPopup = YES;
                    
//                    UIAlertView *alert = CREATE_ALERT(nil, [operation.request.URL absoluteString], @"확인", nil);
//                    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                        if( buttonIndex == 0 )
//                        {
//                            isNowShowPopup = NO;
//                        }
//                    }];
                    
                    isNowShowPopup = NO;
                }
                
                nRetry = 0;
                
                completion(nil, error);
            }
            
            nRetry++;
        }];
        
        NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@%@?", kBaseUrl, str_PostPath];
        NSArray *ar_AllKeys = [params allKeys];
        for( int i = 0; i < [ar_AllKeys count]; i++ )
        {
            NSString *str_Key = [ar_AllKeys objectAtIndex:i];
            NSString *str_Val = [params objectForKey:str_Key];
            [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
        }
        
        if( [strM_CallUrl hasSuffix:@"&"] )
        {
            [strM_CallUrl deleteCharactersInRange:NSMakeRange([strM_CallUrl length]-1, 1)];
        }
        
        NSLog(@"%@", strM_CallUrl);
    }
}

- (void)callSyncWebAPIBlock:(NSString *)path param:(NSMutableDictionary *)params withMethod:(NSString *)aMethod withBlock:(void(^)(id resulte, NSError *error))completion
{
    [MBProgressHUD hide];

    __block BOOL isFinish = NO;
    __block BOOL isSuccess = NO;
    __block NSMutableDictionary *dicM_Result = nil;
    __block NSError *err = nil;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString *str_PostPath = [NSString stringWithFormat:@"/api/%@", path];
    
    if( [aMethod isEqualToString:@"POST"] )
    {
        [client postPath:str_PostPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            nRetry = 0;

            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            dicM_Result = [jsonParser objectWithString:dataString];
            
            [MBProgressHUD hide];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

            isSuccess = YES;
            isFinish = YES;
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
            [MBProgressHUD hide];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

            if( operation.cancelled )
            {
                return ;
            }

            //중복된 팝업을 방지하기 위한 코드
            static BOOL isNowShowPopup = NO;
            
            if( nRetry < kRetryCount )
            {
                NSLog(@"@@@@@@@@@@@RETRY@@@@@@@@@@");
                [self callSyncWebAPIBlock:path param:params withMethod:aMethod withBlock:^(id resulte, NSError *error) {
                    
                }];
            }
            else if( !isNowShowPopup )
            {
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                [window makeToast:@"NetworkError"];
                
                if( !isNowShowPopup )
                {
                    isNowShowPopup = YES;
                    
//                    UIAlertView *alert = CREATE_ALERT(nil, [operation.request.URL absoluteString], @"확인", nil);
//                    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                        if( buttonIndex == 0 )
//                        {
//                            isNowShowPopup = NO;
//                        }
//                    }];
                    
                    isNowShowPopup = NO;
                }
                
                nRetry = 0;
                isFinish = YES;
                err = error;
            }
            
            nRetry++;
        }];
    }
    else
    {
        [client getPath:str_PostPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            nRetry = 0;
            
            NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
            SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
            dicM_Result = [jsonParser objectWithString:dataString];
            
            [MBProgressHUD hide];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
            
            isSuccess = YES;
            isFinish = YES;
            
        }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         
            [MBProgressHUD hide];
            [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];

            if( operation.cancelled )
            {
                return ;
            }

            //중복된 팝업을 방지하기 위한 코드
            static BOOL isNowShowPopup = NO;
            
            if( nRetry < kRetryCount )
            {
                NSLog(@"@@@@@@@@@@@RETRY@@@@@@@@@@");
                [self callSyncWebAPIBlock:path param:params withMethod:aMethod withBlock:^(id resulte, NSError *error) {
                    
                }];
            }
            else if( !isNowShowPopup )
            {
                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                [window makeToast:@"NetworkError"];
                
                if( !isNowShowPopup )
                {
                    isNowShowPopup = YES;
                    
//                    UIAlertView *alert = CREATE_ALERT(nil, [operation.request.URL absoluteString], @"확인", nil);
//                    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                        if( buttonIndex == 0 )
//                        {
//                            isNowShowPopup = NO;
//                        }
//                    }];
                    
                    isNowShowPopup = NO;
                }
                
                nRetry = 0;
                isFinish = YES;
                err = error;
            }
            
            nRetry++;
        }];
    }

    
    NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@%@?", kBaseUrl, str_PostPath];
    NSArray *ar_AllKeys = [params allKeys];
    for( int i = 0; i < [ar_AllKeys count]; i++ )
    {
        NSString *str_Key = [ar_AllKeys objectAtIndex:i];
        NSString *str_Val = [params objectForKey:str_Key];
        [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
    }
    
    if( [strM_CallUrl hasSuffix:@"&"] )
    {
        [strM_CallUrl deleteCharactersInRange:NSMakeRange([strM_CallUrl length]-1, 1)];
    }
    
    NSLog(@"%@", strM_CallUrl);
    
    
    
    while (!isFinish && [[NSRunLoop mainRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]])
    {
        NSLog(@"Wait");
    }
    
    if( isSuccess )
    {
        completion(dicM_Result, nil);
    }
    else
    {
        completion(nil, err);
    }
}

- (void)getAppStoreInfo:(void(^)(id resulte, NSError *error))completion
{
    [MBProgressHUD show];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionary];
    [dicM_Params setObject:kAppStoreId forKey:@"id"];

    [appStoreclient postPath:@"lookup" parameters:dicM_Params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        id dicM_Result = [jsonParser objectWithString:dataString];
        
        completion(dicM_Result, nil);
        
        [MBProgressHUD hide];
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [MBProgressHUD hide];
     
        if( operation.cancelled )
        {
            return ;
        }

        //중복된 팝업을 방지하기 위한 코드
        static BOOL isNowShowPopup = NO;
        
        if( !isNowShowPopup )
        {
            isNowShowPopup = YES;
            
            UIAlertView *alert = CREATE_ALERT(nil, @"NetworkError", @"확인", nil);
            [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                if( buttonIndex == 0 )
                {
                    isNowShowPopup = NO;
                }
            }];
        }
        
        completion(nil, error);
    }];
    
//    NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@%@?", kBaseUrl, str_PostPath];
//    NSArray *ar_AllKeys = [params allKeys];
//    for( int i = 0; i < [ar_AllKeys count]; i++ )
//    {
//        NSString *str_Key = [ar_AllKeys objectAtIndex:i];
//        NSString *str_Val = [params objectForKey:str_Key];
//        [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
//    }
//    
//    if( [strM_CallUrl hasSuffix:@"&"] )
//    {
//        [strM_CallUrl deleteCharactersInRange:NSMakeRange([strM_CallUrl length]-1, 1)];
//    }
//    
//    NSLog(@"%@", strM_CallUrl);
}

- (void)cancelMethod:(NSString *)aMethod withPath:(NSString *)aPath
{
    [client cancelAllHTTPOperationsWithMethod:aMethod path:aPath];
}


- (void)callPushGCM:(NSString *)path param:(NSMutableDictionary *)params withMethod:(NSString *)aMethod withBlock:(void(^)(id resulte, NSError *error))completion
{
    //    [self addDefaultParams:params];
    
    [MBProgressHUD hide];
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    NSString *str_PostPath = @"/thoting_manager/sendQnaNotificationAllMember.php";
    
    [pushClient getPath:str_PostPath parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        NSString *dataString = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
        id dicM_Result = [jsonParser objectWithString:dataString];
        
        completion(dicM_Result, nil);
        
        [MBProgressHUD hide];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
    }failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        
        [MBProgressHUD hide];
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        completion(nil, error);
    }];
    
    NSMutableString *strM_CallUrl = [NSMutableString stringWithFormat:@"%@%@?", pushClient.baseURL, str_PostPath];
    NSArray *ar_AllKeys = [params allKeys];
    for( int i = 0; i < [ar_AllKeys count]; i++ )
    {
        NSString *str_Key = [ar_AllKeys objectAtIndex:i];
        NSString *str_Val = [params objectForKey:str_Key];
        [strM_CallUrl appendString:[NSString stringWithFormat:@"%@=%@&", str_Key, str_Val]];
    }
    
    if( [strM_CallUrl hasSuffix:@"&"] )
    {
        [strM_CallUrl deleteCharactersInRange:NSMakeRange([strM_CallUrl length]-1, 1)];
    }
    
    NSLog(@"%@", strM_CallUrl);
}

@end
