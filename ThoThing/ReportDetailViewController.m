//
//  ReportDetailViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 11..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "ReportDetailViewController.h"

@interface ReportDetailViewController ()
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@end

@implementation ReportDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //61.111.12.53:8008/Login/p
    //examId
    //http://61.111.12.53:8008/report/exam/40
    
//    [self initNaviWithTitle:self.str_Title withLeftItem:[self leftBackBlackMenuBarButtonItem] withRightItem:nil withHexColor:@"F8F8F8"];

    self.webView.hidden = YES;
    
//    NSURL *url = [NSURL URLWithString: @"http://ui.thoting.com/Login/p"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/Login/p", kWebBaseUrl]];

    NSString *body = [NSString stringWithFormat: @"email=%@&password=%@",
                      [[NSUserDefaults standardUserDefaults] objectForKey:@"email"],
                      [[NSUserDefaults standardUserDefaults] objectForKey:@"password"]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
    [self.webView loadRequest: request];

    
    
//    NSURL *url = [NSURL URLWithString: @"http://61.111.12.53:8008/report/exam"];
//    NSString *body = [NSString stringWithFormat:@"%@", self.str_ExamId];
//    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
//    [request setHTTPMethod: @"POST"];
//    [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
//    [self.webView loadRequest: request];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *str_Url = [webView.request.URL absoluteString];
    if ([str_Url rangeOfString:@"Login"].location != NSNotFound)
    {
//        NSString *str_Url = [NSString stringWithFormat:@"http://ui.thoting.com/report/exam/%@", self.str_ExamId];
//        NSString *str_Url = [NSString stringWithFormat:@"%@/report/exam/%@", kWebBaseUrl, self.str_ExamId];
        NSString *str_Url = [NSString stringWithFormat:@"%@/report/exam/%@?pUserId=%@", kWebBaseUrl, self.str_ExamId, self.str_PUserId];

        NSURL *url = [NSURL URLWithString: str_Url];
//        NSString *body = [NSString stringWithFormat:@"%@", self.str_ExamId];
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:url];
//        NSLog(@"request.timeoutInterval : %f", request.timeoutInterval);
//        [request setTimeoutInterval:120.f];
//        NSLog(@"request.timeoutInterval : %f", request.timeoutInterval);
        [request setHTTPMethod: @"POST"];
//        [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
        [self.webView loadRequest: request];
    }
    else
    {
        self.webView.hidden = NO;
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if( [[[request URL] absoluteString] hasPrefix:@"toapp://"] )
    {
        /*
         toapp://cmd?status=certi&name=%EA%B9%80%EC%98%81%EB%AF%BC&di=MC0GCCqGSIb3DQIJAyEA8yLrthJEsPv3mIOU9rQe1ok//b6glOigDEVcKgKhyuc=&ci=h5TWaf7/ebL8ZwtpKnS1sQP+yl5tiIL0ckIVcyTGDHYqTH1xPrM9hI4DFarJqC1ARD+K1SejJ3uS84hhgkAf4w==&hp=01097185879&occu=C0000382
         */
        
        NSString *jsData = [[request URL] absoluteString];
        NSArray *ar_Cert = [jsData componentsSeparatedByString:@"toapp://cmd?status=certi&"];
        if( ar_Cert.count > 1 )
        {
            NSString *str = [[ar_Cert objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            
            NSArray *ar_Sep = [str componentsSeparatedByString:@"&"];
            NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithCapacity:ar_Sep.count];
            for( NSString *str in ar_Sep )
            {
                NSArray *ar = [str componentsSeparatedByString:@"="];
                [dicM setValue:[ar objectAtIndex:1] forKey:[ar objectAtIndex:0]];
            }
            
            //            if( [self.delegate respondsToSelector:@selector(cerFinished:)] )
            //            {
            //                [self dismissViewControllerAnimated:YES
            //                                         completion:^{
            //
            //                                             [self.delegate cerFinished:dicM];
            //                                         }];
            //
            //                //                [self.navigationController popViewControllerAnimated:NO];
            //                return YES;
            //            }
        }
        
        
        NSArray *jsDataArray = [jsData componentsSeparatedByString:@"toapp://"];
        
        //        //1보다크면 무조건 팝!!
        //        if( [jsDataArray count] > 1 )
        //        {
        //            [self.navigationController popViewControllerAnimated:YES];
        //            return YES;
        //        }
        
        NSString *jsString = [jsDataArray objectAtIndex:1]; //jsString == @"call objective-c from javascript"
        
        NSRange range = [jsString rangeOfString:@"CLOSE"];
        if (range.location != NSNotFound)
        {
            [self dismissViewControllerAnimated:YES completion:^{
                
                [self.navigationController popViewControllerAnimated:YES];
            }];
            
            return YES;
        }
        
        NSLog(@"%@", jsString);
        
        //        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"자바스크립트 연동" message:jsString delegate:nil cancelButtonTitle:@"확인" otherButtonTitles:nil];
        //        [alert show];
        
        //        [self callJavaScriptFromObjectiveC];
        //        return NO;
        
    }
    
    return YES;
}


@end
