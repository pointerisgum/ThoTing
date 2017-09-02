//
//  MainSideMenuViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 6. 2..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "MainSideMenuViewController.h"
#import "MainSideMenuCell.h"
#import "MainDefaultCheckCell.h"
#import "SharpChannelMainViewController.h"
#import "ChannelMainViewController.h"
#import "MyMainViewController.h"
#import "ReportMainViewController.h"
#import "UserListViewController.h"
#import "UserControllListViewController.h"
#import "ChannelReportViewController.h"

static CGFloat kReportFooterHeight = 20.f;

@interface MainSideMenuViewController ()
{
    NSInteger nMemberCount;
    NSString *str_UserImagePrefix;

    //나의 팔로잉 카운트
    NSInteger nMyFollowingCnt;

    //나의 팔로워 카운트
    NSInteger nMyFollowerCnt;
    
    NSInteger nChannelFollowingCnt;
    NSInteger nChannelMemberCnt;
    NSInteger nChannelAdminCnt;
    
}
@property (nonatomic, strong) NSString *str_ChannelId;
@property (nonatomic, strong) NSMutableDictionary *dicM_Data;
@property (nonatomic, strong) NSMutableArray *arM_DefaultList;
@property (nonatomic, strong) NSMutableArray *arM_TopList;
@property (nonatomic, strong) NSMutableArray *arM_BottomList;
@property (nonatomic, strong) NSDictionary *dic_ChannelInfo;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Main;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ContentsHeight;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UITableView *tbv_DefaultList;
@property (nonatomic, weak) IBOutlet UITableView *tbv_TopList;
@property (nonatomic, weak) IBOutlet UITableView *tbv_BottomList;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_DefaultTbvHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_TopTbvHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_BottomTbvHeight;
@property (nonatomic, weak) IBOutlet UIImageView *iv_TopArrow;
@property (nonatomic, weak) IBOutlet UIButton *btn_TopLeftX;
@property (nonatomic, weak) IBOutlet UIButton *btn_TopMenu;
@end

@implementation MainSideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    /*
     학생일때
     1. 내 자신
     2. 내가 속한 학교
     3. 내가 회원이거나 관리자인 채널
     */

    /*
     선생일때
     1. 내 자신
     2. 내가 속한 학원들
     */
    self.iv_TopArrow.hidden = YES;

    self.lc_DefaultTbvHeight.constant = 0.f;
    self.lc_TopTbvHeight.constant = 0.f;
    self.lc_BottomTbvHeight.constant = 0.f;
    
    if( self.isChannelMode )
    {
        self.btn_TopLeftX.hidden = NO;
    }
    else
    {
        self.btn_TopLeftX.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
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
                                                NSArray *ar = [NSArray arrayWithArray:[resulte objectForKey:@"channelInfos"]];
                                                if( ar && ar.count > 0 )
                                                {
                                                    [[NSUserDefaults standardUserDefaults] setObject:@"Y" forKey:@"isTeacher"];
                                                }
                                                else
                                                {
                                                    [[NSUserDefaults standardUserDefaults] setObject:@"N" forKey:@"isTeacher"];
                                                }
                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                            }
                                        }
                                        
                                        [self updateList];
//                                        [self updateCount];
                                    }];

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    NSString *str_Path = [NSString stringWithFormat:@"%@/api/v1/get/my/manage/channel/list", kBaseUrl];
//    [[WebAPI sharedData] cancelMethod:@"GET" withPath:str_Path];
}

- (void)viewDidLayoutSubviews
{
    self.sv_Main.contentSize = CGSizeMake(self.sv_Main.contentSize.width,
                                          self.lc_DefaultTbvHeight.constant + self.lc_TopTbvHeight.constant + self.lc_BottomTbvHeight.constant + 10);

    self.lc_ContentsHeight.constant = self.sv_Main.contentSize.height;
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


//- (void)updateCount
//{
//    //v1/get/my/side/tab/info
//    
//    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                                        [Util getUUID], @"uuid",
//                                        nil];
//    
//    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/side/tab/info"
//                                        param:dicM_Params
//                                   withMethod:@"GET"
//                                    withBlock:^(id resulte, NSError *error) {
//                                        
//                                        [MBProgressHUD hide];
//                                        
//                                        if( resulte )
//                                        {
//                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
//                                            if( nCode == 200 )
//                                            {
//                                                nFollowingCnt = [[resulte objectForKey_YM:@"followChannelCount"] integerValue];
//                                                nFollowerCnt = [[resulte objectForKey_YM:@"followerCount"] integerValue];
//                                                nMemberCnt = [[resulte objectForKey_YM:@"memberChannelCount"] integerValue];
//                                                nAdminCnt = [[resulte objectForKey_YM:@"managerChannelCount"] integerValue];
//                                                
//                                                [self.tbv_BottomList reloadData];
//                                            }
//                                        }
//                                    }];
//}

- (void)updateIcon
{
    NSString *str_IsTeacher = [[NSUserDefaults standardUserDefaults] objectForKey:@"isTeacher"];
    if( [str_IsTeacher isEqualToString:@"Y"] )
    {
        NSString *str_Name = @"";
        NSString *str_Key = [NSString stringWithFormat:@"DefaultChannel_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
        NSString *str_DefaultChannel = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
        if( str_DefaultChannel == nil || str_DefaultChannel.length <= 0 )
        {
            str_Name = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
        }
        else
        {
            str_Name = str_DefaultChannel;
        }
        
        if( [str_Name isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]] )
        {
            NSString *str_UserPic = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPic"];
            [self setIcon:str_UserPic];
//            [self.iv_Icon sd_setImageWithURL:[NSURL URLWithString:str_UserPic] placeholderImage:BundleImage(@"no_image.png")];
        }
        else
        {
            NSString *str_IconUrl = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_Pic", str_Key]];
            [self setIcon:str_IconUrl];

//            [self.iv_Icon sd_setImageWithURL:[NSURL URLWithString:str_IconUrl] placeholderImage:BundleImage(@"no_image.png")];
        }
    }
    else
    {
        UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:kTabBarMyIdx];
        item.image = BundleImage(@"tab03_n.png");
        item.selectedImage = BundleImage(@"tab03_p.png");
    }
}

- (void)setIcon:(NSString *)aUrl
{
    NSURL *url = [NSURL URLWithString:aUrl];
    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    
    
    NSURLRequest *theRequest=[NSURLRequest requestWithURL:url
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                          timeoutInterval:60.0];
    
    [iv setImageWithURLRequest:theRequest placeholderImage:nil usingCache:NO success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        
        CGSize size = CGSizeMake(25, 25);
        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        UIGraphicsBeginImageContextWithOptions(newImage.size, NO, [UIScreen mainScreen].scale);
        [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, newImage.size.width, newImage.size.height)
                                    cornerRadius:size.width/2] addClip];
        [newImage drawInRect:CGRectMake(0, 0, newImage.size.width, newImage.size.height)];
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        /*************하단 구조 바뀌며 주석처리함 20170607*************/
        UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:kTabBarMyIdx];
        item.image = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        item.selectedImage = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
        
    }];
}

- (void)updateList
{
    if( self.isChannelMode )
    {
        NSString *str_ChannelName = @"";
        NSArray *ar_ExamInfos = [self.dic_ChannelData objectForKey:@"examInfos"];
        if( ar_ExamInfos.count > 0 )
        {
            NSDictionary *dic = [ar_ExamInfos firstObject];
            str_ChannelName = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelName"]];
        }

        self.lb_Title.text = str_ChannelName;
    }
    else
    {
        NSString *str_IsTeacher = [[NSUserDefaults standardUserDefaults] objectForKey:@"isTeacher"];
        if( [str_IsTeacher isEqualToString:@"Y"] )
        {
            NSString *str_Key = [NSString stringWithFormat:@"DefaultChannel_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
            NSString *str_DefaultChannel = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
            if( str_DefaultChannel == nil || str_DefaultChannel.length <= 0 )
            {
                self.lb_Title.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
                
                [[NSUserDefaults standardUserDefaults] setObject:self.lb_Title.text forKey:str_Key];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else
            {
                self.lb_Title.text = str_DefaultChannel;
            }
        }
        else
        {
            self.lb_Title.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
        }
    }
 
    __block BOOL isMyMode = NO;
    if( [self.lb_Title.text isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]] )
    {
        isMyMode = YES;
    }
    
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
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
                                                
                                                //나의 팔로잉 수
                                                nMyFollowingCnt = [[resulte objectForKey:@"followChannelCount"] integerValue];
                                                
                                                //나의 팔로워 수
                                                nMyFollowerCnt = [[resulte objectForKey:@"memberChannelCount"] integerValue];

                                                
                                                self.dicM_Data = [NSMutableDictionary dictionaryWithDictionary:resulte];
                                                
                                                self.arM_TopList = [NSMutableArray array];
                                                self.arM_BottomList = [NSMutableArray array];
                                                self.arM_DefaultList = [NSMutableArray array];
                                                
                                                [self.arM_DefaultList addObject:@{@"type":@"user"}];
                                                
                                                nMemberCount = 0;
                                                
                                                NSArray *ar_MemberListTmp = [NSArray arrayWithArray:[resulte objectForKey:@"memberChannelInfos"]];
                                                if( ar_MemberListTmp.count > 0 )
                                                {
                                                    for( NSInteger i = 0; i < ar_MemberListTmp.count; i++ )
                                                    {
                                                        NSDictionary *dic = ar_MemberListTmp[i];
                                                        NSInteger nMemberLevel = [[dic objectForKey:@"memberLevel"] integerValue];
                                                        //memberLevel: 사용자 레벨 [1~9: 관리자, 10~99: 일반회원]
                                                        if( [[dic objectForKey:@"statusCode"] isEqualToString:@"T"] && (nMemberLevel >= 1 && nMemberLevel <= 9) )
                                                        {
                                                            [self.arM_DefaultList addObject:dic];
                                                        }
                                                        else if( [[dic objectForKey:@"statusCode"] isEqualToString:@"M"] )
                                                        {
                                                            nMemberCount++;
                                                            [self.arM_BottomList addObject:dic];
                                                        }
                                                    }
                                                }

                                                if( isMyMode )
                                                {
                                                    //나
                                                    //학교
                                                    //나의 팔로워 팔로잉
                                                    //나의 레포트
                                                    //설정
                                                    //페이지 만들기
                                                    //토팅 소개
                                                    //로그아웃
                                                    
                                                    [self.arM_TopList addObject:@{@"type":@"user"}];
                                                    [self.arM_TopList addObject:@{@"type":@"school"}];
                                                    
                                                    [self.arM_BottomList insertObject:@"레포트" atIndex:0];
//                                                    [self.arM_BottomList addObject:@"레포트"];
                                                    
                                                    [self.arM_BottomList addObject:@"팔로잉"];
                                                    [self.arM_BottomList addObject:@"설정"];
                                                    [self.arM_BottomList addObject:@"페이지 만들기"];
                                                    [self.arM_BottomList addObject:@"토팅 소개"];
                                                    [self.arM_BottomList addObject:@"로그아웃"];

                                                }
                                                else
                                                {
                                                    for( NSInteger i = 0; i < self.arM_DefaultList.count; i++ )
                                                    {
                                                        NSDictionary *dic = self.arM_DefaultList[i];
                                                        if( [self.lb_Title.text isEqualToString:[dic objectForKey:@"channelName"]] )
                                                        {
                                                            [self updateChannelInfo:[NSString stringWithFormat:@"%@",[dic objectForKey:@"channelId"]]];
                                                            
                                                            [self.arM_TopList addObject:dic];
                                                            break;
                                                        }
                                                    }

                                                    //회원으로 등록된 채널을 지워주기
                                                    [self.arM_BottomList removeAllObjects];
                                                    
                                                    [self.arM_BottomList addObject:@"레포트"];

                                                    [self.arM_BottomList addObject:@"회원"];
                                                    [self.arM_BottomList addObject:@"팔로워"];
                                                    [self.arM_BottomList addObject:@"관리자 관리"];
                                                    [self.arM_BottomList addObject:@"설정"];
//                                                    [self.arM_BottomList addObject:@"페이지 만들기"]; //페이지를 이미 만들었다면 없애줘야 하는데..
                                                    [self.arM_BottomList addObject:@"토팅 소개"];
                                                    [self.arM_BottomList addObject:@"로그아웃"];
                                                }
                                                
                                                
                                                
                                                
                                                
                                                
                                                
                                                
//                                                //학생과 선생 구분
//                                                if( [str_IsTeacher isEqualToString:@"Y"] )
//                                                    //                                                if( 1 )
//                                                {
//                                                    //선생 또는 관리자
//                                                    self.arM_DefaultList = [NSMutableArray array];
//                                                    [self.arM_DefaultList addObject:@{@"type":@"user"}];
//                                                    [self.arM_DefaultList addObjectsFromArray:ar_MemberListTmp];
//                                                    
////                                                    self.lc_DefaultTbvHeight.constant = self.arM_DefaultList.count * 50.f;
//                                                    
//                                                    [self.tbv_DefaultList reloadData];
//                                                    
//                                                    [self.arM_TopList addObject:@{@"type":@"user"}];
//                                                    
//                                                    self.arM_BottomList = [NSMutableArray array];
//                                                    [self.arM_BottomList addObject:@"회원"];
//                                                    [self.arM_BottomList addObject:@"팔로잉"];
//                                                    //                                                    [self.arM_BottomList addObject:@"공유문제"];
//                                                    //                                                    [self.arM_BottomList addObject:@"올린문제"];
//                                                    [self.arM_BottomList addObject:@"레포트"];
//                                                    [self.arM_BottomList addObject:@"관리자 관리"];
//                                                    [self.arM_BottomList addObject:@"설정"];
//                                                    [self.arM_BottomList addObject:@"페이지 만들기"]; //페이지를 이미 만들었다면 없애줘야 하는데..
//                                                    [self.arM_BottomList addObject:@"토팅 소개"];
//                                                    
//                                                }
//                                                else
//                                                {
//                                                    //학생
//                                                    [self.arM_TopList addObject:@{@"type":@"user"}];
//                                                    [self.arM_TopList addObject:@{@"type":@"school"}];
//                                                    
//                                                    self.arM_BottomList = [NSMutableArray array];
//                                                    [self.arM_BottomList addObject:@"팔로잉"];
//                                                    [self.arM_BottomList addObject:@"레포트"];
//                                                    [self.arM_BottomList addObject:@"설정"];
//                                                    [self.arM_BottomList addObject:@"페이지 만들기"];
//                                                    [self.arM_BottomList addObject:@"토팅 소개"];
//                                                }
//                                                
//                                                [self.arM_TopList addObjectsFromArray:ar_MemberListTmp];
                                                
                                                self.lc_TopTbvHeight.constant = (self.arM_TopList.count * 50.f) + 20.f;
                                                self.lc_BottomTbvHeight.constant = (self.arM_BottomList.count * 60.f) + kReportFooterHeight;
                                                
                                                [self.tbv_DefaultList reloadData];
                                                [self.tbv_TopList reloadData];
                                                [self.tbv_BottomList reloadData];
                                                
                                                [self.view setNeedsLayout];
                                                
                                                if( self.arM_DefaultList.count < 2 )
                                                {
                                                    self.iv_TopArrow.hidden = YES;
                                                }
                                                else
                                                {
                                                    if( self.isChannelMode == NO )
                                                    {
                                                        self.iv_TopArrow.hidden = NO;
                                                    }
                                                }
                                            }
                                        }
                                    }];
}

- (void)updateChannelInfo:(NSString *)aChannelId
{
    self.str_ChannelId = aChannelId;

    NSString *str_Key2 = [NSString stringWithFormat:@"DefaultChannelId_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    [[NSUserDefaults standardUserDefaults] setObject:self.str_ChannelId forKey:str_Key2];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    __weak __typeof__(self) weakSelf = self;

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        aChannelId, @"channelId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/my"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            weakSelf.dic_ChannelInfo = [NSDictionary dictionaryWithDictionary:resulte];
                                            nChannelFollowingCnt = [[resulte objectForKey:@"channelFollowerCount"] integerValue];
                                            nChannelMemberCnt = [[resulte objectForKey:@"channelMemberCount"] integerValue];
                                            nChannelAdminCnt = [[resulte objectForKey:@"channelManagerCount"] integerValue];
                                            [weakSelf.tbv_BottomList reloadData];
                                        }
                                    }];
}


#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if( tableView == self.tbv_BottomList )
    {
        return self.arM_BottomList.count;
    }
    
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( tableView == self.tbv_DefaultList )
    {
        return self.arM_DefaultList.count;
    }
    else if( tableView == self.tbv_TopList )
    {
        return self.arM_TopList.count;
    }
    
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( tableView == self.tbv_DefaultList )
    {
        static NSString *CellIdentifier = @"MainDefaultCheckCell";
        MainDefaultCheckCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        NSDictionary *dic = self.arM_DefaultList[indexPath.row];
        
        cell.btn_Title.selected = NO;

        if( [[dic objectForKey_YM:@"type"] isEqualToString:@"user"] )
        {
            [cell.btn_Title setTitle:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] forState:0];
        }
        else
        {
            NSString *str_ChannelName = [NSString stringWithFormat:@"%@(%@)",
                                         [dic objectForKey_YM:@"channelName"], [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]];
            [cell.btn_Title setTitle:str_ChannelName forState:0];
        }
        
        NSString *str_Key = [NSString stringWithFormat:@"DefaultChannel_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
        NSString *str_DefaultChannel = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
        if( [str_DefaultChannel isEqualToString:cell.btn_Title.titleLabel.text] || [str_DefaultChannel isEqualToString:[dic objectForKey_YM:@"channelName"]] )
        {
            self.lb_Title.text = str_DefaultChannel;
            cell.btn_Title.selected = YES;
        }
        
        return cell;
    }
    else if( tableView == self.tbv_TopList )
    {
        static NSString *CellIdentifier = @"MainSideMenuCell";
        MainSideMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if( indexPath.row == 0 )
        {
            cell.iv_TopLine.hidden = NO;
        }
        else
        {
            cell.iv_TopLine.hidden = YES;
        }
        
        cell.iv_Icon.layer.cornerRadius = 0.f;
        cell.iv_Icon.layer.borderColor = [UIColor clearColor].CGColor;
        cell.iv_Icon.layer.borderWidth = 0.f;

        //상단 테이블 뷰
        NSDictionary *dic = self.arM_TopList[indexPath.row];
        
        if( [[dic objectForKey_YM:@"type"] isEqualToString:@"user"] )
        {
            NSString *str_UserPic = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPic"];
            NSURL *url = [Util createImageUrl:str_UserImagePrefix withFooter:str_UserPic];
            [cell.iv_Icon sd_setImageWithURL:url placeholderImage:BundleImage(@"no_image.png")];
            cell.lb_Title.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
            
            cell.iv_Icon.layer.cornerRadius = cell.iv_Icon.frame.size.width / 2;
            cell.iv_Icon.layer.borderColor = [UIColor colorWithRed:180.f/255.f green:180.f/255.f blue:180.f/255.f alpha:1].CGColor;
            cell.iv_Icon.layer.borderWidth = 1.0f;
        }
        else if( [[dic objectForKey_YM:@"type"] isEqualToString:@"school"] )
        {
            cell.iv_Icon.image = BundleImage(@"sharp_channel.png");
            cell.lb_Title.text = [self.dicM_Data objectForKey_YM:@"channelHashTag"];
        }
        else
        {
            /*
             channelExamCount = 66;
             channelId = 4;
             channelImgUrl = "000/000/edujmLogo.png";
             channelMemberCount = 20;
             channelName = "\Uc9c4\Uba85\Ud559\Uc6d0";
             channelStatus = active;
             channelUrl = edujm;
             createDate = "2016-07-21 00:00:00";
             imgUrl = "000/000/f51df8be247438d5a6df1cf4ab5da74a.jpg";
             isMemberAllow = A;
             isMyFollow = 1;
             memberLevel = 9;
             nId = 13159;
             statusCode = T;
             userId = 138;
             */
            
            /*
             memberLevel: 사용자 레벨 [1~9: 관리자, 10~99: 일반회원]
             statusCode: 사용자 구분 [F-follower, M-회원, T-관리자]
             */
            
            NSString *str_ImageUrl = [dic objectForKey_YM:@"channelImgUrl"];
            NSURL *url = [Util createImageUrl:str_UserImagePrefix withFooter:str_ImageUrl];
            [cell.iv_Icon sd_setImageWithURL:url placeholderImage:BundleImage(@"no_image.png")];

            cell.iv_Icon.layer.cornerRadius = cell.iv_Icon.frame.size.width / 2;
            cell.iv_Icon.layer.borderColor = [UIColor colorWithRed:180.f/255.f green:180.f/255.f blue:180.f/255.f alpha:1].CGColor;
            cell.iv_Icon.layer.borderWidth = 1.0f;

            NSInteger nMemberLevel = [[dic objectForKey_YM:@"memberLevel"] integerValue];
            NSString *str_MemberCode = [dic objectForKey_YM:@"statusCode"];
            if( nMemberLevel >= 1 && nMemberLevel <= 99 )
            {
//                memberLevel: 사용자 레벨 [1~9: 관리자, 10~99: 일반회원]
                
                NSString *str_Tail = @"";
                if( [str_MemberCode isEqualToString:@"T"] )
                {
                    //관리자
                    str_Tail = @"관리자";
                }
                else if( [str_MemberCode isEqualToString:@"M"] )
                {
                    //회원
                    str_Tail = @"회원";
                }

                
                
                NSString *str_Header = [dic objectForKey_YM:@"channelName"];
                NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:
                                                   [NSString stringWithFormat:@"%@(%@)", str_Header, str_Tail]];
                [text addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:15.0f],
                                      NSForegroundColorAttributeName : [UIColor blackColor]}
                              range:NSMakeRange(str_Header.length, 1)];
                
                [text addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:15.0f],
                                      NSForegroundColorAttributeName : kMainRedColor}
                              range:NSMakeRange(str_Header.length + 1, str_Tail.length)];

                [text addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:15.0f],
                                      NSForegroundColorAttributeName : [UIColor blackColor]}
                              range:NSMakeRange(str_Header.length + str_Tail.length + 1, 1)];

                cell.lb_Title.attributedText = text;
            }
            else
            {
                cell.lb_Title.text = [dic objectForKey_YM:@"channelName"];
            }
            
        }
        
        if( indexPath.row == self.arM_TopList.count - 1 )
        {
            cell.lc_BottomLineX.constant = 0.f;
        }
        else
        {
            cell.lc_BottomLineX.constant = 54.f;
        }
        
        return cell;
    }
    
    static NSString *CellIdentifier = @"MainSideMenuCell";
    MainSideMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    cell.iv_Icon.layer.cornerRadius = 0.f;
    cell.iv_Icon.layer.borderColor = [UIColor clearColor].CGColor;
    cell.iv_Icon.layer.borderWidth = 0.f;

//    if( indexPath.row == 0 )
//    {
//        cell.iv_TopLine.hidden = NO;
//    }
//    else
//    {
//        cell.iv_TopLine.hidden = YES;
//    }
    
    cell.iv_TopLine.hidden = NO;
    cell.iv_BottomLine.hidden = YES;
    
    //하단 테이블 뷰
    id obj = self.arM_BottomList[indexPath.section];
    if( [obj isKindOfClass:[NSString class]] )
    {
        NSString *str_Title = self.arM_BottomList[indexPath.section];
        cell.lb_Title.text = str_Title;
        
        if( [str_Title rangeOfString:@"회원"].location != NSNotFound )
        {
            cell.iv_Icon.image = BundleImage(@"user_single_icon.png");
            cell.lb_Title.text = [NSString stringWithFormat:@"%@ %ld", str_Title, nChannelMemberCnt];
        }
        else if( [str_Title rangeOfString:@"팔로워"].location != NSNotFound )
        {
            //채널일 경우
            cell.iv_Icon.image = BundleImage(@"follower_icon.png");
            cell.lb_Title.text = [NSString stringWithFormat:@"팔로워 %ld", nChannelFollowingCnt];
        }
        else if( [str_Title rangeOfString:@"팔로잉"].location != NSNotFound )
        {
            //마이일 경우
            cell.iv_Icon.image = BundleImage(@"follower_icon.png");
            //팔로워 23  팔로잉 77
            cell.lb_Title.text = [NSString stringWithFormat:@"팔로워 %ld  팔로잉 %ld", nMyFollowerCnt, nMyFollowingCnt];
            //        cell.lb_Title.text = [NSString stringWithFormat:@"%@ %ld", str_Title, nFollowCnt];
            cell.iv_BottomLine.hidden = NO;
        }
        else if( [str_Title rangeOfString:@"공유"].location != NSNotFound )
        {
            cell.iv_Icon.image = BundleImage(@"share_icon.png");
        }
        else if( [str_Title rangeOfString:@"올린"].location != NSNotFound )
        {
            cell.iv_Icon.image = BundleImage(@"upload_icon.png");
        }
        else if( [str_Title rangeOfString:@"레포트"].location != NSNotFound )
        {
            cell.iv_Icon.image = BundleImage(@"report_icon.png");
            cell.iv_BottomLine.hidden = NO;
        }
        else if( [str_Title rangeOfString:@"관리자"].location != NSNotFound )
        {
            cell.iv_Icon.image = BundleImage(@"admin_icon.png");
            cell.lb_Title.text = [NSString stringWithFormat:@"%@ %ld", str_Title, nChannelAdminCnt];
            cell.iv_BottomLine.hidden = NO;
        }
        else if( [str_Title rangeOfString:@"설정"].location != NSNotFound )
        {
            cell.iv_Icon.image = BundleImage(@"setting_icon.png");
        }
        else if( [str_Title rangeOfString:@"페이지"].location != NSNotFound )
        {
            cell.iv_Icon.image = BundleImage(@"plus_icon.png");
        }
        else if( [str_Title rangeOfString:@"토팅 소개"].location != NSNotFound )
        {
            cell.iv_Icon.image = BundleImage(@"thoth00.png");
        }
        else if( [str_Title rangeOfString:@"로그아웃"].location != NSNotFound )
        {
            cell.iv_Icon.image = BundleImage(@"logout_icon.png");
            cell.iv_BottomLine.hidden = NO;
        }
    }
    else
    {
        NSDictionary *dic = [NSDictionary dictionaryWithDictionary:obj];

        if( indexPath.section == 1 )
        {
            cell.iv_TopLine.hidden = NO;
        }
        else
        {
            cell.iv_TopLine.hidden = YES;
        }
        
        cell.iv_BottomLine.hidden = NO;
        
        NSString *str_ImageUrl = [dic objectForKey_YM:@"channelImgUrl"];
        NSURL *url = [Util createImageUrl:str_UserImagePrefix withFooter:str_ImageUrl];
        [cell.iv_Icon sd_setImageWithURL:url placeholderImage:BundleImage(@"no_image.png")];
        
        cell.iv_Icon.layer.cornerRadius = cell.iv_Icon.frame.size.width / 2;
        cell.iv_Icon.layer.borderColor = [UIColor colorWithRed:180.f/255.f green:180.f/255.f blue:180.f/255.f alpha:1].CGColor;
        cell.iv_Icon.layer.borderWidth = 1.0f;

        NSString *str_Tail = @"회원";
        NSString *str_Header = [dic objectForKey_YM:@"channelName"];
        NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:
                                           [NSString stringWithFormat:@"%@(%@)", str_Header, str_Tail]];
        [text addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:15.0f],
                              NSForegroundColorAttributeName : [UIColor blackColor]}
                      range:NSMakeRange(str_Header.length, 1)];
        
        [text addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:15.0f],
                              NSForegroundColorAttributeName : kMainRedColor}
                      range:NSMakeRange(str_Header.length + 1, str_Tail.length)];
        
        [text addAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"Helvetica" size:15.0f],
                              NSForegroundColorAttributeName : [UIColor blackColor]}
                      range:NSMakeRange(str_Header.length + str_Tail.length + 1, 1)];
        
        cell.lb_Title.attributedText = text;

        if( self.arM_BottomList.count >= indexPath.section + 1 )
        {
            id obj = self.arM_BottomList[indexPath.section + 1];
            if( [obj isKindOfClass:[NSDictionary class]] )
            {
                //다음께 회원이면
                cell.lc_BottomLineX.constant = 54.f;
                cell.iv_BottomLine.hidden = NO;
            }
            else
            {
                cell.lc_BottomLineX.constant = 0.f;
                cell.iv_BottomLine.hidden = NO;
            }
        }
    }

    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if( tableView == self.tbv_DefaultList )
    {
        if( self.isChannelMode )
        {
            return;
        }

        NSString *str_IsTeacher = [[NSUserDefaults standardUserDefaults] objectForKey:@"isTeacher"];
        if( [str_IsTeacher isEqualToString:@"Y"] )
        {
            NSString *str_Key = [NSString stringWithFormat:@"DefaultChannel_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
            
            NSDictionary *dic = self.arM_DefaultList[indexPath.row];
            
            if( [[dic objectForKey_YM:@"type"] isEqualToString:@"user"] )
            {
                NSString *str_Key2 = [NSString stringWithFormat:@"DefaultChannelId_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:str_Key2];
                [[NSUserDefaults standardUserDefaults] setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] forKey:str_Key];
                self.str_ChannelId = @"";
            }
            else
            {
                [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey_YM:@"channelName"] forKey:str_Key];
                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [dic objectForKey_YM:@"channelImgUrl"]]
                                                          forKey:[NSString stringWithFormat:@"%@_Pic", str_Key]];
            }
            
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            [self updateIcon];
            [self.tbv_DefaultList reloadData];
            
            [self updateList];
            [self goTopArrow:nil];
        }
    }
    else if( tableView == self.tbv_TopList )
    {
        //채널로 이동
        
        NSDictionary *dic = self.arM_TopList[indexPath.row];
        
        if( [[dic objectForKey_YM:@"type"] isEqualToString:@"user"] )
        {
            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            MyMainViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
//            vc.hidesBottomBarWhenPushed = YES;
            vc.isShowNavi = YES;
            vc.isManagerView = YES;
            vc.isPermission = YES;
            vc.str_UserIdx = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if( [[dic objectForKey_YM:@"type"] isEqualToString:@"school"] )
        {
            //학교로 이동
            SharpChannelMainViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"SharpChannelMainViewController"];
//            vc.hidesBottomBarWhenPushed = YES;
            vc.isShowNavi = NO;
            vc.dic_Info = self.dicM_Data;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            //채널로 이동
            ChannelMainViewController *vc = [kChannelBoard instantiateViewControllerWithIdentifier:@"ChannelMainViewController"];
//            vc.hidesBottomBarWhenPushed = YES;
            vc.isShowNavi = YES;
            vc.str_ChannelId = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"channelId"] integerValue]];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if( tableView == self.tbv_BottomList )
    {
        id obj = self.arM_BottomList[indexPath.section];
        if( [obj isKindOfClass:[NSString class]] )
        {
            NSString *str_Title = self.arM_BottomList[indexPath.section];
            if( [str_Title rangeOfString:@"회원"].location != NSNotFound )
            {
                UserControllListViewController *vc = [kEtcBoard instantiateViewControllerWithIdentifier:@"UserControllListViewController"];
                vc.isMannager = YES;
                vc.str_ChannelId = self.str_ChannelId;
                vc.isChannel = YES;
                vc.str_Mode = @"member";
                [self.navigationController pushViewController:vc animated:YES];
            }
            else if( [str_Title rangeOfString:@"팔로워"].location != NSNotFound )
            {
                UserControllListViewController *vc = [kEtcBoard instantiateViewControllerWithIdentifier:@"UserControllListViewController"];
                vc.isMannager = YES;
                vc.str_ChannelId = self.str_ChannelId;
                vc.str_Mode = @"follower";
                [self.navigationController pushViewController:vc animated:YES];
            }
            else if( [str_Title rangeOfString:@"팔로잉"].location != NSNotFound )
            {
                UserListViewController *vc = [kEtcBoard instantiateViewControllerWithIdentifier:@"UserListViewController"];
                vc.userStatusCode = kFollowing;
                vc.str_UserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
                [self.navigationController pushViewController:vc animated:YES];
            }
            //    else if( [str_Title rangeOfString:@"공유"].location != NSNotFound )
            //    {
            //
            //    }
            //    else if( [str_Title rangeOfString:@"올린"].location != NSNotFound )
            //    {
            //
            //    }
            else if( [str_Title rangeOfString:@"레포트"].location != NSNotFound )
            {
                NSString *str_Key = [NSString stringWithFormat:@"DefaultChannel_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
                NSString *str_DefaultChannel = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
                if( [str_DefaultChannel isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]] )
                {
                    //유저
                    ReportMainViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportMainViewController"];
                    vc.str_UserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                else if( str_DefaultChannel == nil || str_DefaultChannel.length <= 0 )
                {
                    //유저
                    ReportMainViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportMainViewController"];
                    vc.str_UserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                else
                {
                    //채널
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Channel" bundle:nil];
                    ChannelReportViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChannelReportViewController"];
                    vc.str_ChannelId = self.str_ChannelId;
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }
            else if( [str_Title rangeOfString:@"관리자"].location != NSNotFound )
            {
                UserControllListViewController *vc = [kEtcBoard instantiateViewControllerWithIdentifier:@"UserControllListViewController"];
                vc.isMannager = YES;
                vc.str_ChannelId = self.str_ChannelId;
                vc.str_Mode = @"manager";
                [self.navigationController pushViewController:vc animated:YES];
            }
            else if( [str_Title rangeOfString:@"설정"].location != NSNotFound )
            {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Setting" bundle:nil];
                UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"OptionViewController"];
                //            vc.hidesBottomBarWhenPushed = YES;
                [self.navigationController pushViewController:vc animated:YES];
            }
            else if( [str_Title rangeOfString:@"페이지"].location != NSNotFound )
            {
                
            }
            else if( [str_Title rangeOfString:@"토팅 소개"].location != NSNotFound )
            {
                
            }
            else if( [str_Title rangeOfString:@"로그아웃"].location != NSNotFound )
            {
                [self logOut];
            }
        }
        else
        {
            NSDictionary *dic = self.arM_BottomList[indexPath.section];
            
            ChannelMainViewController *vc = [kChannelBoard instantiateViewControllerWithIdentifier:@"ChannelMainViewController"];
            //            vc.hidesBottomBarWhenPushed = YES;
            vc.isShowNavi = YES;
            vc.str_ChannelId = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"channelId"] integerValue]];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( tableView == self.tbv_TopList && indexPath.row == 0 )
    {
        return 70.f;
    }
    
    return 50.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if( tableView == self.tbv_BottomList && section == 0 )
    {
        return kReportFooterHeight;
    }

    BOOL isHaveMember = NO;
    NSInteger nFindIdx = -1;
    NSInteger nFindSettingIdx = -1;
    for( NSInteger i = 0; i < self.arM_BottomList.count; i++ )
    {
        id obj = self.arM_BottomList[i];
        if( [obj isKindOfClass:[NSString class]] )
        {
            NSString *str_Title = obj;
            if( [str_Title rangeOfString:@"팔로잉"].location != NSNotFound )
            {
                nFindIdx = i - 1;
            }
            else if( [str_Title rangeOfString:@"설정"].location != NSNotFound )
            {
                nFindSettingIdx = i - 1;
            }
        }
        else if( [obj isKindOfClass:[NSDictionary class]] )
        {
            isHaveMember = YES;
        }
    }
    
    if( isHaveMember && nFindIdx > -1 && section == nFindIdx )
    {
        //찾았을 경우
        return 10.f;
    }

    if( section == nFindSettingIdx )
    {
        return 10.f;
    }
    
    return 0.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    if( tableView == self.tbv_BottomList )
    {
        NSString *str_Title = @"";
        BOOL isHaveMember = NO;
        for( NSInteger i = 0; i < self.arM_BottomList.count; i++ )
        {
            id obj = self.arM_BottomList[i];
            if( [obj isKindOfClass:[NSDictionary class]] )
            {
                isHaveMember = YES;
                break;
            }
        }
        
        if( isHaveMember && section == 0 )
        {
            //찾았을 경우
            str_Title = [NSString stringWithFormat:@"화원 %ld", nMemberCount];
        }

        
        
        UIView *v_Section = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, kReportFooterHeight)];
        v_Section.backgroundColor = [UIColor colorWithRed:235.f/255.f green:235.f/255.f blue:235.f/255.f alpha:1];
        UILabel *lb_Title = [[UILabel alloc] initWithFrame:CGRectMake(15, 3, 60, 15)];
        [lb_Title setFont:[UIFont systemFontOfSize:13]];
        lb_Title.textColor = [UIColor blackColor];
        lb_Title.text = str_Title;
        [v_Section addSubview:lb_Title];
        
        return v_Section;
    }
    
    return nil;
}








- (void)logOut
{
    UIAlertView *alert = CREATE_ALERT(nil, @"로그아웃 하시겠습니까?", @"로그아웃", @"취소");
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
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
    }];
}

- (IBAction)goTopArrow:(id)sender
{
    if( self.isChannelMode )
    {
        return;
    }
    
    if( self.arM_DefaultList.count < 2 )    return;
    
    static BOOL test = NO;
    
    if( test )
    {
        [Util rotationImage:self.iv_TopArrow withRadian:0];
        self.lc_DefaultTbvHeight.constant = 0.f;
    }
    else
    {
        [Util rotationImage:self.iv_TopArrow withRadian:-180];
        self.lc_DefaultTbvHeight.constant = self.arM_DefaultList.count * 50.f;
    }
    
    test = !test;
    
    [UIView animateWithDuration:0.3f animations:^{
        
        [self.view layoutIfNeeded];

    }];
}

@end


//진명
//팔로워 105
//회원 21
//관리자 6
