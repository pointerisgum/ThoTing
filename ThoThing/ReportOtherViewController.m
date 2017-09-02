//
//  ReportOtherViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 26..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "ReportOtherViewController.h"
#import "ReportOtherHeaderCell.h"
#import "ReportOtherCell.h"
#import "ReportOtherTotalMemberCell.h"
#import "ActionSheetStringPicker.h"
#import "UserPageMainViewController.h"
#import "ReportMainViewController.h"
#import "ReportOtherViewController.h"
#import "ReportPopUpViewController.h"
#import "ReportMainViewController.h"
#import "MyMainViewController.h"

@interface ReportOtherViewController () <UITableViewDelegate, UITableViewDataSource>
{
    BOOL isLoding;

    NSInteger nMainChannelId;   //내가 선택한 채널 아이디

    NSString *str_ImagePrefix;
    NSString *str_UserImagePrefix;
    NSString *str_NoImagePrefix;
}
@property (nonatomic, strong) NSMutableArray *ar_List1;
@property (nonatomic, strong) NSArray *ar_List2;
@property (nonatomic, strong) NSArray *ar_List3;
@property (nonatomic, weak) IBOutlet UIView *v_Menus;
@property (nonatomic, weak) IBOutlet UIButton *btn_Tab1;
@property (nonatomic, weak) IBOutlet UIButton *btn_Tab2;
@property (nonatomic, weak) IBOutlet UIButton *btn_Tab3;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Contents;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ContentsWidth;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List1;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List2;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List3;
@end

@implementation ReportOtherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

//    self.tbv_List1.delegate = self;
//    self.tbv_List1.dataSource = self;
    
    self.tbv_List2.delegate = self;
    self.tbv_List2.dataSource = self;

    self.tbv_List3.delegate = self;
    self.tbv_List3.dataSource = self;
    
    self.btn_Tab2.selected = YES;
    
//str_ChannelId
//    if( self.arM_MyChannelList.count > 0 )
//    {
//        [self initNaviWithTitle:[self.dic_Info objectForKey:@"channelName"]
//                   withLeftItem:nil
//                  withRightItem:[self rightReportButtonItem]
//                      withColor:[UIColor colorWithHexString:@"F8F8F8"]];
//    }
//    else
//    {
//        [self initNaviWithTitle:[self.dic_Info objectForKey:@"channelName"]
//                   withLeftItem:nil
//                  withRightItem:nil
//                      withColor:[UIColor colorWithHexString:@"F8F8F8"]];
//    }


    /*
     channelExamCount = 42;
     channelFollowerCount = 99;
     channelId = 4;
     channelImgUrl = "000/000/edujmLogo.png";
     channelName = "\Uc9c4\Uba85\Ud559\Uc6d0";
     channelUrl = edujm;
     createDate = "2016-07-13 18:29:05";
     imgUrl = "000/000/noImage14.png";
     memberLevel = 9;
     statusCode = T;
     userId = 108;
     */
//    [self getMyMainChannelId];
//    [self updateList1];
    [self updateList2];
    [self updateList3];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)getMyMainChannelId
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/profile"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                nMainChannelId = [[resulte objectForKey:@"mainChannelId"] integerValue];
                                            }
                                        }
                                    }];
}

- (void)viewDidLayoutSubviews
{
    self.sv_Contents.contentSize = CGSizeMake(self.sv_Contents.bounds.size.width * 3, 0);
    self.lc_ContentsWidth.constant = self.sv_Contents.contentSize.width;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)settingButtonPressed:(UIButton *)btn
{
    if( self.arM_MyChannelList == nil )
    {
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    ReportPopUpViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ReportPopUpViewController"];
    vc.ar_List = self.arM_MyChannelList;
    vc.nSelectedIdx = nMainChannelId;
    [vc setCompletionBlock:^(id completeResult) {
        
        NSDictionary *dic = completeResult;
        
        NSInteger nSelectedIdx = [[dic objectForKey:@"channelId"] integerValue];
        
        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                            [Util getUUID], @"uuid",
                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"], @"userName",
                                            [NSString stringWithFormat:@"%ld", nSelectedIdx], @"channelId",
                                            nil];
        
        [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/change/my/profile"
                                            param:dicM_Params
                                       withMethod:@"POST"
                                        withBlock:^(id resulte, NSError *error) {
                                            
                                            if( resulte )
                                            {
                                                NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                if( nCode == 200 )
                                                {
                                                    nMainChannelId = nSelectedIdx;
                                                    
                                                    if( nMainChannelId != 0 )
                                                    {
                                                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
                                                        ReportOtherViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ReportOtherViewController"];
                                                        vc.arM_MyChannelList = self.arM_MyChannelList;
                                                        vc.dic_Info = dic;
                                                        
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"kChangeTabBarController" object:vc];
                                                    }
                                                    else
                                                    {
                                                        ReportMainViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportMainViewController"];
                                                        
                                                        [[NSNotificationCenter defaultCenter] postNotificationName:@"kChangeTabBarController" object:vc];
                                                    }
                                                }
                                                else
                                                {
                                                    [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                }
                                            }
                                        }];
    }];
    
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)updateList1
{
    NSString *str_Time = @"";
    if( self.ar_List1 != nil )
    {
        NSDictionary *dic_Main = [self.ar_List1 lastObject];
        if( [[dic_Main objectForKey:@"lastDateTime"] isEqual:[NSNull null]] )
        {
            
        }
        else
        {
            str_Time = [NSString stringWithFormat:@"%lld", [[dic_Main objectForKey:@"lastDateTime"] longLongValue]];
        }
    }
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
//                                        [Util transIntToString:[self.dic_Info objectForKey:@"channelId"]], @"channelId",
                                        self.str_ChannelId, @"channelId",
                                        @"10", @"limitCount",
                                        str_Time, @"lastDateTime",
                                        nil];
    
    if( self.ar_List1 == nil )
    {
        [dicM_Params removeObjectForKey:@"lastDateTime"];
    }
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/report/recently"
                                        param:dicM_Params
                                   withMethod:@"GET"
                            withShowIndicator:self.ar_List1 == nil ? YES : NO
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                str_ImagePrefix = [resulte objectForKey:@"img_prefix"];
                                                str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
                                                str_NoImagePrefix = [resulte objectForKey:@"no_image"];

                                                if( self.ar_List1 == nil || self.ar_List1.count <= 0 )
                                                {
                                                    self.ar_List1 = [NSMutableArray arrayWithArray:[resulte objectForKey:@"recentlyData"]];
                                                }
                                                else
                                                {
                                                    [self.ar_List1 addObjectsFromArray:[resulte objectForKey:@"recentlyData"]];
                                                }
                                                
                                                [self.tbv_List1 reloadData];
                                            }
                                        }
                                        
                                        isLoding = NO;
                                    }];
}

- (void)updateList2
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        //                                        [Util transIntToString:[self.dic_Info objectForKey:@"channelId"]], @"channelId",
                                        self.str_ChannelId, @"channelId",
                                        @"recently", @"orderBy",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/report/user/list"
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
                                                
                                                self.ar_List2 = [resulte objectForKey:@"userList"];
                                                [self.tbv_List2 reloadData];
                                            }
                                        }
                                    }];
}

- (void)updateList3
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
//                                        [Util transIntToString:[self.dic_Info objectForKey:@"channelId"]], @"channelId",
                                        self.str_ChannelId, @"channelId",
                                        @"many", @"orderBy",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/report/user/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
//                                                str_ImagePrefix = [resulte objectForKey:@"img_prefix"];
//                                                str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
//                                                str_NoImagePrefix = [resulte objectForKey:@"no_image"];
                                                
                                                self.ar_List3 = [resulte objectForKey:@"userList"];
                                                [self.tbv_List3 reloadData];
                                            }
                                        }
                                    }];
}



#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if( scrollView == self.tbv_List1 )
    {
        if( self.tbv_List1.contentOffset.y > (self.tbv_List1.contentSize.height * 0.7f) && isLoding == NO )
        {
            isLoding = YES;
            [self updateList1];
        }
    }
}


#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if( tableView == self.tbv_List1 )
    {
        return self.ar_List1.count;
    }
    else if( tableView == self.tbv_List2 )
    {
        return 1;
    }
    else if( tableView == self.tbv_List3 )
    {
        return 1;
    }
    
    return 0;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( tableView == self.tbv_List1 )
    {
        NSDictionary *dic = self.ar_List1[section];
        NSArray *ar_UserInfo = [dic objectForKey:@"userInfo"];
        return ar_UserInfo.count;
    }
    else if( tableView == self.tbv_List2 )
    {
//        NSDictionary *dic = self.ar_List2[section];
//        NSArray *ar_SolveInfo = [dic objectForKey:@"solveInfo"];
//        return ar_SolveInfo.count;
        return self.ar_List2.count;
    }
    else if( tableView == self.tbv_List3 )
    {
        return self.ar_List3.count;
    }
    
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if( tableView == self.tbv_List1 || tableView == self.tbv_List2 )
//    {
//        static NSString *CellIdentifier = @"ReportOtherCell";
//        ReportOtherCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//
//        NSDictionary *dic = nil;
//        if( tableView == self.tbv_List1 )
//        {
//            NSDictionary *dic_Main = self.ar_List1[indexPath.section];
//            NSArray *ar_UserInfo = [dic_Main objectForKey:@"userInfo"];
//            NSDictionary *dic_UserInfo = ar_UserInfo[indexPath.row];
//            NSArray *ar_Tmp = [dic_UserInfo objectForKey:@"solveInfo"];
//            dic = [ar_Tmp firstObject];
//        }
//        else
//        {
//            NSDictionary *dic_Main = self.ar_List2[indexPath.section];
//            NSArray *ar_SolveInfo = [dic_Main objectForKey:@"solveInfo"];
//            dic = ar_SolveInfo[indexPath.row];
//        }
//
//        //코멘트는 사용 안함
//        cell.btn_Comment.hidden = YES;
//        //////////
//        
//        cell.iv_Cover.backgroundColor = [UIColor colorWithHexString:[dic objectForKey_YM:@"codeHex"]];
//
//        cell.lb_CorverTitle.text = [dic objectForKey:@"examTitle"];
//        
//        cell.lb_Title.text = [dic objectForKey:@"subjectName"];
//        
//        cell.lb_Owner.text = [NSString stringWithFormat:@"#%@", [dic objectForKey:@"publisherName"]];
//        
//        
//        
//        
//        
//        
//        
//        NSMutableAttributedString *attM = [[NSMutableAttributedString alloc] initWithString:[Util transIntToString:[dic objectForKey:@"correctAnswerCount"]]];
//        UIColor *grayColor = [UIColor lightGrayColor];
//        UIColor *blackColor = [UIColor blackColor];
//        NSString *string = @"맞은것/";
//        NSDictionary *attrs_Gray = @{ NSForegroundColorAttributeName : grayColor };
//        NSDictionary *attrs_Black = @{ NSForegroundColorAttributeName : blackColor };
//        NSAttributedString *attrStr = [[NSAttributedString alloc] initWithString:string attributes:attrs_Gray];
//        [attM appendAttributedString:attrStr];
//        
//        attrStr = [[NSAttributedString alloc] initWithString:[Util transIntToString:[dic objectForKey:@"solveQuestionCount"]] attributes:attrs_Black];
//        [attM appendAttributedString:attrStr];
//        
//        string = @"푼문제/";
//        attrStr = [[NSAttributedString alloc] initWithString:string attributes:attrs_Gray];
//        [attM appendAttributedString:attrStr];
//
//        attrStr = [[NSAttributedString alloc] initWithString:[Util transIntToString:[dic objectForKey:@"questionCount"]] attributes:attrs_Black];
//        [attM appendAttributedString:attrStr];
//
//        string = @"문제";
//        attrStr = [[NSAttributedString alloc] initWithString:string attributes:attrs_Gray];
//        [attM appendAttributedString:attrStr];
//        
//        cell.lb_Counting.attributedText = attM;
//        
//        
//        
//        CGFloat fTotalCnt = [[dic objectForKey:@"questionCount"] floatValue];
//        CGFloat fFinishCnt = [[dic objectForKey:@"solveQuestionCount"] floatValue];
//        
////        cell.lc_ProgressWidth.constant = 0;
//        
//        CGFloat fFinishPer = fFinishCnt / fTotalCnt;
//        cell.lc_ProgressWidth.constant = cell.lc_ProgressBgWidth.constant * fFinishPer;
//        [cell.iv_Progress setNeedsUpdateConstraints];
//        [cell setNeedsUpdateConstraints];
//        [self.tbv_List1 setNeedsUpdateConstraints];
//        
////        [cell.iv_Progress setNeedsLayout];
////        [cell.iv_Progress updateConstraints];
////        [cell setNeedsUpdateConstraints];
//        
////        [tableView beginUpdates];
////        [tableView endUpdates];
//
//        /*
//         correctAnswerCount = 1;
//         examId = 76;
//         examTitle = "1.\Uc6b0\Uc8fc\Uc758 \Uae30\Uc6d0";
//         imgUrl = "000/000/noImage15.png";
//         lectureId = 0;
//         name = "\Uc81c\Uad8c";
//         publisherName = "\Uc9c4\Uba85\Ud559\Uc6d0";
//         questionCount = 4;
//         solveQuestionCount = 10;
//         starCount = 0;
//         subjectName = "\Uc735\Ud569\Uacfc\Ud559";
//         testerId = 802;
//         url = U123160713;
//         userAffiliation = "\Uad00\Uc545\Uace0\Ub4f1\Ud559\Uad50";
//         userId = 123;
//         userMajor = 2;
//         userSchoolId = 9489;
//         */
//        
//        return cell;
//    }
    
    NSDictionary *dic = nil;

    if( tableView == self.tbv_List2 )
    {
        dic = self.ar_List2[indexPath.row];
    }
    else if( tableView == self.tbv_List3 )
    {
        dic = self.ar_List3[indexPath.row];
    }
    
    static NSString *CellIdentifier = @"ReportOtherTotalMemberCell";
    ReportOtherTotalMemberCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    
    cell.iv_User.tag = indexPath.row;
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap3:)];
    [singleTap setNumberOfTapsRequired:1];
    [cell.iv_User addGestureRecognizer:singleTap];
    
    cell.iv_User.userInteractionEnabled = YES;
    
//    __weak __typeof(&*cell)weakSelf = cell;

    NSString *str_ImageUrl = [dic objectForKey:@"imgUrl"];
    if( [str_ImageUrl isEqualToString:@"no_image"] )
    {
//        [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_NoImagePrefix] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//            
//            [self performSelector:@selector(onImageShowInterval:) withObject:@{@"obj":weakSelf, @"image":image} afterDelay:0.1f];
//        }];
        [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_NoImagePrefix]];
    }
    else
    {
        [cell.iv_User sd_setImageWithURL:[Util createImageUrl:str_UserImagePrefix withFooter:[dic objectForKey:@"imgUrl"]]];
    }
    
    cell.lb_Name.text = [dic objectForKey:@"userName"];
    
    //학생의 경우 #처리
    if( [[dic objectForKey:@"userSchoolId"] isEqual:[NSNull null]] == NO && [[dic objectForKey:@"userSchoolId"] integerValue] > 0 )
    {
        //학생
        cell.lb_Tag.text = [NSString stringWithFormat:@"#%@ #%@학년", [dic objectForKey_YM:@"userAffiliation"], [dic objectForKey_YM:@"userMajor"]];
    }
    else
    {
        //그외
        cell.lb_Tag.text = [NSString stringWithFormat:@"#%@ %@", [dic objectForKey_YM:@"userAffiliation"], [dic objectForKey_YM:@"userMajor"]];
    }

    //시간
    NSString *str_Time = @"";
    if( [[dic objectForKey:@"solveDate"] isEqual:[NSNull null]] )
    {
        cell.lb_Time.text = @"";
    }
    else
    {
        str_Time = [NSString stringWithFormat:@"%lld", [[dic objectForKey:@"solveDate"] longLongValue]];
        cell.lb_Time.text = [self getDday:str_Time];
    }
    

    NSString *str_SubJectName = [dic objectForKey_YM:@"subjectName"];
    if( str_SubJectName.length > 0 )
    {
        cell.lb_Tag2.text = [NSString stringWithFormat:@"#%@", [dic objectForKey_YM:@"subjectName"]];
    }
    else
    {
        cell.lb_Tag2.text = @"";
    }
    
    /*
     channelId = 4;
     examId = 75;
     examTitle = "\Ud070\Ubcc4\Uc0d8 \Ucd5c\Ud0dc\Uc131\Uc758 \Uadfc\Ud604\Ub300\Uc0ac 1400\Uc81c";
     imgUrl = "000/000/noImage13.png";
     isExamFinish = N;
     lectureId = 0;
     memberLevel = 20;
     personGrade = 0;
     schoolGrade = "\Uace0\Ub4f1\Ud559\Uad50";
     solveDate = "2016-07-13 22:11:14";
     solveQuestionCount = 12;
     statusCode = M;
     subjectName = "\Ud55c\Uad6d\Uc0ac";
     url = U121160713;
     userAffiliation = "\Uac15\Uc11c\Uace0\Ub4f1\Ud559\Uad50";
     userId = 121;
     userMajor = 2;
     userName = "\Uacf5\Ubd80\Ud5d0";
     userSchoolId = 9573;
     */
    
    return cell;
}

- (void)onImageShowInterval:(NSDictionary *)dic
{
    ReportOtherTotalMemberCell *cell = [dic objectForKey:@"obj"];
    cell.iv_User.image = [dic objectForKey:@"image"];
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    if( tableView == self.tbv_List1 || tableView == self.tbv_List2 )
//    {
//        return 50.f;
//    }
//    
//    return 0.f;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    static NSString *CellIdentifier = @"ReportOtherHeaderCell";
//    ReportOtherHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//
//    if( tableView == self.tbv_List1 )
//    {
//        NSDictionary *dic_Main = self.ar_List1[section];
//        NSArray *ar_UserInfo = [dic_Main objectForKey:@"userInfo"];
//        NSDictionary *dic = [ar_UserInfo firstObject];
//        
//        
//        //유저 이미지
//        cell.iv_User.tag = section;
//        
//        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap1:)];
//        [singleTap setNumberOfTapsRequired:1];
//        [cell.iv_User addGestureRecognizer:singleTap];
//
//        cell.iv_User.userInteractionEnabled = YES;
//        
//        NSString *str_ImageUrl = [dic objectForKey:@"imgUrl"];
//        if( [str_ImageUrl isEqualToString:@"no_image"] )
//        {
//            [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_NoImagePrefix]];
//        }
//        else
//        {
//            [cell.iv_User sd_setImageWithURL:[Util createImageUrl:str_UserImagePrefix withFooter:[dic objectForKey:@"imgUrl"]]];
//        }
//
//        cell.lb_Name.text = [dic objectForKey:@"name"];
//        
//        //학생의 경우 #처리
//        if( [[dic objectForKey:@"userSchoolId"] isEqual:[NSNull null]] == NO && [[dic objectForKey:@"userSchoolId"] integerValue] > 0 )
//        {
//            //학생
//            cell.lb_Tag.text = [NSString stringWithFormat:@"#%@ #%@학년", [dic objectForKey:@"userAffiliation"], [dic objectForKey:@"userMajor"]];
//        }
//        else
//        {
//            //그외
//            cell.lb_Tag.text = [NSString stringWithFormat:@"#%@ %@", [dic objectForKey:@"userAffiliation"], [dic objectForKey:@"userMajor"]];
//        }
//        
//        //시간
//        NSString *str_Time = @"";
//        if( [[dic_Main objectForKey:@"lastDateTime"] isEqual:[NSNull null]] )
//        {
//            str_Time = @"";
//        }
//        else
//        {
//            str_Time = [NSString stringWithFormat:@"%lld", [[dic_Main objectForKey:@"lastDateTime"] longLongValue]];
//        }
//
//        cell.lb_Time.text = [self getDday:str_Time];
//        
//        return cell;
//    }
//    else if( tableView == self.tbv_List2 )
//    {
//        NSDictionary *dic = self.ar_List2[section];
//        
//        //유저 이미지
//        cell.iv_User.tag = section;
//        
//        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap2:)];
//        [singleTap setNumberOfTapsRequired:1];
//        [cell.iv_User addGestureRecognizer:singleTap];
//        
//        cell.iv_User.userInteractionEnabled = YES;
//        
//        NSString *str_ImageUrl = [dic objectForKey:@"imgUrl"];
//        if( [str_ImageUrl isEqualToString:@"no_image"] )
//        {
//            [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_NoImagePrefix]];
//        }
//        else
//        {
//            [cell.iv_User sd_setImageWithURL:[Util createImageUrl:str_UserImagePrefix withFooter:[dic objectForKey:@"imgUrl"]]];
//        }
//        
//        cell.lb_Name.text = [dic objectForKey:@"name"];
//        
//        //학생의 경우 #처리
//        if( [[dic objectForKey:@"userSchoolId"] isEqual:[NSNull null]] == NO && [[dic objectForKey:@"userSchoolId"] integerValue] > 0 )
//        {
//            //학생
//            cell.lb_Tag.text = [NSString stringWithFormat:@"#%@ #%@학년", [dic objectForKey:@"userAffiliation"], [dic objectForKey:@"userMajor"]];
//        }
//        else
//        {
//            //그외
//            cell.lb_Tag.text = [NSString stringWithFormat:@"#%@ %@", [dic objectForKey:@"userAffiliation"], [dic objectForKey:@"userMajor"]];
//        }
//        
//        cell.lb_Time.text = [dic objectForKey:@"lastDate"];
//        
//        return cell;
//    }
//    
//    return nil;
//}

- (NSString *)getDday:(NSString *)aDay
{
    aDay = [aDay stringByReplacingOccurrencesOfString:@"-" withString:@""];
    aDay = [aDay stringByReplacingOccurrencesOfString:@" " withString:@""];
    aDay = [aDay stringByReplacingOccurrencesOfString:@":" withString:@""];
    
    NSString *str_Year = [aDay substringWithRange:NSMakeRange(0, 4)];
    NSString *str_Month = [aDay substringWithRange:NSMakeRange(4, 2)];
    NSString *str_Day = [aDay substringWithRange:NSMakeRange(6, 2)];
    NSString *str_Hour = [aDay substringWithRange:NSMakeRange(8, 2)];
    NSString *str_Minute = [aDay substringWithRange:NSMakeRange(10, 2)];
    NSString *str_Second = [aDay substringWithRange:NSMakeRange(12, 2)];
    NSString *str_Date = [NSString stringWithFormat:@"%@-%@-%@ %@:%@:%@", str_Year, str_Month, str_Day, str_Hour, str_Minute, str_Second];
    
    NSDateFormatter *format1 = [[NSDateFormatter alloc] init];
    [format1 setDateFormat:@"yyyy-MM-dd HH:mm:ss +0000"];
    
    NSDate *ddayDate = [format1 dateFromString:str_Date];
    
    NSDate *date = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:NSCalendarUnitYear|NSCalendarUnitMonth|NSCalendarUnitDay|NSCalendarUnitHour|NSCalendarUnitMinute|NSCalendarUnitSecond fromDate:date];
    NSInteger nYear = [components year];
    NSInteger nMonth = [components month];
    NSInteger nDay = [components day];
    NSInteger nHour = [components hour];
    NSInteger nMinute = [components minute];
    NSInteger nSecond = [components second];
    
    NSDate *currentTime = [format1 dateFromString:[NSString stringWithFormat:@"%04ld-%02ld-%02ld %02d:%02d:%02d", nYear, nMonth, nDay, nHour, nMinute, nSecond]];
    
    NSTimeInterval diff = [currentTime timeIntervalSinceDate:ddayDate];
    
    NSInteger nWriteTime = diff;
    
    
    
    
    if( nWriteTime > (60 * 60 * 24) )
    {
        return [NSString stringWithFormat:@"%@-%@-%@", str_Year, str_Month, str_Day];
    }
    else
    {
        if( nWriteTime <= 0 )
        {
            return @"1초전";
        }
        else if( nWriteTime < 60 )
        {
            //1분보다 작을 경우
            return [NSString stringWithFormat:@"%ld초전", nWriteTime];
        }
        else if( nWriteTime < (60 * 60) )
        {
            //1시간보다 작을 경우
            return [NSString stringWithFormat:@"%ld분전", nWriteTime / 60];
        }
        else
        {
            return [NSString stringWithFormat:@"%ld시간전", ((nWriteTime / 60) / 60)];
        }
    }

    
    return @"";
}

- (void)handleSingleTap1:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *view = gestureRecognizer.view;
    
    NSDictionary *dic_Main = self.ar_List1[view.tag];
    NSArray *ar_UserInfo = [dic_Main objectForKey:@"userInfo"];
    NSDictionary *dic = [ar_UserInfo firstObject];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MyMainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
    vc.isManagerView = YES;
    vc.isPermission = YES;
    vc.str_UserIdx = [dic objectForKey:@"userId"];
    [self.navigationController pushViewController:vc animated:YES];

//    UserPageMainViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserPageMainViewController"];
//    vc.str_UserIdx = [Util transIntToString:[dic objectForKey:@"userId"]];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)handleSingleTap2:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *view = gestureRecognizer.view;
    
    NSDictionary *dic_Main = self.ar_List2[view.tag];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MyMainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
    vc.isManagerView = YES;
    vc.isPermission = YES;
    vc.str_UserIdx = [dic_Main objectForKey:@"userId"];
    [self.navigationController pushViewController:vc animated:YES];

//    UserPageMainViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserPageMainViewController"];
//    vc.str_UserIdx = [Util transIntToString:[dic_Main objectForKey:@"userId"]];
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)handleSingleTap3:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *view = gestureRecognizer.view;
    
    NSDictionary *dic_Main = nil;
    if( self.sv_Contents.contentOffset.x == 0 )
    {
        dic_Main = self.ar_List2[view.tag];
    }
    else
    {
        dic_Main = self.ar_List3[view.tag];
    }

    
    if( [[dic_Main objectForKey:@"userId"] isEqual:[NSNull null]] )
    {
        ALERT(nil, @"유저 정보가 없습니다", nil, @"확인", nil);
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    MyMainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
    vc.isManagerView = YES;
    vc.isPermission = YES;
    vc.str_UserIdx = [dic_Main objectForKey:@"userId"];
    vc.isShowNavi = YES;
    [self.navigationController pushViewController:vc animated:YES];

//    UserPageMainViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserPageMainViewController"];
//    vc.str_UserIdx = [Util transIntToString:[dic_Main objectForKey:@"userId"]];
//    [self.navigationController pushViewController:vc animated:YES];
}


#pragma mark - IBAction
- (IBAction)goMeneSelected:(id)sender
{
    for( id subView in self.v_Menus.subviews )
    {
        if( [subView isKindOfClass:[UIButton class]] )
        {
            UIButton *subBtn = (UIButton *)subView;
            subBtn.selected = NO;
        }
    }
    
    UIButton *btn = (UIButton *)sender;
    btn.selected = YES;
    
//    if( sender == self.btn_Tab1 )
//    {
//        [UIView animateWithDuration:0.3f
//                         animations:^{
//                             
//                             self.sv_Contents.contentOffset = CGPointMake(self.sv_Contents.bounds.size.width * 0, 0);
//                         }];
//    }
//    else if( sender == self.btn_Tab2 )
    if( sender == self.btn_Tab2 )
    {
//        [self updateList2];

        [self.tbv_List2 reloadData];
        [UIView animateWithDuration:0.3f
                         animations:^{
                             
                             self.sv_Contents.contentOffset = CGPointMake(self.sv_Contents.bounds.size.width * 0, 0);
                         }];
    }
    else if( sender == self.btn_Tab3 )
    {
//        [self updateList3];

        [self.tbv_List3 reloadData];
        [UIView animateWithDuration:0.3f
                         animations:^{
                             
                             self.sv_Contents.contentOffset = CGPointMake(self.sv_Contents.bounds.size.width * 1, 0);
                         }];
    }
}

@end
