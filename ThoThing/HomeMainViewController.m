//
//  HomeMainViewController.m
//  ThoThing
//
//  Created by macpro15 on 2017. 8. 16..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "HomeMainViewController.h"
#import "ChannelMainViewController.h"
#import "ChannelReportViewController.h"
#import "UserControllListViewController.h"
#import "MainSideMenuViewController.h"

@interface HomeMainViewController ()
@property (nonatomic, strong) NSMutableArray *arM_List;
@end

@implementation HomeMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    __weak __typeof__(self) weakSelf = self;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/home/channels"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
//                                            str_ImagePrefix = [resulte objectForKey:@"userImg_prefix"];
                                            
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                self.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"channelInfos"]];
                                                
                                            }
                                        }
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


//- (IBAction)goTest:(id)sender
//{
//    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//    [appDelegate showChannelView];
//}

//- (IBAction)goLibrary:(id)sender
//{
////    NSString *str_ChannelId = @"";
////    NSArray *ar_ExamInfos = [dic_Main objectForKey:@"examInfos"];
////    if( ar_ExamInfos.count > 0 )
////    {
////        NSDictionary *dic = [ar_ExamInfos firstObject];
////        str_ChannelId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]];
////    }
////    else
////    {
////        str_ChannelId = [NSString stringWithFormat:@"%@", [dic_Main objectForKey:@"basicConditionValue"]];
////    }
////    
////    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Channel" bundle:nil];
////    ChannelMainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChannelMainViewController"];
////    vc.hidesBottomBarWhenPushed = YES;
////    vc.isShowNavi = YES;
////    vc.str_ChannelId = str_ChannelId;
////    [self.navigationController pushViewController:vc animated:YES];
//}
//
//- (IBAction)goMember:(id)sender
//{
////    UserControllListViewController *vc = [kEtcBoard instantiateViewControllerWithIdentifier:@"UserControllListViewController"];
////    vc.isMannager = YES;
////    vc.str_ChannelId = self.str_ChannelId;
////    vc.isChannel = YES;
////    vc.str_Mode = @"member";
////    [self.navigationController pushViewController:vc animated:YES];
//}
//
//- (IBAction)goReport:(id)sender
//{
////    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Channel" bundle:nil];
////    ChannelReportViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChannelReportViewController"];
////    vc.str_ChannelId = self.str_ChannelId;
////    [self.navigationController pushViewController:vc animated:YES];
//}
//
//- (IBAction)goMy:(id)sender
//{
//    UINavigationController *navi = [kMainBoard instantiateViewControllerWithIdentifier:@"MainSideNavi"];
//    MainSideMenuViewController *vc = [navi.viewControllers firstObject];
//    vc.isChannelMode = YES;
//    vc.dic_ChannelInfo = self.dic;
//    [self.navigationController pushViewController:vc animated:YES];
//
////    MainSideNavi
//}

@end
