//
//  InitViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 6. 22..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "InitViewController.h"
#import "AppDelegate.h"

@interface InitViewController ()

@end

@implementation InitViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self login];
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

- (void)login
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
                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                
                                                [Common registToken];
                                                [Common logUser];

                                                NSInteger nSchooldId = [[dic objectForKey:@"userSchoolId"] integerValue];
                                                id Aff = [dic objectForKey:@"userAffiliation"];
                                                NSString *str_Affiliation = @"";
                                                if( [Aff isEqual:[NSNull null]] )
                                                {
                                                    str_Affiliation = @"";
                                                }
                                                else
                                                {
                                                    str_Affiliation = Aff;
                                                }
                                                
                                                if( nSchooldId > 0 || str_Affiliation.length > 0 )
                                                {
                                                    UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
                                                    [self.navigationController pushViewController:vc animated:YES];
                                                }
                                                else
                                                {
                                                    
                                                }
                                                
                                                NSString *str_UserId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
                                                NSString *str_UserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
//                                                [SendBird loginWithUserId:str_UserId andUserName:str_UserName andUserImageUrl:nil andAccessToken:kSendBirdApiToken];
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

                                            }
                                            else
                                            {
                                                //로그인 정보가 이상할시 다시 로그인 화면으로 백
                                                AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                                [appDelegate showLoginView];
                                                
                                                ALERT(nil, @"로그인 정보가 잘못되었습니다\n다시 로그인해 주세요", nil, @"확인", nil);
                                            }


                                        }
                                    }];
}

@end
