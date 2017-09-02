//
//  UserListViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 1. 25..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "UserListViewController.h"
#import "MyFollowingCell.h"
#import "ChannelMainViewController.h"

@interface UserListCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Name;
@property (nonatomic, weak) IBOutlet UILabel *lb_SubName;
@end

@implementation UserListCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self layoutIfNeeded];
    
    self.iv_User.clipsToBounds = YES;
    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.width / 2;
    self.iv_User.layer.borderColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1].CGColor;
    self.iv_User.layer.borderWidth = 1.f;
}
//- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
//    [super setSelected:selected animated:animated];
//    
//    // Configure the view for the selected state
//}
@end


@interface UserListViewController ()
{
    NSString *str_ImagePrefix;
    NSString *str_UserImagePrefix;
    NSString *str_NoImagePrefix;
}
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@end

@implementation UserListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if( self.userStatusCode == kFollowing )
    {
        self.lb_Title.text = @"팔로잉";
    }
    else if( self.userStatusCode == kMember )
    {
        self.lb_Title.text = @"회원";
    }
    else if( self.userStatusCode == kAdmin )
    {
        self.lb_Title.text = @"관리자";
    }

    [self updateList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
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
                                        self.str_UserId ? self.str_UserId : [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"], @"pUserId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/follower/channel/list"
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
                                                str_ImagePrefix = [resulte objectForKey:@"img_prefix"];
                                                str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
                                                str_NoImagePrefix = [resulte objectForKey:@"no_image"];

                                                self.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"followChannelInfos"]];

                                                if( self.userStatusCode == kMember )
                                                {
                                                    NSMutableArray *arM_Tmp = [NSMutableArray array];

                                                    for( NSInteger i = 0; i < self.arM_List.count; i++ )
                                                    {
                                                        NSDictionary *dic = self.arM_List[i];
                                                        NSInteger nMemberLevel = [[dic objectForKey:@"memberLevel"] integerValue];
                                                        NSString *str_StatusCode = [dic objectForKey:@"statusCode"];
                                                        if( ([str_StatusCode isEqualToString:@"T"] && nMemberLevel < 10) || [str_StatusCode isEqualToString:@"M"] )
                                                        {
                                                            //관리자이거나 회원일 경우
                                                            [arM_Tmp addObject:dic];
                                                        }
                                                    }
                                                    
                                                    self.arM_List = [NSMutableArray arrayWithArray:arM_Tmp];
                                                }
                                                else if( self.userStatusCode == kAdmin )
                                                {
                                                    NSMutableArray *arM_Tmp = [NSMutableArray array];
                                                    
                                                    for( NSInteger i = 0; i < self.arM_List.count; i++ )
                                                    {
                                                        NSDictionary *dic = self.arM_List[i];
                                                        NSInteger nMemberLevel = [[dic objectForKey:@"memberLevel"] integerValue];
                                                        NSString *str_StatusCode = [dic objectForKey:@"statusCode"];
                                                        if( ([str_StatusCode isEqualToString:@"T"] && (nMemberLevel <= 9 && nMemberLevel >= 1) ))
                                                        {
                                                            //관리자일 경우
                                                            [arM_Tmp addObject:dic];
                                                        }
                                                    }
                                                    
                                                    self.arM_List = [NSMutableArray arrayWithArray:arM_Tmp];
                                                }
                                            }
                                            
                                            [self.tbv_List reloadData];
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
    return self.arM_List.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyFollowingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyFollowingCell"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];

    cell.btn_Follow.tag = indexPath.row;

    NSDictionary *dic = self.arM_List[indexPath.row];

    //채널 이미지
    NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [dic objectForKey:@"channelImgUrl"]];
    [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];

    //팔로우 버튼 초기화
    cell.btn_Follow.titleLabel.textAlignment = NSTextAlignmentCenter;
    cell.btn_Follow.userInteractionEnabled = YES;
    cell.btn_Follow.selected = NO;
    [cell.btn_Follow setBackgroundImage:BundleImage(@"blue_box.png") forState:UIControlStateSelected];
    [cell.btn_Follow setTitle:@"팔로잉" forState:UIControlStateSelected];
    cell.btn_Follow.layer.borderWidth = 1.0f;
    [cell.btn_Follow setBackgroundImage:BundleImage(@"") forState:UIControlStateNormal];
    [cell.btn_Follow setBackgroundImage:BundleImage(@"") forState:UIControlStateSelected];
    /////////////

    NSInteger nMemberLevel = [[dic objectForKey:@"memberLevel"] integerValue];
    NSString *str_StatusCode = [dic objectForKey:@"statusCode"];
    if( [str_StatusCode isEqualToString:@"T"] && nMemberLevel < 10 )
    {
        //관리자
//            cell.btn_Follow.userInteractionEnabled = NO;
        cell.btn_Follow.selected = YES;
        [cell.btn_Follow setTitle:@"관리자" forState:UIControlStateSelected];
        cell.btn_Follow.layer.borderWidth = 0.0f;
        [cell.btn_Follow setBackgroundImage:BundleImage(@"red_box.png") forState:UIControlStateSelected];
        [cell.btn_Follow addTarget:self action:@selector(onAddMannager:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if( [str_StatusCode isEqualToString:@"T"] && nMemberLevel == 99 )
    {
        //관리자 승인대기중
        cell.btn_Follow.userInteractionEnabled = NO;
        [cell.btn_Follow setTitle:@"관리자\n승인대기중" forState:UIControlStateNormal];
        [cell.btn_Follow setTitleColor:kMainColor forState:UIControlStateNormal];
        [cell.btn_Follow setBackgroundColor:[UIColor whiteColor]];
        cell.btn_Follow.layer.borderColor = kMainColor.CGColor;
    }
    else
    {
        //팔로잉 여부
        [cell.btn_Follow setBackgroundColor:[UIColor whiteColor]];
        cell.btn_Follow.selected = NO;
        [cell.btn_Follow removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
        cell.btn_Follow.layer.borderColor = kMainColor.CGColor;

        //회원추가시 수락여부 [A-수락, D-거부, N-회원 아님, Y-사용자 답변 대기중, C-관리자가 해제]
        NSString *str_MemberAllow = [dic objectForKey:@"isMemberAllow"];
        if( [str_MemberAllow isEqualToString:@"A"] )
        {
            [cell.btn_Follow setTitle:@"회원" forState:UIControlStateNormal];
            [cell.btn_Follow setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [cell.btn_Follow setBackgroundColor:kMainOrangeColor];  //이미지가 있는듯하다...
            cell.btn_Follow.layer.borderColor = kMainOrangeColor.CGColor;

//                [cell.btn_Follow addTarget:self action:@selector(onMoveToFollower:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if( [str_MemberAllow isEqualToString:@"D"] )
        {
            [cell.btn_Follow setTitle:@"팔로잉" forState:UIControlStateNormal];
            cell.btn_Follow.selected = YES;
            [cell.btn_Follow setBackgroundColor:kMainColor];
            [cell.btn_Follow addTarget:self action:@selector(onFollowing:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if( [str_MemberAllow isEqualToString:@"Y"] )
        {
            [cell.btn_Follow setTitle:@"회원인증요청" forState:UIControlStateNormal];
            [cell.btn_Follow setTitleColor:kMainColor forState:UIControlStateNormal];
            [cell.btn_Follow setBackgroundColor:[UIColor whiteColor]];
            [cell.btn_Follow addTarget:self action:@selector(onShowNotiView:) forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            BOOL isFollowing = [[dic objectForKey:@"isMyFollow"] boolValue];
            if( isFollowing )
            {
                cell.btn_Follow.selected = YES;
                [cell.btn_Follow setBackgroundColor:kMainColor];
            }
            else
            {
                cell.btn_Follow.selected = NO;
                [cell.btn_Follow setBackgroundColor:[UIColor whiteColor]];
            }

            [cell.btn_Follow addTarget:self action:@selector(onFollowing:) forControlEvents:UIControlEventTouchUpInside];
        }
    }


    //채널명
    cell.lb_Title.text = [dic objectForKey_YM:@"channelName"];

    //토탈 팔로잉 수 & 토탈문제수
    cell.lb_SubTitle.text = [NSString stringWithFormat:@"%ld명 %ld문제",
                             [[dic objectForKey:@"channelFollowerCount"] integerValue],
                             [[dic objectForKey:@"channelExamCount"] integerValue]];

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

    
    
    
    
    
    
    
    
    
    
    
    
    
    
//    static NSString *CellIdentifier = @"UserListCell";
//    UserListCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    
//    /*
//     channelExamCount = 46;
//     channelFollowerCount = 125;
//     channelId = 4;
//     channelImgUrl = "000/000/edujmLogo.png";
//     channelName = "\Uc9c4\Uba85\Ud559\Uc6d0";
//     channelUrl = edujm;
//     createDate = "2016-07-21 00:00:00";
//     imgUrl = "000/000/f51df8be247438d5a6df1cf4ab5da74a.jpg";
//     isMemberAllow = A;
//     isMyFollow = 1;
//     memberLevel = 20;
//     nId = 0;
//     statusCode = M;
//     userId = 138;
//     */
//    
//    NSDictionary *dic = self.arM_List[indexPath.row];
//    
//    NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [dic objectForKey:@"channelImgUrl"]];
//    [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
//
//    cell.lb_Name.text = [dic objectForKey_YM:@"channelName"];
//    
//    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    if( self.isManagerView )    return;

    NSDictionary *dic = self.arM_List[indexPath.row];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Channel" bundle:nil];
    ChannelMainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChannelMainViewController"];
    vc.str_ChannelId = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"channelId"] integerValue]];
    vc.isShowNavi = YES;
    [self.navigationController pushViewController:vc animated:YES];
    
}


- (void)onAddMannager:(UIButton *)btn
{
//    if( self.isManagerView )    return;
    
    NSDictionary *dic = self.arM_List[btn.tag];
    
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

- (void)onFollowing:(UIButton *)btn
{
//    if( self.isManagerView )    return;
    
    NSDictionary *dic = self.arM_List[btn.tag];
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

- (void)onShowNotiView:(UIButton *)btn
{
    NSDictionary *dic = self.arM_List[btn.tag];
    [Common showDetailNoti:self withInfo:dic];
}

@end
