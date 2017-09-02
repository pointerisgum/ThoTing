//
//  ChannelMainViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 9..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "ChannelMainViewController.h"
#import "ChannelQuestionListCell.h"
#import "ChannelFollowingListCell.h"
#import "ChannelMemberListCell.h"
#import "ChannelMannagerListCell.h"
#import "QuestionContainerViewController.h"
#import "UserPageMainViewController.h"
#import "MyMainViewController.h"
#import "QnACell.h"
#import "MakeChattingRoomViewController.h"
#import "ChattingViewController.h"
#import "InRoomMemberListViewController.h"
#import "QuestionDetailViewController.h"
#import "QuestionStartViewController.h"
#import "ReportMainViewController.h"
#import "ChannelReportViewController.h"
#import "ChatFeedViewController.h"
#import "ActionSheetBottomViewController.h"
#import "MyQuestionListCell.h"
#import "SharedViewController.h"
#import "GroupWebViewController.h"
#import "ReportDetailViewController.h"
#import "UserControllListViewController.h"

@interface ChannelMainViewController ()
{
    BOOL isMannager;
//    BOOL isMyPage;
    BOOL isFollowing;
    BOOL isMember;
    BOOL isNaviShow;
    
    NSString *str_ImagePrefix;
    NSString *str_UserImagePrefix;
    NSString *str_NoImagePrefix;
}
@property (nonatomic, strong) NSMutableDictionary *dicM_Data;
//상단뷰
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Name;
@property (nonatomic, weak) IBOutlet UIButton *btn_Folloer;
@property (nonatomic, weak) IBOutlet UIButton *btn_Mannager;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_FollowerWidth;

//메뉴뷰
@property (nonatomic, weak) IBOutlet UIView *v_Menus;
@property (nonatomic, weak) IBOutlet UIButton *btn_QestionList;
@property (nonatomic, weak) IBOutlet UIButton *btn_QnAList;
@property (nonatomic, weak) IBOutlet UIButton *btn_FollowingList;
@property (nonatomic, weak) IBOutlet UIButton *btn_MemberList;
@property (nonatomic, weak) IBOutlet UIButton *btn_MannagerList;
@property (nonatomic, weak) IBOutlet UIButton *btn_Report;
//하단 테이블 뷰
@property (nonatomic, strong) NSArray *ar_Question;
@property (nonatomic, strong) NSMutableArray *ar_Qna;
@property (nonatomic, strong) NSArray *ar_Following;
@property (nonatomic, strong) NSArray *ar_Member;
@property (nonatomic, strong) NSArray *ar_Mannager;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Contents;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ContentsWidth;
@property (nonatomic, weak) IBOutlet UITableView *tbv_QuestionList;
@property (nonatomic, weak) IBOutlet UITableView *tbv_QnAList;
@property (nonatomic, weak) IBOutlet UITableView *tbv_FollowingList;
@property (nonatomic, weak) IBOutlet UITableView *tbv_MemberList;
@property (nonatomic, weak) IBOutlet UITableView *tbv_MannagerList;

@property (nonatomic, weak) IBOutlet UIView *v_MemberMenu;
@property (nonatomic, weak) IBOutlet UIButton *btn_QestionList2;
@property (nonatomic, weak) IBOutlet UIButton *btn_QnAList2;
@property (nonatomic, weak) IBOutlet UIButton *btn_FollowingList2;
@property (nonatomic, weak) IBOutlet UIButton *btn_MemberList2;

@property (nonatomic, weak) IBOutlet UIButton *btn_Status;

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ReportTail;

//새로 추가된 것
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) NSMutableArray *arM_SubjectList;
@property (nonatomic, weak) IBOutlet UIView *v_Header;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_SubjectList;
@property (nonatomic, weak) IBOutlet UILabel *lb_ChannelName;
@property (nonatomic, weak) IBOutlet UIButton *btn_FollowingCnt;
@property (nonatomic, weak) IBOutlet UIButton *btn_MemberCnt;
@property (nonatomic, weak) IBOutlet UIButton *btn_AdminCnt;


@property (nonatomic, weak) IBOutlet UIButton *btn_Back;
@property (nonatomic, weak) IBOutlet UIButton *btn_Close;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ChannelModeNaviHeight;
@property (nonatomic, weak) IBOutlet UIView *v_ChannelModeHeader;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_ChannelModeSubjectList;
@end

@implementation ChannelMainViewController

- (void)updateView
{
    
}
  
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    self.view.alpha = NO;
    
    if( self.isChannelMode )
    {
        self.lc_ChannelModeNaviHeight.constant = 64.f;
//        self.lc_ChannelModeHeaderHeight.constant = 0.f;
        self.tbv_List.tableHeaderView = self.v_ChannelModeHeader;
    }
    else
    {
        self.lc_ChannelModeNaviHeight.constant = 0.f;
//        self.lc_ChannelModeHeaderHeight.constant = 120.f;
        self.tbv_List.tableHeaderView = self.v_Header;
    }

    
    isNaviShow = self.navigationController.navigationBarHidden;
    
    self.btn_Status.layer.cornerRadius = 8.f;
    self.btn_Status.layer.borderWidth = 1.f;
    
    self.btn_FollowingCnt.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.btn_MemberCnt.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.btn_AdminCnt.titleLabel.textAlignment = NSTextAlignmentCenter;

//    self.btn_QestionList.titleLabel.textAlignment = NSTextAlignmentCenter;
//    self.btn_QnAList.titleLabel.textAlignment = NSTextAlignmentCenter;
//    self.btn_FollowingList.titleLabel.textAlignment = NSTextAlignmentCenter;
//    self.btn_MemberList.titleLabel.textAlignment = NSTextAlignmentCenter;
//    self.btn_MannagerList.titleLabel.textAlignment = NSTextAlignmentCenter;
//    self.btn_Report.titleLabel.textAlignment = NSTextAlignmentCenter;
//    
//    self.btn_QestionList2.titleLabel.textAlignment = NSTextAlignmentCenter;
//    self.btn_QnAList2.titleLabel.textAlignment = NSTextAlignmentCenter;
//    self.btn_FollowingList2.titleLabel.textAlignment = NSTextAlignmentCenter;
//    self.btn_MemberList2.titleLabel.textAlignment = NSTextAlignmentCenter;

    self.navigationController.navigationBarHidden = NO;
    
//    [self setDefaultLayer:self.btn_Folloer];
//    [self setDefaultLayer:self.btn_Mannager];
    
    
//    [self startSendBird];
//    
//    NSString *str_ChannelUrl = [NSString stringWithFormat:@"thotingQuestion_channel_%@", [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"questionId"]]];
//    [SendBird joinChannel:str_ChannelUrl];
//    [SendBird connect];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    self.navigationController.navigationBarHidden = YES;
    
    NSLog(@"self.tabBarController.selectedIndex : %ld", self.tabBarController.selectedIndex);
    if( self.tabBarController.selectedIndex == 1 )
    {
        self.navigationController.navigationBarHidden = NO;
    }
    else
    {
        //        self.navigationController.navigationBarHidden = isNaviShow;
        self.navigationController.navigationBarHidden = YES;
    }
    
    if( self.isShowNavi )
    {
        self.navigationController.navigationBarHidden = !self.isShowNavi;
    }

    [MBProgressHUD hide];
    
    [self updateList];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    NSLog(@"self.tabBarController.selectedIndex : %ld", self.tabBarController.selectedIndex);
    if( self.tabBarController.selectedIndex == 1 )
    {
        self.navigationController.navigationBarHidden = NO;
    }
    else
    {
        //        self.navigationController.navigationBarHidden = isNaviShow;
        self.navigationController.navigationBarHidden = YES;
    }
    
    if( self.isShowNavi )
    {
        self.navigationController.navigationBarHidden = !self.isShowNavi;
    }
}

- (void)setDefaultLayer:(UIButton *)btn
{
    btn.selected = NO;
    
    btn.layer.cornerRadius = 8.f;
    btn.layer.borderColor = kMainColor.CGColor;
    btn.layer.borderWidth = 1.f;
    
    [btn setTitleColor:kMainColor forState:UIControlStateNormal];
    
    [btn setBackgroundColor:[UIColor whiteColor]];
    
    NSMutableString *strM_Title = [NSMutableString stringWithString:btn.titleLabel.text];
    [btn setTitle:[strM_Title stringByReplacingOccurrencesOfString:@"v" withString:@"+"] forState:UIControlStateNormal];
}

- (void)setSelectedLayer:(UIButton *)btn
{
    btn.selected = YES;
    
    btn.layer.cornerRadius = 8.f;
    btn.layer.borderColor = [UIColor clearColor].CGColor;
    btn.layer.borderWidth = 0.f;
    
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    [btn setBackgroundColor:kMainRedColor];
    
    NSMutableString *strM_Title = [NSMutableString stringWithString:btn.titleLabel.text];
    [btn setTitle:[strM_Title stringByReplacingOccurrencesOfString:@"+" withString:@"v"] forState:UIControlStateNormal];
}

- (void)viewDidLayoutSubviews
{
//    if( isMannager )
//    {
//        self.v_MemberMenu.hidden = YES;
//        self.lc_FollowerWidth.constant = 0.f;
//        self.lc_ReportTail.constant = 0;
//        [self setSelectedLayer:self.btn_Mannager];
//    }
//    else
//    {
//        self.v_MemberMenu.hidden = NO;
//        self.lc_FollowerWidth.constant = 114.f;
//        self.lc_ReportTail.constant = -(self.view.bounds.size.width / 4);
//        [self setDefaultLayer:self.btn_Mannager];
//        
//        if( isFollowing )
//        {
//            [self setSelectedLayer:self.btn_Folloer];
//        }
//        else
//        {
//            [self setDefaultLayer:self.btn_Folloer];
//        }
//    }
//
//    self.sv_Contents.contentSize = CGSizeMake(self.sv_Contents.bounds.size.width * 5, 0);
//    self.lc_ContentsWidth.constant = self.sv_Contents.contentSize.width;
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
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/my"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        //                                        [UIView animateWithDuration:0.3f
                                        //                                                         animations:^{
                                        //                                                            self.view.alpha = YES;
                                        //                                                         }];
                                        if( resulte )
                                        {
                                            NSLog(@"resulte : %@", resulte);
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                self.dicM_Data = [NSMutableDictionary dictionaryWithDictionary:resulte];
                                                [self updateData];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }

//                                        if( resulte )
//                                        {
//                                            self.dic_Data = [NSDictionary dictionaryWithDictionary:resulte];
//                                            
//                                            self.lb_Title.text = [resulte objectForKey:@"channelHashTag"];
//                                            self.lb_SubTitle.text = [NSString stringWithFormat:@"(%@)", [resulte objectForKey:@"region"]];
//                                            
//                                            NSString *str_TotalUser = [NSString stringWithFormat:@"%@명", [resulte objectForKey:@"hashTagUserCount"]];
//                                            [self.btn_TotalUser setTitle:str_TotalUser forState:UIControlStateNormal];
//                                            
//                                            self.arM_SubjectList = [NSMutableArray array];
//                                            [self.arM_SubjectList addObject:@{@"subjectName":@"업로드",
//                                                                              @"examCount":[NSString stringWithFormat:@"%@", [resulte objectForKey:@"reportCount"]]}];
//                                            
//                                            [self.arM_SubjectList addObject:@{@"subjectName":@"전체",
//                                                                              @"examCount":[NSString stringWithFormat:@"%@", [resulte objectForKey:@"hashTagExamCount"]]}];
//                                            
//                                            [self.arM_SubjectList addObjectsFromArray:[resulte objectForKey:@"hashTagExamSubjectNameInfo"]];
//                                            [self updateSubjectList];
//                                            
//                                            [self.tbv_List reloadData];
//                                        }
                                    }];
}

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
    
    [self initNaviWithTitle:[self.dicM_Data objectForKey:@"channelName"] withLeftItem:[self leftBackBlackMenuBarButtonItem] withRightItem:nil withColor:[UIColor colorWithHexString:@"F8F8F8"]];
    
    isMannager = [[self.dicM_Data objectForKey:@"isChannelManager"] boolValue];
    //    isMannager = NO;  //test code
    isFollowing = [[self.dicM_Data objectForKey:@"isChannelFollower"] boolValue];
    
    self.btn_Mannager.userInteractionEnabled = YES;
    
    if( isMannager == NO )
    {
        BOOL isChannelManagerRequest = [[self.dicM_Data objectForKey:@"isChannelManagerRequest"] boolValue];
        if( isChannelManagerRequest )
        {
            //관리자 신청중일 경우
            [self.btn_Mannager setTitle:@"관리자 승인대기중" forState:UIControlStateNormal];
            self.btn_Mannager.userInteractionEnabled = NO;
        }
        else
        {
            [self.btn_Mannager setTitle:@"+관리자" forState:UIControlStateNormal];
            self.btn_Mannager.userInteractionEnabled = YES;
        }
    }
    
    
    
    str_ImagePrefix = [self.dicM_Data objectForKey:@"img_prefix"];
    str_UserImagePrefix = [self.dicM_Data objectForKey:@"userImg_prefix"];
    str_NoImagePrefix = [self.dicM_Data objectForKey:@"no_image"];
    
    NSString *str_ImageUrl = [self.dicM_Data objectForKey:@"channelImgUrl"];
    if( [str_ImageUrl isEqualToString:@"no_image"] )
    {
        [self.iv_User sd_setImageWithURL:[NSURL URLWithString:str_NoImagePrefix]];
    }
    else
    {
        [self.iv_User sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
    }
    
    self.lb_Name.text = [self.dicM_Data objectForKey:@"channelDesc"];
    
    NSString *str_ButtonTitle = [NSString stringWithFormat:@"%ld\n%@", [[self.dicM_Data objectForKey:@"totalExamCount"] integerValue], @"문제들"];
    [self.btn_QestionList setTitle:str_ButtonTitle forState:UIControlStateNormal];
    [self.btn_QestionList2 setTitle:str_ButtonTitle forState:UIControlStateNormal];
    
    str_ButtonTitle = [NSString stringWithFormat:@"%ld\n%@", [[self.dicM_Data objectForKey:@"qnaRoomCount"] integerValue], @"질문과답"];
    [self.btn_QnAList setTitle:str_ButtonTitle forState:UIControlStateNormal];
    [self.btn_QnAList2 setTitle:str_ButtonTitle forState:UIControlStateNormal];
    
    str_ButtonTitle = [NSString stringWithFormat:@"%ld\n%@", [[self.dicM_Data objectForKey:@"channelFollowerCount"] integerValue], @"팔로워"];
    [self.btn_FollowingList setTitle:str_ButtonTitle forState:UIControlStateNormal];
    [self.btn_FollowingList2 setTitle:str_ButtonTitle forState:UIControlStateNormal];
    
    str_ButtonTitle = [NSString stringWithFormat:@"%ld\n%@", [[self.dicM_Data objectForKey:@"channelMemberCount"] integerValue], @"회원"];
    [self.btn_MemberList setTitle:str_ButtonTitle forState:UIControlStateNormal];
    [self.btn_MemberList2 setTitle:str_ButtonTitle forState:UIControlStateNormal];
    
    str_ButtonTitle = [NSString stringWithFormat:@"%ld\n%@", [[self.dicM_Data objectForKey:@"channelManagerCount"] integerValue], @"관리자"];
    [self.btn_MannagerList setTitle:str_ButtonTitle forState:UIControlStateNormal];
    
    str_ButtonTitle = [NSString stringWithFormat:@"%ld\n%@", [[self.dicM_Data objectForKey:@"reportCount"] integerValue], @"레포트"];
    [self.btn_Report setTitle:str_ButtonTitle forState:UIControlStateNormal];
    
    
    //오늘꺼 6시간
    //마이 학생 페이지 12시간
    //땡땡땡 처리 4시간
    //마이 선생 페이지 5시간
    //팔로우 회원 관리자 볼때 3시간
    
    
    
    //0112일에 수정된 버전 적용한 코드
    //isChannelManaer: 채널 관리자 여부 (true-관리자, false-아님)
    //isChannelManagerRequest: 채널 관리자 신청 (true-신청, false-아님)
    //isChannelFollower: 채널 Follower 여부 (true-follower, false-아님)
    //isChannelMember: 채널 회원 여부 (true-회원, false-아님)
    
    
    //팔로잉 여부
    BOOL bFollowing = [[self.dicM_Data objectForKey:@"isChannelFollower"] boolValue];
    
    //회원 여부
    BOOL bMember = [[self.dicM_Data objectForKey:@"isChannelMember"] boolValue];
    
    //회원 신청 여부가 필요함
    BOOL bReqMember = [[self.dicM_Data objectForKey:@"isChannelMemberRequest"] boolValue];
    
    //관리자 여부
    BOOL bMannager = [[self.dicM_Data objectForKey:@"isChannelManager"] boolValue];
    
    //관리자 신청 여부
    BOOL bReqMannager = [[self.dicM_Data objectForKey:@"isChannelManagerRequest"] boolValue];
    
    
    if( bMannager )
    {
        [self.btn_Status setTitle:@"관리자" forState:UIControlStateNormal];
        [self.btn_Status setTitleColor:[UIColor colorWithHexString:@"F62B00"] forState:UIControlStateNormal];
        self.btn_Status.backgroundColor = [UIColor whiteColor];
        self.btn_Status.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    else if( bReqMannager )
    {
        [self.btn_Status setTitle:@"관리자 요청 중" forState:UIControlStateNormal];
        [self.btn_Status setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.btn_Status.backgroundColor = [UIColor colorWithHexString:@"F62B00"];
        self.btn_Status.layer.borderColor = [UIColor clearColor].CGColor;
    }
    else if( bMember )
    {
        [self.btn_Status setTitle:@"회원" forState:UIControlStateNormal];
        [self.btn_Status setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.btn_Status.backgroundColor = [UIColor whiteColor];
        self.btn_Status.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    else if( bReqMember )
    {
        [self.btn_Status setTitle:@"회원 요청 중" forState:UIControlStateNormal];
        [self.btn_Status setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.btn_Status.backgroundColor = [UIColor colorWithHexString:@"F62B00"];
        self.btn_Status.layer.borderColor = [UIColor clearColor].CGColor;
    }
    else if( bFollowing )
    {
        [self.btn_Status setTitle:@"팔로잉" forState:UIControlStateNormal];
        [self.btn_Status setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        self.btn_Status.backgroundColor = [UIColor whiteColor];
        self.btn_Status.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    else if( bFollowing == NO )
    {
        [self.btn_Status setTitle:@"팔로우" forState:UIControlStateNormal];
        [self.btn_Status setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        self.btn_Status.backgroundColor = kMainColor;
        self.btn_Status.layer.borderColor = [UIColor clearColor].CGColor;
    }
    else
    {
        
    }
    
    
    
    //    if( bFollowing )
    //    {
    //        self.btn_Status.backgroundColor = [UIColor whiteColor];
    //        self.btn_Status.layer.borderColor = [UIColor lightGrayColor].CGColor;
    //
    //        BOOL bMember = [[self.dicM_Data objectForKey:@"isChannelMember"] boolValue];
    //        if( bMember )
    //        {
    //
    //        }
    //        else
    //        {
    //
    //        }
    //    }
    //    else
    //    {
    //        self.btn_Status.backgroundColor = kMainColor;
    //        self.btn_Status.layer.borderColor = kMainColor.CGColor;
    //    }
    
    
    
    ///////////////////////////
    
    NSString *str_FollowingCnt = [NSString stringWithFormat:@"%@\n팔로워", [self.dicM_Data objectForKey:@"channelFollowerCount"]];
    [self.btn_FollowingCnt setTitle:str_FollowingCnt forState:UIControlStateNormal];

    NSString *str_MemberCnt = [NSString stringWithFormat:@"%@\n회원", [self.dicM_Data objectForKey:@"channelMemberCount"]];
    [self.btn_MemberCnt setTitle:str_MemberCnt forState:UIControlStateNormal];

    NSString *str_AdminCnt = [NSString stringWithFormat:@"%@\n관리자", [self.dicM_Data objectForKey:@"channelManagerCount"]];
    [self.btn_AdminCnt setTitle:str_AdminCnt forState:UIControlStateNormal];


    
    self.lb_ChannelName.text = [self.dicM_Data objectForKey:@"channelName"];

//    NSString *str_TotalUser = [NSString stringWithFormat:@"%@명", [resulte objectForKey:@"hashTagUserCount"]];
//    [self.btn_TotalUser setTitle:str_TotalUser forState:UIControlStateNormal];

    self.arM_SubjectList = [NSMutableArray array];
    [self.arM_SubjectList addObject:@{@"subjectName":@"레포트",
                                      @"examCount":[NSString stringWithFormat:@"%@", [self.dicM_Data objectForKey:@"reportCount"]]}];

    [self.arM_SubjectList addObject:@{@"subjectName":@"전체",
                                      @"examCount":[NSString stringWithFormat:@"%@", [self.dicM_Data objectForKey:@"channelExamCount"]]}];

    [self.arM_SubjectList addObjectsFromArray:[self.dicM_Data objectForKey:@"channelExamSubjectNameInfos"]];
    [self updateSubjectList];
    
    [self.tbv_List reloadData];
    ///////////////////////
    
    
    
//    [self.view setNeedsLayout];
    
    self.btn_Status.hidden = NO;
}

- (void)updateSubjectList
{
    BOOL isFirst = YES;

    UIScrollView *sv = nil;
    if( self.isChannelMode )
    {
        sv = self.sv_ChannelModeSubjectList;
    }
    else
    {
        sv = self.sv_SubjectList;
    }

    for( id subView in sv.subviews )
    {
        if( [subView isKindOfClass:[UIButton class]] )
        {
            isFirst = NO;
        }
    }
    
    for( id subView in self.sv_ChannelModeSubjectList.subviews )
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
            else
            {
                [btn setTitleColor:kMainColor forState:UIControlStateNormal];
                [btn setTitleColor:kMainColor forState:UIControlStateHighlighted];
            }
            
            if( [[dic objectForKey:@"subjectName"] isEqualToString:@"전체"] )
            {
                btn.selected = YES;
            }
            
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            
            [btn addTarget:self action:@selector(onMenuSelected:) forControlEvents:UIControlEventTouchUpInside];
            
            if( self.isChannelMode )
            {
                [self.sv_ChannelModeSubjectList addSubview:btn];
            }
            else
            {
                [self.sv_SubjectList addSubview:btn];
            }
        }
        
        if( self.isChannelMode )
        {
            self.sv_ChannelModeSubjectList.contentSize = CGSizeMake(70 * self.arM_SubjectList.count, 0);
        }
        else
        {
            self.sv_SubjectList.contentSize = CGSizeMake(70 * self.arM_SubjectList.count, 0);
        }
        
        [self updateTableView:@"전체"];
    }
}

- (void)onReportTouchDown:(UIButton *)btn
{
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:BundleImage(@"rect_green.png") forState:UIControlStateNormal];
    [self performSelector:@selector(onRemoveInteraction:) withObject:btn afterDelay:0.5f];
}

- (void)onRemoveInteraction:(UIButton *)btn
{
    [btn setTitleColor:[UIColor colorWithHexString:@"4FB826"] forState:UIControlStateNormal];
    [btn setBackgroundImage:BundleImage(@"") forState:UIControlStateNormal];
}

- (void)onMenuSelected:(UIButton *)btn
{
    NSDictionary *dic = self.arM_SubjectList[btn.tag];
    
    if( btn.tag != 0 )
    {
        UIScrollView *sv = nil;
        if( self.isChannelMode )
        {
            sv = self.sv_ChannelModeSubjectList;
        }
        else
        {
            sv = self.sv_SubjectList;
        }

        for( id subView in sv.subviews )
        {
            if( [subView isKindOfClass:[UIButton class]] )
            {
                UIButton *btn_Sub = (UIButton *)subView;
                btn_Sub.selected = NO;
            }
        }
        
        btn.selected = YES;
    }
    
    [self updateTableView:[dic objectForKey:@"subjectName"]];
}

- (void)updateTableView:(NSString *)aSubject
{
    if( [aSubject isEqualToString:@"레포트"] )
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Channel" bundle:nil];
        ChannelReportViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChannelReportViewController"];
        vc.str_ChannelId = self.str_ChannelId;
        [self.navigationController pushViewController:vc animated:YES];

        return;
    }
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        @"channel", @"channelType",
                                        @"", @"channelHashTag",
                                        nil];
    
    if( [aSubject isEqualToString:@"전체"] )
    {
        [dicM_Params setObject:@"0" forKey:@"subjectName"];
    }
    else
    {
        [dicM_Params setObject:aSubject forKey:@"subjectName"];
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
                                                self.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"examListInfos"]];
                                                [self.tbv_List reloadData];
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
    
    
    cell.v_Progess.hidden = cell.v_Star.hidden = YES;
    
    CGFloat fTotalCnt = [[dic objectForKey:@"questionCount"] floatValue];
    CGFloat fFinishCnt = [[dic objectForKey:@"solveQuestionCount"] floatValue];
    
    CGFloat fFinishPer = fFinishCnt / fTotalCnt;
    cell.lc_ProgressWidth.constant = cell.lc_ProgressBgWidth.constant * fFinishPer;

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
    
    QuestionStartViewController  *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"QuestionStartViewController"];
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
    return 10.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v_Section = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10)];
    v_Section.backgroundColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1];
    return v_Section;
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
    
    if( scrollView == self.tbv_List )
    {
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
}

- (void)onItemInfo:(UIButton *)btn
{
    NSDictionary *dic = self.arM_List[btn.tag];
    
    __block NSString *str_ExamId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"examId"]];
    
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

    BOOL isChannelManagerRequest = [[self.dicM_Data objectForKey:@"isChannelManagerRequest"] boolValue];
    if( isMannager && isChannelManagerRequest == NO )
    {
        NSString *str_Shared = [dic objectForKey:@"OpenYn"];
        if( [str_Shared isEqualToString:@"Y"] )
        {
            [arM_Test addObject:@{@"type":@"toggle", @"contents":@"회원에게만 공유", @"value":@"Y"}];
        }
        else
        {
            [arM_Test addObject:@{@"type":@"toggle", @"contents":@"회원에게만 공유", @"value":@"N"}];
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
        else if( [str_Type isEqualToString:@"toggle"] )
        {
            NSNumber *num = [completeResult objectForKey:@"onOff"];
            BOOL isOnOff = [num boolValue];
            [self onSharedChange:isOnOff withExamId:str_ExamId withIdx:btn.tag];
        }
    }];
    
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

//- (void)updateList
//{
//    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                                        [Util getUUID], @"uuid",
//                                        self.str_ChannelId, @"channelId",
//                                        nil];
//    
//    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/my"
//                                        param:dicM_Params
//                                   withMethod:@"GET"
//                                    withBlock:^(id resulte, NSError *error) {
//                                        
//                                        [MBProgressHUD hide];
//                                        
////                                        [UIView animateWithDuration:0.3f
////                                                         animations:^{
////                                                            self.view.alpha = YES;
////                                                         }];
//                                        
//                                        if( resulte )
//                                        {
//                                            NSLog(@"resulte : %@", resulte);
//                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
//                                            if( nCode == 200 )
//                                            {
//                                                self.dicM_Data = [NSMutableDictionary dictionaryWithDictionary:resulte];
//                                                [self updateData];
//                                            }
//                                            else
//                                            {
//                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
//                                            }
//                                        }
//                                        
//                                        [self updateQuestionList];
//                                        [self updateQnAList];
//                                        [self updateFolloingList];
//                                        [self updateMemberList];
//                                        [self updateMannagerList];
//                                    }];
//}
//
//- (void)updateQuestionList
//{
//    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                                        [Util getUUID], @"uuid",
//                                        self.str_ChannelId, @"channelId",
//                                        nil];
//    
//    //#채널일때 v1/get/package/exam/browse (빨간색 파라미터 3개만 쓰면 됨)
//    //일반채널일때 v1/get/channel/my/exam
//    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/my/exam"
//                                        param:dicM_Params
//                                   withMethod:@"GET"
//                                    withBlock:^(id resulte, NSError *error) {
//                                        
//                                        [MBProgressHUD hide];
//                                        
//                                        if( resulte )
//                                        {
//                                            NSLog(@"resulte : %@", resulte);
//                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
//                                            if( nCode == 200 )
//                                            {
//                                                self.ar_Question = [NSArray arrayWithArray:[resulte objectForKey:@"examListInfos"]];
//                                                [self.tbv_QuestionList reloadData];
//                                            }
//                                            else
//                                            {
//                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
//                                            }
//                                        }
//                                    }];
//}
//
//- (void)updateQnAList
//{
//    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                                        [Util getUUID], @"uuid",
//                                        self.str_ChannelId, @"channelId",
//                                        nil];
//    
//    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/qna/chat/room/list"
//                                        param:dicM_Params
//                                   withMethod:@"GET"
//                                    withBlock:^(id resulte, NSError *error) {
//                                        
//                                        [MBProgressHUD hide];
//                                        
//                                        if( resulte )
//                                        {
//                                            self.ar_Qna = nil;
//                                            
//                                            isMember = [[resulte objectForKey:@"isMember"] isEqualToString:@"Y"];
//                                            
//                                            NSLog(@"resulte : %@", resulte);
//                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
//                                            if( nCode == 200 )
//                                            {
//                                                self.ar_Qna = [NSMutableArray arrayWithArray:[resulte objectForKey:@"qnaRoomInfos"]];
//                                            }
//                                            else
//                                            {
//                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
//                                            }
//                                            
//                                            [self.tbv_QnAList reloadData];
//                                        }
//                                    }];
//}
//
//- (void)updateFolloingList
//{
//    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                                        [Util getUUID], @"uuid",
//                                        self.str_ChannelId, @"channelId",
//                                        @"follower", @"statusCode",
//                                        nil];
//    
//    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/user/list"
//                                        param:dicM_Params
//                                   withMethod:@"GET"
//                                    withBlock:^(id resulte, NSError *error) {
//                                        
//                                        [MBProgressHUD hide];
//                                        
//                                        if( resulte )
//                                        {
//                                            self.ar_Following = nil;
//                                            
//                                            NSLog(@"resulte : %@", resulte);
//                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
//                                            if( nCode == 200 )
//                                            {
//                                                self.ar_Following = [NSArray arrayWithArray:[resulte objectForKey:@"userList"]];
//                                            }
//                                            else
//                                            {
//                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
//                                            }
//                                            
//                                            [self.tbv_FollowingList reloadData];
//                                        }
//                                    }];
//}
//
//- (void)updateMemberList
//{
//    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                                        [Util getUUID], @"uuid",
//                                        self.str_ChannelId, @"channelId",
//                                        @"member", @"statusCode",
//                                        nil];
//    
//    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/user/list"
//                                        param:dicM_Params
//                                   withMethod:@"GET"
//                                    withBlock:^(id resulte, NSError *error) {
//                                        
//                                        [MBProgressHUD hide];
//                                        
//                                        if( resulte )
//                                        {
//                                            self.ar_Member = nil;
//
//                                            NSLog(@"resulte : %@", resulte);
//                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
//                                            if( nCode == 200 )
//                                            {
//                                                self.ar_Member = [NSArray arrayWithArray:[resulte objectForKey:@"userList"]];
//                                            }
//                                            else
//                                            {
//                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
//                                            }
//                                            
//                                            [self.tbv_MemberList reloadData];
//                                        }
//                                    }];
//}
//
//- (void)updateMannagerList
//{
//    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                                        [Util getUUID], @"uuid",
//                                        self.str_ChannelId, @"channelId",
//                                        @"manager", @"statusCode",
//                                        nil];
//    
//    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/user/list"
//                                        param:dicM_Params
//                                   withMethod:@"GET"
//                                    withBlock:^(id resulte, NSError *error) {
//                                        
//                                        [MBProgressHUD hide];
//                                        
//                                        if( resulte )
//                                        {
//                                            self.ar_Mannager = nil;
//                                            
//                                            NSLog(@"resulte : %@", resulte);
//                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
//                                            if( nCode == 200 )
//                                            {
//                                                NSMutableArray *arM_Tmp = [NSMutableArray array];
//                                                self.ar_Mannager = [NSArray arrayWithArray:[resulte objectForKey:@"userList"]];
//                                                
//                                                if( isMannager == NO )
//                                                {
//                                                    //관리자가 아닐시 관리자인 사람만 보이게 하기
//                                                    
//                                                    for( NSInteger i = 0; i < self.ar_Mannager.count; i++ )
//                                                    {
//                                                        NSDictionary *dic = self.ar_Mannager[i];
//                                                        NSInteger nLevel = [[dic objectForKey:@"memberLevel"] integerValue];
//                                                        NSString *str_Status = [dic objectForKey:@"statusCode"];
//                                                        if( [str_Status isEqualToString:@"T"] && nLevel == 9 )
//                                                        {
//                                                            [arM_Tmp addObject:dic];
//                                                        }
//                                                    }
//
//                                                    self.ar_Mannager = [NSArray arrayWithArray:arM_Tmp];
//                                                }
//                                            }
//                                            else
//                                            {
//                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
//                                            }
//                                            
//                                            [self.tbv_MannagerList reloadData];
//                                        }
//                                    }];
//}


/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */




//#pragma mark - Table view methods
//- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
//{
//    return 1;
//}
//
//// Customize the number of rows in the table view.
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
//{
//    if( tableView == self.tbv_QuestionList )            return self.ar_Question.count;
//    else if( tableView == self.tbv_QnAList )            return isMannager ? self.ar_Qna.count + 1 : self.ar_Qna.count;
//    else if( tableView == self.tbv_FollowingList )      return self.ar_Following.count;
//    else if( tableView == self.tbv_MemberList )         return self.ar_Member.count;
//    else if( tableView == self.tbv_MannagerList )       return self.ar_Mannager.count;
//    
//    return 0;
//}
//
//// Customize the appearance of table view cells.
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if( tableView == self.tbv_QuestionList )
//    {
//        ChannelQuestionListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelQuestionListCell"];
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        
//        cell.btn_Price.tag = cell.sw_Shared.tag = indexPath.row;
//        
//        NSDictionary *dic = self.ar_Question[indexPath.row];
//        
//        cell.iv_Thumb.backgroundColor = [UIColor colorWithHexString:[dic objectForKey_YM:@"codeHex"]];
//        
//        //문제집 제목
//        cell.lb_QuestionTitle.text = [dic objectForKey:@"examTitle"];
//        
//        //제목
//        cell.lb_Title.text = [dic objectForKey:@"subjectName"];
//        
//        //학교 학년
//        NSInteger nGrade = [[dic objectForKey:@"personGrade"] integerValue];
//        cell.lb_Grade.text = [NSString stringWithFormat:@"%@ %@학년", [dic objectForKey:@"schoolGrade"], nGrade == 0 ? @"전체" : [NSString stringWithFormat:@"%ld", nGrade]];
//        
//        //출판사
//        cell.lb_Owner.text = [dic objectForKey:@"publisherName"];
//        
//        //공유 버튼들
//        NSString *str_Shared = [dic objectForKey:@"OpenYn"];
//        cell.sw_Shared.on = ![str_Shared isEqualToString:@"Y"];
//        [cell.sw_Shared addTarget:self action:@selector(onSharedChange:) forControlEvents:UIControlEventValueChanged];
//        
//        if( isMannager == NO )
//        {
//            cell.v_Shared.hidden = YES;
//        }
//        
//        [cell.btn_Price removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
//
//        //구매버튼 관련
//        BOOL isPruchase = [[dic objectForKey:@"isPaid"] boolValue];
//        if( isPruchase )
//        {
//            //구매한 경우
//            [cell.btn_Price setTitle:@"문제풀기" forState:UIControlStateNormal];
//            [cell.btn_Price addTarget:self action:@selector(onShowMyPage:) forControlEvents:UIControlEventTouchUpInside];
//        }
//        else
//        {
//            //구매하지 않은 경우
//            //구매 버튼
//            NSString *str_Purchers = @"";
//            if( [[dic objectForKey:@"heartCount"] integerValue] == 0 )
//            {
//                //무료
//                str_Purchers = @"무료";
//            }
//            else
//            {
//                //유료
//                NSInteger nQuestionCount = [[dic objectForKey:@"questionCount"] integerValue];
//                str_Purchers = [NSString stringWithFormat:@"$%f", nQuestionCount - 0.01];
//            }
//            
//            [cell.btn_Price setTitle:str_Purchers forState:UIControlStateNormal];
//            [cell.btn_Price addTarget:self action:@selector(onPrice:) forControlEvents:UIControlEventTouchUpInside];
//        }
//        
//        
//        return cell;
//    }
//    else if( tableView == self.tbv_QnAList )
//    {
//        QnACell *cell = [tableView dequeueReusableCellWithIdentifier:@"QnACell"];
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        
//        /*
//         codeHex = "#607D8B";
//         codeName = "bgm-bluegray";
//         createDate = 20160906000000;
//         personGrade = 1;
//         qnaCount = 0;
//         roomName = "\Uad6d\Uc5b4";
//         schoolGrade = "\Uace0\Ub4f1\Ud559\Uad50";
//         subjectName = "\Uad6d\Uc5b4";
//         */
//     
//        if( isMember && indexPath.row != self.ar_Qna.count )
//        {
//            //관리자이고 마지막 셀이 아니면
//            cell.btn_Info.tag = indexPath.row;
//            cell.btn_Info.hidden = NO;
//            [cell.btn_Info addTarget:self action:@selector(onInfo:) forControlEvents:UIControlEventTouchUpInside];
//        }
//        else
//        {
//            cell.btn_Info.hidden = YES;
//        }
//        
//        
//        if( isMannager && indexPath.row == self.ar_Qna.count )
//        {
//            //마지막 셀
//            cell.v_TitleBg.backgroundColor = [UIColor colorWithHexString:@"#E4E4E4"];
//            cell.lb_Title.text = @"+ #질문방 만들기";
//            cell.lb_PeopleCnt.text = @"";
//            cell.lb_Date.text = @"";
//            
//            cell.btn_Info.hidden = YES;
//        }
//        else
//        {
//            NSDictionary *dic = self.ar_Qna[indexPath.row];
//            cell.v_TitleBg.backgroundColor = [UIColor colorWithHexString:[dic objectForKey_YM:@"codeHex"]];
//            cell.lb_Title.text = [NSString stringWithFormat:@"#%@", [dic objectForKey:@"roomName"]];
//            cell.lb_PeopleCnt.text = [NSString stringWithFormat:@"%@ 참가자", [dic objectForKey:@"userCount"]];
//            
//            NSString *str_Date = [NSString stringWithFormat:@"%@", [dic objectForKey:@"lastChatDate"]];
//            
//            if( str_Date.length >= 12 )
//            {
//                NSString *str_Year = [str_Date substringWithRange:NSMakeRange(0, 4)];
//                NSString *str_Month = [str_Date substringWithRange:NSMakeRange(4, 2)];
//                NSString *str_Day = [str_Date substringWithRange:NSMakeRange(6, 2)];
//                NSString *str_Hour = [str_Date substringWithRange:NSMakeRange(8, 2)];
//                NSString *str_Minute = [str_Date substringWithRange:NSMakeRange(10, 2)];
//                
//                cell.lb_Date.text = [NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld", [str_Year integerValue], [str_Month integerValue], [str_Day integerValue], [str_Hour integerValue], [str_Minute integerValue]];
//            }
//            else
//            {
//                cell.lb_Date.text = str_Date;
//            }
//        }
//        
//        return cell;
//    }
//    else if( tableView == self.tbv_FollowingList )
//    {
//        ChannelFollowingListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelFollowingListCell"];
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        
//        cell.btn_Add.tag = indexPath.row;
//        
//        NSDictionary *dic = self.ar_Following[indexPath.row];
//        
//        //유저 이미지
//        NSString *str_ImageUrl = [dic objectForKey:@"imgUrl"];
//        if( [str_ImageUrl isEqualToString:@"no_image"] )
//        {
//            [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_NoImagePrefix]];
//        }
//        else
//        {
//            [cell.iv_User sd_setImageWithURL:[Util createImageUrl:str_UserImagePrefix withFooter:[dic objectForKey:@"imgUrl"]]];
//        }
//        
//        //유저 이름
//        cell.lb_Name.text = [dic objectForKey:@"userName"];
//        
//        //학교 학년
//        cell.lb_Grade.text = [NSString stringWithFormat:@"%@ %@", [dic objectForKey:@"userAffiliation"], [dic objectForKey:@"userMajor"]];
//        
//        if( isMannager )
//        {
//            //회원 버튼
//            cell.btn_Add.userInteractionEnabled = YES;
//            
//            NSInteger nLevel = [[dic objectForKey:@"memberLevel"] integerValue];
//            NSString *str_Status = [dic objectForKey:@"statusCode"];
//            if( [str_Status isEqualToString:@"T"] && nLevel == 99 )
//            {
//                //관리자 신청중인 사람
//                [cell.btn_Add setTitle:@"관리자 승인대기중" forState:UIControlStateNormal];
//                cell.btn_Add.selected = NO;
//                cell.btn_Add.userInteractionEnabled = NO;
//            }
//            else if( [str_Status isEqualToString:@"T"] )
//            {
//                //관리자
//                [cell.btn_Add setTitle:@"관리자" forState:UIControlStateNormal];
//                cell.btn_Add.userInteractionEnabled = NO;
//            }
//            else if( [str_Status isEqualToString:@"M"] )
//            {
//                //현재 회원이거나 관리자일 경우
//                [cell.btn_Add setTitle:@"회원해제" forState:UIControlStateNormal];
//                cell.btn_Add.selected = YES;
//            }
//            else
//            {
//                [cell.btn_Add setTitle:@"+회원등록" forState:UIControlStateNormal];
//                cell.btn_Add.selected = NO;
//            }
//            
//            [cell.btn_Add addTarget:self action:@selector(onAddFollower:) forControlEvents:UIControlEventTouchUpInside];
//        }
//        else
//        {
//            cell.btn_Add.hidden = YES;
//        }
//        
//        return cell;
//    }
//    else if( tableView == self.tbv_MemberList )
//    {
//        ChannelFollowingListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelFollowingListCell"];
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        
//        cell.btn_Add.tag = cell.btn_Close.tag = indexPath.row;
//        
//        NSDictionary *dic = self.ar_Member[indexPath.row];
//        
//        //유저 이미지
//        NSString *str_ImageUrl = [dic objectForKey:@"imgUrl"];
//        if( [str_ImageUrl isEqualToString:@"no_image"] )
//        {
//            [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_NoImagePrefix]];
//        }
//        else
//        {
//            [cell.iv_User sd_setImageWithURL:[Util createImageUrl:str_UserImagePrefix withFooter:[dic objectForKey:@"imgUrl"]]];
//        }
//        
//        //유저 이름
//        cell.lb_Name.text = [dic objectForKey:@"userName"];
//        
//        //학교 학년
//        cell.lb_Grade.text = [NSString stringWithFormat:@"%@ %@", [dic objectForKey:@"userAffiliation"], [dic objectForKey:@"userMajor"]];
//        
//        if( isMannager )
//        {
//            cell.lc_CloseWidth.constant = 0.f;
//            cell.btn_Add.selected = NO;
//            cell.btn_Add.layer.borderColor = [UIColor clearColor].CGColor;
//
//            [cell.btn_Add removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
//            [cell.btn_Close removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
//            
//            //회원추가시 수락여부 [A-수락, D-거부, N-회원 아님, Y-사용자 답변 대기중, C-관리자가 해제]
//            NSString *str_MemberAllow = [dic objectForKey:@"isMemberAllow"];
//            if( [str_MemberAllow isEqualToString:@"D"] )
//            {
//                [cell.btn_Add setTitle:@"회원거부" forState:UIControlStateNormal];
//                cell.btn_Add.titleLabel.textColor = kMainColor;
//                [cell.btn_Add setTitleColor:kMainColor forState:UIControlStateNormal];
//                cell.btn_Add.layer.borderColor = kMainRedColor.CGColor;
//                cell.lc_CloseWidth.constant = 50.f;
//                
//                [cell.btn_Close addTarget:self action:@selector(onMoveToFollower:) forControlEvents:UIControlEventTouchUpInside];
//            }
//            else if( [str_MemberAllow isEqualToString:@"Y"] )
//            {
//                [cell.btn_Add setTitle:@"회원대기" forState:UIControlStateNormal];
//                [cell.btn_Add setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//                cell.btn_Add.layer.borderColor = [UIColor lightGrayColor].CGColor;
//                cell.lc_CloseWidth.constant = 50.f;
//                
//                [cell.btn_Close addTarget:self action:@selector(onMoveToFollower:) forControlEvents:UIControlEventTouchUpInside];
//            }
//            else
//            {
//                //회원 버튼
//                NSString *str_Status = [dic objectForKey:@"statusCode"];
//                if( [str_Status isEqualToString:@"M"] || [str_Status isEqualToString:@"T"] )
//                {
//                    //현재 회원이거나 관리자일 경우
//                    [cell.btn_Add setTitle:@"회원해제" forState:UIControlStateNormal];
//                    cell.btn_Add.selected = YES;
//                }
//                else
//                {
//                    [cell.btn_Add setTitle:@"+회원등록" forState:UIControlStateNormal];
//                    cell.btn_Add.selected = NO;
//                }
//                
//                [cell.btn_Add addTarget:self action:@selector(onAddMember:) forControlEvents:UIControlEventTouchUpInside];
//            }
//        }
//        else
//        {
//            cell.btn_Add.hidden = YES;
//        }
//        
//        return cell;
//    }
//    else if( tableView == self.tbv_MannagerList )
//    {
//        ChannelFollowingListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelFollowingListCell"];
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//        
//        cell.btn_Add.tag = indexPath.row;
//        
//        NSDictionary *dic = self.ar_Mannager[indexPath.row];
//        
//        //유저 이미지
//        NSString *str_ImageUrl = [dic objectForKey:@"imgUrl"];
//        if( [str_ImageUrl isEqualToString:@"no_image"] )
//        {
//            [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_NoImagePrefix]];
//        }
//        else
//        {
//            [cell.iv_User sd_setImageWithURL:[Util createImageUrl:str_UserImagePrefix withFooter:[dic objectForKey:@"imgUrl"]]];
//        }
//        
//        //유저 이름
//        cell.lb_Name.text = [dic objectForKey:@"userName"];
//        
//        //학교 학년
//        cell.lb_Grade.text = [NSString stringWithFormat:@"%@ %@", [dic objectForKey:@"userAffiliation"], [dic objectForKey:@"userMajor"]];
//        
//        if( isMannager )
//        {
//            //회원 버튼
//            NSString *str_Status = [dic objectForKey:@"statusCode"];
//            NSInteger nLevel = [[dic objectForKey:@"memberLevel"] integerValue];
//            if( nLevel < 10 )
//            {
//                //관리자
//                [cell.btn_Add setTitle:@"관리자해제" forState:UIControlStateNormal];
//                cell.btn_Add.selected = YES;
//            }
//            else if( nLevel == 99 || [str_Status isEqualToString:@"T"] )
//            {
//                //관리자 신청자
//                [cell.btn_Add setTitle:@"+관리자등록" forState:UIControlStateNormal];
//                cell.btn_Add.selected = NO;
//            }
//            
//            [cell.btn_Add addTarget:self action:@selector(onAddMannager:) forControlEvents:UIControlEventTouchUpInside];
//        }
//        else
//        {
//            cell.btn_Add.hidden = YES;
//        }
//        
//        return cell;
//    }
//
//    return nil;
//}
//
//// Override to support row selection in the table view.
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    if( tableView == self.tbv_QuestionList )
//    {
//        NSDictionary *dic = self.ar_Question[indexPath.row];
//        BOOL isPruchase = [[dic objectForKey:@"isPaid"] boolValue];
//        if( isPruchase )
//        {
////            [[NSNotificationCenter defaultCenter] postNotificationName:kChangeTabBar object:[NSNumber numberWithInteger:5]];
//        }
//        
//        //문제집 디테일로 이동
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//        QuestionDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"QuestionDetailViewController"];
//        vc.str_Idx = [NSString stringWithFormat:@"%@", [dic objectForKey:@"examId"]];
//        vc.str_Title = [dic objectForKey:@"examTitle"];
//        [self.navigationController pushViewController:vc animated:YES];
//    }
//    else if( tableView == self.tbv_QnAList )
//    {
//        if( isMannager && indexPath.row == self.ar_Qna.count )
//        {
//            //질문방 만들기
//            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
//            UINavigationController *navi = [storyboard instantiateViewControllerWithIdentifier:@"MakeChattingRoomNavi"];
//            MakeChattingRoomViewController *vc = (MakeChattingRoomViewController *)[navi.viewControllers firstObject];
//            vc.hidesBottomBarWhenPushed = YES;
//            vc.str_ChannelId = self.str_ChannelId;
//            [vc setCompletionBlock:^(id completeResult) {
//               
//                [self updateQnAList];
//            }];
//            [self performSelector:@selector(onShowMakeController:) withObject:navi afterDelay:0.1f];
//        }
//        else
//        {
//            NSDictionary *dic = self.ar_Qna[indexPath.row];
//            if( isMember )
//            {
//                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chatting" bundle:nil];
//                ChattingViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChattingViewController"];
//                vc.dic_Info = dic;
//                vc.str_ChannelId = self.str_ChannelId;
//                vc.str_RId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"rId"]];
//                vc.hidesBottomBarWhenPushed = YES;
//                [self.navigationController pushViewController:vc animated:YES];
//            }
//            else
//            {
//                [self.navigationController.view makeToast:@"회원만 참가할 수 있습니다." withPosition:kPositionBottom];
//            }
//        }
//    }
//    else
//    {
//        NSDictionary *dic = nil;
//        if( tableView == self.tbv_FollowingList )
//        {
//            dic = self.ar_Following[indexPath.row];
//        }
//        else if( tableView == self.tbv_MemberList )
//        {
//            dic = self.ar_Member[indexPath.row];
//        }
//        else if( tableView == self.tbv_MannagerList )
//        {
//            dic = self.ar_Mannager[indexPath.row];
//        }
//        
//        BOOL isMyManner = NO;
//        
//        NSData *followChannelInfoData = [[NSUserDefaults standardUserDefaults] objectForKey:@"followChannelInfo"];
//        NSArray *ar_MyChannelMannagerList = [NSKeyedUnarchiver unarchiveObjectWithData:followChannelInfoData];
//        for( NSInteger i = 0; i < ar_MyChannelMannagerList.count; i++ )
//        {
//            NSDictionary *dic = ar_MyChannelMannagerList[i];
//            if( [[dic objectForKey:@"isChannelAdmin"] isEqualToString:@"N"] )
//            {
//                continue;
//            }
//            
//            if( [self.str_ChannelId integerValue] == [[dic objectForKey:@"channelId"] integerValue] )
//            {
//                isMyManner = YES;
//                break;
//            }
//        }
//        
//        //회원추가시 수락여부 [A-수락, D-거부, N-회원 아님, Y-사용자 답변 대기중, C-관리자가 해제]
//        NSString *str_MemberAllow = [dic objectForKey:@"isMemberAllow"];
//        if( isMyManner )
//        {
//            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//            MyMainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
//            vc.isManagerView = YES;
//            vc.isPermission = [str_MemberAllow isEqualToString:@"A"];
//            vc.str_UserIdx = [dic objectForKey:@"userId"];
//            vc.isShowNavi = YES;
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//        else
//        {
//            MyMainViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
//            vc.isAnotherUser = YES;
//            vc.str_UserIdx = [dic objectForKey:@"userId"];
//            [self.navigationController pushViewController:vc animated:YES];
//        }
//    }
//}

//- (void)onInfo:(UIButton *)btn
//{
//    __block NSDictionary *dic = self.ar_Qna[btn.tag];
//    
//    NSMutableArray *arM = [NSMutableArray array];
//    [arM addObject:@"삭제"];
//    [arM addObject:@"참여자 보기"];
//    
//    [OHActionSheet showSheetInView:self.view
//                             title:nil
//                 cancelButtonTitle:@"취소"
//            destructiveButtonTitle:nil
//                 otherButtonTitles:arM
//                        completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
//     {
//         if( buttonIndex == 0 )
//         {
//             //삭제
//             UIAlertView *alert = CREATE_ALERT(nil, @"삭제하시겠습니까?", @"확인", @"취소");
//             [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                 
//                 if( buttonIndex == 0 )
//                 {
//                     NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                                         [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                                                         [Util getUUID], @"uuid",
//                                                         [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]], @"channelId",
//                                                         [NSString stringWithFormat:@"%@", [dic objectForKey:@"rId"]], @"rId",
//                                                         nil];
//                     
//                     __weak __typeof(&*self)weakSelf = self;
//                     
//                     [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/delete/channel/qna/chat/room"
//                                                         param:dicM_Params
//                                                    withMethod:@"GET"
//                                                     withBlock:^(id resulte, NSError *error) {
//                                                         
//                                                         [MBProgressHUD hide];
//                                                         
//                                                         if( resulte )
//                                                         {
//                                                             NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
//                                                             if( nCode == 200 )
//                                                             {
//                                                                 [self.ar_Qna removeObjectAtIndex:btn.tag];
//                                                                 [self.tbv_QnAList reloadData];
//                                                                 [self updateQnAList];
////                                                                 NSInteger nGroupId = [[dic objectForKey:@"groupId"] integerValue];
////                                                                 NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"rId":[NSString stringWithFormat:@"%@", [dic objectForKey:@"rId"]]}
////                                                                                                                    options:NSJSONWritingPrettyPrinted
////                                                                                                                      error:&error];
////                                                                 NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
////                                                                 
////                                                                 [SendBird sendMessage:@"delete-room" withData:jsonString];
//                                                             }
//                                                             else
//                                                             {
//                                                                 [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
//                                                             }
//                                                         }
//                                                     }];
//                 }
//             }];
//         }
//         else if( buttonIndex == 1 )
//         {
//             //참여자 보기
//             UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chatting" bundle:nil];
//             InRoomMemberListViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"InRoomMemberListViewController"];
//             vc.str_ChannelId = self.str_ChannelId;
//             vc.str_QuestionId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]];
//             [self.navigationController pushViewController:vc animated:YES];
//         }
//     }];
//}

- (void)onShowMakeController:(UINavigationController *)navi
{
    [self presentViewController:navi animated:YES completion:^{
        
    }];
}



#pragma mark - IBAction
- (IBAction)goFollower:(id)sender
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        self.btn_Folloer.selected == NO ? @"follow" : @"unfollow", @"setMode",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/channel/follow"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                if( self.btn_Folloer.selected == NO )
                                                {
                                                    isFollowing = YES;
                                                    [self setSelectedLayer:self.btn_Folloer];
                                                }
                                                else
                                                {
                                                    isFollowing = NO;
                                                    [self setDefaultLayer:self.btn_Folloer];
                                                }
                                                
                                                [self updateList];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

- (IBAction)goMannager:(id)sender
{
    //내 페이지는 관리자 해제 못하게 왜냐면 내 페이지니까
//    if( isMyPage )  return;
    
    
    if( isMannager )
    {
        UIAlertView *alert = CREATE_ALERT(nil, @"관리자 해제 하시겠습니까?", @"예", @"아니요");
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            if( buttonIndex == 0 )
            {
                [self mannager];
            }
        }];
    }
    else
    {
        [self mannager];
    }
}

- (void)mannager
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/channel/request/manager"
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
//                                                [self.navigationController.view makeToast:@"관리자 신청 되었습니다" withPosition:kPositionCenter];
                                                [self updateList];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

- (IBAction)goMeneSelected:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if( btn == self.btn_Report )
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Channel" bundle:nil];
        ChannelReportViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChannelReportViewController"];
        vc.str_ChannelId = self.str_ChannelId;
        [self.navigationController pushViewController:vc animated:YES];
        
        return;
    }
    
    for( id subView in self.v_Menus.subviews )
    {
        if( [subView isKindOfClass:[UIButton class]] )
        {
            UIButton *subBtn = (UIButton *)subView;
            subBtn.selected = NO;
        }
    }
    
    for( id subView in self.v_MemberMenu.subviews )
    {
        if( [subView isKindOfClass:[UIButton class]] )
        {
            UIButton *subBtn = (UIButton *)subView;
            subBtn.selected = NO;
        }
    }

    
    btn.selected = YES;
    
    if( sender == self.btn_QestionList || sender == self.btn_QestionList2 )
    {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             
                             self.sv_Contents.contentOffset = CGPointMake(self.sv_Contents.bounds.size.width * 0, 0);
                         }];
    }
    else if( sender == self.btn_QnAList || sender == self.btn_QnAList2 )
    {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             
                             self.sv_Contents.contentOffset = CGPointMake(self.sv_Contents.bounds.size.width * 1, 0);
                         }];
    }
    else if( sender == self.btn_FollowingList || sender == self.btn_FollowingList2 )
    {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             
                             self.sv_Contents.contentOffset = CGPointMake(self.sv_Contents.bounds.size.width * 2, 0);
                         }];
    }
    else if( sender == self.btn_MemberList || sender == self.btn_MemberList2 )
    {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             
                             self.sv_Contents.contentOffset = CGPointMake(self.sv_Contents.bounds.size.width * 3, 0);
                         }];
    }
    else if( sender == self.btn_MannagerList )
    {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             
                             self.sv_Contents.contentOffset = CGPointMake(self.sv_Contents.bounds.size.width * 4, 0);
                         }];
    }
}

//- (void)onSharedChange:(UISwitch *)sw
//{
//    NSDictionary *dic = self.ar_Question[sw.tag];
//
//    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                                        [Util getUUID], @"uuid",
//                                        self.str_ChannelId, @"channelId",
//                                        [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]], @"examId",
//                                        sw.on ? @"C" : @"Y", @"setMode",
//                                        nil];
//    
//    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/exam/only/channel/open"
//                                        param:dicM_Params
//                                   withMethod:@"POST"
//                                    withBlock:^(id resulte, NSError *error) {
//                                        
//                                        [MBProgressHUD hide];
//                                        
//                                        if( resulte )
//                                        {
//                                            NSLog(@"resulte : %@", resulte);
//                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
//                                            if( nCode == 200 )
//                                            {
//                                                [self updateList];
//                                            }
//                                            else
//                                            {
//                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
//                                            }
//                                        }
//                                    }];
//}

//- (void)onPrice:(UIButton *)btn
//{
//    __block NSDictionary *dic = self.ar_Question[btn.tag];
//
//    UIAlertView *alert = CREATE_ALERT(nil, @"문제를 구매하시겠습니까?", @"예", @"아니요");
//    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//        if( buttonIndex == 0 )
//        {
//            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                                [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                                                [Util getUUID], @"uuid",
//                                                [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]], @"examId",
//                                                nil];
//            
//            [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/user/paymentinfo"
//                                                param:dicM_Params
//                                           withMethod:@"POST"
//                                            withBlock:^(id resulte, NSError *error) {
//                                                
//                                                [MBProgressHUD hide];
//                                                
//                                                if( resulte )
//                                                {
//                                                    NSLog(@"resulte : %@", resulte);
//                                                    NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
//                                                    if( nCode == 200 )
//                                                    {
//                                                        ALERT(nil, @"문제를 구매 했습니다", nil, @"확인", nil);
////                                                        [[NSNotificationCenter defaultCenter] postNotificationName:kChangeTabBar object:[NSNumber numberWithInteger:5]];
//                                                        
//                                                        [self updateQuestionList];
//                                                    }
//                                                    else
//                                                    {
//                                                        [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
//                                                    }
//                                                }
//                                            }];
//        }
//    }];
//}

- (void)onAddFollower:(UIButton *)btn
{
    NSDictionary *dic = self.ar_Following[btn.tag];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        [NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]], @"userId",
                                        btn.selected ? @"terminate" : @"mamber", @"setMode",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/channel/member"
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

- (void)onAddMember:(UIButton *)btn
{
    if( btn.selected )
    {
        UIAlertView *alert = CREATE_ALERT(nil, @"회원 해제 하시겠습니까?", @"예", @"아니요");
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            if( buttonIndex == 0 )
            {
                [self addMember:btn];
            }
        }];
    }
    else
    {
        [self addMember:btn];
    }
}

- (void)addMember:(UIButton *)btn
{
    NSDictionary *dic = self.ar_Member[btn.tag];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        [NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]], @"userId",
                                        btn.selected ? @"terminate" : @"mamber", @"setMode",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/channel/member"
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

- (void)onMoveToFollower:(UIButton *)btn
{
    NSDictionary *dic = self.ar_Member[btn.tag];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        [NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]], @"userId",
                                        @"terminate", @"setMode",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/channel/member"
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
                                                [self.navigationController.view makeToast:[NSString stringWithFormat:@"%@님이 회원 리스트에서 삭제 되었습니다", [dic objectForKey:@"userName"]] withPosition:kPositionCenter];
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
    if( btn.selected )
    {
        UIAlertView *alert = CREATE_ALERT(nil, @"관리자 해제 하시겠습니까?", @"예", @"아니요");
        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
            
            if( buttonIndex == 0 )
            {
                [self addMannager:btn];
            }
        }];
    }
    else
    {
        [self addMannager:btn];
    }
}

- (void)addMannager:(UIButton *)btn
{
    NSDictionary *dic = self.ar_Mannager[btn.tag];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        [NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]], @"userId",
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

- (void)onShowMyPage:(UIButton *)btn
{
    NSDictionary *dic = self.ar_Question[btn.tag];

    QuestionStartViewController  *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"QuestionStartViewController"];
    //        vc.hidesBottomBarWhenPushed = YES;
    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
    vc.str_StartIdx = @"0";
    vc.str_Title = [dic objectForKey:@"examTitle"];
    vc.str_ChannelId = self.str_ChannelId;
//    vc.str_UserIdx = self.str_UserIdx;
    vc.isPdf = [[dic objectForKey:@"examType"] isEqualToString:@"pdfExam"];
    
    [self.navigationController pushViewController:vc animated:YES];

//    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeTabBar object:[NSNumber numberWithInteger:5]];

//    //문제풀기
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentQuestionIdx"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//
//    NSDictionary *dic = self.ar_Question[btn.tag];
//    
//    QuestionContainerViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
//    vc.hidesBottomBarWhenPushed = YES;
//    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
//    vc.str_StartIdx = @"0";
//    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goStatusTouch:(id)sender
{
    [self.view endEditing:YES];

    //팔로잉 여부
    BOOL bFollowing = [[self.dicM_Data objectForKey:@"isChannelFollower"] boolValue];
    
    //회원 여부
    BOOL bMember = [[self.dicM_Data objectForKey:@"isChannelMember"] boolValue];
    
    //회원 신청 여부가 필요함
    BOOL bReqMember = [[self.dicM_Data objectForKey:@"isChannelMemberRequest"] boolValue];
    
    //관리자 여부
    BOOL bMannager = [[self.dicM_Data objectForKey:@"isChannelManager"] boolValue];
    
    //관리자 신청 여부
    BOOL bReqMannager = [[self.dicM_Data objectForKey:@"isChannelManagerRequest"] boolValue];
    
    if( bFollowing == NO )
    {
        //팔로잉이 아닌 경우 바로 팔로우 하게
        [self follow:YES];
    }
    else if( bFollowing && bMember == NO && bReqMember == NO && bMannager == NO && bReqMannager == NO )
    {
        //단순 팔로잉일 경우엔 취소
        [OHActionSheet showSheetInView:self.view
                                 title:@"팔로우를 취소하시겠어요?"
                     cancelButtonTitle:@"취소"
                destructiveButtonTitle:@"팔로우 취소"
                     otherButtonTitles:nil
                            completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
         {
             if( buttonIndex == 0 )
             {
                 [self follow:NO];
             }
         }];
    }
    else if( bMember && bMannager == NO && bReqMannager == NO )
    {
        //회원인 상태
        [OHActionSheet showSheetInView:self.view
                                 title:@"회원을 취소하시겠어요?"
                     cancelButtonTitle:@"취소"
                destructiveButtonTitle:@"회원 취소"
                     otherButtonTitles:nil
                            completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
         {
             if( buttonIndex == 0 )
             {
                 //회원취소
                 [self member:NO];
             }
         }];
    }
    else if( bMannager && bReqMannager == NO )
    {
        //관리자인 상태
        [OHActionSheet showSheetInView:self.view
                                 title:@"관리자를 취소하시겠어요?"
                     cancelButtonTitle:@"취소"
                destructiveButtonTitle:@"관리자 취소"
                     otherButtonTitles:nil
                            completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
         {
             if( buttonIndex == 0 )
             {
                 //관리자 취소
                 [self mannager];
             }
         }];
    }
    else if( [self.btn_Status.titleLabel.text isEqualToString:@"회원 요청 중"] )
    {
        [OHActionSheet showSheetInView:self.view
                                 title:@"회원 요청을 취소하시겠어요?"
                     cancelButtonTitle:@"취소"
                destructiveButtonTitle:@"회원 요청 취소"
                     otherButtonTitles:nil
                            completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
         {
             if( buttonIndex == 0 )
             {
                 //회원 요청 취소 취소
                 NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                     [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                     [Util getUUID], @"uuid",
                                                     self.str_ChannelId, @"channelId",
                                                     [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"], @"userId",
                                                     @"terminate", @"setMode",
                                                     nil];
                 
                 [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/channel/member"
                                                     param:dicM_Params
                                                withMethod:@"POST"
                                                 withBlock:^(id resulte, NSError *error) {
                                                     
                                                     [MBProgressHUD hide];
                                                     
                                                     if( resulte )
                                                     {
                                                         [self updateList];
                                                     }
                                                 }];
             }
         }];
    }
    else if( [self.btn_Status.titleLabel.text isEqualToString:@"관리자 요청 중"] )
    {
        [OHActionSheet showSheetInView:self.view
                                 title:@"관리자 요청을 취소하시겠어요?"
                     cancelButtonTitle:@"취소"
                destructiveButtonTitle:@"관리자 요청 취소"
                     otherButtonTitles:nil
                            completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
         {
             if( buttonIndex == 0 )
             {
                 //관리자 요청 취소 취소
                 NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                     [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                     [Util getUUID], @"uuid",
                                                     self.str_ChannelId, @"channelId",
                                                     [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"], @"userId",
                                                     @"terminate", @"setMode",
                                                     nil];
                 
                 [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/channel/member"
                                                     param:dicM_Params
                                                withMethod:@"POST"
                                                 withBlock:^(id resulte, NSError *error) {
                                                     
                                                     [MBProgressHUD hide];
                                                     
                                                     if( resulte )
                                                     {
                                                         [self updateList];
                                                     }
                                                 }];
             }
         }];
    }
}

- (IBAction)goInfo:(id)sender
{
    [self.view endEditing:YES];
    
    if( [self.btn_Status.titleLabel.text isEqualToString:@"팔로잉"] || [self.btn_Status.titleLabel.text isEqualToString:@"팔로우"] )
    {
        //상태가 팔로잉이거나 아무것도 아닐시
        [OHActionSheet showSheetInView:self.view
                                 title:nil
                     cancelButtonTitle:@"취소"
                destructiveButtonTitle:nil
                     otherButtonTitles:@[@"메세지 보내기", @"회원 요청", @"관리자 요청", @"신고"]
                            completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
         {
             if( buttonIndex == 0 )
             {
                 //메세지 보내기
                 [self sendMessage];
             }
             else if( buttonIndex == 1 )
             {
                 //회원요청
                 [self member:YES];
             }
             else if( buttonIndex == 2 )
             {
                 //관리자 요청
                 [self mannager];
             }
             else if( buttonIndex == 3 )
             {
                 //신고
                 [self sendReport];
             }
         }];
    }
    else if( [self.btn_Status.titleLabel.text isEqualToString:@"회원 요청 중"] || [self.btn_Status.titleLabel.text isEqualToString:@"회원"] )
    {
        [OHActionSheet showSheetInView:self.view
                                 title:nil
                     cancelButtonTitle:@"취소"
                destructiveButtonTitle:nil
                     otherButtonTitles:@[@"메세지 보내기", @"관리자 요청", @"신고"]
                            completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
         {
             if( buttonIndex == 0 )
             {
                 //메세지 보내기
                 [self sendMessage];
             }
             else if( buttonIndex == 1 )
             {
                 //관리자 요청
                 [self mannager];
             }
             else if( buttonIndex == 2 )
             {
                 //신고
                 [self sendReport];
             }
         }];
    }
    else if( [self.btn_Status.titleLabel.text isEqualToString:@"관리자 요청 중"] || [self.btn_Status.titleLabel.text isEqualToString:@"관리자"] )
    {
        [OHActionSheet showSheetInView:self.view
                                 title:nil
                     cancelButtonTitle:@"취소"
                destructiveButtonTitle:nil
                     otherButtonTitles:@[@"메세지 보내기", @"신고"]
                            completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
         {
             if( buttonIndex == 0 )
             {
                 //메세지 보내기
                 [self sendMessage];
             }
             else if( buttonIndex == 1 )
             {
                 //신고
                 [self sendReport];
             }
         }];
    }
}

- (void)mannager:(BOOL)isOn
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"], @"userId",
                                        isOn ? @"manager" : @"delete", @"setMode",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/channel/manager"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
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

- (void)follow:(BOOL)isOn
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        isOn ? @"follow" : @"unfollow", @"setMode",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/channel/follow"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
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

- (void)member:(BOOL)isOn
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"], @"userId",
                                        isOn ? @"member" : @"terminate", @"setMode",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/channel/member"
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

- (void)sendMessage
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/message/room/info"
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
                                                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
                                                ChatFeedViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedViewController"];
                                                vc.hidesBottomBarWhenPushed = YES;
                                                vc.str_RId = [NSString stringWithFormat:@"%@", [resulte objectForKey_YM:@"rId"]];
                                                vc.str_RoomName = [NSString stringWithFormat:@"%@", [resulte objectForKey_YM:@"roomName"]];
                                                //    vc.roomColor = nil;
                                                vc.dic_Info = resulte;
                                                vc.channelImageUrl = [resulte objectForKey_YM:@"channelImgUrl"];
                                                //    rId = 515;
                                                [self.navigationController pushViewController:vc animated:YES];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];

}

- (void)sendReport
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/channel/report"
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
                                                [self.navigationController.view makeToast:@"신고 되었습니다" withPosition:kPositionCenter];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

- (IBAction)goShowFollowingList:(id)sender
{
    UserControllListViewController *vc = [kEtcBoard instantiateViewControllerWithIdentifier:@"UserControllListViewController"];
    vc.isMannager = isMannager;
    vc.str_ChannelId = self.str_ChannelId;
    vc.isChannel = YES;
    vc.str_Mode = @"follower";
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goShowMemberList:(id)sender
{
    UserControllListViewController *vc = [kEtcBoard instantiateViewControllerWithIdentifier:@"UserControllListViewController"];
    vc.isMannager = isMannager;
    vc.str_ChannelId = self.str_ChannelId;
    vc.str_Mode = @"member";
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goShowAdminList:(id)sender
{
    UserControllListViewController *vc = [kEtcBoard instantiateViewControllerWithIdentifier:@"UserControllListViewController"];
    vc.isMannager = isMannager;
    vc.str_ChannelId = self.str_ChannelId;
    vc.str_Mode = @"manager";
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onSharedChange:(BOOL)isOnOff withExamId:(NSString *)aExamId withIdx:(NSInteger)nIdx
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        aExamId, @"examId",
                                        isOnOff ? @"C" : @"Y", @"setMode",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/exam/only/channel/open"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:self.arM_List[nIdx]];
                                                if( [[dicM objectForKey:@"OpenYn"] isEqualToString:@"Y"] )
                                                {
                                                    [dicM setObject:@"N" forKey:@"OpenYn"];
                                                }
                                                else
                                                {
                                                    [dicM setObject:@"Y" forKey:@"OpenYn"];
                                                }
                                                [self.arM_List replaceObjectAtIndex:nIdx withObject:dicM];
                                                [self.tbv_List reloadData];
//                                                [self updateList];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

@end
