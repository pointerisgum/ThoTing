//
//  InRoomMemberListViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 9. 13..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "InRoomMemberListViewController.h"
#import "InRoomCell.h"
#import "UserPageMainViewController.h"
#import "MyMainViewController.h"

@interface InRoomMemberListViewController ()
{
    NSString *str_ImagePrefix;
    NSString *str_UserImagePrefix;
    NSString *str_NoImagePrefix;
}
@property (nonatomic, strong) NSArray *ar_List;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@end

@implementation InRoomMemberListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initNaviWithTitle:@"참여자" withLeftItem:[self leftBackBlackMenuBarButtonItem] withRightItem:nil withColor:[UIColor colorWithHexString:@"F8F8F8"]];

    [self updateList];
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

- (void)updateList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        self.str_QuestionId, @"questionId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/qna/chat/room/user/list"
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
                                                str_ImagePrefix = [resulte objectForKey:@"img_prefix"];
                                                str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
                                                str_NoImagePrefix = [resulte objectForKey:@"no_image"];

                                                self.ar_List = [NSArray arrayWithArray:[resulte objectForKey:@"userListInfos"]];
                                                NSString *str_Title = [NSString stringWithFormat:@"참여자 %ld", self.ar_List.count];
                                                [self initNaviWithTitle:str_Title withLeftItem:[self leftBackBlackMenuBarButtonItem] withRightItem:nil withColor:[UIColor colorWithHexString:@"F8F8F8"]];

                                                [self.tbv_List reloadData];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}




#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.ar_List.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InRoomCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InRoomCell"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*
     memberLevel = 9;
     url = T108160419;
     userId = 108;
     userName = "\Ud1a0\Ud305\Uc120\Uc0dd\Ub2d81";
     userThumbnail = "000/000/164aa850dc2e3c45bff40379582d642e_620.jpg";
     userType = manager;
     */
    
    cell.iv_User.tag = indexPath.row;
    
    NSDictionary *dic = self.ar_List[indexPath.row];
    
    [cell.iv_User sd_setImageWithURL:[Util createImageUrl:str_UserImagePrefix withFooter:[dic objectForKey:@"userThumbnail"]]];
 
    cell.iv_User.userInteractionEnabled = YES;
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
    [imageTap setNumberOfTapsRequired:1];
    [cell.iv_User addGestureRecognizer:imageTap];

    
    cell.lb_Name.text = [dic objectForKey:@"userName"];

    NSString *str_Major = [NSString stringWithFormat:@"%@", [dic objectForKey:@"userMajor"]];
    if( str_Major.length > 0 )
    {
        cell.lb_Tag.text = [NSString stringWithFormat:@"#%@_%@학년", [dic objectForKey:@"userAffiliation"], str_Major];
    }
    else
    {
        cell.lb_Tag.text = [NSString stringWithFormat:@"#%@", [dic objectForKey:@"userAffiliation"]];
    }
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)imageTap:(UIGestureRecognizer *)gesture
{
    UIView *view = (UIView *)gesture.view;
    NSDictionary *dic = self.ar_List[view.tag];
    
    MyMainViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
    vc.isAnotherUser = YES;
    vc.str_UserIdx = [dic objectForKey:@"userId"];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
