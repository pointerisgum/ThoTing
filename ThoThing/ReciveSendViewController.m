//
//  ReciveSendViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 6. 8..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "ReciveSendViewController.h"
#import "MyQuestionListCell.h"
#import "QuestionStartViewController.h"
#import "QuestionStartViewController.h"
#import "ActionSheetBottomViewController.h"
#import "QuestionDetailViewController.h"
#import "SharedViewController.h"
#import "GroupWebViewController.h"
#import "ReportDetailViewController.h"
#import "LibrarySectionCell.h"
#import "MyMainViewController.h"

@interface ReciveSendViewController ()
@property (nonatomic, assign) NSInteger nReceiveCount;  //받은 문제 수
@property (nonatomic, assign) NSInteger nSendCount;     //보낸 문제 수
@property (nonatomic, strong) NSMutableArray *arM_List1;
@property (nonatomic, strong) NSMutableArray *arM_List2;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Contents;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ContentsWidth;
@property (nonatomic, weak) IBOutlet UISegmentedControl *seg;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List1;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List2;
@end

@implementation ReciveSendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.sv_Contents.pagingEnabled = YES;
    
    [self updateReceive];
    [self updateSend];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidLayoutSubviews
{
    self.sv_Contents.contentSize = CGSizeMake(self.sv_Contents.frame.size.width * 2, self.sv_Contents.frame.size.height);
    self.lc_ContentsWidth.constant = self.sv_Contents.contentSize.width;
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

- (void)updateReceive
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"], @"pUserId",
                                        @"inviteExam", @"pageType",
                                        nil];
    
    if( self.str_ChannelId )
    {
        [dicM_Params setObject:self.str_ChannelId forKey:@"channelId"];
    }
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/page/package/exam/browse"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            self.arM_List1 = [NSMutableArray arrayWithArray:[resulte objectForKey:@"recommendInfo"]];
                                            [self.seg setTitle:[NSString stringWithFormat:@"받은문제 %ld", self.arM_List1.count] forSegmentAtIndex:0];
                                            [self.tbv_List1 reloadData];
                                        }
                                    }];
}

- (void)updateSend
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"], @"pUserId",
                                        @"shareExam", @"pageType",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/page/package/exam/browse"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            self.arM_List2 = [NSMutableArray arrayWithArray:[resulte objectForKey:@"recommendInfo"]];
                                            [self.seg setTitle:[NSString stringWithFormat:@"보낸문제 %ld", self.arM_List2.count] forSegmentAtIndex:1];
                                            [self.tbv_List2 reloadData];
                                        }
                                    }];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if( scrollView == self.sv_Contents )
    {
        NSInteger nPage = scrollView.contentOffset.x / scrollView.frame.size.width;
        if( nPage == 0 )
        {
            self.seg.selectedSegmentIndex = 0;
            //        [self performSelector:@selector(onDResetInterval) withObject:nil afterDelay:0.3f];
        }
        else
        {
            self.seg.selectedSegmentIndex = 1;
            //        [self performSelector:@selector(onQResetInterval) withObject:nil afterDelay:0.3f];
        }
    }
}



#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if( tableView == self.tbv_List1 )
    {
        return self.arM_List1.count;
    }
    
    return self.arM_List2.count;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( tableView == self.tbv_List1 )
    {
        NSDictionary *dic_Main = self.arM_List1[section];
        NSArray *ar = [dic_Main objectForKey:@"examInfos"];
        return ar.count;
    }
    
    NSDictionary *dic_Main = self.arM_List2[section];
    NSArray *ar = [dic_Main objectForKey:@"examInfos"];
    return ar.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyQuestionListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyQuestionListCell"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    cell.v_Base.clipsToBounds = YES;
    cell.v_Base.layer.borderColor = [UIColor colorWithRed:200.f/255.f green:200.f/255.f blue:200.f/255.f alpha:1].CGColor;
    cell.v_Base.layer.borderWidth = 0.5f;

    cell.btn_Group.tag = cell.btn_Result.tag = indexPath.row;
    
    NSDictionary *dic = nil;
    if( tableView == self.tbv_List1 )
    {
        NSDictionary *dic_Main = self.arM_List1[indexPath.section];
        NSArray *ar = [dic_Main objectForKey:@"examInfos"];
        dic = ar[indexPath.row];
    }
    else
    {
        NSDictionary *dic_Main = self.arM_List2[indexPath.section];
        NSArray *ar = [dic_Main objectForKey:@"examInfos"];
        dic = ar[indexPath.row];
    }
    
    
    /*
     basicConditionName = condTime;
     basicConditionValue = 140073648;
     basicConditionValue2 = 20170605;
     condTime = 140073648;
     examCount = 1;
     examInfos =             (
     {
     OpenYn = Y;
     amount = 0;
     avgStarCount = 0;
     changeDate = "2017-06-05 19:33:51";
     channelId = "<null>";
     channelName = "<null>";
     channelUrl = "<null>";
     clipCount = 0;
     codeHex = "#00BCD4";
     coverBgColor = "bgm-cyan";
     coverPath = "000/000/413467316ccc3b2a965b523949858a8a.pdf_cover.png";
     createDate = "2017-06-01 22:38:47";
     examId = 2438;
     examSolveCount = 2;
     examTitle = "\Ubaa8\Uc758\Ud3c9\Uac00 2018\Ud559\Ub144\Ub3c4 6\Uc6d4 \Uc601\Uc5b4";
     examType = pdfExam;
     examUniqueUserCount = 2;
     examUserCount = 2;
     groupId = 0;
     groupName = "<null>";
     groupQuestionCount = 0;
     heartCount = 0;
     isClip = "-1";
     isFinishCount = 0;
     isPaid = "no-paid";
     isSolve = 0;
     lectureId = 0;
     myStarCount = 0;
     packageChangeDate = "2017-06-02 15:07:17";
     personGrade = 0;
     publisherId = "-1";
     publisherName = "";
     questionCount = 45;
     sId = 1560;
     schoolGrade = "\Uace0\Ub4f1\Ud559\Uad50";
     solveQuestionCount = 0;
     starUserCount = 0;
     subjectName = "\Uc601\Uc5b4";
     teacherId = 195;
     teacherImg = "000/000/noImage13.png";
     teacherName = "\Uc544\Ubbf8\Ub2ec\Ub9ac";
     teacherUrl = U195170113;
     userInfo =                     (
     {
     userId = 195;
     userName = "\Uc544\Ubbf8\Ub2ec\Ub9ac";
     userThumbnail = "000/000/noImage13.png";
     userUrl = U195170113;
     }
     );
     userInfoSize = 1;
     }
     );
     hashTag = "2017.06.05";
     lastCondTime = 20170605;
     lastDateTime = 20170605193351;
     */

    cell.v_Progess.alpha = cell.btn_Result.alpha = cell.btn_Group.alpha = YES;
    cell.iv_Thumb.backgroundColor = [UIColor colorWithHexString:[dic objectForKey_YM:@"codeHex"]];
    
    //문제집 제목
    cell.lb_QuestionTitle.text = [dic objectForKey:@"subjectName"];
    
    //제목
    cell.lb_Title.text = [dic objectForKey:@"examTitle"];
    
    //학교 학년
    NSInteger nQCnt = [[dic objectForKey_YM:@"questionCount"] integerValue];
    NSInteger nUserCnt = [[dic objectForKey_YM:@"examUniqueUserCount"] integerValue];
    
    cell.lb_Grade.text = [NSString stringWithFormat:@"%@  문제 %ld  USER %ld명",
                          [dic objectForKey:@"schoolGrade"], nQCnt, nUserCnt];
    
    if( [[dic objectForKey_YM:@"isPaid"] isEqualToString:@"paid"] )
    {
        //구매한 문제
        cell.v_Progess.hidden = NO;
        cell.v_Star.hidden = YES;
        
        CGFloat fTotalCnt = [[dic objectForKey:@"questionCount"] floatValue];
        CGFloat fFinishCnt = [[dic objectForKey:@"solveQuestionCount"] floatValue];
        
        CGFloat fFinishPer = fFinishCnt / fTotalCnt;
        cell.lc_ProgressWidth.constant = cell.lc_ProgressBgWidth.constant * fFinishPer;
    }
    else
    {
        //구매 하지 않은 문제
        cell.v_Progess.hidden = YES;
        cell.v_Star.hidden = NO;
        
        NSInteger nStar = [[dic objectForKey:@"avgStarCount"] integerValue];
        switch (nStar)
        {
            case 0:
                cell.iv_Star1.image = BundleImage(@"star_empty.png");
                cell.iv_Star2.image = BundleImage(@"star_empty.png");
                cell.iv_Star3.image = BundleImage(@"star_empty.png");
                cell.iv_Star4.image = BundleImage(@"star_empty.png");
                cell.iv_Star5.image = BundleImage(@"star_empty.png");
                break;
                
            case 1:
                cell.iv_Star1.image = BundleImage(@"star_fill.png");
                cell.iv_Star2.image = BundleImage(@"star_empty.png");
                cell.iv_Star3.image = BundleImage(@"star_empty.png");
                cell.iv_Star4.image = BundleImage(@"star_empty.png");
                cell.iv_Star5.image = BundleImage(@"star_empty.png");
                break;
                
            case 2:
                cell.iv_Star1.image = BundleImage(@"star_fill.png");
                cell.iv_Star2.image = BundleImage(@"star_fill.png");
                cell.iv_Star3.image = BundleImage(@"star_empty.png");
                cell.iv_Star4.image = BundleImage(@"star_empty.png");
                cell.iv_Star5.image = BundleImage(@"star_empty.png");
                break;
                
            case 3:
                cell.iv_Star1.image = BundleImage(@"star_fill.png");
                cell.iv_Star2.image = BundleImage(@"star_fill.png");
                cell.iv_Star3.image = BundleImage(@"star_fill.png");
                cell.iv_Star4.image = BundleImage(@"star_empty.png");
                cell.iv_Star5.image = BundleImage(@"star_empty.png");
                break;
                
            case 4:
                cell.iv_Star1.image = BundleImage(@"star_fill.png");
                cell.iv_Star2.image = BundleImage(@"star_fill.png");
                cell.iv_Star3.image = BundleImage(@"star_fill.png");
                cell.iv_Star4.image = BundleImage(@"star_fill.png");
                cell.iv_Star5.image = BundleImage(@"star_empty.png");
                break;
                
            case 5:
                cell.iv_Star1.image = BundleImage(@"star_fill.png");
                cell.iv_Star2.image = BundleImage(@"star_fill.png");
                cell.iv_Star3.image = BundleImage(@"star_fill.png");
                cell.iv_Star4.image = BundleImage(@"star_fill.png");
                cell.iv_Star5.image = BundleImage(@"star_fill.png");
                break;
                
            default:
                break;
        }
    }
    
    cell.btn_Info.tag = indexPath.row;
    [cell.btn_Info addTarget:self action:@selector(onItemInfo:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDictionary *dic_Main = nil;
    if( tableView == self.tbv_List1 )
    {
        dic_Main = self.arM_List1[section];
    }
    else
    {
        dic_Main = self.arM_List2[section];
    }
    
    LibrarySectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LibrarySectionCell"];
    NSString *str_Date = [NSString stringWithFormat:@"%@", [dic_Main objectForKey:@"lastDateTime"]];
    NSRange range = NSMakeRange(0, 4);
    NSString *str_Year = [str_Date substringWithRange:range];
    
    range = NSMakeRange(4, 2);
    NSString *str_Month = [str_Date substringWithRange:range];
    
    range = NSMakeRange(6, 2);
    NSString *str_Day = [str_Date substringWithRange:range];

    NSArray *ar = [dic_Main objectForKey:@"examInfos"];
    if( ar && ar.count > 0 )
    {
        NSDictionary *dic = [ar firstObject];
        [cell.btn_UserName setTitle:[dic objectForKey_YM:@"teacherName"] forState:UIControlStateNormal];
        cell.btn_UserName.tag = [[dic objectForKey_YM:@"teacherId"] integerValue];
        [cell.btn_UserName addTarget:self action:@selector(onGoUserPage:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    cell.lb_SectionTitle.text = [NSString stringWithFormat:@"%@.%@.%@", str_Year, str_Month, str_Day];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.f;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = nil;
    if( tableView == self.tbv_List1 )
    {
        NSDictionary *dic_Main = self.arM_List1[indexPath.section];
        NSArray *ar = [dic_Main objectForKey:@"examInfos"];
        dic = ar[indexPath.row];
    }
    else
    {
        NSDictionary *dic_Main = self.arM_List2[indexPath.section];
        NSArray *ar = [dic_Main objectForKey:@"examInfos"];
        dic = ar[indexPath.row];
    }
    
    QuestionStartViewController  *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionStartViewController"];
    //        vc.hidesBottomBarWhenPushed = YES;
    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
    vc.str_StartIdx = @"0";
    vc.str_Title = [dic objectForKey:@"examTitle"];
    vc.str_UserIdx = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    vc.isPdf = [[dic objectForKey:@"examType"] isEqualToString:@"pdfExam"];
    vc.str_ChannelId = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"channelId"]];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onGoUserPage:(UIButton *)btn
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MyMainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
    //    vc.isManagerView = YES;
    //    vc.isPermission = YES;
    vc.str_UserIdx = [NSString stringWithFormat:@"%ld", btn.tag];
    vc.isShowNavi = YES;
    vc.isAnotherUser = YES;
    //    vc.hidesBottomBarWhenPushed = NO;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    //푸터 고정
    //    CGFloat sectionFooterHeight = 70.f;
    //    CGFloat tableViewHeight = self.tbv_List.frame.size.height;
    //
    //    if( scrollView.contentOffset.y == tableViewHeight )
    //    {
    //        scrollView.contentInset = UIEdgeInsetsMake(0, 0,-scrollView.contentOffset.y, 0);
    //    }
    //    else if ( scrollView.contentOffset.y >= sectionFooterHeight + self.tbv_List.frame.size.height )
    //    {
    //        scrollView.contentInset = UIEdgeInsetsMake(0, 0,-sectionFooterHeight, 0);
    //    }
    
    if( scrollView == self.tbv_List1 || scrollView == self.tbv_List2 )
    {
        //    헤더고정
        CGFloat sectionHeaderHeight = 30.f;
        if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0)
        {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        }
        else if (scrollView.contentOffset.y>=sectionHeaderHeight)
        {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
}

- (void)onItemInfo:(UIButton *)btn
{
    NSDictionary *dic = nil;
    if( self.seg.selectedSegmentIndex == 0 )
    {
        dic = self.arM_List1[btn.tag];
    }
    else
    {
        dic = self.arM_List2[btn.tag];
    }
    
    NSMutableArray *arM_Test = [NSMutableArray array];
    [arM_Test addObject:@{@"type":@"info", @"contents":[dic objectForKey:@"examTitle"]}];
    [arM_Test addObject:@{@"type":@"share", @"contents":@"공유"}];
    
    //단원보기 버튼 유무
    NSInteger nGroupId = [[dic objectForKey:@"groupId"] integerValue];
    if( nGroupId > 0 )
    {
        [arM_Test addObject:@{@"type":@"normal", @"contents":@"단원보기"}];
    }
    
    //    if( self.isAnotherUser == NO )
    if( 1 )
    {
        //결과보기 버튼 유무
        NSInteger nFinishCount = [[dic objectForKey:@"isFinishCount"] integerValue];
        NSInteger nSolve = [[dic objectForKey:@"isSolve"] integerValue];
        if( nFinishCount > 0 || nSolve == 1 )
        {
            //표시
            [arM_Test addObject:@{@"type":@"result", @"contents":@"결과보기"}];
        }
    }
    
    if( [[dic objectForKey:@"isPaid"] isEqualToString:@"paid"] )
    {
        //구매 했을 경우에만 별점 띄우기
        [arM_Test addObject:@{@"type":@"star", @"contents":@"평가", @"data":dic}];
    }
    
    ActionSheetBottomViewController *vc = [kEtcBoard instantiateViewControllerWithIdentifier:@"ActionSheetBottomViewController"];
    vc.arM_List = arM_Test;
    [vc setCompletionStarBlock:^(id completeResult) {
        
        if( self.seg.selectedSegmentIndex == 0 )
        {
            [self.arM_List1 replaceObjectAtIndex:btn.tag withObject:completeResult];
        }
        else
        {
            [self.arM_List2 replaceObjectAtIndex:btn.tag withObject:completeResult];
        }
        
    }];
    
    [vc setCompletionBlock:^(id completeResult) {
        
        NSString *str_Type = [completeResult objectForKey:@"type"];
        if( [str_Type isEqualToString:@"info"] )
        {
            //정보
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            QuestionDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"QuestionDetailViewController"];
            vc.str_Idx = [NSString stringWithFormat:@"%@", [dic objectForKey:@"examId"]];
            vc.str_Title = [dic objectForKey:@"examTitle"];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if( [str_Type isEqualToString:@"share"] )
        {
            //공유
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chatting" bundle:nil];
            SharedViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SharedViewController"];
            vc.hidesBottomBarWhenPushed = YES;
            vc.str_ExamId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"examId"]];
            vc.str_QuestionId = @"0";
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if( [str_Type isEqualToString:@"normal"] )
        {
            //단원보기
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
            GroupWebViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"GroupWebViewController"];
            vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"groupId"] integerValue]];
            vc.str_GroupName = [dic objectForKey_YM:@"groupName"];
            vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if( [str_Type isEqualToString:@"result"] )
        {
            //결과보기
            NSInteger nGrade = [[dic objectForKey:@"personGrade"] integerValue];
            NSString *str_Grade = [NSString stringWithFormat:@"%@ %@학년", [dic objectForKey:@"schoolGrade"], nGrade == 0 ? @"전체" : [NSString stringWithFormat:@"%ld", nGrade]];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
            ReportDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ReportDetailViewController"];
            vc.str_Title = [NSString stringWithFormat:@"%@ %@ %@", [dic objectForKey:@"subjectName"], str_Grade, [dic objectForKey:@"publisherName"]];
            vc.str_ExamId = [dic objectForKey:@"examId"];
            vc.str_PUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
            [self presentViewController:vc animated:YES completion:^{
                
            }];
        }
    }];
    
    [self presentViewController:vc animated:YES completion:^{
        
    }];
    
}



- (IBAction)goSegChange:(id)sender
{
    if( self.seg.selectedSegmentIndex == 0 )
    {
        [UIView animateWithDuration:0.3f animations:^{
           
            self.sv_Contents.contentOffset = CGPointZero;;
        }];
    }
    else
    {
        [UIView animateWithDuration:0.3f animations:^{
            
            self.sv_Contents.contentOffset = CGPointMake(self.sv_Contents.frame.size.width, 0);
        }];
    }
}

@end
