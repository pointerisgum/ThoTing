//
//  ChannelReportViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 12. 9..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "ChannelReportViewController.h"
#import "ActionSheetDatePicker.h"
//#import "ReportOtherTotalMemberCell.h"
#import "MyMainViewController.h"
#import "ReportOtherViewController.h"
#import "YmExtendButton.h"
#import "ChannelReportDetailViewController.h"
#import "UIButton+Extend.h"

@interface ChannelReportDateCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Name;
@property (nonatomic, weak) IBOutlet UILabel *lb_Contents;
@property (nonatomic, weak) IBOutlet UILabel *lb_SubjectName;
@property (nonatomic, weak) IBOutlet UILabel *lb_TotalQCount;
@property (nonatomic, weak) IBOutlet UILabel *lb_MyScore;
@property (nonatomic, weak) IBOutlet UILabel *lb_DoneCount;
@property (nonatomic, weak) IBOutlet UIButton *btn_Detail;
@end

@implementation ChannelReportDateCell
- (void)awakeFromNib {
    [super awakeFromNib];
    [self layoutIfNeeded];
    
    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.width/2;
    self.iv_User.layer.borderWidth = 1.f;
    self.iv_User.layer.borderColor = [UIColor colorWithRed:200.f/255.f green:200.f/255.f blue:200.f/255.f alpha:1].CGColor;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end

@interface ChannelReportHeaderCell : UITableViewCell
@property (nonatomic, weak) IBOutlet UILabel *lb_Name;
@end

@implementation ChannelReportHeaderCell
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
@end


@interface ChannelReportViewController ()
{
    BOOL isLoding;
//    BOOL isMore;    //더보기인지 여부
    NSInteger nTotalCnt;

    NSString *str_ImagePrefix;
    NSString *str_UserImagePrefix;
    NSString *str_NoImagePrefix;
    UITextField *tf_Current;
}
@property (nonatomic, strong) ReportOtherViewController *vc_ReportOtherViewController;
@property (nonatomic, strong) NSMutableArray *arM_List1;
@property (nonatomic, strong) NSMutableArray *arM_List2;
@property (nonatomic, strong) NSMutableArray *arM_List3;
@property (nonatomic, strong) NSMutableArray *arM_Subject;
@property (nonatomic, assign) NSInteger nSubjectIdx;
@property (nonatomic, weak) IBOutlet UISegmentedControl *seg;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Contents;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ContentsWidth;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List1;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List2;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List3;
@property (nonatomic, weak) IBOutlet UIView *v_Tab3;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_SearchRight;
@property (nonatomic, weak) IBOutlet UITextField *tf_SearchDate1;
@property (nonatomic, weak) IBOutlet UITextField *tf_SearchDate2;

@property (nonatomic, weak) IBOutlet UIScrollView *sv_Subject;

@property (nonatomic, weak) IBOutlet UIButton *btn_New; //최근
@property (nonatomic, weak) IBOutlet UIButton *btn_Big; //많이 푼

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_SearchHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_SubjectHeight;

@property (nonatomic, weak) IBOutlet UIButton *btn_Calender;

@property (nonatomic, weak) IBOutlet UIButton *btn_Back;
@property (nonatomic, weak) IBOutlet UIButton *btn_Close;

@end

@implementation ChannelReportViewController

- (void)displayContentController: (UIViewController*) content;
{
    [self addChildViewController:content];
    [content.view setFrame:CGRectMake(0.0f, 0.0f, self.v_Tab3.frame.size.width, self.v_Tab3.frame.size.height)];
    [self.v_Tab3 addSubview:content.view];
    [content didMoveToParentViewController:self];
//    self.vc_ChannelMainViewController.navigationController.navigationBarHidden = YES;
}

- (void)hideContentController:(UIViewController *)content
{
    [content willMoveToParentViewController:nil];
    [content.view removeFromSuperview];
    [content removeFromParentViewController];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if( self.isChannelMode )
    {
        self.btn_Back.hidden = YES;
        self.btn_Close.hidden = NO;
    }
    else
    {
        self.btn_Back.hidden = NO;
        self.btn_Close.hidden = YES;
    }
    
    [self getSubjectList];
    [self updateList1];
//    [self updateList3New:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    self.vc_ReportOtherViewController = [storyboard instantiateViewControllerWithIdentifier:@"ReportOtherViewController"];
    self.vc_ReportOtherViewController.str_ChannelId = self.str_ChannelId;
    [self displayContentController:self.vc_ReportOtherViewController];

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidLayoutSubviews
{
    self.sv_Contents.contentSize = CGSizeMake(self.sv_Contents.frame.size.width * 3, self.sv_Contents.frame.size.height);
    self.lc_ContentsWidth.constant = self.sv_Contents.contentSize.width;
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
    isLoding = YES;

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        @"10", @"limitCount",
                                        nil];
    
    if( self.tf_SearchDate1.text.length > 0 && self.tf_SearchDate2.text.length > 0 )
    {
        [dicM_Params setObject:self.tf_SearchDate1.text forKey:@"startDate"];
        [dicM_Params setObject:self.tf_SearchDate2.text forKey:@"endDate"];
        [dicM_Params setObject:@"0" forKey:@"limitCount"];
        
        [self.arM_List1 removeAllObjects];
        self.arM_List1 = nil;
    }
    else if( self.arM_List1 && self.arM_List1.count > 0 )
    {
        NSDictionary *dic = [self.arM_List1 lastObject];
        [dicM_Params setObject:[dic objectForKey:@"lastCondTime"] forKey:@"lastCondTime"];
    }

    __weak __typeof__(self) weakSelf = self;
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/admin/report/daily"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            str_ImagePrefix = [resulte objectForKey:@"img_prefix"];
                                            str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
                                            str_NoImagePrefix = [resulte objectForKey:@"no_image"];

                                            if( weakSelf.arM_List1 == nil || weakSelf.arM_List1.count <= 0 )
                                            {
                                                weakSelf.arM_List1 = [NSMutableArray arrayWithArray:[resulte objectForKey:@"reportData"]];
                                            }
                                            else
                                            {
                                                [weakSelf.arM_List1 addObjectsFromArray:[resulte objectForKey:@"reportData"]];
                                            }
                                            
                                            if( weakSelf.arM_List1 == nil || weakSelf.arM_List1.count <= 0 )
                                            {
                                                [weakSelf.navigationController.view makeToast:@"데이터가 없습니다" withPosition:kPositionCenter];
                                            }
                                            [weakSelf.tbv_List1 reloadData];
                                            
                                            isLoding = NO;
                                        }
                                    }];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if( scrollView == self.tbv_List1 && scrollView.contentOffset.y > scrollView.contentSize.height - scrollView.frame.size.height - 20 && self.arM_List1.count > 0 )
//    if( scrollView == self.tbv_List1 && scrollView.contentOffset.y <= 0 && isLoding == NO && self.arM_List1.count > 0 )
    {
        if( isLoding == NO )
        {
            if( self.tf_SearchDate1.text.length <= 0 && self.tf_SearchDate2.text.length <= 0 )
            {
                isLoding = YES;
                [self updateList1];
            }
        }
    }
}

- (void)updateList2
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
//                                        @"", @"examId",//문제별 리스트로 가져오는 경우
//                                        [dic objectForKey:@"subjectName"], @"subjectName", //과목별 리스트로 가져오는 경우
                                        @"", @"startDate",
                                        @"", @"endDate",
                                        nil];
    
    if( self.nSubjectIdx > -1 )
    {
        NSDictionary *dic = self.arM_Subject[self.nSubjectIdx];
        [dicM_Params setObject:[dic objectForKey:@"subjectName"] forKey:@"subjectName"];
    }

    
//    if( self.tf_SearchDate1.text.length > 0 && self.tf_SearchDate2.text.length > 0 )
//    {
//        [dicM_Params setObject:self.tf_SearchDate1.text forKey:@"startDate"];
//        [dicM_Params setObject:self.tf_SearchDate2.text forKey:@"endDate"];
//    }

    __weak __typeof__(self) weakSelf = self;
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/admin/report/daily"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            str_ImagePrefix = [resulte objectForKey:@"img_prefix"];
                                            str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
                                            str_NoImagePrefix = [resulte objectForKey:@"no_image"];
                                            
                                            weakSelf.arM_List2 = [NSMutableArray arrayWithArray:[resulte objectForKey:@"reportData"]];
                                            [weakSelf.tbv_List2 reloadData];
                                        }
                                    }];

}

- (void)getSubjectList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        nil];

    __weak __typeof__(self) weakSelf = self;
     
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/exam/subjectName"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            weakSelf.arM_Subject = [NSMutableArray arrayWithArray:[resulte objectForKey:@"subjectNames"]];
                                            [weakSelf updateSubjectLayout];
                                        }
                                    }];
}

- (void)updateSubjectLayout
{
//    static CGFloat fSubjectWidth = 80.f;
    
    CGFloat fX = 15;
    for( NSInteger i = 0; i < self.arM_Subject.count; i++ )
    {
        NSDictionary *dic = self.arM_Subject[i];
        NSString *str_Text = [dic objectForKey:@"subjectName"];
        if( str_Text.length <= 0 )
        {
            continue;
        }
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(fX, 0, 20 + (str_Text.length * 10), 45);
        [btn setTitle:str_Text forState:UIControlStateNormal];
        [btn setTitleColor:kMainColor forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [btn.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:13.f]];
        if( i == 0 )
        {
            btn.selected = YES;
        }
        
        btn.tag = i;
        [btn addTarget:self action:@selector(onSubjectSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        fX += btn.frame.size.width;
        self.sv_Subject.contentSize = CGSizeMake(fX + 10, self.sv_Subject.contentSize.height);
        
        [self.sv_Subject addSubview:btn];
    }
    
    [self.sv_Subject setNeedsLayout];
    
    if( self.arM_Subject.count > 0 )
    {
        self.nSubjectIdx = 0;
        self.lc_SubjectHeight.constant = 45.f;
    }
    else
    {
        self.nSubjectIdx = -1;
        self.lc_SubjectHeight.constant = 0.f;
    }
    
    [self updateList2];
}

- (void)onSubjectSelected:(UIButton *)btn
{
    for( id subView in self.sv_Subject.subviews )
    {
        if( [subView isKindOfClass:[UIButton class]] )
        {
            UIButton *btn_Sub = (UIButton *)subView;
            btn_Sub.selected = NO;
        }
    }
    
    btn.selected = YES;
    
    self.nSubjectIdx = btn.tag;
    [self updateList2];
}

- (void)updateList3New:(BOOL)isNew
{
    self.btn_New.selected = isNew;
    self.btn_Big.selected = !isNew;

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        nil];
    
    __weak __typeof__(self) weakSelf = self;
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:isNew ? @"v1/get/channel/report/recently" : @"v1/get/channel/report/orderBy/SolveCount"
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
                                                
                                                weakSelf.arM_List3 = [NSMutableArray arrayWithArray:[resulte objectForKey:@"recentlyData"]];
                                                [weakSelf.tbv_List3 reloadData];
                                            }
                                        }
                                    }];
}

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
//    NSString *str_Second = [aDay substringWithRange:NSMakeRange(12, 2)];
    NSString *str_Date = [NSString stringWithFormat:@"%@-%@-%@ %@:%@", str_Year, str_Month, str_Day, str_Hour, str_Minute];
    
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

//- (void)handleSingleTap3:(UIGestureRecognizer *)gestureRecognizer
//{
//    UIView *view = gestureRecognizer.view;
//    
//    NSDictionary *dic_Main = self.arM_List3[view.tag];
//    if( [[dic_Main objectForKey:@"userId"] isEqual:[NSNull null]] )
//    {
//        ALERT(nil, @"유저 정보가 없습니다", nil, @"확인", nil);
//        return;
//    }
//    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    MyMainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
//    vc.isManagerView = YES;
//    vc.isPermission = YES;
//    vc.str_UserIdx = [dic_Main objectForKey:@"userId"];
//    vc.isShowNavi = YES;
//    [self.navigationController pushViewController:vc animated:YES];
//    
//    //    UserPageMainViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"UserPageMainViewController"];
//    //    vc.str_UserIdx = [Util transIntToString:[dic_Main objectForKey:@"userId"]];
//    //    [self.navigationController pushViewController:vc animated:YES];
//}


#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if( tableView == self.tbv_List1 )
    {
        return self.arM_List1.count;
    }
    else if( tableView == self.tbv_List2 )
    {
        return self.arM_List2.count;
    }
    
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if( tableView == self.tbv_List1 )
    {
        NSDictionary *dic = self.arM_List1[section];
        NSArray *ar_List = [dic objectForKey:@"userInfo"];
        return ar_List.count;
    }
    else if( tableView == self.tbv_List2 )
    {
        NSDictionary *dic = self.arM_List2[section];
        NSArray *ar_List = [dic objectForKey:@"userInfo"];
        return ar_List.count;
    }
    else if( tableView == self.tbv_List3 )
    {
        return self.arM_List3.count;
    }
    
    return 0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if( tableView == self.tbv_List1 )
    {
        ChannelReportDateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelReportDateCell"];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

        NSDictionary *dic_Main = self.arM_List1[indexPath.section];
        NSArray *ar_List = [dic_Main objectForKey:@"userInfo"];
        NSDictionary *dic = ar_List[indexPath.row];
        
        NSURL *url = [Util createImageUrl:str_UserImagePrefix withFooter:[dic objectForKey_YM:@"imgUrl"]];
        [cell.iv_User sd_setImageWithURL:url placeholderImage:BundleImage(@"no_image.png")];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTap1:)];
        [singleTap setNumberOfTapsRequired:1];
        [cell.iv_User addGestureRecognizer:singleTap];
        cell.iv_User.userInteractionEnabled = YES;
        cell.iv_User.tag = (indexPath.section * 100) + indexPath.row;
        
        cell.lb_Name.text = [dic objectForKey:@"name"];
        
        cell.btn_Detail.tag = [[NSString stringWithFormat:@"%ld", (indexPath.section * 100) + indexPath.row] integerValue];
        [cell.btn_Detail addTarget:self action:@selector(onDetail:) forControlEvents:UIControlEventTouchUpInside];
        
        NSArray *ar_Solve = [dic objectForKey:@"solveInfo"];
        if( ar_Solve && ar_Solve.count > 0 )
        {
            NSDictionary *dic_Solve = [ar_Solve firstObject];
            cell.lb_Contents.text = [dic_Solve objectForKey:@"examTitle"];
            
            NSInteger fTotalCount = [[dic_Solve objectForKey:@"examQuestionCount"] integerValue];   //전체문제
            NSInteger fDoneCount = [[dic_Solve objectForKey:@"solveQuestionCount"] integerValue];   //푼문제
            NSInteger fPassCount = [[dic_Solve objectForKey:@"correctAnswerCount"] integerValue];   //맞은문제
            NSInteger nTotalRanking = [[dic_Solve objectForKey:@"koreaRank"] integerValue];     //전국등수
            NSInteger nChannelRanking = [[dic_Solve objectForKey:@"channelRank"] integerValue]; //채널등수
            
            cell.lb_SubjectName.text = [dic_Solve objectForKey_YM:@"subjectName"];
            cell.lb_TotalQCount.text = [NSString stringWithFormat:@"문제 %ld", fTotalCount];
//            cell.lb_MyScore.text = [NSString stringWithFormat:@"%ld 점", (NSInteger)(fPassCount/fDoneCount) * 100];
            cell.lb_MyScore.text = [NSString stringWithFormat:@"%@ 점", [dic_Solve objectForKey_YM:@"correctAnswerCount"]];
            cell.lb_DoneCount.text = [NSString stringWithFormat:@"푼문제 %@", [dic_Solve objectForKey:@"solveQuestionCount"]];
        }

        return cell;
    }
    else if( tableView == self.tbv_List2 )
    {
        ChannelReportDateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelReportDateCell"];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        NSDictionary *dic_Main = self.arM_List2[indexPath.section];
        NSArray *ar_List = [dic_Main objectForKey:@"userInfo"];
        NSDictionary *dic = ar_List[indexPath.row];
        
        NSURL *url = [Util createImageUrl:str_UserImagePrefix withFooter:[dic objectForKey_YM:@"imgUrl"]];
        [cell.iv_User sd_setImageWithURL:url placeholderImage:BundleImage(@"no_image.png")];
        
        UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userTap2:)];
        [singleTap setNumberOfTapsRequired:1];
        [cell.iv_User addGestureRecognizer:singleTap];
        cell.iv_User.userInteractionEnabled = YES;
        cell.iv_User.tag = (indexPath.section * 100) + indexPath.row;
        
        cell.lb_Name.text = [dic objectForKey:@"name"];
        
        cell.btn_Detail.tag = [[NSString stringWithFormat:@"%ld", (indexPath.section * 100) + indexPath.row] integerValue];
        [cell.btn_Detail addTarget:self action:@selector(onDetail:) forControlEvents:UIControlEventTouchUpInside];
        
        NSArray *ar_Solve = [dic objectForKey:@"solveInfo"];
        if( ar_Solve && ar_Solve.count > 0 )
        {
            NSDictionary *dic_Solve = [ar_Solve firstObject];
            cell.lb_Contents.text = [dic_Solve objectForKey:@"examTitle"];
            
            NSInteger fTotalCount = [[dic_Solve objectForKey:@"examQuestionCount"] integerValue];   //전체문제
            NSInteger fDoneCount = [[dic_Solve objectForKey:@"solveQuestionCount"] integerValue];   //푼문제
            NSInteger fPassCount = [[dic_Solve objectForKey:@"correctAnswerCount"] integerValue];   //맞은문제
            NSInteger nTotalRanking = [[dic_Solve objectForKey:@"koreaRank"] integerValue];     //전국등수
            NSInteger nChannelRanking = [[dic_Solve objectForKey:@"channelRank"] integerValue]; //채널등수
            
            cell.lb_SubjectName.text = [dic_Solve objectForKey_YM:@"subjectName"];
            cell.lb_TotalQCount.text = [NSString stringWithFormat:@"문제 %ld", fTotalCount];
//            cell.lb_MyScore.text = [NSString stringWithFormat:@"%ld 점", (NSInteger)(fPassCount/fDoneCount) * 100];
            cell.lb_MyScore.text = [NSString stringWithFormat:@"%@ 점", [dic_Solve objectForKey_YM:@"correctAnswerCount"]];
            cell.lb_DoneCount.text = [NSString stringWithFormat:@"푼문제 %@", [dic_Solve objectForKey:@"solveQuestionCount"]];
        }

        return cell;
    }

    return nil;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if( tableView == self.tbv_List1 )
    {
        ChannelReportHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelReportHeaderCell"];
        
        NSDictionary *dic_Main = self.arM_List1[section];
        NSString *str_Date = [NSString stringWithFormat:@"%@", [dic_Main objectForKey:@"lastDateTime"]];
        
        NSRange range = NSMakeRange(0, 4);
        NSString *str_Year = [str_Date substringWithRange:range];
        
        range = NSMakeRange(4, 2);
        NSString *str_Month = [str_Date substringWithRange:range];
        
        range = NSMakeRange(6, 2);
        NSString *str_Day = [str_Date substringWithRange:range];
        
        cell.lb_Name.text = [NSString stringWithFormat:@"%@.%@.%@", str_Year, str_Month, str_Day];
        
        return cell;
    }
    else if( tableView == self.tbv_List2 )
    {
        ChannelReportHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelReportHeaderCell"];
        
        NSDictionary *dic_Main = self.arM_List2[section];
        NSString *str_Date = [NSString stringWithFormat:@"%@", [dic_Main objectForKey:@"lastDateTime"]];
        
        NSRange range = NSMakeRange(0, 4);
        NSString *str_Year = [str_Date substringWithRange:range];
        
        range = NSMakeRange(4, 2);
        NSString *str_Month = [str_Date substringWithRange:range];
        
        range = NSMakeRange(6, 2);
        NSString *str_Day = [str_Date substringWithRange:range];
        
        cell.lb_Name.text = [NSString stringWithFormat:@"%@.%@.%@", str_Year, str_Month, str_Day];
        
        return cell;
    }
    
    return nil;
}



- (void)onDetail:(UIButton *)btn
{
    NSInteger nSection = btn.tag / 100;
    NSInteger nRow = btn.tag % 100;
    NSDictionary *dic = nil;
    
    if( self.seg.selectedSegmentIndex == 0 )
    {
        NSDictionary *dic_Main = self.arM_List1[nSection];
        NSArray *ar_List = [dic_Main objectForKey:@"userInfo"];
        dic = ar_List[nRow];
    }
    else if( self.seg.selectedSegmentIndex == 1 )
    {
        NSDictionary *dic_Main = self.arM_List2[nSection];
        NSArray *ar_List = [dic_Main objectForKey:@"userInfo"];
        dic = ar_List[nRow];
    }
    
    NSArray *ar = [dic objectForKey:@"solveInfo"];
    if( ar.count > 0 )
    {
        NSDictionary *dic = [ar firstObject];
        ChannelReportDetailViewController *vc = [[ChannelReportDetailViewController alloc] initWithNibName:@"ChannelReportDetailViewController" bundle:nil];
        vc.dic_Info = dic;
        vc.str_ChannelId = self.str_ChannelId;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)userTap1:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *view = gestureRecognizer.view;
    
    NSDictionary *dic_Main = self.arM_List1[view.tag / 100];
    NSArray *ar_Tmp = [dic_Main objectForKey:@"userInfo"];
    if( ar_Tmp.count > 0 )
    {
        NSDictionary *dic = ar_Tmp[view.tag % 100];
        
        if( [[dic objectForKey:@"userId"] isEqual:[NSNull null]] )
        {
            ALERT(nil, @"유저 정보가 없습니다", nil, @"확인", nil);
            return;
        }
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MyMainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
        vc.isManagerView = YES;
        vc.isPermission = YES;
        vc.str_UserIdx = [dic objectForKey:@"userId"];
        vc.isShowNavi = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)userTap2:(UIGestureRecognizer *)gestureRecognizer
{
    UIView *view = gestureRecognizer.view;
    
    NSDictionary *dic_Main = self.arM_List2[view.tag / 100];
    NSArray *ar_Tmp = [dic_Main objectForKey:@"userInfo"];
    if( ar_Tmp.count > 0 )
    {
        NSDictionary *dic = ar_Tmp[view.tag % 100];
        
        if( [[dic objectForKey:@"userId"] isEqual:[NSNull null]] )
        {
            ALERT(nil, @"유저 정보가 없습니다", nil, @"확인", nil);
            return;
        }
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MyMainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
        vc.isManagerView = YES;
        vc.isPermission = YES;
        vc.str_UserIdx = [dic objectForKey:@"userId"];
        vc.isShowNavi = YES;
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - IBAction
- (IBAction)goSegChange:(id)sender
{
    [UIView animateWithDuration:0.3f animations:^{
       
        self.sv_Contents.contentOffset = CGPointMake(self.sv_Contents.frame.size.width * self.seg.selectedSegmentIndex, 0);

    }];
    
    if( self.seg.selectedSegmentIndex == 0 )
    {
        self.btn_Calender.hidden = NO;
    }
    else if( self.seg.selectedSegmentIndex == 1 )
    {
        self.btn_Calender.hidden = YES;
    }
    else if( self.seg.selectedSegmentIndex == 2 )
    {
        self.btn_Calender.hidden = YES;
    }
}

- (IBAction)goShowSearch:(id)sender
{
//    if( self.lc_SearchRight.constant < 240.f )
//    {
//        self.lc_SearchRight.constant = 240.f;
//        
//        [UIView animateWithDuration:0.3f animations:^{
//            
//            [self.view layoutIfNeeded];
//        }];
//    }
}

- (IBAction)goCloseSearch:(id)sender
{
    [self goCalenderToggle:nil];
    
//    if( self.lc_SearchRight.constant >= 240.f )
//    {
//        self.lc_SearchRight.constant = 0.f;
//        
//        [UIView animateWithDuration:0.3f animations:^{
//            
//            [self.view layoutIfNeeded];
//        }completion:^(BOOL finished) {
//            
//            self.tf_SearchDate1.text = self.tf_SearchDate2.text = @"";
//            [self updateList1];
//        }];
//    }
}

#pragma mark UITextFieldDelegate
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if( textField == self.tf_SearchDate1 || textField == self.tf_SearchDate2 )
    {
        tf_Current = textField;

        if( textField == self.tf_SearchDate1 )
        {
            NSString *strDate = @"2010-01-01";
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];

            NSDate *date = [[NSDate alloc] init];
            date = [formatter dateFromString:strDate];

            ActionSheetDatePicker *picker = [[ActionSheetDatePicker alloc] initWithTitle:@"검색 시작 날짜"
                                                                          datePickerMode:UIDatePickerModeDate
                                                                            selectedDate:[NSDate date]
                                                                             minimumDate:date
                                                                             maximumDate:[NSDate date]
                                                                                  target:self
                                                                                  action:@selector(onSelectedDate:)
                                                                                  origin:self.view];
            [picker showActionSheetPicker];
        }
        else
        {
            if( self.tf_SearchDate1.text.length <= 0 )
            {
                [self.navigationController.view makeToast:@"시작 날짜를 입력해 주세요" withPosition:kPositionCenter];
                return NO;
            }
            
            NSString *strDate = self.tf_SearchDate1.text;
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"yyyy-MM-dd"];
            
            NSDate *date = [[NSDate alloc] init];
            date = [formatter dateFromString:strDate];

            ActionSheetDatePicker *picker = [[ActionSheetDatePicker alloc] initWithTitle:@"검색 종료 날짜"
                                                                          datePickerMode:UIDatePickerModeDate
                                                                            selectedDate:[NSDate date]
                                                                             minimumDate:date
                                                                             maximumDate:[NSDate date]
                                                                                  target:self
                                                                                  action:@selector(onSelectedDate:)
                                                                                  origin:self.view];
            
            [picker showActionSheetPicker];
        }
        
        return NO;
    }
    
    return YES;
}

- (void)onSelectedDate:(NSDate *)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    
    NSString *str_Date = [formatter stringFromDate:date];
    NSLog(@"%@", str_Date);
    tf_Current.text = str_Date;
    
    if( tf_Current == self.tf_SearchDate2 )
    {
        if( self.tf_SearchDate1.text.length > 0 )
        {
            //검색하기
            [self updateList1];
        }
    }
}

- (IBAction)goNew:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if( btn.selected )  return;
    
    [self updateList3New:YES];
}

- (IBAction)goBig:(id)sender
{
    UIButton *btn = (UIButton *)sender;
    if( btn.selected )  return;

    [self updateList3New:NO];
}

- (IBAction)goCalenderToggle:(id)sender
{
    if( self.lc_SearchHeight.constant == 0 )
    {
        self.lc_SearchHeight.constant = 44.f;
    }
    else if( self.lc_SearchHeight.constant == 44 )
    {
        self.lc_SearchHeight.constant = 0.f;
        
        self.tf_SearchDate1.text = self.tf_SearchDate2.text = @"";
        [self updateList1];
    }
    
    [UIView animateWithDuration:0.3f animations:^{
       
        [self.view layoutIfNeeded];
    }];
}

@end
