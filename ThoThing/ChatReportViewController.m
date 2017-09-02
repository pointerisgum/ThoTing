//
//  ChatReportViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 1. 10..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "ChatReportViewController.h"
#import "ChatReportCell.h"
#import "ChannelReportDetailHeaderCell.h"
#import "RankingMainViewController.h"
#import "MyMainViewController.h"

@interface ChatReportViewController ()
{
    NSString *str_ImagePrefix;
    NSString *str_UserImagePrefix;
    NSString *str_NoImagePrefix;
    
    NSInteger nTotalQnaCount;
}
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_Info;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@end

@implementation ChatReportViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSDictionary *dic_ActionMap = [self.dic_Info objectForKey:@"actionMap"];
    self.lb_Title.text = [dic_ActionMap objectForKey_YM:@"examTitle"];
    
    [self updateList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
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
    NSInteger nExamId = [[self.dic_Info objectForKey:@"examId"] integerValue];
    if( nExamId <= 0 )
    {
        NSDictionary *dic_ActionMap = [self.dic_Info objectForKey:@"actionMap"];
        nExamId = [[dic_ActionMap objectForKey:@"examId"] integerValue];
    }
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        @"0", @"channelId",
                                        [NSString stringWithFormat:@"%ld", nExamId], @"examId",
                                        [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"sId"]], @"sId",
                                        @"share", @"reportType",
                                        @"ios", @"resultType",
                                        nil];
    
    __weak __typeof__(self) weakSelf = self;
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/admin/report/daily"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];

                                        NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                        if( nCode == 200 )
                                        {
                                            NSInteger nTotalUserCount = [[resulte objectForKey:@"examSolveUserCount"] integerValue];
                                            if( nTotalUserCount <= 0 )
                                            {
                                                UIAlertView *alert = CREATE_ALERT(nil, @"아직 푼 사람이 없습니다", @"확인", nil);
                                                [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                    
                                                    [self.navigationController popViewControllerAnimated:YES];
                                                }];
                                                
                                                return;
                                            }
                                            
                                            str_ImagePrefix = [resulte objectForKey:@"img_prefix"];
                                            str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
                                            str_NoImagePrefix = [resulte objectForKey:@"no_image"];
                                            
                                            NSDictionary *dic_ExamDetailInfo = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"examDetailInfo"]];
                                            nTotalQnaCount = [[dic_ExamDetailInfo objectForKey:@"examQuestionCount"] integerValue];
                                            
                                            self.lb_Info.text = [NSString stringWithFormat:@"전체 %@명      평균 %@      문제 %@",
                                                                 [resulte objectForKey:@"examSolveUserCount"],
                                                                 [dic_ExamDetailInfo objectForKey:@"avgScore"],
                                                                 [dic_ExamDetailInfo objectForKey:@"examQuestionCount"]];
                                            
                                            weakSelf.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"reportData"]];
                                            [weakSelf.tbv_List reloadData];
                                        }
                                        else
                                        {
                                            ALERT(nil, [resulte objectForKey:@"error_message"], nil, @"확인", nil);
                                            [self.navigationController popViewControllerAnimated:YES];
//                                            [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                        }
                                    }];
}


#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.arM_List.count;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dic = self.arM_List[section];
    NSArray *ar_List = [dic objectForKey:@"userInfo"];
    return ar_List.count;
    
//    if( ar_List.count > 0 )
//    {
//        NSDictionary *dic_Sub = [ar_List firstObject];
//        NSArray *ar_Tmp = [dic_Sub objectForKey:@"solveInfo"];
//        
//        return ar_Tmp.count;
//    }
//    
//    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChatReportCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatReportCell"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic_Main = self.arM_List[indexPath.section];
    NSArray *ar_List = [dic_Main objectForKey:@"userInfo"];
    NSDictionary *dic_Solve = [ar_List objectAtIndex:indexPath.row];
//    NSArray *ar_Tmp = [dic_Sub objectForKey:@"solveInfo"];
//    if( ar_Tmp.count > 0 )
//    {
//        NSLog(@"solveInfo.count : %ld", ar_Tmp.count);
//        NSDictionary *dic_Solve = ar_Tmp[indexPath.row];
    
        NSURL *url = [Util createImageUrl:str_UserImagePrefix withFooter:[dic_Solve objectForKey_YM:@"userThumbnail"]];
        [cell.iv_User sd_setImageWithURL:url placeholderImage:BundleImage(@"no_image.png")];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTap1:)];
        [singleTap setNumberOfTapsRequired:1];
        [cell.iv_User addGestureRecognizer:singleTap];
        cell.iv_User.userInteractionEnabled = YES;
        cell.iv_User.tag = (indexPath.section * 100) + indexPath.row;
        
//        cell.lb_Name.text = [dic_Solve objectForKey:@"name"];
        cell.lb_Name.text = [dic_Solve objectForKey:@"realName"];
        cell.lb_School.text = [NSString stringWithFormat:@"%@ %@", [dic_Solve objectForKey:@"userAffiliation"], [dic_Solve objectForKey:@"userMajor"]];
        
        NSString *str_EndDate = [NSString stringWithFormat:@"%@", [dic_Solve objectForKey_YM:@"endDate"]];
//        NSString *str_Year = [str_EndDate substringWithRange:NSMakeRange(0, 4)];
        NSString *str_Month = [str_EndDate substringWithRange:NSMakeRange(4, 2)];
        NSString *str_Day = [str_EndDate substringWithRange:NSMakeRange(6, 2)];
//        NSString *str_Hour = [str_EndDate substringWithRange:NSMakeRange(8, 2)];
//        NSString *str_Minute = [str_EndDate substringWithRange:NSMakeRange(10, 2)];
//        NSString *str_Second = [str_EndDate substringWithRange:NSMakeRange(12, 2)];
        NSString *str_Date = [NSString stringWithFormat:@"%@.%@", str_Month, str_Day];
        cell.lb_Date.text = str_Date;
        
        NSInteger fDoneCount = [[dic_Solve objectForKey:@"solveQuestionCount"] integerValue];   //푼문제
        //        NSInteger fPassCount = [[dic_Solve objectForKey:@"correctAnswerCount"] integerValue];   //맞은문제
        
        //        cell.lb_Score.text = [NSString stringWithFormat:@"%ld 점", (NSInteger)(fPassCount/fDoneCount) * 100];
        cell.lb_Score.text = [NSString stringWithFormat:@"%@ 점", [dic_Solve objectForKey:@"correctAnswerCount"]];
        
        NSString *str_FinishYn = [dic_Solve objectForKey_YM:@"isExamFinish"];
        if( [str_FinishYn isEqualToString:@"Y"] )
        {
            cell.lb_SolveCount.text = @"";
        }
        else
        {
            cell.lb_SolveCount.text = [NSString stringWithFormat:@"푼문제 %ld", fDoneCount];
        }
        
        [cell.btn_Ranking setTitle:[NSString stringWithFormat:@"%@등", [dic_Solve objectForKey:@"channelRank"]] forState:UIControlStateNormal];
        
        cell.btn_Ranking.tag = [[NSString stringWithFormat:@"%ld", (indexPath.section * 100) + indexPath.row] integerValue];
        [cell.btn_Ranking addTarget:self action:@selector(onShowRanking:) forControlEvents:UIControlEventTouchUpInside];
//    }
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 70.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    ChannelReportDetailHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelReportDetailHeaderCell"];
    
    NSDictionary *dic_Main = self.arM_List[section];
    NSString *str_Date = [NSString stringWithFormat:@"%@", [dic_Main objectForKey:@"lastDateTime"]];
    
    NSRange range = NSMakeRange(0, 4);
    NSString *str_Year = [str_Date substringWithRange:range];
    
    range = NSMakeRange(4, 2);
    NSString *str_Month = [str_Date substringWithRange:range];
    
    range = NSMakeRange(6, 2);
    NSString *str_Day = [str_Date substringWithRange:range];

    cell.lb_Date.text = [NSString stringWithFormat:@"%@.%@.%@", str_Year, str_Month, str_Day];

    NSString *str_IsBeforeYn = [dic_Main objectForKey_YM:@"isBefore"];
    if( [str_IsBeforeYn isEqualToString:@"Y"] )
    {
        cell.lb_DateSub.text = @"기존에 푼 사람";
    }
    else
    {
        cell.lb_DateSub.text = @"";
    }
    
    return cell;
}

- (void)userTap1:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *view = gestureRecognizer.view;
    
    NSDictionary *dic_Main = self.arM_List[view.tag / 100];
    NSArray *ar_Tmp = [dic_Main objectForKey:@"userInfo"];
    if( ar_Tmp.count > 0 )
    {
        NSDictionary *dic = ar_Tmp[view.tag % 100];
        
        if( [[dic objectForKey:@"userId"] isEqual:[NSNull null]] )
        {
            ALERT(nil, @"유저 정보가 없습니다", nil, @"확인", nil);
            return;
        }
        
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MyMainViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
        vc.isManagerView = YES;
        vc.isPermission = YES;
        vc.isShowNavi = YES;
        vc.str_UserIdx = [dic objectForKey:@"userId"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)onShowRanking:(UIButton *)btn
{
    NSInteger nSection = btn.tag / 100;
    NSInteger nRow = btn.tag % 100;
    
    NSDictionary *dic_Main = self.arM_List[nSection];
    NSArray *ar_Tmp = [dic_Main objectForKey:@"userInfo"];
    NSDictionary *dic_Info = [ar_Tmp objectAtIndex:nRow];

    NSString *str_Date = [NSString stringWithFormat:@"%@", [dic_Main objectForKey:@"lastDateTime"]];
        
    NSRange range = NSMakeRange(4, 2);
    NSString *str_Month = [str_Date substringWithRange:range];
    
    range = NSMakeRange(6, 2);
    NSString *str_Day = [str_Date substringWithRange:range];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    UINavigationController *navi = [storyboard instantiateViewControllerWithIdentifier:@"RankingNavi"];
    RankingMainViewController *vc = [navi.viewControllers firstObject];
    vc.dic_Info = dic_Info;
    vc.str_Date = [NSString stringWithFormat:@"%@월 %@일 공유", str_Month, str_Day];
    vc.str_sId = [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"sId"]];
    [self presentViewController:navi animated:YES completion:^{
        
    }];
}

@end
