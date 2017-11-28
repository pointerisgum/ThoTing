//
//  ChangePwStep1ViewController.m
//  ThoThing
//
//  Created by macpro15 on 2017. 11. 20..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "ChangePwStep1ViewController.h"
#import "ChangePwStep2ViewController.h"

@interface ChangePwStep1ViewController ()
@property (nonatomic, weak) IBOutlet UIButton *btn_Next;
@property (nonatomic, weak) IBOutlet UITextField *tf_Pw;
@end

@implementation ChangePwStep1ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tf_Pw.text = @"";
    
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
    NSString *str_Pw = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    if( [str_Pw isEqualToString:self.tf_Pw.text] )
    {
        self.btn_Next.selected = YES;
    }
    else
    {
        self.btn_Next.selected = NO;
    }
    
    if( self.tf_Pw.text.length <= 0 )
    {
        self.btn_Next.selected = NO;
    }
}


- (IBAction)goNext:(id)sender
{
    __weak __typeof(&*self)weakSelf = self;

    NSString *str_Pw = [[NSUserDefaults standardUserDefaults] objectForKey:@"password"];
    if( [str_Pw isEqualToString:self.tf_Pw.text] )
    {
        //다음
        ChangePwStep2ViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"ChangePwStep2ViewController"];
        [vc setCompletionBlock:^(id completeResult) {
           
            [weakSelf.navigationController popViewControllerAnimated:YES];
        }];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        [Util showToast:@"비밀번호가 일치하지 않습니다"];
    }
}

@end
