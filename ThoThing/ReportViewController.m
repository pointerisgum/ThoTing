//
//  ReportViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 8. 30..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "ReportViewController.h"
#import "ReportCell.h"
#import "GroupWebViewController.h"
#import "QuestionContainerViewController.h"
#import "ReportDetailViewController.h"

@interface ReportViewController ()
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) NSDictionary *dic_Info;
@property (nonatomic, weak) IBOutlet UISegmentedControl *seg;
@property (nonatomic, weak) IBOutlet UILabel *lb_CurrentQuestionNum;
@property (nonatomic, weak) IBOutlet UILabel *lb_TotalQuestionNum;
@property (nonatomic, weak) IBOutlet UILabel *lb_StartNum;
@property (nonatomic, weak) IBOutlet UILabel *lb_CurrentNum;
@property (nonatomic, weak) IBOutlet UILabel *lb_EndNum;
@property (nonatomic, weak) IBOutlet UILabel *lb_StartDate;
@property (nonatomic, weak) IBOutlet UILabel *lb_CurrentDate;
@property (nonatomic, weak) IBOutlet UILabel *lb_Tab1;
@property (nonatomic, weak) IBOutlet UILabel *lb_Tab2;
@property (nonatomic, weak) IBOutlet UILabel *lb_Tab3;
@property (nonatomic, weak) IBOutlet UILabel *lb_Tab4;
@property (nonatomic, weak) IBOutlet UILabel *lb_Tag;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_GraphWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_CurrentNumX;
@property (nonatomic, weak) IBOutlet UIImageView *iv_GraphLine;

//단원보기
@property (nonatomic, weak) IBOutlet UIView *v_Group;
@property (nonatomic, weak) IBOutlet UIWebView *webView;

//네비뷰
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UIButton *btn_Result;
@property (nonatomic, weak) IBOutlet UIButton *btn_Info;

@end

@implementation ReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = YES;
    
    self.lb_Title.text = self.str_Title;
    
    self.v_Group.hidden = YES;


    if( self.isGroupYn == NO )
    {
//        [self.seg setTitle:@"전체" forSegmentAtIndex:0];
        [self.seg removeSegmentAtIndex:1 animated:NO];
//        self.seg.selectedSegmentIndex = 0;
    }
    self.lb_StartNum.layer.cornerRadius = self.lb_StartNum.frame.size.width/2;
    self.lb_StartNum.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.lb_StartNum.layer.borderWidth = 1.f;

    self.lb_CurrentNum.layer.cornerRadius = self.lb_CurrentNum.frame.size.width/2;
    self.lb_CurrentNum.layer.borderColor = kMainColor.CGColor;
    self.lb_CurrentNum.layer.borderWidth = 2.f;

    self.lb_EndNum.layer.cornerRadius = self.lb_EndNum.frame.size.width/2;
    self.lb_EndNum.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.lb_EndNum.layer.borderWidth = 1.f;

    self.arM_List = [NSMutableArray array];
    
    //★
    
}

- (void)viewDidLayoutSubviews
{
    if( self.dic_Info )
    {
        __block NSInteger nDoneCnt = [[self.dic_Info objectForKey:@"solveQuestionCount"] integerValue];
        __block NSInteger nTotalQuestionCnt = [[self.dic_Info objectForKey:@"questionCount"] integerValue];

        [UIView animateWithDuration:0.7f
                         animations:^{
                             
                             self.lc_CurrentNumX.constant = self.iv_GraphLine.frame.size.width * (float)nDoneCnt / (float)nTotalQuestionCnt;
                         }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateList];
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



- (void)updateList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ExamId, @"examId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exam/detail/info"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSLog(@"resulte : %@", resulte);
                                            
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                NSDictionary *dic = [resulte objectForKey:@"examInfo"];
                                                self.dic_Info = dic;
                                                
                                                NSInteger nTotalQuestionCnt = [[dic objectForKey:@"questionCount"] integerValue];

                                                NSString *str_Date = [NSString stringWithFormat:@"%@", [dic objectForKey:@"changeDate"]];
                                                
                                                if( str_Date.length >= 12 )
                                                {
//                                                    NSString *str_Year = [str_Date substringWithRange:NSMakeRange(0, 4)];
                                                    NSString *str_Month = [str_Date substringWithRange:NSMakeRange(4, 2)];
                                                    NSString *str_Day = [str_Date substringWithRange:NSMakeRange(6, 2)];
//                                                    NSString *str_Hour = [str_Date substringWithRange:NSMakeRange(8, 2)];
//                                                    NSString *str_Minute = [str_Date substringWithRange:NSMakeRange(10, 2)];

                                                    
                                                    str_Date = [NSString stringWithFormat:@"%02ld월 %02ld일", [str_Month integerValue], [str_Day integerValue]];
                                                }
                                                
                                                [self.seg setTitle:str_Date forSegmentAtIndex:0];
                                                
                                                //현재 푼 문제
                                                self.lb_CurrentQuestionNum.text = [NSString stringWithFormat:@"%@", [dic objectForKey:@"solveQuestionCount"]];
                                                self.lb_TotalQuestionNum.text = [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionCount"]];
                                                
                                                
                                                
                                                //그래프
                                                self.lb_CurrentNum.text = [NSString stringWithFormat:@"%@", [dic objectForKey:@"solveQuestionCount"]];
                                                self.lb_EndNum.text = [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionCount"]];
                                                
                                                
                                                //문제를풀기시작한날짜
                                                str_Date = [NSString stringWithFormat:@"%@", [dic objectForKey:@"examFirstDate"]];
                                                if( str_Date.length >= 12 )
                                                {
                                                    NSString *str_Year = [str_Date substringWithRange:NSMakeRange(0, 4)];
                                                    NSString *str_Month = [str_Date substringWithRange:NSMakeRange(4, 2)];
                                                    NSString *str_Day = [str_Date substringWithRange:NSMakeRange(6, 2)];
                                                    
                                                    str_Date = [NSString stringWithFormat:@"%04ld %02ld.%02ld", [str_Year integerValue], [str_Month integerValue], [str_Day integerValue]];
                                                }
                                                self.lb_StartDate.text = str_Date;
                                                
                                                //마지막으로 문제를 푼 날짜
                                                str_Date = [NSString stringWithFormat:@"%@", [dic objectForKey:@"examLastDate"]];
                                                if( str_Date.length >= 12 )
                                                {
                                                    NSString *str_Year = [str_Date substringWithRange:NSMakeRange(0, 4)];
                                                    NSString *str_Month = [str_Date substringWithRange:NSMakeRange(4, 2)];
                                                    NSString *str_Day = [str_Date substringWithRange:NSMakeRange(6, 2)];
                                                    
                                                    str_Date = [NSString stringWithFormat:@"%04ld %02ld.%02ld", [str_Year integerValue], [str_Month integerValue], [str_Day integerValue]];
                                                }
                                                self.lb_CurrentDate.text = str_Date;
                                                
                                                
                                                
                                                //맞은 문제%
                                                NSInteger nOkCnt = [[dic objectForKey:@"correctQuestionCount"] integerValue];
                                                
                                                //틀린문제%
                                                NSInteger nNoCnt = [[dic objectForKey:@"inCorrectQuestionCount"] integerValue];
                                                
                                                //푼 문제%
                                                NSInteger nDoneCnt = [[dic objectForKey:@"solveQuestionCount"] integerValue];

                                                //안푼문제%
                                                NSInteger nNotCnt = [[dic objectForKey:@"nonSolveQuestionCount"] integerValue];

                                                //별표한 문제
                                                NSInteger nStarCnt = [[dic objectForKey:@"myStarCount"] integerValue];

                                                //다른 사람이들이 많이 틀린 문제들
                                                
                                                [self.arM_List addObject:@{@"title":@"맞은문제",
                                                                           @"per":[NSString stringWithFormat:@"%.0f%%", (float)nOkCnt / (float)nTotalQuestionCnt * 100.f],
                                                                           @"count":[NSString stringWithFormat:@"%ld", nOkCnt]}];
                                                
                                                [self.arM_List addObject:@{@"title":@"틀린문제",
                                                                           @"per":[NSString stringWithFormat:@"%.0f%%", (float)nNoCnt / (float)nTotalQuestionCnt * 100.f],
                                                                           @"count":[NSString stringWithFormat:@"%ld", nNoCnt]}];

                                                [self.arM_List addObject:@{@"title":@"푼 문제",
                                                                           @"per":[NSString stringWithFormat:@"%.0f%%", (float)nDoneCnt / (float)nTotalQuestionCnt * 100.f],
                                                                           @"count":[NSString stringWithFormat:@"%ld", nDoneCnt]}];

                                                [self.arM_List addObject:@{@"title":@"안푼문제",
                                                                           @"per":[NSString stringWithFormat:@"%.0f%%", (float)nNotCnt / (float)nTotalQuestionCnt * 100.f],
                                                                           @"count":[NSString stringWithFormat:@"%ld", nNotCnt]}];

                                                [self.arM_List addObject:@{@"title":@"★별표한 문제",
                                                                           @"per":[NSString stringWithFormat:@"%.0f%%", (float)nStarCnt / (float)nTotalQuestionCnt * 100.f],
                                                                           @"count":[NSString stringWithFormat:@"%ld", nStarCnt]}];

                                                [self.arM_List addObject:@{@"title":@"다른 사람이들이 많이 틀린 문제들",
                                                                           @"per":[NSString stringWithFormat:@"%.0f%%", (float)0 / (float)nTotalQuestionCnt * 100.f],
                                                                           @"count":[NSString stringWithFormat:@"%ld", 0]}];

                                                [self.tbv_List reloadData];
                                                
                                                
                                                //하단 뷰들
                                                //푼 사람
                                                self.lb_Tab1.text = [NSString stringWithFormat:@"%@%%", [dic objectForKey:@"perMainHashTagUserSolveCount"]];
                                                
                                                //태그
                                                self.lb_Tab2.text = [NSString stringWithFormat:@"%@", [dic objectForKey:@"mainHashTagUserSolveQuestionCount"]];
                                                self.lb_Tag.text = [dic objectForKey:@"userMainHashTag"];
                                                
                                                //푼 사람
                                                self.lb_Tab3.text = [NSString stringWithFormat:@"%@%%", [dic objectForKey:@"perTotalUserSolveCount"]];
                                                
                                                //문제 구매
                                                self.lb_Tab4.text = [NSString stringWithFormat:@"%@", [dic objectForKey:@"examUniqueUserCount"]];
                                                
                                                [self.view setNeedsLayout];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}


#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arM_List.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ReportCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ReportCell"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = [self.arM_List objectAtIndex:indexPath.row];
    cell.lb_Title.text = [dic objectForKey:@"title"];
    cell.lb_SubTitle.text = [dic objectForKey:@"per"];
    cell.lb_Tail.text = [dic objectForKey:@"count"];
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}



#pragma mark - IBAction
- (IBAction)goSegChange:(id)sender
{
    if( self.seg.selectedSegmentIndex == 0 )
    {
        self.v_Group.hidden = YES;
        return;
    }
    
    self.v_Group.hidden = NO;
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@/Login/p", kWebBaseUrl]];
    
    NSString *body = [NSString stringWithFormat: @"email=%@&password=%@",
                      [[NSUserDefaults standardUserDefaults] objectForKey:@"email"],
                      [[NSUserDefaults standardUserDefaults] objectForKey:@"password"]];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
    [self.webView loadRequest: request];
}



//단원보기 관련 코드
#pragma mark - UIWebViewDelegate
- (void)webViewDidStartLoad:(UIWebView *)webView
{
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    NSString *str_Idx = [NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey:@"groupId"] integerValue]];
    NSString *str_GroupName = [self.dic_Info objectForKey:@"groupName"];
    
    NSString *str_Url = [NSString stringWithFormat:@"%@/Exam/group_inc/%@", kWebBaseUrl, str_Idx];
    NSURL *url = [NSURL URLWithString: str_Url];
    NSString *body = [NSString stringWithFormat:@"groupName=%@", str_GroupName];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url];
    [request setHTTPMethod: @"POST"];
    [request setHTTPBody: [body dataUsingEncoding: NSUTF8StringEncoding]];
    [self.webView loadRequest: request];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if( [[[request URL] absoluteString] hasPrefix:@"thoting://"] )
    {
        NSString *jsData = [[request URL] absoluteString];
        NSArray *ar_Sep = [jsData componentsSeparatedByString:@"thoting://exam/"];
        if( ar_Sep.count > 1 )
        {
            NSString *str = [[ar_Sep objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            str = [str stringByReplacingOccurrencesOfString:@"/" withString:@""];
            
            QuestionContainerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
            vc.hidesBottomBarWhenPushed = YES;
            vc.str_Idx = str;
            vc.str_StartIdx = @"0";
            [self.navigationController pushViewController:vc animated:YES];
            
            return YES;
        }
        
        
        NSArray *jsDataArray = [jsData componentsSeparatedByString:@"toapp://"];
        
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
    }
    
    return YES;
}


- (IBAction)goResult:(id)sender
{
    NSInteger nGrade = [[self.dic_Info objectForKey:@"personGrade"] integerValue];
    NSString *str_Grade = [NSString stringWithFormat:@"%@ %@학년",
                           [self.dic_Info objectForKey:@"schoolGrade"], nGrade == 0 ? @"전체" : [NSString stringWithFormat:@"%ld", nGrade]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    ReportDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ReportDetailViewController"];
    vc.str_Title = [NSString stringWithFormat:@"%@ %@ %@", [self.dic_Info objectForKey:@"subjectName"], str_Grade, [self.dic_Info objectForKey:@"publisherName"]];
    vc.str_ExamId = [self.dic_Info objectForKey:@"examId"];
    vc.str_PUserId = self.str_UserIdx;
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

@end
