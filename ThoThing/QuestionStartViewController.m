//
//  QuestionStartViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 9. 2..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//
 
#import "QuestionStartViewController.h"
#import "QuestionContainerViewController.h"
#import "ReportCell.h"
#import "GroupWebViewController.h"
#import "ReportDetailViewController.h"

#import "QuestionViewController.h"

@interface QuestionStartViewController ()
{
    NSInteger nOtherPer;    //다른 사람들이 많이 틀린 문제
}
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) NSDictionary *dic_Info;
@property (nonatomic, weak) IBOutlet UILabel *lb_StartNum;
@property (nonatomic, weak) IBOutlet UILabel *lb_CurrentNum;
@property (nonatomic, weak) IBOutlet UILabel *lb_EndNum;
@property (nonatomic, weak) IBOutlet UILabel *lb_StartDate;
@property (nonatomic, weak) IBOutlet UILabel *lb_CurrentDate;
@property (nonatomic, weak) IBOutlet UILabel *lb_Tab1;
@property (nonatomic, weak) IBOutlet UILabel *lb_Tab2;
@property (nonatomic, weak) IBOutlet UILabel *lb_Tab3;
@property (nonatomic, weak) IBOutlet UILabel *lb_Tab4;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_CurrentNumX;
@property (nonatomic, weak) IBOutlet UIImageView *iv_GraphLine;
@property (nonatomic, weak) IBOutlet UILabel *lb_BottomTag;

//네비뷰
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;

//상단 뷰들
@property (nonatomic, weak) IBOutlet UIView *v_Start;
@property (nonatomic, weak) IBOutlet UIView *v_Continue;
@property (nonatomic, weak) IBOutlet UIView *v_Retry;

@property (nonatomic, weak) IBOutlet UIButton *btn_Start;

@property (nonatomic, weak) IBOutlet UIButton *btn_Continue;
@property (nonatomic, weak) IBOutlet UIButton *btn_First1;

@property (nonatomic, weak) IBOutlet UIButton *btn_NonPass;
@property (nonatomic, weak) IBOutlet UIButton *btn_First2;

@end

@implementation QuestionStartViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.navigationController.navigationBarHidden = YES;
    
    self.lb_CurrentNum.hidden = YES;

    self.navigationController.navigationBarHidden = YES;
    
    self.v_Start.hidden = self.v_Continue.hidden = self.v_Retry.hidden = YES;

    self.lb_Title.text = self.str_Title;
    
    self.btn_Start.layer.cornerRadius = 36.f;
    self.btn_Start.layer.borderColor = kMainColor.CGColor;
    self.btn_Start.layer.borderWidth = 1.f;

    self.btn_Continue.layer.cornerRadius = 34.f;
    self.btn_Continue.layer.borderColor = kMainColor.CGColor;
    self.btn_Continue.layer.borderWidth = 1.f;
    
    self.btn_First1.layer.cornerRadius = 34.f;
    self.btn_First1.layer.borderColor = kMainColor.CGColor;
    self.btn_First1.layer.borderWidth = 1.f;

    self.btn_NonPass.layer.cornerRadius = 34.f;
    self.btn_NonPass.layer.borderColor = kMainRedColor.CGColor;
    self.btn_NonPass.layer.borderWidth = 1.f;

    self.btn_First2.layer.cornerRadius = 34.f;
    self.btn_First2.layer.borderColor = kMainColor.CGColor;
    self.btn_First2.layer.borderWidth = 1.f;

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
        __block NSInteger nDoneCnt = [[self.dic_Info objectForKey:@"examMySolveQuestionCount"] integerValue] - 1;
        __block NSInteger nTotalQuestionCnt = [[self.dic_Info objectForKey:@"questionCount"] integerValue] - 1;
        
        if( nDoneCnt < 0 )
        {
            self.lb_CurrentNum.hidden = YES;
        }
        else
        {
            self.lb_CurrentNum.hidden = NO;
        }
        [UIView animateWithDuration:0.7f
                         animations:^{
                             
                             if( nDoneCnt >= 0 )
                             {
                                 if( isnan(self.iv_GraphLine.frame.size.width * (float)nDoneCnt / (float)nTotalQuestionCnt) )
                                 {
                                     self.lc_CurrentNumX.constant = 0.f;
                                 }
                                 else
                                 {
                                     self.lc_CurrentNumX.constant = self.iv_GraphLine.frame.size.width * (float)nDoneCnt / (float)nTotalQuestionCnt;
                                 }
                             }
                         }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;

    [self updateList];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = NO;
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
                                        self.str_Idx, @"examId",
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
                                                
                                                self.v_Start.hidden = self.v_Continue.hidden = self.v_Retry.hidden = YES;
                                                
                                                NSInteger nTotalQuestionCnt = [[dic objectForKey:@"questionCount"] integerValue];
                                                NSInteger nDoneQuestionCnt = [[dic objectForKey:@"examMySolveQuestionCount"] integerValue];
                                                if( nDoneQuestionCnt == 0 )
                                                {
                                                    //문제를 하나도 풀지 않았다면 처음부터 풀기
                                                    self.v_Start.hidden = NO;
                                                    self.lb_CurrentNum.hidden = YES;
                                                }
                                                else if( nDoneQuestionCnt == nTotalQuestionCnt )
                                                {
                                                    //문제를 모두 풀었다면
                                                    self.v_Retry.hidden = NO;
                                                    self.lb_CurrentNum.hidden = NO;
                                                }
                                                else
                                                {
                                                    //그 외에는 이어서 풀기
                                                    self.v_Continue.hidden = NO;
                                                    self.lb_CurrentNum.hidden = NO;
                                                    NSInteger nNowQuestionNum = [[dic objectForKey:@"beginExamNo"] integerValue];
                                                    [self.btn_Continue setTitle:[NSString stringWithFormat:@"%ld번부터 풀기", nNowQuestionNum] forState:UIControlStateNormal];
                                                }
                                                
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
                                                
                                                
                                                //그래프
                                                self.lb_CurrentNum.text = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"examMySolveQuestionCount"]];
                                                self.lb_EndNum.text = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"questionCount"]];
                                                
                                                
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
                                                NSInteger nOkCnt = [[dic objectForKey:@"examMyCorrectQuestionCount"] integerValue];
                                                
                                                //틀린문제%
                                                NSInteger nNoCnt = [[dic objectForKey:@"examMyInCorrectQuestionCount"] integerValue];
                                                
                                                //푼 문제%
                                                NSInteger nDoneCnt = [[dic objectForKey:@"examMySolveQuestionCount"] integerValue];
                                                
                                                //안푼문제%
                                                NSInteger nNotCnt = [[dic objectForKey:@"examMyNonSolveQuestionCount"] integerValue];
                                                
                                                //별표한 문제
                                                NSInteger nStarCnt = [[dic objectForKey:@"examMyStarQuestionCount"] integerValue];
                                                
                                                //다른 사람이들이 많이 틀린 문제들
                                                NSInteger nOtherCnt = [[dic objectForKey:@"examLowCorrectQuestionCount"] integerValue];

                                                
                                                [self.arM_List removeAllObjects];
                                                
                                                [self.arM_List addObject:@{@"title":@"맞은문제",
                                                                           @"per":[NSString stringWithFormat:@"%.0f%%", (float)nOkCnt / (float)nTotalQuestionCnt * 100.f],
                                                                           @"count":[NSString stringWithFormat:@"%ld", nOkCnt]}];
                                                
                                                [self.arM_List addObject:@{@"title":@"틀린문제",
                                                                           @"per":[NSString stringWithFormat:@"%.0f%%", (float)nNoCnt / (float)nTotalQuestionCnt * 100.f],
                                                                           @"count":[NSString stringWithFormat:@"%ld", nNoCnt]}];
                                                
//                                                [self.arM_List addObject:@{@"title":@"푼 문제",
//                                                                           @"per":[NSString stringWithFormat:@"%.0f%%", (float)nDoneCnt / (float)nTotalQuestionCnt * 100.f],
//                                                                           @"count":[NSString stringWithFormat:@"%ld", nDoneCnt]}];
//                                                
//                                                [self.arM_List addObject:@{@"title":@"안푼문제",
//                                                                           @"per":[NSString stringWithFormat:@"%.0f%%", (float)nNotCnt / (float)nTotalQuestionCnt * 100.f],
//                                                                           @"count":[NSString stringWithFormat:@"%ld", nNotCnt]}];
                                                
                                                [self.arM_List addObject:@{@"title":@"★별표한 문제",
                                                                           @"per":[NSString stringWithFormat:@"%.0f%%", (float)nStarCnt / (float)nTotalQuestionCnt * 100.f],
                                                                           @"count":[NSString stringWithFormat:@"%ld", nStarCnt]}];
                                                
                                                [self.arM_List addObject:@{@"title":@"다른 사람이들이 많이 틀린 문제들",
                                                                           @"per":[NSString stringWithFormat:@"(상위 %.0f%%)", (float)nOtherCnt / (float)nTotalQuestionCnt * 100.f],
                                                                           @"count":[NSString stringWithFormat:@"%ld", nOtherCnt]}];
                                                
                                                [self.arM_List addObject:@{@"title":@"결과보기"}];

                                                nOtherPer = (float)nOtherCnt / (float)nTotalQuestionCnt * 100.f;
                                                [self.tbv_List reloadData];
                                                
                                                
                                                //하단 뷰들
                                                //푼 사람
                                                self.lb_Tab1.text = [NSString stringWithFormat:@"%@", [dic objectForKey:@"paidUserCount"]];
                                                
                                                //평균정답률
                                                self.lb_Tab2.text = [NSString stringWithFormat:@"%@%%", [dic objectForKey:@"perTotalUserSolveCount"]];
                                                
                                                //푼 사람
                                                self.lb_Tab3.text = [NSString stringWithFormat:@"%@", [dic objectForKey:@"mainHashTagUserSolveQuestionCount"]];
                                                self.lb_BottomTag.text = [dic objectForKey:@"userMainHashTag"];
                                                
                                                //평균정답률
                                                self.lb_Tab4.text = [NSString stringWithFormat:@"%@%%", [dic objectForKey:@"perMainHashTagUserSolveCount"]];
                                                
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
    
    
    //셀 초기화
    for( id subView in cell.contentView.subviews )
    {
        if( [subView isKindOfClass:[UIButton class]] )
        {
            UIButton *btn = (UIButton *)subView;
            [btn removeFromSuperview];
        }
    }
    
    cell.lb_Title.text = @"";
    cell.lb_SubTitle.text = @"";
    cell.lb_Tail.text = @"";
    ////////////////////////////////
    
    
    
    NSDictionary *dic = [self.arM_List objectAtIndex:indexPath.row];
    NSString *str_Title = [dic objectForKey:@"title"];
    
    if( [str_Title isEqualToString:@"결과보기"] )
    {
        for( id subView in cell.contentView.subviews )
        {
            if( [subView isKindOfClass:[UIButton class]] )
            {
                UIButton *btn = (UIButton *)subView;
                [btn removeFromSuperview];
            }
        }
        
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        UIButton *btn_Result = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_Result.tag = 456;
        btn_Result.frame = CGRectMake(0, 25, 100, 40);
        btn_Result.layer.cornerRadius = 8.f;
        btn_Result.layer.borderWidth = 1.f;
        btn_Result.layer.borderColor = [UIColor redColor].CGColor;
        [btn_Result setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        [btn_Result setTitle:str_Title forState:UIControlStateNormal];
        btn_Result.center = CGPointMake(self.view.frame.size.width / 2, btn_Result.center.y);
        [cell.contentView addSubview:btn_Result];
        
        [btn_Result addTarget:self action:@selector(onShowResulte:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.lb_Title.text = str_Title;
        cell.lb_SubTitle.text = [dic objectForKey:@"per"];
        cell.lb_Tail.text = [dic objectForKey:@"count"];
        
        if( indexPath.row == 1 )
        {
            cell.lb_Title.textColor = cell.lb_Tail.textColor = kMainRedColor;
        }
        else
        {
            cell.lb_Title.textColor = cell.lb_Tail.textColor = kMainColor;
        }
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = [self.arM_List objectAtIndex:indexPath.row];
    NSString *str_Title = [dic objectForKey:@"title"];
    
    if( [str_Title isEqualToString:@"결과보기"] )
    {
        return 90.f;
    }
    
    return 44.f;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*
     //전체 문제 수
     NSInteger nTotalCnt = [[dic objectForKey:@"questionCount"] integerValue];
     
     //맞은 수
     NSInteger nPassCnt = [[dic objectForKey:@"correctQuestionCount"] integerValue];
     weakSelf.lb_PassCnt.text = [NSString stringWithFormat:@"%ld", nPassCnt];
     
     //틀린 수
     NSInteger nNonPassCnt = [[dic objectForKey:@"inCorrectQuestionCount"] integerValue];
     weakSelf.lb_NonPassCnt.text = [NSString stringWithFormat:@"%ld", nNonPassCnt];
     
     //별표 수
     weakSelf.lb_StarCnt.text = [NSString stringWithFormat:@"%@", [dic objectForKey:@"starQuestionCount"]];
     
     
     //맞은 문제와 틀린 문제를 더해서 총 문제수와 비교한다
     //두개의 합이 같으면 다 푼걸로 간주
     if( nTotalCnt <= (nPassCnt + nNonPassCnt) )
     {
     self.btn_Result.selected = YES;
     self.btn_Result.layer.borderColor = kMainRedColor.CGColor;
     self.btn_Result.userInteractionEnabled = YES;
     }
     else
     {
     self.btn_Result.selected = NO;
     self.btn_Result.layer.borderColor = [UIColor lightGrayColor].CGColor;
     self.btn_Result.userInteractionEnabled = NO;
     }
     */
    NSDictionary *dic = [self.arM_List objectAtIndex:indexPath.row];
    NSString *str_Title = [dic objectForKey:@"title"];
    
    if( [str_Title isEqualToString:@"결과보기"] )
    {
        return;
    }

    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentQuestionIdx"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    QuestionContainerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
    vc.str_ChannelId = self.str_ChannelId;
    vc.hidesBottomBarWhenPushed = YES;

    NSInteger nCnt = [[dic objectForKey:@"count"] integerValue];
    
    if( nCnt <= 0 ) return;
    
    
    switch (indexPath.row)
    {
        case 0:
            //맞은문제
            vc.str_Idx = self.str_Idx;
            vc.str_StartIdx = @"0";
            vc.str_SortType = @"correctQuestion";
            break;
            
        case 1:
            //틀린문제
            vc.str_Idx = self.str_Idx;
            vc.str_StartIdx = @"0";
            vc.str_SortType = @"inCorrectQuestion";
            break;

        case 2:
            //푼 문제
            vc.str_Idx = self.str_Idx;
            vc.str_StartIdx = @"0";
            vc.str_SortType = @"solveQuestion";
            break;

        case 3:
            //안푼문제
            vc.str_Idx = self.str_Idx;
            vc.str_StartIdx = @"0";
            vc.str_SortType = @"nonSolveQuestion";
            break;

        case 4:
            //별표한 문제
            vc.str_Idx = self.str_Idx;
            vc.str_StartIdx = @"0";
            vc.str_SortType = @"myStarQuestion";
            break;

        case 5:
            //다른 사람들이 많이 틀린 문제
            vc.str_Idx = self.str_Idx;
            vc.str_StartIdx = @"0";
            vc.str_SortType = @"lowCorrect";
            vc.str_LowPer = [NSString stringWithFormat:@"%ld", nOtherPer];
            break;

        default:
            break;
    }
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onShowResulte:(UIButton *)btn
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    ReportDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ReportDetailViewController"];
    vc.str_ExamId = self.str_Idx;
    vc.str_PUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}



#pragma mark - IBAction
- (IBAction)goBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)goStart:(id)sender
{
    if( [[self.dic_Info objectForKey:@"isPaid"] isEqualToString:@"paid"] )
    {
        [self starQuestion];
    }
    else
    {
        UIAlertView *alert = CREATE_ALERT(nil, @"문제를 구매하시겠습니까?", @"예", @"아니요");
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if( buttonIndex == 0 )
            {
                NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                    [Util getUUID], @"uuid",
                                                    [NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey:@"examId"] integerValue]], @"examId",
                                                    nil];
                
                [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/user/paymentinfo"
                                                    param:dicM_Params
                                               withMethod:@"POST"
                                                withBlock:^(id resulte, NSError *error) {
                                                    
                                                    [MBProgressHUD hide];
                                                    
                                                    if( resulte )
                                                    {
                                                        NSLog(@"resulte : %@", resulte);
                                                        NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                        if( nCode == 200 )
                                                        {
//                                                            ALERT(nil, @"문제를 구매 했습니다", nil, @"확인", nil);
                                                            [self starQuestion];
                                                        }
                                                        else
                                                        {
                                                            [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                        }
                                                    }
                                                }];
            }
        }];
    }
}

- (void)starQuestion
{
    //시작하기
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentQuestionIdx"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self reSetLocalQData];

    if( self.isPdf )
    {
        QuestionContainerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
        vc.hidesBottomBarWhenPushed = YES;
        vc.str_Idx = self.str_Idx;
        vc.str_StartIdx = @"0";
        vc.str_SortType = @"all";
        vc.isPdf = self.isPdf;
        vc.nStartPdfPage = 1;
        vc.str_ChannelId = self.str_ChannelId;
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        [self resetNormalQ];
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Question" bundle:nil];
        UINavigationController *navi = [storyBoard instantiateViewControllerWithIdentifier:@"QuestionNavi"];
        QuestionViewController *vc = [navi.viewControllers firstObject];
        vc.str_Idx = self.str_Idx;
        vc.str_StartIdx = @"0";
        vc.str_SortType = @"all";
        vc.isPdf = self.isPdf;
        vc.nStartPdfPage = 1;
        vc.str_ChannelId = self.str_ChannelId;
        vc.str_Title = self.str_Title;
        
        [self presentViewController:navi animated:NO completion:^{
            
        }];
    }
}

- (IBAction)goIngStart:(id)sender
{
    if( [[self.dic_Info objectForKey:@"isPaid"] isEqualToString:@"paid"] )
    {
        [self ingStarQuestion];
    }
    else
    {
        UIAlertView *alert = CREATE_ALERT(nil, @"문제를 구매하시겠습니까?", @"예", @"아니요");
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if( buttonIndex == 0 )
            {
                NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                    [Util getUUID], @"uuid",
                                                    [NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey:@"examId"] integerValue]], @"examId",
                                                    nil];
                
                [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/user/paymentinfo"
                                                    param:dicM_Params
                                               withMethod:@"POST"
                                                withBlock:^(id resulte, NSError *error) {
                                                    
                                                    [MBProgressHUD hide];
                                                    
                                                    if( resulte )
                                                    {
                                                        NSLog(@"resulte : %@", resulte);
                                                        NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                        if( nCode == 200 )
                                                        {
                                                            //                                                            ALERT(nil, @"문제를 구매 했습니다", nil, @"확인", nil);
                                                            [self ingStarQuestion];
                                                        }
                                                        else
                                                        {
                                                            [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                        }
                                                    }
                                                }];
            }
        }];
    }
}

- (void)ingStarQuestion
{
    //이어풀기
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentQuestionIdx"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    if( self.isPdf )
    {
        QuestionContainerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
        vc.hidesBottomBarWhenPushed = YES;
        vc.str_Idx = self.str_Idx;
        vc.str_StartIdx = [NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey:@"beginExamNo"] integerValue] - 1];
        vc.str_SortType = @"all";
        vc.isPdf = self.isPdf;
        vc.str_ChannelId = self.str_ChannelId;
        vc.nStartPdfPage = [[self.dic_Info objectForKey_YM:@"pdfPage"] integerValue];
        vc.str_PdfPage = [NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey_YM:@"pdfPage"] integerValue]];
        vc.str_PdfNo = [NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey:@"beginExamNo"] integerValue]];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Question" bundle:nil];
        UINavigationController *navi = [storyBoard instantiateViewControllerWithIdentifier:@"QuestionNavi"];
        QuestionViewController *vc = [navi.viewControllers firstObject];
        vc.str_Idx = self.str_Idx;
        vc.str_StartIdx = [NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey:@"beginExamNo"] integerValue] - 1];
        vc.str_SortType = @"all";
        vc.isPdf = self.isPdf;
        vc.nStartPdfPage = [[self.dic_Info objectForKey_YM:@"pdfPage"] integerValue];
        vc.str_ChannelId = self.str_ChannelId;
        vc.str_Title = self.str_Title;
        //        vc.str_PdfPage = [NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey_YM:@"pdfPage"] integerValue]];
        //        vc.str_PdfNo = [NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey:@"beginExamNo"] integerValue]];
        
        [self presentViewController:navi animated:NO completion:^{
            
        }];
    }
}

- (IBAction)goFirstStart:(id)sender
{
    if( [[self.dic_Info objectForKey:@"isPaid"] isEqualToString:@"paid"] )
    {
        [self firstStartQuestion];
    }
    else
    {
        UIAlertView *alert = CREATE_ALERT(nil, @"문제를 구매하시겠습니까?", @"예", @"아니요");
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if( buttonIndex == 0 )
            {
                NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                    [Util getUUID], @"uuid",
                                                    [NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey:@"examId"] integerValue]], @"examId",
                                                    nil];
                
                [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/user/paymentinfo"
                                                    param:dicM_Params
                                               withMethod:@"POST"
                                                withBlock:^(id resulte, NSError *error) {
                                                    
                                                    [MBProgressHUD hide];
                                                    
                                                    if( resulte )
                                                    {
                                                        NSLog(@"resulte : %@", resulte);
                                                        NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                        if( nCode == 200 )
                                                        {
                                                            //                                                            ALERT(nil, @"문제를 구매 했습니다", nil, @"확인", nil);
                                                            [self firstStartQuestion];
                                                        }
                                                        else
                                                        {
                                                            [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                        }
                                                    }
                                                }];
            }
        }];
    }
}

- (void)firstStartQuestion
{
    //처음부터 다시풀기
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentQuestionIdx"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self reSetLocalQData];

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_Idx, @"examId",
                                        //                                            @"1770", @"examId",
                                        @"testing", @"viewMode",   //풀기 상태 [testing-문제풀기, scoring-문제리뷰]
                                        @"", @"testerId",   //답안지 ID
                                        //                                            @"", @"firstExamNo",   //화면에 표시된 첫 문제 번호
                                        //                                            self.str_StartIdx, @"lastExamNo",    //화면에 표시된 마지막 문제 번호
                                        //                                            @"next", @"scrollType",
                                        @"all", @"questionType", //문제 형식 [all - 전체, inCorrectQuestion - 틀린문제, myStarQuestion - 내가 별표 한 문제, solveQuestion - 푼문제, nonSolveQuestion - 안푼 문제, manyQNAQuestion - 질문이 달린 문제]
                                        @"package", @"examMode", //문제 유형 [package - 일반문제, category - 단원문제]
                                        @"1", @"limitCount",
                                        @"new", @"solveMode",
                                        nil];
    
    __weak __typeof(&*self)weakSelf = self;
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exam/question/list"
     //        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exam/question"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            if( weakSelf.isPdf )
                                            {
                                                QuestionContainerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
                                                vc.hidesBottomBarWhenPushed = YES;
                                                vc.str_Idx = self.str_Idx;
                                                vc.str_StartIdx = @"0";
                                                vc.str_SortType = @"all";
                                                vc.isNew = NO;
                                                vc.isPdf = self.isPdf;
                                                vc.str_ChannelId = self.str_ChannelId;
                                                vc.nStartPdfPage = 1;
                                                
                                                [weakSelf.navigationController pushViewController:vc animated:YES];
                                            }
                                            else
                                            {
//                                                [self resetNormalQ];

                                                NSString *str_DataKey = [NSString stringWithFormat:@"Q_%@_%@", self.str_Idx, [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
                                                [[NSUserDefaults standardUserDefaults] removeObjectForKey:str_DataKey];
                                                
//                                                NSString *str_InfoKey = [NSString stringWithFormat:@"QInfo_%@", self.str_Idx];
//                                                [[NSUserDefaults standardUserDefaults] removeObjectForKey:str_InfoKey];
                                                
                                                [[NSUserDefaults standardUserDefaults] synchronize];

                                                NSDictionary *dic_ExamUserInfo = [resulte objectForKey:@"examUserInfo"];

                                                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Question" bundle:nil];
                                                UINavigationController *navi = [storyBoard instantiateViewControllerWithIdentifier:@"QuestionNavi"];
                                                QuestionViewController *vc = [navi.viewControllers firstObject];
                                                vc.str_Idx = self.str_Idx;
//                                                vc.str_StartIdx = [NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey:@"beginExamNo"] integerValue] - 1];
                                                vc.str_StartIdx = @"0";
                                                vc.str_SortType = @"all";
                                                vc.isPdf = self.isPdf;
                                                vc.nStartPdfPage = 1;
                                                vc.str_ChannelId = self.str_ChannelId;
                                                vc.str_Title = self.str_Title;
//                                                vc.isNew = YES;
//                                                vc.str_TesterId = [NSString stringWithFormat:@"%@", [dic_ExamUserInfo objectForKey:@"testerId"]];
                                                
                                                
                                                NSString *str_InfoKey = [NSString stringWithFormat:@"QInfo_%@_%@", self.str_Idx, [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
                                                NSData *qInfoData = [[NSUserDefaults standardUserDefaults] objectForKey:str_InfoKey];
                                                NSDictionary *dic_Tmp = [NSKeyedUnarchiver unarchiveObjectWithData:qInfoData];
                                                NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic_Tmp];
                                                
                                                NSMutableDictionary *dicM_ExamUserInfo = [NSMutableDictionary dictionaryWithDictionary:[dicM objectForKey:@"examUserInfo"]];
                                                [dicM_ExamUserInfo setObject:[NSString stringWithFormat:@"%@", [dic_ExamUserInfo objectForKey:@"testerId"]] forKey:@"testerId"];
                                                [dicM setObject:dicM_ExamUserInfo forKey:@"examUserInfo"];
                                                
                                                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dicM];
                                                [[NSUserDefaults standardUserDefaults] setObject:data forKey:str_InfoKey];
                                                [[NSUserDefaults standardUserDefaults] synchronize];

                                                

                                                [self presentViewController:navi animated:NO completion:^{
                                                    
                                                }];
                                            }
                                        }
                                    }];
}

- (IBAction)goNonPassStart:(id)sender
{
    if( [[self.dic_Info objectForKey:@"isPaid"] isEqualToString:@"paid"] )
    {
        [self nonPassStartQuestion];
    }
    else
    {
        UIAlertView *alert = CREATE_ALERT(nil, @"문제를 구매하시겠습니까?", @"예", @"아니요");
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            if( buttonIndex == 0 )
            {
                NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                    [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                    [Util getUUID], @"uuid",
                                                    [NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey:@"examId"] integerValue]], @"examId",
                                                    nil];
                
                [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/user/paymentinfo"
                                                    param:dicM_Params
                                               withMethod:@"POST"
                                                withBlock:^(id resulte, NSError *error) {
                                                    
                                                    [MBProgressHUD hide];
                                                    
                                                    if( resulte )
                                                    {
                                                        NSLog(@"resulte : %@", resulte);
                                                        NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                        if( nCode == 200 )
                                                        {
                                                            //                                                            ALERT(nil, @"문제를 구매 했습니다", nil, @"확인", nil);
                                                            [self nonPassStartQuestion];
                                                        }
                                                        else
                                                        {
                                                            [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                        }
                                                    }
                                                }];
            }
        }];
    }
}

- (void)nonPassStartQuestion
{
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentQuestionIdx"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    [self reSetLocalQData];

    if( self.isPdf )
    {
        QuestionContainerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
        vc.hidesBottomBarWhenPushed = YES;
        vc.str_Idx = self.str_Idx;
        vc.str_StartIdx = @"0";
        vc.str_SortType = @"inCorrectQuestionSolve";
        //    vc.isNew = YES;
        vc.isPdf = self.isPdf;
        vc.str_ChannelId = self.str_ChannelId;
        vc.nStartPdfPage = 1;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
//        [self resetNormalQ];

        NSString *str_DataKey = [NSString stringWithFormat:@"Q_%@_%@", self.str_Idx, [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:str_DataKey];
        
        NSString *str_InfoKey = [NSString stringWithFormat:@"QInfo_%@_%@", self.str_Idx, [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:str_InfoKey];

        [[NSUserDefaults standardUserDefaults] synchronize];
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Question" bundle:nil];
        UINavigationController *navi = [storyBoard instantiateViewControllerWithIdentifier:@"QuestionNavi"];
        QuestionViewController *vc = [navi.viewControllers firstObject];
        vc.str_Idx = self.str_Idx;
        vc.str_StartIdx = [NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey:@"beginExamNo"] integerValue] - 1];
        vc.str_SortType = @"inCorrectQuestionSolve";
        vc.isPdf = self.isPdf;
        vc.nStartPdfPage = 1;
        vc.str_ChannelId = self.str_ChannelId;
        vc.str_Title = self.str_Title;
        vc.isNonPassMode = YES;

        [self presentViewController:navi animated:NO completion:^{
            
        }];
    }
}

- (void)reSetLocalQData
{
//    NSString *str_NormalQKey = [NSString stringWithFormat:@"NormalQuestion_%@",
//                                [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
//    
//    NSData *NormalQData = [[NSUserDefaults standardUserDefaults] objectForKey:str_NormalQKey];
//    NSMutableDictionary *dicM_NormalQ = [NSKeyedUnarchiver unarchiveObjectWithData:NormalQData];
//    NSArray *ar_AllKeys = [dicM_NormalQ allKeys];
//    for( NSInteger i = 0; i < ar_AllKeys.count; i++ )
//    {
//        NSString *str_Key = [ar_AllKeys objectAtIndex:i];
//        if( [str_Key rangeOfString:self.str_Idx].location == NSNotFound )
//        {
//            continue;
//        }
//        NSDictionary *dic_Tmp = [dicM_NormalQ objectForKey:str_Key];
//        NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic_Tmp];
//        NSArray *ar_QInfo = [dicM objectForKey:@"questionInfos"];
//        if( ar_QInfo )
//        {
//            NSMutableDictionary *dicM_QuestionInfos = [NSMutableDictionary dictionaryWithDictionary:[ar_QInfo firstObject]];
//            [dicM_QuestionInfos setObject:[NSNull null] forKey:@"user_correct"];
//            [dicM setObject:@[dicM_QuestionInfos] forKey:@"questionInfos"];
//        }
//        
//        [dicM_NormalQ setObject:dicM forKey:str_Key];
//    }
//    
//    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dicM_NormalQ];
//    [[NSUserDefaults standardUserDefaults] setObject:data forKey:str_NormalQKey];
//    [[NSUserDefaults standardUserDefaults] synchronize];
    
//    if( self.isPdf )
//    {
//        NSString *str_PdfQKey = [NSString stringWithFormat:@"PdfQuestion_%@",
//                                    [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
//        
//        NSData *PdfQData = [[NSUserDefaults standardUserDefaults] objectForKey:str_PdfQKey];
//        NSMutableDictionary *dicM_PdfQ = [NSKeyedUnarchiver unarchiveObjectWithData:PdfQData];
//        NSArray *ar_PdfAllKeys = [dicM_PdfQ allKeys];
//        for( NSInteger i = 0; i < ar_PdfAllKeys.count; i++ )
//        {
//            NSString *str_Key = [ar_PdfAllKeys objectAtIndex:i];
//            if( [str_Key rangeOfString:self.str_Idx].location == NSNotFound )
//            {
//                continue;
//            }
//            
//            [dicM_PdfQ removeObjectForKey:str_Key];
//        }
//        
//        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dicM_PdfQ];
//        [[NSUserDefaults standardUserDefaults] setObject:data forKey:str_PdfQKey];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
//    else
//    {
//        NSString *str_NormalQKey = [NSString stringWithFormat:@"NormalQuestion_%@",
//                                    [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
//        
//        NSData *NormalQData = [[NSUserDefaults standardUserDefaults] objectForKey:str_NormalQKey];
//        NSMutableDictionary *dicM_NormalQ = [NSKeyedUnarchiver unarchiveObjectWithData:NormalQData];
//        NSArray *ar_NormalAllKeys = [dicM_NormalQ allKeys];
//        for( NSInteger i = 0; i < ar_NormalAllKeys.count; i++ )
//        {
//            NSString *str_Key = [ar_NormalAllKeys objectAtIndex:i];
//            if( [str_Key rangeOfString:self.str_Idx].location == NSNotFound )
//            {
//                continue;
//            }
//            
//            [dicM_NormalQ removeObjectForKey:str_Key];
//        }
//        
//        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dicM_NormalQ];
//        [[NSUserDefaults standardUserDefaults] setObject:data forKey:str_NormalQKey];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//    }
    
    
    NSString *str_PdfQKey = [NSString stringWithFormat:@"PdfQuestion_%@",
                             [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    
    NSData *PdfQData = [[NSUserDefaults standardUserDefaults] objectForKey:str_PdfQKey];
    NSMutableDictionary *dicM_PdfQ = [NSKeyedUnarchiver unarchiveObjectWithData:PdfQData];
    NSArray *ar_PdfAllKeys = [dicM_PdfQ allKeys];
    for( NSInteger i = 0; i < ar_PdfAllKeys.count; i++ )
    {
        NSString *str_Key = [ar_PdfAllKeys objectAtIndex:i];
        if( [str_Key rangeOfString:self.str_Idx].location == NSNotFound )
        {
            continue;
        }
        
        [dicM_PdfQ removeObjectForKey:str_Key];
    }
    
    NSData *pdfData = [NSKeyedArchiver archivedDataWithRootObject:dicM_PdfQ];
    [[NSUserDefaults standardUserDefaults] setObject:pdfData forKey:str_PdfQKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    
    NSString *str_NormalQKey = [NSString stringWithFormat:@"NormalQuestion_%@",
                                [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    
    NSData *NormalQData = [[NSUserDefaults standardUserDefaults] objectForKey:str_NormalQKey];
    NSMutableDictionary *dicM_NormalQ = [NSKeyedUnarchiver unarchiveObjectWithData:NormalQData];
    NSArray *ar_NormalAllKeys = [dicM_NormalQ allKeys];
    for( NSInteger i = 0; i < ar_NormalAllKeys.count; i++ )
    {
        NSString *str_Key = [ar_NormalAllKeys objectAtIndex:i];
        if( [str_Key rangeOfString:self.str_Idx].location == NSNotFound )
        {
            continue;
        }
        
        [dicM_NormalQ removeObjectForKey:str_Key];
    }
    
    NSData *normalData = [NSKeyedArchiver archivedDataWithRootObject:dicM_NormalQ];
    [[NSUserDefaults standardUserDefaults] setObject:normalData forKey:str_NormalQKey];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)resetNormalQ
{
    NSString *str_DataKey = [NSString stringWithFormat:@"Q_%@_%@", self.str_Idx, [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSData *qData = [[NSUserDefaults standardUserDefaults] objectForKey:str_DataKey];
    NSArray *ar_Tmp = [NSKeyedUnarchiver unarchiveObjectWithData:qData];
    NSMutableArray *arM = [NSMutableArray arrayWithArray:ar_Tmp];
    for( NSInteger i = 0; i < arM.count; i++ )
    {
        NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:[arM objectAtIndex:i]];
        [dicM setObject:[NSNull null] forKey:@"user_correct"];
        [arM replaceObjectAtIndex:i withObject:dicM];
    }

    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:arM];
    [[NSUserDefaults standardUserDefaults] setObject:data forKey:str_DataKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/*
 case kPass:
 self.completionBlock(@{@"obj":dic, @"type":@"correctQuestion"});
 break;
 
 case kNonPass:
 self.completionBlock(@{@"obj":dic, @"type":@"inCorrectQuestion"});
 break;
 
 case kStar:
 self.completionBlock(@{@"obj":dic, @"type":@"myStarQuestion"});
 break;
 
 default:
 self.completionBlock(@{@"obj":dic, @"type":@"all"});
 break;
 */

@end
