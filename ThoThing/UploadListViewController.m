//
//  UploadListViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 6. 8..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "UploadListViewController.h"
#import "MyQuestionListCell.h"
#import "QuestionStartViewController.h"
#import "LibrarySubjectCell.h"
#import "ActionSheetBottomViewController.h"
#import "QuestionDetailViewController.h"
#import "SharedViewController.h"
#import "GroupWebViewController.h"
#import "ReportDetailViewController.h"
#import "LibrarySectionCell.h"

@interface UploadListViewController ()
{
    NSInteger nSelectedSubjectIdx;
}
@property (nonatomic, strong) NSMutableArray *arM_Subject;
@property (nonatomic, strong) NSMutableArray *arM_BottomList;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UICollectionView *cv_Subject;
@property (nonatomic, weak) IBOutlet UITableView *tbv_BottomList;
@end

@implementation UploadListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    nSelectedSubjectIdx = 0;
    
    NSString *str_Header = @"올린문제 ";
    NSString *str_Tail = [NSString stringWithFormat:@"%ld", self.nUploadCount];
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:
                                       [NSString stringWithFormat:@"%@%@", str_Header, str_Tail]];
    [text addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:18.0f],
                          NSForegroundColorAttributeName : [UIColor lightGrayColor]}
                  range:NSMakeRange(str_Header.length, str_Tail.length)];
    
//    [text addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:15.0f],
//                          NSForegroundColorAttributeName : kMainRedColor}
//                  range:NSMakeRange(str_Header.length + 1, str_Tail.length)];
//    
//    [text addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:15.0f],
//                          NSForegroundColorAttributeName : [UIColor blackColor]}
//                  range:NSMakeRange(str_Header.length + str_Tail.length + 1, 1)];
    
    self.lb_Title.attributedText = text;

    
    //저장
    NSString *str_Key = [NSString stringWithFormat:@"Library_%@_%@_%@",//Upload_전체_138
                         @"Upload",
                         @"전체",
                         [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSData *dictionaryData = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
    NSDictionary *resulte = [NSKeyedUnarchiver unarchiveObjectWithData:dictionaryData];
    if( resulte )
    {
        //        isShowIndicator = NO;
        self.arM_BottomList = [NSMutableArray arrayWithArray:[resulte objectForKey:@"examListInfos"]];
        if( self.arM_BottomList.count > 0 )
        {
            [self.tbv_BottomList reloadData];
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    if( self.str_ChannelId )
    {
        //채널
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            self.str_ChannelId, @"channelId",
                                            nil];
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/my"
                                            param:dicM_Params
                                       withMethod:@"GET"
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            [MBProgressHUD hide];
                                            
                                            if( resulte )
                                            {
                                                self.arM_Subject = [NSMutableArray array];
                                                [self.arM_Subject addObject:@{@"examCount":[NSString stringWithFormat:@"%ld", [[resulte objectForKey:@"channelExamCount"] integerValue]],
                                                                              @"subjectName":@"전체"}];
                                                [self.arM_Subject addObjectsFromArray:[resulte objectForKey:@"여기"]];
                                                [self.cv_Subject reloadData];
                                                
                                                [self updateBottomList];
                                            }
                                        }];
    }
    else
    {
        //유저
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
                                                self.arM_Subject = [NSMutableArray array];
                                                [self.arM_Subject addObject:@{@"examCount":[NSString stringWithFormat:@"%ld", [[resulte objectForKey:@"myUploadExamCount"] integerValue]],
                                                                              @"subjectName":@"전체"}];
                                                [self.arM_Subject addObjectsFromArray:[resulte objectForKey:@"myUploadSubjectNameInfos"]];
                                                [self.cv_Subject reloadData];
                                                
                                                [self updateBottomList];
                                            }
                                        }];
    }
}

- (void)updateBottomList
{
    NSDictionary *dic = self.arM_Subject[nSelectedSubjectIdx];
    NSString *str_SubjectName = [dic objectForKey:@"subjectName"];
    
//    BOOL isShowIndicator = YES;
//    NSString *str_Key = [NSString stringWithFormat:@"Library_%@_%@_%@",//Upload_전체_138
//                         @"Upload",
//                         str_SubjectName,
//                         [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
//    NSData *dictionaryData = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
//    NSDictionary *resulte = [NSKeyedUnarchiver unarchiveObjectWithData:dictionaryData];
//    if( resulte )
//    {
//        isShowIndicator = NO;
//        self.arM_BottomList = [NSMutableArray arrayWithArray:[resulte objectForKey:@"examListInfos"]];
//        if( self.arM_BottomList.count > 0 )
//        {
//            [self.tbv_BottomList reloadData];
//        }
//    }
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"], @"pUserId",
                                        @"uploadExam", @"pageType",
                                        nil];
    
    if( [str_SubjectName isEqualToString:@"전체"] )
    {
        [dicM_Params setObject:@"0" forKey:@"subjectName"];
    }
    else
    {
        [dicM_Params setObject:str_SubjectName forKey:@"subjectName"];
    }
    
    if( self.str_ChannelId )
    {
        [dicM_Params setObject:self.str_ChannelId forKey:@"channelId"];
    }
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/page/package/exam/browse"
                                        param:dicM_Params
                                   withMethod:@"GET"
                            withShowIndicator:YES
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                NSString *str_Key = [NSString stringWithFormat:@"Library_%@_%@_%@",//Upload_전체_138
                                                                     @"Upload",
                                                                     str_SubjectName,
                                                                     [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];

                                                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:resulte];
                                                [[NSUserDefaults standardUserDefaults] setObject:data forKey:str_Key];
                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                
                                                self.arM_BottomList = [NSMutableArray arrayWithArray:[resulte objectForKey:@"recommendInfo"]];
                                                [self.tbv_BottomList reloadData];
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


#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.arM_BottomList.count;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSDictionary *dic_Main = self.arM_BottomList[section];
    NSArray *ar = [dic_Main objectForKey:@"examInfos"];
    return ar.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyQuestionListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyQuestionListCell"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    cell.v_Base.clipsToBounds = YES;
    cell.v_Base.layer.borderWidth = 0.5f;
    cell.v_Base.layer.borderColor = [UIColor colorWithRed:200.f/255.f green:200.f/255.f blue:200.f/255.f alpha:1].CGColor;

    cell.btn_Group.tag = cell.btn_Result.tag = indexPath.row;
    
    NSDictionary *dic_Main = self.arM_BottomList[indexPath.section];
    NSArray *ar = [dic_Main objectForKey:@"examInfos"];
    NSDictionary *dic = ar[indexPath.row];
    
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
    
    cell.btn_Info.tag = (indexPath.section * 10000) + indexPath.row;
    [cell.btn_Info addTarget:self action:@selector(onItemInfo:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //        if( self.isManagerView )    return;
    
    NSDictionary *dic_Main = self.arM_BottomList[indexPath.section];
    NSArray *ar = [dic_Main objectForKey:@"examInfos"];
    NSDictionary *dic = ar[indexPath.row];
    
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

- (nullable UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    NSDictionary *dic_Main = self.arM_BottomList[section];
    
    LibrarySectionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LibrarySectionCell"];
    NSString *str_Date = [NSString stringWithFormat:@"%@", [dic_Main objectForKey:@"lastDateTime"]];
    NSRange range = NSMakeRange(0, 4);
    NSString *str_Year = [str_Date substringWithRange:range];
    
    range = NSMakeRange(4, 2);
    NSString *str_Month = [str_Date substringWithRange:range];
    
    range = NSMakeRange(6, 2);
    NSString *str_Day = [str_Date substringWithRange:range];
    
    cell.lb_SectionTitle.text = [NSString stringWithFormat:@"%@.%@.%@", str_Year, str_Month, str_Day];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 30.f;
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
    
    [self.tbv_BottomList setContentOffset:CGPointZero animated:NO];
}


- (void)onItemInfo:(UIButton *)btn
{
    NSDictionary *dic_Main = self.arM_BottomList[btn.tag / 10000];
    NSArray *ar = [dic_Main objectForKey:@"examInfos"];
    NSDictionary *dic = ar[btn.tag % 10000];
    
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

@end
