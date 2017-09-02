//
//  QuestionListViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 6. 24..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "QuestionListViewController.h"
#import "TLYShyNavBarManager.h"
#import "QuestionListCell.h"
#import "QuestionListHeaderCell.h"
#import "QuestionListTitleView.h"
#import "AnswerNumberView.h"
#import "AnswerView.h"
#import "QuestionDiscriptionViewController.h"

#import "AnswerTitleCell.h"
#import "Answer6Cell.h"
#import "AnswerDiscripCell.h"
#import "AnswerSubjectiveCell.h"

#import "AnswerPrintNumber2Cell.h"
#import "AnswerPrintSubjectCell.h"
#import "YTPlayerView.h"
#import "YmExtendButton.h"
//#import "QuestionFooterCell.h"
@import AVFoundation;
@import MediaPlayer;
@import AMPopTip;
#import "QuestionIngStarNaviView.h"
#import "StarListViewController.h"
#import "QuestionContainerViewController.h"
#import "AudioView.h"
#import "SideMenuViewController.h"


@interface QuestionListViewController ()
{
    BOOL isFinish;      //문제를 풀었는지
    BOOL isFinishPass;  //문제를 풀고 맞췄는지
}

@property (nonatomic, strong) NSString *str_TesterId;

//음성문제 관련
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) YmExtendButton *btn_QuestionPlay;
//@property (nonatomic, strong) AudioView *v_Audio;
/////////

//비디오 관련
@property (nonatomic, strong) MPMoviePlayerViewController *vc_Movie;
///////////

@property (nonatomic, strong) NSMutableDictionary *dicM_CellHeight;
@property (nonatomic, strong) NSString *str_ImagePreFix;
@property (nonatomic, strong) NSString *str_UserThum;
@property (nonatomic, strong) AMPopTip *popTip;
@property (nonatomic, strong) NSDictionary *dic_PackageInfo;
@property (nonatomic, strong) NSDictionary *dic_UserInfo;
@property (nonatomic, strong) NSTimer *tm_Time;
@property (nonatomic, strong) UIButton *btn_LeftBarItem;
@property (nonatomic, strong) UIButton *btn_RightBarItem;
@property (nonatomic, strong) QuestionListTitleView *v_Title;
@property (nonatomic, strong) QuestionListCell *questionListCell;
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) QuestionIngStarNaviView *v_RightMenu;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet UIButton *btn_Menu;
@property (nonatomic, weak) IBOutlet AnswerNumberView *v_Answer;
@end

@implementation QuestionListViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.navigationController.navigationBarHidden = NO;

//    [self initNaviWithTitle:@"토팅" withLeftItem:[self leftBackMenuBarButtonItem] withRightItem:[self rightBookMarkItem]];

    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"QuestionIngStarNaviView" owner:self options:nil];
    self.v_RightMenu = [topLevelObjects objectAtIndex:0];
    [self.v_RightMenu.btn_Count addTarget:self action:@selector(onStarList:) forControlEvents:UIControlEventTouchUpInside];
    
    [self initNaviWithTitle:@"풀고있는 문제" withLeftItem:[self leftBackBlackMenuBarButtonItem] withRightItem:[[UIBarButtonItem alloc] initWithCustomView:self.v_RightMenu] withColor:[UIColor colorWithHexString:@"F8F8F8"]];


    
    
    

    
    
    self.dicM_CellHeight = [NSMutableDictionary dictionary];
    
    self.questionListCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([QuestionListCell class])];

//    UIView *view = view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.view.bounds), 40.f)];
//    view.backgroundColor = [UIColor redColor];

    /* Library code */
    self.shyNavBarManager.scrollView = self.tbv_List;
    /* Can then be remove by setting the ExtensionView to nil */
//    [self.shyNavBarManager setExtensionView:view];

    self.popTip = [AMPopTip popTip];
    self.popTip.edgeMargin = 5;
    self.popTip.offset = 2;
    self.popTip.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    self.popTip.shouldDismissOnTap = YES;
    self.popTip.animationIn = 0;
    self.popTip.animationOut = 0;
    self.popTip.tapHandler = ^{
        NSLog(@"Tap!");
        //        [weakSelf.popTip hide];
    };
    self.popTip.dismissHandler = ^{
        NSLog(@"Dismiss!");
    };

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    [MBProgressHUD hide];

    [self updateList];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    [self.navigationController.navigationBar setBarTintColor:kMainColor];
//    [self.navigationController.navigationBar setTranslucent:NO];

//    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
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
    /*
     firstExamNo: 화면에 표시된 첫 문제 번호
     lastExamNo: 화면에 표시된 마지막 문제 번호
     scrollType: 문제를 더 불러오기 위한 스크롤 타입 [next - 아래로 내린 경우, 위로 올린 경우 - pre]
     questionType: 문제 형식 [all - 전체, inCorrectQuestion - 틀린문제, myStarQuestion - 내가 별표 한 문제, solveQuestion - 푼문제, nonSolveQuestion - 안푼 문제, manyQNAQuestion - 질문이 달린 문제]
     examMode: 문제 유형 [package - 일반문제, category - 단원문제]
     limitCount: 가져올 문제수
     */
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        @"", @"examId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/now/play/exam/question/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                //성공
                                                self.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"questionInfos"]];
                                                [self setFinishCheck:self.arM_List];
                                                [self.tbv_List reloadData];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                            
                                            self.str_ImagePreFix = [resulte objectForKey:@"img_prefix"];
                                            self.str_UserThum = [resulte objectForKey:@"userThumbnail"];
                                            
                                            NSArray *ar = [resulte objectForKey:@"questionInfos"];
                                            NSDictionary *dic = [ar firstObject];
//                                            NSArray *ar_Tmp = [dic_Tmp objectForKey:@"examExplainInfos"];
                                            
                                            self.str_Idx = [NSString stringWithFormat:@"%@", [dic objectForKey:@"examId"]];
                                            self.str_TesterId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"testerId"]];
                                            
                                            [self.v_RightMenu.btn_Count setTitle:[NSString stringWithFormat:@"%ld", [[resulte objectForKey:@"myStarQuestionCount"] integerValue]] forState:UIControlStateNormal];
                                        }
                                    }];
}

- (void)setFinishCheck:(NSArray *)ar
{
    NSDictionary *dic = [ar firstObject];
    id userCorrect = [dic objectForKey:@"user_correct"];
    if( [userCorrect isEqual:[NSNull null]] )
    {
        //안푼문제
        isFinish = NO;
    }
    else
    {
        //푼 문제
        [self.btn_Menu removeFromSuperview];
        
        isFinish = YES;
        
        //내답
        NSString *str_UserCorrect = [NSString stringWithFormat:@"%@", [dic objectForKey:@"user_correct"]];
        
        //정답
        NSString *str_Correct = [NSString stringWithFormat:@"%@", [dic objectForKey:@"correctAnswer"]];
        str_Correct = [str_Correct stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        
        if( [str_UserCorrect isEqualToString:str_Correct] )
        {
            isFinishPass = YES;
        }
        else
        {
            isFinishPass = NO;
        }
        
        
    }
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if( self.popTip.isHidden == NO )
    {
        [self.popTip hide];
    }
}

//- (void)scrollViewWillBeginDecelerating:(UIScrollView *)scrollView
//{
//    self.btn_Menu.hidden = YES;
//}
//
//- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
//{
//    self.btn_Menu.hidden = NO;
//}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.arM_List.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QuestionListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuestionListCell" forIndexPath:indexPath];
    
    [self configureCell:cell forRowAtIndexPath:indexPath isOnlySize:NO];

//    [cell updateConstraintsIfNeeded];

    
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return UITableViewAutomaticDimension;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSNumber *num_OldCellHeight = [self.dicM_CellHeight objectForKey:[NSString stringWithFormat:@"%ld", indexPath.section]];
//    CGFloat fOldHeight = [num_OldCellHeight floatValue];
//    if( fOldHeight  > 20 )
//    {
//        return fOldHeight;
//    }
    
    [self configureCell:self.questionListCell forRowAtIndexPath:indexPath isOnlySize:YES];

    [self.questionListCell updateConstraintsIfNeeded];
    [self.questionListCell layoutIfNeeded];

    self.questionListCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.questionListCell.bounds));

    CGFloat fHeight = [self.questionListCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    [self.dicM_CellHeight setObject:[NSNumber numberWithFloat:fHeight] forKey:[NSString stringWithFormat:@"%ld", indexPath.section]];
    
    return fHeight;

}

- (void)configureCell:(QuestionListCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath isOnlySize:(BOOL)isOnlySize
{
    //    self.lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(self.lb_Contents.frame);
    
    if( isOnlySize == NO )
    {
        for( UIView *subView in cell.contentView.subviews )
        {
            [subView removeFromSuperview];
        }
    }
    
    //    NSDictionary *dic = self.arM_List[[self.str_StartIdx integerValue] - 1];
    NSDictionary *dic = self.arM_List[indexPath.section];
    
    __block CGFloat fSampleViewTotalHeight = 20;
    NSArray *ar_ExamQuestionInfos = [dic objectForKey:@"examQuestionInfos"];
    for( NSInteger i = 0; i < ar_ExamQuestionInfos.count; i++ )
    {
        NSDictionary *dic = ar_ExamQuestionInfos[i];
        NSString *str_Type = [dic objectForKey:@"questionType"];
        NSString *str_Body = [dic objectForKey:@"questionBody"];
        //        NSLog(@"%@", str_Type);
        if( [str_Type isEqualToString:@"text"] )
        {
            UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(8, fSampleViewTotalHeight, cell.contentView.frame.size.width - 16, 0)];
            lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(lb_Contents.frame);
            lb_Contents.font = [UIFont fontWithName:@"Helvetica" size:14.f];
            lb_Contents.text = str_Body;
            lb_Contents.numberOfLines = 0;
            
            CGRect frame = lb_Contents.frame;
            frame.size.height = [Util getTextSize:lb_Contents].height;
            lb_Contents.frame = frame;
            
            if( isOnlySize == NO )
            {
                [cell.contentView addSubview:lb_Contents];
            }
            
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
            
            if( isOnlySize == NO )
            {
                [cell.contentView addSubview:lb_Contents];
            }
            
            fSampleViewTotalHeight += rect.size.height + 10;
        }
        else if( [str_Type isEqualToString:@"image"] )
        {
            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(8, fSampleViewTotalHeight, cell.contentView.frame.size.width - 16, 0)];
            iv.contentMode = UIViewContentModeScaleAspectFill;
            iv.clipsToBounds = YES;
            
            
            CGFloat fPer = iv.frame.size.width / [[dic objectForKey:@"width"] floatValue];
            CGFloat fHeight = [[dic objectForKey:@"height"] floatValue] * fPer;
            
            if( isnan(fHeight) )    fHeight = 300.f;

            CGRect frame = iv.frame;
            frame.size.height = fHeight;
            iv.frame = frame;
            
            NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", self.str_ImagePreFix, str_Body];
            [iv sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
            
            if( isOnlySize == NO )
            {
                [cell.contentView addSubview:iv];
            }
            
            fSampleViewTotalHeight += iv.frame.size.height + 10;
            
        }
        else if( [str_Type isEqualToString:@"videoLink"] )
        {
            //유튜브
            YTPlayerView *playerView = [[YTPlayerView alloc] initWithFrame:
                                        CGRectMake(8, fSampleViewTotalHeight, cell.contentView.frame.size.width - 16, (cell.contentView.frame.size.width - 16) * 0.7f)];
            
            NSDictionary *playerVars = @{
                                         @"controls" : @1,
                                         @"playsinline" : @1,
                                         @"autohide" : @1,
                                         @"showinfo" : @0,
                                         @"modestbranding" : @1
                                         };
            
            [playerView loadWithVideoId:str_Body playerVars:playerVars];
            
            if( isOnlySize == NO )
            {
                [cell.contentView addSubview:playerView];
            }
            
            fSampleViewTotalHeight += playerView.frame.size.height + 10;
        }
        else if( [str_Type isEqualToString:@"audio"] )
        {
            //음성
//            self.btn_QuestionPlay = [YmExtendButton buttonWithType:UIButtonTypeCustom];
//            self.btn_QuestionPlay.dic_Info = dic;
//            self.btn_QuestionPlay.frame = CGRectMake(8, fSampleViewTotalHeight, 50, 50);
//            [self.btn_QuestionPlay setImage:BundleImage(@"play_big.png") forState:UIControlStateNormal];
//            [self.btn_QuestionPlay setImage:BundleImage(@"pause_big.png") forState:UIControlStateSelected];
////            [self.btn_QuestionPlay addTarget:self action:@selector(onQuestionPlay:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.contentView addSubview:self.btn_QuestionPlay];
//            
//            fSampleViewTotalHeight += self.btn_QuestionPlay.frame.size.height + 10;
            
//            if( self.v_Audio == nil )
//            {
//                NSString *str_Body = [dic objectForKey:@"questionBody"];
//                NSString *str_Url = [NSString stringWithFormat:@"%@%@", self.str_ImagePreFix, str_Body];
//                
//                NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"AudioView" owner:self options:nil];
//                self.v_Audio = [topLevelObjects objectAtIndex:0];
//                [self.v_Audio initPlayer:str_Url];
//            }
//            
//            self.v_Audio.btn_Play.userInteractionEnabled = NO;
//            
//            CGRect frame = self.v_Audio.frame;
//            frame.origin.y = fSampleViewTotalHeight;
//            frame.size.width = self.view.bounds.size.width;
//            frame.size.height = 60;
//            self.v_Audio.frame = frame;
//            
//            [cell.contentView addSubview:self.v_Audio];
//            
//            fSampleViewTotalHeight += self.v_Audio.frame.size.height + 10;

            NSString *str_Body = [dic objectForKey:@"questionBody"];
            NSString *str_Url = [NSString stringWithFormat:@"%@%@", self.str_ImagePreFix, str_Body];
            
            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"AudioView" owner:self options:nil];
            AudioView *v_Audio = [topLevelObjects objectAtIndex:0];
            [v_Audio initPlayer:str_Url];
            v_Audio.userInteractionEnabled = NO;
            
            CGRect frame = v_Audio.frame;
            frame.origin.y = fSampleViewTotalHeight;
            frame.size.width = self.view.bounds.size.width;
            frame.size.height = 48;
            v_Audio.frame = frame;
            
            if( isOnlySize == NO )
            {
                [cell.contentView addSubview:v_Audio];
            }
            
            fSampleViewTotalHeight += v_Audio.frame.size.height + 10;

        }
        else if( [str_Type isEqualToString:@"video"] )
        {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(8, fSampleViewTotalHeight, cell.contentView.frame.size.width - 16, (cell.contentView.frame.size.width - 16) * 0.7f)];
            
            NSString *str_Url = [NSString stringWithFormat:@"%@%@", self.str_ImagePreFix, str_Body];
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
            
            if( isOnlySize == NO )
            {
                [cell.contentView addSubview:view];
            }
            
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
            
            fSampleViewTotalHeight += view.frame.size.height + 10;
        }
    }
    
    CGRect frame = cell.frame;
    frame.size.height = fSampleViewTotalHeight;
    cell.frame = frame;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 80.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return [self configureHeaderTableview:tableView withSection:section];
}

//- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
//{
//    return 30.0f;
//}
//
//- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    static NSString *CellIdentifier = @"QuestionFooterCell";
//    QuestionFooterCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//    
//    if (cell == nil)
//    {
//        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
//        cell = [topLevelObjects objectAtIndex:0];
//    }
//    
//    NSDictionary *dic = self.arM_List[section];
//    cell.lb_Title.text = [NSString stringWithFormat:@"%@ %@", [dic objectForKey:@"subjectName"], [dic objectForKey:@"examTitle"]];
//    cell.lb_Date.text = [dic objectForKey:@"lastAnswerDate"];
//    
//    return cell;
//}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.arM_List[indexPath.section];
    
    QuestionContainerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
    vc.hidesBottomBarWhenPushed = YES;
    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
    id startIdx = [dic objectForKey:@"examNo"];
    if( [startIdx isEqual:[NSNull null]] )
    {
        vc.str_StartIdx = @"0";
    }
    else
    {
        vc.str_StartIdx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examNo"] integerValue] - 1];
    }
    
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
//    if( indexPath.section == nCurrentSection )
//    {
//        [UIView animateWithDuration:0.3f
//                         animations:^{
//                             
//                             self.v_Answer.alpha = NO;
//                         }];
//    }
//    
//    NSLog(@"out : %ld", indexPath.section);

//    if ([tableView.indexPathsForVisibleRows indexOfObject:indexPath] == NSNotFound)
//    {
//        if( indexPath.section == nCurrentSection )
//        {
//            [UIView animateWithDuration:0.7f
//                             animations:^{
//                                 
//                                 CGRect frame = self.v_Answer.frame;
//                                 frame.origin.y = self.view.bounds.size.height;
//                                 self.v_Answer.frame = frame;
//                             }completion:^(BOOL finished) {
//                                 
//                                 [self.v_Answer removeFromSuperview];
//                             }];
//        }
//        NSLog(@"out : %ld", indexPath.section);
//    }
}

- (UIView *)configureHeaderTableview:(UITableView *)tableView withSection:(NSInteger)section
{
    static NSString *CellIdentifier = @"QuestionListHeaderCell";
    QuestionListHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [cell.btn_Play removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    
    //        NSDictionary *dic = self.arM_List[[self.str_StartIdx integerValue] - 1];
    NSDictionary *dic = self.arM_List[section];
    
    cell.lb_Title.text = [NSString stringWithFormat:@"%@ %@", [dic objectForKey:@"subjectName"], [dic objectForKey:@"examTitle"]];
    cell.lb_Date.text = [dic objectForKey:@"lastAnswerDate"];

    [cell.btn_ViewCnt setTitle:[NSString stringWithFormat:@"%ld", [[dic objectForKey:@"totalAnswerCount"] integerValue]] forState:UIControlStateNormal];
    [cell.btn_StarCnt setTitle:[NSString stringWithFormat:@"%ld", [[dic objectForKey:@"starCount"] integerValue]] forState:UIControlStateNormal];
    [cell.btn_CommentCnt setTitle:[NSString stringWithFormat:@"%ld", [[dic objectForKey:@"replyCount"] integerValue]] forState:UIControlStateNormal];
    //    NSInteger nVideoExplainCount = [[dic objectForKey:@"videoExplainCount"] integerValue];
    
    NSInteger nQnaCnt = [[dic objectForKey:@"explainCount"] integerValue] + [[dic objectForKey:@"qnaCount"] integerValue];
    [cell.btn_QnaCnt setTitle:[NSString stringWithFormat:@"풀이와 질문 %ld", nQnaCnt] forState:UIControlStateNormal];
//    [cell.btn_QnaCnt addTarget:self action:@selector(onDiscription:) forControlEvents:UIControlEventTouchUpInside];
    
    NSInteger nVideoExplainCount = [[dic objectForKey:@"explainCount"] integerValue];
    if( nVideoExplainCount > 0 )
    {
        cell.v_PlayContainer.hidden = NO;
        //        [cell.btn_Play addTarget:self action:@selector(onDiscription:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        cell.v_PlayContainer.hidden = YES;
    }
    
    cell.btn_Info.tag = cell.btn_StarCnt.tag = section;
//    [cell.btn_Info addTarget:self action:@selector(onInfo:) forControlEvents:UIControlEventTouchUpInside];
    
    NSInteger nMyStarCnt = [[dic objectForKey:@"existStarCount"] integerValue];
    [self updateStarStatus:cell.btn_StarCnt withCnt:nMyStarCnt];
    
    [cell.btn_StarCnt addTarget:self action:@selector(onStarToggle:) forControlEvents:UIControlEventTouchUpInside];
    
    
    if( isFinish )
    {
        [cell setLabelColor:[UIColor whiteColor]];
        
        [cell.btn_ViewCnt setImage:BundleImage(@"eye_white.png") forState:UIControlStateNormal];
        [cell.btn_CommentCnt setImage:BundleImage(@"comment_off_white.png") forState:UIControlStateNormal];
        [cell.btn_StarCnt setImage:BundleImage(@"star_white.png") forState:UIControlStateNormal];
        [cell.btn_Info setImage:BundleImage(@"sidemenu_white.png") forState:UIControlStateNormal];

        if( isFinishPass )
        {
            //맞춘문제
            cell.backgroundColor = [UIColor colorWithHexString:@"3bd1fe"];
        }
        else
        {
            //틀린문제
            cell.backgroundColor = kMainRedColor;
        }
        
        //        [cell.btn_ViewCnt setTitle:@"" forState:UIControlStateNormal];
        cell.iv_User.layer.cornerRadius = cell.iv_User.frame.size.width / 2;
        
        NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", self.str_ImagePreFix, self.str_UserThum];
        [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            
            NSString *str_Title = cell.btn_ViewCnt.titleLabel.text;
            [cell.btn_ViewCnt setTitle:[NSString stringWithFormat:@"   %@", str_Title] forState:UIControlStateNormal];
        }];
    }
    
    
    
    return cell;
}
- (void)updateStarStatus:(UIButton *)btn withCnt:(NSInteger)nStarCnt
{
    NSDictionary *dic = self.arM_List[btn.tag];
    if( nStarCnt > 0 )
    {
        //별표를 했으면 별 온 시키고 시험나올듯 글씨 없애준다
        btn.selected = YES;
        [btn setTitle:[NSString stringWithFormat:@"%ld", [[dic objectForKey:@"starCount"] integerValue]] forState:UIControlStateNormal];
    }
    else
    {
        //별표를 안했으면 시험나올듯과 별표카운트 표시
        btn.selected = NO;
//        [btn setTitle:[NSString stringWithFormat:@"시험나올듯 %ld", [[dic objectForKey:@"starCount"] integerValue]] forState:UIControlStateNormal];
        [btn setTitle:[NSString stringWithFormat:@"%ld", [[dic objectForKey:@"starCount"] integerValue]] forState:UIControlStateNormal];
    }
}

- (void)onStarToggle:(UIButton *)btn
{
    NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:self.arM_List[btn.tag]];
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", [dicM objectForKey:@"questionId"]], @"questionId",   //문제 ID
                                        !btn.selected ? @"on" : @"off", @"setMode",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/exam/question/star"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                NSInteger nTotalStarCount = [[dicM objectForKey:@"starCount"] integerValue];
                                                NSInteger nMyStartCnt = [[dicM objectForKey:@"existStarCount"] integerValue];
                                                NSInteger nMyQeustionCnt = [self.v_RightMenu.btn_Count.titleLabel.text integerValue];
                                                if( btn.selected == NO )
                                                {
                                                    //추가
                                                    nMyStartCnt++;
                                                    nTotalStarCount++;
                                                    nMyQeustionCnt++;
                                                }
                                                else
                                                {
                                                    //삭제
                                                    nMyStartCnt--;
                                                    nTotalStarCount--;
                                                    nMyQeustionCnt--;
                                                }
                                                
                                                //네비에 있는 토탈 별표 카운트
                                                [self.v_RightMenu.btn_Count setTitle:[NSString stringWithFormat:@"%ld", nMyQeustionCnt] forState:UIControlStateNormal];

                                                //별표 온오프
                                                [dicM setObject:[NSString stringWithFormat:@"%ld", nMyStartCnt] forKey:@"existStarCount"];
                                                
                                                //해당 문제에 대한 별표 총 갯수
                                                [dicM setObject:[NSString stringWithFormat:@"%ld", nTotalStarCount] forKey:@"starCount"];
                                                
                                                [self.arM_List replaceObjectAtIndex:btn.tag withObject:dicM];
                                                
                                                [self updateStarStatus:btn withCnt:nMyStartCnt];

//                                                btn.selected = !btn.selected;
                                                
//                                                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:btn.tag];
//                                                NSArray *indexPaths = [[NSArray alloc] initWithObjects:indexPath, nil];
////                                                [self.tbv_List reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
//                                                [self configureHeaderTableview:self.tbv_List withSection:btn.tag];

//                                                existStarCount
//                                                [self updateList];
                                            }
                                        }
                                    }];
}


//- (void)reloadHeaders
//{
//    for (NSInteger i = 0; i < [self numberOfSectionsInTableView:self.tbv_List]; i++)
//    {
//        
//        UITableViewHeaderFooterView *header = [self.tableView headerViewForSection:i];
//        [self configureHeader:header forSection:i];
//    }
//}


#pragma mark - IBAction
- (IBAction)goMenu:(id)sender
{
    
}

//- (void)onInfo:(UIButton *)btn
//{
//    NSDictionary *dic = self.arM_List[btn.tag];
//
//    SideMenuViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"SideMenuViewController"];
//    vc.str_TesterId = self.str_TesterId;
//    vc.str_Idx = self.str_Idx;
////    vc.str_StartNo = [NSString stringWithFormat:@"%ld", [self.str_StartIdx integerValue] + 1];
//    [self presentViewController:vc animated:NO completion:^{
//        
//    }];
//}

//- (void)onInfo:(UIButton *)btn
//{
//    CGPoint buttonPosition = [btn convertPoint:CGPointZero toView:self.tbv_List];
//    
//    NSDictionary *dic = self.arM_List[btn.tag];
//    
//    NSMutableString *strM_Msg = [NSMutableString string];
//    
//    //과목
//    NSString *str_SubjectName = [NSString stringWithFormat:@"과목 : %@", [dic objectForKey:@"subjectName"]];
//    [strM_Msg appendString:str_SubjectName];
//    
//    //정답율
//    NSInteger nUserCorrectAnswerCnt = [[dic objectForKey:@"userCorrectAnswerCount"] integerValue];
//    NSInteger nTotalAnswerCnt = [[dic objectForKey:@"totalAnswerCount"] integerValue];
//    
//    CGFloat fVal = (CGFloat)nUserCorrectAnswerCnt / (CGFloat)nTotalAnswerCnt;
//    if( isnan(fVal) )
//    {
//        fVal = .0f;
//    }
//    NSInteger nPer = fVal * 100;
//    NSString *str_CorrectAnswer = [NSString stringWithFormat:@"정답율 : %ld%%", nPer];
//    [strM_Msg appendString:@"\n"];
//    [strM_Msg appendString:str_CorrectAnswer];
//    
//    //이 문제를 푼 사람
//    NSString *str_TotalAnswerCnt = [NSString stringWithFormat:@"이 문제를 푼 사람 : %ld명", nTotalAnswerCnt];
//    [strM_Msg appendString:@"\n"];
//    [strM_Msg appendString:str_TotalAnswerCnt];
//    
//    //이 문제를 맞힌 사람
//    NSString *str_UserCorrentAnswerCnt = [NSString stringWithFormat:@"이 문제를 맞힌 사람 : %ld명", nUserCorrectAnswerCnt];
//    [strM_Msg appendString:@"\n"];
//    [strM_Msg appendString:str_UserCorrentAnswerCnt];
//    
//    
//    self.popTip.popoverColor = kMainColor;
//    //    static int direction = 0;
//    [self.popTip showText:strM_Msg direction:AMPopTipDirectionDown maxWidth:200 inView:self.tbv_List fromFrame:CGRectMake(buttonPosition.x, buttonPosition.y, btn.frame.size.width, btn.frame.size.height) duration:0];
//    //    direction = (direction + 1) % 4;
//    
//}

- (void)onStarList:(UIButton *)btn
{
    StarListViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"StarListViewController"];
    vc.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:vc animated:YES];
}

@end
