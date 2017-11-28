//
//  LoginViewController.m
//  ThoTing
//
//  Created by KimYoung-Min on 2016. 6. 8..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "LoginViewController.h"
#import "InputUserInfoViewController.h"
#import "JoinWebViewController.h"
#import "UnderLineButton.h"

@interface LoginViewController () <UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UITextField *tf_Id;
@property (nonatomic, weak) IBOutlet UITextField *tf_Pw;
@property (nonatomic, weak) IBOutlet UIView *v_Join;
@property (nonatomic, weak) IBOutlet UIView *v_Login;

//가입
@property (nonatomic, weak) IBOutlet UITextField *tf_Name;
@property (nonatomic, weak) IBOutlet UITextField *tf_Email;
@property (nonatomic, weak) IBOutlet UITextField *tf_Password;
@property (nonatomic, weak) IBOutlet UnderLineButton *btn_Clause;
@property (nonatomic, weak) IBOutlet UIButton *btn_Join;
@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

#ifdef DEBUG
    self.tf_Id.text = @"ss2@t.com";
//    self.tf_Id.text = @"teacher1@thoting.com";
//    self.tf_Id.text = @"student1@thoting.com";
//    self.tf_Id.text = @"ymtest28@t.com";
//    self.tf_Id.text = @"ymtest28@t.com";
//    self.tf_Id.text = @"ym1@t.com";
    self.tf_Pw.text = @"12341234";
    
    self.tf_Name.text = @"김영민";
    self.tf_Email.text = @"ss32@t.com";
    self.tf_Password.text = @"12341234";
#endif
    
    NSString *str_UserEmail = [[NSUserDefaults standardUserDefaults] objectForKey:@"UserEmail"];
    if( str_UserEmail && str_UserEmail.length > 0 )
    {
        self.tf_Id.text = str_UserEmail;
    }

    [self addTabGesture];
    
    [self.btn_Clause addUnderLine];
    
    self.btn_Join.layer.cornerRadius = 5.f;
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

- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
{
//    self.tf_Id.text
//    self.tf_Pw.text
    
    return YES;
}


- (void)loginWithBack:(BOOL)isBack
{
    if( self.tf_Id.text.length <= 0 || self.tf_Pw.text.length <= 0 )
    {
        return;
    }
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        self.tf_Id.text, @"email",
                                        self.tf_Pw.text, @"password",
                                        [Util getUUID], @"uuid",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/signin"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        //#ifdef DEBUG
                                        //                                        [[NSUserDefaults standardUserDefaults] setObject:[resulte objectForKey:@"secretKey"] forKey:@"secretKey"];
                                        //                                        [[NSUserDefaults standardUserDefaults] synchronize];
                                        //
                                        //                                        UIViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"MainViewController"];
                                        //                                        [self.navigationController pushViewController:vc animated:YES];
                                        //                                        return ;
                                        //#endif
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                NSDictionary *dic = [resulte objectForKey:@"result"];
                                                [[NSUserDefaults standardUserDefaults] setObject:[resulte objectForKey:@"userImg_prefix"] forKey:@"userImg_prefix"];
                                                [[NSUserDefaults standardUserDefaults] setObject:[resulte objectForKey:@"apiToken"] forKey:@"apiToken"];
                                                [[NSUserDefaults standardUserDefaults] setObject:[resulte objectForKey:@"secretKey"] forKey:@"secretKey"];
                                                [[NSUserDefaults standardUserDefaults] setObject:self.tf_Id.text forKey:@"email"];
                                                [[NSUserDefaults standardUserDefaults] setObject:self.tf_Pw.text forKey:@"password"];
                                                [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey:@"userId"] forKey:@"userId"];
                                                [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey:@"userName"] forKey:@"userName"];
                                                [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey:@"userRole"] forKey:@"userRole"];
                                                [[NSUserDefaults standardUserDefaults] setObject:[resulte objectForKey:@"hashtagStr"] forKey:@"hashtagStr"];
                                                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", [resulte objectForKey:@"hashtagChannelId"]] forKey:@"hashtagChannelId"];
                                                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", [resulte objectForKey:@"channelHashTag"]] forKey:@"channelHashTag"];

                                                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld",
                                                                                                  [[dic objectForKey:@"userSchoolId"] integerValue]] forKey:@"userSchoolId"];
                                                
//                                                NSArray *ar = [resulte objectForKey:@"followChannelInfo"];
//                                                for( NSInteger i = 0; i < ar.count; i++ )
//                                                {
//                                                    NSDictionary *dic = [ar objectAtIndex:i];
//                                                    
//                                                }
                                                
                                                NSData *followChannelData = [NSKeyedArchiver archivedDataWithRootObject:[resulte objectForKey:@"followChannelInfo"]];
                                                [[NSUserDefaults standardUserDefaults] setObject:followChannelData forKey:@"followChannelInfo"];
//                                                [[NSUserDefaults standardUserDefaults] setObject:[dic objectForKey:@"userPic"] forKey:@"userPic"];
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
                                                    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:YES] forKey:@"IsLogin"];
                                                    [[NSUserDefaults standardUserDefaults] setObject:self.tf_Id.text forKey:@"UserEmail"];
                                                    [[NSUserDefaults standardUserDefaults] synchronize];
                                                    
                                                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                                    [appDelegate showMainView];
                                                }
                                                else
                                                {
                                                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
                                                    InputUserInfoViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"InputUserInfoViewController"];
                                                    vc.isBack = isBack;
                                                    [self.navigationController pushViewController:vc animated:YES];
                                                }
                                                
                                                NSString *str_UserId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
                                                NSString *str_UserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
//                                                [SendBird loginWithUserId:str_UserId andUserName:str_UserName andUserImageUrl:nil andAccessToken:kSendBirdApiToken];
                                                [SBDMain connectWithUserId:str_UserId accessToken:kSendBirdApiToken completionHandler:^(SBDUser * _Nullable user, SBDError * _Nullable error) {
                                                    
                                                    if( error == nil )
                                                    {
                                                        [SBDMain registerDevicePushToken:[SBDMain getPendingPushToken] unique:YES completionHandler:^(SBDPushTokenRegistrationStatus status, SBDError * _Nullable error) {
                                                            
                                                        }];

                                                        SBDUser *user = [SBDMain getCurrentUser];
                                                        NSLog(@"%@", user.profileUrl);
                                                        
                                                        [[NSUserDefaults standardUserDefaults] setObject:user.profileUrl forKey:@"userPic"];
                                                        [[NSUserDefaults standardUserDefaults] synchronize];

                                                        [SBDMain updateCurrentUserInfoWithNickname:user.nickname
                                                                                        profileUrl:user.profileUrl
                                                                                 completionHandler:^(SBDError * _Nullable error) {

                                                                                 }];
                                                    }
                                                }];

                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                        else
                                        {
                                            [self.navigationController.view makeToast:@"이메일 또는 비밀번호가 잘못되었습니다" withPosition:kPositionCenter];
                                        }
                                    }];
}


#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if( textField == self.tf_Id )
    {
        [self.tf_Pw becomeFirstResponder];
    }
    else if( textField == self.tf_Pw )
    {
        [self loginWithBack:YES];
    }
    else if( textField == self.tf_Name )
    {
        [self.tf_Email becomeFirstResponder];
    }
    else if( textField == self.tf_Email )
    {
        [self.tf_Password becomeFirstResponder];
    }
    else if( textField == self.tf_Password )
    {
        [self goJoin:nil];
    }

    return YES;
}



#pragma mark - IBAction
- (IBAction)goShowJoinView:(id)sender
{
//    JoinWebViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"JoinWebViewController"];
//    [self presentViewController:vc animated:YES completion:^{
//        
//    }];
    self.v_Join.hidden = NO;
    self.v_Login.hidden = YES;
}

- (IBAction)goshowLoginView:(id)sender
{
    self.v_Join.hidden = YES;
    self.v_Login.hidden = NO;
}

- (IBAction)goFindPw:(id)sender
{
    //비밀번호 리셋
    UIAlertController *alertController = [UIAlertController
                                          alertControllerWithTitle:@"비밀번호 초기화"
                                          message:@"회원가입시 입력한 이메일 주소를 사용해서\n비밀번호를 재설정할 수 있도록\n메일을 보내드립니다."
                                          preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField *textField)
     {
         textField.placeholder = @"이메일 입력";
     }];
    
    UIAlertAction *okAction = [UIAlertAction
                               actionWithTitle:NSLocalizedString(@"OK", @"OK action")
                               style:UIAlertActionStyleDefault
                               handler:^(UIAlertAction *action)
                               {
                                   UITextField *tf_Email = alertController.textFields.firstObject;

                                   if( tf_Email.text.length > 0 )
                                   {
                                       NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                           tf_Email.text, @"userEmail",
                                                                           nil];
                                       
                                       [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/forgot/password"
                                                                           param:dicM_Params
                                                                      withMethod:@"POST"
                                                                       withBlock:^(id resulte, NSError *error) {
                                                                           
                                                                           if( resulte )
                                                                           {
                                                                               NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                                               if( nCode == 200 )
                                                                               {
                                                                                   [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                                               }
                                                                               else
                                                                               {
                                                                                   [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                                               }
                                                                           }
                                                                       }];
                                   }
                               }];
    
    UIAlertAction *cancelAction = [UIAlertAction
                                   actionWithTitle:NSLocalizedString(@"Cancel", @"Cancel action")
                                   style:UIAlertActionStyleCancel
                                   handler:^(UIAlertAction *action)
                                   {
                                       NSLog(@"Cancel action");
                                   }];

    [alertController addAction:okAction];
    [alertController addAction:cancelAction];

    [self presentViewController:alertController animated:YES completion:nil];
}


- (IBAction)goLogin:(id)sender
{
    [self loginWithBack:YES];
}


- (IBAction)goShowClause:(id)sender
{
    
}

- (IBAction)goJoin:(id)sender
{
    if( self.tf_Name.text.length <= 0 )
    {
        [self.navigationController.view makeToast:@"사용자명을 입력해 주세요" withPosition:kPositionCenter];
        return;
    }
    else if( self.tf_Email.text.length <= 0 )
    {
        [self.navigationController.view makeToast:@"이메일 주소를 입력해 주세요" withPosition:kPositionCenter];
        return;
    }
    else if( self.tf_Password.text.length <= 0 )
    {
        [self.navigationController.view makeToast:@"비밀번호를 입력해 주세요" withPosition:kPositionCenter];
        return;
    }
    
    self.view.userInteractionEnabled = NO;
    [self.view endEditing:YES];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [Util getUUID], @"uuid",
                                        self.tf_Name.text, @"userName",
                                        self.tf_Email.text, @"userEmail",
                                        self.tf_Password.text, @"userPassword",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/signup/user"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                self.tf_Id.text = self.tf_Email.text;
                                                
                                                [[NSUserDefaults standardUserDefaults] setObject:self.tf_Email.text forKey:@"UserEmail"];
                                                [[NSUserDefaults standardUserDefaults] synchronize];
                                                
                                                [self.navigationController.view makeToast:@"회원가입 되었습니다\n로그인 해주세요" withPosition:kPositionCenter];
                                                
                                                self.tf_Name.text = self.tf_Email.text = self.tf_Password.text = @"";
                                                self.v_Join.hidden = YES;
                                                self.v_Login.hidden = NO;

//                                                [self loginWithBack:NO];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                        
                                        self.view.userInteractionEnabled = YES;
                                    }];
}

@end
