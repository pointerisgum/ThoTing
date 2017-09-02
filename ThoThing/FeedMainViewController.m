//
//  FeedMainViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 6. 22..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "FeedMainViewController.h"
//#import "QuestionListSwipeViewController.h"
#import "QuestionContainerViewController.h"
//#import "StarListDetailViewController.h"
#import "FeedBarCell.h"
#import "FeedBalloonCell.h"
#import "ChannelMainViewController.h"
#import "AddDiscripViewController.h"
#import "YmExtendButton.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import "FeedQnaCell.h"
#import "QuestionDiscriptionViewController.h"
#import "ChattingViewController.h"
#import "FeedChatCell.h"
#import "QuestionListViewController.h"
#import "FeedSharedCell.h"
#import "QuestionDetailViewController.h"
#import "YTPlayerView.h"
#import "YmExtendButton.h"
#import "AudioView.h"
#import "ODRefreshControl.h"

@import AVFoundation;
@import MediaPlayer;

@interface FeedMainViewController ()
{
    BOOL isLoding;

    NSInteger nLastChannelExamNotiId;
    NSInteger nLastChannelNotiId;
    NSInteger nLastQnaNotiId;
    
    NSString *str_UserImagePrefix;
    NSString *str_NoImagePrefix;
    NSString *str_ImagePreFix;
    
    NSArray *ar_ColorList;
}
@property (nonatomic, strong) NSMutableArray *ar_List;
@property (nonatomic, strong) FeedBarCell *v_FeedBarCell;
@property (nonatomic, strong) FeedBalloonCell *v_FeedBalloonCell;
@property (nonatomic, strong) FeedQnaCell *v_FeedQnaCell;
@property (nonatomic, strong) FeedChatCell *v_FeedChatCell;
@property (nonatomic, strong) FeedSharedCell *v_FeedSharedCell;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, strong) YTPlayerView *playerView;
@property (nonatomic, strong) AudioView *v_Audio;
@property (nonatomic, strong) MPMoviePlayerViewController *vc_Movie;
@property (nonatomic, strong) ODRefreshControl *refreshControl;

//@property SendBirdChannelListQuery *channelListQuery;

@end

@implementation FeedMainViewController

- (void)updateFeedList:(NSNotification *)noti
{
    [self updateBadgeCount];
    
    [self.ar_List removeAllObjects];
    [self updateList];
}

//- (void)updateBadgeCount
//{
//    NSInteger nBadgeCnt = 0;
//    for( NSInteger i = 0; i < self.ar_List.count; i++ )
//    {
//        NSDictionary *dic = self.ar_List[i];
//        NSString *str_MoveType = [dic objectForKey:@"actionMoveType"];
//        if( [str_MoveType isEqualToString:@"confirm-join"] )
//        {
//            nBadgeCnt++;
//        }
//    }
//    
//    if( nBadgeCnt == 0 )
//    {
//        [[self navigationController] tabBarItem].badgeValue = nil;
//    }
//    else
//    {
//        [[self navigationController] tabBarItem].badgeValue = [NSString stringWithFormat:@"%ld", nBadgeCnt];
//    }
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = NO;
    
//    [self initNaviWithTitle:@"피드" withLeftItem:nil withRightItem:[self rightIngQuestion] withColor:[UIColor colorWithHexString:@"F8F8F8"]];
    [self initNaviWithTitle:@"피드" withLeftItem:nil withRightItem:[self rightIngQuestion] withColor:[UIColor colorWithHexString:@"F8F8F8"]];

    self.v_FeedBarCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([FeedBarCell class])];
    self.v_FeedBalloonCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([FeedBalloonCell class])];
    self.v_FeedQnaCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([FeedQnaCell class])];
    self.v_FeedChatCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([FeedChatCell class])];
    self.v_FeedSharedCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([FeedSharedCell class])];
    
    ar_ColorList = @[@"9ED8EB", @"FDE581", @"DAF180", @"DBD6F1", @"FBDADC", @"E1E1E1"];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateFeedList:) name:kMessageKey object:nil];

    
    NSString *str_UserId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSString *str_UserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
    
//    self.channelListQuery = [SendBird queryChannelList];
//    
//    [SendBird loginWithUserId:str_UserId andUserName:str_UserName andUserImageUrl:nil andAccessToken:kSendBirdApiToken];
//    self.channelListQuery = [SendBird queryChannelList];
    
//    self.refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tbv_List];
//    self.refreshControl.tintColor = kMainYellowColor;
//    [self.refreshControl addTarget:self action:@selector(onRefresh:) forControlEvents:UIControlEventValueChanged];
//    [self.tbv_List addSubview:self.refreshControl];

//    [self startSendBird];
    
    /*
     invite
     MessagingViewController *vc = [[MessagingViewController alloc] init];
     [vc setTitle:@"Messaging Channel"];
     [vc setSenderId:[SendBird getUserId]];
     [vc setSenderDisplayName:[SendBird getUserName]];
     [vc inviteUsers:userIds];
     UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:vc];
     [self presentViewController:nc animated:YES completion:nil];
     */

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    self.navigationController.navigationBarHidden = NO;
    
    [MBProgressHUD hide];
    
    [self.ar_List removeAllObjects];
    self.ar_List = nil;
    [self updateList];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (void)rightIngQuestionPress:(UIButton *)btn
{
    QuestionListViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionListViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onRefresh:(UIRefreshControl *)sender
{
    [self.ar_List removeAllObjects];
    [self updateList];
    [self.refreshControl performSelector:@selector(endRefreshing) withObject:nil afterDelay:0.3];
}

- (void)removeBadgeCount:(NSDictionary *)dic
{
    __weak __typeof__(self) weakSelf = self;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", [dic objectForKey:@"nId"]], @"nId",
                                        [NSString stringWithFormat:@"%@", [dic objectForKey:@"pkId"]], @"pkId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/read/noti"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                NSInteger nBadgeCnt = [[resulte objectForKey:@"notiCount"] integerValue];
                                                if( nBadgeCnt == 0 )
                                                {
                                                    [[weakSelf navigationController] tabBarItem].badgeValue = nil;
                                                    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                                                }
                                                else
                                                {
                                                    [[weakSelf navigationController] tabBarItem].badgeValue = [NSString stringWithFormat:@"%ld", nBadgeCnt];
                                                    [UIApplication sharedApplication].applicationIconBadgeNumber = nBadgeCnt;
                                                    
                                                }
                                            }
                                            else
                                            {
                                                //                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

- (void)updateBadgeCount
{
    __weak __typeof__(self) weakSelf = self;

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/user/noti/unread/count"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                NSInteger nBadgeCnt = [[resulte objectForKey:@"notiCount"] integerValue];
                                                if( nBadgeCnt == 0 )
                                                {
                                                    [[weakSelf navigationController] tabBarItem].badgeValue = nil;
                                                    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
                                                }
                                                else
                                                {
                                                    [[weakSelf navigationController] tabBarItem].badgeValue = [NSString stringWithFormat:@"%ld", nBadgeCnt];
                                                    [UIApplication sharedApplication].applicationIconBadgeNumber = nBadgeCnt;
                                                }
                                            }
                                            else
                                            {
//                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
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

/*
 apiToken = 4096c557bdaa5cab6de6c8c139e8c51d;
 dataType = each;
 limitCount = 10;
 uuid = "40543916-5E94-48E4-AED6-9B4CC1BE8FD8";
 */

/*
 
 */
- (void)updateList
{
    [self updateBadgeCount];

    __weak __typeof__(self) weakSelf = self;

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        @"each", @"dataType",
                                        @"10", @"limitCount",
                                        nil];
    
    if( self.ar_List == nil || self.ar_List.count <= 0 )
    {
//        [dicM_Params setObject:@"" forKey:@"lastNotiId"];
    }
    else
    {
        [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nLastChannelExamNotiId] forKey:@"lastChannelExamNotiId"];
        [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nLastChannelNotiId] forKey:@"lastChannelNotiId"];
        [dicM_Params setObject:[NSString stringWithFormat:@"%ld", nLastQnaNotiId] forKey:@"lastQnaNotiId"];
    }
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/feed/list"
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
                                                str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
                                                str_NoImagePrefix = [resulte objectForKey:@"no_image"];
                                                str_ImagePreFix = [resulte objectForKey:@"img_prefix"];
                                                
                                                nLastChannelExamNotiId = [[resulte objectForKey:@"lastChannelExamNotiId"] integerValue];
                                                nLastChannelNotiId = [[resulte objectForKey:@"lastChannelNotiId"] integerValue];
                                                nLastQnaNotiId = [[resulte objectForKey:@"lastQnaNotiId"] integerValue];
                                                
                                                if( weakSelf.ar_List == nil || weakSelf.ar_List.count <= 0 )
                                                {
                                                    weakSelf.ar_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"feedInfos"]];
                                                }
                                                else
                                                {
                                                    [weakSelf.ar_List addObjectsFromArray:[resulte objectForKey:@"feedInfos"]];
                                                }
                                                
                                                [weakSelf.tbv_List reloadData];
                                                [weakSelf.view setNeedsLayout];

//                                                [weakSelf performSelectorOnMainThread:@selector(onTest1) withObject:nil waitUntilDone:YES];
//                                                [weakSelf performSelector:@selector(onTest2) withObject:nil afterDelay:0.1f];
                                            }
                                        }
                                        
                                        isLoding = NO;
                                    }];
}


- (void)onTest1
{
    self.tbv_List.hidden = YES;
    [self.tbv_List reloadData];
}

- (void)onTest2
{
    [self.tbv_List reloadData];
    self.tbv_List.hidden = NO;
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
    return self.ar_List.count;
}

- (void)configureSharedCell:(FeedSharedCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    for( UIView *subView in cell.contentView.subviews )
    {
        if( subView.tag > 100 )
        {
            [subView removeFromSuperview];
        }
    }

    cell.iv_Thumb.backgroundColor = [UIColor clearColor];
    cell.iv_PdfCover.hidden = YES;
    cell.lb_QTitle.hidden = NO;
    cell.lb_QDiscrip.hidden = NO;
    cell.iv_Thumb.hidden = YES;
    cell.iv_Arrow.hidden = NO;
    cell.btn_Start.hidden = NO;
    cell.lb_Title.text = @"";
    
    NSDictionary *dic = self.ar_List[indexPath.row];
    
    cell.tag = indexPath.row;

    //제목
    cell.lb_Title.text = [dic objectForKey:@"feedContent"];

    //유저 이미지
    NSString *str_UserImageUrl = [dic objectForKey:@"feederImgUrl"];
    if( [str_UserImageUrl isEqualToString:@"no_image"] )
    {
        //유저 이미지가 없을 경우
//        [cell.iv_User sd_setImageWithURL:[Util createImageUrl:@"" withFooter:str_NoImagePrefix]];
        cell.iv_User.image = BundleImage(@"no_image.png");
    }
    else
    {
        //유저 이미지가 있을 경우
//        [cell.iv_User sd_setImageWithURL:[Util createImageUrl:@"" withFooter:str_UserImageUrl]];
        [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_UserImageUrl] placeholderImage:BundleImage(@"no_image.png")];
    }
    
    //공유 메세지
    NSString *str_Message = [dic objectForKey:@"shareComment"];
    if( str_Message && str_Message.length > 0 )
    {
        //메세지 내용이 있으면
        cell.lc_MessageHeight.constant = 15.f;
        cell.lb_SharedMessage.text = str_Message;
    }
    else
    {
        //메세지 내용이 없으면
        cell.lc_MessageHeight.constant = 0.f;
        cell.lb_SharedMessage.text = @"";
    }
    
    //날짜
    NSString *str_Date = [NSString stringWithFormat:@"%@", [dic objectForKey:@"displayTimeMsg"]];
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

    //문제집 커버
    NSString *str_CorverYn = [dic objectForKey:@"useCover"];
    if( [str_CorverYn isEqualToString:@"Y"] )
    {
        //커버 있음
//        cell.lc_ThumbWidth.constant = 80.f;

        NSString *str_CoverImageUrl = [dic objectForKey:@"examCover"];
        [cell.iv_User sd_setImageWithURL:[Util createImageUrl:str_ImagePreFix withFooter:str_CoverImageUrl]];
    }
    else
    {
        //커버 없음
//        cell.lc_ThumbWidth.constant = 0.f;
    }
    
    //문제 타이틀
    cell.lb_QTitle.text = [dic objectForKey:@"examTitle"];
    
    //문제 디스크립션
    NSMutableString *strM_Discrip = [NSMutableString string];
    [strM_Discrip appendString:[NSString stringWithFormat:@"%@ 문제", [dic objectForKey:@"questionCount"]]];
    
    NSString *str_Owner = [dic objectForKey:@"publisherName"];
    if( str_Owner )
    {
        [strM_Discrip appendString:@"\n"];
        [strM_Discrip appendString:str_Owner];
    }
    
    [strM_Discrip appendString:@"\n"];
    [strM_Discrip appendString:[NSString stringWithFormat:@"구매 %@", [dic objectForKey:@"examUserCount"]]];
    
    cell.lb_QDiscrip.text = strM_Discrip;
    
    //구매 여부
    NSString *str_Buy = [dic objectForKey:@"actionMoveType"];
    if( [str_Buy isEqualToString:@"go-solve"] )
    {
        //구매
        cell.iv_Arrow.hidden = YES;
        cell.btn_Start.hidden = NO;

        //공유 종료
        NSString *str_SharedType = [dic objectForKey:@"shareType"];
        if( [str_SharedType isEqualToString:@"exam"] )
        {
            //문제지
            cell.iv_Thumb.hidden = NO;
            cell.lb_CoverTitle.text = [dic objectForKey:@"examTitle"];
            cell.iv_Thumb.backgroundColor = [UIColor colorWithHexString:[dic objectForKey:@"coverBgColorHexCode"]];
        }
        else //question
        {
            //문제
        }
    }
    else //go-detail 이거는 구매 안함
    {
        //구매 안함
        cell.iv_Arrow.hidden = NO;
        cell.btn_Start.hidden = YES;
    }

    NSString *str_QType = [dic objectForKey:@"examType"];
    NSString *str_SharedType = [dic objectForKey:@"shareType"];
    if( [str_SharedType isEqualToString:@"question"] && [str_QType isEqualToString:@"pdf"] )
    {
        //PDF문제 공유일 경우
        cell.iv_PdfCover.hidden = NO;
        cell.lb_QTitle.hidden = YES;
        cell.lb_QDiscrip.hidden = YES;
        cell.iv_Thumb.hidden = YES;
        cell.iv_Arrow.hidden = YES;
        cell.btn_Start.hidden = YES;
        
        NSString *str_PdfCoverUrl = [dic objectForKey:@"examCover"];
        if( str_PdfCoverUrl && str_PdfCoverUrl.length > 0 )
        {
            //커버가 있을 경우
            [cell.iv_PdfCover sd_setImageWithURL:[Util createImageUrl:str_ImagePreFix withFooter:str_PdfCoverUrl]];
            
            CGFloat fWidth = [[dic objectForKey:@"questionWidth"] floatValue];
            CGFloat fHeight = [[dic objectForKey:@"questionHeight"] floatValue];
            CGFloat fScale = (self.view.frame.size.width - 30) / fWidth;
            fHeight *= fScale;
            if( isnan(fHeight) )
            {
                fHeight = 300.f;
            }
            cell.lc_PdfCorverHeight.constant = fHeight;
        }
        else
        {
            //커버가 없을 경우
            cell.lc_PdfCorverHeight.constant = 0.f;
        }
    }
    else if( [str_SharedType isEqualToString:@"question"] && [str_QType isEqualToString:@"normal"] )
    {
        //일반문제 공유일 경우
        cell.iv_PdfCover.hidden = YES;
        cell.lb_QTitle.hidden = YES;
        cell.lb_QDiscrip.hidden = YES;
        cell.iv_Thumb.hidden = YES;
        cell.iv_Arrow.hidden = YES;
        cell.btn_Start.hidden = YES;
        
        __block CGFloat fSampleViewTotalHeight = 110;
        
        NSDictionary *dic_Tmp = [dic objectForKey:@"questionInfo"];
        NSArray *ar_ExamQuestionInfos = [dic_Tmp objectForKey_YM:@"examQuestionInfos"];
        for( NSInteger i = 0; i < ar_ExamQuestionInfos.count; i++ )
        {
            NSDictionary *dic = ar_ExamQuestionInfos[i];
            NSString *str_Type = [dic objectForKey_YM:@"questionType"];
            NSString *str_Body = [dic objectForKey_YM:@"questionBody"];
            //        NSLog(@"%@", str_Type);
            if( [str_Type isEqualToString:@"text"] )
            {
                UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(8, fSampleViewTotalHeight, cell.contentView.frame.size.width - 16, 0)];
                lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(lb_Contents.frame);
                lb_Contents.font = [UIFont fontWithName:@"Helvetica" size:14.f];
                lb_Contents.text = str_Body;
                lb_Contents.numberOfLines = 0;
                lb_Contents.tag = 101;
                
                CGRect frame = lb_Contents.frame;
                frame.size.height = [Util getTextSize:lb_Contents].height;
                lb_Contents.frame = frame;
                
                [cell.contentView addSubview:lb_Contents];
                
                fSampleViewTotalHeight += lb_Contents.frame.size.height + 10;
            }
            else if( [str_Type isEqualToString:@"html"] )
            {
                NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[str_Body dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(cell.contentView.frame.size.width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
                
                UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(8, fSampleViewTotalHeight, cell.contentView.frame.size.width - 16, rect.size.height)];
                lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(lb_Contents.frame);
                lb_Contents.numberOfLines = 0;
                lb_Contents.attributedText = attrStr;
                lb_Contents.tag = 102;
                [cell.contentView addSubview:lb_Contents];
                
                fSampleViewTotalHeight += rect.size.height + 10;
            }
            else if( [str_Type isEqualToString:@"image"] )
            {
                UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(8, fSampleViewTotalHeight, cell.contentView.frame.size.width - 16, 0)];
                iv.contentMode = UIViewContentModeScaleAspectFill;
                iv.clipsToBounds = YES;
                iv.tag = 103;
                
                CGFloat fPer = iv.frame.size.width / [[dic objectForKey:@"width"] floatValue];
                CGFloat fHeight = [[dic objectForKey:@"height"] floatValue] * fPer;
                
                if( isnan(fHeight) )    fHeight = 300.f;
                
                CGRect frame = iv.frame;
                frame.size.height = fHeight;
                iv.frame = frame;
                
                NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, str_Body];
                [iv sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
                
                [cell.contentView addSubview:iv];
                
                fSampleViewTotalHeight += iv.frame.size.height + 10;
                
            }
            else if( [str_Type isEqualToString:@"videoLink"] )
            {
                //유튜브
                self.playerView = [[YTPlayerView alloc] initWithFrame:
                                   CGRectMake(8, fSampleViewTotalHeight, cell.contentView.frame.size.width - 16, (cell.contentView.frame.size.width - 16) * 0.7f)];
                
                NSDictionary *playerVars = @{
                                             @"controls" : @1,
                                             @"playsinline" : @1,
                                             @"autohide" : @1,
                                             @"showinfo" : @0,
                                             @"modestbranding" : @1
                                             };
                
                [self.playerView loadWithVideoId:str_Body playerVars:playerVars];
                self.playerView.tag = 104;
                [cell.contentView addSubview:self.playerView];
                
                fSampleViewTotalHeight += self.playerView.frame.size.height + 10;
            }
            else if( [str_Type isEqualToString:@"audio"] )
            {
                //음성
//                if( self.v_Audio == nil )
//                {
//                    NSString *str_Body = [dic objectForKey:@"questionBody"];
//                    NSString *str_Url = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, str_Body];
//                    
//                    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"AudioView" owner:self options:nil];
//                    self.v_Audio = [topLevelObjects objectAtIndex:0];
//                    [self.v_Audio initPlayer:str_Url];
//                }

                NSString *str_Body = [dic objectForKey:@"questionBody"];
                NSString *str_Url = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, str_Body];
                
                NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"AudioView" owner:self options:nil];
                AudioView *v_Audio = [topLevelObjects objectAtIndex:0];
                v_Audio.userInteractionEnabled = NO;
//                [v_Audio initPlayer:str_Url];
                [v_Audio initPlayer:str_Url whitViewing:YES];

                CGRect frame = v_Audio.frame;
                frame.origin.y = fSampleViewTotalHeight;
                frame.size.width = self.view.bounds.size.width;
                frame.size.height = 48;
                v_Audio.frame = frame;
                
                v_Audio.tag = 105;
                [cell.contentView addSubview:v_Audio];
                
                fSampleViewTotalHeight += v_Audio.frame.size.height + 10;
                
            }
            else if( [str_Type isEqualToString:@"video"] )
            {
                UIView *view = [[UIView alloc]initWithFrame:CGRectMake(8, fSampleViewTotalHeight, cell.contentView.frame.size.width - 16, (cell.contentView.frame.size.width - 16) * 0.7f)];
                
                NSString *str_Url = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, str_Body];
                self.vc_Movie = [[MPMoviePlayerViewController alloc]initWithContentURL:[NSURL URLWithString:str_Url]];
                self.vc_Movie.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
                self.vc_Movie.moviePlayer.repeatMode = MPMovieRepeatModeOne;
                //            vc.moviePlayer.fullscreen = NO;
                //            vc.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
                self.vc_Movie.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
                self.vc_Movie.moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
                self.vc_Movie.moviePlayer.shouldAutoplay = NO;
                self.vc_Movie.moviePlayer.repeatMode = NO;
                //                [self.vc_Movie.moviePlayer setFullscreen:NO animated:NO];
                [self.vc_Movie.moviePlayer prepareToPlay];
                
                [view addSubview:self.vc_Movie.view];
                [cell.contentView addSubview:view];
                view.tag = 106;
                
                [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
                
                fSampleViewTotalHeight += view.frame.size.height + 10;
            }
            
            CGRect frame = cell.frame;
            frame.size.height = fSampleViewTotalHeight;
            cell.frame = frame;
        }
        
        
        //보기입력
        CGFloat fX = 15.f;
        NSArray *ar_ExamUserItemInfos = [dic_Tmp objectForKey_YM:@"examUserItemInfos"];
        for( NSInteger i = 0; i < ar_ExamUserItemInfos.count; i++ )
        {
            NSDictionary *dic = ar_ExamUserItemInfos[i];
            NSString *str_Type = [dic objectForKey_YM:@"type"];
            NSString *str_Body = [dic objectForKey_YM:@"itemBody"];
            NSString *str_Number = [NSString stringWithFormat:@"%@ ", [dic objectForKey_YM:@"printNo"]];
            
            if( [str_Type isEqualToString:@"itemImage"] )
            {
                UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(fX, fSampleViewTotalHeight, 20, 20)];
                UIFont *font = [UIFont fontWithName:@"Helvetica" size:14.f];
                lb_Contents.font = font;
                lb_Contents.numberOfLines = 0;
                lb_Contents.text = str_Number;
                [cell.contentView addSubview:lb_Contents];
                lb_Contents.tag = 111;
                
                UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(fX + 20, fSampleViewTotalHeight, cell.contentView.frame.size.width - (20 + (fX * 2)), 0)];
                iv.contentMode = UIViewContentModeScaleAspectFill;
                iv.clipsToBounds = YES;
                
                NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, str_Body];
                
                NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:str_ImageUrl]];
                UIImage *image = [UIImage imageWithData:imageData];
                UIImage *resizeImage = [Util imageWithImage:image convertToWidth:iv.frame.size.width];
                iv.image = resizeImage;
                
                CGRect frame = iv.frame;
                frame.size.height = resizeImage.size.height;
                iv.frame = frame;
                
                [cell.contentView addSubview:iv];
                iv.tag = 112;
                
                fSampleViewTotalHeight += iv.frame.size.height + 10;
            }
            else
            {
                NSMutableAttributedString * attrStr_Html = [[NSMutableAttributedString alloc] initWithData:[str_Body dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                
                UIFont *font = [UIFont fontWithName:@"Helvetica" size:20.f];
                NSDictionary *dic_Attr = [NSDictionary dictionaryWithObject:font
                                                                     forKey:NSFontAttributeName];
                NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str_Number attributes:dic_Attr];
                [attrStr appendAttributedString:attrStr_Html];
                
                CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(cell.contentView.frame.size.width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
                
                UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(fX, fSampleViewTotalHeight, cell.contentView.frame.size.width - 16, rect.size.height)];
                lb_Contents.numberOfLines = 0;
                lb_Contents.attributedText = attrStr;
                [cell.contentView addSubview:lb_Contents];
                lb_Contents.tag = 113;
                
                fSampleViewTotalHeight += rect.size.height + 10;
            }
            
            CGRect frame = cell.frame;
            frame.size.height = fSampleViewTotalHeight;
            cell.frame = frame;
        }
        
        
        UIButton *btn_DeleteFeed = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_DeleteFeed.tag = indexPath.row;
        [btn_DeleteFeed setFrame:CGRectMake(self.tbv_List.frame.size.width- 60, 10, 60, 60)];
        [btn_DeleteFeed setImage:BundleImage(@"delete_feed.png") forState:UIControlStateNormal];
        btn_DeleteFeed.imageEdgeInsets = UIEdgeInsetsMake(-50, 20, 0, 0);
        [btn_DeleteFeed addTarget:self action:@selector(onDeleteFeed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn_DeleteFeed];
        
        CGRect frame = cell.frame;
        frame.size.height = fSampleViewTotalHeight;
        cell.frame = frame;
    }
    
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.ar_List[indexPath.row];
    NSString *str_Type = [dic objectForKey:@"displayType"];
    NSString *str_MoveType = [dic objectForKey:@"actionMoveType"];
    NSLog(@"feederType : %@", [dic objectForKey:@"feederType"]);
    if( [[dic objectForKey:@"feederType"] isEqualToString:@"share"] )
    {
        //공유
        FeedSharedCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedSharedCell"];
        [self configureSharedCell:cell forRowAtIndexPath:indexPath];
        return cell;
    }
    else if( [str_Type isEqualToString:@"balloon"] )
    {
        //말풍선 형태
        FeedBalloonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedBalloonCell"];
        [self configureBalloonCell:cell forRowAtIndexPath:indexPath];
        return cell;
    }
    else if( [str_Type isEqualToString:@"bar"] && [str_MoveType isEqualToString:@"chatroom-join"] )
    {
        FeedChatCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedChatCell"];
        [self configureChatCell:cell forRowAtIndexPath:indexPath];
//        [self.v_FeedChatCell updateConstraintsIfNeeded];
//        [self.v_FeedChatCell layoutIfNeeded];

        return cell;
    }
    else if( [str_Type isEqualToString:@"bar"] && [str_MoveType isEqualToString:@"chatroom-join"] == NO )
    {
        //나머지는 바 형태
        FeedBarCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedBarCell"];
        [self configureBarCell:cell forRowAtIndexPath:indexPath];
        return cell;
    }
    else
    {
        FeedQnaCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedQnaCell"];
        [self configureQnaCell:cell forRowAtIndexPath:indexPath];
        
        [self.v_FeedQnaCell updateConstraintsIfNeeded];
        [self.v_FeedQnaCell layoutIfNeeded];
        
        return cell;
    }

    return nil;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell *cell = [self.tbv_List cellForRowAtIndexPath:indexPath];

    NSDictionary *dic = self.ar_List[indexPath.row];
    NSString *str_Type = [dic objectForKey:@"displayType"];
    NSString *str_MoveType = [dic objectForKey:@"actionMoveType"];

    if( [str_Type isEqualToString:@"bar"] && [str_MoveType isEqualToString:@"chatroom-join"] )
    {
        //채팅방 초대는 참여하기 버튼으로 들어가야 하기 때문에 셀 선택시 리턴 해버린다
        return;
    }
    
    if( [[dic objectForKey:@"feederType"] isEqualToString:@"share"] )
    {
        //공유 선택시
        //구매 여부
        [self removeBadgeCount:dic];

        NSString *str_Buy = [dic objectForKey:@"actionMoveType"];
        if( [str_Buy isEqualToString:@"go-solve"] )
        {
            //구매
            QuestionContainerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
            vc.hidesBottomBarWhenPushed = YES;
            vc.str_SortType = @"all";
            vc.str_Idx = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%@", [dic objectForKey:@"examId"]]];

            //문제지인지 문제인지 구분
            NSString *str_SharedType = [dic objectForKey:@"shareType"];
            if( [str_SharedType isEqualToString:@"exam"] )
            {
                //문제지
                vc.str_StartIdx = @"0";
            }
            else //question
            {
                //문제
                vc.str_StartIdx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examNo"] integerValue] - 1];
            }
            
            //문제 타입
            NSString *str_QType = [dic objectForKey:@"examType"];
            if( [str_QType isEqualToString:@"normal"] )
            {
                //일반문제
                vc.isPdf = NO;
            }
            else
            {
                //PDF 문제
                vc.isPdf = YES;
                vc.nStartPdfPage = [[dic objectForKey:@"examNo"] integerValue];
            }

            [self.navigationController pushViewController:vc animated:YES];
        }
        else //go-detail 이거는 구매 안함
        {
            //구매 안함
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            QuestionDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"QuestionDetailViewController"];
            vc.str_Idx = [NSString stringWithFormat:@"%@", [NSString stringWithFormat:@"%@", [dic objectForKey:@"examId"]]];
            vc.str_Title = [dic objectForKey:@"examTitle"];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
    else if( [str_Type isEqualToString:@"balloon"] )
    {
        //말풍선 형태
        [self onMore:cell.tag];
    }
    else if( [str_Type isEqualToString:@"bar"] )
    {
        //나머지는 바 형태
        [self onMore:cell.tag];
    }
    else
    {
        NSString *str_FeedType = [dic objectForKey:@"feedType"];
        if( [str_FeedType isEqualToString:@"qna-question"] )    return;
        
        if( [str_FeedType isEqualToString:@"channelQna"] )
        {
            NSLog(@"Qna");
            
            [self removeBadgeCount:dic];

            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chatting" bundle:nil];
            ChattingViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChattingViewController"];
            vc.dic_Info = @{@"questionId" : [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]],
                            @"roomName" : [dic objectForKey:@"roomName"],
                            @"groupId" : [NSString stringWithFormat:@"%@", [dic objectForKey:@"groupId"]]};
//                            @"groupId" : [NSString stringWithFormat:@"%@", @"9470"]};
            vc.isMove = YES;
            vc.str_RId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"rId"]];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if( [str_FeedType isEqualToString:@"channelReply"] )
        {
            NSLog(@"Rep");

            [self removeBadgeCount:dic];

            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chatting" bundle:nil];
            ChattingViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChattingViewController"];
            vc.dic_Info = @{@"questionId" : [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]],
                            @"roomName" : [dic objectForKey:@"roomName"],
                            @"groupId" : [NSString stringWithFormat:@"%@", [dic objectForKey:@"groupId"]]};
//                            @"groupId" : [NSString stringWithFormat:@"%@", @"9470"]};
            vc.isMove = YES;
            vc.str_RId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"rId"]];
            vc.hidesBottomBarWhenPushed = YES;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            NSString *str_Tab = [dic objectForKey:@"goTab"];
            
            [self removeBadgeCount:dic];
            
            QuestionDiscriptionViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionDiscriptionViewController"];
            vc.str_ExamId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"examId"]];
            vc.str_QuestionId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]];
            vc.isQuestion = [str_Tab isEqualToString:@"qna"] ? YES : NO;
            vc.hidesBottomBarWhenPushed = YES;
            //    vc.str_ImagePreFix = self.str_ImagePreFix;
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.ar_List[indexPath.row];
    NSString *str_Type = [dic objectForKey:@"displayType"];
    NSString *str_MoveType = [dic objectForKey:@"actionMoveType"];

    if( [[dic objectForKey:@"feederType"] isEqualToString:@"share"] )
    {
        //공유
        NSString *str_QType = [dic objectForKey:@"examType"];
        NSString *str_SharedType = [dic objectForKey:@"shareType"];
        if( [str_SharedType isEqualToString:@"question"] && [str_QType isEqualToString:@"pdf"] )
        {
            //PDF문제지 공유일 경우
            NSString *str_PdfCoverUrl = [dic objectForKey:@"examCover"];
            if( str_PdfCoverUrl && str_PdfCoverUrl.length > 0 )
            {
                //커버가 있을 경우
                CGFloat fWidth = [[dic objectForKey:@"questionWidth"] floatValue];
//                if( isnan(fWidth) ) fWidth = self.view.frame.size.width - 30;
                CGFloat fHeight = [[dic objectForKey:@"questionHeight"] floatValue];
//                if( isnan(fHeight) ) fHeight = 100;
                CGFloat fScale = (self.view.frame.size.width - 30) / fWidth;
                fHeight *= fScale;
                
                if( isnan(fHeight) ) return 300;

                return fHeight + 120;
            }
            else
            {
                //커버가 없을 경우

            }
        }
        else if( [str_SharedType isEqualToString:@"question"] && [str_QType isEqualToString:@"normal"] )
        {
            [self configureSharedCell:self.v_FeedSharedCell forRowAtIndexPath:indexPath];
            
            [self.v_FeedSharedCell updateConstraintsIfNeeded];
            [self.v_FeedSharedCell layoutIfNeeded];
            
            self.v_FeedSharedCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.v_FeedSharedCell.bounds));
            return self.v_FeedSharedCell.bounds.size.height;
        }
        
        return 214.f;
//        else if( [str_SharedType isEqualToString:@"question"] && [str_QType isEqualToString:@"normal"] )
//        {
//            return 300;
//        }
        
//        [self configureSharedCell:self.v_FeedSharedCell forRowAtIndexPath:indexPath];
//
//        [self.v_FeedSharedCell updateConstraintsIfNeeded];
//        [self.v_FeedSharedCell layoutIfNeeded];
//
//        self.v_FeedSharedCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.v_FeedSharedCell.bounds));
//        return self.v_FeedSharedCell.bounds.size.height;
//        return [self.v_FeedSharedCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 20;
    }
    else if( [str_Type isEqualToString:@"balloon"] )
    {
        //말풍선 형태
//        FeedBalloonCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedBalloonCell"];

        [self configureBalloonCell:self.v_FeedBalloonCell forRowAtIndexPath:indexPath];
        
        [self.v_FeedBalloonCell updateConstraintsIfNeeded];
        [self.v_FeedBalloonCell layoutIfNeeded];
        
        self.v_FeedBalloonCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.v_FeedBalloonCell.bounds));
         
        return [self.v_FeedBalloonCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 20;
    }
    else if( [str_Type isEqualToString:@"bar"] && [str_MoveType isEqualToString:@"chatroom-join"] )
    {
        [self configureChatCell:self.v_FeedChatCell forRowAtIndexPath:indexPath];
        
        [self.v_FeedChatCell updateConstraintsIfNeeded];
        [self.v_FeedChatCell layoutIfNeeded];
        
        self.v_FeedChatCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.v_FeedChatCell.bounds));
        
        return [self.v_FeedChatCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 20;
    }
    else if( [str_Type isEqualToString:@"bar"] && [str_MoveType isEqualToString:@"chatroom-join"] == NO )
    {
//        static FeedBarCell *cell = nil;
//        static dispatch_once_t onceToken;
//        
//        dispatch_once(&onceToken, ^{
//            cell = [self.tbv_List dequeueReusableCellWithIdentifier:@"FeedBarCell"];
//        });
//        
//        [self configureBarCell:cell forRowAtIndexPath:indexPath];
//        
//        [cell layoutIfNeeded];
//        
//        CGSize size = [cell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
//        return size.height;
//
//        
////        return [self calculateHeightForConfiguredSizingCell:cell];

        //바 형태
//        FeedBarCell *cell = [tableView dequeueReusableCellWithIdentifier:@"FeedBarCell"];
        
        [self configureBarCell:self.v_FeedBarCell forRowAtIndexPath:indexPath];
        
        [self.v_FeedBarCell updateConstraintsIfNeeded];
        [self.v_FeedBarCell layoutIfNeeded];
        
        self.v_FeedBarCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.v_FeedBarCell.bounds));
        
        return [self.v_FeedBarCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 20;
    }
    else if( [str_Type isEqualToString:@"application"] )
    {
        [self configureQnaCell:self.v_FeedQnaCell forRowAtIndexPath:indexPath];
        
        [self.v_FeedQnaCell updateConstraintsIfNeeded];
        [self.v_FeedQnaCell layoutIfNeeded];
        
        self.v_FeedQnaCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.v_FeedQnaCell.bounds));
        
//        NSLog(@"cell height : %f", [self.v_FeedQnaCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height);
        return self.v_FeedQnaCell.bounds.size.height + 20;// [self.v_FeedBarCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 20;
//        return [self.v_FeedBarCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 20;

    }
    
    return 0;
}

- (void)addQnaItem:(FeedQnaCell *)cell withData:(NSDictionary *)dic_Main withIndexPath:(NSIndexPath *)indexPath withLeft:(BOOL)isLeft withQna:(BOOL)isQna
{
    __block CGFloat fSampleViewTotalHeight = 20;
    
    [cell.iv_User removeFromSuperview];
    [cell.lb_Name removeFromSuperview];
    [cell.lb_Date removeFromSuperview];

    BOOL isOnlyText = YES;
    
    CGFloat fTextWidth = 20.0f;
    
    NSDictionary *dic_Info = dic_Main;
    
    NSInteger nColorIdx = [[dic_Info objectForKey:@"groupId"] integerValue];
    nColorIdx = (nColorIdx % 6);
    
    UIImageView *iv_Ballon = [[UIImageView alloc] init];
    UIImage *i_Ballon = nil;
    
    NSArray *ar = nil;

    NSInteger nX = 80.f;
    NSInteger nTail = 35.f;
    
    cell.separatorInset = UIEdgeInsetsMake(0, 8, 0, 8);

    if( isQna )
    {
        cell.separatorInset = UIEdgeInsetsMake(0, 1150, 0, 0);
        
        ar = [dic_Info objectForKey:@"data"];
        
        UILabel * lb_Title = [[UILabel alloc] initWithFrame:CGRectMake(8, fSampleViewTotalHeight, self.tbv_List.frame.size.width - 16 - 60, 15)];
//        lb_Title.preferredMaxLayoutWidth = CGRectGetWidth(lb_Title.frame);
        lb_Title.font = [UIFont fontWithName:@"Helvetica" size:14.f];
//        lb_Title.textColor = [UIColor lightGrayColor];
        lb_Title.numberOfLines = 1;
        
        lb_Title.text = [NSString stringWithFormat:@"%@ / %@", [dic_Main objectForKey:@"channelName"], [dic_Main objectForKey:@"roomName"]];
        
//        CGRect frame = lb_Title.frame;
//        frame.size.height = [Util getTextSize:lb_Title].height;
//        lb_Title.frame = frame;
        
        [cell.contentView addSubview:lb_Title];
        
        
        UIButton *btn_DeleteFeed = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_DeleteFeed.tag = indexPath.row;
        [btn_DeleteFeed setFrame:CGRectMake(self.tbv_List.frame.size.width- 60, 10, 60, 60)];
        [btn_DeleteFeed setImage:BundleImage(@"delete_feed.png") forState:UIControlStateNormal];
        btn_DeleteFeed.imageEdgeInsets = UIEdgeInsetsMake(-50, 20, 0, 0);
        [btn_DeleteFeed addTarget:self action:@selector(onDeleteFeed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn_DeleteFeed];
        
        fSampleViewTotalHeight += 35.f;
    }
    else
    {
        //댓글이 몇번째 댓글인지 내려주기로 했음
        ar = [dic_Info objectForKey:@"data"];
    }
    
    if( isLeft )
    {
        NSString *str_ImageName = [NSString stringWithFormat:@"bubble_%ld.png", nColorIdx + 1];
        
        UIImage *i_Ballon = BundleImage(str_ImageName);
        i_Ballon = [Util makeNinePatchImage:i_Ballon];
        [iv_Ballon setImage:i_Ballon];
        
        nX = 80.f;
        nTail = 35.f;
    }
    else
    {
        NSString *str_ImageName = [NSString stringWithFormat:@"bubble_min_reverse_%ld.png", nColorIdx + 1];
        
        UIImage *i_Ballon = BundleImage(str_ImageName);
        i_Ballon = [Util makeNinePatchImage:i_Ballon];
        [iv_Ballon setImage:i_Ballon];
        
        nX = 35.f;
        nTail = 60.f;
    }
    
    [cell.contentView addSubview:iv_Ballon];
    
    
    UIColor *color = kMainColor;
    UIImage *image = i_Ballon;// Image to mask with
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [color setFill];
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextClipToMask(context, CGRectMake(0, 0, image.size.width, image.size.height), [image CGImage]);
    CGContextFillRect(context, CGRectMake(0, 0, image.size.width, image.size.height));
    
    i_Ballon = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    
    for( NSInteger i = 0; i < ar.count; i++ )
    {
        NSDictionary *dic = ar[i];
        NSString *str_Type = isQna ? [dic objectForKey:@"qnaType"] : [dic objectForKey:@"replyType"];
        NSString *str_Body = isQna ? [dic objectForKey:@"qnaBody"] : [dic objectForKey:@"replyBody"];
        
        if( [str_Type isEqualToString:@"text"] )
        {
            UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(nX, fSampleViewTotalHeight,
                                                                              self.tbv_List.frame.size.width- (nX + nTail) - (isLeft ? 0 : 20), 0)];
            lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(lb_Contents.frame);
            lb_Contents.font = [UIFont fontWithName:@"Helvetica" size:14.f];
            lb_Contents.text = str_Body;
            lb_Contents.numberOfLines = 0;
            
            if( isLeft )
            {
                lb_Contents.textAlignment = NSTextAlignmentLeft;
            }
            else
            {
                lb_Contents.textAlignment = NSTextAlignmentRight;
            }
            
            CGRect frame = lb_Contents.frame;
            frame.size.height = [Util getTextSize:lb_Contents].height;
            lb_Contents.frame = frame;
            
            if( [Util getTextSize:lb_Contents].width > fTextWidth )
            {
                fTextWidth = [Util getTextSize:lb_Contents].width;
            }
            
            [cell.contentView addSubview:lb_Contents];
            
            fSampleViewTotalHeight += lb_Contents.frame.size.height + 10;
        }
        else if( [str_Type isEqualToString:@"image"] )
        {
            isOnlyText = NO;
            
            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(nX, fSampleViewTotalHeight, self.tbv_List.frame.size.width - (nX + nTail) - (isLeft ? 0 : 20), 0)];
            iv.contentMode = UIViewContentModeScaleAspectFill;
            iv.clipsToBounds = YES;
            
            CGFloat fPer = iv.frame.size.width / [[dic objectForKey:@"width"] floatValue];
            CGFloat fHeight = [[dic objectForKey:@"height"] floatValue] * fPer;
            
            if( isnan(fHeight) )    fHeight = 300.f;
            
            CGRect frame = iv.frame;
            frame.size.height = fHeight;
            iv.frame = frame;
            
            NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, str_Body];
            [iv sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
            
            [cell.contentView addSubview:iv];
            
            fSampleViewTotalHeight += iv.frame.size.height + 10;
            
//            iv.userInteractionEnabled = YES;
//            UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
//            [imageTap setNumberOfTapsRequired:1];
//            [iv addGestureRecognizer:imageTap];
        }
        else if( [str_Type isEqualToString:@"video"] )
        {
            isOnlyText = NO;
            
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(nX, fSampleViewTotalHeight,
                                                                   self.tbv_List.frame.size.width - (nX + nTail), (self.tbv_List.frame.size.width - (nX + nTail)) * 0.7f)];
            view.backgroundColor = [UIColor blackColor];
            view.tag = indexPath.section;
            
            NSString *str_Url = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, str_Body];
            NSURL *URL = [NSURL URLWithString:str_Url];
            
            AVURLAsset* asset = [AVURLAsset URLAssetWithURL:URL options:nil];
//            AVAssetImageGenerator* imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
//            imageGenerator.appliesPreferredTrackTransform = YES;
//            CGImageRef cgImage = [imageGenerator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:nil error:nil];
//            UIImage* thumbnail = [UIImage imageWithCGImage:cgImage];
//            
//            CGImageRelease(cgImage);
            
            
            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(nX, fSampleViewTotalHeight, self.tbv_List.frame.size.width - (nX + nTail) - (isLeft ? 0 : 20), 0)];
            iv.contentMode = UIViewContentModeScaleAspectFill;
            iv.clipsToBounds = YES;
            
            CGFloat fPer = iv.frame.size.width / [[dic objectForKey_YM:@"videoCoverWidth"] floatValue];
            CGFloat fHeight = [[dic objectForKey_YM:@"videoCoverHeight"] floatValue] * fPer;
            
            if( isnan(fHeight) )    fHeight = 300.f;
            
            CGRect frame = iv.frame;
            frame.size.height = fHeight;
            iv.frame = frame;
            
            NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, [dic objectForKey:@"videoCoverPath"]];
            [iv sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
            
            [cell.contentView addSubview:iv];
            
            fSampleViewTotalHeight += iv.frame.size.height + 10;
            
            
            YmExtendButton *btn_Play = [YmExtendButton buttonWithType:UIButtonTypeCustom];
            btn_Play.obj = URL;
            btn_Play.tag = indexPath.section;
            [btn_Play setImage:BundleImage(@"play_white.png") forState:UIControlStateNormal];
            [btn_Play setFrame:CGRectMake(0, 0, 88, 88)];
            //            btn_Play.backgroundColor = [UIColor blackColor];
            btn_Play.layer.cornerRadius = 8.f;
            btn_Play.center = iv.center;
            //                [btn_Play addTarget:self action:@selector(onPlayMove:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:btn_Play];
        }
    }
    
    CGRect frame = cell.frame;
    frame.size.height = fSampleViewTotalHeight + 20;
    cell.frame = frame;
    
    //말풍선
    if( isLeft )
    {
        if( isOnlyText )
        {
            iv_Ballon.frame = CGRectMake(nX - 20, 10, fTextWidth + 40, fSampleViewTotalHeight - 10);
        }
        else
        {
            iv_Ballon.frame = CGRectMake(nX - 20, 10, self.tbv_List.frame.size.width - (nX), fSampleViewTotalHeight - 10);
        }
    }
    else
    {
        if( isOnlyText )
        {
            iv_Ballon.frame = CGRectMake(self.tbv_List.frame.size.width - 85 - fTextWidth - 10, 10, fTextWidth + 30, fSampleViewTotalHeight - 10);
        }
        else
        {
            iv_Ballon.frame = CGRectMake(20, 10, self.tbv_List.frame.size.width - 85, fSampleViewTotalHeight - 10);
        }
    }
    
    if( isQna )
    {
        CGRect frame = iv_Ballon.frame;
        frame.origin.y += 35.f;
        frame.size.height -= 35.f;
        iv_Ballon.frame = frame;
    }
    
    //유저 이미지
    CGFloat fImageSize = 45.f;
    UIImageView *iv_User = [[UIImageView alloc] initWithFrame:CGRectMake(isLeft ? 10 : self.tbv_List.frame.size.width - (fImageSize + 15), fSampleViewTotalHeight - (fImageSize - 10),
                                                                         fImageSize, fImageSize)];
    iv_User.clipsToBounds = YES;
    [iv_User sd_setImageWithURL:[NSURL URLWithString:[dic_Main objectForKey:@"imgUrl"]]];
    iv_User.layer.cornerRadius = iv_User.frame.size.width/2;
    iv_User.layer.borderColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1].CGColor;
    iv_User.layer.borderWidth = 1.f;
    [cell.contentView addSubview:iv_User];
    
    
    //유저 이름
    UILabel *lb_Name = [[UILabel alloc] initWithFrame:CGRectMake(nX - 10, fSampleViewTotalHeight + 8, 0, 15)];
    lb_Name.font = [UIFont fontWithName:@"Helvetica" size:12];
    lb_Name.textColor = [UIColor darkGrayColor];
    lb_Name.text = [dic_Info objectForKey:@"name"];
    
    frame = lb_Name.frame;
    frame.size.width = [Util getTextSize:lb_Name].width;
    if( isLeft == NO )
    {
        frame.origin.x = self.tbv_List.frame.size.width - (frame.size.width + 80);
    }
    lb_Name.frame = frame;
    
    [cell.contentView addSubview:lb_Name];
    
    
    //날짜
    UILabel *lb_Date = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + frame.size.width + 8, fSampleViewTotalHeight + 8, 0, 15)];
    lb_Date.font = [UIFont fontWithName:@"Helvetica" size:12];
    lb_Date.textColor = [UIColor lightGrayColor];
    
    NSString *str_Date = [NSString stringWithFormat:@"%@", [dic_Info objectForKey:@"createDate"]];
    
    if( str_Date.length >= 12 )
    {
        NSString *str_Year = [str_Date substringWithRange:NSMakeRange(0, 4)];
        NSString *str_Month = [str_Date substringWithRange:NSMakeRange(4, 2)];
        NSString *str_Day = [str_Date substringWithRange:NSMakeRange(6, 2)];
        NSString *str_Hour = [str_Date substringWithRange:NSMakeRange(8, 2)];
        NSString *str_Minute = [str_Date substringWithRange:NSMakeRange(10, 2)];
        
        lb_Date.text = [NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld", [str_Year integerValue], [str_Month integerValue], [str_Day integerValue], [str_Hour integerValue], [str_Minute integerValue]];
    }
    else
    {
        lb_Date.text = str_Date;
    }
    
    
    frame = lb_Date.frame;
    frame.size.width = [Util getTextSize:lb_Date].width;
    if( isLeft == NO )
    {
        frame.origin.x = self.tbv_List.frame.size.width - (self.tbv_List.frame.size.width - lb_Name.frame.origin.x) - frame.size.width - 6;
    }
    
    lb_Date.frame = frame;
    
    [cell.contentView addSubview:lb_Date];
}

- (void)configureQnaCell:(FeedQnaCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    for( id subView in cell.contentView.subviews )
    {
        if( [subView isEqual:cell.iv_User] == NO && [subView isEqual:cell.lb_Name] == NO && [subView isEqual:cell.lb_Date] == NO )
        {
            [subView removeFromSuperview];
        }
    }

    cell.contentView.backgroundColor = [UIColor whiteColor];
    cell.iv_User.hidden = cell.lb_Name.hidden = cell.lb_Date.hidden = NO;

    __block CGFloat fSampleViewTotalHeight = 60;

    NSDictionary *dic_Main = self.ar_List[indexPath.row];
    
    NSString *str_FeedType = [dic_Main objectForKey:@"feedType"];
    if( [str_FeedType isEqualToString:@"channelQna"] )
    {
        [self addQnaItem:cell withData:dic_Main withIndexPath:(NSIndexPath *)indexPath withLeft:YES withQna:YES];
    }
    else if( [str_FeedType isEqualToString:@"channelReply"] )
    {
        [self addQnaItem:cell withData:dic_Main withIndexPath:(NSIndexPath *)indexPath withLeft:NO withQna:NO];
    }
    else if( [str_FeedType isEqualToString:@"qna-question"] )
    {
        cell.iv_User.hidden = cell.lb_Name.hidden = cell.lb_Date.hidden = YES;
        
        fSampleViewTotalHeight = 20;
        
        NSArray *ar_ExamQuestionInfos = [dic_Main objectForKey:@"examQuestionInfos"];
        for( NSInteger i = 0; i < ar_ExamQuestionInfos.count; i++ )
        {
            NSDictionary *dic = ar_ExamQuestionInfos[i];
            NSString *str_Type = [dic objectForKey:@"questionType"];
            NSString *str_Body = [dic objectForKey:@"questionBody"];
            //        NSLog(@"%@", str_Type);
            if( [str_Type isEqualToString:@"text"] )
            {
                UILabel * lb_Title = [[UILabel alloc] initWithFrame:CGRectMake(8, fSampleViewTotalHeight, self.tbv_List.frame.size.width - 60, 0)];
                lb_Title.preferredMaxLayoutWidth = CGRectGetWidth(lb_Title.frame);
                lb_Title.font = [UIFont fontWithName:@"Helvetica" size:14.f];
                lb_Title.text = str_Body;
                lb_Title.textColor = [UIColor lightGrayColor];
                lb_Title.numberOfLines = 0;

                lb_Title.text = [NSString stringWithFormat:@"[%@]", [dic_Main objectForKey:@"examTitle"]];
                
                CGRect frame = lb_Title.frame;
                frame.size.height = [Util getTextSize:lb_Title].height;
                lb_Title.frame = frame;

                [cell.contentView addSubview:lb_Title];

                fSampleViewTotalHeight += lb_Title.frame.size.height + 10;

                UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(8, fSampleViewTotalHeight, self.tbv_List.frame.size.width - 16, 0)];
                lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(lb_Contents.frame);
                lb_Contents.font = [UIFont fontWithName:@"Helvetica" size:14.f];
                lb_Contents.text = str_Body;
                lb_Contents.numberOfLines = 0;
                
                NSMutableString *strM = [NSMutableString stringWithFormat:@"%@. %@", [dic_Main objectForKey:@"examNo"], lb_Contents.text];
                lb_Contents.text = strM;
                
                frame = lb_Contents.frame;
                frame.size.height = [Util getTextSize:lb_Contents].height;
                lb_Contents.frame = frame;
                
                [cell.contentView addSubview:lb_Contents];

                fSampleViewTotalHeight += lb_Contents.frame.size.height + 10;
            }
            else if( [str_Type isEqualToString:@"html"] )
            {
                UILabel * lb_Title = [[UILabel alloc] initWithFrame:CGRectMake(8, fSampleViewTotalHeight, self.tbv_List.frame.size.width - 16, 0)];
                lb_Title.preferredMaxLayoutWidth = CGRectGetWidth(lb_Title.frame);
                lb_Title.font = [UIFont fontWithName:@"Helvetica" size:15.f];
                lb_Title.text = str_Body;
                lb_Title.textColor = [UIColor lightGrayColor];
                lb_Title.numberOfLines = 0;
                
                lb_Title.text = [NSString stringWithFormat:@"[%@]", [dic_Main objectForKey:@"examTitle"]];
                
                CGRect frame = lb_Title.frame;
                frame.size.height = [Util getTextSize:lb_Title].height;
                lb_Title.frame = frame;
                
                [cell.contentView addSubview:lb_Title];
                
                fSampleViewTotalHeight += lb_Title.frame.size.height + 10;

                
                NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[str_Body dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(self.tbv_List.frame.size.width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
                
                UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(8, fSampleViewTotalHeight, self.tbv_List.frame.size.width - 16, rect.size.height)];
                lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(lb_Contents.frame);
                lb_Contents.numberOfLines = 0;
                lb_Contents.attributedText = attrStr;
                [cell.contentView addSubview:lb_Contents];

                fSampleViewTotalHeight += rect.size.height + 10;
            }
            else if( [str_Type isEqualToString:@"image"] )
            {
                UILabel * lb_Title = [[UILabel alloc] initWithFrame:CGRectMake(8, fSampleViewTotalHeight, self.tbv_List.frame.size.width - 16, 0)];
                lb_Title.preferredMaxLayoutWidth = CGRectGetWidth(lb_Title.frame);
                lb_Title.font = [UIFont fontWithName:@"Helvetica" size:14.f];
                lb_Title.text = str_Body;
                lb_Title.textColor = [UIColor lightGrayColor];
                lb_Title.numberOfLines = 0;
                
                lb_Title.text = [NSString stringWithFormat:@"[%@]", [dic_Main objectForKey:@"examTitle"]];
                
                CGRect frame = lb_Title.frame;
                frame.size.height = [Util getTextSize:lb_Title].height;
                lb_Title.frame = frame;
                
                [cell.contentView addSubview:lb_Title];
                
                fSampleViewTotalHeight += lb_Title.frame.size.height + 10;

                
                UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(8, fSampleViewTotalHeight, self.tbv_List.frame.size.width - 16, 0)];
                iv.contentMode = UIViewContentModeScaleAspectFill;
                iv.clipsToBounds = YES;
                
                
                CGFloat fPer = iv.frame.size.width / [[dic objectForKey:@"width"] floatValue];
                CGFloat fHeight = [[dic objectForKey:@"height"] floatValue] * fPer;
                
                if( isnan(fHeight) )    fHeight = 300.f;
                
                frame = iv.frame;
                frame.size.height = fHeight;
                iv.frame = frame;
                
                NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, str_Body];
                [iv sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
                
                [cell.contentView addSubview:iv];
                
                fSampleViewTotalHeight += iv.frame.size.height + 10;
                
            }
            else if( [str_Type isEqualToString:@"video"] )
            {
                UIView *view = [[UIView alloc]initWithFrame:CGRectMake(8, fSampleViewTotalHeight, self.tbv_List.frame.size.width - 16, (self.tbv_List.frame.size.width - 16) * 0.7f)];
                view.backgroundColor = [UIColor blackColor];
                view.tag = indexPath.section;
                
                NSString *str_Url = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, str_Body];
                NSURL *URL = [NSURL URLWithString:str_Url];
                
//                AVURLAsset* asset = [AVURLAsset URLAssetWithURL:URL options:nil];
//                AVAssetImageGenerator* imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
//                imageGenerator.appliesPreferredTrackTransform = YES;
//                CGImageRef cgImage = [imageGenerator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:nil error:nil];
//                UIImage* thumbnail = [UIImage imageWithCGImage:cgImage];
//                
//                CGImageRelease(cgImage);
                
                UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(8, fSampleViewTotalHeight, self.tbv_List.frame.size.width - 16, 0)];
                iv.contentMode = UIViewContentModeScaleAspectFill;
                iv.clipsToBounds = YES;
                
                CGFloat fPer = iv.frame.size.width / [[dic objectForKey_YM:@"videoCoverWidth"] floatValue];
                CGFloat fHeight = [[dic objectForKey_YM:@"videoCoverHeight"] floatValue] * fPer;
                
                if( isnan(fHeight) )    fHeight = 300.f;
                
                CGRect frame = iv.frame;
                frame.size.height = fHeight;
                iv.frame = frame;
                
                NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, [dic objectForKey:@"videoCoverPath"]];
                [iv sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
                
                [cell.contentView addSubview:iv];
                
                fSampleViewTotalHeight += iv.frame.size.height + 10;
                
                
                YmExtendButton *btn_Play = [YmExtendButton buttonWithType:UIButtonTypeCustom];
                btn_Play.obj = URL;
                btn_Play.tag = indexPath.section;
                [btn_Play setImage:BundleImage(@"play_white.png") forState:UIControlStateNormal];
                [btn_Play setFrame:CGRectMake(0, 0, 88, 88)];
                //            btn_Play.backgroundColor = [UIColor blackColor];
                btn_Play.layer.cornerRadius = 8.f;
                btn_Play.center = iv.center;
//                [btn_Play addTarget:self action:@selector(onPlayMove:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:btn_Play];
            }
        }
        
        UIButton *btn_DeleteFeed = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_DeleteFeed.tag = indexPath.row;
        [btn_DeleteFeed setFrame:CGRectMake(self.tbv_List.frame.size.width- 60, 10, 60, 60)];
        [btn_DeleteFeed setImage:BundleImage(@"delete_feed.png") forState:UIControlStateNormal];
        btn_DeleteFeed.imageEdgeInsets = UIEdgeInsetsMake(-50, 20, 0, 0);
        [btn_DeleteFeed addTarget:self action:@selector(onDeleteFeed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn_DeleteFeed];

        CGRect frame = cell.frame;
        frame.size.height = fSampleViewTotalHeight;
        cell.frame = frame;
    }
    else if( [str_FeedType isEqualToString:@"qna"] )
    {
        cell.iv_User.hidden = cell.lb_Name.hidden = cell.lb_Date.hidden = NO;

        cell.lc_ImageX.constant = 15.f;
        
        [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:[dic_Main objectForKey:@"imgUrl"]]];
        cell.lb_Name.text = [dic_Main objectForKey:@"name"];
        
        NSString *str_Date = [NSString stringWithFormat:@"%@", [dic_Main objectForKey:@"createDate"]];
        
        if( str_Date.length >= 12 )
        {
            NSString *str_Year = [str_Date substringWithRange:NSMakeRange(0, 4)];
            NSString *str_Month = [str_Date substringWithRange:NSMakeRange(4, 2)];
            NSString *str_Day = [str_Date substringWithRange:NSMakeRange(6, 2)];
            NSString *str_Hour = [str_Date substringWithRange:NSMakeRange(8, 2)];
            NSString *str_Minute = [str_Date substringWithRange:NSMakeRange(10, 2)];
            
            cell.lb_Date.text = [NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld", [str_Year integerValue], [str_Month integerValue], [str_Day integerValue], [str_Hour integerValue], [str_Minute integerValue]];
        }

        NSArray *ar_ExamQuestionInfos = [dic_Main objectForKey:@"data"];
        for( NSInteger i = 0; i < ar_ExamQuestionInfos.count; i++ )
        {
            NSDictionary *dic = ar_ExamQuestionInfos[i];
            NSString *str_Type = [dic objectForKey:@"qnaType"];
            NSString *str_Body = [dic objectForKey:@"qnaBody"];
            if( [str_Type isEqualToString:@"text"] )
            {
                UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(cell.lc_ImageX.constant, fSampleViewTotalHeight, self.tbv_List.frame.size.width - (cell.lc_ImageX.constant + 8), 0)];
                lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(lb_Contents.frame);
                lb_Contents.font = [UIFont fontWithName:@"Helvetica" size:14.f];
                lb_Contents.text = str_Body;
                lb_Contents.numberOfLines = 0;
                
                CGRect frame = lb_Contents.frame;
                frame.size.height = [Util getTextSize:lb_Contents].height;
                lb_Contents.frame = frame;
                
                [cell.contentView addSubview:lb_Contents];
                
                fSampleViewTotalHeight += lb_Contents.frame.size.height + 10;
            }
            else if( [str_Type isEqualToString:@"html"] )
            {
                NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[str_Body dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(self.tbv_List.frame.size.width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
                
                UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(cell.lc_ImageX.constant, fSampleViewTotalHeight, self.tbv_List.frame.size.width - (cell.lc_ImageX.constant + 8), rect.size.height)];
                lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(lb_Contents.frame);
                lb_Contents.numberOfLines = 0;
                lb_Contents.attributedText = attrStr;
                [cell.contentView addSubview:lb_Contents];
                
                fSampleViewTotalHeight += rect.size.height + 10;
            }
            else if( [str_Type isEqualToString:@"image"] )
            {
                UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(cell.lc_ImageX.constant, fSampleViewTotalHeight, self.tbv_List.frame.size.width - (cell.lc_ImageX.constant + 8), 0)];
                iv.contentMode = UIViewContentModeScaleAspectFill;
                iv.clipsToBounds = YES;
                
                
                CGFloat fPer = iv.frame.size.width / [[dic objectForKey:@"width"] floatValue];
                CGFloat fHeight = [[dic objectForKey:@"height"] floatValue] * fPer;
                
                if( isnan(fHeight) )    fHeight = 300.f;
                
                CGRect frame = iv.frame;
                frame.size.height = fHeight;
                iv.frame = frame;
                
                NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, str_Body];
                [iv sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
                
                [cell.contentView addSubview:iv];
                
                fSampleViewTotalHeight += iv.frame.size.height + 10;
                
            }
            else if( [str_Type isEqualToString:@"video"] )
            {
                UIView *view = [[UIView alloc]initWithFrame:CGRectMake(cell.lc_ImageX.constant, fSampleViewTotalHeight, self.tbv_List.frame.size.width - (cell.lc_ImageX.constant + 8), (self.tbv_List.frame.size.width - (cell.lc_ImageX.constant + 8)) * 0.7f)];
                view.backgroundColor = [UIColor blackColor];
                view.tag = indexPath.section;
                
                NSString *str_Url = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, str_Body];
                NSURL *URL = [NSURL URLWithString:str_Url];
                
//                AVURLAsset* asset = [AVURLAsset URLAssetWithURL:URL options:nil];
//                AVAssetImageGenerator* imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
//                imageGenerator.appliesPreferredTrackTransform = YES;
//                CGImageRef cgImage = [imageGenerator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:nil error:nil];
//                UIImage* thumbnail = [UIImage imageWithCGImage:cgImage];
//                
//                CGImageRelease(cgImage);
                
                UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(cell.lc_ImageX.constant, fSampleViewTotalHeight, self.tbv_List.frame.size.width - (cell.lc_ImageX.constant + 8), 0)];
                iv.contentMode = UIViewContentModeScaleAspectFill;
                iv.clipsToBounds = YES;
                
                CGFloat fPer = iv.frame.size.width / [[dic objectForKey_YM:@"videoCoverWidth"] floatValue];
                CGFloat fHeight = [[dic objectForKey_YM:@"videoCoverHeight"] floatValue] * fPer;
                
                if( isnan(fHeight) )    fHeight = 300.f;
                
                CGRect frame = iv.frame;
                frame.size.height = fHeight;
                iv.frame = frame;
                
                NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, [dic objectForKey:@"videoCoverPath"]];
                [iv sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
                
                [cell.contentView addSubview:iv];
                
                fSampleViewTotalHeight += iv.frame.size.height + 10;
                
                
                YmExtendButton *btn_Play = [YmExtendButton buttonWithType:UIButtonTypeCustom];
                btn_Play.obj = URL;
                btn_Play.tag = indexPath.section;
                [btn_Play setImage:BundleImage(@"play_white.png") forState:UIControlStateNormal];
                [btn_Play setFrame:CGRectMake(0, 0, 88, 88)];
                //            btn_Play.backgroundColor = [UIColor blackColor];
                btn_Play.layer.cornerRadius = 8.f;
                btn_Play.center = iv.center;
//                [btn_Play addTarget:self action:@selector(onPlayMove:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:btn_Play];
            }
        }
        
        UIButton *btn_DeleteFeed = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_DeleteFeed.tag = indexPath.row;
        [btn_DeleteFeed setFrame:CGRectMake(self.tbv_List.frame.size.width- 60, 10, 60, 60)];
        [btn_DeleteFeed setImage:BundleImage(@"delete_feed.png") forState:UIControlStateNormal];
        btn_DeleteFeed.imageEdgeInsets = UIEdgeInsetsMake(-50, 20, 0, 0);
        [btn_DeleteFeed addTarget:self action:@selector(onDeleteFeed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn_DeleteFeed];

        
        CGRect frame = cell.frame;
        frame.size.height = fSampleViewTotalHeight;
        cell.frame = frame;
        
        [cell.contentView updateConstraintsIfNeeded];
        [cell.contentView layoutIfNeeded];
    }
    else if( [str_FeedType isEqualToString:@"reply"] )
    {
        cell.iv_User.hidden = cell.lb_Name.hidden = cell.lb_Date.hidden = NO;

        [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:[dic_Main objectForKey:@"imgUrl"]]];
        cell.lb_Name.text = [dic_Main objectForKey:@"name"];
        
        NSString *str_Date = [NSString stringWithFormat:@"%@", [dic_Main objectForKey:@"createDate"]];
        
        if( str_Date.length >= 12 )
        {
            NSString *str_Year = [str_Date substringWithRange:NSMakeRange(0, 4)];
            NSString *str_Month = [str_Date substringWithRange:NSMakeRange(4, 2)];
            NSString *str_Day = [str_Date substringWithRange:NSMakeRange(6, 2)];
            NSString *str_Hour = [str_Date substringWithRange:NSMakeRange(8, 2)];
            NSString *str_Minute = [str_Date substringWithRange:NSMakeRange(10, 2)];
            
            cell.lb_Date.text = [NSString stringWithFormat:@"%04ld-%02ld-%02ld %02ld:%02ld", [str_Year integerValue], [str_Month integerValue], [str_Day integerValue], [str_Hour integerValue], [str_Minute integerValue]];
        }

        cell.contentView.backgroundColor = [UIColor colorWithHexString:@"F3F3F3"];
        cell.lc_ImageX.constant = 45.f;
        
        NSArray *ar_ExamQuestionInfos = [dic_Main objectForKey:@"data"];
        
        for( NSInteger i = 0; i < ar_ExamQuestionInfos.count; i++ )
        {
            NSDictionary *dic = ar_ExamQuestionInfos[i];
            NSString *str_Type = [dic objectForKey:@"replyType"];
            NSString *str_Body = [dic objectForKey:@"replyBody"];
            if( [str_Type isEqualToString:@"text"] )
            {
                UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(cell.lc_ImageX.constant, fSampleViewTotalHeight, self.tbv_List.frame.size.width - 16 - cell.lc_ImageX.constant, 0)];
                lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(lb_Contents.frame);
                lb_Contents.font = [UIFont fontWithName:@"Helvetica" size:14.f];
                lb_Contents.text = str_Body;
                lb_Contents.numberOfLines = 0;
                
                CGRect frame = lb_Contents.frame;
                frame.size.height = [Util getTextSize:lb_Contents].height;
                lb_Contents.frame = frame;
                
                [cell.contentView addSubview:lb_Contents];
                
                fSampleViewTotalHeight += lb_Contents.frame.size.height + 10;
            }
            else if( [str_Type isEqualToString:@"html"] )
            {
                NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[str_Body dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(self.tbv_List.frame.size.width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
                
                UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(cell.lc_ImageX.constant, fSampleViewTotalHeight, self.tbv_List.frame.size.width - 16 - cell.lc_ImageX.constant, rect.size.height)];
                lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(lb_Contents.frame);
                lb_Contents.numberOfLines = 0;
                lb_Contents.attributedText = attrStr;
                [cell.contentView addSubview:lb_Contents];
                
                fSampleViewTotalHeight += rect.size.height + 10;
            }
            else if( [str_Type isEqualToString:@"image"] )
            {
                UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(cell.lc_ImageX.constant, fSampleViewTotalHeight, self.tbv_List.frame.size.width - 16 - cell.lc_ImageX.constant, 0)];
                iv.contentMode = UIViewContentModeScaleAspectFill;
                iv.clipsToBounds = YES;
                
                
                CGFloat fPer = iv.frame.size.width / [[dic objectForKey:@"width"] floatValue];
                CGFloat fHeight = [[dic objectForKey:@"height"] floatValue] * fPer;
                
                if( isnan(fHeight) )    fHeight = 300.f;
                
                CGRect frame = iv.frame;
                frame.size.height = fHeight;
                iv.frame = frame;
                
                NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, str_Body];
                [iv sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
                
                [cell.contentView addSubview:iv];
                
                fSampleViewTotalHeight += iv.frame.size.height + 10;
                
            }
            else if( [str_Type isEqualToString:@"video"] )
            {
                UIView *view = [[UIView alloc]initWithFrame:CGRectMake(cell.lc_ImageX.constant, fSampleViewTotalHeight, self.tbv_List.frame.size.width - (fSampleViewTotalHeight + 8), (self.tbv_List.frame.size.width - 16 - cell.lc_ImageX.constant) * 0.7f)];
                view.backgroundColor = [UIColor blackColor];
                view.tag = indexPath.section;
                
                NSString *str_Url = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, str_Body];
                NSURL *URL = [NSURL URLWithString:str_Url];
                
//                AVURLAsset* asset = [AVURLAsset URLAssetWithURL:URL options:nil];
//                AVAssetImageGenerator* imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
//                imageGenerator.appliesPreferredTrackTransform = YES;
//                CGImageRef cgImage = [imageGenerator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:nil error:nil];
//                UIImage* thumbnail = [UIImage imageWithCGImage:cgImage];
//                
//                CGImageRelease(cgImage);
                
                UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(cell.lc_ImageX.constant, fSampleViewTotalHeight, view.frame.size.width, 0)];
                iv.contentMode = UIViewContentModeScaleAspectFill;
                iv.clipsToBounds = YES;
                
                CGFloat fPer = iv.frame.size.width / [[dic objectForKey_YM:@"videoCoverWidth"] floatValue];
                CGFloat fHeight = [[dic objectForKey_YM:@"videoCoverHeight"] floatValue] * fPer;
                
                if( isnan(fHeight) )    fHeight = 300.f;
                
                CGRect frame = iv.frame;
                frame.size.height = fHeight;
                iv.frame = frame;
                
                NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, [dic objectForKey:@"videoCoverPath"]];
                [iv sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
                
                [cell.contentView addSubview:iv];
                
                fSampleViewTotalHeight += iv.frame.size.height + 10;
                
                
                YmExtendButton *btn_Play = [YmExtendButton buttonWithType:UIButtonTypeCustom];
                btn_Play.obj = URL;
                btn_Play.tag = indexPath.section;
                [btn_Play setImage:BundleImage(@"play_white.png") forState:UIControlStateNormal];
                [btn_Play setFrame:CGRectMake(0, 0, 88, 88)];
                //            btn_Play.backgroundColor = [UIColor blackColor];
                btn_Play.layer.cornerRadius = 8.f;
                btn_Play.center = iv.center;
//                [btn_Play addTarget:self action:@selector(onPlayMove:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:btn_Play];
            }
        }
        
        UIButton *btn_DeleteFeed = [UIButton buttonWithType:UIButtonTypeCustom];
        btn_DeleteFeed.tag = indexPath.row;
        [btn_DeleteFeed setFrame:CGRectMake(self.tbv_List.frame.size.width- 60, 10, 60, 60)];
        [btn_DeleteFeed setImage:BundleImage(@"delete_feed.png") forState:UIControlStateNormal];
        btn_DeleteFeed.imageEdgeInsets = UIEdgeInsetsMake(-50, 20, 0, 0);
        [btn_DeleteFeed addTarget:self action:@selector(onDeleteFeed:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn_DeleteFeed];

        CGRect frame = cell.frame;
        frame.size.height = fSampleViewTotalHeight;
        cell.frame = frame;
    }
}

- (void)configureBarCell:(FeedBarCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.ar_List[indexPath.row];
 
    cell.tag = cell.btn_More.tag = indexPath.row;
    [cell.btn_More removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    
    NSString *str_UserImageUrl = [dic objectForKey:@"feederImgUrl"];
    if( [str_UserImageUrl isEqualToString:@"no_image"] )
    {
        //유저 이미지가 없을 경우
        [cell.iv_User sd_setImageWithURL:[Util createImageUrl:str_UserImagePrefix withFooter:str_NoImagePrefix]];
    }
    else
    {
        //유저 이미지가 있을 경우
        [cell.iv_User sd_setImageWithURL:[Util createImageUrl:str_UserImagePrefix withFooter:str_UserImageUrl]];
    }
    
    //팔로잉 언팔로잉 여부
    NSString *str_MoveType = [dic objectForKey:@"actionMoveType"];
    if( [str_MoveType isEqualToString:@"follow-channel"] )
    {
        //팔로잉이 아님
        cell.btn_More.selected = NO;
        cell.lc_MoreWidth.constant = 75.f;
        
        cell.btn_More.layer.borderColor = kMainColor.CGColor;
        [cell.btn_More setTitle:@"+팔로우" forState:UIControlStateNormal];
        [cell.btn_More setTitleColor:kMainColor forState:UIControlStateNormal];
        
        [cell.btn_More addTarget:self action:@selector(onFollowing:) forControlEvents:UIControlEventTouchUpInside];
    }
    else if( [str_MoveType isEqualToString:@"confirm-join"] )
    {
        cell.btn_More.selected = NO;
        cell.lc_MoreWidth.constant = 75.f;
        
        cell.btn_More.layer.borderColor = kMainRedColor.CGColor;
        [cell.btn_More setTitle:@"인증요청" forState:UIControlStateNormal];
        [cell.btn_More setTitleColor:kMainRedColor forState:UIControlStateNormal];
        
        [cell.btn_More addTarget:self action:@selector(onShowNoti:) forControlEvents:UIControlEventTouchUpInside];
    }
//    else if( [str_MoveType isEqualToString:@"chatroom-join"] )
//    {
//        cell.btn_More.selected = NO;
//        cell.lc_MoreWidth.constant = 75.f;
//        
//        cell.btn_More.layer.borderColor = kMainRedColor.CGColor;
//        [cell.btn_More setTitle:@"참여하기" forState:UIControlStateNormal];
//        [cell.btn_More setTitleColor:kMainRedColor forState:UIControlStateNormal];
//        
//        [cell.btn_More addTarget:self action:@selector(onShowNoti:) forControlEvents:UIControlEventTouchUpInside];
//    }
    else
    {
        //팔로잉중
        cell.btn_More.selected = YES;
        cell.lc_MoreWidth.constant = 0.f;
    }
    
    NSString *str_FeedType = [dic objectForKey:@"feedType"];
    if( [str_FeedType isEqualToString:@"text"] )
    {
        //text
        cell.lb_Title.text = [NSString stringWithFormat:@"%@ %@", [dic objectForKey:@"feedContent"], [dic objectForKey:@"displayTimeMsg"]];
        //        cell.lb_Title.preferredMaxLayoutWidth = CGRectGetWidth(cell.lb_Title.frame);  //필요한가? 없어도 되나?
    }
    else
    {
        //html
        NSString *str_Html = [dic objectForKey:@"feedContent"];
        NSAttributedString * attrStr_Html = [[NSAttributedString alloc] initWithData:[str_Html dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
        
        UIFont *font = [UIFont fontWithName:@"Helvetica" size:14.f];
        NSDictionary *dic_Attr = [NSDictionary dictionaryWithObject:font
                                                             forKey:NSFontAttributeName];
        NSString *str_Time = [dic objectForKey:@"displayTimeMsg"];
        NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str_Time attributes:dic_Attr];
        [attrStr appendAttributedString:attrStr_Html];
        //        cell.lb_Title.preferredMaxLayoutWidth = CGRectGetWidth(cell.lb_Title.frame);  //필요한가? 없어도 되나?
        cell.lb_Title.attributedText = attrStr;
    }

}

- (void)configureChatCell:(FeedChatCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.ar_List[indexPath.row];
    
    NSString *str_UserImageUrl = [dic objectForKey:@"feederImgUrl"];
    if( [str_UserImageUrl isEqualToString:@"no_image"] )
    {
        //유저 이미지가 없을 경우
        [cell.iv_User sd_setImageWithURL:[Util createImageUrl:str_UserImagePrefix withFooter:str_NoImagePrefix]];
    }
    else
    {
        //유저 이미지가 있을 경우
        [cell.iv_User sd_setImageWithURL:[Util createImageUrl:str_UserImagePrefix withFooter:str_UserImageUrl]];
    }
    
    cell.tag = cell.btn_Join.tag = indexPath.row;
    
    cell.lb_Name.text = [dic objectForKey:@"feederName"];
    
    NSString *str_Date = [NSString stringWithFormat:@"%@", [dic objectForKey:@"displayTimeMsg"]];
    
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
    
    cell.lb_Contents.text = [dic objectForKey:@"feedContent"];

    [cell.btn_Join addTarget:self action:@selector(onJoinChatRoom:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)onJoinChatRoom:(UIButton *)btn
{
    NSDictionary *dic = self.ar_List[btn.tag];
    
    [self removeBadgeCount:dic];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chatting" bundle:nil];
    ChattingViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChattingViewController"];
    vc.dic_Info = @{@"questionId" : [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"actionMoveId"]],
                    @"roomName" : [dic objectForKey_YM:@"roomName"]};
//                    @"roomName" : @""};
    vc.str_RId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"rId"]];
    vc.isMove = YES;
    vc.str_ChannelId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)configureBalloonCell:(FeedBalloonCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.ar_List[indexPath.row];
    
    NSString *str_UserImageUrl = [dic objectForKey:@"feederImgUrl"];
    if( [str_UserImageUrl isEqualToString:@"no_image"] )
    {
        //유저 이미지가 없을 경우
        [cell.iv_User sd_setImageWithURL:[Util createImageUrl:str_UserImagePrefix withFooter:str_NoImagePrefix]];
    }
    else
    {
        //유저 이미지가 있을 경우
        [cell.iv_User sd_setImageWithURL:[Util createImageUrl:str_UserImagePrefix withFooter:str_UserImageUrl]];
    }

    cell.tag = indexPath.row;
    
    cell.lb_Title.text = [NSString stringWithFormat:@"%@\n%@", [dic objectForKey:@"feederName"], [dic objectForKey:@"displayTimeMsg"]];

    NSString *str_FeedType = [dic objectForKey:@"feedType"];
    if( [str_FeedType isEqualToString:@"text"] )
    {
        //text
        cell.lb_Discription.text = [dic objectForKey:@"feedContent"];
//        cell.lb_Discription.preferredMaxLayoutWidth = CGRectGetWidth(cell.lb_Discription.frame);  //필요한가? 없어도 되나?
    }
    else
    {
        //html
        NSString *str_Html = [dic objectForKey:@"feedContent"];
        NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[str_Html dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//        cell.lb_Discription.preferredMaxLayoutWidth = CGRectGetWidth(cell.lb_Discription.frame);  //필요한가? 없어도 되나?
        cell.lb_Discription.attributedText = attrStr;
    }
}

- (void)onFollowing:(UIButton *)btn
{
    NSDictionary *dic = self.ar_List[btn.tag];

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"actionMoveId"] integerValue]], @"channelId",
                                        btn.selected ? @"unfollow" : @"follow", @"setMode",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/channel/follow"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                [self.ar_List removeAllObjects];
                                                [self updateList];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

- (void)onDeleteFeed:(UIButton *)btn
{
    NSDictionary *dic = self.ar_List[btn.tag];
    if( [[dic objectForKey:@"feedType"] isEqualToString:@"channelQna"] )
    {
        if( self.ar_List.count >= btn.tag )
        {
            NSDictionary *dic_Next = self.ar_List[btn.tag + 1];
            if( [[dic_Next objectForKey:@"feedType"] isEqualToString:@"channelReply"] )
            {
                [self.ar_List removeObjectAtIndex:btn.tag + 1];
                [self removeBadgeCount:dic_Next];
            }
        }
    }
    [self.ar_List removeObjectAtIndex:btn.tag];
    [self.tbv_List reloadData];
    [self removeBadgeCount:dic];
//    [self updateList];
}

- (void)onMore:(NSInteger)nTag
{
    NSDictionary *dic = self.ar_List[nTag];
    
    NSString *str_MoveType = [dic objectForKey:@"actionMoveType"];
    if( [str_MoveType isEqualToString:@"channel"] || [str_MoveType isEqualToString:@"follow-channel"] )
    {
        //TODO: 채널로 이동 로직 구현
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Channel" bundle:nil];
        ChannelMainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChannelMainViewController"];
        vc.str_ChannelId = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"actionMoveId"] integerValue]];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if( [str_MoveType isEqualToString:@"confirm-join"] )
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Channel" bundle:nil];
        ChannelMainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChannelMainViewController"];
        vc.str_ChannelId = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"feederId"] integerValue]];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if( [str_MoveType isEqualToString:@"my"] )
    {
        //TODO: 마이페이지로 이동 로직 구현
        [[NSNotificationCenter defaultCenter] postNotificationName:kChangeTabBar object:[NSNumber numberWithInteger:4]];
    }
    else if( [str_MoveType isEqualToString:@"hashtag"] )
    {
        //아직은 없음 나중에 구현할 것
    }
}



- (IBAction)goTest:(id)sender
{
//    StarListDetailViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"StarListDetailViewController"];
//    vc.str_SchoolGrade = @"고등학교";
//    vc.str_PersonGrade = @"2";
//    vc.str_SubjectName = @"생활기술";
//    vc.nPage = 0;
//    [self.navigationController pushViewController:vc animated:YES];

//    QuestionContainerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
//    vc.hidesBottomBarWhenPushed = YES;
//    vc.str_Idx = @"419";
//    vc.str_StartIdx = @"0";
//    [self.navigationController pushViewController:vc animated:YES];
    
    NSString *str_ChannelUrl = @"ymtestchannelurl1";
    //https://api.sendbird.com/channel/{Action}
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        kSendBirdApiToken, @"auth",
                                        str_ChannelUrl, @"channel_url",
                                        @"ymtestchannelName", @"name",
                                        //                                        @"", @"cover_url",
                                        //                                        @"", @"data",
                                        nil];
    
    [[WebAPI sharedData] callAsyncSendBirdAPIBlock:@"channel/create"
                                             param:dicM_Params
                                        withMethod:@"POST"
                                         withBlock:^(id resulte, NSError *error) {
                                             
                                             if( resulte )
                                             {
                                                 if( [[resulte objectForKey:@"error"] integerValue] == 1 )
                                                 {
                                                     //이미 방이 있으면 조인
//                                                     [SendBird joinChannel:str_ChannelUrl];
//                                                     [SendBird connect];
                                                     
//                                                     [SendBird sendMessage:@"@@hi@@"];
                                                 }
                                                 
                                             }
                                         }];

//    [SendBird sendMessage:@"@@hi@@"];
}

- (IBAction)goSendMsg:(id)sender
{
//    [SendBird sendMessage:@"test" withTempId:@"tempid"];
}



- (void)startSendBird
{
//    [SendBird setEventHandlerConnectBlock:^(SendBirdChannel *channel) {
//        
//    } errorBlock:^(NSInteger code) {
//        
//    } channelLeftBlock:^(SendBirdChannel *channel) {
//        
//    } messageReceivedBlock:^(SendBirdMessage *message) {
//        
//        NSLog(@"Recive");
//        NSLog(@"%@", message.message);
//        ALERT(nil, message.message, nil, @"확인", nil);
//    } systemMessageReceivedBlock:^(SendBirdSystemMessage *message) {
//        
//    } broadcastMessageReceivedBlock:^(SendBirdBroadcastMessage *message) {
//        
//    } fileReceivedBlock:^(SendBirdFileLink *fileLink) {
//        
//    } messagingStartedBlock:^(SendBirdMessagingChannel *channel) {
//        
//    } messagingUpdatedBlock:^(SendBirdMessagingChannel *channel) {
//        
//    } messagingEndedBlock:^(SendBirdMessagingChannel *channel) {
//        
//    } allMessagingEndedBlock:^{
//        
//    } messagingHiddenBlock:^(SendBirdMessagingChannel *channel) {
//        
//    } allMessagingHiddenBlock:^{
//        
//    } readReceivedBlock:^(SendBirdReadStatus *status) {
//        
//    } typeStartReceivedBlock:^(SendBirdTypeStatus *status) {
//        
//    } typeEndReceivedBlock:^(SendBirdTypeStatus *status) {
//        
//    } allDataReceivedBlock:^(NSUInteger sendBirdDataType, int count) {
//        
//    } messageDeliveryBlock:^(BOOL send, NSString *message, NSString *data, NSString *tempId) {
//        
//    } mutedMessagesReceivedBlock:^(SendBirdMessage *message) {
//        
//    } mutedFileReceivedBlock:^(SendBirdFileLink *message) {
//        
//    }];
}


- (IBAction)goQuestionDiscrip:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    AddDiscripViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"AddDiscripViewController"];
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)onShowNoti:(UIButton *)btn
{
    /*
     actionLabel = "";
     actionMoveId = 5;
     actionMoveType = channel;
     actionYn = N;
     displayTimeMsg = "";
     displayType = bar;
     feedContent = "\Uc601\Uc5b4\Ub4e3\Uae30_\Uae30\Ucd9c\Uc5d0\Uc11c \Ucd5c\Uadfc 2\Uc8fc\Uac04 \Uc5c5\Ub85c\Ub4dc\Ud55c \Ubb38\Uc81c\Uac00 \Uc5c6\Uc2b5\Ub2c8\Ub2e4.";
     feedType = text;
     feederId = 5;
     feederImgUrl = "http://data.clipnote.co.kr:8282/c_edujm/images/user/000/000/english_lc.png";
     feederName = "\Uc601\Uc5b4\Ub4e3\Uae30_\Uae30\Ucd9c";
     feederType = channel;
     */
    
    NSDictionary *dic = self.ar_List[btn.tag];
    [Common showDetailNoti:self withInfo:dic];
}


@end
