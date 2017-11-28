//
//  MyMainViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 6. 22..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "MyMainViewController.h"
#import "MyQuestionListCell.h"
#import "MyFollowingCell.h"
#import "AppDelegate.h"
#import "QuestionContainerViewController.h"
#import "GroupWebViewController.h"
#import "ReportDetailViewController.h"
#import "ChannelMainViewController.h"
#import "InputUserInfoViewController.h"
#import "InputUserInfo2ViewController.h"
#import "OptionViewController.h"
#import "ReportViewController.h"
#import "QuestionStartViewController.h"
#import "QnACell.h"
#import "ChattingViewController.h"
#import "InRoomMemberListViewController.h"
#import "PageViewController.h"
#import "ReportMainViewController.h"
#import "MyHeaderView.h"
#import "ActionSheetBottomViewController.h"
#import "SharedViewController.h"
#import "UserListViewController.h"
#import "SharpChannelMainViewController.h"
#import "QuestionDetailViewController.h"
#import "WrongAnsStarViewController.h"

typedef enum {
    kUpload     = -1,
    kPaid       = 0,
    KNoData     = 1,
} QuestionType;

@interface MyMainViewController () <UIScrollViewDelegate, UIActionSheetDelegate, MyHeaderViewDelegate>
{
    BOOL isMyPage;
    BOOL isFirst;
    
    NSString *str_ImagePrefix;
    NSString *str_UserImagePrefix;
    NSString *str_NoImagePrefix;
    
    NSInteger nUploadCount;
    NSInteger nPaidCount;
    QuestionType questionType;
    
    NSInteger nInCorrectQuestionCount;  //오답 카운트
    NSInteger nStarQuestionCount;       //별표 카운트
}
@property (nonatomic, strong) NSMutableDictionary *dicM_Data;
//상단뷰
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Name;
@property (nonatomic, weak) IBOutlet UILabel *lb_Hash;
@property (nonatomic, weak) IBOutlet UILabel *lb_TotalUser;
@property (nonatomic, weak) IBOutlet UIButton *btn_Profile;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ProfileWidth;
@property (nonatomic, weak) IBOutlet UIView *v_Tag;

//메뉴뷰
@property (nonatomic, weak) IBOutlet UIView *v_Menus;
@property (nonatomic, weak) IBOutlet UIButton *btn_QestionList;
@property (nonatomic, weak) IBOutlet UIButton *btn_QnAList;
@property (nonatomic, weak) IBOutlet UIButton *btn_FollowingList;
@property (nonatomic, weak) IBOutlet UIButton *btn_BookMarkList;
@property (nonatomic, weak) IBOutlet UIButton *btn_ReportList;
//@property (nonatomic, weak) IBOutlet UIButton *btn_Report;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Contents;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ContentsWidth;

//하단 메뉴 테이블뷰들
@property (nonatomic, strong) NSArray *ar_Question;
@property (nonatomic, strong) NSMutableArray *ar_Qna;
@property (nonatomic, strong) NSArray *ar_Following;
@property (nonatomic, strong) NSArray *ar_Report;
@property (nonatomic, weak) IBOutlet UITableView *tbv_QuestionList;
@property (nonatomic, weak) IBOutlet UITableView *tbv_QnAList;
@property (nonatomic, weak) IBOutlet UITableView *tbv_FollowingList;
@property (nonatomic, weak) IBOutlet UITableView *tbv_ReportList;


//새로 수정된 부분
@property (nonatomic, strong) NSString *str_CurrentSubject;
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) NSMutableArray *arM_SubjectiList;
@property (nonatomic, strong) MyHeaderView *v_MyHeaderView;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@end

@implementation MyMainViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    isFirst = YES;
    questionType = KNoData;
    
    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"MyHeaderView" owner:self options:nil];
    self.v_MyHeaderView = [topLevelObjects objectAtIndex:0];
    self.v_MyHeaderView.delegate = self;
//    self.v_MyHeaderView.backgroundColor = [UIColor redColor];
//    self.tbv_List.backgroundColor = [UIColor blueColor];
    self.tbv_List.tableHeaderView = self.v_MyHeaderView;
    
    
    //    self.btn_Profile.hidden = YES;
    //
    //    self.v_Tag.layer.cornerRadius = 8.f;
    //    self.v_Tag.layer.borderColor = kMainColor.CGColor;
    //    self.v_Tag.layer.borderWidth = 1.f;
    //
    //    self.btn_Profile.titleLabel.textAlignment = NSTextAlignmentCenter;
    //    self.btn_QestionList.titleLabel.textAlignment = NSTextAlignmentCenter;
    //    self.btn_QnAList.titleLabel.textAlignment = NSTextAlignmentCenter;
    //    self.btn_FollowingList.titleLabel.textAlignment = NSTextAlignmentCenter;
    //    self.btn_BookMarkList.titleLabel.textAlignment = NSTextAlignmentCenter;
    //    self.btn_ReportList.titleLabel.textAlignment = NSTextAlignmentCenter;
    ////    self.btn_Report.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    if( self.isAnotherUser )
    {
        
    }
    else
    {
        if( self.isManagerView == NO )
        {
            self.str_UserIdx = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
        }
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMyPageQuestion) name:kShowMyPageQuestion object:nil];
}

- (void)showMyPageQuestion
{
    [self.navigationController popToRootViewControllerAnimated:NO];
    self.tbv_QuestionList.contentOffset = CGPointZero;
    [self goMeneSelected:self.btn_QestionList];
}

- (void)settingButtonPressed:(UIButton *)btn
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Setting" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"OptionViewController"];
    [self.navigationController pushViewController:vc animated:YES];
    
    //    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil
    //                                                             delegate:self
    //                                                    cancelButtonTitle:@"취소"
    //                                               destructiveButtonTitle:@"로그아웃"
    //                                                    otherButtonTitles:nil];
    //
    //    [actionSheet showInView:self.view];
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
    
    //    self.navigationController.navigationBarHidden = YES;
    
    if( self.isShowNavi )
    {
        self.navigationController.navigationBarHidden = NO;
    }
    else
    {
        self.navigationController.navigationBarHidden = YES;
    }
    
    if( self.isAnotherUser )
    {
        self.navigationController.navigationBarHidden = NO;
    }
    
    [MBProgressHUD hide];
    
    [self updateList];
}

- (void)viewDidLayoutSubviews
{
    //    if( isMyPage )
    if( self.isManagerView == NO )
    {
        //        self.btn_Profile.hidden = NO;
    }
    else
    {
        //        self.btn_Profile.hidden = YES;
        self.lc_ProfileWidth.constant = 0;
    }
    
    self.sv_Contents.contentSize = CGSizeMake(self.sv_Contents.bounds.size.width * 5, 0);
    self.lc_ContentsWidth.constant = self.sv_Contents.contentSize.width;
    
    if( self.v_MyHeaderView )
    {
        if( self.v_MyHeaderView.arM_List.count > 2 )
        {
            CGRect frame = self.v_MyHeaderView.frame;
            if( nUploadCount > 0 && nPaidCount == 0 )
            {
                frame.size.height = 270.f + ((self.v_MyHeaderView.arM_List.count - 2) * 44);
            }
            else if( nUploadCount > 0 && nPaidCount > 0 )
            {
                frame.size.height = 270.f + ((self.v_MyHeaderView.arM_List.count - 2) * 44);
            }
            else
            {
                frame.size.height = 220.f + ((self.v_MyHeaderView.arM_List.count - 2) * 44);
            }
            self.v_MyHeaderView.frame = frame;
        }
        else
        {
            CGRect frame = self.v_MyHeaderView.frame;
            if( nUploadCount > 0 && nPaidCount == 0 )
            {
//                frame.size.height = 270.f + ((self.v_MyHeaderView.arM_List.count) * 44);
                frame.size.height = 270.f;
                
                if( self.v_MyHeaderView.arM_List.count == 2 )
                {
                    frame.size.height = 270.f;
                }
                else
                {
                    frame.size.height = 220.f;
                }
            }
            else if( nUploadCount > 0 && nPaidCount > 0 )
            {
//                frame.size.height = 270.f + ((self.v_MyHeaderView.arM_List.count) * 44);
                if( self.v_MyHeaderView.arM_List.count == 2 )
                {
                    frame.size.height = 270.f;
                }
                else
                {
                    frame.size.height = 220.f;
                }
            }
            else
            {
                frame.size.height = 220.f;
            }

            self.v_MyHeaderView.frame = frame;
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// // In a storyboard-based application, you will often want to do a little preparation before navigation
// - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
// // Get the new view controller using [segue destinationViewController].
// // Pass the selected object to the new view controller.
//
//     if( [segue.identifier isEqualToString:@"MyProfileSegue"] )
//     {
//         NSString *str_SchoolId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userSchoolId"];
//         if( [str_SchoolId integerValue] > 0 )
//         {
//             //학생인 경우
//             InputUserInfoViewController *vc = [segue destinationViewController];
//             vc.isProfileMode = YES;
//         }
//         else
//         {
//             //학생이 아닌 경우
//             InputUserInfo2ViewController *vc = [segue destinationViewController];
//             vc.isProfileMode = YES;
//         }
//     }
// }



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
                                            self.str_ChannelId = [NSString stringWithFormat:@"%@", [resulte objectForKey:@"hashtagChannelId"]];
                                            
                                            NSLog(@"resulte : %@", resulte);
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                self.dicM_Data = [NSMutableDictionary dictionaryWithDictionary:resulte];
                                                self.v_MyHeaderView.dic_Data = self.dicM_Data;
                                                [self updateData];
                                            }
                                        }
                                        
                                        nUploadCount = [[resulte objectForKey:@"myUploadExamCount"] integerValue];
                                        nPaidCount = [[resulte objectForKey:@"myPaidExamCount"] integerValue];
                                        
                                        if( isFirst )
                                        {
                                            isFirst = NO;
                                            
                                            [self.v_MyHeaderView.btn_Q1 removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
                                            [self.v_MyHeaderView.btn_Q2 removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
                                            
                                            //올린 문제가 없을 경우 표시하지 않음
                                            if( nUploadCount == 0 && nPaidCount > 0 )
                                            {
                                                self.v_MyHeaderView.lc_QuestionHeight.constant = 0.f;
                                                questionType = kPaid;
                                            }
                                            
                                            //올린 문제와 구매한 문제 둘 다 없을 경우 표시하지 않음
                                            if( nUploadCount == 0 && nPaidCount == 0 )
                                            {
                                                self.v_MyHeaderView.lc_QuestionHeight.constant = 0.f;
                                                questionType = KNoData;
                                            }
                                            
                                            //올린 문제만 있을 경우
                                            if( nUploadCount > 0 && nPaidCount == 0 )
                                            {
                                                questionType = kUpload;
                                                
                                                self.v_MyHeaderView.lc_QuestionHeight.constant = 50.f;
                                                
                                                [self.v_MyHeaderView.btn_Q1 setTitle:[NSString stringWithFormat:@"올린문제 %ld", nUploadCount]
                                                                            forState:UIControlStateNormal];
                                                
                                                self.v_MyHeaderView.btn_Q1.selected = YES;
                                            }
                                            
                                            //둘 다 있을 경우
                                            if( nUploadCount > 0 && nPaidCount > 0 )
                                            {
                                                self.v_MyHeaderView.lc_QuestionHeight.constant = 50.f;
                                                
                                                if( nUploadCount > nPaidCount )
                                                {
                                                    //올린 문제가 더 많을 경우
                                                    questionType = kUpload;
                                                    
                                                    [self.v_MyHeaderView.btn_Q2 setTitle:[NSString stringWithFormat:@"올린문제 %ld", nUploadCount]
                                                                                forState:UIControlStateNormal];
                                                    
                                                    [self.v_MyHeaderView.btn_Q1 setTitle:[NSString stringWithFormat:@"구매문제 %ld", nPaidCount]
                                                                                forState:UIControlStateNormal];
                                                    
                                                    [self.v_MyHeaderView.btn_Q2 addTarget:self
                                                                                   action:@selector(onUploadTouch:) forControlEvents:UIControlEventTouchUpInside];
                                                    
                                                    [self.v_MyHeaderView.btn_Q1 addTarget:self
                                                                                   action:@selector(onPaidTouch:) forControlEvents:UIControlEventTouchUpInside];
                                                }
                                                else
                                                {
                                                    //구매 문제가 더 많을 경우
                                                    questionType = kPaid;
                                                    
                                                    [self.v_MyHeaderView.btn_Q2 setTitle:[NSString stringWithFormat:@"구매문제 %ld", nPaidCount]
                                                                                forState:UIControlStateNormal];
                                                    
                                                    [self.v_MyHeaderView.btn_Q1 setTitle:[NSString stringWithFormat:@"올린문제 %ld", nUploadCount]
                                                                                forState:UIControlStateNormal];
                                                    
                                                    [self.v_MyHeaderView.btn_Q2 addTarget:self
                                                                                   action:@selector(onPaidTouch:) forControlEvents:UIControlEventTouchUpInside];
                                                    
                                                    [self.v_MyHeaderView.btn_Q1 addTarget:self
                                                                                   action:@selector(onUploadTouch:) forControlEvents:UIControlEventTouchUpInside];
                                                }
                                                
                                                self.v_MyHeaderView.btn_Q2.selected = YES;
                                                self.v_MyHeaderView.btn_Q1.selected = NO;
                                            }
                                        }
                                        
                                        self.v_MyHeaderView.arM_SubjectiList = [NSMutableArray array];
                                        
                                        if( self.isAnotherUser == NO )
                                        {
                                            nInCorrectQuestionCount = [[resulte objectForKey:@"inCorrectQuestionCount"] integerValue];
                                            nStarQuestionCount = [[resulte objectForKey:@"starQuestionCount"] integerValue];
                                            
                                            [self.v_MyHeaderView.arM_SubjectiList addObject:@{@"subjectName":@"레포트",
                                                                                              @"examCount":[NSString stringWithFormat:@"%@", [resulte objectForKey:@"reportCount"]]}];
                                            [self.v_MyHeaderView.arM_SubjectiList addObject:@{@"subjectName":@"오답,별표",
                                                                                              @"examCount":[NSString stringWithFormat:@"%ld",
                                                                                                            nInCorrectQuestionCount + nStarQuestionCount]}];
                                        }
                                        
                                        if( questionType == kUpload )
                                        {
                                            [self.v_MyHeaderView.arM_SubjectiList addObject:@{@"subjectName":@"전체",
                                                                                              @"examCount":[NSString stringWithFormat:@"%@", [resulte objectForKey:@"myUploadExamCount"]]}];
                                            [self.v_MyHeaderView.arM_SubjectiList addObjectsFromArray:[resulte objectForKey:@"myUploadSubjectNameInfos"]];
                                        }
                                        else
                                        {
                                            [self.v_MyHeaderView.arM_SubjectiList addObject:@{@"subjectName":@"전체",
                                                                                              @"examCount":[NSString stringWithFormat:@"%@", [resulte objectForKey:@"myPaidExamCount"]]}];
                                            [self.v_MyHeaderView.arM_SubjectiList addObjectsFromArray:[resulte objectForKey:@"myPaidSubjectNameInfos"]];
                                        }
                                        [self.v_MyHeaderView updateSubjectList];
                                        
                                        NSArray *ar_MemberListTmp = [NSArray arrayWithArray:[resulte objectForKey:@"memberChannelInfos"]];
                                        self.v_MyHeaderView.arM_List = [NSMutableArray array];
                                        [self.v_MyHeaderView.arM_List addObject:@{@"type":@"school"}];
                                        [self.v_MyHeaderView.arM_List addObjectsFromArray:ar_MemberListTmp];
                                        [self.v_MyHeaderView.btn_Member setTitle:[NSString stringWithFormat:@"%ld\n회원", ar_MemberListTmp.count]
                                                                        forState:UIControlStateNormal];
                                        [self.v_MyHeaderView.tbv_School reloadData];
                                        
                                        [self.v_MyHeaderView updateSelectSubject:self.str_CurrentSubject];
                                    }];
}



#pragma mark - MyHeaderViewDelegate
- (void)tableViewTouch:(NSDictionary *)dic
{
    NSLog(@"%@", dic);
    
    if( [[dic objectForKey:@"type"] isEqualToString:@"school"] )
    {
        //학교로 이동
        SharpChannelMainViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"SharpChannelMainViewController"];
        vc.isShowNavi = self.isShowNavi;
        vc.dic_Info = self.dicM_Data;
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        //채널로 이동
        ChannelMainViewController *vc = [kChannelBoard instantiateViewControllerWithIdentifier:@"ChannelMainViewController"];
        vc.isShowNavi = YES;
        vc.str_ChannelId = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"channelId"] integerValue]];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)onReloadInterval
{
    [self.tbv_List reloadData];
    
    NSString *str_Path = [NSString stringWithFormat:@"%@/api/v1/get/user/my/upload/exam", kBaseUrl];
    [[WebAPI sharedData] cancelMethod:@"GET" withPath:str_Path];
}

- (void)updateTableView:(NSString *)aSubject
{
    if( [aSubject isEqualToString:@"레포트"] )
    {
        ReportMainViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportMainViewController"];
        vc.str_ChannelId = self.str_ChannelId;
        vc.str_UserId = self.str_UserIdx;
        [self.navigationController pushViewController:vc animated:YES];
        
        return;
    }
    else if( [aSubject isEqualToString:@"오답,별표"] )
    {
        WrongAnsStarViewController *vc = [kEtcBoard instantiateViewControllerWithIdentifier:@"WrongAnsStarViewController"];
        [self.navigationController pushViewController:vc animated:YES];
        
        return;
    }
    
    self.str_CurrentSubject = aSubject;
    
    BOOL isShowIndicator = YES;
    NSString *str_Key = [NSString stringWithFormat:@"%@_%@_%@",//Upload_전체_138
                         questionType == kUpload ? @"Upload" : @"Paid",
                         aSubject,
                         self.str_UserIdx];
    NSData *dictionaryData = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
    NSDictionary *resulte = [NSKeyedUnarchiver unarchiveObjectWithData:dictionaryData];
    if( resulte )
    {
        isShowIndicator = NO;
        self.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"examListInfos"]];
        [self performSelector:@selector(onReloadInterval) withObject:nil afterDelay:0.3f];
        
        
    }

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_UserIdx, @"pUserId",
                                        nil];
    
    if( [aSubject isEqualToString:@"전체"] )
    {
        [dicM_Params setObject:@"0" forKey:@"subjectName"];
    }
    else
    {
        [dicM_Params setObject:aSubject forKey:@"subjectName"];
    }
    
    NSString *str_Path = @"";
    if( questionType == kUpload )
    {
        str_Path = @"v1/get/user/my/upload/exam";
    }
    else
    {
        str_Path = @"v1/get/user/my/paid/exam";
    }
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:str_Path
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
                                                NSString *str_Key = [NSString stringWithFormat:@"%@_%@_%@",//Upload_전체_138
                                                                     questionType == kUpload ? @"Upload" : @"Paid",
                                                                     aSubject,
                                                                     self.str_UserIdx];
                                                NSData *data = [NSKeyedArchiver archivedDataWithRootObject:resulte];
                                                [[NSUserDefaults standardUserDefaults] setObject:data forKey:str_Key];
                                                [[NSUserDefaults standardUserDefaults] synchronize];

                                                self.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"examListInfos"]];
                                                [self.tbv_List reloadData];
                                            }
                                        }
                                    }];
}



//- (void)updateSubjectList
//{
//    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                                        [Util getUUID], @"uuid",
//                                        self.str_UserIdx, @"pUserId",
//                                        @"0", @"subjectName",
//                                        nil];
//
//    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/user/my/paid/exam"
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
//                                        }
//                                    }];
//}

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

- (void)updateQnAList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_UserIdx, @"pUserId",
                                        @"my", @"callWhere",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/channel/qna/chat/room/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            self.ar_Qna = nil;
                                            
                                            NSLog(@"resulte : %@", resulte);
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                self.ar_Qna = [NSMutableArray arrayWithArray:[resulte objectForKey:@"qnaRoomInfos"]];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                            
                                            [self.tbv_QnAList reloadData];
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
    //v1/get/report/user/daily
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
    
    if( self.isManagerView )
    {
        [self initNaviWithTitle:[self.dicM_Data objectForKey:@"userName"] withLeftItem:[self leftBackBlackMenuBarButtonItem] withRightItem:nil withColor:[UIColor colorWithHexString:@"F8F8F8"]];
    }
    else
    {
        if( self.isAnotherUser )
        {
            NSString *str_MyId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
            NSString *str_UserID = [NSString stringWithFormat:@"%@", self.str_UserIdx];
            if( [ str_UserID isEqualToString:str_MyId] )
            {
                [self initNaviWithTitle:[self.dicM_Data objectForKey:@"userName"] withLeftItem:[self leftBackBlackMenuBarButtonItem] withRightItem:[self rightLogOutButtonItem] withColor:[UIColor colorWithHexString:@"F8F8F8"]];
            }
            else
            {
                [self initNaviWithTitle:[self.dicM_Data objectForKey:@"userName"] withLeftItem:[self leftBackBlackMenuBarButtonItem] withRightItem:nil withColor:[UIColor colorWithHexString:@"F8F8F8"]];
            }
        }
        else
        {
            [self initNaviWithTitle:[self.dicM_Data objectForKey:@"userName"] withLeftItem:nil withRightItem:[self rightLogOutButtonItem] withColor:[UIColor colorWithHexString:@"F8F8F8"]];
        }
    }
    
    
    isMyPage = [[self.dicM_Data objectForKey:@"isMyPage"] boolValue];
    str_ImagePrefix = [self.dicM_Data objectForKey:@"img_prefix"];
    str_UserImagePrefix = [self.dicM_Data objectForKey:@"userImg_prefix"];
    str_NoImagePrefix = [self.dicM_Data objectForKey:@"no_image"];
    
    NSString *str_ImageUrl = [self.dicM_Data objectForKey:@"imgUrl"];
    if( [str_ImageUrl isEqualToString:@"no_image"] )
    {
        [self.v_MyHeaderView.iv_User sd_setImageWithString:str_NoImagePrefix completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            NSData *data = UIImagePNGRepresentation(image);
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"userImage"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
        //        [self.iv_User sd_setImageWithURL:[NSURL URLWithString:str_NoImagePrefix]];
    }
    else
    {
        [self.v_MyHeaderView.iv_User sd_setImageWithString:str_ImageUrl completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            NSData *data = UIImagePNGRepresentation(image);
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"userImage"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }];
        //        [self.iv_User sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
    }
    
    //    [self.iv_User sd_setImageWithURL:[Util createImageUrl:str_UserImagePrefix withFooter:[self.dicM_Data objectForKey:@"imgUrl"]]];
    
    self.v_MyHeaderView.lb_Name.text = [self.dicM_Data objectForKey:@"userName"];
    
    //    self.lb_Hash.text = [self.dicM_Data objectForKey:@"hashtagStr"];
    //
    //    self.lb_TotalUser.text = [NSString stringWithFormat:@"%ld명", [[self.dicM_Data objectForKey:@"useHashCodeCount"] integerValue]];
    
    //    NSString *str_ButtonTitle = [NSString stringWithFormat:@"%ld\n%@", [[self.dicM_Data objectForKey:@"buyExamCount"] integerValue], @"문제들"];
    //    [self.btn_QestionList setTitle:str_ButtonTitle forState:UIControlStateNormal];
    //
    //    str_ButtonTitle = [NSString stringWithFormat:@"%ld\n%@", [[self.dicM_Data objectForKey:@"chatRoomCount"] integerValue], @"질문과답"];
    //    [self.btn_QnAList setTitle:str_ButtonTitle forState:UIControlStateNormal];
    
    NSString *str_ButtonTitle = [NSString stringWithFormat:@"%ld\n%@", [[self.dicM_Data objectForKey:@"followChannelCount"] integerValue], @"팔로잉"];
    [self.v_MyHeaderView.btn_Following setTitle:str_ButtonTitle forState:UIControlStateNormal];
    
    //    str_ButtonTitle = [NSString stringWithFormat:@"%ld\n%@", [[self.dicM_Data objectForKey:@"useHashCodeCount"] integerValue], @"회원"];
    //    [self.v_MyHeaderView.btn_Member setTitle:str_ButtonTitle forState:UIControlStateNormal];
    
    
    //    str_ButtonTitle = [NSString stringWithFormat:@"%ld\n%@", [[self.dicM_Data objectForKey:@"bookmarkCount"] integerValue], @"북마크"];
    //    [self.btn_BookMarkList setTitle:str_ButtonTitle forState:UIControlStateNormal];
    //
    //    str_ButtonTitle = [NSString stringWithFormat:@"%ld\n%@", [[self.dicM_Data objectForKey:@"solveExamCount"] integerValue], @"레포트"];
    //    [self.btn_ReportList setTitle:str_ButtonTitle forState:UIControlStateNormal];
    
    //    str_ButtonTitle = [NSString stringWithFormat:@"%ld\n%@", [[self.dicM_Data objectForKey:@"reportCount"] integerValue], @"레포트"];
    //    [self.btn_Report setTitle:str_ButtonTitle forState:UIControlStateNormal];
    
    [self.view setNeedsLayout];
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
    
    //채널관리자가 왔을때 내 나와바리 여부에 따른 처리
    if( self.isManagerView )
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
    
    cell.btn_Info.tag = indexPath.section;
    [cell.btn_Info addTarget:self action:@selector(onItemInfo:) forControlEvents:UIControlEventTouchUpInside];
    
    //TODO: 남이 볼때 화면처리
    
    //    //단원보기
    //    [cell.btn_Group addTarget:self action:@selector(onShowGroup:) forControlEvents:UIControlEventTouchUpInside];
    //
    //    //단원보기 버튼 유무
    //    NSInteger nGroupId = [[dic objectForKey:@"groupId"] integerValue];
    //    if( nGroupId == 0 )
    //    {
    //        //단원없음
    //        cell.btn_Group.hidden = YES;
    //    }
    //    else
    //    {
    //        cell.btn_Group.hidden = NO;
    //    }
    //
    //
    //    //결과보기
    //    [cell.btn_Result addTarget:self action:@selector(onShowResult:) forControlEvents:UIControlEventTouchUpInside];
    //
    //    //결과보기 버튼 유무
    //    NSInteger nFinishCount = [[dic objectForKey:@"isFinishCount"] integerValue];
    //    NSInteger nSolve = [[dic objectForKey:@"isSolve"] integerValue];
    //    if( nFinishCount > 0 || nSolve == 1 )
    //    {
    //        //표시
    //        cell.btn_Result.hidden = NO;
    //    }
    //    else
    //    {
    //        cell.btn_Result.hidden = YES;
    //    }
    
    return cell;
    
    //    if( tableView == self.tbv_QuestionList )
    //    {
    //        MyQuestionListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyQuestionListCell"];
    //        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //
    //        cell.btn_Group.tag = cell.btn_Result.tag = indexPath.row;
    //
    //        NSDictionary *dic = self.ar_Question[indexPath.row];
    //
    //        //채널관리자가 왔을때 내 나와바리 여부에 따른 처리
    //        if( self.isManagerView )
    //        {
    //            //관리자가 들어 왔을시
    ////            if( self.isPermission && [[dic objectForKey:@"isChannelAdmin"] isEqualToString:@"Y"] )
    //            if( 1 )
    //            {
    //                //권한이 있고, 이 채널의 어드민이면
    //                cell.v_Progess.alpha = cell.btn_Result.alpha = cell.btn_Group.alpha = YES;
    //            }
    //            else
    //            {
    //                cell.v_Progess.alpha = cell.btn_Result.alpha = cell.btn_Group.alpha = NO;
    //            }
    //        }
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
    //        if( nGrade == 0 )
    //        {
    //            cell.lb_Grade.text = [NSString stringWithFormat:@"%@", [dic objectForKey:@"schoolGrade"]];
    //        }
    //        else
    //        {
    //            cell.lb_Grade.text = [NSString stringWithFormat:@"%@ %ld학년", [dic objectForKey:@"schoolGrade"], nGrade];
    //        }
    //
    //        //출판사
    //        cell.lb_Owner.text = [dic objectForKey:@"publisherName"];
    //
    //        CGFloat fTotalCnt = [[dic objectForKey:@"questionCount"] floatValue];
    //        CGFloat fFinishCnt = [[dic objectForKey:@"solveQuestionCount"] floatValue];
    //
    //        CGFloat fFinishPer = fFinishCnt / fTotalCnt;
    //        cell.lc_ProgressWidth.constant = cell.lc_ProgressBgWidth.constant * fFinishPer;
    //
    //        //TODO: 남이 볼때 화면처리
    //
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
    //
    //        return cell;
    //    }
    //    else if( tableView == self.tbv_QnAList )
    //    {
    //        QnACell *cell = [tableView dequeueReusableCellWithIdentifier:@"QnACell"];
    //        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //
    //        NSDictionary *dic = self.ar_Qna[indexPath.row];
    //
    //        cell.btn_Info.tag = indexPath.row;
    //        cell.btn_Info.hidden = NO;
    //        [cell.btn_Info addTarget:self action:@selector(onInfo:) forControlEvents:UIControlEventTouchUpInside];
    //
    //        NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [dic objectForKey:@"channelImgUrl"]];
    //        [cell.iv_ChannelIcon sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
    //
    //        cell.iv_ChannelIcon.userInteractionEnabled = YES;
    //        cell.iv_ChannelIcon.tag = indexPath.row;
    //        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
    //        [imageTap setNumberOfTapsRequired:1];
    //        [cell.iv_ChannelIcon addGestureRecognizer:imageTap];
    //
    //        cell.v_TitleBg.backgroundColor = [UIColor colorWithHexString:[dic objectForKey_YM:@"codeHex"]];
    //        cell.lb_Title.text = [NSString stringWithFormat:@"#%@", [dic objectForKey:@"roomName"]];
    //        cell.lb_PeopleCnt.text = [NSString stringWithFormat:@"%@ 참가자", [dic objectForKey:@"userCount"]];
    //
    //        NSString *str_Date = [NSString stringWithFormat:@"%@", [dic objectForKey:@"lastChatDate"]];
    //
    //        if( str_Date.length >= 12 )
    //        {
    //            NSString *str_Year = [str_Date substringWithRange:NSMakeRange(0, 4)];
    //            NSString *str_Month = [str_Date substringWithRange:NSMakeRange(4, 2)];
    //            NSString *str_Day = [str_Date substringWithRange:NSMakeRange(6, 2)];
    //            NSString *str_Hour = [str_Date substringWithRange:NSMakeRange(8, 2)];
    //            NSString *str_Minute = [str_Date substringWithRange:NSMakeRange(10, 2)];
    //
    //            cell.lb_Date.text = [NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld", [str_Year integerValue], [str_Month integerValue], [str_Day integerValue], [str_Hour integerValue], [str_Minute integerValue]];
    //        }
    //        else
    //        {
    //            cell.lb_Date.text = str_Date;
    //        }
    //
    //        return cell;
    //    }
    //    else if( tableView == self.tbv_FollowingList )
    //    {
    //        MyFollowingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyFollowingCell"];
    //        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //
    //        cell.btn_Follow.tag = indexPath.row;
    //
    //        NSDictionary *dic = self.ar_Following[indexPath.row];
    //
    //        //채널 이미지
    //        NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [dic objectForKey:@"channelImgUrl"]];
    //        [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
    //
    //        //팔로우 버튼 초기화
    //        cell.btn_Follow.titleLabel.textAlignment = NSTextAlignmentCenter;
    //        cell.btn_Follow.userInteractionEnabled = YES;
    //        cell.btn_Follow.selected = NO;
    //        [cell.btn_Follow setBackgroundImage:BundleImage(@"blue_box.png") forState:UIControlStateSelected];
    //        [cell.btn_Follow setTitle:@"팔로잉" forState:UIControlStateSelected];
    //        cell.btn_Follow.layer.borderWidth = 1.0f;
    //        [cell.btn_Follow setBackgroundImage:BundleImage(@"") forState:UIControlStateNormal];
    //        [cell.btn_Follow setBackgroundImage:BundleImage(@"") forState:UIControlStateSelected];
    //        /////////////
    //
    //        NSInteger nMemberLevel = [[dic objectForKey:@"memberLevel"] integerValue];
    //        NSString *str_StatusCode = [dic objectForKey:@"statusCode"];
    //        if( [str_StatusCode isEqualToString:@"T"] && nMemberLevel == 9 )
    //        {
    //            //관리자
    ////            cell.btn_Follow.userInteractionEnabled = NO;
    //            cell.btn_Follow.selected = YES;
    //            [cell.btn_Follow setTitle:@"관리자" forState:UIControlStateSelected];
    //            cell.btn_Follow.layer.borderWidth = 0.0f;
    //            [cell.btn_Follow setBackgroundImage:BundleImage(@"red_box.png") forState:UIControlStateSelected];
    //            [cell.btn_Follow addTarget:self action:@selector(onAddMannager:) forControlEvents:UIControlEventTouchUpInside];
    //        }
    //        else if( [str_StatusCode isEqualToString:@"T"] && nMemberLevel == 99 )
    //        {
    //            //관리자 승인대기중
    //            cell.btn_Follow.userInteractionEnabled = NO;
    //            [cell.btn_Follow setTitle:@"관리자\n승인대기중" forState:UIControlStateNormal];
    //            [cell.btn_Follow setTitleColor:kMainColor forState:UIControlStateNormal];
    //            [cell.btn_Follow setBackgroundColor:[UIColor whiteColor]];
    //            cell.btn_Follow.layer.borderColor = kMainColor.CGColor;
    //        }
    //        else
    //        {
    //            //팔로잉 여부
    //            [cell.btn_Follow setBackgroundColor:[UIColor whiteColor]];
    //            cell.btn_Follow.selected = NO;
    //            [cell.btn_Follow removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    //            cell.btn_Follow.layer.borderColor = kMainColor.CGColor;
    //
    //            //회원추가시 수락여부 [A-수락, D-거부, N-회원 아님, Y-사용자 답변 대기중, C-관리자가 해제]
    //            NSString *str_MemberAllow = [dic objectForKey:@"isMemberAllow"];
    //            if( [str_MemberAllow isEqualToString:@"A"] )
    //            {
    //                [cell.btn_Follow setTitle:@"회원" forState:UIControlStateNormal];
    //                [cell.btn_Follow setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //                [cell.btn_Follow setBackgroundColor:kMainOrangeColor];  //이미지가 있는듯하다...
    //                cell.btn_Follow.layer.borderColor = kMainOrangeColor.CGColor;
    //
    ////                [cell.btn_Follow addTarget:self action:@selector(onMoveToFollower:) forControlEvents:UIControlEventTouchUpInside];
    //            }
    //            else if( [str_MemberAllow isEqualToString:@"D"] )
    //            {
    //                [cell.btn_Follow setTitle:@"팔로잉" forState:UIControlStateNormal];
    //                cell.btn_Follow.selected = YES;
    //                [cell.btn_Follow setBackgroundColor:kMainColor];
    //                [cell.btn_Follow addTarget:self action:@selector(onFollowing:) forControlEvents:UIControlEventTouchUpInside];
    //            }
    //            else if( [str_MemberAllow isEqualToString:@"Y"] )
    //            {
    //                [cell.btn_Follow setTitle:@"회원인증요청" forState:UIControlStateNormal];
    //                [cell.btn_Follow setTitleColor:kMainColor forState:UIControlStateNormal];
    //                [cell.btn_Follow setBackgroundColor:[UIColor whiteColor]];
    //                [cell.btn_Follow addTarget:self action:@selector(onShowNotiView:) forControlEvents:UIControlEventTouchUpInside];
    //            }
    //            else
    //            {
    //                BOOL isFollowing = [[dic objectForKey:@"isMyFollow"] boolValue];
    //                if( isFollowing )
    //                {
    //                    cell.btn_Follow.selected = YES;
    //                    [cell.btn_Follow setBackgroundColor:kMainColor];
    //                }
    //                else
    //                {
    //                    cell.btn_Follow.selected = NO;
    //                    [cell.btn_Follow setBackgroundColor:[UIColor whiteColor]];
    //                }
    //
    //                [cell.btn_Follow addTarget:self action:@selector(onFollowing:) forControlEvents:UIControlEventTouchUpInside];
    //            }
    //        }
    //
    //
    //        //채널명
    //        cell.lb_Title.text = [dic objectForKey_YM:@"channelName"];
    //
    //        //토탈 팔로잉 수 & 토탈문제수
    //        cell.lb_SubTitle.text = [NSString stringWithFormat:@"%ld명 %ld문제",
    //                                 [[dic objectForKey:@"channelFollowerCount"] integerValue],
    //                                 [[dic objectForKey:@"channelExamCount"] integerValue]];
    //
    ////        //팔로잉 여부
    ////        cell.btn_Status.tag = indexPath.row;
    ////        BOOL isFollow = [[dic objectForKey:@"isMyFollow"] boolValue];
    ////        if( isFollow )
    ////        {
    ////            cell.btn_Status.selected = YES;
    ////            cell.btn_Status.backgroundColor = kMainColor;
    ////        }
    ////        else
    ////        {
    ////            cell.btn_Status.selected = NO;
    ////            cell.btn_Status.backgroundColor = [UIColor whiteColor];
    ////        }
    ////
    ////        [cell.btn_Status addTarget:self action:@selector(onFollowing:) forControlEvents:UIControlEventTouchUpInside];
    //
    //        return cell;
    //    }
    //    else if( tableView == self.tbv_ReportList )
    //    {
    //        MyQuestionListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyQuestionListCell"];
    //        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    //
    //        cell.btn_Group.tag = cell.btn_Result.tag = indexPath.row;
    //
    //        NSDictionary *dic = self.ar_Report[indexPath.row];
    //
    //        //채널관리자가 왔을때 내 나와바리 여부에 따른 처리
    //        if( self.isManagerView )
    //        {
    //            //관리자가 들어 왔을시
    //            if( self.isPermission && [[dic objectForKey:@"isChannelAdmin"] isEqualToString:@"Y"] )
    //            {
    //                //권한이 있고, 이 채널의 어드민이면
    //                cell.v_Progess.alpha = cell.btn_Result.alpha = cell.btn_Group.alpha = YES;
    //            }
    //            else
    //            {
    //                cell.v_Progess.alpha = cell.btn_Result.alpha = cell.btn_Group.alpha = NO;
    //            }
    //        }
    //
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
    //        CGFloat fTotalCnt = [[dic objectForKey:@"questionCount"] floatValue];
    //        CGFloat fFinishCnt = [[dic objectForKey:@"solveQuestionCount"] floatValue];
    //
    //        CGFloat fFinishPer = fFinishCnt / fTotalCnt;
    //        cell.lc_ProgressWidth.constant = cell.lc_ProgressBgWidth.constant * fFinishPer;
    //
    //        //TODO: 남이 볼때 화면처리
    //
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
    //
    //        return cell;
    //    }
    //
    //    return nil;
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
    vc.str_UserIdx = self.str_UserIdx;
    vc.isPdf = [[dic objectForKey:@"examType"] isEqualToString:@"pdfExam"];
    vc.str_ChannelId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]];
    
    [self.navigationController pushViewController:vc animated:YES];
    
    //    if( tableView == self.tbv_QuestionList )
    //    {
    //        if( self.isManagerView )    return;
    //
    //        NSDictionary *dic = self.ar_Question[indexPath.row];
    //
    //        QuestionStartViewController  *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionStartViewController"];
    ////        vc.hidesBottomBarWhenPushed = YES;
    //        vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
    //        vc.str_StartIdx = @"0";
    //        vc.str_Title = [dic objectForKey:@"examTitle"];
    //        vc.str_UserIdx = self.str_UserIdx;
    //        vc.isPdf = [[dic objectForKey:@"examType"] isEqualToString:@"pdfExam"];
    //        vc.str_ChannelId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]];
    //
    //        [self.navigationController pushViewController:vc animated:YES];
    //
    ////        //문제풀기
    ////        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentQuestionIdx"];
    ////        [[NSUserDefaults standardUserDefaults] synchronize];
    ////
    ////        QuestionContainerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
    ////        vc.hidesBottomBarWhenPushed = YES;
    ////        vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
    ////        vc.str_StartIdx = @"0";
    ////
    ////        [self.navigationController pushViewController:vc animated:YES];
    //    }
    //    else if( tableView == self.tbv_QnAList )
    //    {
    //        NSDictionary *dic = self.ar_Qna[indexPath.row];
    //        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chatting" bundle:nil];
    //        ChattingViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChattingViewController"];
    //        vc.dic_Info = dic;
    //        vc.str_ChannelId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]];
    //        vc.str_RId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"rId"]];
    //        vc.isMyMode = YES;
    //        vc.i_User = self.iv_User.image;
    //        vc.hidesBottomBarWhenPushed = YES;
    //        [self.navigationController pushViewController:vc animated:YES];
    //    }
    //    else if( tableView == self.tbv_FollowingList )
    //    {
    //        NSDictionary *dic = self.ar_Following[indexPath.row];
    //        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Channel" bundle:nil];
    //        ChannelMainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChannelMainViewController"];
    //        vc.str_ChannelId = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"channelId"] integerValue]];
    //        vc.isShowNavi = YES;
    //        [self.navigationController pushViewController:vc animated:YES];
    ////        [self performSelector:@selector(onTest:) withObject:vc afterDelay:0.5f];
    //
    //    }
    //    else if( tableView == self.tbv_ReportList )
    //    {
    //        if( self.isManagerView )    return;
    //
    //        //문제풀기
    //        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentQuestionIdx"];
    //        [[NSUserDefaults standardUserDefaults] synchronize];
    //
    //        NSDictionary *dic = self.ar_Report[indexPath.row];
    //        BOOL isGroupYn = NO;
    //        NSInteger nGroupId = [[dic objectForKey:@"groupId"] integerValue];
    //        if( nGroupId > 0 )
    //        {
    //            isGroupYn = YES;
    //        }
    //
    //        //결과보기 버튼 유무
    //        NSInteger nFinishCount = [[dic objectForKey:@"isFinishCount"] integerValue];
    //        NSInteger nSolve = [[dic objectForKey:@"isSolve"] integerValue];
    //        BOOL isResultYn = NO;
    //        if( nFinishCount > 0 || nSolve == 1 )
    //        {
    //            //표시
    //            isResultYn = YES;
    //        }
    //
    //        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    //        ReportViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ReportViewController"];
    //        vc.str_ExamId = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
    //        vc.isGroupYn = isGroupYn;
    //        vc.isResultYn = isResultYn;
    //        vc.str_Title = [dic objectForKey:@"examTitle"];
    //        vc.str_UserIdx = self.str_UserIdx;
    //        [self.navigationController pushViewController:vc animated:YES];
    //
    ////        QuestionContainerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
    ////        vc.hidesBottomBarWhenPushed = YES;
    ////        vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
    ////        vc.str_StartIdx = @"0";
    ////
    ////        [self.navigationController pushViewController:vc animated:YES];
    //    }
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
    
    NSMutableArray *arM_Test = [NSMutableArray array];
    [arM_Test addObject:@{@"type":@"info", @"contents":[dic objectForKey:@"examTitle"]}];
    [arM_Test addObject:@{@"type":@"share", @"contents":@"공유"}];
    
    //단원보기 버튼 유무
    NSInteger nGroupId = [[dic objectForKey:@"groupId"] integerValue];
    if( nGroupId > 0 )
    {
        [arM_Test addObject:@{@"type":@"normal", @"contents":@"단원보기"}];
    }
    
    if( self.isAnotherUser == NO )
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
            vc.str_PUserId = self.str_UserIdx;
            [self presentViewController:vc animated:YES completion:^{
                
            }];
        }
    }];
    
    [self presentViewController:vc animated:YES completion:^{
        
    }];
    
}

- (void)onTest:(UIViewController *)vc
{
    vc.navigationController.navigationBarHidden = NO;
}
- (void)onInfo:(UIButton *)btn
{
    __block NSDictionary *dic = self.ar_Qna[btn.tag];
    
    NSMutableArray *arM = [NSMutableArray array];
    [arM addObject:@"삭제"];
    [arM addObject:@"참여자 보기"];
    
    [OHActionSheet showSheetInView:self.view
                             title:nil
                 cancelButtonTitle:@"취소"
            destructiveButtonTitle:nil
                 otherButtonTitles:arM
                        completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
     {
         if( buttonIndex == 0 )
         {
             //삭제
             UIAlertView *alert = CREATE_ALERT(nil, @"삭제하시겠습니까?", @"확인", @"취소");
             [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                 
                 if( buttonIndex == 0 )
                 {
                     NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                         [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                         [Util getUUID], @"uuid",
                                                         @"my", @"pageInfo",
                                                         @"hide", @"setMode",
                                                         //                                                         [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]], @"channelId",
                                                         [NSString stringWithFormat:@"%@", [dic objectForKey:@"rId"]], @"rId",
                                                         nil];
                     
                     __weak __typeof(&*self)weakSelf = self;
                     
                     [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/hide/my/qna/chat/room"
                                                         param:dicM_Params
                                                    withMethod:@"POST"
                                                     withBlock:^(id resulte, NSError *error) {
                                                         
                                                         [MBProgressHUD hide];
                                                         
                                                         if( resulte )
                                                         {
                                                             NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                             if( nCode == 200 )
                                                             {
                                                                 [self.ar_Qna removeObjectAtIndex:btn.tag];
                                                                 [self.tbv_QnAList reloadData];
                                                                 [self updateQnAList];
                                                                 //                                                                 NSInteger nGroupId = [[dic objectForKey:@"groupId"] integerValue];
                                                                 //                                                                 NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"rId":[NSString stringWithFormat:@"%@", [dic objectForKey:@"rId"]]}
                                                                 //                                                                                                                    options:NSJSONWritingPrettyPrinted
                                                                 //                                                                                                                      error:&error];
                                                                 //                                                                 NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                                 //
                                                                 //                                                                 [SendBird sendMessage:@"delete-room" withData:jsonString];
                                                             }
                                                             else
                                                             {
                                                                 [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                             }
                                                         }
                                                     }];
                 }
             }];
         }
         else if( buttonIndex == 1 )
         {
             //참여자 보기
             UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chatting" bundle:nil];
             InRoomMemberListViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"InRoomMemberListViewController"];
             vc.str_ChannelId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]];
             vc.str_QuestionId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]];
             [self.navigationController pushViewController:vc animated:YES];
         }
     }];
}

- (void)imageTap:(UIGestureRecognizer *)gesture
{
    UIView *view = (UIView *)gesture.view;
    NSDictionary *dic = self.ar_Qna[view.tag];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Channel" bundle:nil];
    ChannelMainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChannelMainViewController"];
    vc.str_ChannelId = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"channelId"] integerValue]];
    [self.navigationController pushViewController:vc animated:YES];
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
    
    NSInteger nGrade = [[dic objectForKey:@"personGrade"] integerValue];
    NSString *str_Grade = [NSString stringWithFormat:@"%@ %@학년", [dic objectForKey:@"schoolGrade"], nGrade == 0 ? @"전체" : [NSString stringWithFormat:@"%ld", nGrade]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    ReportDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ReportDetailViewController"];
    vc.str_Title = [NSString stringWithFormat:@"%@ %@ %@", [dic objectForKey:@"subjectName"], str_Grade, [dic objectForKey:@"publisherName"]];
    vc.str_ExamId = [dic objectForKey:@"examId"];
    vc.str_PUserId = self.str_UserIdx;
    //    vc.str_TesterUserId = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"testerId"]];
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}





#pragma mark - IBAction
- (IBAction)goProfile:(id)sender
{
    NSString *str_SchoolId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userSchoolId"];
    if( [str_SchoolId integerValue] > 0 )
    {
        //학생인 경우
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
        InputUserInfoViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"InputUserInfoViewController"];
        vc.isProfileMode = YES;
        [self presentViewController:vc animated:NO completion:^{
            
        }];
    }
    else
    {
        //학생이 아닌 경우
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
        InputUserInfoViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"InputUserInfoViewController"];
        vc.isProfileMode = YES;
        vc.isNotStudent = YES;
        [self presentViewController:vc animated:NO completion:^{
            
        }];
    }
}

- (IBAction)goMeneSelected:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if( btn == self.btn_ReportList )
    {
        ReportMainViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportMainViewController"];
        vc.str_ChannelId = self.str_ChannelId;
        vc.str_UserId = self.str_UserIdx;
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
    
    btn.selected = YES;
    
    if( sender == self.btn_QestionList )
    {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             
                             self.sv_Contents.contentOffset = CGPointZero;
                         }];
    }
    else if( sender == self.btn_QnAList )
    {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             
                             self.sv_Contents.contentOffset = CGPointMake(self.sv_Contents.bounds.size.width * 1, 0);
                         }];
    }
    else if( sender == self.btn_FollowingList )
    {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             
                             self.sv_Contents.contentOffset = CGPointMake(self.sv_Contents.bounds.size.width * 3, 0);
                         }];
    }
    else if( sender == self.btn_BookMarkList )
    {
        
    }
    else if( sender == self.btn_ReportList )
    {
        [UIView animateWithDuration:0.3f
                         animations:^{
                             
                             self.sv_Contents.contentOffset = CGPointMake(self.sv_Contents.bounds.size.width * 2, 0);
                         }];
    }
}

- (void)onFollowing:(UIButton *)btn
{
    if( self.isManagerView )    return;
    
    NSDictionary *dic = self.ar_Following[btn.tag];
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        //                                        [NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]], @"userId",
                                        [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"channelId"] integerValue]], @"channelId",
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
    if( self.isManagerView )    return;
    
    NSDictionary *dic = self.ar_Following[btn.tag];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"channelId"] integerValue]], @"channelId",
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

- (void)onShowNotiView:(UIButton *)btn
{
    NSDictionary *dic = self.ar_Following[btn.tag];
    [Common showDetailNoti:self withInfo:dic];
    
}

- (IBAction)goHashPage:(id)sender
{
    //schoolTag
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Channel" bundle:nil];
    PageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
    vc.str_ChannelHashTag = [self.dicM_Data objectForKey:@"channelHashTag"];
    vc.str_HashtagChannelId = [self.dicM_Data objectForKey:@"hashtagChannelId"];
    vc.str_ChannelType = [self.dicM_Data objectForKey:@"channelType"];
    vc.dic_Info = self.dicM_Data;
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goShowFollowingList:(id)sender
{
    UserListViewController *vc = [kEtcBoard instantiateViewControllerWithIdentifier:@"UserListViewController"];
    vc.userStatusCode = kFollowing;
    vc.str_UserId = self.str_UserIdx;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)goShowMemberList:(id)sender
{
    UserListViewController *vc = [kEtcBoard instantiateViewControllerWithIdentifier:@"UserListViewController"];
    vc.userStatusCode = kMember;
    vc.str_UserId = self.str_UserIdx;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onUploadTouch:(UIButton *)btn
{
    self.v_MyHeaderView.btn_Q1.selected = NO;
    self.v_MyHeaderView.btn_Q2.selected = NO;
    
    btn.selected = YES;
    
    questionType = kUpload;
    
    self.v_MyHeaderView.isFirst = YES;
    [self updateList];
}

- (void)onPaidTouch:(UIButton *)btn
{
    self.v_MyHeaderView.btn_Q1.selected = NO;
    self.v_MyHeaderView.btn_Q2.selected = NO;
    
    btn.selected = YES;
    
    questionType = kPaid;
    
    self.v_MyHeaderView.isFirst = YES;
    [self updateList];
}

- (void)leftBackSideMenuButtonPressed:(UIButton *)btn
{
    if( self.isModalMode )
    {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
