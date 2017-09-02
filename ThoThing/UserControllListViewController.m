//
//  UserControllListViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 1. 31..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "UserControllListViewController.h"
#import "UserControllListCell.h"
#import "MyMainViewController.h"

@interface UserControllListViewController ()
{
    BOOL isNaviStatus;
    
    NSString *str_ImagePrefix;
    NSString *str_UserImagePrefix;
    NSString *str_NoImagePrefix;
}
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, weak) IBOutlet UILabel *lb_MasterTitle;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_TitleCount;
@property (nonatomic, weak) IBOutlet UIButton *btn_Master;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet UIButton *btn_Back;
@property (nonatomic, weak) IBOutlet UIButton *btn_Close;
@end

@implementation UserControllListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    isNaviStatus = self.navigationController.navigationBarHidden;
    
    self.btn_Master.hidden = YES;
    
    if( self.isChannelMode )
    {
        self.btn_Back.hidden = YES;
        self.btn_Close.hidden = NO;
    }
    else
    {
        self.btn_Back.hidden = NO;
        self.btn_Close.hidden = YES;
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    if( self.isMasterMode )
    {
        self.lb_MasterTitle.hidden = NO;
        [self updateMasterList];
    }
    else
    {
        if( [self.str_Mode isEqualToString:@"sharp"] )
        {
            [self updateSharpList];
        }
        else
        {
            [self updateList];
        }
    }
    
//    NSString *str_Key = [NSString stringWithFormat:@"MainSideIdx_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
//    [[NSUserDefaults standardUserDefaults] setObject:@"1" forKey:str_Key];
//    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.navigationBarHidden = isNaviStatus;
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

- (void)updateSharpList
{
    NSString *str_ChannelHashTag = self.str_ChannelHashTag;
    str_ChannelHashTag = [str_ChannelHashTag stringByReplacingOccurrencesOfString:@"#" withString:@""];

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        self.str_ChannelType, @"channelType",
                                        str_ChannelHashTag, @"channelHashTag",
                                        nil];
    
    __weak __typeof(&*self)weakSelf = self;
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/hashtag/channel/member"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            str_ImagePrefix = [resulte objectForKey:@"img_prefix"];
                                            str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
                                            str_NoImagePrefix = [resulte objectForKey:@"no_image"];
                                            
                                            NSString *str_Title = [resulte objectForKey_YM:@"channelHashTag"];
                                            NSMutableAttributedString *attM = [[NSMutableAttributedString alloc] initWithString:str_Title];
                                            
                                            UIColor *color = [UIColor lightGrayColor];
                                            NSString *str_UserCount = [NSString stringWithFormat:@" %@", [resulte objectForKey:@"hashTagUserCount"]];
                                            
                                            NSDictionary *attrs = @{ NSForegroundColorAttributeName : color };
                                            NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:str_UserCount attributes:attrs];
                                            [attM appendAttributedString:attrStr];

                                            weakSelf.lb_Title.attributedText = attM;
                                            
                                            weakSelf.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"hashTagUserList"]];
                                            [weakSelf.tbv_List reloadData];
                                        }
                                    }];
}

- (void)updateList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        self.str_Mode, @"statusCode",
                                        nil];
    
    __weak __typeof(&*self)weakSelf = self;
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/user/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            str_ImagePrefix = [resulte objectForKey:@"img_prefix"];
                                            str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
                                            str_NoImagePrefix = [resulte objectForKey:@"no_image"];

                                            if( [weakSelf.str_Mode isEqualToString:@"follower"] )
                                            {
                                                NSString *str_Title = @"";
                                                if( self.isChannel )
                                                {
                                                    str_Title = @"팔로워";
                                                }
                                                else
                                                {
                                                    str_Title = @"팔로잉";
                                                }
                                                
                                                NSMutableAttributedString *attM = [[NSMutableAttributedString alloc] initWithString:str_Title];
                                                
                                                UIColor *color = [UIColor lightGrayColor];
                                                NSString *str_UserCount = [NSString stringWithFormat:@" %@", [resulte objectForKey:@"userListCount"]];
                                                
                                                NSDictionary *attrs = @{ NSForegroundColorAttributeName : color };
                                                NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:str_UserCount attributes:attrs];
                                                [attM appendAttributedString:attrStr];
                                                
                                                weakSelf.lb_Title.attributedText = attM;
                                            }
                                            else if( [weakSelf.str_Mode isEqualToString:@"member"] )
                                            {
                                                NSString *str_Title = @"회원";
                                                NSMutableAttributedString *attM = [[NSMutableAttributedString alloc] initWithString:str_Title];
                                                
                                                UIColor *color = [UIColor lightGrayColor];
                                                NSString *str_UserCount = [NSString stringWithFormat:@" %@", [resulte objectForKey:@"userListCount"]];
                                                
                                                NSDictionary *attrs = @{ NSForegroundColorAttributeName : color };
                                                NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:str_UserCount attributes:attrs];
                                                [attM appendAttributedString:attrStr];
                                                
                                                weakSelf.lb_Title.attributedText = attM;
                                            }
                                            else if( [weakSelf.str_Mode isEqualToString:@"manager"] )
                                            {
                                                NSString *str_Title = @"관리자";
                                                NSMutableAttributedString *attM = [[NSMutableAttributedString alloc] initWithString:str_Title];
                                                
                                                UIColor *color = [UIColor lightGrayColor];
                                                NSString *str_UserCount = [NSString stringWithFormat:@" %@", [resulte objectForKey:@"userListCount"]];
                                                
                                                NSDictionary *attrs = @{ NSForegroundColorAttributeName : color };
                                                NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:str_UserCount attributes:attrs];
                                                [attM appendAttributedString:attrStr];
                                                
                                                weakSelf.lb_Title.attributedText = attM;
                                            }

                                            weakSelf.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"userList"]];
                                            [weakSelf.tbv_List reloadData];
                                        }
                                    }];
}

- (void)updateMasterList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        self.str_Mode, @"statusCode",
                                        nil];
    
    __weak __typeof(&*self)weakSelf = self;
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/user/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            str_ImagePrefix = [resulte objectForKey:@"img_prefix"];
                                            str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
                                            str_NoImagePrefix = [resulte objectForKey:@"no_image"];
                                            
                                            weakSelf.arM_List = [NSMutableArray array];
                                            NSArray *ar = [resulte objectForKey:@"userList"];
                                            for( NSInteger i = 0; i < ar.count; i++ )
                                            {
                                                NSDictionary *dic = [ar objectAtIndex:i];
                                                NSInteger nMemberLevel = [[dic objectForKey:@"memberLevel"] integerValue];
                                                NSString *str_StatusCode = [dic objectForKey:@"statusCode"];
                                                if( [str_StatusCode isEqualToString:@"T"] && (nMemberLevel == 5 || nMemberLevel < 10) )
                                                {
                                                    [weakSelf.arM_List addObject:dic];
                                                }
                                            }
                                            
                                            [weakSelf.tbv_List reloadData];
                                        }
                                    }];
}



#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    self.btn_Master.hidden = YES;
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
    UserControllListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UserControllListCell"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.arM_List[indexPath.row];
    
    if( [self.str_Mode isEqualToString:@"sharp"] )
    {
        cell.lb_Date.hidden = cell.lb_Discrip.hidden = cell.sw.hidden = YES;

        NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [dic objectForKey:@"userThumbNail"]];
        [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
        
        cell.iv_User.tag = indexPath.row;
        cell.iv_User.userInteractionEnabled = YES;
        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
        [imageTap setNumberOfTapsRequired:1];
        [cell.iv_User addGestureRecognizer:imageTap];

        cell.lb_Name.text = [dic objectForKey:@"userName"];
        
        cell.lb_School.text = [dic objectForKey:@"userAffiliation"];

        return cell;
    }

    NSURL *url = [Util createImageUrl:str_UserImagePrefix withFooter:[dic objectForKey_YM:@"imgUrl"]];
    [cell.iv_User sd_setImageWithURL:url placeholderImage:BundleImage(@"no_image.png")];
    
    cell.lc_SwTail.constant = 15.f;
    cell.iv_User.tag = cell.sw.tag = indexPath.row;
    cell.iv_User.userInteractionEnabled = YES;
    [cell.sw addTarget:self action:@selector(onSwToggle:) forControlEvents:UIControlEventValueChanged];
    
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
    [imageTap setNumberOfTapsRequired:1];
    [cell.iv_User addGestureRecognizer:imageTap];

    cell.lb_Name.text = [dic objectForKey_YM:@"userName"];
    
    cell.lb_School.text = [NSString stringWithFormat:@"%@ %@", [dic objectForKey_YM:@"userAffiliation"], [dic objectForKey_YM:@"userMajor"]];
    
    cell.lb_Date.hidden = cell.lb_Discrip.hidden = cell.sw.hidden = YES;
    
    NSString *str_DateTmp = [NSString stringWithFormat:@"%@", [dic objectForKey:@"createDate"]];
    NSArray *ar_DateTmp = [str_DateTmp componentsSeparatedByString:@" "];
    if( ar_DateTmp.count > 1 )
    {
        cell.lb_Date.text = [ar_DateTmp firstObject];
    }

    if( [self.str_Mode isEqualToString:@"follower"] )
    {
        cell.lb_Date.hidden = cell.lb_Discrip.hidden = cell.sw.hidden = YES;
        
        NSString *str_CancelCmd = [dic objectForKey:@"cancelCmd"];
        if( [str_CancelCmd isEqualToString:@"cancelMember"] )
        {
            cell.lb_Date.hidden = cell.lb_Discrip.hidden = NO;
            cell.lb_Discrip.text = @"회원 해제";
            cell.lc_SwTail.constant = -50.f;
        }
        else if( [str_CancelCmd isEqualToString:@"cancelManager"] )
        {
            cell.lb_Date.hidden = cell.lb_Discrip.hidden = NO;
            cell.lb_Discrip.text = @"관리자 해제";
            cell.lc_SwTail.constant = -50.f;
        }
        else
        {
            cell.lb_Date.text = cell.lb_Discrip.text = @"";
            cell.lc_SwTail.constant = 0.f;
        }
    }
    else if( [self.str_Mode isEqualToString:@"member"] )
    {
        if( self.isMannager )
        {
            cell.lb_Date.hidden = cell.lb_Discrip.hidden = cell.sw.hidden = NO;
        }
        
        NSString *str_MemberLevel = [NSString stringWithFormat:@"%@", [dic objectForKey:@"memberLevel"]];
        NSString *str_MemberAllow = [NSString stringWithFormat:@"%@", [dic objectForKey:@"isMemberAllow"]];
        if( [str_MemberAllow isEqualToString:@"A"] && [str_MemberLevel isEqualToString:@"20"] )
        {
            [cell.lb_Discrip setTextColor:[UIColor lightGrayColor]];
            cell.lb_Discrip.text = @"회원";
            cell.lb_Date.text = [NSString stringWithFormat:@"%@ ~", cell.lb_Date.text];
            cell.sw.on = YES;
        }
        else if( [str_MemberAllow isEqualToString:@"Y"] && [str_MemberLevel isEqualToString:@"20"] )
        {
            [cell.lb_Discrip setTextColor:[UIColor redColor]];
            cell.lb_Discrip.text = @"회원 요청";
            cell.sw.on = NO;
        }
        else
        {
            [cell.lb_Discrip setTextColor:[UIColor redColor]];
            cell.lb_Discrip.text = @"회원 해제";
            cell.sw.on = NO;
        }
    }
    else if( [self.str_Mode isEqualToString:@"manager"] )
    {
        if( self.isMasterMode )
        {
            cell.sw.hidden = NO;
            [cell.sw removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
            [cell.sw addTarget:self action:@selector(onMasterToggle:) forControlEvents:UIControlEventValueChanged];
            
            NSInteger nMemberLevel = [[dic objectForKey:@"memberLevel"] integerValue];
            if( nMemberLevel == 5 )
            {
                cell.sw.on = YES;
            }
            else
            {
                cell.sw.on = NO;
            }
        }
        else if( self.isMannager )
        {
            cell.lb_Date.hidden = cell.lb_Discrip.hidden = cell.sw.hidden = NO;
            
            NSInteger nMemberLevel = [[dic objectForKey:@"memberLevel"] integerValue];
            NSString *str_StatusCode = [dic objectForKey:@"statusCode"];
            if( [str_StatusCode isEqualToString:@"T"] && nMemberLevel == 5 )
            {
                //마스터 관리자
                cell.lc_SwTail.constant = -50.f;
                [cell.lb_Discrip setTextColor:[UIColor redColor]];
                cell.lb_Discrip.text = @"마스터 관리자";
                cell.lb_Date.text = [NSString stringWithFormat:@"%@ ~", cell.lb_Date.text];

                NSString *str_MyId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
                if( [[dic objectForKey:@"userId"] integerValue] == [str_MyId integerValue] )
                {
                    self.btn_Master.hidden = NO;
                }
            }
            else if( [str_StatusCode isEqualToString:@"T"] && nMemberLevel < 10 )
            {
                //관리자
                [cell.lb_Discrip setTextColor:[UIColor lightGrayColor]];
                cell.lb_Discrip.text = @"관리자";
                cell.lb_Date.text = [NSString stringWithFormat:@"%@ ~", cell.lb_Date.text];
                cell.sw.on = YES;
            }
            else if( [str_StatusCode isEqualToString:@"T"] && nMemberLevel == 99 )
            {
                //관리자 신청
                [cell.lb_Discrip setTextColor:[UIColor redColor]];
                cell.lb_Discrip.text = @"관리자 요청";
                cell.sw.on = NO;
            }
            else
            {
                [cell.lb_Discrip setTextColor:[UIColor redColor]];
                cell.lb_Discrip.text = @"관리자 해제";
                cell.sw.on = NO;
            }
        }
    }
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)imageTap:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *view = (UIView *)gestureRecognizer.view;
    NSDictionary *dic = self.arM_List[view.tag];
    
    MyMainViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
    vc.isAnotherUser = YES;
    vc.isShowNavi = NO;
    vc.str_UserIdx = [dic objectForKey:@"userId"];
    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - IBAction
- (void)onSwToggle:(id)sender
{
    UISwitch *sw = (UISwitch *)sender;
    NSDictionary *dic_Tmp = self.arM_List[sw.tag];
    NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic_Tmp];
    
    if( [self.str_Mode isEqualToString:@"member"] )
    {
        if( self.isMannager )
        {
            __block BOOL isOn = NO;
            NSString *str_MemberLevel = [NSString stringWithFormat:@"%@", [dic_Tmp objectForKey:@"memberLevel"]];
            NSString *str_MemberAllow = [NSString stringWithFormat:@"%@", [dic_Tmp objectForKey:@"isMemberAllow"]];
            if( [str_MemberAllow isEqualToString:@"A"] && [str_MemberLevel isEqualToString:@"20"] )
            {
                isOn = YES;
            }
            else if( [str_MemberAllow isEqualToString:@"Y"] && [str_MemberLevel isEqualToString:@"20"] )
            {

            }
            else
            {

            }
            
            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                [Util getUUID], @"uuid",
                                                self.str_ChannelId, @"channelId",
                                                [NSString stringWithFormat:@"%@", [dic_Tmp objectForKey:@"userId"]], @"userId",
                                                isOn ? @"terminate" : @"mamber", @"setMode",
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
                                                        if( isOn )
                                                        {
                                                            [dicM setObject:@"C" forKey:@"isMemberAllow"];
                                                        }
                                                        else
                                                        {
                                                            [dicM setObject:@"A" forKey:@"isMemberAllow"];
                                                        }
                                                        
                                                        NSDictionary *dic_FollowerInfo = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"followerInfo"]];
                                                        [dicM setObject:[dic_FollowerInfo objectForKey:@"changeDate"] forKey:@"createDate"];
                                                        
                                                        [self.arM_List replaceObjectAtIndex:sw.tag withObject:dicM];
                                                        [self.tbv_List reloadData];
                                                    }
                                                    else
                                                    {
                                                        [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                    }
                                                }
                                            }];
        }
    }
    else if( [self.str_Mode isEqualToString:@"manager"] )
    {
        if( self.isMannager )
        {
            __block BOOL isOn = NO;
            NSInteger nMemberLevel = [[dic_Tmp objectForKey:@"memberLevel"] integerValue];
            NSString *str_StatusCode = [dic_Tmp objectForKey:@"statusCode"];
            if( [str_StatusCode isEqualToString:@"T"] && nMemberLevel < 10 )
            {
                //관리자
                isOn = YES;
            }
            else if( [str_StatusCode isEqualToString:@"T"] && nMemberLevel == 99 )
            {
                //관리자 신청

            }
            else
            {

            }

            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                [Util getUUID], @"uuid",
                                                self.str_ChannelId, @"channelId",
                                                [NSString stringWithFormat:@"%@", [dic_Tmp objectForKey:@"userId"]], @"userId",
                                                isOn ? @"delete" : @"manager", @"setMode",
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
                                                        if( isOn )
                                                        {
                                                            [dicM setObject:@"C" forKey:@"statusCode"];
                                                        }
                                                        else
                                                        {
                                                            [dicM setObject:@"T" forKey:@"statusCode"];
                                                            [dicM setObject:@"9" forKey:@"memberLevel"];
                                                        }
                                                        
                                                        NSDictionary *dic_FollowerInfo = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"followerInfo"]];
                                                        if( [dic_FollowerInfo objectForKey:@"changeDate"] == nil )
                                                        {
                                                            dic_FollowerInfo = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"followInfo"]];
                                                        }
                                                        [dicM setObject:[dic_FollowerInfo objectForKey:@"changeDate"] forKey:@"createDate"];
                                                        
                                                        [self.arM_List replaceObjectAtIndex:sw.tag withObject:dicM];
                                                    }
                                                    else
                                                    {
                                                        [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                    }
                                                    
                                                    [self.tbv_List reloadData];
                                                }
                                            }];
        }
    }
}

- (void)onMasterToggle:(id)sender
{
    UISwitch *sw = (UISwitch *)sender;
    __block BOOL isOn = sw.on;
    if( isOn == NO )
    {
        //최소 1명의 마스터 관리자가 있어야 하기 때문에 검사
        NSInteger nMasterCnt = 0;
        for( NSInteger i = 0; i < self.arM_List.count; i++ )
        {
            NSDictionary *dic = [self.arM_List objectAtIndex:i];
            NSInteger nMemberLevel = [[dic objectForKey:@"memberLevel"] integerValue];
            if( nMemberLevel == 5 )
            {
                nMasterCnt++;
            }
        }
        
        if( nMasterCnt <= 1 )
        {
            sw.on = YES;
            ALERT(nil, @"최소 1명의 마스터\n관리자가 필요합니다", nil, @"확인", nil);
            return;
        }
    }
    NSDictionary *dic_Tmp = self.arM_List[sw.tag];
    NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic_Tmp];

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        [NSString stringWithFormat:@"%@", [dic_Tmp objectForKey:@"userId"]], @"userId",
                                        isOn ? @"master" : @"delete", @"setMode",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/channel/master"
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
                                                if( isOn )
                                                {
                                                    [dicM setObject:@"5" forKey:@"memberLevel"];
                                                }
                                                else
                                                {
                                                    [dicM setObject:@"9" forKey:@"memberLevel"];
                                                }
                                                
//                                                NSDictionary *dic_FollowerInfo = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"followerInfo"]];
//                                                if( [dic_FollowerInfo objectForKey:@"changeDate"] == nil )
//                                                {
//                                                    dic_FollowerInfo = [NSDictionary dictionaryWithDictionary:[resulte objectForKey:@"followInfo"]];
//                                                }
//                                                [dicM setObject:[dic_FollowerInfo objectForKey:@"changeDate"] forKey:@"createDate"];
                                                
                                                [self.arM_List replaceObjectAtIndex:sw.tag withObject:dicM];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                            
                                            [self.tbv_List reloadData];
                                        }
                                    }];
}

- (IBAction)goMaster:(id)sender
{
    UserControllListViewController *vc = [kEtcBoard instantiateViewControllerWithIdentifier:@"UserControllListViewController"];
    vc.isMasterMode = YES;
    vc.str_ChannelId = self.str_ChannelId;
    vc.str_Mode = @"manager";
    [self.navigationController pushViewController:vc animated:YES];
}

@end
