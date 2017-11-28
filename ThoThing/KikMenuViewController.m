//
//  KikMenuViewController.m
//  ThoThing
//
//  Created by macpro15 on 2017. 9. 25..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "KikMenuViewController.h"

@interface KikMenuViewController ()
@property (nonatomic, weak) IBOutlet UIButton *btn_Close;
@property (nonatomic, weak) IBOutlet UIButton *btn_Chat;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ChatLeft;
@property (nonatomic, weak) IBOutlet UIButton *btn_GroupMake;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_GroupMakeLeft;
@property (nonatomic, weak) IBOutlet UIButton *btn_Groups;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_GroupsLeft;
@property (nonatomic, weak) IBOutlet UIButton *btn_Bot;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_BotLeft;

@end

@implementation KikMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setButtonLayer:self.btn_Chat];
    [self setButtonLayer:self.btn_GroupMake];
    [self setButtonLayer:self.btn_Groups];
    [self setButtonLayer:self.btn_Bot];

}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    __weak __typeof__(self) weakSelf = self;

    [UIView animateWithDuration:0.2f
                     animations:^{
                         weakSelf.btn_Close.transform = CGAffineTransformMakeRotation(degreesToRadian(-45));
                     }];
    
    [self moveOnBottuon:self.lc_BotLeft];
    [self performSelector:@selector(moveOnBottuon:) withObject:self.lc_GroupsLeft afterDelay:0.05f];
    [self performSelector:@selector(moveOnBottuon:) withObject:self.lc_GroupMakeLeft afterDelay:0.1f];
    [self performSelector:@selector(moveOnBottuon:) withObject:self.lc_ChatLeft afterDelay:0.15f];
    
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

- (void)setButtonLayer:(UIButton *)btn
{
    btn.layer.cornerRadius = 24.f;
    btn.layer.borderColor = [UIColor colorWithRed:200.f/255.f green:200.f/255.f blue:200.f/255.f alpha:1].CGColor;
    btn.layer.borderWidth = 1.f;
}

- (void)moveOnBottuon:(NSLayoutConstraint *)lc
{
    __weak __typeof__(self) weakSelf = self;

    lc.constant = 30.f;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        [weakSelf.view layoutIfNeeded];
        
    }completion:^(BOOL finished) {
        
        lc.constant = 20.f;
        
        [UIView animateWithDuration:0.05f animations:^{
            
            [weakSelf.view layoutIfNeeded];
            
        }];
        
    }];
}

- (void)moveOffBottuon:(NSLayoutConstraint *)lc
{
    __weak __typeof__(self) weakSelf = self;
    
    lc.constant = -200.f;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        [weakSelf.view layoutIfNeeded];
    }];
}

- (IBAction)goDismmis:(id)sender
{
    __weak __typeof__(self) weakSelf = self;

    [UIView animateWithDuration:0.2f
                     animations:^{
                         
                         weakSelf.btn_Close.transform = CGAffineTransformMakeRotation(degreesToRadian(0));
                         
                     }completion:^(BOOL finished) {
                         
                         if( weakSelf.completionBlock )
                         {
                             weakSelf.completionBlock(nil);
                         }
                         
                         [weakSelf dismissViewControllerAnimated:YES completion:^{
                             
                             if(  weakSelf.completionMenuSelectBlock )
                             {
                                 weakSelf.completionMenuSelectBlock(weakSelf.selectType);
                             }
                         }];
                     }];
    
//    [self moveOffBottuon:self.lc_GroupsLeft];
//    [self performSelector:@selector(moveOffBottuon:) withObject:self.lc_GroupMakeLeft afterDelay:0.05f];
//    [self performSelector:@selector(moveOffBottuon:) withObject:self.lc_ChatLeft afterDelay:0.1f];
//    [self performSelector:@selector(moveOffBottuon:) withObject:self.lc_BotLeft afterDelay:0.15f];

    [self moveOffBottuon:self.lc_ChatLeft];
    [self performSelector:@selector(moveOffBottuon:) withObject:self.lc_GroupMakeLeft afterDelay:0.05f];
    [self performSelector:@selector(moveOffBottuon:) withObject:self.lc_GroupsLeft afterDelay:0.1f];
    [self performSelector:@selector(moveOffBottuon:) withObject:self.lc_BotLeft afterDelay:0.15f];

//0312285618
}

- (IBAction)goOneOnOneChat:(id)sender
{
    self.selectType = kOneOnOneChat;
    [self goDismmis:nil];
}

- (IBAction)goMakeGroup:(id)sender
{
    self.selectType = kMakeGroupChat;
    [self goDismmis:nil];
}

- (IBAction)goGroups:(id)sender
{
    self.selectType = kGroups;
    [self goDismmis:nil];
}

- (IBAction)goBot:(id)sender
{
    self.selectType = kExamBot;
    [self goDismmis:nil];
}


@end
