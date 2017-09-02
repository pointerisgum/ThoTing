//
//  LibraryMainViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 6. 7..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "LibraryMainViewController.h"
#import "LibrarySubjectCell.h"
#import "LibraryTopCell.h"
#import "QuestionStartViewController.h"
#import "MyQuestionListCell.h"
#import "ActionSheetBottomViewController.h"
#import "QuestionDetailViewController.h"
#import "SharedViewController.h"
#import "GroupWebViewController.h"
#import "ReportDetailViewController.h"
#import "WrongAnsStarViewController.h"
#import "UploadListViewController.h"
#import "ReciveSendViewController.h"
#import "SearchBarViewController.h"
#import "LibrarySectionCell.h"

@interface LibraryMainViewController ()
{
    BOOL isUserMode;
    NSInteger nSelectedSubjectIdx;
    NSInteger nInCorrectQuestionCount;  //오답 카운트
    NSInteger nStarQuestionCount;       //별표 카운트
    NSInteger nUploadExamCount;         //업로드 카운트
}
@property (nonatomic, strong) NSMutableArray *arM_TopList;
@property (nonatomic, strong) NSMutableArray *arM_Subject;
@property (nonatomic, strong) NSMutableArray *arM_BottomList;
@property (nonatomic, strong) NSMutableDictionary *dicM_Data;
@property (nonatomic, weak) IBOutlet UIImageView *iv_ReceiveSendNew;
@property (nonatomic, weak) IBOutlet UITableView *tbv_TopList;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_TopHeight;
@property (nonatomic, weak) IBOutlet UICollectionView *cv_Subject;
@property (nonatomic, weak) IBOutlet UITableView *tbv_BottomList;
@property (nonatomic, weak) IBOutlet UIButton *btn_Close;
@end

@implementation LibraryMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1];  //탭바 사이즈를 줄였더니 self.view의 백그라운드 색이 보여서 처리함

    nSelectedSubjectIdx = 0;
    self.lc_TopHeight.constant = 0.f;
    
//    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                                        [Util getUUID], @"uuid",
//                                        nil];
//    
//    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/manage/channel/list"
//                                        param:dicM_Params
//                                   withMethod:@"GET"
//                                    withBlock:^(id resulte, NSError *error) {
//                                        
//                                        if( resulte )
//                                        {
//                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
//                                            if( nCode == 200 )
//                                            {
//                                                NSArray *ar = [NSArray arrayWithArray:[resulte objectForKey:@"channelInfos"]];
//                                                if( ar && ar.count > 0 )
//                                                {
//                                                    [[NSUserDefaults standardUserDefaults] setObject:@"Y" forKey:@"isTeacher"];
//                                                }
//                                                else
//                                                {
//                                                    [[NSUserDefaults standardUserDefaults] setObject:@"N" forKey:@"isTeacher"];
//                                                }
//                                                
//                                                [[NSUserDefaults standardUserDefaults] synchronize];
//                                            }
//                                        }
//                                    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    NSString *str_Key = [NSString stringWithFormat:@"DefaultChannel_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSString *str_DefaultChannel = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
    if( [str_DefaultChannel isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]] )
    {
        //유저
        isUserMode = YES;
        [self updateUserList];
    }
    else if( str_DefaultChannel == nil || str_DefaultChannel.length <= 0 )
    {
        //유저
        isUserMode = YES;
        [self updateUserList];
    }
    else
    {
        //채널
        isUserMode = NO;
        [self updateChannelList];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    NSString *str_Path = [NSString stringWithFormat:@"%@/api/v1/get/my/page/package/exam/browse", kBaseUrl];
//    [[WebAPI sharedData] cancelMethod:@"GET" withPath:str_Path];
}

- (void)updateUserList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"], @"pUserId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/user/my"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            nUploadExamCount = [[resulte objectForKey:@"myUploadExamCount"] integerValue];
                                            nInCorrectQuestionCount = [[resulte objectForKey:@"inCorrectQuestionCount"] integerValue];
                                            nStarQuestionCount = [[resulte objectForKey:@"starQuestionCount"] integerValue];
                                            
                                            self.arM_TopList = [NSMutableArray array];
                                            
                                            CGFloat fTopListHeight = 0;
                                            
                                            if( nUploadExamCount > 0 && (nInCorrectQuestionCount + nStarQuestionCount) > 0 )
                                            {
                                                fTopListHeight = 60.f;
                                                
                                                if( nUploadExamCount > (nInCorrectQuestionCount + nStarQuestionCount) )
                                                {
                                                    [self.arM_TopList addObject:@{@"title":@"올린문제",
                                                                                  @"count":[NSString stringWithFormat:@"%ld", nUploadExamCount]}];
                                                    
                                                    if( 1 )
                                                    {
                                                        [self.arM_TopList addObject:@{@"title":@"오답,별표",
                                                                                      @"count":[NSString stringWithFormat:@"%ld", nInCorrectQuestionCount + nStarQuestionCount]}];
                                                        
                                                        fTopListHeight += 60.f;
                                                    }
                                                }
                                                else
                                                {
                                                    if( 1 )
                                                    {
                                                        [self.arM_TopList addObject:@{@"title":@"오답,별표",
                                                                                      @"count":[NSString stringWithFormat:@"%ld", nInCorrectQuestionCount + nStarQuestionCount]}];
                                                        
                                                        fTopListHeight += 60.f;
                                                    }
                                                    
                                                    [self.arM_TopList addObject:@{@"title":@"올린문제",
                                                                                  @"count":[NSString stringWithFormat:@"%ld", nUploadExamCount]}];
                                                }
                                            }
                                            else if( nUploadExamCount > 0 )
                                            {
                                                fTopListHeight = 60.f;
                                                [self.arM_TopList addObject:@{@"title":@"올린문제",
                                                                              @"count":[NSString stringWithFormat:@"%ld", nUploadExamCount]}];
                                            }
                                            else if( nInCorrectQuestionCount > 0 || nStarQuestionCount > 0 )
                                            {
                                                fTopListHeight = 60.f;
                                                if( 1 )
                                                {
                                                    [self.arM_TopList addObject:@{@"title":@"오답,별표",
                                                                                  @"count":[NSString stringWithFormat:@"%ld", nInCorrectQuestionCount + nStarQuestionCount]}];
                                                }
                                            }
                                            
                                            [self.tbv_TopList reloadData];
                                            self.lc_TopHeight.constant = fTopListHeight;
                                            
                                            self.arM_Subject = [NSMutableArray array];
                                            [self.arM_Subject addObject:@{@"examCount":[NSString stringWithFormat:@"%ld", [[resulte objectForKey:@"myPaidExamCount"] integerValue]],
                                                                          @"subjectName":@"전체"}];
                                            [self.arM_Subject addObjectsFromArray:[resulte objectForKey:@"myPaidSubjectNameInfos"]];
                                            [self.cv_Subject reloadData];
                                            
                                            [self updateBottomList];
                                        }
                                    }];
}

- (void)updateChannelList
{
    NSString *str_Key2 = [NSString stringWithFormat:@"DefaultChannelId_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSString *str_ChannelId = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key2];

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        str_ChannelId, @"channelId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/my"
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
                                                nUploadExamCount = [[resulte objectForKey:@"uploadExamCount"] integerValue];

                                                self.arM_TopList = [NSMutableArray array];
                                                [self.arM_TopList addObject:@{@"title":@"올린문제",
                                                                              @"count":[NSString stringWithFormat:@"%ld", nUploadExamCount]}];
                                                [self.tbv_TopList reloadData];
                                                self.lc_TopHeight.constant = 60.f;

                                                self.dicM_Data = [NSMutableDictionary dictionaryWithDictionary:resulte];
                                                [self updateData];
                                                [self updateChannelBottomList];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

- (void)updateBottomList
{
    NSString *str_Key = [NSString stringWithFormat:@"DefaultChannel_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSString *str_DefaultChannel = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
    if( [str_DefaultChannel isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]] )
    {
        //유저
        isUserMode = YES;
        [self updateUserBottomList];
    }
    else if( str_DefaultChannel == nil || str_DefaultChannel.length <= 0 )
    {
        //유저
        isUserMode = YES;
        [self updateUserBottomList];
    }
    else
    {
        //채널
        isUserMode = NO;
        [self updateChannelBottomList];
    }

    
}

- (void)updateUserBottomList
{
    NSDictionary *dic = self.arM_Subject[nSelectedSubjectIdx];
    NSString *str_SubjectName = [dic objectForKey:@"subjectName"];
    
    BOOL isShowIndicator = YES;
    NSString *str_Key = [NSString stringWithFormat:@"Library_%@_%@_%@",//Upload_전체_138
                         @"Paid",
                         str_SubjectName,
                         [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSData *dictionaryData = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
    NSDictionary *resulte = [NSKeyedUnarchiver unarchiveObjectWithData:dictionaryData];
    if( resulte )
    {
        isShowIndicator = NO;
        self.arM_BottomList = [NSMutableArray arrayWithArray:[resulte objectForKey:@"recommendInfo"]];
        [self.tbv_BottomList reloadData];
    }
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"], @"pUserId",
                                        nil];
    
    if( [str_SubjectName isEqualToString:@"전체"] )
    {
        [dicM_Params setObject:@"" forKey:@"subjectName"];
    }
    else
    {
        [dicM_Params setObject:str_SubjectName forKey:@"subjectName"];
    }
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/page/package/exam/browse"
                                        param:dicM_Params
                                   withMethod:@"GET"
                            withShowIndicator:isShowIndicator
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:resulte];
                                                [[NSUserDefaults standardUserDefaults] setObject:data forKey:str_Key];
                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                
                                                self.arM_BottomList = [NSMutableArray arrayWithArray:[resulte objectForKey:@"recommendInfo"]];
                                                [self.tbv_BottomList reloadData];
                                            }
                                        }
                                    }];
}

- (void)updateData
{
    self.arM_Subject = [NSMutableArray array];
    [self.arM_Subject addObject:@{@"subjectName":@"전체",
                                      @"examCount":[NSString stringWithFormat:@"%@", [self.dicM_Data objectForKey:@"channelExamCount"]]}];
    
    [self.arM_Subject addObjectsFromArray:[self.dicM_Data objectForKey:@"channelExamSubjectNameInfos"]];

    [self.cv_Subject reloadData];
    
//    [self.tbv_BottomList reloadData];
}

- (void)updateChannelBottomList
{
    NSDictionary *dic = self.arM_Subject[nSelectedSubjectIdx];
    NSString *str_SubjectName = [dic objectForKey:@"subjectName"];

    NSString *str_Key2 = [NSString stringWithFormat:@"DefaultChannelId_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSString *str_ChannelId = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key2];

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        str_ChannelId, @"channelId",
                                        @"channel", @"channelType",
                                        @"", @"channelHashTag",
                                        nil];
    
    if( [str_SubjectName isEqualToString:@"전체"] )
    {
        [dicM_Params setObject:@"0" forKey:@"subjectName"];
    }
    else
    {
        [dicM_Params setObject:str_SubjectName forKey:@"subjectName"];
    }
    
    //    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/package/exam/browse"
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/my/exam" //02.10일 제권님이 api를 바꿔달라는 요청으로 수정함
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                self.arM_BottomList = [NSMutableArray arrayWithArray:[resulte objectForKey:@"examListInfos"]];
                                                [self.tbv_BottomList reloadData];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
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

#pragma mark - UISearchBarDelegate
- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    UINavigationController *navi = [storyboard instantiateViewControllerWithIdentifier:@"SearchNavi"];
    SearchBarViewController *vc = [navi.viewControllers firstObject];
    vc.isLibraryMode = YES;
    [self presentViewController:navi animated:YES completion:^{
        
    }];
    
    return NO;
}


#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if( tableView == self.tbv_TopList )
    {
        return 1;
    }
    
    return self.arM_BottomList.count;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( tableView == self.tbv_TopList )
    {
        return self.arM_TopList.count;
    }
    
    if( isUserMode == NO )
    {
        return 1;
    }
    
    NSDictionary *dic_Main = self.arM_BottomList[section];
    NSArray *ar = [dic_Main objectForKey:@"examInfos"];
    return ar.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( tableView == self.tbv_TopList )
    {
        LibraryTopCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LibraryTopCell"];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        NSDictionary *dic = self.arM_TopList[indexPath.row];
        NSString *str_Title = [dic objectForKey:@"title"];
        NSString *str_Count = [dic objectForKey:@"count"];
        
        if( [str_Title rangeOfString:@"올린문제"].location != NSNotFound )
        {
            cell.iv_Icon.image = BundleImage(@"upload_icon.png");
        }
        else if( [str_Title rangeOfString:@"오답"].location != NSNotFound )
        {
            cell.iv_Icon.image = BundleImage(@"star_icon.png");
        }

        cell.lb_Title.text = str_Title;
        cell.lb_Count.text = str_Count;

        if( indexPath.row >= self.arM_TopList.count - 1 )
        {
            cell.iv_UnderBar.hidden = YES;
        }
        else
        {
            cell.iv_UnderBar.hidden = NO;
        }
        
        return cell;
    }
    
    MyQuestionListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyQuestionListCell"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    cell.v_Base.clipsToBounds = YES;
    cell.v_Base.layer.borderColor = [UIColor colorWithRed:200.f/255.f green:200.f/255.f blue:200.f/255.f alpha:1].CGColor;
    cell.v_Base.layer.borderWidth = 0.5f;
    
    cell.btn_Group.tag = cell.btn_Result.tag = indexPath.row;
    
    NSDictionary *dic = nil;
    NSDictionary *dic_Main = self.arM_BottomList[indexPath.section];
    if( isUserMode )
    {
        NSArray *ar = [dic_Main objectForKey:@"examInfos"];
        dic = ar[indexPath.row];
    }
    else
    {
        dic = dic_Main;
    }
    
    //채널관리자가 왔을때 내 나와바리 여부에 따른 처리
//    if( self.isManagerView )
    if( 1 )
    {
        //관리자가 들어 왔을시
        //            if( self.isPermission && [[dic objectForKey:@"isChannelAdmin"] isEqualToString:@"Y"] )
        if( 1 )
        {
            //권한이 있고, 이 채널의 어드민이면
            cell.v_Progess.alpha = cell.btn_Result.alpha = cell.btn_Group.alpha = YES;
        }
        else
        {
            cell.v_Progess.alpha = cell.btn_Result.alpha = cell.btn_Group.alpha = NO;
        }
    }
    
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
    
    if( isUserMode )
    {
        cell.btn_Info.tag = (indexPath.section * 10000) + indexPath.row;
    }
    else
    {
        cell.btn_Info.tag = indexPath.section * 10000;
    }
    
    [cell.btn_Info addTarget:self action:@selector(onItemInfo:) forControlEvents:UIControlEventTouchUpInside];

    return cell;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDictionary *dic_Main = self.arM_BottomList[section];

    LibrarySectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LibrarySectionCell"];
//    cell.backgroundColor = [UIColor clearColor];
//    cell.contentView.backgroundColor = [UIColor clearColor];

    NSString *str_Date = [NSString stringWithFormat:@"%@", [dic_Main objectForKey_YM:@"lastDateTime"]];
    if( str_Date && str_Date.length >= 8 )
    {
        NSRange range = NSMakeRange(0, 4);
        NSString *str_Year = [str_Date substringWithRange:range];
        
        range = NSMakeRange(4, 2);
        NSString *str_Month = [str_Date substringWithRange:range];
        
        range = NSMakeRange(6, 2);
        NSString *str_Day = [str_Date substringWithRange:range];
        
        cell.lb_SectionTitle.text = [NSString stringWithFormat:@"%@.%@.%@", str_Year, str_Month, str_Day];
    }
    else
    {
        cell.lb_SectionTitle.text = @"";
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if( tableView == self.tbv_BottomList )
    {
        if( isUserMode )
        {
            return 30.f;
        }
        
        return 10.f;
    }
    
    return 0;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if( tableView == self.tbv_TopList )
    {
        NSDictionary *dic = self.arM_TopList[indexPath.row];
        NSString *str_Title = [dic objectForKey:@"title"];
        
        if( [str_Title rangeOfString:@"올린문제"].location != NSNotFound )
        {
            UploadListViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"UploadListViewController"];
            vc.hidesBottomBarWhenPushed = YES;
            vc.nUploadCount = nUploadExamCount;
            if( isUserMode == NO )
            {
                NSString *str_Key2 = [NSString stringWithFormat:@"DefaultChannelId_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
                NSString *str_ChannelId = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key2];
                vc.str_ChannelId = str_ChannelId;
            }
            
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if( [str_Title rangeOfString:@"오답"].location != NSNotFound )
        {
            WrongAnsStarViewController *vc = [kEtcBoard instantiateViewControllerWithIdentifier:@"WrongAnsStarViewController"];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }

    }
    else if( tableView == self.tbv_BottomList )
    {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
//        if( self.isManagerView )    return;
        
        NSDictionary *dic = nil;
        NSDictionary *dic_Main = self.arM_BottomList[indexPath.section];
        if( isUserMode )
        {
            NSArray *ar = [dic_Main objectForKey:@"examInfos"];
            dic = ar[indexPath.row];
        }
        else
        {
            dic = dic_Main;
        }
        
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
    
    if( scrollView == self.tbv_BottomList )
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


#pragma mark - CollectionView

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arM_Subject.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"LibrarySubjectCell";
    
    LibrarySubjectCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    /*
     examCount = 45;
     subjectName = "\Uc601\Uc5b4";
     */
    
    NSDictionary *dic = self.arM_Subject[indexPath.row];
    NSString *str_Title = [NSString stringWithFormat:@"%ld\n%@", [[dic objectForKey:@"examCount"] integerValue], [dic objectForKey:@"subjectName"]];
    [cell.btn_Title setTitle:str_Title forState:0];

    if( indexPath.row == nSelectedSubjectIdx )
    {
        cell.btn_Title.selected = YES;
    }
    else
    {
        cell.btn_Title.selected = NO;
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    nSelectedSubjectIdx = indexPath.row;
    [self.cv_Subject reloadData];
    [self updateBottomList];
    
    //다른 과목을 선택했을때 스크롤뷰 오프셋 초기화
    [self.tbv_BottomList setContentOffset:CGPointZero animated:NO];
}


- (void)onItemInfo:(UIButton *)btn
{
    NSDictionary *dic = nil;
    NSDictionary *dic_Main = self.arM_BottomList[btn.tag / 10000];
    if( isUserMode )
    {
        NSArray *ar = [dic_Main objectForKey:@"examInfos"];
        dic = ar[btn.tag % 10000];
    }
    else
    {
        dic = dic_Main;
    }
//    NSDictionary *dic_Main = self.arM_BottomList[btn.tag / 10000];
//    NSArray *ar = [dic_Main objectForKey:@"examInfos"];
//    NSDictionary *dic = ar[btn.tag % 10000];
    
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
        
        [self.arM_BottomList replaceObjectAtIndex:btn.tag withObject:completeResult];
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

- (IBAction)goReceiveSend:(id)sender
{
    NSString *str_Key2 = [NSString stringWithFormat:@"DefaultChannelId_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSString *str_ChannelId = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key2];
    
    ReciveSendViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"ReciveSendViewController"];
    vc.str_ChannelId = str_ChannelId;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
