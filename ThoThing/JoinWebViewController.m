//
//  JoinWebViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 12..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "JoinWebViewController.h"

@interface JoinWebViewController ()
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@end

@implementation JoinWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSString *str_Url = [NSString stringWithFormat:@"%@/api/v1/signup/form", kBaseUrl];
    NSURL *url = [NSURL URLWithString:str_Url];
//    NSString *body = [NSString stringWithFormat: @"email=%@&password=%@",
//                      [[NSUserDefaults standardUserDefaults] objectForKey:@"email"],
//                      [[NSUserDefaults standardUserDefaults] objectForKey:@"password"]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
    [request setHTTPMethod:@"GET"];
//    [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
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
//    NSString *str_Url = [webView.request.URL absoluteString];
//    if ([str_Url rangeOfString:@"Login"].location != NSNotFound)
//    {
//        //http://61.111.12.53:8008/Exam/group_inc/29?groupName={인코딩된그룹명}
//        
//        NSString *str_Url = [NSString stringWithFormat:@"http://ui.thoting.com/Exam/group_inc/%@", self.str_Idx];
//        NSURL *url = [NSURL URLWithString: str_Url];
//        NSString *body = [NSString stringWithFormat:@"groupName=%@", self.str_GroupName];
//        NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
//        [request setHTTPMethod: @"POST"];
//        [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
//        [self.webView loadRequest: request];
//    }
//    else
//    {
//        self.webView.hidden = NO;
//    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if( [[[request URL] absoluteString] hasPrefix:@"thoting://"] )
    {
        NSString *jsData = [[request URL] absoluteString];
        NSArray *ar_Sep = [jsData componentsSeparatedByString:@"thoting://"];
        if( ar_Sep.count > 1 )
        {
            NSString *jsString = [ar_Sep objectAtIndex:1];
            NSRange range = [jsString rangeOfString:@"login"];
            if (range.location != NSNotFound)
            {
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }
            
            range = [jsString rangeOfString:@"cancel"];
            if (range.location != NSNotFound)
            {
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }

            range = [jsString rangeOfString:@"close"];
            if (range.location != NSNotFound)
            {
                [self dismissViewControllerAnimated:YES completion:^{
                    
                }];
            }

            return YES;
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
