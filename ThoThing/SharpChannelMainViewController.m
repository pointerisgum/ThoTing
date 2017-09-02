//
//  SharpChannelMainViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 1. 25..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "SharpChannelMainViewController.h"
#import "MyQuestionListCell.h"
#import "QuestionStartViewController.h"
#import "ActionSheetBottomViewController.h"
#import "SharedViewController.h"
#import "GroupWebViewController.h"
#import "ReportDetailViewController.h"
#import "ReportMainViewController.h"
#import "UserControllListViewController.h"
#import "QuestionDetailViewController.h"
#import "WrongAnsStarViewController.h"

@interface SharpChannelMainViewController ()
{
    BOOL isLoding;
}
@property (nonatomic, strong) NSString *str_CurrentSubjectName;
@property (nonatomic, strong) NSDictionary *dic_Data;
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) NSMutableArray *arM_SubjectList;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_SubTitle;
@property (nonatomic, weak) IBOutlet UIView *v_Header;
@property (nonatomic, weak) IBOutlet UIButton *btn_TotalUser;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_SubjectList;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@end

@implementation SharpChannelMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tbv_List.tableHeaderView = self.v_Header;
    [self updateList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;

//    if( self.isShowNavi )
//    {
//        self.navigationController.navigationBarHidden = NO;
//    }
//    else
//    {
//        self.navigationController.navigationBarHidden = YES;
//    }
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
    NSString *str_ChannelHashTag = [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"channelHashTag"]];
    str_ChannelHashTag = [str_ChannelHashTag stringByReplacingOccurrencesOfString:@"#" withString:@""];

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"hashtagChannelId"]], @"channelId",
//                                        @"keywordTag", @"channelType",
                                        @"schoolTag", @"channelType",
                                        str_ChannelHashTag, @"channelHashTag",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/hashtag/channel"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            self.dic_Data = [NSDictionary dictionaryWithDictionary:resulte];
                                            
                                            self.lb_Title.text = [resulte objectForKey:@"channelHashTag"];
                                            self.lb_SubTitle.text = [NSString stringWithFormat:@"(%@)", [resulte objectForKey:@"region"]];
                                            
                                            NSString *str_TotalUser = [NSString stringWithFormat:@"%@명", [resulte objectForKey:@"hashTagUserCount"]];
                                            [self.btn_TotalUser setTitle:str_TotalUser forState:UIControlStateNormal];
                                            
                                            self.arM_SubjectList = [NSMutableArray array];
//                                            [self.arM_SubjectList addObject:@{@"subjectName":@"업로드",
//                                                                                              @"examCount":[NSString stringWithFormat:@"%@", [resulte objectForKey:@"hashTagUploadExamCount"]]}];
                                            
                                            //nInCorrectQuestionCount + nStarQuestionCount]}];
                                            [self.arM_SubjectList addObject:@{@"subjectName":@"오답,별표",
                                                                              @"examCount":[NSString stringWithFormat:@"%ld",
                                                                                            [[resulte objectForKey:@"inCorrectQuestionCount"] integerValue] +
                                                                                            [[resulte objectForKey:@"starQuestionCount"] integerValue]]}];

                                            [self.arM_SubjectList addObject:@{@"subjectName":@"전체",
                                                                                              @"examCount":[NSString stringWithFormat:@"%@", [resulte objectForKey:@"hashTagExamCount"]]}];

                                            [self.arM_SubjectList addObjectsFromArray:[resulte objectForKey:@"hashTagExamSubjectNameInfo"]];
                                            [self updateSubjectList];

                                            [self.tbv_List reloadData];
                                        }
                                    }];
}

- (void)updateSubjectList
{
    BOOL isFirst = YES;
    for( id subView in self.sv_SubjectList.subviews )
    {
        if( [subView isKindOfClass:[UIButton class]] )
        {
            isFirst = NO;
        }
    }
    
    if( isFirst )
    {
        for( NSInteger i = 0; i < self.arM_SubjectList.count; i++ )
        {
            NSDictionary *dic = self.arM_SubjectList[i];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = i;
            btn.frame = CGRectMake(i * 70, 0, 70, 50);
            btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            [btn.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
            
            NSString *str_Title = [NSString stringWithFormat:@"%@\n%@", [dic objectForKey:@"examCount"], [dic objectForKey:@"subjectName"]];
            [btn setTitle:str_Title forState:UIControlStateNormal];
            
            if( [[dic objectForKey:@"subjectName"] isEqualToString:@"레포트"] )
            {
                [btn setTitleColor:[UIColor colorWithHexString:@"4FB826"] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(onReportTouchDown:) forControlEvents:UIControlEventTouchDown];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                [btn setBackgroundImage:BundleImage(@"rect_green.png") forState:UIControlStateHighlighted];
            }
            else if( [[dic objectForKey:@"subjectName"] isEqualToString:@"오답,별표"] )
            {
                [btn setTitleColor:[UIColor colorWithHexString:@"F62B00"] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(onReportTouchDown:) forControlEvents:UIControlEventTouchDown];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                [btn setBackgroundImage:BundleImage(@"rect_red.png") forState:UIControlStateHighlighted];
            }
            else
            {
                [btn setTitleColor:kMainColor forState:UIControlStateNormal];
            }
            
            if( [[dic objectForKey:@"subjectName"] isEqualToString:@"전체"] )
            {
                btn.selected = YES;
            }
            
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            
            [btn addTarget:self action:@selector(onMenuSelected:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.sv_SubjectList addSubview:btn];
        }
        
        self.sv_SubjectList.contentSize = CGSizeMake(70 * self.arM_SubjectList.count, 0);
        
        [self updateTableView:@"전체"];
    }
}

- (void)onReportTouchDown:(UIButton *)btn
{
    if( [btn.titleLabel.text rangeOfString:@"레포트"].location != NSNotFound )
    {
        [btn setBackgroundImage:BundleImage(@"rect_green.png") forState:UIControlStateNormal];
    }
    else if( [btn.titleLabel.text rangeOfString:@"오답,별표"].location != NSNotFound )
    {
        [btn setBackgroundImage:BundleImage(@"rect_red.png") forState:UIControlStateNormal];
    }
    
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self performSelector:@selector(onRemoveInteraction:) withObject:btn afterDelay:0.5f];
}

- (void)onReportTouchCancel:(UIButton *)btn
{
    if( [btn.titleLabel.text rangeOfString:@"레포트"].location != NSNotFound )
    {
        [btn setTitleColor:[UIColor colorWithHexString:@"4FB826"] forState:UIControlStateNormal];
    }
    else if( [btn.titleLabel.text rangeOfString:@"오답,별표"].location != NSNotFound )
    {
        [btn setTitleColor:[UIColor colorWithHexString:@"F62B00"] forState:UIControlStateNormal];
    }
    
    [btn setBackgroundImage:BundleImage(@"") forState:UIControlStateNormal];
}

- (void)onRemoveInteraction:(UIButton *)btn
{
    if( [btn.titleLabel.text rangeOfString:@"레포트"].location != NSNotFound )
    {
        [btn setTitleColor:[UIColor colorWithHexString:@"4FB826"] forState:UIControlStateNormal];
    }
    else if( [btn.titleLabel.text rangeOfString:@"오답,별표"].location != NSNotFound )
    {
        [btn setTitleColor:[UIColor colorWithHexString:@"F62B00"] forState:UIControlStateNormal];
    }
    
    [btn setBackgroundImage:BundleImage(@"") forState:UIControlStateNormal];
}

- (void)onMenuSelected:(UIButton *)btn
{
    NSDictionary *dic = self.arM_SubjectList[btn.tag];
    
    if( btn.tag != 0 )
    {
        for( id subView in self.sv_SubjectList.subviews )
        {
            if( [subView isKindOfClass:[UIButton class]] )
            {
                UIButton *btn_Sub = (UIButton *)subView;
                btn_Sub.selected = NO;
            }
        }
        
        btn.selected = YES;
    }
    
    [self.arM_List removeAllObjects];
    self.arM_List = nil;
    
    [self updateTableView:[dic objectForKey:@"subjectName"]];
}

- (void)updateTableView:(NSString *)aSubject
{
//    if( [aSubject isEqualToString:@"레포트"] )
//    {
//        ReportMainViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportMainViewController"];
//        vc.str_ChannelId = self.str_ChannelId;
//        vc.str_UserId = self.str_UserIdx;
//        [self.navigationController pushViewController:vc animated:YES];
//        
//        return;
//    }
    
    if( [aSubject isEqualToString:@"오답,별표"] )
    {
        WrongAnsStarViewController *vc = [kEtcBoard instantiateViewControllerWithIdentifier:@"WrongAnsStarViewController"];
        [self.navigationController pushViewController:vc animated:YES];
        
        return;
    }
    
    if( isLoding )
    {
        return;
    }

    self.str_CurrentSubjectName = aSubject;
    
    NSString *str_ChannelHashTag = [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"channelHashTag"]];
    str_ChannelHashTag = [str_ChannelHashTag stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"hashtagChannelId"]], @"channelId",
                                        @"schoolTag", @"channelType",
                                        str_ChannelHashTag, @"channelHashTag",
//                                        @"138", @"pUserId",
                                        @"10", @"limitCount",
                                        @"0", @"offsetCount",
                                        nil];
    
    if( [aSubject isEqualToString:@"전체"] )
    {
        [dicM_Params setObject:@"0" forKey:@"subjectName"];
    }
    else
    {
        [dicM_Params setObject:aSubject forKey:@"subjectName"];
    }
    
    if( self.arM_List.count > 0 )
    {
//        NSDictionary *dic = [self.arM_List lastObject];
//        NSString *str_LastExamId = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"examId"]];
        [dicM_Params setObject:[NSString stringWithFormat:@"%ld", self.arM_List.count] forKey:@"offsetCount"];
    }
    
    isLoding = YES;
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/package/exam/browse"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                if( self.arM_List == nil || self.arM_List.count <= 0 )
                                                {
                                                    self.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"examListInfos"]];
                                                }
                                                else
                                                {
                                                    [self.arM_List addObjectsFromArray:[resulte objectForKey:@"examListInfos"]];
                                                }
                                                
                                                [self.tbv_List reloadData];
                                            }
                                            else if( nCode == 201 )
                                            {
                                                
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                        
                                        isLoding = NO;
                                    }];
    
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if( scrollView == self.tbv_List && scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height - 20 && self.arM_List.count > 0 )
    {
        if( isLoding == NO )
        {
            [self updateTableView:self.str_CurrentSubjectName];
        }
    }
}



#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.arM_List.count;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyQuestionListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyQuestionListCell"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    cell.v_Base.clipsToBounds = YES;
    cell.v_Base.layer.borderColor = [UIColor colorWithRed:200.f/255.f green:200.f/255.f blue:200.f/255.f alpha:1].CGColor;
    cell.v_Base.layer.borderWidth = 0.5f;

    cell.btn_Group.tag = cell.btn_Result.tag = indexPath.section;
    
    NSDictionary *dic = self.arM_List[indexPath.section];
    
//    //채널관리자가 왔을때 내 나와바리 여부에 따른 처리
//    if( self.isManagerView )
//    {
//        //관리자가 들어 왔을시
//        //            if( self.isPermission && [[dic objectForKey:@"isChannelAdmin"] isEqualToString:@"Y"] )
//        if( 1 )
//        {
//            //권한이 있고, 이 채널의 어드민이면
//            cell.v_Progess.alpha = cell.btn_Result.alpha = cell.btn_Group.alpha = YES;
//        }
//        else
//        {
//            cell.v_Progess.alpha = cell.btn_Result.alpha = cell.btn_Group.alpha = NO;
//        }
//    }
    
    cell.iv_Thumb.backgroundColor = [UIColor colorWithHexString:[dic objectForKey_YM:@"codeHex"]];
    
    //문제집 제목
    cell.lb_QuestionTitle.text = [dic objectForKey:@"subjectName"];
    
    //제목
    cell.lb_Title.text = [dic objectForKey:@"examTitle"];
    
    //학교 학년
    cell.lb_Grade.text = [NSString stringWithFormat:@"%@  문제 %@  USER %@명",
                          [dic objectForKey:@"schoolGrade"], [dic objectForKey:@"questionCount"], [dic objectForKey:@"examUniqueUserCount"]];
    
    
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
    
    cell.btn_Info.tag = indexPath.section;
    [cell.btn_Info addTarget:self action:@selector(onItemInfo:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    if( self.isManagerView )    return;
    
    NSDictionary *dic = self.arM_List[indexPath.section];
    
    QuestionStartViewController  *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionStartViewController"];
    //        vc.hidesBottomBarWhenPushed = YES;
    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
    vc.str_StartIdx = @"0";
    vc.str_Title = [dic objectForKey:@"examTitle"];
    vc.str_UserIdx = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    vc.isPdf = [[dic objectForKey:@"examType"] isEqualToString:@"pdfExam"];
    vc.str_ChannelId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v_Section = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10.f)];
    v_Section.backgroundColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1];
    return v_Section;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 5.0f;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    UIView *v_Section = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 5.f)];
//    v_Section.backgroundColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1];
//    return v_Section;
//}

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


    //    헤더고정
    CGFloat sectionHeaderHeight = 10.f;
    if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0)
    {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (scrollView.contentOffset.y>=sectionHeaderHeight)
    {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}


- (void)onItemInfo:(UIButton *)btn
{
    NSDictionary *dic = self.arM_List[btn.tag];
    
    NSMutableArray *arM_Test = [NSMutableArray array];
    [arM_Test addObject:@{@"type":@"info", @"contents":[dic objectForKey:@"examTitle"]}];
    [arM_Test addObject:@{@"type":@"share", @"contents":@"공유"}];
    
    //단원보기 버튼 유무
    NSInteger nGroupId = [[dic objectForKey:@"groupId"] integerValue];
    if( nGroupId > 0 )
    {
        [arM_Test addObject:@{@"type":@"normal", @"contents":@"단원보기"}];
    }
    
    
    //결과보기 버튼 유무
    NSInteger nFinishCount = [[dic objectForKey:@"isFinishCount"] integerValue];
    NSInteger nSolve = [[dic objectForKey:@"isSolve"] integerValue];
    if( nFinishCount > 0 || nSolve == 1 )
    {
        //표시
        [arM_Test addObject:@{@"type":@"result", @"contents":@"결과보기"}];
    }
    
    if( [[dic objectForKey:@"isPaid"] isEqualToString:@"paid"] )
    {
        //구매 했을 경우에만 별점 띄우기
        [arM_Test addObject:@{@"type":@"star", @"contents":@"평가", @"data":dic}];
    }
    
    ActionSheetBottomViewController *vc = [kEtcBoard instantiateViewControllerWithIdentifier:@"ActionSheetBottomViewController"];
    vc.arM_List = arM_Test;
    [vc setCompletionStarBlock:^(id completeResult) {
        
        [self.arM_List replaceObjectAtIndex:btn.tag withObject:completeResult];
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


- (IBAction)goSchoolList:(id)sender
{
    UserControllListViewController *vc = [kEtcBoard instantiateViewControllerWithIdentifier:@"UserControllListViewController"];
    vc.isMannager = NO;
    vc.str_ChannelId = [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"hashtagChannelId"]];
    vc.str_Mode = @"sharp";
    vc.str_ChannelType = @"schoolTag";
    vc.str_ChannelHashTag = [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"channelHashTag"]];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
