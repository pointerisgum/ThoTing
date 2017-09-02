//
//  MainChannelViewController.m
//  ThoThing
//
//  Created by macpro15 on 2017. 8. 16..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "MainChannelViewController.h"
#import "ChannelMainViewController.h"
#import "ChannelReportViewController.h"
#import "UserControllListViewController.h"
#import "MainSideMenuViewController.h"
#import "ChatFeedMainViewController.h"
#import "AddDiscripViewController.h"
#import <MXParallaxHeader/MXParallaxHeader.h>
#import "MyQuestionListCell.h"
#import "QuestionStartViewController.h"
#import "ActionSheetBottomViewController.h"
#import "QuestionDetailViewController.h"
#import "SharedViewController.h"
#import "GroupWebViewController.h"
#import "ReportDetailViewController.h"
#import "MainChannelEmptyCell.h"

@interface MainChannelViewController () <MXParallaxHeaderDelegate>
{
    BOOL isMannager;
    //    BOOL isMyPage;
    BOOL isFollowing;
    BOOL isMember;
    BOOL isNaviShow;
    
    NSString *str_ImagePrefix;
    NSString *str_UserImagePrefix;
    NSString *str_NoImagePrefix;
    
    NSString *str_CreateDate;
    NSString *str_OwnerName;
    NSString *str_OwnerThumb;
}
//@property (nonatomic, weak) IBOutlet UITabBar *myTabBar;
@property (nonatomic, strong) NSMutableDictionary *dicM_Data;
@property (nonatomic, strong) NSString *str_ChannelId;
@property (nonatomic, strong) NSString *str_ChannelName;
@property (nonatomic, strong) NSString *str_BoardQuestionId;
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, weak) IBOutlet UILabel *lb_TmpTitle;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet UIView *v_Header;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Header;
@property (nonatomic, weak) IBOutlet UIView *v_Navi;
@property (nonatomic, weak) IBOutlet UIImageView *iv_NaviBg;
@property (nonatomic, weak) IBOutlet UILabel *lb_MainTitle;
@property (nonatomic, weak) IBOutlet UIButton *btn_Write;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_TitleBottom;




@property (nonatomic, strong) NSMutableArray *arM_SubjectList;
@property (nonatomic, weak) IBOutlet UIView *v_ChannelModeHeader;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_ChannelModeSubjectList;
@property (nonatomic, weak) IBOutlet UIActivityIndicatorView *indicator;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_SubjectHeight;

@property (nonatomic, weak) IBOutlet UILabel *lb_HeaderTitle;
@property (nonatomic, weak) IBOutlet UIButton *btn_HeaderMemeberCount;
@property (nonatomic, weak) IBOutlet UIButton *btn_HeaderAdd;
@property (nonatomic, weak) IBOutlet UIButton *btn_TailAdd;
@end

@implementation MainChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSArray *ar_ExamInfos = [self.dic_ChannelInfo objectForKey:@"examInfos"];
    if( ar_ExamInfos.count > 0 )
    {
        NSDictionary *dic = [ar_ExamInfos firstObject];
        self.str_ChannelName = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelName"]];
        self.str_ChannelId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]];
    }
    else
    {
        self.str_ChannelName = @"";
        self.str_ChannelId = @"";
    }

    self.lb_TmpTitle.text = self.lb_MainTitle.text = self.lb_HeaderTitle.text = self.str_ChannelName;
    
    self.btn_Write.layer.cornerRadius = 16.f;

//    self.tbv_List.tableHeaderView = self.v_ChannelModeHeader;

    self.tbv_List.parallaxHeader.view = self.v_ChannelModeHeader; // You can set the parallax header view from the floating view.
    self.tbv_List.parallaxHeader.height = 320.f;
    self.tbv_List.parallaxHeader.mode = MXParallaxHeaderModeFill;
    self.tbv_List.parallaxHeader.minimumHeight = 114;
    self.tbv_List.parallaxHeader.delegate = self;

    

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    
    [self updateTopList];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillLayoutSubviews {
    
//    CGRect tabFrame = self.myTabBar.frame; //self.TabBar is IBOutlet of your TabBar
//    tabFrame.size.height = 45.f;
//    tabFrame.origin.y = self.view.frame.size.height - 45.f;
//    self.myTabBar.frame = tabFrame;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)updateTopList
{
    //
    __weak __typeof__(self) weakSelf = self;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/my"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                weakSelf.str_BoardQuestionId = [NSString stringWithFormat:@"%@", [resulte objectForKey_YM:@"boardQuestionId"]];
                                                
                                                NSString *str_ImageUrl = [NSString stringWithFormat:@"%@", [resulte objectForKey_YM:@"channelImgUrl"]];
                                                [weakSelf.iv_Header sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
                                                
                                                str_CreateDate = [NSString stringWithFormat:@"%@", [resulte objectForKey:@"channelCreateDate"]];
                                                str_OwnerName = [NSString stringWithFormat:@"%@", [resulte objectForKey:@"channelOwnerName"]];
                                                str_OwnerThumb = [NSString stringWithFormat:@"%@", [resulte objectForKey:@"channelOwnerThumbnail"]];
                                                
                                                [self updateList];
                                            }
                                        }
                                    }];
}

- (void)updateList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/my"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        //                                        [UIView animateWithDuration:0.3f
                                        //                                                         animations:^{
                                        //                                                            self.view.alpha = YES;
                                        //                                                         }];
                                        if( resulte )
                                        {
                                            NSLog(@"resulte : %@", resulte);
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                self.dicM_Data = [NSMutableDictionary dictionaryWithDictionary:resulte];
                                                //
                                                //
                                                NSInteger nManagerCnt = [[self.dicM_Data objectForKey_YM:@"channelManagerCount"] integerValue];
                                                NSInteger nMemberCnt = [[self.dicM_Data objectForKey_YM:@"channelMemberCount"] integerValue];
                                                [self.btn_HeaderMemeberCount setTitle:[NSString stringWithFormat:@"멤버 %ld", nManagerCnt + nMemberCnt] forState:UIControlStateNormal];
                                                
                                                NSInteger nTotalQCount = [[self.dicM_Data objectForKey_YM:@"channelExamCount"] integerValue];
                                                if( nTotalQCount > 0 )
                                                {
                                                    self.lc_SubjectHeight.constant = 50.f;
                                                    [self.view setNeedsUpdateConstraints];
                                                    [UIView animateWithDuration:.1f animations:^{
                                                        [self.view layoutIfNeeded];
                                                    }];

                                                    self.tbv_List.parallaxHeader.minimumHeight = 114.f;
                                                    [self updateData];
                                                }
                                                else
                                                {
                                                    //문제가 하나도 없을때 만든 정보 보여주기
                                                    self.lc_SubjectHeight.constant = 0.f;
                                                    [self.view setNeedsUpdateConstraints];
                                                    [UIView animateWithDuration:.1f animations:^{
                                                        [self.view layoutIfNeeded];
                                                    }];

                                                    self.tbv_List.parallaxHeader.minimumHeight = 0.f;
                                                    self.arM_List = [NSMutableArray array];
                                                    [self.arM_List addObject:@{@"type":@"empty"}];
                                                    [self.tbv_List reloadData];
                                                }
                                                
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                        
                                        [self.indicator stopAnimating];
                                    }];
}

- (void)updateData
{
    self.arM_SubjectList = [NSMutableArray array];
//    [self.arM_SubjectList addObject:@{@"subjectName":@"레포트",
//                                      @"examCount":[NSString stringWithFormat:@"%@", [self.dicM_Data objectForKey:@"reportCount"]]}];
    
    [self.arM_SubjectList addObject:@{@"subjectName":@"최신",
                                      @"examCount":[NSString stringWithFormat:@"%@", [self.dicM_Data objectForKey:@"channelExamCount"]]}];
    
    [self.arM_SubjectList addObjectsFromArray:[self.dicM_Data objectForKey:@"channelExamSubjectNameInfos"]];
    [self updateSubjectList];
    
    [self.tbv_List reloadData];
}

- (void)updateSubjectList
{
    BOOL isFirst = YES;
    
    UIScrollView *sv = self.sv_ChannelModeSubjectList;
    
    for( id subView in sv.subviews )
    {
        if( [subView isKindOfClass:[UIButton class]] )
        {
            isFirst = NO;
        }
    }
    
    for( id subView in self.sv_ChannelModeSubjectList.subviews )
    {
        if( [subView isKindOfClass:[UIButton class]] )
        {
            isFirst = NO;
        }
    }
    
    if( isFirst )
    {
        for( NSInteger i = 0; i < self.arM_SubjectList.count; i++ )
        {
            NSDictionary *dic = self.arM_SubjectList[i];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = i;
            btn.frame = CGRectMake(i * 70, 0, 70, 50);
            btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            [btn.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
            
            NSString *str_Title = [NSString stringWithFormat:@"%@\n%@", [dic objectForKey:@"examCount"], [dic objectForKey:@"subjectName"]];
            [btn setTitle:str_Title forState:UIControlStateNormal];
            
            if( [[dic objectForKey:@"subjectName"] isEqualToString:@"레포트"] )
            {
                [btn setTitleColor:[UIColor colorWithHexString:@"4FB826"] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(onReportTouchDown:) forControlEvents:UIControlEventTouchDown];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                [btn setBackgroundImage:BundleImage(@"rect_green.png") forState:UIControlStateHighlighted];
            }
            else
            {
                [btn setTitleColor:kMainColor forState:UIControlStateNormal];
                [btn setTitleColor:kMainColor forState:UIControlStateHighlighted];
            }
            
            if( [[dic objectForKey:@"subjectName"] isEqualToString:@"최신"] )
            {
                btn.selected = YES;
            }
            
            [btn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            
            [btn addTarget:self action:@selector(onMenuSelected:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.sv_ChannelModeSubjectList addSubview:btn];
        }
        
        self.sv_ChannelModeSubjectList.contentSize = CGSizeMake(70 * self.arM_SubjectList.count, 0);
        
        [self updateTableView:@"최신"];
    }
}

- (void)updateTableView:(NSString *)aSubject
{
    if( [aSubject isEqualToString:@"레포트"] )
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Channel" bundle:nil];
        ChannelReportViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChannelReportViewController"];
        vc.str_ChannelId = self.str_ChannelId;
        [self.navigationController pushViewController:vc animated:YES];
        
        return;
    }
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        @"channel", @"channelType",
                                        @"", @"channelHashTag",
                                        nil];
    
    if( [aSubject isEqualToString:@"최신"] )
    {
        [dicM_Params setObject:@"0" forKey:@"subjectName"];
    }
    else
    {
        [dicM_Params setObject:aSubject forKey:@"subjectName"];
    }
    
    //    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/package/exam/browse"
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/my/exam" //02.10일 제권님이 api를 바꿔달라는 요청으로 수정함
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                self.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"examListInfos"]];
                                                [self.tbv_List reloadData];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

- (void)onMenuSelected:(UIButton *)btn
{
    NSDictionary *dic = self.arM_SubjectList[btn.tag];
    
//    if( btn.tag != 0 )
//    {
        UIScrollView *sv = self.sv_ChannelModeSubjectList;
        
        for( id subView in sv.subviews )
        {
            if( [subView isKindOfClass:[UIButton class]] )
            {
                UIButton *btn_Sub = (UIButton *)subView;
                btn_Sub.selected = NO;
            }
        }
        
        btn.selected = YES;
//    }
    
    [self updateTableView:[dic objectForKey:@"subjectName"]];
}

- (void)onReportTouchDown:(UIButton *)btn
{
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setBackgroundImage:BundleImage(@"rect_green.png") forState:UIControlStateNormal];
    [self performSelector:@selector(onRemoveInteraction:) withObject:btn afterDelay:0.5f];
}

- (void)onRemoveInteraction:(UIButton *)btn
{
    [btn setTitleColor:[UIColor colorWithHexString:@"4FB826"] forState:UIControlStateNormal];
    [btn setBackgroundImage:BundleImage(@"") forState:UIControlStateNormal];
}


#pragma mark <MXParallaxHeaderDelegate>

- (void)parallaxHeaderDidScroll:(MXParallaxHeader *)parallaxHeader {
//    NSLog(@"progress %f", parallaxHeader.progress);
    
    self.btn_TailAdd.alpha = self.iv_NaviBg.alpha = 1 - parallaxHeader.progress;
//    self.btn_TailAdd.alpha = 1 - (parallaxHeader.progress + 0.5f);
    
    CGFloat f = -100 * (parallaxHeader.progress - 0.1);
    if( f < 0 )
    {
        self.lc_TitleBottom.constant = f;
    }
    else
    {
        self.lc_TitleBottom.constant = 0;
    }
    
    static BOOL isInit = YES;
    if( parallaxHeader.progress <= 1.0 )
    {
        isInit = YES;
    }
    
    if( parallaxHeader.progress > 1.5 && isInit == YES )
    {
        if( self.indicator.hidden )
        {
            isInit = NO;
            [self.indicator startAnimating];
            [self updateList];
        }
    }
}

//#pragma mark <UITableViewDelegate>
//
//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
//    self.tbv_List.parallaxHeader.height = indexPath.row * 10;
//}
//
//#pragma mark <UITableViewDataSource>
//
//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 50;
//}
//
//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
//    cell.textLabel.text = [NSString stringWithFormat:@"Height %ld", (long)indexPath.row * 10];
//    return cell;
//}


#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.arM_List.count;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MyQuestionListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyQuestionListCell"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    cell.v_Base.clipsToBounds = YES;
    cell.v_Base.layer.borderColor = [UIColor colorWithRed:200.f/255.f green:200.f/255.f blue:200.f/255.f alpha:1].CGColor;
    cell.v_Base.layer.borderWidth = 0.5f;
    
    cell.btn_Group.tag = cell.btn_Result.tag = indexPath.section;
    
    NSDictionary *dic = self.arM_List[indexPath.section];
    
    if( [[dic objectForKey:@"type"] isEqualToString:@"empty"] )
    {
        MainChannelEmptyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MainChannelEmptyCell"];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        if( str_OwnerThumb && str_OwnerName && str_CreateDate )
        {
            [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_OwnerThumb]];
            cell.lb_UserName.text = str_OwnerName;
            cell.lb_Time.text = [Util getDday:str_CreateDate];
            cell.lb_Contents.text = [NSString stringWithFormat:@"%@님이 토팅에 채널을 만들었습니다.\n문제등 컨텐츠를 올리고 같이 할 회원을 초대하세요.", str_OwnerName];
        }

        return cell;
    }
    
    //    //채널관리자가 왔을때 내 나와바리 여부에 따른 처리
    //    if( self.isManagerView )
    //    {
    //        //관리자가 들어 왔을시
    //        //            if( self.isPermission && [[dic objectForKey:@"isChannelAdmin"] isEqualToString:@"Y"] )
    //        if( 1 )
    //        {
    //            //권한이 있고, 이 채널의 어드민이면
    //            cell.v_Progess.alpha = cell.btn_Result.alpha = cell.btn_Group.alpha = YES;
    //        }
    //        else
    //        {
    //            cell.v_Progess.alpha = cell.btn_Result.alpha = cell.btn_Group.alpha = NO;
    //        }
    //    }
    
    cell.iv_Thumb.backgroundColor = [UIColor colorWithHexString:[dic objectForKey_YM:@"codeHex"]];
    
    //문제집 제목
    cell.lb_QuestionTitle.text = [dic objectForKey:@"subjectName"];
    
    //제목
    cell.lb_Title.text = [dic objectForKey:@"examTitle"];
    
    //학교 학년
    cell.lb_Grade.text = [NSString stringWithFormat:@"%@  문제 %@  USER %@명",
                          [dic objectForKey:@"schoolGrade"], [dic objectForKey:@"questionCount"], [dic objectForKey:@"examUniqueUserCount"]];
    
    
    cell.v_Progess.hidden = cell.v_Star.hidden = YES;
    
    CGFloat fTotalCnt = [[dic objectForKey:@"questionCount"] floatValue];
    CGFloat fFinishCnt = [[dic objectForKey:@"solveQuestionCount"] floatValue];
    
    CGFloat fFinishPer = fFinishCnt / fTotalCnt;
    cell.lc_ProgressWidth.constant = cell.lc_ProgressBgWidth.constant * fFinishPer;
    
    if( [[dic objectForKey_YM:@"isPaid"] isEqualToString:@"paid"] )
    {
        //구매한 문제
        cell.v_Progess.hidden = NO;
        cell.v_Star.hidden = YES;
        
        CGFloat fTotalCnt = [[dic objectForKey:@"questionCount"] floatValue];
        CGFloat fFinishCnt = [[dic objectForKey:@"solveQuestionCount"] floatValue];
        
        CGFloat fFinishPer = fFinishCnt / fTotalCnt;
        cell.lc_ProgressWidth.constant = cell.lc_ProgressBgWidth.constant * fFinishPer;
    }
    else
    {
        //구매 하지 않은 문제
        cell.v_Progess.hidden = YES;
        cell.v_Star.hidden = NO;
        
        NSInteger nStar = [[dic objectForKey:@"avgStarCount"] integerValue];
        switch (nStar)
        {
            case 0:
                cell.iv_Star1.image = BundleImage(@"star_empty.png");
                cell.iv_Star2.image = BundleImage(@"star_empty.png");
                cell.iv_Star3.image = BundleImage(@"star_empty.png");
                cell.iv_Star4.image = BundleImage(@"star_empty.png");
                cell.iv_Star5.image = BundleImage(@"star_empty.png");
                break;
                
            case 1:
                cell.iv_Star1.image = BundleImage(@"star_fill.png");
                cell.iv_Star2.image = BundleImage(@"star_empty.png");
                cell.iv_Star3.image = BundleImage(@"star_empty.png");
                cell.iv_Star4.image = BundleImage(@"star_empty.png");
                cell.iv_Star5.image = BundleImage(@"star_empty.png");
                break;
                
            case 2:
                cell.iv_Star1.image = BundleImage(@"star_fill.png");
                cell.iv_Star2.image = BundleImage(@"star_fill.png");
                cell.iv_Star3.image = BundleImage(@"star_empty.png");
                cell.iv_Star4.image = BundleImage(@"star_empty.png");
                cell.iv_Star5.image = BundleImage(@"star_empty.png");
                break;
                
            case 3:
                cell.iv_Star1.image = BundleImage(@"star_fill.png");
                cell.iv_Star2.image = BundleImage(@"star_fill.png");
                cell.iv_Star3.image = BundleImage(@"star_fill.png");
                cell.iv_Star4.image = BundleImage(@"star_empty.png");
                cell.iv_Star5.image = BundleImage(@"star_empty.png");
                break;
                
            case 4:
                cell.iv_Star1.image = BundleImage(@"star_fill.png");
                cell.iv_Star2.image = BundleImage(@"star_fill.png");
                cell.iv_Star3.image = BundleImage(@"star_fill.png");
                cell.iv_Star4.image = BundleImage(@"star_fill.png");
                cell.iv_Star5.image = BundleImage(@"star_empty.png");
                break;
                
            case 5:
                cell.iv_Star1.image = BundleImage(@"star_fill.png");
                cell.iv_Star2.image = BundleImage(@"star_fill.png");
                cell.iv_Star3.image = BundleImage(@"star_fill.png");
                cell.iv_Star4.image = BundleImage(@"star_fill.png");
                cell.iv_Star5.image = BundleImage(@"star_fill.png");
                break;
                
            default:
                break;
        }
    }
    
    cell.btn_Info.tag = indexPath.section;
    [cell.btn_Info addTarget:self action:@selector(onItemInfo:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.arM_List[indexPath.section];

    if( [[dic objectForKey:@"type"] isEqualToString:@"empty"] )
    {
        return 120.f;
    }
    
    return 100.f;
}


// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    //    if( self.isManagerView )    return;
    
    NSDictionary *dic = self.arM_List[indexPath.section];
    
    if( [[dic objectForKey:@"type"] isEqualToString:@"empty"] )
    {
        return;
    }
    
    QuestionStartViewController  *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"QuestionStartViewController"];
    //        vc.hidesBottomBarWhenPushed = YES;
    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
    vc.str_StartIdx = @"0";
    vc.str_Title = [dic objectForKey:@"examTitle"];
    vc.str_UserIdx = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
    vc.isPdf = [[dic objectForKey:@"examType"] isEqualToString:@"pdfExam"];
    vc.str_ChannelId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]];
    
    [self.navigationController pushViewController:vc animated:YES];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
//{
//    return 10.f;
//}
//
//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *v_Section = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10)];
//    v_Section.backgroundColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1];
//    return v_Section;
//}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    //    //푸터 고정
//    //    CGFloat sectionFooterHeight = 70.f;
//    //    CGFloat tableViewHeight = self.tbv_List.frame.size.height;
//    //
//    //    if( scrollView.contentOffset.y == tableViewHeight )
//    //    {
//    //        scrollView.contentInset = UIEdgeInsetsMake(0, 0,-scrollView.contentOffset.y, 0);
//    //    }
//    //    else if ( scrollView.contentOffset.y >= sectionFooterHeight + self.tbv_List.frame.size.height )
//    //    {
//    //        scrollView.contentInset = UIEdgeInsetsMake(0, 0,-sectionFooterHeight, 0);
//    //    }
//    
//    if( scrollView == self.tbv_List )
//    {
//        //    헤더고정
//        CGFloat sectionHeaderHeight = 10.f;
//        if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0)
//        {
//            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
//        }
//        else if (scrollView.contentOffset.y>=sectionHeaderHeight)
//        {
//            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
//        }
//    }
//}


- (void)onItemInfo:(UIButton *)btn
{
    NSDictionary *dic = self.arM_List[btn.tag];
    
    __block NSString *str_ExamId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"examId"]];
    
    NSMutableArray *arM_Test = [NSMutableArray array];
    [arM_Test addObject:@{@"type":@"info", @"contents":[dic objectForKey:@"examTitle"]}];
    [arM_Test addObject:@{@"type":@"share", @"contents":@"공유"}];
    
    //단원보기 버튼 유무
    NSInteger nGroupId = [[dic objectForKey:@"groupId"] integerValue];
    if( nGroupId > 0 )
    {
        [arM_Test addObject:@{@"type":@"normal", @"contents":@"단원보기"}];
    }
    
    
    //결과보기 버튼 유무
    NSInteger nFinishCount = [[dic objectForKey:@"isFinishCount"] integerValue];
    NSInteger nSolve = [[dic objectForKey:@"isSolve"] integerValue];
    if( nFinishCount > 0 || nSolve == 1 )
    {
        //표시
        [arM_Test addObject:@{@"type":@"result", @"contents":@"결과보기"}];
    }
    
    BOOL isChannelManagerRequest = [[self.dicM_Data objectForKey:@"isChannelManagerRequest"] boolValue];
    if( isMannager && isChannelManagerRequest == NO )
    {
        NSString *str_Shared = [dic objectForKey:@"OpenYn"];
        if( [str_Shared isEqualToString:@"Y"] )
        {
            [arM_Test addObject:@{@"type":@"toggle", @"contents":@"회원에게만 공유", @"value":@"Y"}];
        }
        else
        {
            [arM_Test addObject:@{@"type":@"toggle", @"contents":@"회원에게만 공유", @"value":@"N"}];
        }
    }
    
    if( [[dic objectForKey:@"isPaid"] isEqualToString:@"paid"] )
    {
        //구매 했을 경우에만 별점 띄우기
        [arM_Test addObject:@{@"type":@"star", @"contents":@"평가", @"data":dic}];
    }
    
    ActionSheetBottomViewController *vc = [kEtcBoard instantiateViewControllerWithIdentifier:@"ActionSheetBottomViewController"];
    vc.arM_List = arM_Test;
    [vc setCompletionStarBlock:^(id completeResult) {
        
        [self.arM_List replaceObjectAtIndex:btn.tag withObject:completeResult];
    }];
    
    [vc setCompletionBlock:^(id completeResult) {
        
        NSString *str_Type = [completeResult objectForKey:@"type"];
        if( [str_Type isEqualToString:@"info"] )
        {
            //정보
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            QuestionDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"QuestionDetailViewController"];
            vc.str_Idx = [NSString stringWithFormat:@"%@", [dic objectForKey:@"examId"]];
            vc.str_Title = [dic objectForKey:@"examTitle"];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if( [str_Type isEqualToString:@"share"] )
        {
            //공유
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chatting" bundle:nil];
            SharedViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SharedViewController"];
            vc.hidesBottomBarWhenPushed = YES;
            vc.str_ExamId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"examId"]];
            vc.str_QuestionId = @"0";
            vc.str_ChannelId =  self.str_ChannelId;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if( [str_Type isEqualToString:@"normal"] )
        {
            //단원보기
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
            GroupWebViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"GroupWebViewController"];
            vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"groupId"] integerValue]];
            vc.str_GroupName = [dic objectForKey_YM:@"groupName"];
            vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if( [str_Type isEqualToString:@"result"] )
        {
            //결과보기
            NSInteger nGrade = [[dic objectForKey:@"personGrade"] integerValue];
            NSString *str_Grade = [NSString stringWithFormat:@"%@ %@학년", [dic objectForKey:@"schoolGrade"], nGrade == 0 ? @"전체" : [NSString stringWithFormat:@"%ld", nGrade]];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
            ReportDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ReportDetailViewController"];
            vc.str_Title = [NSString stringWithFormat:@"%@ %@ %@", [dic objectForKey:@"subjectName"], str_Grade, [dic objectForKey:@"publisherName"]];
            vc.str_ExamId = [dic objectForKey:@"examId"];
            vc.str_PUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
            [self presentViewController:vc animated:YES completion:^{
                
            }];
        }
        else if( [str_Type isEqualToString:@"toggle"] )
        {
            NSNumber *num = [completeResult objectForKey:@"onOff"];
            BOOL isOnOff = [num boolValue];
            [self onSharedChange:isOnOff withExamId:str_ExamId withIdx:btn.tag];
        }
    }];
    
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (void)onSharedChange:(BOOL)isOnOff withExamId:(NSString *)aExamId withIdx:(NSInteger)nIdx
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        aExamId, @"examId",
                                        isOnOff ? @"C" : @"Y", @"setMode",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/exam/only/channel/open"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:self.arM_List[nIdx]];
                                                if( [[dicM objectForKey:@"OpenYn"] isEqualToString:@"Y"] )
                                                {
                                                    [dicM setObject:@"N" forKey:@"OpenYn"];
                                                }
                                                else
                                                {
                                                    [dicM setObject:@"Y" forKey:@"OpenYn"];
                                                }
                                                [self.arM_List replaceObjectAtIndex:nIdx withObject:dicM];
                                                [self.tbv_List reloadData];
                                                //                                                [self updateList];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}














- (IBAction)goHome:(id)sender
{
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.isChannelMode = NO;
    
    NSArray *myViewControllers = appDelegate.vc_Main.viewControllers;
    for (UINavigationController *navViewController in myViewControllers)
    {
        UIViewController *ctrl = navViewController.topViewController;
        if( [ctrl isKindOfClass:[ChatFeedMainViewController class]] )
        {
            ChatFeedMainViewController *vc_Tmp = (ChatFeedMainViewController *)ctrl;
            [vc_Tmp updateSendBirdDelegate];    //홈화면에서 메인화면으로 전환 후 샌드버드 델리게이트 업데이트
        }
    }

    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
//    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
//    [appDelegate showMainView];
}

- (IBAction)goAddFeed:(id)sender
{
    if( self.str_BoardQuestionId == nil )
    {
        [Util showToast:@"필수 데이터 누락"];
        return;
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    AddDiscripViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"AddDiscripViewController"];
    [vc setDismissBlock:^(id completeResult) {
        
//        [self updateDList];
    }];
    //    vc.str_Idx = [NSString stringWithFormat:@"%@", [self.dic_CurrentQuestion objectForKey:@"questionId"]];
    vc.str_Idx = self.str_BoardQuestionId;
    vc.isFeedMode = YES;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)goAsk:(id)sender
{
    ChatFeedMainViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"ChatFeedMainViewController"];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    navi.navigationBarHidden = YES;
    navi.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.str_ChannelId = self.str_ChannelId;
    vc.dic_ChannelData = self.dic_ChannelInfo;
    vc.isChannelMode = YES;
    [self presentViewController:navi animated:YES completion:^{
        
    }];
}

- (IBAction)goLibrary:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Channel" bundle:nil];
    ChannelMainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChannelMainViewController"];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    navi.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.isShowNavi = NO;
    vc.str_ChannelId = self.str_ChannelId;
    vc.isChannelMode = YES;
    [self presentViewController:navi animated:YES completion:^{
        
    }];
}

- (IBAction)goMember:(id)sender
{
    UserControllListViewController *vc = [kEtcBoard instantiateViewControllerWithIdentifier:@"UserControllListViewController"];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    navi.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.isMannager = YES;
    vc.str_ChannelId = self.str_ChannelId;
    vc.isChannel = YES;
    vc.str_Mode = @"member";
    vc.isChannelMode = YES;
    [self presentViewController:navi animated:YES completion:^{
        
    }];
}

- (IBAction)goReport:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Channel" bundle:nil];
    ChannelReportViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChannelReportViewController"];
    UINavigationController *navi = [[UINavigationController alloc] initWithRootViewController:vc];
    navi.navigationBarHidden = YES;
    navi.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.isChannelMode = YES;
    vc.str_ChannelId = self.str_ChannelId;
    [self presentViewController:navi animated:YES completion:^{
        
    }];
}

- (IBAction)goMy:(id)sender
{
    UINavigationController *navi = [kMainBoard instantiateViewControllerWithIdentifier:@"MainSideNavi"];
    MainSideMenuViewController *vc = [navi.viewControllers firstObject];
    navi.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    vc.isChannelMode = YES;
    vc.dic_ChannelData = self.dic_ChannelInfo;
    [self presentViewController:navi animated:YES completion:^{
        
    }];
}

- (IBAction)goAddQuestion:(id)sender
{
    //문제 만들기
    
}

@end
