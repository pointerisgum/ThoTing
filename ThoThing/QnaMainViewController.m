//
//  QnaMainViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 10. 6..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "QnaMainViewController.h"
#import "QnACell.h"
#import "ChattingViewController.h"
#import "ChannelMainViewController.h"

@interface QnaMainViewController ()
{
    NSString *str_ImagePrefix;
    NSString *str_UserImagePrefix;
    
    NSInteger nNextNum;
    BOOL isLoding;
}
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@end

@implementation QnaMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self initNaviWithTitle:@"질문과 답" withLeftItem:nil withRightItem:nil withColor:[UIColor colorWithHexString:@"F8F8F8"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
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
    isLoding = YES;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        @"20", @"limtCount",
                                        [NSString stringWithFormat:@"%ld", nNextNum == 0 ? nNextNum : nNextNum + 1], @"nextNum",
                                        nil];

    __weak __typeof(&*self)weakSelf = self;

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/follow/channel/qna/chat/room/list"
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
                                                if( str_ImagePrefix == nil )
                                                {
                                                    str_ImagePrefix = [resulte objectForKey:@"image_prefix"];
                                                }
                                                
                                                if( str_UserImagePrefix == nil )
                                                {
                                                    str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
                                                }

                                                if( weakSelf.arM_List != nil && weakSelf.arM_List.count > 0 )
                                                {
                                                    [weakSelf.arM_List addObjectsFromArray:[resulte objectForKey:@"qnaRoomInfos"]];
                                                }
                                                else
                                                {
                                                    weakSelf.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"qnaRoomInfos"]];
                                                }

                                                [weakSelf.tbv_List reloadData];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                            
                                            nNextNum = self.arM_List.count;
                                            
                                            [self.tbv_List reloadData];
                                            
                                            isLoding = NO;
                                        }
                                    }];
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if( scrollView == self.tbv_List )
    {
        if( scrollView.contentOffset.y > scrollView.contentSize.height - self.tbv_List.frame.size.height - 20
           && isLoding == NO )
        {
            isLoding = YES;
            [self updateList];
        }
    }
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
    QnACell *cell = [tableView dequeueReusableCellWithIdentifier:@"QnACell"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.arM_List[indexPath.row];
    
    NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [dic objectForKey:@"channelImgUrl"]];
    [cell.iv_ChannelIcon sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
    
    cell.iv_ChannelIcon.userInteractionEnabled = YES;
    cell.iv_ChannelIcon.tag = indexPath.row;
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
    [imageTap setNumberOfTapsRequired:1];
    [cell.iv_ChannelIcon addGestureRecognizer:imageTap];
    
    cell.v_TitleBg.backgroundColor = [UIColor colorWithHexString:[dic objectForKey_YM:@"codeHex"]];
    cell.lb_Title.text = [NSString stringWithFormat:@"#%@", [dic objectForKey:@"roomName"]];
    cell.lb_PeopleCnt.text = [NSString stringWithFormat:@"%@ 참가자", [dic objectForKey:@"userCount"]];
    
    NSString *str_Date = [NSString stringWithFormat:@"%@", [dic objectForKey:@"lastChatDate"]];
    
    if( str_Date.length >= 12 )
    {
        NSString *str_Year = [str_Date substringWithRange:NSMakeRange(0, 4)];
        NSString *str_Month = [str_Date substringWithRange:NSMakeRange(4, 2)];
        NSString *str_Day = [str_Date substringWithRange:NSMakeRange(6, 2)];
        NSString *str_Hour = [str_Date substringWithRange:NSMakeRange(8, 2)];
        NSString *str_Minute = [str_Date substringWithRange:NSMakeRange(10, 2)];
        
        cell.lb_Date.text = [NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld", [str_Year integerValue], [str_Month integerValue], [str_Day integerValue], [str_Hour integerValue], [str_Minute integerValue]];
    }
    else
    {
        cell.lb_Date.text = str_Date;
    }
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.arM_List[indexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chatting" bundle:nil];
    ChattingViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChattingViewController"];
    vc.dic_Info = dic;
    vc.str_ChannelId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]];
    vc.str_RId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"rId"]];
    vc.isMyMode = YES;
//    vc.i_User = self.iv_User.image;
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)imageTap:(UIGestureRecognizer *)gesture
{
    UIView *view = (UIView *)gesture.view;
    NSDictionary *dic = self.arM_List[view.tag];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Channel" bundle:nil];
    ChannelMainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChannelMainViewController"];
    vc.str_ChannelId = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"channelId"] integerValue]];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
