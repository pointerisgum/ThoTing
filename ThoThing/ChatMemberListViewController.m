//
//  ChatMemberListViewController.m
//  ThoThing
//
//  Created by macpro15 on 2017. 9. 27..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "ChatMemberListViewController.h"
#import "ChatIngUserCell.h"

@interface ChatMemberListViewController ()
{
    NSString *str_UserImagePrefix;
}
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@end

@implementation ChatMemberListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSDictionary *dic_Data = [NSJSONSerialization JSONObjectWithData:[self.channel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
    NSLog(@"%@", dic_Data);
    
    for( NSInteger i = 0; i < self.channel.members.count; i++ )
    {
        SBDUser *user = self.channel.members[i];
        NSLog(@"%@", user.profileUrl);
        NSLog(@"%@", user.nickname);
    }
    
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
                                        [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"channelId"]], @"channelId",
                                        [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"questionId"]], @"questionId",
                                        @"invite", @"listMode",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/qna/chat/room/invite/user/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                //                                                    str_ImagePrefix = [resulte objectForKey:@"img_prefix"];
                                                str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
                                                //                                                    str_NoImagePrefix = [resulte objectForKey:@"no_image"];
                                                
                                                self.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"userListInfos"]];
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
    return self.arM_List.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*
     channelId = 4;
     imgUrl = "000/000/noImage14.png";
     isMemberAllow = A;
     lastInviteDate = 20170927173538;
     memberLevel = 20;
     url = U122160713;
     userId = 122;
     userName = "\Uacf5\Ubd80\Uaf5d";
     userType = member;
     */
    
    NSDictionary *dic = self.arM_List[indexPath.row];
    
    ChatIngUserCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChatIngUserCell"];
    
    cell.btn_Check.selected = NO;

    NSString *str_UserImageUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [dic objectForKey_YM:@"imgUrl"]];
    [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_UserImageUrl] placeholderImage:BundleImage(@"kik_no_user_30.png")];
    
    cell.lb_Name.text = [dic objectForKey_YM:@"userName"];
    cell.lb_NinkName.text = [dic objectForKey_YM:@"userEmail"];
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.arM_List[indexPath.row];
    

}

@end
