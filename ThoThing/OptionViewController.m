//
//  OptionViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 8. 19..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "OptionViewController.h"
#import "OptionListCell.h"
#import "OptionHeaderCell.h"
#import "OptionFooterCell.h"
#import "ProfileModifyViewController.h"
#import "ChangePwViewController.h"

@interface OptionViewController () <UIActionSheetDelegate>
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@end

@implementation OptionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initNaviWithTitle:@"옵션" withLeftItem:[self leftBackBlackMenuBarButtonItem] withRightItem:nil withColor:[UIColor colorWithHexString:@"F8F8F8"]];

    //엠프티셀의 세퍼레이터 지우기
    self.tbv_List.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    [self updateList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = NO;
    
//    NSString *str_Key = [NSString stringWithFormat:@"MainSideIdx_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
//    [[NSUserDefaults standardUserDefaults] setObject:@"10" forKey:str_Key];
//    [[NSUserDefaults standardUserDefaults] synchronize];
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
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"], @"pUserId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/follower/channel/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        self.arM_List = nil;
                                        
                                        if( resulte )
                                        {
                                            NSLog(@"resulte : %@", resulte);
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                //회원 아닌 경우 걸러내기
                                                NSMutableArray *arM = [NSMutableArray arrayWithArray:[resulte objectForKey:@"followChannelInfos"]];
                                                for( NSInteger i = 0; i < arM.count; i++ )
                                                {
                                                    NSDictionary *dic = arM[i];
                                                    NSString *str_Status = [dic objectForKey:@"isMemberAllow"];
                                                    
                                                    NSInteger nLevel = [[dic objectForKey:@"memberLevel"] integerValue];
                                                    NSString *str_Code = [dic objectForKey:@"statusCode"];
                                                    BOOL isMannager = nLevel < 10 && [str_Code isEqualToString:@"T"];
                                                    
                                                    if( isMannager == NO && ([str_Status isEqualToString:@"N"] || [str_Status isEqualToString:@"C"]) )
                                                    {
                                                        [arM removeObjectAtIndex:i];
                                                    }
                                                }
                                                ////////////////
                                                
                                                self.arM_List = [NSMutableArray array];
                                                [self.arM_List addObject:@[@"프로필 편집",@"비밀번호 변경"]];
                                                [self.arM_List addObject:arM];
                                                [self.arM_List addObject:@[@"로그아웃"]];
                                                [self.tbv_List reloadData];
                                            }
                                            else
                                            {
                                                self.arM_List = [NSMutableArray array];
                                                [self.arM_List addObject:@[@"프로필 편집",@"비밀번호 변경"]];
                                                [self.arM_List addObject:@[]];
                                                [self.arM_List addObject:@[@"로그아웃"]];
                                                [self.tbv_List reloadData];
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
    NSArray *ar_SubList = self.arM_List[section];
    return ar_SubList.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    OptionListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OptionListCell" forIndexPath:indexPath];
    
    cell.lb_Status.text = @"";
    cell.iv_TopLine.hidden = cell.iv_BottomLine.hidden = YES;
    cell.sw.hidden = YES;
    [cell.lb_Title setTextColor:[UIColor blackColor]];
    cell.accessoryType = UITableViewCellAccessoryNone;

    cell.sw.tag = indexPath.row;
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)])
    {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 0)];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)])
    {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 15, 0, 0)];
    }

    if( indexPath.section == 0 )
    {
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    if( indexPath.section == 1 )
    {
        cell.sw.hidden = NO;
    }
    
    if( indexPath.section == 2 )
    {
        cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
        [cell.lb_Title setTextColor:kMainColor];
        cell.iv_TopLine.hidden = cell.iv_BottomLine.hidden = NO;
    }
    


    NSArray *ar_SubList = self.arM_List[indexPath.section];
    if( indexPath.section != 1 )
    {
        NSString *str_Title = ar_SubList[indexPath.row];
        cell.lb_Title.text = str_Title;
    }
    else
    {
        /*
         channelExamCount = 44;
         channelFollowerCount = 102;
         channelId = 4;
         channelImgUrl = "000/000/edujmLogo.png";
         channelName = "\Uc9c4\Uba85\Ud559\Uc6d0";
         channelUrl = edujm;
         createDate = "2016-07-13 18:29:05";
         imgUrl = "000/000/noImage14.png";
         isMemberAllow = N;
         isMyFollow = 1;
         memberLevel = 9;
         nId = 0;
         statusCode = T;
         userId = 108;
         */
        
        //회원추가시 수락여부 [A-수락, D-거부, N-회원 아님, Y-사용자 답변 대기중, C-관리자가 해제]
        NSDictionary *dic = ar_SubList[indexPath.row];
        cell.lb_Title.text = [dic objectForKey_YM:@"channelName"];
        
        NSInteger nLevel = [[dic objectForKey:@"memberLevel"] integerValue];
        NSString *str_Code = [dic objectForKey:@"statusCode"];
        BOOL isMannager = nLevel < 10 && [str_Code isEqualToString:@"T"];

        NSString *str_Status = [dic objectForKey:@"isMemberAllow"];
        if( isMannager )
        {
            //매니저일 경우
            cell.sw.on = YES;
            cell.lb_Status.text = @"";
        }
        else if( [str_Status isEqualToString:@"A"] )
        {
            //수락
            cell.sw.on = YES;
            cell.lb_Status.text = @"";
        }
        else if( [str_Status isEqualToString:@"D"] )
        {
            //거부
            cell.sw.on = NO;
            cell.lb_Status.text = @"회원 거부했습니다";
        }
        else if( [str_Status isEqualToString:@"Y"] )
        {
            //대기중
            cell.sw.on = NO;
            cell.lb_Status.text = @"회원 대기중입니다";
        }
        else if( [str_Status isEqualToString:@"C"] )
        {
            //관리자가 해제
            cell.sw.on = NO;
            cell.lb_Status.text = @"관리자에 의해 해제 되었습니다";
        }
        else if( [str_Status isEqualToString:@"N"] )
        {
            //관리자가 해제
            cell.sw.on = NO;
            cell.lb_Status.text = @"회원이 아닙니다";
        }

        [cell.sw addTarget:self action:@selector(onSwChange:) forControlEvents:UIControlEventValueChanged];
    }
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if( indexPath.section == 0 && indexPath.row == 0 )
    {
        NSArray *ar_SubList = self.arM_List[indexPath.section];
        NSDictionary *dic = ar_SubList[indexPath.row];

        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Setting" bundle:nil];
        ProfileModifyViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ProfileModifyViewController"];
//        vc.str_ChannelId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]];
        [self presentViewController:vc animated:YES completion:^{
            
        }];
    }
    else if( indexPath.section == 0 && indexPath.row == 1 )
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Setting" bundle:nil];
        ChangePwViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChangePwViewController"];
        [self presentViewController:vc animated:YES completion:^{
            
        }];
    }
    else if( indexPath.section == 2 )
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
        }];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if( section == 2 )
    {
        return 0;
    }
    
    return 44.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    OptionHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OptionHeaderCell"];
    
    if( section == 0 )
    {
        cell.lb_Title.text = @"계정";
    }
    else if( section == 1 )
    {
        cell.lb_Title.text = @"채널 회원 동의";
    }
    else
    {
        return nil;
    }
    
    return cell;
}

- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    OptionFooterCell *cell = [tableView dequeueReusableCellWithIdentifier:@"OptionFooterCell"];
    
    if( section == 0 )
    {
        cell.lb_Title.text = @"계정이 비공개인 경우 회원님이 승인한 사람만 '토팅'에서 회원님의 사진과 기본적인 프로파일만 볼 수 있습니다.";
    }
    else if( section == 1 )
    {
        cell.lb_Title.text = @"채널 회원 동의 하면, 채널 관리자가 회원님의 시험에 대한 레포트를 볼 수 있습니다.";
    }
    else
    {
        return nil;
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if( section == 2 )
    {
        return 0;
    }

    return 70.f;
}


//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
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
//    
//    
//    //    헤더고정
//    CGFloat sectionHeaderHeight = 44.f;
//    if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0)
//    {
//        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
//    }
//    else if (scrollView.contentOffset.y>=sectionHeaderHeight)
//    {
//        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
//    }
//}


- (void)onSwChange:(UISwitch *)sw
{
    NSInteger nTag = sw.tag;
    
    NSArray *ar_SubList = self.arM_List[1];
    NSDictionary *dic = ar_SubList[nTag];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]], @"channelId",
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"], @"userId",                         //noti를 받은 사용자 ID
                                        @"member-noti", @"notiType",            //noti 종류 [meember-noti: 회원 등록 noti]    //confirm-join
                                        sw.isOn ? @"Y" : @"D", @"userConfirm",    //사용자 응답 [Y-수락, D-거부]
                                        //                                        isYes ? @"member" : @"terminate", @"setMode", //[member-등록, terminate-해제]
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/user/noti/confirm"
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

@end
