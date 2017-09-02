//
//  InputUserInfo2ViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 25..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "InputUserInfo2ViewController.h"

@interface InputUserInfo2ViewController ()
@property (nonatomic, weak) IBOutlet UITextField *tf;
@property (nonatomic, weak) IBOutlet UIButton *btn_NotStudent;
@end

@implementation InputUserInfo2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if( self.isProfileMode )
    {
        self.tf.text = self.str_Affiliation;
    }
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


- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self goAdd:nil];
    
    return YES;
}


- (IBAction)goAdd:(id)sender
{
    if( self.tf.text.length > 0 )
    {
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"], @"userName",
                                            self.tf.text, @"userAffiliation",
//                                            @"", @"userDesc",
                                            nil];
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/change/my/profile"
                                            param:dicM_Params
                                       withMethod:@"POST"
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            if( resulte )
                                            {
                                                NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                if( nCode == 200 )
                                                {
                                                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"IsLogin"];
                                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                                    
                                                    if( self.isProfileMode )
                                                    {
                                                        [self dismissViewControllerAnimated:NO completion:^{
                                                            
                                                            [[NSNotificationCenter defaultCenter] postNotificationName:@"ModalBackNoti" object:nil userInfo:nil];
                                                        }];
                                                    }
                                                    else
                                                    {
                                                        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"email"], @"email",
                                                                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"password"], @"password",
                                                                                            [Util getUUID], @"uuid",
                                                                                            nil];
                                                        
                                                        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/signin"
                                                                                            param:dicM_Params
                                                                                       withMethod:@"GET"
                                                                                        withBlock:^(id resulte, NSError *error) {
                                                                                            
                                                                                            if( resulte )
                                                                                            {
                                                                                                NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                                                                if( nCode == 200 )
                                                                                                {
                                                                                                    NSDictionary *dic = [resulte objectForKey:@"result"];
                                                                                                    [[NSUserDefaults standardUserDefaults] setObject:[resulte objectForKey:@"apiToken"] forKey:@"apiToken"];
                                                                                                    [[NSUserDefaults standardUserDefaults] setObject:[resulte objectForKey:@"secretKey"] forKey:@"secretKey"];
                                                                                                    [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey:@"userId"] forKey:@"userId"];
                                                                                                    [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey:@"userName"] forKey:@"userName"];
                                                                                                    [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey:@"userRole"] forKey:@"userRole"];
                                                                                                    [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld",
                                                                                                                                                      [[dic objectForKey:@"userSchoolId"] integerValue]] forKey:@"userSchoolId"];
                                                                                                    
                                                                                                    NSData *followChannelData = [NSKeyedArchiver archivedDataWithRootObject:[resulte objectForKey:@"followChannelInfo"]];
                                                                                                    [[NSUserDefaults standardUserDefaults] setObject:followChannelData forKey:@"followChannelInfo"];
                                                                                                    [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey:@"userPic"] forKey:@"userPic"];
                                                                                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                                                                                    
                                                                                                    [Common registToken];
                                                                                                    [Common logUser];
                                                                                                    
                                                                                                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"IsLogin"];
                                                                                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                                                                                    
                                                                                                    NSString *str_UserId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
                                                                                                    NSString *str_UserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
//                                                                                                    [SendBird loginWithUserId:str_UserId andUserName:str_UserName andUserImageUrl:nil andAccessToken:kSendBirdApiToken];

                                                                                                    [SBDMain connectWithUserId:str_UserId accessToken:kSendBirdApiToken completionHandler:^(SBDUser * _Nullable user, SBDError * _Nullable error) {
                                                                                                        
                                                                                                        if( error == nil )
                                                                                                        {
                                                                                                            [SBDMain registerDevicePushToken:[SBDMain getPendingPushToken] unique:YES completionHandler:^(SBDPushTokenRegistrationStatus status, SBDError * _Nullable error) {
                                                                                                                
                                                                                                            }];

                                                                                                            [SBDMain updateCurrentUserInfoWithNickname:str_UserName
                                                                                                                                            profileUrl:[[NSUserDefaults standardUserDefaults] objectForKey:@"userPic"]
                                                                                                                                     completionHandler:^(SBDError * _Nullable error) {
                                                                                                                                         
                                                                                                                                     }];
                                                                                                        }
                                                                                                    }];

                                                                                                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                                                                                    [appDelegate showMainView];
                                                                                                }
                                                                                                else
                                                                                                {
//                                                                                                    //로그인 정보가 이상할시 다시 로그인 화면으로 백
//                                                                                                    [self showLoginView];
//                                                                                                    
//                                                                                                    ALERT(nil, @"로그인 정보가 잘못되었습니다\n다시 로그인해 주세요", nil, @"확인", nil);
                                                                                                }
                                                                                                
                                                                                            }
                                                                                            else
                                                                                            {
                                                                                                //로그인 정보가 이상할시 다시 로그인 화면으로 백
                                                                                                ALERT(nil, @"정보가 잘못되었습니다", nil, @"확인", nil);
//                                                                                                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
//                                                                                                self.window.rootViewController = self.loginNavi;
                                                                                            }
                                                                                        }];
                                                    }
                                                }
                                                else
                                                {
                                                    [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                }
                                            }
                                        }];
    }
}

- (IBAction)goBack:(id)sender
{
    if( self.isProfileMode )
    {
        [self dismissViewControllerAnimated:NO completion:^{
            
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ModalBackNoti" object:nil userInfo:nil];            
        }];
    }
    else
    {
        [self.navigationController popToRootViewControllerAnimated:YES];
//        [super goBack:sender];
    }
}

- (IBAction)goNotStudent:(id)sender
{
    if( self.isProfileMode )
    {
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:NO];
    }
}

@end
