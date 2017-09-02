//
//  ReportMainViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 6. 22..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "ReportMainViewController.h"
#import "ReportDateCell.h"
#import "ReportDateHeaderCell.h"
#import "ReportDetailViewController.h"
#import "ExtendLabel.h"
#import "RankingMainViewController.h"
#import "ActionSheetStringPicker.h"
#import "ReportOtherViewController.h"
#import "ReportSubjectHeaderCell.h"
#import "ReportSubjectTitleCell.h"
#import "ReportSubjectListCell.h"
#import "GroupWebViewController.h"
#import "ReportPopUpViewController.h"

@interface ReportMainViewController () <UITextFieldDelegate>
{
    NSInteger nMainChannelId;   //내가 선택한 채널 아이디
    BOOL isRefresh;
}
@property (nonatomic, strong) NSMutableArray *arM_MyChannelList;
@property (nonatomic, strong) NSMutableArray *arM_SubjectList;
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) NSMutableArray *arM_School;
@property (nonatomic, strong) NSMutableArray *arM_Subject;
@property (nonatomic, assign) NSInteger nSubjectIdx;
@property (nonatomic, assign) NSInteger nSchoolIdx;
//@property (nonatomic, weak) IBOutlet UIButton *btn_Title;
@property (nonatomic, weak) IBOutlet UISegmentedControl *seg;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet UITableView *tbv_SubjectList;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_SearchRight;
@property (nonatomic, weak) IBOutlet UITextField *tf_SearchDate1;
@property (nonatomic, weak) IBOutlet UITextField *tf_SearchDate2;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_School;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Subject;
@end

@implementation ReportMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = NO;

    self.tbv_SubjectList.hidden = YES;
    self.seg.selectedSegmentIndex = 0;
    
//    self.btn_Title.layer.cornerRadius = 5.f;
    
    isRefresh = YES;
    
    self.navigationController.navigationBarHidden = YES;
//    [self initNaviWithTitle:@"나의 레포트" withLeftItem:[self leftBackBlackMenuBarButtonItem] withRightItem:nil withColor:[UIColor colorWithHexString:@"F8F8F8"]];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onNotRefrechNoti) name:@"NotRefrechNoti" object:nil];
    
    [self getSchoolList];
}

- (void)onNotRefrechNoti
{
    isRefresh = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    [MBProgressHUD hide];

    [self updateList];
    
    if( isRefresh )
    {
        [self updateSubjectList];
        isRefresh = NO;
    }
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

- (void)getSchoolList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_UserId, @"ownerId",
                                        nil];
    
    __weak __typeof__(self) weakSelf = self;
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/exam/school"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                weakSelf.arM_School = [NSMutableArray arrayWithArray:[resulte objectForKey:@"schoolInfos"]];
                                                [weakSelf updateSchoolLayout];
                                                
                                                [self getSubjectList];
                                            }
                                        }
                                    }];
}

- (void)getSubjectList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_UserId, @"ownerId",
                                        nil];
    
    NSDictionary *dic_School = self.arM_School[self.nSchoolIdx];
    
    if( dic_School )
    {
        [dicM_Params setObject:[dic_School objectForKey:@"schoolGrade"] forKey:@"schoolGrade"];
    }
    __weak __typeof__(self) weakSelf = self;
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/exam/subjectName"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                weakSelf.arM_Subject = [NSMutableArray arrayWithArray:[resulte objectForKey:@"subjectNames"]];
                                                [weakSelf updateSubjectLayout];
                                                [weakSelf updateSubjectList];
                                            }
                                        }
                                    }];
}

- (void)updateSchoolLayout
{
    CGFloat fX = 15;
    for( NSInteger i = 0; i < self.arM_School.count; i++ )
    {
        NSDictionary *dic = self.arM_School[i];
        NSString *str_Text = [dic objectForKey_YM:@"schoolGrade"];
        if( str_Text.length <= 0 )
        {
            continue;
        }
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(fX, 0, 20 + (str_Text.length * 10), 45);
        [btn setTitle:str_Text forState:UIControlStateNormal];
        [btn setTitleColor:kMainColor forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [btn.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:13.f]];
        if( i == 0 )
        {
            btn.selected = YES;
        }
        
        btn.tag = i;
        [btn addTarget:self action:@selector(onSchoolSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        fX += btn.frame.size.width;
        self.sv_School.contentSize = CGSizeMake(fX + 10, self.sv_School.contentSize.height);
        
        [self.sv_School addSubview:btn];
    }
    
    [self.sv_School setNeedsLayout];
    
    if( self.arM_School.count > 0 )
    {
        self.nSchoolIdx = 0;
    }
}

- (void)updateSubjectLayout
{
    for( id subView in self.sv_Subject.subviews )
    {
        if( [subView isKindOfClass:[UIButton class]] )
        {
            UIButton *btn = (UIButton *)subView;
            [btn removeFromSuperview];
        }
    }
    
    CGFloat fX = 15;
    for( NSInteger i = 0; i < self.arM_Subject.count; i++ )
    {
        NSDictionary *dic = self.arM_Subject[i];
        NSString *str_Text = [dic objectForKey_YM:@"subjectName"];
        if( str_Text.length <= 0 )
        {
            continue;
        }
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(fX, 0, 20 + (str_Text.length * 10), 45);
        [btn setTitle:str_Text forState:UIControlStateNormal];
        [btn setTitleColor:kMainColor forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [btn.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:13.f]];
        if( i == 0 )
        {
            btn.selected = YES;
        }
        
        btn.tag = i;
        [btn addTarget:self action:@selector(onSubjectSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        fX += btn.frame.size.width;
        self.sv_Subject.contentSize = CGSizeMake(fX + 10, self.sv_Subject.contentSize.height);

        [self.sv_Subject addSubview:btn];
    }
    
    [self.sv_Subject setNeedsLayout];
    
    if( self.arM_Subject.count > 0 )
    {
        self.nSubjectIdx = 0;
        [self updateSubjectList];
    }
}

- (void)onSchoolSelected:(UIButton *)btn
{
    for( id subView in self.sv_School.subviews )
    {
        if( [subView isKindOfClass:[UIButton class]] )
        {
            UIButton *btn_Sub = (UIButton *)subView;
            btn_Sub.selected = NO;
        }
    }
    
    btn.selected = YES;
    
    self.nSchoolIdx = btn.tag;
//    [self updateSubjectList];
    [self getSubjectList];
}

- (void)onSubjectSelected:(UIButton *)btn
{
    for( id subView in self.sv_Subject.subviews )
    {
        if( [subView isKindOfClass:[UIButton class]] )
        {
            UIButton *btn_Sub = (UIButton *)subView;
            btn_Sub.selected = NO;
        }
    }
    
    btn.selected = YES;
    
    self.nSubjectIdx = btn.tag;
    [self updateSubjectList];
}

- (void)settingButtonPressed:(UIButton *)btn
{
    if( self.arM_MyChannelList == nil )
    {
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    ReportPopUpViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ReportPopUpViewController"];
    vc.ar_List = self.arM_MyChannelList;
    vc.nSelectedIdx = 0;
    [vc setCompletionBlock:^(id completeResult) {

        NSDictionary *dic = completeResult;

        NSInteger nSelectedIdx = [[dic objectForKey:@"channelId"] integerValue];
        
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"], @"userName",
                                            [NSString stringWithFormat:@"%ld", nSelectedIdx], @"channelId",
                                            nil];
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/change/my/profile"
                                            param:dicM_Params
                                       withMethod:@"POST"
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            if( resulte )
                                            {
                                                NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                if( nCode == 200 )
                                                {
                                                    nMainChannelId = nSelectedIdx;
                                                    
                                                    if( nMainChannelId != 0 )
                                                    {
                                                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
                                                        ReportOtherViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ReportOtherViewController"];
                                                        vc.arM_MyChannelList = self.arM_MyChannelList;
                                                        vc.dic_Info = dic;
                                                        
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"kChangeTabBarController" object:vc];
                                                    }
                                                }
                                                else
                                                {
                                                    [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                }
                                            }
                                        }];
    }];
    
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (void)updateMyReportList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/manage/channel/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                self.arM_MyChannelList = [NSMutableArray arrayWithArray:[resulte objectForKey:@"channelInfos"]];
                                                nMainChannelId = [[resulte objectForKey:@"mainChannelId"] integerValue];
                                            }
                                            else
                                            {
                                                UIAlertView *alert = CREATE_ALERT(nil, [resulte objectForKey:@"error_message"], @"확인", nil);
                                                [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                    
                                                    [self.navigationController popViewControllerAnimated:YES];
                                                }];
                                            }
                                        }
                                    }];
}

- (void)updateSubjectList
{
    __weak __typeof(&*self)weakSelf = self;

    NSDictionary *dic_School = self.arM_School[self.nSchoolIdx];
    NSDictionary *dic_Subject = self.arM_Subject[self.nSubjectIdx];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_UserId, @"ownerId",
                                        [dic_School objectForKey:@"schoolGrade"], @"schoolGrade",
                                        [dic_Subject objectForKey:@"subjectName"], @"subjectName", //과목별 리스트로 가져오는 경우
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/report/subjectName"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                weakSelf.arM_SubjectList = [resulte objectForKey:@"reportData"];
                                                [weakSelf.tbv_SubjectList reloadData];
//                                                for( NSInteger i = 0; i < weakSelf.arM_SubjectList.count; i++ )
//                                                {
//                                                    NSDictionary *dic_Main = weakSelf.arM_SubjectList[i];
//                                                    NSArray *ar_Tmp = [dic_Main objectForKey:@"subjectNameInfos"];
//                                                    
//                                                    NSInteger nCnt = 0;
//                                                    for( NSInteger j = 0; j < ar_Tmp.count; j++ )
//                                                    {
//                                                        NSMutableDictionary *dicM = ar_Tmp[j];
//                                                        NSMutableArray *arM = [NSMutableArray arrayWithArray:[dicM objectForKey:@"examInfos"]];
//                                                        [arM insertObject:@{@"type":@"title", @"obj":[dicM objectForKey:@"subjectName"]} atIndex:0];
//                                                        [dicM setObject:arM forKey:@"examInfos"];
//                                                        NSLog(@"%@", dicM);
//                                                        
//                                                        nCnt += arM.count;
//                                                    }
//                                                }
//                                                
//                                                [weakSelf performSelectorOnMainThread:@selector(reloadInterval) withObject:nil waitUntilDone:YES];
                                            }
                                        }
                                    }];
}

- (void)reloadInterval
{
    [self.tbv_SubjectList reloadData];
}

- (void)updateList
{
    [self updateMyReportList];

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_UserId, @"ownerId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/report/user/daily"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                //성공
                                                self.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"reportInfos"]];
                                                [self.tbv_List reloadData];
                                            }
                                            else
                                            {
//                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}




#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if( tableView == self.tbv_SubjectList )
    {
        return self.arM_SubjectList.count;
    }
    
    return self.arM_List.count;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( tableView == self.tbv_SubjectList )
    {
        NSDictionary *dic_Main = self.arM_SubjectList[section];
        NSArray *ar_Tmp = [dic_Main objectForKey:@"userInfo"];
        if( ar_Tmp.count > 0 )
        {
            NSDictionary *dic_Tmp = [ar_Tmp firstObject];
            NSArray *ar_Solve = [dic_Tmp objectForKey:@"solveInfo"];
            return ar_Solve.count;
        }
        
        return 0;
        
//        NSDictionary *dic_Main = self.arM_SubjectList[section];
//        NSArray *ar_Tmp = [dic_Main objectForKey:@"subjectNameInfos"];
//        
//        NSInteger nCnt = 0;
//        for( NSInteger i = 0; i < ar_Tmp.count; i++ )
//        {
////            NSDictionary *dic = ar_Tmp[i];
//            NSMutableDictionary *dicM = ar_Tmp[i];
////            nCnt += [[dicM objectForKey:@"examInfoCount"] integerValue];
//            NSMutableArray *arM = [NSMutableArray arrayWithArray:[dicM objectForKey:@"examInfos"]];
////            [arM insertObject:@{@"type":@"title", @"obj":[dicM objectForKey:@"subjectName"]} atIndex:0];
//////            [arM addObject:@{@"type":@"title", @"obj":[dicM objectForKey:@"subjectName"]}];
////            [dicM setObject:arM forKey:@"examInfos"];
////            NSLog(@"%@", dicM);
//            
//            nCnt += arM.count;
//        }
//        
//        return nCnt;
    }
    
    NSDictionary *dic = self.arM_List[section];
    NSArray *ar_List = [dic objectForKey:@"data"];
    
    return ar_List.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( tableView == self.tbv_SubjectList )
    {
        NSDictionary *dic_Main = self.arM_SubjectList[indexPath.section];
        NSArray *ar_Tmp = [dic_Main objectForKey:@"userInfo"];
        NSDictionary *dic = nil;
        if( ar_Tmp.count > 0 )
        {
            NSDictionary *dic_Tmp = [ar_Tmp firstObject];
            NSArray *ar_Solve = [dic_Tmp objectForKey:@"solveInfo"];
            dic = ar_Solve[indexPath.row];
        }

        static NSString *CellIdentifier = @"ReportSubjectListCell";
        ReportSubjectListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        //디테일
        cell.btn_Select.dic_Info = dic;
        [cell.btn_Select addTarget:self action:@selector(onDetailSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        
        //그리드
        [cell.btn_Grid removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
        
        if( [[dic objectForKey_YM:@"lectureId"] integerValue] > 0 )
        {
            //단원 있음
            cell.btn_Grid.hidden = NO;
            cell.btn_Grid.tag = [[dic objectForKey_YM:@"groupId"] integerValue];
            cell.btn_Grid.str_SubTitle = [dic objectForKey_YM:@"groupName"];
            [cell.btn_Grid addTarget:self action:@selector(onShowGrid:) forControlEvents:UIControlEventTouchUpInside];
            cell.lc_GridWidth.constant = 30.f;
        }
        else
        {
            //단원 없음
            cell.btn_Grid.hidden = YES;
            cell.lc_GridWidth.constant = 0.f;
        }

        
        //랭킹
        cell.btn_Ranking.dic_Info = dic;
        [cell.btn_Ranking addTarget:self action:@selector(onShowRanking:) forControlEvents:UIControlEventTouchUpInside];

        
        
        NSInteger nGrade = [[dic objectForKey_YM:@"personGrade"] integerValue];
        NSString *str_SchoolGrade = [dic objectForKey_YM:@"schoolGrade"];
        if( [str_SchoolGrade isEqualToString:@"초등학교"] )
        {
            str_SchoolGrade = @"초";
        }
        else if( [str_SchoolGrade isEqualToString:@"중학교"] )
        {
            str_SchoolGrade = @"중";
        }
        else if( [str_SchoolGrade isEqualToString:@"고등학교"] )
        {
            str_SchoolGrade = @"고";
        }

        if( nGrade == 0 )
        {
            cell.lb_Title.text = [NSString stringWithFormat:@"%@ %@", [dic objectForKey_YM:@"examTitle"], str_SchoolGrade];
        }
        else
        {
            cell.lb_Title.text = [NSString stringWithFormat:@"%@ %@%ld", [dic objectForKey_YM:@"examTitle"], str_SchoolGrade, nGrade];
        }
        
        
        //전체 문제수
        cell.lb_QCnt.text = [NSString stringWithFormat:@"문제 %@", [dic objectForKey_YM:@"examQuestionCount"]];
        
        
        //랭킹
        cell.lb_MyRanking.text = [NSString stringWithFormat:@"%@등", [dic objectForKey_YM:@"userRank"]];
        
        //avgScore
        //내 점수
//        CGFloat fOkCount = [[dic objectForKey:@"solveQuestionCount"] floatValue];
//        CGFloat fSuccessCount = [[dic objectForKey:@"correctAnswerCount"] floatValue];
//        cell.lb_Score.text = [NSString stringWithFormat:@"%.0f점", (fSuccessCount/fOkCount) * 100];
        cell.lb_Score.text = [NSString stringWithFormat:@"%@점", [dic objectForKey:@"correctAnswerCount"]];
        
        
        //전체평균 점수
        cell.lb_TotalAvgScore.text = [NSString stringWithFormat:@"전체평균 %@점", [dic objectForKey_YM:@"avgScore"]];
        
        
        //전체 인원수
        cell.lb_TotalUserCount.text = [NSString stringWithFormat:@"전체 %@명", [dic objectForKey_YM:@"totalSolveCount"]];
        
//
//        cell.lb_SubTitle.text = [dic objectForKey_YM:@"publisherName"];
//        
//        cell.lb_Count.text = [NSString stringWithFormat:@"%@", [Util transIntToString:[dic objectForKey_YM:@"solveQuestionCount"]]];
        
        
        return cell;
    }
    
    static NSString *CellIdentifier = @"ReportDateCell";
    ReportDateCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic_Main = self.arM_List[indexPath.section];
    NSArray *ar_List = [dic_Main objectForKey:@"data"];
    NSDictionary *dic = ar_List[indexPath.row];
    
    
//    NSString *str_Grade = [NSString stringWithFormat:@"%@ %@학년", [dic objectForKey:@"schoolGrade"], nGrade == 0 ? @"전체" : [NSString stringWithFormat:@"%ld", nGrade]];
//    cell.lb_Subject.text = [NSString stringWithFormat:@"%@ %@ %@", [dic objectForKey:@"subjectName"], str_Grade, [dic objectForKey:@"publisherName"]];
    
    NSString *str_Score = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"score"] integerValue]];
    NSMutableAttributedString *attM = [[NSMutableAttributedString alloc] initWithString:str_Score];
    UIColor *color = [UIColor blackColor];
    NSString *string = @"점";
    NSDictionary *attrs = @{ NSForegroundColorAttributeName : color };
    NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:string attributes:attrs];
    [attM appendAttributedString:attrStr];
    cell.lb_Score.attributedText = attM;

//    cell.lb_Score.text = [NSString stringWithFormat:@"%ld점", [[dic objectForKey:@"score"] integerValue]];
    
//    cell.lb_ScoreCount.text = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"uRank"] integerValue]];
    
    
    NSString *str_ScoreCount = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"uRank"] integerValue]];
    
    attM = [[NSMutableAttributedString alloc] initWithString:str_ScoreCount];
    color = kMainColor;
    string = @"등";
    attrs = @{ NSForegroundColorAttributeName : color };
    attrStr = [[NSAttributedString alloc] initWithString:string attributes:attrs];
    [attM appendAttributedString:attrStr];
    cell.lb_ScoreCount.attributedText = attM;

    
    
//    cell.lb_ScoreCount.dic_Info = dic;
    

    cell.btn_Ranking.dic_Info = dic;
    [cell.btn_Ranking addTarget:self action:@selector(onShowRanking:) forControlEvents:UIControlEventTouchUpInside];
    
//    cell.lb_ScoreCount.userInteractionEnabled = YES;
//    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cell.btn_Ranking:)];
//    [cell.lb_ScoreCount addGestureRecognizer:tapRecognizer];

    
//    cell.lb_ExamTitle.text = [dic objectForKey:@"examTitle"];
    
    ///////////
    cell.lb_Subject.text = [dic objectForKey_YM:@"examTitle"];
    
    NSInteger nGrade = [[dic objectForKey_YM:@"personGrade"] integerValue];
    NSString *str_Grade = [dic objectForKey_YM:@"schoolGrade"];
//    if( [str_Grade isEqualToString:@"초등학교"] )
//    {
//        str_Grade = @"초";
//    }
//    else if( [str_Grade isEqualToString:@"중학교"] )
//    {
//        str_Grade = @"중";
//    }
//    else if( [str_Grade isEqualToString:@"고등학교"] )
//    {
//        str_Grade = @"고";
//    }
    
    
    NSInteger nQCnt = [[dic objectForKey_YM:@"questionCount"] integerValue];
    cell.lb_SubjectName.text = [dic objectForKey_YM:@"subjectName"];
    cell.lb_TotalQuestionCount.text = [NSString stringWithFormat:@"문제 %ld", nQCnt];
    
    
//    if( nGrade == 0 )
//    {
//        cell.lb_ExamTitle.text = [NSString stringWithFormat:@"%@ %@", [dic objectForKey_YM:@"subjectName"], str_Grade];
//    }
//    else
//    {
//        cell.lb_ExamTitle.text = [NSString stringWithFormat:@"%@ %@ %ld학년", [dic objectForKey_YM:@"subjectName"], str_Grade, nGrade];
//    }
    //////////////
    
    
//    NSMutableString *strM = [NSMutableString string];
    cell.lb_AvgScore.text = [NSString stringWithFormat:@"전체평균 %@점", [dic objectForKey_YM:@"avgScore"]];
    
    cell.lb_TotalCount.text = [NSString stringWithFormat:@"전체 %@명", [dic objectForKey_YM:@"allTesterCount"]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( tableView == self.tbv_SubjectList )
    {
//        NSMutableArray *arM_MyList = [NSMutableArray array];
//        
//        NSDictionary *dic_Main = self.arM_SubjectList[indexPath.section];
//        NSArray *ar_Tmp = [dic_Main objectForKey:@"subjectNameInfos"];
//        for( NSInteger i = 0; i < ar_Tmp.count; i++ )
//        {
//            NSDictionary *dic = ar_Tmp[i];
//            NSArray *ar_Tmp2 = [dic objectForKey:@"examInfos"];
//            for( NSInteger j = 0; j < ar_Tmp2.count; j++ )
//            {
//                [arM_MyList addObject:ar_Tmp2[j]];
//            }
//        }
//        
//        NSDictionary *dic = arM_MyList[indexPath.row];
//        
//        if( [[dic objectForKey:@"type"] isEqualToString:@"title"] == NO )
//        {
//            static NSString *CellIdentifier = @"ReportSubjectTitleCell";
//            ReportSubjectTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//            [tableView deselectRowAtIndexPath:indexPath animated:YES];
//            
//            cell.lb_Title.text = [dic objectForKey:@"obj"];
//            
//            return 80.f;
//        }

        return 80.f;
    }

    return 80;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if( tableView == self.tbv_List )
    {
        NSDictionary *dic_Main = self.arM_List[indexPath.section];
        NSArray *ar_List = [dic_Main objectForKey:@"data"];
        NSDictionary *dic = ar_List[indexPath.row];
        NSLog(@"%@", dic);
        
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
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if( tableView == self.tbv_SubjectList )
    {
        return 50.f;
    }
    
    return 50.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *CellIdentifier = @"ReportDateHeaderCell";
    ReportDateHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if( tableView == self.tbv_SubjectList )
    {
        NSDictionary *dic_Main = self.arM_SubjectList[section];
        NSString *str_Date = [dic_Main objectForKey_YM:@"solveDate"];
        if( str_Date.length >= 8 )
        {
            NSString *str_Year = [str_Date substringWithRange:NSMakeRange(0, 4)];
            NSString *str_Month = [str_Date substringWithRange:NSMakeRange(4, 2)];
            NSString *str_Day = [str_Date substringWithRange:NSMakeRange(6, 2)];
            cell.lb_Date.text = [NSString stringWithFormat:@"%@.%@.%@", str_Year, str_Month, str_Day];
            return cell;
        }
    }
    
    NSDictionary *dic = self.arM_List[section];
    cell.lb_Date.text = [dic objectForKey:@"finishDate"];
    
    return cell;
}

//- (void)rankingTab:(UIGestureRecognizer *)gesture
//{
//    ExtendLabel *lb = (ExtendLabel *)gesture.view;
//    
//    RankingMainViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"RankingMainViewController"];
//    vc.dic_Info = lb.dic_Info;
//    [self presentViewController:vc animated:YES completion:^{
//        
//    }];
//}

- (void)onDetailSelected:(YmExtendButton *)btn
{
    NSDictionary *dic = btn.dic_Info;
    NSLog(@"%@", dic);
    
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

- (void)onShowGrid:(YmExtendButton *)btn
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    GroupWebViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"GroupWebViewController"];
    vc.str_Idx = [NSString stringWithFormat:@"%ld", btn.tag];
    vc.str_GroupName = btn.str_SubTitle;
    vc.isGrupMode = YES;
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onRankingSelected:(YmExtendButton *)btn
{
    
}

- (IBAction)goSegChange:(id)sender
{
    if( self.seg.selectedSegmentIndex == 0 )
    {
        self.tbv_List.hidden = NO;
        self.tbv_SubjectList.hidden = YES;
    }
    else
    {
        self.tbv_List.hidden = YES;
        self.tbv_SubjectList.hidden = NO;
    }
}

- (void)onShowRanking:(YmExtendButton *)btn
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    UINavigationController *navi = [storyboard instantiateViewControllerWithIdentifier:@"RankingNavi"];
    RankingMainViewController *vc = [navi.viewControllers firstObject];
    vc.dic_Info = btn.dic_Info;
    [self presentViewController:navi animated:YES completion:^{
        
    }];
}


- (IBAction)goShowSearch:(id)sender
{
    if( self.lc_SearchRight.constant < 240.f )
    {
        self.lc_SearchRight.constant = 240.f;
        
        [UIView animateWithDuration:0.3f animations:^{
           
            [self.view layoutIfNeeded];
        }];
    }
}

- (IBAction)goCloseSearch:(id)sender
{
    if( self.lc_SearchRight.constant >= 240.f )
    {
        self.lc_SearchRight.constant = 0.f;
        
        [UIView animateWithDuration:0.3f animations:^{
            
            [self.view layoutIfNeeded];
        }completion:^(BOOL finished) {
            
            self.tf_SearchDate1.text = self.tf_SearchDate2.text = @"";
        }];
    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if( textField == self.tf_SearchDate1 || textField == self.tf_SearchDate2 )
    {
        return NO;
    }
    
    return YES;
}

@end
