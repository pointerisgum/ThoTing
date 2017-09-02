//
//  PauseViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 11. 9..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "PauseViewController.h"

@interface PauseViewController ()
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_StartCnt;
@property (nonatomic, weak) IBOutlet UILabel *lb_TotlaCnt;
@property (nonatomic, weak) IBOutlet UIButton *btn_Time;
@end

@implementation PauseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.btn_Time.layer.cornerRadius = 18.f;
    self.btn_Time.layer.borderColor = [UIColor whiteColor].CGColor;
    self.btn_Time.layer.borderWidth = 1.f;
    
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

- (void)updateDataWithTitle:(NSString *)aTitle withStartCnt:(NSString *)aStartCnt withTotalCnt:(NSString *)aTotalCnt withTime:(NSString *)aTime
{
    self.lb_Title.text = aTitle;
    self.lb_StartCnt.text = aStartCnt;
    self.lb_TotlaCnt.text = aTotalCnt;
    [self.btn_Time setTitle:aTime forState:UIControlStateNormal];
}

- (IBAction)goResume:(id)sender
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"removePause" object:nil];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

@end
