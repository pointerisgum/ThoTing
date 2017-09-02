//
//  ChannelSideMenuViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 4. 14..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "ChannelSideMenuViewController.h"

@interface ChannelSideMenuCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UIImageView *iv_UnderLine;
@end

@implementation ChannelSideMenuCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}
- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end


@interface ChannelSideMenuViewController ()
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_SideMenuX;
@property (nonatomic, weak) IBOutlet UILabel *lb_UserName;
@property (nonatomic, weak) IBOutlet UILabel *lb_HashTag;
@end

@implementation ChannelSideMenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.lb_UserName.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    self.lb_HashTag.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"hashtagStr"];
    
    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.width / 2;
    self.iv_User.layer.borderColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1].CGColor;
    self.iv_User.layer.borderWidth = 1.f;

    NSString *str_Url = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPic"];
    [self.iv_User sd_setImageWithURL:[NSURL URLWithString:str_Url]];
    
    self.arM_List = [NSMutableArray array];
    [self.arM_List addObject:@"팔로워 팔로우"];       //1
//    [self.arM_List addObject:@"영동고/회원"];        //2
//    [self.arM_List addObject:@"풀고 있는 문제들"];     //3
    [self.arM_List addObject:@"피드"];                //4
//    [self.arM_List addObject:@"공유"];                //5
    [self.arM_List addObject:@"라이브러리"];             //6
//    [self.arM_List addObject:@"올린문제"];              //7
    [self.arM_List addObject:@"레포트"];               //8
    [self.arM_List addObject:@"오답,별표"];             //9
    [self.arM_List addObject:@"설정"];                //10
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.lc_SideMenuX.constant = 0;
    [self.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.view layoutIfNeeded];
    }];
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


#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arM_List.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"ChannelSideMenuCell";
    ChannelSideMenuCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
//    cell.iv_UnderLine.hidden = YES;
    
    cell.lb_Title.text = self.arM_List[indexPath.row];
    
//    if( indexPath.row == 1 )
//    {
//        cell.iv_UnderLine.hidden = NO;
//    }
//    else if( indexPath.row == 2 )
//    {
//        cell.iv_UnderLine.hidden = NO;
//    }
//    else if( indexPath.row == 8 )
//    {
//        cell.iv_UnderLine.hidden = NO;
//    }
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //여기
    return;
//    if( indexPath.row != 10 )
//    {
//        NSString *str_Key = [NSString stringWithFormat:@"MainSideIdx_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
//        [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%ld", indexPath.row + 1] forKey:str_Key];
//        [[NSUserDefaults standardUserDefaults] synchronize];
//        
//        [self.tbv_List reloadData];
//    }
    
    [self closeMenu];
    
    
    
    //여기 는 잠깐 노란색으로 보여줬다 사라지게 하는 코드
    NSString *str_Title = self.arM_List[indexPath.row];
    
    ChannelSideMenuCell *cell = (ChannelSideMenuCell *)[tableView cellForRowAtIndexPath:indexPath];
    cell.lb_Title.backgroundColor = [UIColor yellowColor];
    [self performSelector:@selector(onDelayClose) withObject:str_Title afterDelay:0.5f];
    
    if( self.completionBlock )
    {
        self.completionBlock(str_Title);
    }
}

- (void)onDelayClose
{
    [self closeMenu];
}

#pragma mark - IBAction
- (void)closeMenu
{
    self.lc_SideMenuX.constant = -self.view.bounds.size.width;
    [self.view setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.25f animations:^{
        [self.view layoutIfNeeded];
    }completion:^(BOOL finished) {
        
        [self dismissViewControllerAnimated:NO completion:^{
            
        }];
    }];
}

- (IBAction)goCloseMenu:(id)sender
{
    [self closeMenu];
}

@end
