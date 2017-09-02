//
//  InputUserInfoViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 11..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "InputUserInfoViewController.h"
#import "SelectSchoolViewController.h"
#import "ActionSheetStringPicker.h"
#import "InputUserInfo2ViewController.h"

@interface InputUserInfoViewController ()
{
    NSString *str_Affiliation;
}
@property (nonatomic, strong) NSDictionary *dic_SchoolInfo;
@property (nonatomic, assign) NSInteger nSchoolLevel;

@property (nonatomic, weak) IBOutlet UITextField *tf_School;
@property (nonatomic, weak) IBOutlet UITextField *tf_SchoolLevel;
@property (nonatomic, weak) IBOutlet UIButton *btn_Add;
@property (nonatomic, weak) IBOutlet UIButton *btn_TopAdd;
@end

@implementation InputUserInfoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if( self.isBack == NO )
    {
        //백버튼 지우기 (회원가입에서 타고 들어왔을 시)
        
    }
    self.btn_Add.layer.cornerRadius = 8.f;
    self.btn_Add.layer.borderColor = kMainColor.CGColor;
    self.btn_Add.layer.borderWidth = 1.f;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(modalBackNoti) name:@"ModalBackNoti" object:nil];
    
    if( self.isProfileMode )
    {
        self.view.hidden = YES;
        
        self.btn_TopAdd.hidden = YES;
        
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            nil];
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/profile"
                                            param:dicM_Params
                                       withMethod:@"GET"
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            if( resulte )
                                            {
                                                NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                if( nCode == 200 )
                                                {
                                                    self.nSchoolLevel = [[resulte objectForKey:@"userPersonGrade"] integerValue];
                                                    self.dic_SchoolInfo = @{@"schoolName":[resulte objectForKey:@"userSchoolName"],
                                                                            @"schoolGrade":[resulte objectForKey:@"userSchoolGrade"],
                                                                            @"schoolId":[NSString stringWithFormat:@"%ld", [[resulte objectForKey:@"userSchoolId"] integerValue]]};
                                                    
                                                    str_Affiliation = [resulte objectForKey:@"userAffiliation"];
                                                    
                                                    NSLog(@"%@", self.dic_SchoolInfo.allKeys);
                                                    
                                                    self.tf_School.text = [self.dic_SchoolInfo objectForKey:@"schoolName"];
                                                    if( self.nSchoolLevel > 0 )
                                                    {
                                                        self.tf_SchoolLevel.text = [NSString stringWithFormat:@"%ld학년", self.nSchoolLevel];
                                                    }
                                                }
                                            }
                                            
                                            if( self.isProfileMode && self.isNotStudent )
                                            {
                                                self.isNotStudent = NO;
                                                
                                                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
                                                InputUserInfo2ViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"InputUserInfo2ViewController"];
                                                vc.isProfileMode = self.isProfileMode;
                                                vc.str_Affiliation = str_Affiliation;
                                                [self presentViewController:vc animated:NO completion:^{
                                                    
                                                }];
                                            }
                                            
                                            self.view.hidden = NO;
                                        }];
    }
}

//- (void)viewWillAppear:(BOOL)animated
//{
//    [super viewWillAppear: animated];
//    
//    if( self.isProfileMode && self.isNotStudent )
//    {
//        self.isNotStudent = NO;
//        
//        InputUserInfo2ViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"InputUserInfo2ViewController"];
//        vc.isProfileMode = self.isProfileMode;
//        vc.str_Affiliation = str_Affiliation;
//        [self presentViewController:vc animated:NO completion:^{
//            
//        }];
//    }
//}

- (void)modalBackNoti
{
    [self dismissViewControllerAnimated:NO completion:^{
        
    }];
}

- (IBAction)goBack:(id)sender
{
    if( self.isProfileMode )
    {
        [self dismissViewControllerAnimated:YES completion:^{
            
        }];
    }
    else
    {
        [super goBack:sender];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    
    InputUserInfo2ViewController *vc = [segue destinationViewController];
    vc.isProfileMode = self.isProfileMode;
    vc.str_Affiliation = str_Affiliation;
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if( textField == self.tf_School )
    {
        [self.view endEditing:YES];
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
        SelectSchoolViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SelectSchoolViewController"];
        [vc setCompletionBlock:^(id completeResult) {
            
            self.dic_SchoolInfo = [NSDictionary dictionaryWithDictionary:completeResult];
            self.tf_School.text = [self.dic_SchoolInfo objectForKey:@"schoolName"];
            
            self.nSchoolLevel = -1;
            self.tf_SchoolLevel.text = @"";

        }];
        
        [self presentViewController:vc animated:YES completion:^{
            
        }];
        
        return NO;
    }
    else if( textField == self.tf_SchoolLevel )
    {
        [self.view endEditing:YES];
        
        if( self.dic_SchoolInfo == nil )
        {
            [self.navigationController.view makeToast:@"학교를 선택해 주세요" withPosition:kPositionCenter];
            return NO;
        }
        
        ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            
            self.nSchoolLevel = selectedIndex + 1;
            self.tf_SchoolLevel.text = selectedValue;
            
        };
        ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
            NSLog(@"Block Picker Canceled");
        };
        
        /*
         schoolAddress = "\Uacbd\Uae30 \Uc218\Uc6d0\Uc2dc \Ud314\Ub2ec\Uad6c \Uc6b0\Ub9cc\Ub3d971\Ubc88\Uc9c0";
         schoolGrade = "\Uace0\Ub4f1\Ud559\Uad50";
         schoolId = 9104;
         schoolName = "\Uc720\Uc2e0\Uace0\Ub4f1\Ud559\Uad50";
         schoolRegion = "\Uacbd\Uae30";
         */
        NSArray *colors = nil;
        NSString *str_Grade = [self.dic_SchoolInfo objectForKey:@"schoolGrade"];
        if( [str_Grade isEqualToString:@"중학교"] )
        {
            colors = @[@"1학년", @"2학년", @"3학년"];
        }
        else if( [str_Grade isEqualToString:@"고등학교"] )
        {
            colors = @[@"1학년", @"2학년", @"3학년"];
        }
        else
        {
            colors = @[@"1학년", @"2학년", @"3학년", @"4학년", @"5학년", @"6학년"];
        }
        
        [ActionSheetStringPicker showPickerWithTitle:@"학년선택" rows:colors initialSelection:0 doneBlock:done cancelBlock:cancel origin:self.view];
        
        return NO;
    }
//    else if( textField == self.tf_SubTitle )
//    {
//        [self.view endEditing:YES];
//        
//        __block NSArray *colors = @[@"국어", @"영어", @"수학", @"과학", @"미술", @"체육", @"직접입력"];
//        
//        ActionStringDoneBlock done = ^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
//            
//            if( selectedIndex == colors.count - 1 )
//            {
//                //마지막 오브젝트면 직접입력
//                InputSubjectViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"InputSubjectViewController"];
//                [vc setCompletionBlock:^(id completeResult) {
//                    
//                    self.tf_SubTitle.text = completeResult;
//                }];
//                
//                [self presentViewController:vc animated:YES completion:^{
//                    
//                }];
//            }
//            else
//            {
//                self.tf_SubTitle.text = selectedValue;
//            }
//        };
//        ActionStringCancelBlock cancel = ^(ActionSheetStringPicker *picker) {
//            NSLog(@"Block Picker Canceled");
//        };
//        
//        
//        [ActionSheetStringPicker showPickerWithTitle:@"과목선택" rows:colors initialSelection:0 doneBlock:done cancelBlock:cancel origin:self.view];
//        
//        return NO;
//    }
    
    return YES;
}



- (IBAction)goAdd:(id)sender
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if( self.tf_School.text.length <= 0 )
    {
        [window makeToast:@"학교를 입력해 주세요" withPosition:kPositionCenter];
        return;
    }
    
    if( self.tf_SchoolLevel.text.length <= 0 )
    {
        [window makeToast:@"학년을 입력해 주세요" withPosition:kPositionCenter];
        return;
    }

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%ld", [[self.dic_SchoolInfo objectForKey:@"schoolId"] integerValue]], @"schoolId",
                                        [NSString stringWithFormat:@"%ld", self.nSchoolLevel], @"personGrade",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/change/my/school/info"
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
                                                    [self dismissViewControllerAnimated:YES completion:^{
                                                        
                                                    }];
                                                }
                                                else
                                                {
                                                    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                                                    [appDelegate showMainView];
                                                }
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

@end
