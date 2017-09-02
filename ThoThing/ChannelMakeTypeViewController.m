//
//  ChannelMakeTypeViewController.m
//  ThoThing
//
//  Created by macpro15 on 2017. 8. 25..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "ChannelMakeTypeViewController.h"

@interface ChannelMakeTypeViewController ()
@property (nonatomic, weak) IBOutlet UIButton *btn_1;
@property (nonatomic, weak) IBOutlet UIButton *btn_2;
@property (nonatomic, weak) IBOutlet UIButton *btn_3;
@property (nonatomic, weak) IBOutlet UIButton *btn_4;
@property (nonatomic, weak) IBOutlet UIButton *btn_5;
@end

@implementation ChannelMakeTypeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setButtonColor:self.btn_1 withHex:@"33C75A" withTitle:@"학원"];
    [self setButtonColor:self.btn_2 withHex:@"6A9EF0" withTitle:@"출판사"];
    [self setButtonColor:self.btn_3 withHex:@"FF4949" withTitle:@"공부방"];
    [self setButtonColor:self.btn_4 withHex:@"FFB241" withTitle:@"학교"];
    [self setButtonColor:self.btn_5 withHex:@"676B81" withTitle:@"기타"];

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

- (void)setButtonColor:(UIButton *)btn withHex:(NSString *)aHexColor withTitle:(NSString *)aTitle
{
    btn.layer.cornerRadius = 4.f;
    btn.layer.borderColor = [UIColor colorWithHexString:aHexColor].CGColor;
    btn.layer.borderWidth = 1.f;
    [btn setTitleColor:[UIColor colorWithHexString:aHexColor] forState:UIControlStateNormal];
    [btn setTitle:aTitle forState:UIControlStateNormal];
}

- (IBAction)goInputChannelInfo:(id)sender
{
    
}

@end
