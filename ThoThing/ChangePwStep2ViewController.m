//
//  ChangePwStep2ViewController.m
//  ThoThing
//
//  Created by macpro15 on 2017. 11. 20..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "ChangePwStep2ViewController.h"

@interface ChangePwStep2ViewController ()
@property (nonatomic, weak) IBOutlet UIButton *btn_Save;
@property (nonatomic, weak) IBOutlet UITextField *tf_Pw;
@property (nonatomic, weak) IBOutlet UITextField *tf_PwConfirm;
@end

@implementation ChangePwStep2ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.tf_Pw becomeFirstResponder];
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

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self performSelector:@selector(inputPw) withObject:nil afterDelay:0.1f];
    
    return YES;
}

- (void)inputPw
{
    if( self.tf_Pw.text.length <= 0 || self.tf_PwConfirm.text.length <= 0 )
    {
        self.btn_Save.selected = NO;
        return;
    }
    
    if( self.tf_Pw.text.length == self.tf_PwConfirm.text.length )
    {
        self.btn_Save.selected = YES;
    }
    else
    {
        self.btn_Save.selected = NO;
    }
}


- (IBAction)goSave:(id)sender
{
    if( self.tf_Pw.text.length <= 0 || self.tf_PwConfirm.text.length <= 0 )
    {
        return;
    }
    
    if( [self.tf_Pw.text isEqualToString:self.tf_PwConfirm.text] )
    {
        __block NSString *str_Pw = self.tf_Pw.text;
        NSString *str_OldPw = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];

        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            self.tf_Pw.text, @"newPassword",
                                            str_OldPw, @"oldPassword",
                                            self.tf_PwConfirm.text, @"confirmPassword",
                                            nil];
        
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
                                                    [[NSUserDefaults standardUserDefaults] setObject:str_Pw forKey:@"password"];
                                                    [[NSUserDefaults standardUserDefaults] synchronize];

                                                    [self.navigationController.view makeToast:@"비밀번호가 변경 되었습니다" withPosition:kPositionCenter];

                                                    [self.navigationController popViewControllerAnimated:NO];
                                                    
                                                    if( self.completionBlock )
                                                    {
                                                        self.completionBlock(nil);
                                                    }
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
        [self.navigationController.view makeToast:@"비밀번호가 일치하지 않습니다" withPosition:kPositionCenter];
    }
}

@end
