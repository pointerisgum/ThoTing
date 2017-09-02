//
//  NotiViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 8. 11..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "NotiViewController.h"

@interface NotiViewController ()
{
    NSInteger nId;
    NSInteger channelId;
}
@property (nonatomic, strong) NSDictionary *dic_Data;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_SubTitle;
@property (nonatomic, weak) IBOutlet UILabel *lb_Contents;
@property (nonatomic, weak) IBOutlet UIButton *btn_Yes;
@property (nonatomic, weak) IBOutlet UIButton *btn_No;
@property (nonatomic, weak) IBOutlet UIView *v_Buttons;
@end

@implementation NotiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    nId = [[self.dic_Info objectForKey:@"actionMoveId"] integerValue];
//    channelId = [[self.dic_Info objectForKey:@"feederId"] integerValue];
//    nIdx = [[self.dic_Info objectForKey:@"feederId"] integerValue];
    
    if( nId == 0 )
    {
        nId = [[self.dic_Info objectForKey:@"gcm.notification.nId"] integerValue];
        
        if( nId == 0 )
        {
            //팔로잉에서 들어왔을때
            nId = [[self.dic_Info objectForKey:@"nId"] integerValue];
        }

    }
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%ld", nId], @"nId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/noti/detail/info"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                self.lb_Title.text = [NSString stringWithFormat:@"%@ 회원 인증하기", [resulte objectForKey:@"channelName"]];
                                                self.lb_SubTitle.text = [resulte objectForKey:@"headerText"];
                                                self.lb_Contents.text = [resulte objectForKey:@"bodyText"];

                                                self.dic_Data = [NSDictionary dictionaryWithDictionary:resulte];
                                                
                                                channelId = [[resulte objectForKey:@"channelId"] integerValue];
                                            }
                                            else
                                            {
                                                UIAlertView *alert = CREATE_ALERT(nil, [resulte objectForKey:@"error_message"], @"확인", nil);
                                                [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                                                    
                                                    [self dismissViewControllerAnimated:YES completion:nil];
                                                }];
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


- (IBAction)goYes:(id)sender
{
    [self reqNoti:YES];
}

- (IBAction)goNo:(id)sender
{
    [self reqNoti:NO];
}

- (void)reqNoti:(BOOL)isYes
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%ld", channelId], @"channelId",
                                        [self.dic_Data objectForKey:@"userId"], @"userId",                         //noti를 받은 사용자 ID
                                        @"member-noti", @"notiType",            //noti 종류 [meember-noti: 회원 등록 noti]    //confirm-join
                                        isYes ? @"Y" : @"D", @"userConfirm",    //사용자 응답 [Y-수락, D-거부]
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
                                                self.v_Buttons.hidden = YES;
                                                NSString *str_Contents = self.lb_Contents.text;
                                                self.lb_Contents.text = [NSString stringWithFormat:@"%@\n\n%@", str_Contents, isYes ? @"YES" : @"NO"];
                                                
                                                [[NSNotificationCenter defaultCenter] postNotificationName:kMessageKey
                                                                                                    object:nil
                                                                                                  userInfo:nil];

//                                                [self dismissViewControllerAnimated:YES completion:^{
//                                                    
//                                                }];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

@end
