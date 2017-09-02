//
//  RankingMainViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 25..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "RankingMainViewController.h"
#import "RankingMainCell.h"
#import "UserPageMainViewController.h"
#import "MyMainViewController.h"

@interface RankingMainViewController ()
{
    NSString *str_UserSchoolName;
    
    NSString *str_ImagePrefix;
    NSString *str_UserImagePrefix;
    NSString *str_NoImagePrefix;
}
@property (nonatomic, strong) NSMutableArray *ar_List;
@property (nonatomic, weak) IBOutlet UISegmentedControl *seg;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@end

@implementation RankingMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    __weak __typeof(&*self)weakSelf = self;

    if( self.str_sId )
    {
        [self.seg setTitle:self.str_Date forSegmentAtIndex:0];
        [self.seg setTitle:@"전체" forSegmentAtIndex:1];
        self.seg.selectedSegmentIndex = 0;
        
        [self updateList:NO];
    }
    else
    {
        __weak __typeof(&*self)weakSelf = self;

        NSString *str_SchoolId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userSchoolId"];
        if( [str_SchoolId integerValue] > 0 )
        {
            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                [Util getUUID], @"uuid",
                                                [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"], @"pUserId",
                                                nil];
            
            [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/user/my"
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
                                                        str_UserSchoolName = [resulte objectForKey:@"hashtagStr"];
                                                        NSArray *ar_Sep = [str_UserSchoolName componentsSeparatedByString:@"_"];
                                                        if( ar_Sep.count > 1 )
                                                        {
                                                            str_UserSchoolName = [ar_Sep firstObject];
                                                        }
                                                    }
                                                }
                                                
                                                [weakSelf.seg setTitle:str_UserSchoolName forSegmentAtIndex:0];
                                                [weakSelf.seg setTitle:@"전체" forSegmentAtIndex:1];
                                                weakSelf.seg.selectedSegmentIndex = 0;
                                                
                                                [weakSelf updateList:NO];
                                            }];
        }
        else
        {
            [weakSelf.seg setTitle:@"전체" forSegmentAtIndex:0];
            [weakSelf.seg removeSegmentAtIndex:1 animated:NO];
            weakSelf.seg.selectedSegmentIndex = 0;
            
            [weakSelf updateList:YES];
        }
    }
    
//    NSString *str_SchoolId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userSchoolId"];
//    if( [str_SchoolId integerValue] > 0 )
//    {
//        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                                            [Util getUUID], @"uuid",
//                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"], @"pUserId",
//                                            nil];
//        
//        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/user/my"
//                                            param:dicM_Params
//                                       withMethod:@"GET"
//                                        withBlock:^(id resulte, NSError *error) {
//                                            
//                                            [MBProgressHUD hide];
//                                            
//                                            if( resulte )
//                                            {
//                                                NSLog(@"resulte : %@", resulte);
//                                                NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
//                                                if( nCode == 200 )
//                                                {
//                                                    str_UserSchoolName = [resulte objectForKey:@"hashtagStr"];
//                                                    NSArray *ar_Sep = [str_UserSchoolName componentsSeparatedByString:@"_"];
//                                                    if( ar_Sep.count > 1 )
//                                                    {
//                                                        str_UserSchoolName = [ar_Sep firstObject];
//                                                    }
//                                                }
//                                            }
//                                            
////                                            [weakSelf.seg setTitle:str_UserSchoolName forSegmentAtIndex:0];
//                                            [weakSelf.seg setTitle:@"전체" forSegmentAtIndex:1];
//                                            weakSelf.seg.selectedSegmentIndex = 0;
//
//                                            [weakSelf updateList:NO];
//                                        }];
//    }
//    else
//    {
//        [weakSelf.seg setTitle:@"전체" forSegmentAtIndex:0];
//        [weakSelf.seg removeSegmentAtIndex:1 animated:NO];
//        weakSelf.seg.selectedSegmentIndex = 0;
//
//        [weakSelf updateList:YES];
//    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    self.navigationController.view.tintColor = [UIColor clearColor];
    self.navigationController.navigationBarHidden = YES;
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

- (void)updateList:(BOOL)isTotal
{
    NSString *str_SchoolId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userSchoolId"];
    if( [str_SchoolId integerValue] <= 0 )
    {
        str_SchoolId = @"";
    }
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey:@"examId"] integerValue]], @"examId",
                                        [NSString stringWithFormat:@"%ld", [[self.dic_Info objectForKey:@"testerId"] integerValue]], @"testerId",
                                        str_SchoolId, @"schoolId",
                                        nil];
    
    if( isTotal )
    {
        [dicM_Params setObject:@"0" forKey:@"sId"];
        [dicM_Params removeObjectForKey:@"schoolId"];
        
        if( self.str_sId == nil )
        {
            [dicM_Params removeObjectForKey:@"sId"];
        }
    }
    else
    {
        if( self.str_sId )
        {
            [dicM_Params setObject:self.str_sId forKey:@"sId"];
        }
    }
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exam/user/rank/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                str_ImagePrefix = [resulte objectForKey:@"img_prefix"];
                                                str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
                                                str_NoImagePrefix = [resulte objectForKey:@"no_image"];

                                                self.ar_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"rankInfos"]];

//                                                if( isTotal )
//                                                {
//                                                    self.ar_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"rankInfos"]];
//                                                }
//                                                else
//                                                {
//                                                    self.ar_List = [NSMutableArray array];
//                                                    NSArray *ar_Tmp = [NSMutableArray arrayWithArray:[resulte objectForKey:@"rankInfos"]];
//                                                    for( NSInteger i = 0; i < ar_Tmp.count; i++ )
//                                                    {
//                                                        NSDictionary *dic = ar_Tmp[i];
//                                                        if( [[dic objectForKey:@"userSchoolId"] integerValue] > 0 )
//                                                        {
//                                                            [self.ar_List addObject:dic];
//                                                        }
//                                                    }
//                                                }
                                                
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
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"RankingMainCell";
    RankingMainCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*
     changeDate = "2016-07-22 13:53";
     createDate = "2016-07-13 22:59";
     examId = 10;
     examLapTime = 2000;
     imgUrl = "no_image";
     isExamFinish = Y;
     name = "\Uc81c\Uc774\Uc2a8";
     score = 1;
     testerId = 597;
     "u_progress" = 4;
     url = U127160713;
     userAffiliation = "\Uc9c4\Uba85\Ud559\Uc6d0\Uc120\Uc0dd\Ub2d8";
     userId = 127;
     userMajor = "";
     userRank = 3;
     userSchoolId = 0;
     */
    
//    cell.iv_User
    
    NSDictionary *dic = self.ar_List[indexPath.row];
    
    //유저 이미지
    NSString *str_ImageUrl = [dic objectForKey:@"imgUrl"];
    if( [str_ImageUrl isEqualToString:@"no_image"] )
    {
        [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_NoImagePrefix]];
    }
    else
    {
        [cell.iv_User sd_setImageWithURL:[Util createImageUrl:str_UserImagePrefix withFooter:[dic objectForKey:@"imgUrl"]]];
    }

    cell.iv_User.tag = indexPath.row;
    
    
    
    cell.iv_User.userInteractionEnabled = YES;
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
    [imageTap setNumberOfTapsRequired:1];
    [cell.iv_User addGestureRecognizer:imageTap];

    
    
    //이름
    cell.lb_Name.text = [dic objectForKey_YM:@"name"];
    
    //태그
    NSInteger nSchoolId = [[dic objectForKey_YM:@"userSchoolId"] integerValue];
    if( nSchoolId > 0 )
    {
        //학생
        cell.lb_Tag.text = [NSString stringWithFormat:@"%@ %@", [dic objectForKey_YM:@"userAffiliation"], [dic objectForKey_YM:@"userMajor"]];
    }
    else
    {
        //기타
        cell.lb_Tag.text = [dic objectForKey_YM:@"userAffiliation"];
    }
    
    //랭킹
    cell.lb_Ranking.text = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"userRank"] integerValue]];
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)imageTap:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *view = gestureRecognizer.view;
    NSDictionary *dic = self.ar_List[view.tag];
    
    MyMainViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
    vc.isAnotherUser = YES;
    vc.str_UserIdx = [dic objectForKey:@"userId"];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - IBAction
- (IBAction)goSegChange:(id)sender
{
    NSString *str_SchoolId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userSchoolId"];
    if( [str_SchoolId integerValue] > 0 )
    {
        if( self.seg.selectedSegmentIndex == 0 )
        {
            [self updateList:NO];
        }
        else
        {
            [self updateList:YES];
        }
    }
}

@end
