//
//  ChangePwViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 8. 19..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//


//패스워드 변경은 https://sites.google.com/site/thotingapi/api/api-jeong-ui/api-list/paeseuwodeubyeongyeongapi2

#import "ChangePwViewController.h"

@interface ChangePwViewController () <UITextFieldDelegate>
@property (nonatomic, weak) IBOutlet UITextField *tf_OldPw;
@property (nonatomic, weak) IBOutlet UITextField *tf_NewPw;
@property (nonatomic, weak) IBOutlet UITextField *tf_NewPwConfirm;
@end

@implementation ChangePwViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    if( textField == self.tf_OldPw )
    {
        [self.tf_NewPw becomeFirstResponder];
    }
    else if( textField == self.tf_NewPw )
    {
        [self.tf_NewPwConfirm becomeFirstResponder];
    }
    else if( textField == self.tf_NewPwConfirm )
    {
        [self goDone:nil];
    }
    
    return YES;
}


- (IBAction)goDone:(id)sender
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];

    if( self.tf_OldPw.text.length <= 0 )
    {
        [window makeToast:@"현재 비밀번호를 입력해 주세요" withPosition:kPositionCenter];
        return;
    }
    
    if( self.tf_NewPw.text.length <= 0 )
    {
        [window makeToast:@"새 비밀번호를 입력해 주세요" withPosition:kPositionCenter];
        return;
    }

    if( self.tf_NewPwConfirm.text.length <= 0 )
    {
        [window makeToast:@"새 비밀번호 확인을 입력해 주세요" withPosition:kPositionCenter];
        return;
    }
    
    if( [self.tf_NewPw.text isEqualToString:self.tf_NewPwConfirm.text] == NO )
    {
        [window makeToast:@"변경할 비밀번호가 일치하지 않습니다" withPosition:kPositionCenter];
        return;
    }
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.tf_NewPw.text, @"newPassword",
                                        self.tf_OldPw.text, @"oldPassword",
                                        self.tf_NewPwConfirm.text, @"confirmPassword",
                                        nil];
//    [dicM_Params setObject:self.tf_NewPw.text forKey:@"newPassword"];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"/v1/change/my/confirm/password"
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
                                                [window makeToast:@"비밀번호가 변경 되었습니다" withPosition:kPositionCenter];
                                                [self dismissViewControllerAnimated:YES completion:^{
                                                    
                                                }];
                                            }
                                            else
                                            {
                                                [window makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

@end
