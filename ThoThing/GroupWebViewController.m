//
//  GroupWebViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 11..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "GroupWebViewController.h"
#import "QuestionContainerViewController.h"

@interface GroupWebViewController ()
{
    BOOL isPushMode;
}
@property (nonatomic, weak) IBOutlet UIButton *btn_Close;
@property (nonatomic, weak) IBOutlet UIWebView *webView;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Bg;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_Top;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_Bottom;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_Left;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_Right;
@end

@implementation GroupWebViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (self.presentingViewController != nil)
    {
        isPushMode = NO;
    }
    else
    {
        isPushMode = YES;
    }

    //61.111.12.53:8008/Login/p
    //examId
    //http://61.111.12.53:8008/report/exam/40
    
    self.webView.hidden = YES;
     
//    NSURL *url = [NSURL URLWithString: @"http://ui.thoting.com/Login/p"];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/Login/p", kWebBaseUrl]];

    NSString *body = [NSString stringWithFormat: @"email=%@&password=%@",
                      [[NSUserDefaults standardUserDefaults] objectForKey:@"email"],
                      [[NSUserDefaults standardUserDefaults] objectForKey:@"password"]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
    [self.webView loadRequest: request];

    if( isPushMode )
    {
        [self initNaviWithTitle:self.str_GroupName withLeftItem:[self leftBackBlackMenuBarButtonItem] withRightItem:nil withColor:[UIColor colorWithHexString:@"F8F8F8"]];

        self.view.backgroundColor = [UIColor whiteColor];
        self.iv_Bg.hidden = YES;
        
        self.btn_Close.hidden = YES;
     
        self.lc_Top.constant = 0;
        self.lc_Bottom.constant = 0;
        self.lc_Left.constant = 0;
        self.lc_Right.constant = 0;
    }
    
//    if( self.isGrupMode )
//    {
//        self.navigationController.navigationBarHidden = NO;
//    }
//    else
//    {
//        self.navigationController.navigationBarHidden = YES;
//    }
}

- (void)leftBackSideMenuButtonPressed:(UIButton *)btn
{
    if( self.isGrupMode )
    {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"NotRefrechNoti" object:nil];
    }
    [self.navigationController popViewControllerAnimated:YES];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentQuestionIdx"];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
    if( self.isGrupMode )
    {
        //http://dev2.thoting.com/api/v1/get/channel/report/orderBy/SolveCount?apiToken=324eae7b81fcf4c1d329e28dbfddd82e&uuid=995977b2-c52e-4bf1-ae3d-70bb09f48559&channelId=5&limitCount=20
        
        NSString *str_Url = [webView.request.URL absoluteString];
        if ([str_Url rangeOfString:@"Login"].location != NSNotFound)
        {
            //http://ui2.thoting.com/Exam/group/7?groupName=
            NSString *str_Url = [NSString stringWithFormat:@"%@/Exam/group_inc/%@", kWebBaseUrl, self.str_Idx];
            NSURL *url = [NSURL URLWithString: str_Url];
            NSString *body = [NSString stringWithFormat:@"groupName=%@", self.str_GroupName];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
            [request setHTTPMethod: @"POST"];
            [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
            [self.webView loadRequest: request];
        }
        else
        {
            self.webView.hidden = NO;
        }
    }
    else
    {
        NSString *str_Url = [webView.request.URL absoluteString];
        if ([str_Url rangeOfString:@"Login"].location != NSNotFound)
        {
            //http://61.111.12.53:8008/Exam/group_inc/29?groupName={인코딩된그룹명}
            
            NSString *str_Url = [NSString stringWithFormat:@"%@/Exam/group_inc/%@", kWebBaseUrl, self.str_Idx];
            NSURL *url = [NSURL URLWithString: str_Url];
            NSString *body = [NSString stringWithFormat:@"groupName=%@", self.str_GroupName];
            NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
            [request setHTTPMethod: @"POST"];
            [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
            [self.webView loadRequest: request];
        }
        else
        {
            self.webView.hidden = NO;
        }
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if( [[[request URL] absoluteString] hasPrefix:@"thoting://"] )
    {
        /*
         toapp://cmd?status=certi&name=%EA%B9%80%EC%98%81%EB%AF%BC&di=MC0GCCqGSIb3DQIJAyEA8yLrthJEsPv3mIOU9rQe1ok//b6glOigDEVcKgKhyuc=&ci=h5TWaf7/ebL8ZwtpKnS1sQP+yl5tiIL0ckIVcyTGDHYqTH1xPrM9hI4DFarJqC1ARD+K1SejJ3uS84hhgkAf4w==&hp=01097185879&occu=C0000382
         */
        
        NSString *jsData = [[request URL] absoluteString];
        NSArray *ar_Sep = [jsData componentsSeparatedByString:@"thoting://exam/"];
        if( ar_Sep.count > 1 )
        {
            if( isPushMode )
            {
                NSString *str = [[ar_Sep objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                str = [str stringByReplacingOccurrencesOfString:@"/" withString:@""];

                QuestionContainerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
                vc.hidesBottomBarWhenPushed = YES;
                vc.str_Idx = str;
                vc.str_StartIdx = @"0";
                [self.navigationController pushViewController:vc animated:YES];
            }
            else
            {
                NSString *str = [[ar_Sep objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                str = [str stringByReplacingOccurrencesOfString:@"/" withString:@""];
                
                [self dismissViewControllerAnimated:YES completion:^{
                    
                    if( self.completionWebBlock )
                    {
                        self.completionWebBlock(str);
                    }
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
