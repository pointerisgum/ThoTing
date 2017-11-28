//
//  MyAccountViewController.m
//  ThoThing
//
//  Created by macpro15 on 2017. 11. 20..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "MyAccountViewController.h"
#import "NameChangeViewController.h"
#import "EmailChangeViewController.h"
#import "ChangePwStep1ViewController.h"
//#import "ChangePwStep2ViewController.h"

@interface MyAccountViewController ()
@property (nonatomic, weak) IBOutlet UILabel *lb_UserName;
@property (nonatomic, weak) IBOutlet UILabel *lb_Email;
@end

@implementation MyAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    SBDUser *user = [SBDMain getCurrentUser];
    self.lb_UserName.text = user.nickname;
    self.lb_Email.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"email"];
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

- (IBAction)goNamechange:(id)sender
{
    UIViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"NameChangeViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goEmailChange:(id)sender
{
    UIViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"EmailChangeViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goChangePw:(id)sender
{
    UIViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"ChangePwStep1ViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goLogOut:(id)sender
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

@end
