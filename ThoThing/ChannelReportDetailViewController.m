//
//  ChannelReportDetailViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 12. 16..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "ChannelReportDetailViewController.h"
#import "ChannelReportDetailHeaderCell.h"
#import "ChannelReportDetailListCell.h"
#import "RankingMainViewController.h"
#import "MyMainViewController.h"

@interface ChannelReportDetailViewController ()
{
    NSString *str_ImagePrefix;
    NSString *str_UserImagePrefix;
    NSString *str_NoImagePrefix;
}
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_Info;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@end

@implementation ChannelReportDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.lb_Title.text = [self.dic_Info objectForKey:@"examTitle"];
    
    //[self.dic_Info objectForKey:@"examQuestionCount"]; //전체
    //[self.dic_Info objectForKey:@"avgScore"]; //평균
//    [self.dic_Info objectForKey:@"solveQuestionCount"]; //
    
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
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"examId"]], @"examId",//문제별 리스트로 가져오는 경우
                                        //                                        @"", @"subjectName", //과목별 리스트로 가져오는 경우
                                        //                                        @"", @"startDate",
                                        //                                        @"", @"endDate",
                                        nil];
    
    __weak __typeof__(self) weakSelf = self;
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/admin/report/daily"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            str_ImagePrefix = [resulte objectForKey:@"img_prefix"];
                                            str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
                                            str_NoImagePrefix = [resulte objectForKey:@"no_image"];
                                            
                                            self.lb_Info.text = [NSString stringWithFormat:@"전체 %@명      평균 %@      문제 %@",
                                                                 [resulte objectForKey:@"examSolveUserCount"],
                                                                 [self.dic_Info objectForKey:@"avgScore"],
                                                                 [self.dic_Info objectForKey:@"examQuestionCount"]];
                                            
                                            weakSelf.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"reportData"]];
                                            [weakSelf.tbv_List reloadData];
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
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{ 
    ChannelReportDetailListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelReportDetailListCell"];
    if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"ChannelReportDetailListCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic_Main = self.arM_List[indexPath.section];
    NSArray *ar_List = [dic_Main objectForKey:@"userInfo"];
    NSDictionary *dic_Sub = ar_List[indexPath.row];
    NSArray *ar_Tmp = [dic_Sub objectForKey:@"solveInfo"];
    if( ar_Tmp.count > 0 )
    {
        NSDictionary *dic_Solve = [ar_Tmp firstObject];
        
        NSURL *url = [Util createImageUrl:str_UserImagePrefix withFooter:[dic_Sub objectForKey_YM:@"imgUrl"]];
        [cell.iv_User sd_setImageWithURL:url placeholderImage:BundleImage(@"no_image.png")];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTap1:)];
        [singleTap setNumberOfTapsRequired:1];
        [cell.iv_User addGestureRecognizer:singleTap];
        cell.iv_User.userInteractionEnabled = YES;
        cell.iv_User.tag = (indexPath.section * 100) + indexPath.row;

        cell.lb_Name.text = [dic_Sub objectForKey:@"name"];
        cell.lb_School.text = [NSString stringWithFormat:@"%@ %@", [dic_Sub objectForKey:@"userAffiliation"], [dic_Sub objectForKey:@"userMajor"]];
        
        NSInteger fDoneCount = [[dic_Solve objectForKey:@"solveQuestionCount"] integerValue];   //푼문제
        NSInteger fPassCount = [[dic_Solve objectForKey:@"correctAnswerCount"] integerValue];   //맞은문제

//        cell.lb_Score.text = [NSString stringWithFormat:@"%ld 점", (NSInteger)(fPassCount/fDoneCount) * 100];
        cell.lb_Score.text = [NSString stringWithFormat:@"%@ 점", [dic_Solve objectForKey:@"correctAnswerCount"]];
        cell.lb_DoneQCnt.text = [NSString stringWithFormat:@"푼문제 %ld", fDoneCount];
        
        [cell.btn_Ranking setTitle:[NSString stringWithFormat:@"%@등", [dic_Solve objectForKey:@"channelRank"]] forState:UIControlStateNormal];
        
        cell.btn_Ranking.tag = [[NSString stringWithFormat:@"%ld", (indexPath.section * 100) + indexPath.row] integerValue];
        [cell.btn_Ranking addTarget:self action:@selector(onShowRanking:) forControlEvents:UIControlEventTouchUpInside];
    }

    
//    cell.btn_Detail.tag = [[NSString stringWithFormat:@"%ld", (indexPath.section * 100) + indexPath.row] integerValue];
//    [cell.btn_Detail addTarget:self action:@selector(onDetail:) forControlEvents:UIControlEventTouchUpInside];
//    
//    NSArray *ar_Solve = [dic objectForKey:@"solveInfo"];
//    if( ar_Solve && ar_Solve.count > 0 )
//    {
//        NSDictionary *dic_Solve = [ar_Solve firstObject];
//        cell.lb_Contents.text = [dic_Solve objectForKey:@"examTitle"];
//        
//        NSInteger fTotalCount = [[dic_Solve objectForKey:@"examQuestionCount"] integerValue];   //전체문제
//        NSInteger fDoneCount = [[dic_Solve objectForKey:@"solveQuestionCount"] integerValue];   //푼문제
//        NSInteger fPassCount = [[dic_Solve objectForKey:@"correctAnswerCount"] integerValue];   //맞은문제
//        NSInteger nTotalRanking = [[dic_Solve objectForKey:@"koreaRank"] integerValue];     //전국등수
//        NSInteger nChannelRanking = [[dic_Solve objectForKey:@"channelRank"] integerValue]; //채널등수
//
//        cell.lb_SubjectName.text = [dic_Solve objectForKey_YM:@"subjectName"];
//        cell.lb_TotalQCount.text = [NSString stringWithFormat:@"문제 %ld", fTotalCount];
//        cell.lb_MyScore.text = [NSString stringWithFormat:@"%ld 점", (NSInteger)(fPassCount/fDoneCount) * 100];
//        cell.lb_DoneCount.text = [NSString stringWithFormat:@"푼문제 %@", [dic_Solve objectForKey:@"solveQuestionCount"]];
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
    if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"ChannelReportDetailHeaderCell" owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }

    NSDictionary *dic_Main = self.arM_List[section];
    NSString *str_Date = [NSString stringWithFormat:@"%@", [dic_Main objectForKey:@"lastDateTime"]];
    
    NSRange range = NSMakeRange(0, 4);
    NSString *str_Year = [str_Date substringWithRange:range];
    
    range = NSMakeRange(4, 2);
    NSString *str_Month = [str_Date substringWithRange:range];
    
    range = NSMakeRange(6, 2);
    NSString *str_Day = [str_Date substringWithRange:range];
    
    cell.lb_Date.text = [NSString stringWithFormat:@"%@.%@.%@", str_Year, str_Month, str_Day];
    
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
        vc.str_UserIdx = [dic objectForKey:@"userId"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)onShowRanking:(UIButton *)btn
{
    NSInteger nSection = btn.tag / 100;
    NSInteger nRow = btn.tag % 100;

    NSDictionary *dic_Main = self.arM_List[nSection];
    NSArray *ar_List = [dic_Main objectForKey:@"userInfo"];
    NSDictionary *dic = ar_List[nRow];
    NSArray *ar_Tmp = [dic objectForKey:@"solveInfo"];
    
    if( ar_Tmp.count > 0 )
    {
        NSDictionary *dic_Info = [ar_Tmp firstObject];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
        UINavigationController *navi = [storyboard instantiateViewControllerWithIdentifier:@"RankingNavi"];
        RankingMainViewController *vc = [navi.viewControllers firstObject];
        vc.dic_Info = dic_Info;
        [self presentViewController:navi animated:YES completion:^{
            
        }];
    }
}

@end
