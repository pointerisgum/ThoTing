//
//  QuestionPauseViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 5. 17..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "QuestionPauseViewController.h"

@interface QuestionPauseViewController ()
@property (nonatomic, weak) IBOutlet UIView *v_Pause;
@property (nonatomic, weak) IBOutlet UILabel *lb_CurrentQ;
@property (nonatomic, weak) IBOutlet UILabel *lb_TotalQ;
@property (nonatomic, weak) IBOutlet UIButton *btn_Time;
@end

@implementation QuestionPauseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.v_Pause.layer.cornerRadius = 20.f;
    self.v_Pause.layer.borderWidth = 1.f;
    self.v_Pause.layer.borderColor = [UIColor whiteColor].CGColor;
    
    NSInteger nSecond = self.nTime % 60;
    NSInteger nMinute = self.nTime / 60;
    [self.btn_Time setTitle:[NSString stringWithFormat:@"%02ld:%02ld", nMinute, nSecond] forState:UIControlStateNormal];

    self.lb_CurrentQ.text = self.str_CurrentQ;
    self.lb_TotalQ.text = self.str_TotalQ;

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

- (IBAction)goClose:(id)sender
{
    if( self.completionBlock )
    {
        self.completionBlock(nil);
    }
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
