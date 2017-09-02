//
//  PageViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 12. 5..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "PageViewController.h"
#import "QuestionStartViewController.h"
#import "ChannelQuestionListCell.h"
#import "ChannelFollowingListCell.h"
#import "ChannelMainViewController.h"
#import "QuestionDetailViewController.h"
#import "UserPageMainViewController.h"
#import "MyMainViewController.h"

@interface PageViewController ()
{
//    NSString *str_ImagePrefix;
    NSString *str_UserImagePrefix;
    NSString *str_NoImagePrefix;
}
@property (nonatomic, strong) NSString *str_UserIdx;
@property (nonatomic, strong) NSMutableArray *arM_Tab1;
@property (nonatomic, strong) NSMutableArray *arM_Tab2;
@property (nonatomic, weak) IBOutlet UIButton *btn_Tab1;
@property (nonatomic, weak) IBOutlet UIButton *btn_Tab2;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Contents;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ContentsWidth;
@property (nonatomic, weak) IBOutlet UITableView *tbv_Tab1;
@property (nonatomic, weak) IBOutlet UITableView *tbv_Tab2;
@end

@implementation PageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self initNaviWithTitle:self.str_ChannelHashTag withLeftItem:[self leftBackBlackMenuBarButtonItem] withRightItem:nil withColor:[UIColor colorWithHexString:@"F8F8F8"]];

    self.navigationController.navigationBarHidden = NO;
    
    self.str_UserIdx = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];

    self.btn_Tab1.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.btn_Tab2.titleLabel.textAlignment = NSTextAlignmentCenter;

    NSString *str_ButtonTitle = [NSString stringWithFormat:@"%d\n%@", 0, @"문제들"];
    [self.btn_Tab1 setTitle:str_ButtonTitle forState:UIControlStateNormal];
    
    str_ButtonTitle = [NSString stringWithFormat:@"%d\n%@", 0, @"멤버"];
    [self.btn_Tab2 setTitle:str_ButtonTitle forState:UIControlStateNormal];

//    NSString *str_ButtonTitle = [NSString stringWithFormat:@"%ld\n%@", [[self.dicM_Data objectForKey:@"totalExamCount"] integerValue], @"문제들"];
//    [self.btn_Tab1 setTitle:str_ButtonTitle forState:UIControlStateNormal];
//    
//    str_ButtonTitle = [NSString stringWithFormat:@"%ld\n%@", [[self.dicM_Data objectForKey:@"qnaRoomCount"] integerValue], @"질문과답"];
//    [self.btn_Tab2 setTitle:str_ButtonTitle forState:UIControlStateNormal];

    [self updateList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    self.sv_Contents.contentSize = CGSizeMake(self.sv_Contents.frame.size.width * 2, self.sv_Contents.frame.size.height);
    self.lc_ContentsWidth.constant = self.sv_Contents.contentSize.width;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
//채널타입 구분
//#채널 등록 방법?
//#채널 테스트
- (void)updateList
{
    NSString *str_ChannelHashTag = self.str_ChannelHashTag;
    str_ChannelHashTag = [str_ChannelHashTag stringByReplacingOccurrencesOfString:@"#" withString:@""];

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_HashtagChannelId, @"channelId",
                                        self.str_ChannelType, @"channelType",
                                        str_ChannelHashTag, @"channelHashTag",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/hashtag/channel"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
                                            str_NoImagePrefix = [resulte objectForKey:@"no_image"];
                                            
                                            NSString *str_ButtonTitle = [NSString stringWithFormat:@"%@\n%@", [resulte objectForKey:@"hashTagExamCount"], @"문제들"];
                                            [self.btn_Tab1 setTitle:str_ButtonTitle forState:UIControlStateNormal];
                                            
                                            str_ButtonTitle = [NSString stringWithFormat:@"%@\n%@", [resulte objectForKey:@"hashTagUserCount"], @"멤버"];
                                            [self.btn_Tab2 setTitle:str_ButtonTitle forState:UIControlStateNormal];
                                        }
                                        
                                        [self updateTab1];
                                        [self updateTab2];
                                    }];
}

- (void)updateTab1
{
    NSString *str_ChannelHashTag = self.str_ChannelHashTag;
    str_ChannelHashTag = [str_ChannelHashTag stringByReplacingOccurrencesOfString:@"#" withString:@""];

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_HashtagChannelId, @"channelId",
                                        self.str_ChannelType, @"channelType",
                                        str_ChannelHashTag, @"channelHashTag",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/package/exam/browse"
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
                                                self.arM_Tab1 = [NSMutableArray arrayWithArray:[resulte objectForKey:@"examListInfos"]];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                            
                                            [self.tbv_Tab1 reloadData];
                                        }
                                    }];
}

- (void)updateTab2
{
    NSString *str_ChannelHashTag = self.str_ChannelHashTag;
    str_ChannelHashTag = [str_ChannelHashTag stringByReplacingOccurrencesOfString:@"#" withString:@""];

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_HashtagChannelId, @"channelId",
                                        self.str_ChannelType, @"channelType",
                                        str_ChannelHashTag, @"channelHashTag",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/hashtag/channel/member"
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
                                                self.arM_Tab2 = [NSMutableArray arrayWithArray:[resulte objectForKey:@"hashTagUserList"]];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                            
                                            [self.tbv_Tab2 reloadData];
                                        }
                                    }];
}


- (void)onSharedChange:(UISwitch *)sw
{
    NSDictionary *dic = self.arM_Tab1[sw.tag];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_HashtagChannelId, @"channelId",
                                        [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]], @"examId",
                                        sw.on ? @"C" : @"Y", @"setMode",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/exam/only/channel/open"
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
    [self showQuestion:btn.tag];
}

- (void)onPrice:(UIButton *)btn
{
    __block NSDictionary *dic = self.arM_Tab1[btn.tag];
    
    UIAlertView *alert = CREATE_ALERT(nil, @"문제를 구매하시겠습니까?", @"예", @"아니요");
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if( buttonIndex == 0 )
        {
            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                [Util getUUID], @"uuid",
                                                [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]], @"examId",
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
                                                        
//                                                        [self updateQuestionList];
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


#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( tableView == self.tbv_Tab1 )            return self.arM_Tab1.count;
    else if( tableView == self.tbv_Tab2 )            return self.arM_Tab2.count;
    
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( tableView == self.tbv_Tab1 )
    {
        ChannelQuestionListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelQuestionListCell"];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        cell.btn_Price.tag = cell.sw_Shared.tag = indexPath.row;
        
        NSDictionary *dic = self.arM_Tab1[indexPath.row];

        
        cell.iv_Thumb.backgroundColor = [UIColor colorWithHexString:[dic objectForKey_YM:@"codeHex"]];
        
        //문제집 제목
        cell.lb_QuestionTitle.text = [dic objectForKey:@"examTitle"];
        
        //제목
        cell.lb_Title.text = [dic objectForKey:@"subjectName"];
        
        //학교 학년
        NSInteger nGrade = [[dic objectForKey:@"personGrade"] integerValue];
        cell.lb_Grade.text = [NSString stringWithFormat:@"%@ %@학년", [dic objectForKey:@"schoolGrade"], nGrade == 0 ? @"전체" : [NSString stringWithFormat:@"%ld", nGrade]];
        
        //출판사
        cell.lb_Owner.text = [dic objectForKey:@"publisherName"];
        
        //공유 버튼들
        NSString *str_Shared = [dic objectForKey:@"OpenYn"];
        cell.sw_Shared.on = ![str_Shared isEqualToString:@"Y"];
        [cell.sw_Shared addTarget:self action:@selector(onSharedChange:) forControlEvents:UIControlEventValueChanged];
        
        [cell.btn_Price removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
        
        //구매버튼 관련
//        BOOL isPruchase = [[dic objectForKey:@"isPaid"] boolValue];
        if( [[dic objectForKey_YM:@"isPaid"] isEqualToString:@"paid"] )
        {
            //구매한 경우
            [cell.btn_Price setTitle:@"문제풀기" forState:UIControlStateNormal];
            [cell.btn_Price addTarget:self action:@selector(onShowMyPage:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            //구매하지 않은 경우
            //구매 버튼
            NSString *str_Purchers = @"";
            if( [[dic objectForKey:@"heartCount"] integerValue] == 0 )
            {
                //무료
                str_Purchers = @"무료";
            }
            else
            {
                //유료
                NSInteger nQuestionCount = [[dic objectForKey:@"questionCount"] integerValue];
                str_Purchers = [NSString stringWithFormat:@"$%f", nQuestionCount - 0.01];
            }
            
            [cell.btn_Price setTitle:str_Purchers forState:UIControlStateNormal];
            [cell.btn_Price addTarget:self action:@selector(onPrice:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        /*
         OpenYn = Y;
         changeDate = "2016-12-06 09:37:09";
         channelId = 4;
         channelName = "\Uc9c4\Uba85\Ud559\Uc6d0";
         channelUrl = edujm;
         clipCount = 2;
         codeHex = "#FF9800";
         coverBgColor = "bgm-orange";
         createDate = "2015-10-22 17:10:48";
         examId = 2;
         examSolveCount = 5;
         examTitle = "2013\Ub144 \Uc81c1\Ud68c \Uace01 \Uc601\Uc5b4\Ub4e3\Uae30\Ud3c9\Uac00";
         examType = normalExam;
         examUniqueUserCount = 5;
         examUserCount = 4;
         groupId = 0;
         groupName = "<null>";
         groupQuestionCount = 0;
         heartCount = 0;
         isClip = "-1";
         isFinishCount = 0;
         isSolve = 0;
         lectureId = 0;
         personGrade = 1;
         publisherId = 149;
         publisherName = "\Uc9c4\Uba85\Ud559\Uc6d0";
         questionCount = 20;
         schoolGrade = "\Uace0\Ub4f1\Ud559\Uad50";
         solveQuestionCount = 0;
         subjectName = "\Uc601\Uc5b4";
         teacherImg = "000/000/9ff8cffe6e1b3c7cac146ac0a958ba96_620.jpg";
         teacherName = "\Uc9c4\Uba85\Ud559\Uc6d0";
         teacherUrl = teacher10;
         */

        
        return cell;
    }
    else if( tableView == self.tbv_Tab2 )
    {
        ChannelFollowingListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelFollowingListCell"];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        NSDictionary *dic = self.arM_Tab2[indexPath.row];
        
        /*
         userAffiliation = "\Uc601\Ub3d9\Uace0\Ub4f1\Ud559\Uad50";
         userId = 138;
         userName = "\Uae40\Uc601\Ubbfc";
         userThumbNail = "000/000/f51df8be247438d5a6df1cf4ab5da74a.jpg";
         */

        //채널 이미지
        NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [dic objectForKey:@"userThumbNail"]];
        [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
        
        cell.lb_Name.text = [dic objectForKey:@"userName"];
        
        cell.lb_Grade.text = [dic objectForKey:@"userAffiliation"];
        
//        NSInteger nGrade = [[dic objectForKey:@"personGrade"] integerValue];
//        cell.lb_Grade.text = [NSString stringWithFormat:@"%@ %@학년", [dic objectForKey:@"schoolGrade"], nGrade == 0 ? @"전체" : [NSString stringWithFormat:@"%ld", nGrade]];

        /*
         userAffiliation = "\Uc601\Ub3d9\Uace0\Ub4f1\Ud559\Uad50";
         userId = 138;
         userName = "\Uae40\Uc601\Ubbfc";
         */

        return cell;
    }
    
    return nil;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if( tableView == self.tbv_Tab1 )
    {
        NSDictionary *dic = self.arM_Tab1[indexPath.row];
//        BOOL isPruchase = [[dic objectForKey:@"isPaid"] boolValue];
        if( [[dic objectForKey_YM:@"isPaid"] isEqualToString:@"paid"] )
        {
            //구매한 경우
            [self showQuestion:indexPath.row];
        }
        else
        {
            //구매하지 않은 경우
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            QuestionDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"QuestionDetailViewController"];
            vc.str_Idx = [NSString stringWithFormat:@"%@", [dic objectForKey:@"examId"]];
            vc.str_Title = [dic objectForKey:@"examTitle"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if( tableView == self.tbv_Tab2 )
    {
        NSDictionary *dic = self.arM_Tab2[indexPath.row];
        MyMainViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
        vc.isAnotherUser = YES;
        vc.str_UserIdx = [dic objectForKey:@"userId"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)showQuestion:(NSInteger)nIdx
{
    NSDictionary *dic = self.arM_Tab1[nIdx];
    
    QuestionStartViewController  *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionStartViewController"];
    //        vc.hidesBottomBarWhenPushed = YES;
    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
    vc.str_StartIdx = @"0";
    vc.str_Title = [dic objectForKey:@"examTitle"];
    vc.str_UserIdx = self.str_UserIdx;
    vc.isPdf = [[dic objectForKey:@"examType"] isEqualToString:@"pdfExam"];
    vc.str_ChannelId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]];
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goTab1:(id)sender
{
    if( self.btn_Tab1.selected == NO )
    {
        self.btn_Tab1.selected = YES;
        self.btn_Tab2.selected = NO;
        
        [UIView animateWithDuration:0.3f animations:^{
           
            self.sv_Contents.contentOffset = CGPointZero;
        }];
    }
}

- (IBAction)goTab2:(id)sender
{
    if( self.btn_Tab2.selected == NO )
    {
        self.btn_Tab1.selected = NO;
        self.btn_Tab2.selected = YES;
        
        
        [UIView animateWithDuration:0.3f animations:^{
            
            self.sv_Contents.contentOffset = CGPointMake(self.sv_Contents.frame.size.width, 0);
        }];
    }
}

@end
