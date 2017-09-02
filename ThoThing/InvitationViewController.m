//
//  InvitationViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 9. 13..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "InvitationViewController.h"
#import "InvitationCell.h"
#import "UserPageMainViewController.h"
#import "MyMainViewController.h"

@interface InvitationViewController ()
{
    NSString *str_ImagePrefix;
    NSString *str_UserImagePrefix;
    NSString *str_NoImagePrefix;
    
    UIColor *deSelectColor;
    NSMutableDictionary *dicM_Check;
    
    CGFloat fKeyboardHeight;
}
@property (nonatomic, strong) UIButton *btn_RightNaviItem;
@property (nonatomic, strong) NSArray *ar_List;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet UITextField *tf_SharedMessage;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_AccBottom;
@property (nonatomic, weak) IBOutlet UIView *v_TextFieldBg;
@end

@implementation InvitationViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    deSelectColor = [UIColor colorWithRed:180.f/255.f green:180.f/255.f blue:180.f/255.f alpha:1];
    
    self.v_TextFieldBg.layer.cornerRadius = 16.f;
    self.v_TextFieldBg.layer.borderWidth = 1.f;
    self.v_TextFieldBg.layer.borderColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1].CGColor;
    
    self.btn_RightNaviItem = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btn_RightNaviItem.frame = CGRectMake(0, 0, 75, 30);
    [self.btn_RightNaviItem setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    if( self.isShare )
    {
        [self.btn_RightNaviItem setTitle:@"공유하기" forState:0];
    }
    else
    {
        [self.btn_RightNaviItem setTitle:@"초대하기" forState:0];
    }
    [self.btn_RightNaviItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    [self.btn_RightNaviItem setTitleColor:deSelectColor forState:UIControlStateNormal];
    [self.btn_RightNaviItem addTarget:self action:@selector(rightInvitationPress:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btn_RightNaviItem.layer.cornerRadius = 8.f;
    self.btn_RightNaviItem.layer.borderWidth = 1.f;

    if( self.isShare )
    {
        [self initNaviWithTitle:@"공유하기" withLeftItem:[self leftBackBlackMenuBarButtonItem] withRightItem:[[UIBarButtonItem alloc] initWithCustomView:self.btn_RightNaviItem] withColor:[UIColor colorWithHexString:@"F8F8F8"]];
    }
    else
    {
        [self initNaviWithTitle:@"초대하기" withLeftItem:[self leftBackBlackMenuBarButtonItem] withRightItem:[[UIBarButtonItem alloc] initWithCustomView:self.btn_RightNaviItem] withColor:[UIColor colorWithHexString:@"F8F8F8"]];
    }

    [self invitationButtonOff];

    dicM_Check = [NSMutableDictionary dictionary];
    
    [self updateList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAnimate:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAnimate:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

#pragma mark - Notification
- (void)keyboardWillAnimate:(NSNotification *)notification
{
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    fKeyboardHeight = keyboardBounds.size.height;
    
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        [UIView setAnimationCurve:[curve intValue]];
        if([notification name] == UIKeyboardWillShowNotification)
        {
            self.lc_AccBottom.constant = keyboardBounds.size.height;
        }
        else if([notification name] == UIKeyboardWillHideNotification)
        {
            self.lc_AccBottom.constant = -50.f;
        }
    }completion:^(BOOL finished) {
        
    }];
}

- (void)invitationButtonOn
{
    self.btn_RightNaviItem.userInteractionEnabled = YES;
    
    self.btn_RightNaviItem.layer.borderColor = kMainColor.CGColor;
    [self.btn_RightNaviItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.btn_RightNaviItem setBackgroundColor:kMainColor];
}

- (void)invitationButtonOff
{
    self.btn_RightNaviItem.userInteractionEnabled = NO;
    
    self.btn_RightNaviItem.layer.borderColor = deSelectColor.CGColor;
    [self.btn_RightNaviItem setTitleColor:deSelectColor forState:UIControlStateNormal];
    [self.btn_RightNaviItem setBackgroundColor:[UIColor whiteColor]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rightInvitationPress:(UIButton *)btn
{
    if( dicM_Check.count <= 0 ) return;

    self.btn_RightNaviItem.userInteractionEnabled = NO;
    
    if( self.isShare )
    {
        [self.tf_SharedMessage becomeFirstResponder];
        
    }
    else
    {
        NSMutableString *strM = [NSMutableString string];
        NSArray *ar_AllKeys = dicM_Check.allKeys;
        for( NSInteger i = 0; i < ar_AllKeys.count; i++ )
        {
            [strM appendString:[dicM_Check objectForKey:ar_AllKeys[i]]];
            [strM appendString:@","];
        }
        
        if( [strM hasSuffix:@","] )
        {
            [strM deleteCharactersInRange:NSMakeRange([strM length]-1, 1)];
        }
        
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            self.str_RId, @"rId",
                                            strM, @"inviteUserIdStr",
                                            nil];
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/qna/chat/room/invite/user"
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
                                                    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                                                    [window makeToast:@"초대했습니다" withPosition:kPositionBottom];
                                                    
                                                    [self.navigationController popViewControllerAnimated:YES];
                                                }
                                                else
                                                {
                                                    [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                }
                                            }
                                            
                                            self.btn_RightNaviItem.userInteractionEnabled = YES;
                                        }];
    }
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
    if( self.isShare )
    {
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
//                                            self.str_ChannelId, @"channelId",
//                                            self.str_QuestionId, @"questionId",
                                            nil];
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/follow/channel/member/list"
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
                                                    
                                                    self.ar_List = [NSArray arrayWithArray:[resulte objectForKey:@"userListInfos"]];
                                                    [self.tbv_List reloadData];
                                                }
                                                else
                                                {
                                                    [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                }
                                            }
                                        }];
    }
    else
    {
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            self.str_ChannelId, @"channelId",
                                            self.str_QuestionId, @"questionId",
                                            nil];
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/qna/chat/room/invite/user/list"
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
                                                    
                                                    self.ar_List = [NSArray arrayWithArray:[resulte objectForKey:@"userListInfos"]];
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




#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ar_List.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InvitationCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InvitationCell"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*
     memberLevel = 9;
     url = T108160419;
     userId = 108;
     userName = "\Ud1a0\Ud305\Uc120\Uc0dd\Ub2d81";
     userThumbnail = "000/000/164aa850dc2e3c45bff40379582d642e_620.jpg";
     userType = manager;
     */
    
    cell.iv_User.tag = indexPath.row;
    
    NSDictionary *dic = self.ar_List[indexPath.row];
    
    cell.iv_User.userInteractionEnabled = YES;
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
    [imageTap setNumberOfTapsRequired:1];
    [cell.iv_User addGestureRecognizer:imageTap];

    if( self.isShare )
    {
        [cell.iv_User sd_setImageWithURL:[Util createImageUrl:str_UserImagePrefix withFooter:[dic objectForKey:@"userThumbnail"]]];

        NSString *str_Date = [NSString stringWithFormat:@"%@", [dic objectForKey:@"lastShareDate"]];
        if( str_Date.length >= 12 )
        {
            NSString *str_Year = [str_Date substringWithRange:NSMakeRange(0, 4)];
            NSString *str_Month = [str_Date substringWithRange:NSMakeRange(4, 2)];
            NSString *str_Day = [str_Date substringWithRange:NSMakeRange(6, 2)];
            //        NSString *str_Hour = [str_Date substringWithRange:NSMakeRange(8, 2)];
            //        NSString *str_Minute = [str_Date substringWithRange:NSMakeRange(10, 2)];
            
            cell.lb_Date.text = [NSString stringWithFormat:@"공유 %04ld-%02ld-%02ld", [str_Year integerValue], [str_Month integerValue], [str_Day integerValue]];
        }
        else
        {
            cell.lb_Date.text = str_Date;
        }
    }
    else
    {
        [cell.iv_User sd_setImageWithURL:[Util createImageUrl:str_UserImagePrefix withFooter:[dic objectForKey:@"imgUrl"]]];
        
        NSString *str_Date = [NSString stringWithFormat:@"%@", [dic objectForKey:@"lastInviteDate"]];
        if( str_Date.length >= 12 )
        {
            NSString *str_Year = [str_Date substringWithRange:NSMakeRange(0, 4)];
            NSString *str_Month = [str_Date substringWithRange:NSMakeRange(4, 2)];
            NSString *str_Day = [str_Date substringWithRange:NSMakeRange(6, 2)];
            //        NSString *str_Hour = [str_Date substringWithRange:NSMakeRange(8, 2)];
            //        NSString *str_Minute = [str_Date substringWithRange:NSMakeRange(10, 2)];
            
            cell.lb_Date.text = [NSString stringWithFormat:@"초대 %04ld-%02ld-%02ld", [str_Year integerValue], [str_Month integerValue], [str_Day integerValue]];
        }
        else
        {
            cell.lb_Date.text = str_Date;
        }
    }

    cell.lb_Name.text = [dic objectForKey:@"userName"];
    
    NSString *str_UserId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]];
    NSInteger nSelectedUserId = [[dicM_Check objectForKey:str_UserId] integerValue];
    if( nSelectedUserId > 0 )
    {
        cell.btn_Check.selected = YES;
    }
    else
    {
        cell.btn_Check.selected = NO;
    }
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.ar_List[indexPath.row];
    NSString *str_UserId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]];
    
    InvitationCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    cell.btn_Check.selected = !cell.btn_Check.selected;
    
    if( cell.btn_Check.selected )
    {
        //선택이면 추가
        [dicM_Check setObject:str_UserId forKey:str_UserId];
    }
    else
    {
        //아니면 우선 삭제
        [dicM_Check removeObjectForKey:str_UserId];
    }
    
    if( dicM_Check.count > 0 )
    {
        [self invitationButtonOn];
    }
    else
    {
        [self invitationButtonOff];
    }
}


- (IBAction)goSend:(id)sender
{
    
}

- (void)imageTap:(UIGestureRecognizer *)gesture
{
    UIView *view = (UIView *)gesture.view;
    NSDictionary *dic = self.ar_List[view.tag];
    
    MyMainViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
    vc.isAnotherUser = YES;
    vc.str_UserIdx = [dic objectForKey:@"userId"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goSendShared:(id)sender
{
    if( dicM_Check.count <= 0 )
    {
        self.btn_RightNaviItem.userInteractionEnabled = YES;
        return;
    }

    NSMutableString *strM = [NSMutableString string];
    NSArray *ar_AllKeys = dicM_Check.allKeys;
    for( NSInteger i = 0; i < ar_AllKeys.count; i++ )
    {
        [strM appendString:[dicM_Check objectForKey:ar_AllKeys[i]]];
        [strM appendString:@","];
    }
    
    if( [strM hasSuffix:@","] )
    {
        [strM deleteCharactersInRange:NSMakeRange([strM length]-1, 1)];
    }

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ExamId, @"examId",
                                        self.str_QuestionId, @"questionId",
                                        self.tf_SharedMessage.text, @"shareMsg",
                                        strM, @"inviteUserIdStr",
                                        nil];
    
    NSString *str_Key = [NSString stringWithFormat:@"DefaultChannelId_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSString *str_DefaultChannelId = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
    if( str_DefaultChannelId && str_DefaultChannelId.length > 0 )
    {
        [dicM_Params setObject:str_DefaultChannelId forKey:@"managerChannelId"];
    }

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/send/share/message/channel/member"
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
                                                UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                                                [window makeToast:@"공유했습니다" withPosition:kPositionBottom];
//                                                [SendBird sendMessage:@"dashBoardUpdate" withData:@"공유"];
                                                
                                                if( self.completionBlock )
                                                {
                                                    self.completionBlock(nil);
                                                }
                                                else
                                                {
                                                    [self.navigationController popViewControllerAnimated:YES];
                                                }

                                                [self.navigationController popViewControllerAnimated:YES];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                        
                                        self.btn_RightNaviItem.userInteractionEnabled = YES;
                                    }];

}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self goSendShared:nil];
    return YES;
}

@end
