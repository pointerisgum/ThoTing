//
//  UserPageMainViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 25..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "UserPageMainViewController.h"
#import "MyQuestionListCell.h"
#import "MyFollowingCell.h"
#import "AppDelegate.h"
#import "QuestionContainerViewController.h"
#import "GroupWebViewController.h"
#import "ReportDetailViewController.h"
#import "ChannelMainViewController.h"
#import "InputUserInfoViewController.h"
#import "QuestionStartViewController.h"

@interface UserPageMainViewController () <UIScrollViewDelegate, UIActionSheetDelegate>
{
    BOOL isMyPage;
    
    NSString *str_ImagePrefix;
    NSString *str_UserImagePrefix;
    NSString *str_NoImagePrefix;
}
@property (nonatomic, strong) NSMutableDictionary *dicM_Data;
//상단뷰
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Name;
@property (nonatomic, weak) IBOutlet UILabel *lb_Hash;
@property (nonatomic, weak) IBOutlet UILabel *lb_TotalUser;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ProfileWidth;
@property (nonatomic, weak) IBOutlet UIView *v_Tag;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_TagCheckWidth;

//메뉴뷰
@property (nonatomic, weak) IBOutlet UIView *v_Menus;
@property (nonatomic, weak) IBOutlet UIButton *btn_QestionList;
@property (nonatomic, weak) IBOutlet UIButton *btn_FollowingList;
@property (nonatomic, weak) IBOutlet UIButton *btn_BookMarkList;
@property (nonatomic, weak) IBOutlet UIButton *btn_ReportList;

@property (nonatomic, weak) IBOutlet UIScrollView *sv_Contents;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ContentsWidth;

//하단 메뉴 테이블뷰들
@property (nonatomic, strong) NSArray *ar_Question;
@property (nonatomic, strong) NSArray *ar_Following;
@property (nonatomic, strong) NSArray *ar_Report;
@property (nonatomic, weak) IBOutlet UITableView *tbv_QuestionList;
@property (nonatomic, weak) IBOutlet UITableView *tbv_FollowingList;
@property (nonatomic, weak) IBOutlet UITableView *tbv_ReportList;

@end

@implementation UserPageMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.v_Tag.layer.cornerRadius = 8.f;
    self.v_Tag.layer.borderColor = kMainColor.CGColor;
    self.v_Tag.layer.borderWidth = 1.f;
    
    self.btn_QestionList.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.btn_FollowingList.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.btn_BookMarkList.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.btn_ReportList.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    self.navigationController.navigationBarHidden = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMyPageQuestion) name:kShowMyPageQuestion object:nil];
    
    
    //str_UserIdx
}

- (void)showMyPageQuestion
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    self.tbv_QuestionList.contentOffset = CGPointZero;
    [self goMeneSelected:self.btn_QestionList];
}

- (void)settingButtonPressed:(UIButton *)btn
{
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                             delegate:self
                                                    cancelButtonTitle:@"취소"
                                               destructiveButtonTitle:@"로그아웃"
                                                    otherButtonTitles:nil];
    
    [actionSheet showInView:self.view];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if( buttonIndex == 0 )
    {
        NSString *str_Token = [[NSUserDefaults standardUserDefaults] objectForKey:@"PushToken"];
        
#if TARGET_IPHONE_SIMULATOR
        str_Token = @"fPSwKVXXPRs:APA91bFY_iJqmHcsHIMx_8O1jOmHIeYa8krP0ZPPgqCvu-Okfcp78tMAp1urapdJiPNfc8Qfe-Ya9tR3J_y2hlvxzWW-oKdTi3YL7HEid54r6ncx0EB-azhVv__dRT4dJRFUoHW6_z0T";
#endif

        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            str_Token, @"deviceToken",
                                            nil];
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/signout"
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
                                                    //                                                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"apiToken"];
                                                    //                                                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"secretKey"];
                                                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"email"];
                                                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"password"];
                                                    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"userId"];
                                                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"IsLogin"];
                                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                                    
                                                    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeTabBar object:[NSNumber numberWithInteger:0]];
                                                    
                                                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                                    [appDelegate showLoginView];
                                                }
                                            }
                                        }];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [MBProgressHUD hide];
    
    [self updateList];
}

- (void)viewDidLayoutSubviews
{
    self.sv_Contents.contentSize = CGSizeMake(self.sv_Contents.bounds.size.width * 3, 0);
    self.lc_ContentsWidth.constant = self.sv_Contents.contentSize.width;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if( [segue.identifier isEqualToString:@"MyProfileSegue"] )
    {
        InputUserInfoViewController *vc = [segue destinationViewController];
        vc.isProfileMode = YES;
    }
}



- (void)updateList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_UserIdx, @"pUserId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/user/my"
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
                                                self.dicM_Data = [NSMutableDictionary dictionaryWithDictionary:resulte];
                                                [self updateData];
                                            }
                                        }
                                        
                                        [self updateQuestionList];
                                        [self updateFollowingList];
                                        [self updateReportList];
                                    }];
}

- (void)updateQuestionList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_UserIdx, @"pUserId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/user/my/paid/exam"
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
                                                self.ar_Question = [NSArray arrayWithArray:[resulte objectForKey:@"examListInfos"]];
                                                [self.tbv_QuestionList reloadData];
                                            }
                                        }
                                    }];
}

- (void)updateFollowingList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_UserIdx, @"pUserId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/follower/channel/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            self.ar_Following = nil;
                                            
                                            NSLog(@"resulte : %@", resulte);
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                self.ar_Following = [NSArray arrayWithArray:[resulte objectForKey:@"followChannelInfos"]];
                                            }
                                            
                                            [self.tbv_FollowingList reloadData];
                                        }
                                    }];
}

- (void)updateReportList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_UserIdx, @"pUserId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/user/my/report/exam"
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
                                                self.ar_Report = [NSArray arrayWithArray:[resulte objectForKey:@"examListInfos"]];
                                                [self.tbv_ReportList reloadData];
                                            }
                                        }
                                    }];
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


- (void)updateData
{
    /*
     bookmarkCount = 0;
     buyExamCount = 0;
     "error_code" = success;
     "error_message" = success;
     followChannelCount = 1;
     hashtagStr = "";
     imgUrl = "/common/clipnote/img/no-image-256.png";
     "img_prefix" = "http://data.clipnote.co.kr:8282/c_edujm/exam/";
     isMyPage = 0;
     "response_code" = 200;
     solveExamCount = 0;
     success = success;
     useHashCode = N;
     useHashCodeCount = 0;
     userId = 108;
     "userImg_prefix" = "http://data.clipnote.co.kr:8282/c_edujm/images/user/";
     userName = "\Ud1a0\Ud305\Uc120\Uc0dd\Ub2d81";
     */
    
    
    [self initNaviWithTitle:[self.dicM_Data objectForKey:@"userName"] withLeftItem:[self leftBackBlackMenuBarButtonItem] withRightItem:nil withColor:[UIColor colorWithHexString:@"F8F8F8"]];
    
    //isSamHashTag
    
    NSString *str_SameHashTag = [self.dicM_Data objectForKey:@"isSameHashTag"];
    if( [str_SameHashTag isEqualToString:@"Y"] )
    {
        //같은 태그
//        self.v_Tag.backgroundColor = kMainColor;
    }
    else
    {
        //다른 태그
        self.v_Tag.backgroundColor = [UIColor whiteColor];
        self.lc_TagCheckWidth.constant = 0;
        self.lb_Hash.textColor = kMainColor;
        self.lb_TotalUser.textColor = [UIColor darkGrayColor];
    }
    
    isMyPage = [[self.dicM_Data objectForKey:@"isMyPage"] boolValue];
    str_ImagePrefix = [self.dicM_Data objectForKey:@"img_prefix"];
    str_UserImagePrefix = [self.dicM_Data objectForKey:@"userImg_prefix"];
    str_NoImagePrefix = [self.dicM_Data objectForKey:@"no_image"];
    
    NSString *str_ImageUrl = [self.dicM_Data objectForKey:@"imgUrl"];
    if( [str_ImageUrl isEqualToString:@"no_image"] )
    {
        [self.iv_User sd_setImageWithURL:[NSURL URLWithString:str_NoImagePrefix]];
    }
    else
    {
        [self.iv_User sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
    }
    
    //    [self.iv_User sd_setImageWithURL:[Util createImageUrl:str_UserImagePrefix withFooter:[self.dicM_Data objectForKey:@"imgUrl"]]];
    
    self.lb_Name.text = [self.dicM_Data objectForKey_YM:@"userName"];
    
    self.lb_Hash.text = [self.dicM_Data objectForKey_YM:@"hashtagStr"];
    
    self.lb_TotalUser.text = [NSString stringWithFormat:@"%ld명", [[self.dicM_Data objectForKey_YM:@"useHashCodeCount"] integerValue]];
    
    NSString *str_ButtonTitle = [NSString stringWithFormat:@"%ld\n%@", [[self.dicM_Data objectForKey_YM:@"buyExamCount"] integerValue], @"문제들"];
    [self.btn_QestionList setTitle:str_ButtonTitle forState:UIControlStateNormal];
    
    str_ButtonTitle = [NSString stringWithFormat:@"%ld\n%@", [[self.dicM_Data objectForKey_YM:@"followChannelCount"] integerValue], @"팔로잉"];
    [self.btn_FollowingList setTitle:str_ButtonTitle forState:UIControlStateNormal];
    
    str_ButtonTitle = [NSString stringWithFormat:@"%ld\n%@", [[self.dicM_Data objectForKey_YM:@"bookmarkCount"] integerValue], @"북마크"];
    [self.btn_BookMarkList setTitle:str_ButtonTitle forState:UIControlStateNormal];
    
    str_ButtonTitle = [NSString stringWithFormat:@"%ld\n%@", [[self.dicM_Data objectForKey_YM:@"solveExamCount"] integerValue], @"레포트"];
    [self.btn_ReportList setTitle:str_ButtonTitle forState:UIControlStateNormal];
    
    [self.view setNeedsLayout];
}



#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( tableView == self.tbv_QuestionList )            return self.ar_Question.count;
    else if( tableView == self.tbv_FollowingList )      return self.ar_Following.count;
    else if( tableView == self.tbv_ReportList )         return self.ar_Report.count;
    
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( tableView == self.tbv_QuestionList )
    {
        MyQuestionListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyQuestionListCell"];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        cell.btn_Paid.tag = cell.btn_Group.tag = cell.btn_Result.tag = indexPath.row;
        
        NSDictionary *dic = self.ar_Question[indexPath.row];
        
        cell.iv_Thumb.backgroundColor = [UIColor colorWithHexString:[dic objectForKey_YM:@"codeHex"]];
        
        //문제집 제목
        cell.lb_QuestionTitle.text = [dic objectForKey_YM:@"examTitle"];
        
        //제목
        cell.lb_Title.text = [dic objectForKey_YM:@"subjectName"];
        
        //학교 학년
        NSInteger nGrade = [[dic objectForKey_YM:@"personGrade"] integerValue];
        if( nGrade == 0 )
        {
            cell.lb_Grade.text = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"schoolGrade"]];
        }
        else
        {
            cell.lb_Grade.text = [NSString stringWithFormat:@"%@ %ld학년", [dic objectForKey_YM:@"schoolGrade"], nGrade];
        }
        
        //출판사
        cell.lb_Owner.text = [dic objectForKey_YM:@"publisherName"];
        
        CGFloat fTotalCnt = [[dic objectForKey_YM:@"questionCount"] floatValue];
        CGFloat fFinishCnt = [[dic objectForKey_YM:@"solveQuestionCount"] floatValue];
        
        CGFloat fFinishPer = fFinishCnt / fTotalCnt;
        cell.lc_ProgressWidth.constant = cell.iv_ProgressBg.frame.size.width * fFinishPer;
        
        //TODO: 남이 볼때 화면처리
        [cell.btn_Paid removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
        
//        NSString *str_IsPaid = [dic objectForKey_YM:@"isPaid"];
        if( [[dic objectForKey_YM:@"isPaid"] isEqualToString:@"paid"] )
        {
            //나도 구매한것
            cell.btn_Paid.selected = YES;
        }
        else
        {
            //나는 구매 안한것
            cell.btn_Paid.selected = NO;
            
            if( [[dic objectForKey_YM:@"heartCount"] integerValue] == 0 )
            {
                //무료
                [cell.btn_Paid setTitle:@"무료" forState:UIControlStateNormal];
            }
            else
            {
                //유료
                NSInteger nQuestionCount = [[dic objectForKey_YM:@"questionCount"] integerValue];
                [cell.btn_Paid setTitle:[NSString stringWithFormat:@"$%f", nQuestionCount - 0.01] forState:UIControlStateNormal];
            }
            
            [cell.btn_Paid addTarget:self action:@selector(onPrice:) forControlEvents:UIControlEventTouchUpInside];
        }
        
//        //단원보기
//        [cell.btn_Group addTarget:self action:@selector(onShowGroup:) forControlEvents:UIControlEventTouchUpInside];
//        
//        //단원보기 버튼 유무
//        NSInteger nGroupId = [[dic objectForKey:@"groupId"] integerValue];
//        if( nGroupId == 0 )
//        {
//            //단원없음
//            cell.btn_Group.hidden = YES;
//        }
//        else
//        {
//            cell.btn_Group.hidden = NO;
//        }
//        
//        
//        //결과보기
//        [cell.btn_Result addTarget:self action:@selector(onShowResult:) forControlEvents:UIControlEventTouchUpInside];
//        
//        //결과보기 버튼 유무
//        NSInteger nFinishCount = [[dic objectForKey:@"isFinishCount"] integerValue];
//        NSInteger nSolve = [[dic objectForKey:@"isSolve"] integerValue];
//        if( nFinishCount > 0 || nSolve == 1 )
//        {
//            //표시
//            cell.btn_Result.hidden = NO;
//        }
//        else
//        {
//            cell.btn_Result.hidden = YES;
//        }
        
        return cell;
    }
    else if( tableView == self.tbv_FollowingList )
    {
        MyFollowingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyFollowingCell"];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        cell.btn_Follow.tag = indexPath.row;
        
        NSDictionary *dic = self.ar_Following[indexPath.row];
        
        //채널 이미지
        NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [dic objectForKey_YM:@"channelImgUrl"]];
        [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
        
        //팔로우 버튼 초기화
        cell.btn_Follow.titleLabel.textAlignment = NSTextAlignmentCenter;
        cell.btn_Follow.userInteractionEnabled = YES;
        cell.btn_Follow.selected = NO;
        [cell.btn_Follow setBackgroundImage:BundleImage(@"blue_box.png") forState:UIControlStateSelected];
        [cell.btn_Follow setTitle:@"팔로잉" forState:UIControlStateSelected];
        cell.btn_Follow.layer.borderWidth = 1.0f;
        [cell.btn_Follow removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
        /////////////
        
        NSInteger nMemberLevel = [[dic objectForKey_YM:@"memberLevel"] integerValue];
        NSString *str_StatusCode = [dic objectForKey_YM:@"statusCode"];
        if( [str_StatusCode isEqualToString:@"T"] && nMemberLevel < 10 )
        {
            //관리자
            //            cell.btn_Follow.userInteractionEnabled = NO;
            cell.btn_Follow.selected = YES;
            [cell.btn_Follow setTitle:@"관리자" forState:UIControlStateSelected];
            cell.btn_Follow.layer.borderWidth = 0.0f;
            [cell.btn_Follow setBackgroundImage:BundleImage(@"red_box.png") forState:UIControlStateSelected];
//            [cell.btn_Follow addTarget:self action:@selector(onAddMannager:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if( [str_StatusCode isEqualToString:@"T"] && nMemberLevel == 99 )
        {
            //관리자 승인대기중
            cell.btn_Follow.userInteractionEnabled = NO;
            [cell.btn_Follow setTitle:@"관리자\n승인대기중" forState:UIControlStateNormal];
        }
        else
        {
            //팔로잉 여부
            BOOL isFollowing = [[dic objectForKey_YM:@"isMyFollow"] boolValue];
            if( isFollowing )
            {
                cell.btn_Follow.selected = YES;
            }
            else
            {
                cell.btn_Follow.selected = NO;
                [cell.btn_Follow addTarget:self action:@selector(onFollowing:) forControlEvents:UIControlEventTouchUpInside];
            }
        }
        
        
        //채널명
        cell.lb_Title.text = [dic objectForKey_YM:@"channelName"];
        
        //토탈 팔로잉 수 & 토탈문제수
        cell.lb_SubTitle.text = [NSString stringWithFormat:@"%ld명 %ld문제",
                                 [[dic objectForKey_YM:@"channelFollowerCount"] integerValue],
                                 [[dic objectForKey_YM:@"channelExamCount"] integerValue]];
        
        //        //팔로잉 여부
        //        cell.btn_Status.tag = indexPath.row;
        //        BOOL isFollow = [[dic objectForKey:@"isMyFollow"] boolValue];
        //        if( isFollow )
        //        {
        //            cell.btn_Status.selected = YES;
        //            cell.btn_Status.backgroundColor = kMainColor;
        //        }
        //        else
        //        {
        //            cell.btn_Status.selected = NO;
        //            cell.btn_Status.backgroundColor = [UIColor whiteColor];
        //        }
        //
        //        [cell.btn_Status addTarget:self action:@selector(onFollowing:) forControlEvents:UIControlEventTouchUpInside];
        
        return cell;
    }
    else if( tableView == self.tbv_ReportList )
    {
        MyQuestionListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyQuestionListCell"];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        cell.btn_Group.tag = cell.btn_Result.tag = indexPath.row;
        
        NSDictionary *dic = self.ar_Report[indexPath.row];
        
        cell.iv_Thumb.backgroundColor = [UIColor colorWithHexString:[dic objectForKey_YM:@"codeHex"]];
        
        //문제집 제목
        cell.lb_QuestionTitle.text = [dic objectForKey_YM:@"examTitle"];
        
        //제목
        cell.lb_Title.text = [dic objectForKey_YM:@"subjectName"];
        
        //학교 학년
        NSInteger nGrade = [[dic objectForKey_YM:@"personGrade"] integerValue];
        cell.lb_Grade.text = [NSString stringWithFormat:@"%@ %@학년", [dic objectForKey_YM:@"schoolGrade"], nGrade == 0 ? @"전체" : [NSString stringWithFormat:@"%ld", nGrade]];
        
        //출판사
        cell.lb_Owner.text = [dic objectForKey_YM:@"publisherName"];
        
        CGFloat fTotalCnt = [[dic objectForKey_YM:@"questionCount"] floatValue];
        CGFloat fFinishCnt = [[dic objectForKey_YM:@"solveQuestionCount"] floatValue];
        
        CGFloat fFinishPer = fFinishCnt / fTotalCnt;
        cell.lc_ProgressWidth.constant = cell.iv_ProgressBg.frame.size.width * fFinishPer;
        
        //TODO: 남이 볼때 화면처리
        
        //단원보기
        [cell.btn_Group addTarget:self action:@selector(onShowGroup:) forControlEvents:UIControlEventTouchUpInside];
        
        //단원보기 버튼 유무
        NSInteger nGroupId = [[dic objectForKey_YM:@"groupId"] integerValue];
        if( nGroupId == 0 )
        {
            //단원없음
            cell.btn_Group.hidden = YES;
        }
        else
        {
            cell.btn_Group.hidden = NO;
        }
        
        
        //결과보기
        [cell.btn_Result addTarget:self action:@selector(onShowResult:) forControlEvents:UIControlEventTouchUpInside];
        
        //결과보기 버튼 유무
        NSInteger nFinishCount = [[dic objectForKey_YM:@"isFinishCount"] integerValue];
        NSInteger nSolve = [[dic objectForKey_YM:@"isSolve"] integerValue];
        if( nFinishCount > 0 || nSolve == 1 )
        {
            //표시
            cell.btn_Result.hidden = NO;
        }
        else
        {
            cell.btn_Result.hidden = YES;
        }
        
        return cell;
    }
    
    return nil;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if( tableView == self.tbv_QuestionList )
    {
        NSDictionary *dic = self.ar_Question[indexPath.row];
//        NSString *str_IsPaid = [dic objectForKey_YM:@"isPaid"];
        if( [[dic objectForKey_YM:@"isPaid"] isEqualToString:@"paid"] )
        {
            //나도 구매한것
            //문제풀기 스타트 화면
            QuestionStartViewController  *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionStartViewController"];
//            vc.hidesBottomBarWhenPushed = YES;
            vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"examId"] integerValue]];
            vc.str_StartIdx = @"0";
            vc.str_Title = [dic objectForKey_YM:@"examTitle"];
            vc.str_UserIdx = self.str_UserIdx;
            vc.str_ChannelId = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"channelId"] integerValue]];

            [self.navigationController pushViewController:vc animated:YES];

            
//            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentQuestionIdx"];
//            [[NSUserDefaults standardUserDefaults] synchronize];
//            
//            QuestionContainerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
//            vc.hidesBottomBarWhenPushed = YES;
//            vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
//            vc.str_StartIdx = @"0";
//            
//            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if( tableView == self.tbv_FollowingList )
    {
        NSDictionary *dic = self.ar_Following[indexPath.row];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Channel" bundle:nil];
        ChannelMainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChannelMainViewController"];
        vc.str_ChannelId = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"channelId"] integerValue]];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if( tableView == self.tbv_ReportList )
    {
        //문제풀기
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentQuestionIdx"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        NSDictionary *dic = self.ar_Report[indexPath.row];
        
        QuestionContainerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
        vc.hidesBottomBarWhenPushed = YES;
        vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"examId"] integerValue]];
        vc.str_StartIdx = @"0";
        
        [self.navigationController pushViewController:vc animated:YES];
    }
}



- (void)onShowGroup:(UIButton *)btn
{
    //    NSDictionary *dic = self.ar_Question[btn.tag];
    //
    //    GroupWebViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"GroupWebViewController"];
    //    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"groupId"] integerValue]];
    //    vc.str_GroupName = [dic objectForKey:@"groupName"];
    //    [vc setCompletionWebBlock:^(id completeResult) {
    //        //문제풀기
    //        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentQuestionIdx"];
    //        [[NSUserDefaults standardUserDefaults] synchronize];
    //
    //        QuestionContainerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
    //        vc.hidesBottomBarWhenPushed = YES;
    //        vc.str_Idx = completeResult;
    //        vc.str_StartIdx = @"0";
    //        [self.navigationController pushViewController:vc animated:YES];
    //    }];
    //
    //    [self presentViewController:vc animated:YES completion:^{
    //
    //    }];
    
    NSDictionary *dic = self.ar_Question[btn.tag];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    GroupWebViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"GroupWebViewController"];
    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"groupId"] integerValue]];
    vc.str_GroupName = [dic objectForKey_YM:@"groupName"];
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    
    //    [vc setCompletionWebBlock:^(id completeResult) {
    //        //문제풀기
    //        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentQuestionIdx"];
    //        [[NSUserDefaults standardUserDefaults] synchronize];
    //
    //        QuestionContainerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
    //        vc.hidesBottomBarWhenPushed = YES;
    //        vc.str_Idx = completeResult;
    //        vc.str_StartIdx = @"0";
    //        [self.navigationController pushViewController:vc animated:YES];
    //    }];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onShowResult:(UIButton *)btn
{
    NSDictionary *dic = self.ar_Question[btn.tag];
    
    NSInteger nGrade = [[dic objectForKey_YM:@"personGrade"] integerValue];
    NSString *str_Grade = [NSString stringWithFormat:@"%@ %@학년", [dic objectForKey_YM:@"schoolGrade"], nGrade == 0 ? @"전체" : [NSString stringWithFormat:@"%ld", nGrade]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    ReportDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ReportDetailViewController"];
    vc.str_Title = [NSString stringWithFormat:@"%@ %@ %@", [dic objectForKey_YM:@"subjectName"], str_Grade, [dic objectForKey_YM:@"publisherName"]];
    vc.str_ExamId = [dic objectForKey_YM:@"examId"];
    vc.str_PUserId = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"userId"]];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}





#pragma mark - IBAction
- (IBAction)goProfile:(id)sender
{
    
}

- (IBAction)goMeneSelected:(id)sender
{
    for( id subView in self.v_Menus.subviews )
    {
        if( [subView isKindOfClass:[UIButton class]] )
        {
            UIButton *subBtn = (UIButton *)subView;
            subBtn.selected = NO;
        }
    }
    
    UIButton *btn = (UIButton *)sender;
    btn.selected = YES;
    
    if( sender == self.btn_QestionList )
    {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             
                             self.sv_Contents.contentOffset = CGPointZero;
                         }];
    }
    else if( sender == self.btn_FollowingList )
    {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             
                             self.sv_Contents.contentOffset = CGPointMake(self.sv_Contents.bounds.size.width * 1, 0);
                         }];
    }
    else if( sender == self.btn_BookMarkList )
    {
        
    }
}

- (void)onFollowing:(UIButton *)btn
{
    NSDictionary *dic = self.ar_Following[btn.tag];
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        //                                        [NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]], @"userId",
                                        [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"channelId"] integerValue]], @"channelId",
                                        btn.selected ? @"unfollow" : @"follow", @"setMode",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/channel/follow"
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
                                                [self updateList];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

- (void)onAddMannager:(UIButton *)btn
{
    NSDictionary *dic = self.ar_Following[btn.tag];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"channelId"] integerValue]], @"channelId",
                                        [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"userId"]], @"userId",
                                        btn.selected ? @"delete" : @"manager", @"setMode",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/channel/manager"
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
                                                [self updateList];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

- (void)onPrice:(UIButton *)btn
{
    __block NSDictionary *dic = self.ar_Question[btn.tag];
    
    UIAlertView *alert = CREATE_ALERT(nil, @"문제를 구매하시겠습니까?", @"예", @"아니요");
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if( buttonIndex == 0 )
        {
            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                [Util getUUID], @"uuid",
                                                [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"examId"] integerValue]], @"examId",
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
                                                        ALERT(nil, @"문제를 구매 했습니다", nil, @"확인", nil);
//                                                        [[NSNotificationCenter defaultCenter] postNotificationName:kChangeTabBar object:[NSNumber numberWithInteger:5]];
                                                        
                                                        [self updateList];
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

@end
