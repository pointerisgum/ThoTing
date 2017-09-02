//
//  QuestionDetailViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 6. 22..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "QuestionDetailViewController.h"
#import "SampleView.h"
#import "QuestionListViewController.h"
#import "QuestionContainerViewController.h"
#import "YTPlayerView.h"
#import "AudioView.h"
#import "YmExtendButton.h"
#import "GroupWebViewController.h"
#import "SharedViewController.h"
#import "QuestionStartViewController.h"
#import "ChannelMainViewController.h"

@import AVFoundation;
@import AMPopTip;
@import MediaPlayer;

@interface QuestionDetailViewController ()

//음성문제 관련
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) YmExtendButton *btn_QuestionPlay;
@property (nonatomic, strong) AudioView *v_Audio;
/////////

//비디오 관련
@property (nonatomic, strong) MPMoviePlayerViewController *vc_Movie;
///////////

@property (nonatomic, strong) AMPopTip *popTip;
@property (nonatomic, strong) NSString *str_ImagePreFix;
@property (nonatomic, strong) NSDictionary *dic_Data;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ContentsHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_SampleViewHeight;

//@property (nonatomic, weak) IBOutlet UIView *v_SvContents;
@property (nonatomic, strong) YTPlayerView *playerView;

@property (nonatomic, weak) IBOutlet UIImageView *iv_Cover;
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;
@property (nonatomic, weak) IBOutlet UILabel *lb_Subject;
@property (nonatomic, weak) IBOutlet UILabel *lb_Grade;
@property (nonatomic, weak) IBOutlet UILabel *lb_Ower;
@property (nonatomic, weak) IBOutlet UIButton *btn_Owner;
@property (nonatomic, weak) IBOutlet UILabel *lb_TeacherName;
@property (nonatomic, weak) IBOutlet UILabel *lb_Date;
@property (nonatomic, weak) IBOutlet UILabel *lb_QuestionAndUserCount;
@property (nonatomic, weak) IBOutlet UIButton *btn_Price;

@property (nonatomic, weak) IBOutlet UIImageView *iv_Purcher;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Star;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Discription;
@property (nonatomic, weak) IBOutlet UIImageView *iv_School;

@property (nonatomic, weak) IBOutlet UIButton *btn_Purcher;
@property (nonatomic, weak) IBOutlet UIButton *btn_Star;
@property (nonatomic, weak) IBOutlet UIButton *btn_Discription;
@property (nonatomic, weak) IBOutlet UIButton *btn_School;

@property (nonatomic, weak) IBOutlet SampleView *v_Sample;


@property (nonatomic, weak) IBOutlet UIButton *btn_Group;   //단원보기
@property (nonatomic, weak) IBOutlet UILabel *lb_TotalQuestionCnt;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Star1;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Star2;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Star3;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Star4;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Star5;

@property (nonatomic, weak) IBOutlet UILabel *lb_Tag;

@property (nonatomic, weak) IBOutlet UIButton *btn_Tab2;    //푼 사람
@property (nonatomic, weak) IBOutlet UIButton *btn_Tab3;    //태그
@property (nonatomic, weak) IBOutlet UIButton *btn_Tab4;    //구매

@property (nonatomic, weak) IBOutlet UIButton *btn_Shared;

@end

@implementation QuestionDetailViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self initNaviWithTitle:@"토팅" withLeftItem:[self leftBackMenuBarButtonItem] withRightItem:[self rightBookMarkItem] withColor:[UIColor colorWithHexString:@"F8F8F8"]];
    [self initNaviWithTitle:self.str_Title withLeftItem:[self leftBackMenuBarButtonItem] withRightItem:nil withColor:[UIColor colorWithHexString:@"F8F8F8"]];

    
    self.btn_Shared.layer.cornerRadius = self.btn_Shared.frame.size.width / 2;
    self.btn_Shared.layer.borderColor = kMainColor.CGColor;
    self.btn_Shared.layer.borderWidth = 1.f;

    self.btn_Price.layer.cornerRadius = 8.f;
    self.btn_Price.layer.borderColor = kMainColor.CGColor;
    self.btn_Price.layer.borderWidth = 1.f;
    
    self.btn_Group.layer.cornerRadius = 8.f;
    self.btn_Group.layer.borderColor = kMainRedColor.CGColor;
    self.btn_Group.layer.borderWidth = 1.f;
    
    [self addTabGesture];
    
//    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTouchSample:)];
//    [singleTap setNumberOfTapsRequired:1];
//    [self.v_Sample addGestureRecognizer:singleTap];

//    self.v_Sample.userInteractionEnabled = NO;
    
    self.navigationController.navigationBarHidden = NO;
    
    [AMPopTip appearance].font = [UIFont fontWithName:@"Avenir-Medium" size:12];
    
//    __weak __typeof(&*self)weakSelf = self;

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
 
    self.hidesBottomBarWhenPushed = NO;

    [self updateList];

}

- (void)viewDidLayoutSubviews
{
//    [self updateSampleQuestion];

//    self.lc_ContentsHeight.constant = 1000;
//    self.lc_SampleViewHeight.constant = 1000;

//    self.v_SvContents.frame = CGRectMake(0, 0, self.sv_Main.frame.size.width, 1000);
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


- (void)rightBookMarkPress:(UIButton *)btn
{
    //TODO: 북마크 로직
    
}


#pragma mark - UIGesture
- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
    [self.popTip hide];
}

- (void)onTouchSample:(UIGestureRecognizer *)gestureRecognizer
{
    return; //실제론 샘플 문제 눌렀을때 아무 반응이 없어야 하기 때문에 처리함. 아래는 테스트를 위해 구현한 코드임
    
    if( self.dic_Data == nil )  return;
    
//    NSString *str_Idx = [self.dic_Data objectForKey:@""];
    
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentQuestionIdx"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    NSDictionary *dic_SampleQuestionInfo = [self.dic_Data objectForKey:@"sampleQuestionInfo"];
    QuestionContainerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
    vc.hidesBottomBarWhenPushed = YES;
    vc.str_Idx = self.str_Idx;
    vc.str_StartIdx = @"0";//[NSString stringWithFormat:@"%ld", [[dic_SampleQuestionInfo objectForKey:@"questionId"] integerValue]];
    [self.navigationController pushViewController:vc animated:YES];
}



#pragma mark - Custom
- (void)updateList
{
    __weak __typeof(&*self)weakSelf = self;

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_Idx, @"examId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exam/detail/info"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                //성공
                                                weakSelf.dic_Data = [NSDictionary dictionaryWithDictionary:resulte];
                                                weakSelf.str_ImagePreFix = [weakSelf.dic_Data objectForKey:@"img_prefix"];
                                                [weakSelf updateData:[weakSelf.dic_Data objectForKey:@"examInfo"]];
                                                [weakSelf updateSampleQuestion];
                                                [weakSelf updateSampleQuestion];    //왜 두번해야 음성파일이 나오는지 모르겠네...
//                                                [weakSelf performSelector:@selector(onReload) withObject:nil afterDelay:0.3f];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

- (void)onReload
{
    [self updateSampleQuestion];
}

- (void)updateData:(NSDictionary *)dic
{
    self.iv_Cover.backgroundColor = [UIColor colorWithHexString:[dic objectForKey_YM:@"codeHex"]];
    
    self.lb_Title.text = [dic objectForKey:@"examTitle"];

    self.lb_Subject.text = [dic objectForKey:@"subjectName"];
    
    self.lb_Grade.text = [dic objectForKey_YM:@"schoolGrade"];
    
    self.lb_QuestionAndUserCount.text = [NSString stringWithFormat:@"문제 %@  USER %@", [dic objectForKey_YM:@"questionCount"], [dic objectForKey_YM:@"paidUserCount"]];
    
//    self.lb_Ower.text = [dic objectForKey:@"publisherName"];
    self.lb_Ower.text = [dic objectForKey_YM:@"channelName"];
    
    [self.btn_Owner setTitle:[dic objectForKey_YM:@"channelName"] forState:UIControlStateNormal];
    
//    self.lb_TeacherName.text = [dic objectForKey:@"teacherName"];
    
    NSString *str_Date = [NSString stringWithFormat:@"%@", [dic objectForKey:@"createDate"]];
    
    if( str_Date.length >= 8 )
    {
        NSString *str_Year = [str_Date substringWithRange:NSMakeRange(0, 4)];
        NSString *str_Month = [str_Date substringWithRange:NSMakeRange(4, 2)];
        NSString *str_Day = [str_Date substringWithRange:NSMakeRange(6, 2)];
//        NSString *str_Hour = [str_Date substringWithRange:NSMakeRange(8, 2)];
//        NSString *str_Minute = [str_Date substringWithRange:NSMakeRange(10, 2)];
        
        self.lb_Date.text = [NSString stringWithFormat:@"%04ld.%02ld.%02ld", [str_Year integerValue], [str_Month integerValue], [str_Day integerValue]];
    }
    else
    {
        self.lb_Date.text = [dic objectForKey:@"createDate"];
    }
    
    //전체 문제수
//    self.lb_TotalQuestionCnt.text = [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionCount"]];
    
    //단원보기 유무
    NSInteger nGroupCnt = [[dic objectForKey:@"groupQuestionCount"] integerValue];
    if( nGroupCnt > 0 )
    {
        //단원 있음
        self.btn_Group.hidden = NO;
        [self.btn_Group addTarget:self action:@selector(onShowGroup:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        //단원 없음
        self.btn_Group.hidden = YES;
    }
    [self.btn_Price removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    
    //평가
    NSInteger nStarGrade = [[dic objectForKey_YM:@"starGrade"] integerValue];
    switch (nStarGrade) {
        case 1:
            self.iv_Star1.image = BundleImage(@"star_red.png");
            break;

        case 2:
            self.iv_Star1.image = BundleImage(@"star_red.png");
            self.iv_Star2.image = BundleImage(@"star_red.png");
            break;

        case 3:
            self.iv_Star1.image = BundleImage(@"star_red.png");
            self.iv_Star2.image = BundleImage(@"star_red.png");
            self.iv_Star3.image = BundleImage(@"star_red.png");
            break;

        case 4:
            self.iv_Star1.image = BundleImage(@"star_red.png");
            self.iv_Star2.image = BundleImage(@"star_red.png");
            self.iv_Star3.image = BundleImage(@"star_red.png");
            self.iv_Star4.image = BundleImage(@"star_red.png");
            break;

        case 5:
            self.iv_Star1.image = BundleImage(@"star_red.png");
            self.iv_Star2.image = BundleImage(@"star_red.png");
            self.iv_Star3.image = BundleImage(@"star_red.png");
            self.iv_Star4.image = BundleImage(@"star_red.png");
            self.iv_Star5.image = BundleImage(@"star_red.png");
            break;

        default:
            break;
    }
    
    //푼 사람
    [self.btn_Tab2 setTitle:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"examSolveCount"] integerValue]] forState:UIControlStateNormal];
    
    //태그
    self.lb_Tag.text = [dic objectForKey:@"userMainHashTag"];
    [self.btn_Tab3 setTitle:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"targetSchoolCount"] integerValue]] forState:UIControlStateNormal];

    //구매
    [self.btn_Tab4 setTitle:[NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"examUniqueUserCount"] integerValue]] forState:UIControlStateNormal];

    
    NSString *str_Purchase = [dic objectForKey:@"isPaid"];
    if( [str_Purchase isEqualToString:@"paid"] )
    {
        //구매한 경우
        [self.btn_Price setTitle:@"문제풀기" forState:UIControlStateNormal];
        [self.btn_Price addTarget:self action:@selector(onShowMyPage:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        NSString *str_Purchers = @"";
        if( [[dic objectForKey_YM:@"heartCount"] integerValue] == 0 )
        {
            //무료
            str_Purchers = @"무료";
        }
        else
        {
            //유료
            NSInteger nQuestionCount = [[dic objectForKey_YM:@"questionCount"] integerValue];
            str_Purchers = [NSString stringWithFormat:@"$%f", nQuestionCount - 0.01];
        }
        
        [self.btn_Price setTitle:str_Purchers forState:UIControlStateNormal];
        [self.btn_Price addTarget:self action:@selector(onPrice:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    
//    [self.btn_Purcher setTitle:[NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examIniqueUserCount"] integerValue]] forState:UIControlStateNormal];
//    [self.btn_Star setTitle:[NSString stringWithFormat:@"%ld", [[dic objectForKey:@"starGrade"] integerValue]] forState:UIControlStateNormal];
//    [self.btn_Discription setTitle:[NSString stringWithFormat:@"%ld", [[dic objectForKey:@"explainCount"] integerValue]] forState:UIControlStateNormal];
//    [self.btn_School setTitle:[NSString stringWithFormat:@"%ld", [[dic objectForKey:@"targetSchoolCount"] integerValue]] forState:UIControlStateNormal];
    
}

- (void)onShowGroup:(UIButton *)btn
{
    NSDictionary *dic = [self.dic_Data objectForKey:@"examInfo"];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    GroupWebViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"GroupWebViewController"];
    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"groupId"] integerValue]];
    vc.str_GroupName = [dic objectForKey_YM:@"groupName"];
    vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    vc.modalPresentationStyle = UIModalPresentationFullScreen;
    
    [self.navigationController pushViewController:vc animated:YES];
}

//샘플문제
- (void)updateSampleQuestion
{
    for( UIView *subView in self.v_Sample.subviews )
    {
        if( subView.tag == 0 )
        {
            [subView removeFromSuperview];
        }
    }
    
    NSDictionary *dic_SampleQuestionInfo = [self.dic_Data objectForKey:@"sampleQuestionInfo"];

    self.v_Sample.lb_Number.text = [NSString stringWithFormat:@"%ld", [[dic_SampleQuestionInfo objectForKey:@"examNo"] integerValue]];
    [self.v_Sample.btn_ViewCnt setTitle:[NSString stringWithFormat:@"%ld", [[dic_SampleQuestionInfo objectForKey:@"totalAnswerCount"] integerValue]] forState:UIControlStateNormal];
    [self.v_Sample.btn_StarCnt setTitle:[NSString stringWithFormat:@"%ld", [[dic_SampleQuestionInfo objectForKey:@"starCount"] integerValue]] forState:UIControlStateNormal];
    [self.v_Sample.btn_CommentCnt setTitle:[NSString stringWithFormat:@"%ld", [[dic_SampleQuestionInfo objectForKey:@"replayCount"] integerValue]] forState:UIControlStateNormal];
    
//    NSInteger nVideoExplainCount = [[dic_SampleQuestionInfo objectForKey:@"videoExplainCount"] integerValue];
    NSInteger nVideoExplainCount = [[dic_SampleQuestionInfo objectForKey_YM:@"explainCount"] integerValue];

    self.v_Sample.btn_Play.layer.borderWidth = 0.f;
//    self.v_Sample.btn_Play.layer.cornerRadius = 0.f;
    
    if( nVideoExplainCount > 0 )
    {
        self.v_Sample.btn_Play.hidden = NO;
        
        NSDictionary *dic_ExamInfo = [self.dic_Data objectForKey:@"examInfo"];
        NSInteger nQnaCnt = nVideoExplainCount + [[dic_ExamInfo objectForKey_YM:@"qnaCount"] integerValue];
        [self.v_Sample.btn_Play setTitle:[NSString stringWithFormat:@"풀이와 질문 %ld", nQnaCnt] forState:UIControlStateNormal];
    }
    else
    {
        self.v_Sample.btn_Play.hidden = YES;
    }
    
    CGFloat fSampleViewTotalHeight = 48;
    NSDictionary *dic_ExamInfo = [self.dic_Data objectForKey:@"sampleQuestionInfo"];
    NSArray *ar_ExamQuestionInfos = [dic_ExamInfo objectForKey:@"examQuestionInfos"];
    for( NSInteger i = 0; i < ar_ExamQuestionInfos.count; i++ )
    {
        NSDictionary *dic = ar_ExamQuestionInfos[i];
        NSString *str_Type = [dic objectForKey:@"questionType"];
        NSString *str_Body = [dic objectForKey:@"questionBody"];
        NSLog(@"%@", str_Type);
        if( [str_Type isEqualToString:@"text"] )
        {
            UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(8, fSampleViewTotalHeight, self.v_Sample.frame.size.width - 16, 0)];
            lb_Contents.font = [UIFont fontWithName:@"Helvetica" size:14.f];
//            lb_Contents.textColor = [UIColor darkGrayColor];
            lb_Contents.text = str_Body;
            lb_Contents.numberOfLines = 0;
            
            CGRect frame = lb_Contents.frame;
            frame.size.height = [Util getTextSize:lb_Contents].height;
            lb_Contents.frame = frame;
            
            [self.v_Sample addSubview:lb_Contents];
            
            fSampleViewTotalHeight += lb_Contents.frame.size.height + 10;
        }
        else if( [str_Type isEqualToString:@"html"] )
        {
            NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[str_Body dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(self.v_Sample.frame.size.width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];

            UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(8, fSampleViewTotalHeight, self.v_Sample.frame.size.width - 16, rect.size.height)];
            lb_Contents.numberOfLines = 0;
            lb_Contents.attributedText = attrStr;
            [self.v_Sample addSubview:lb_Contents];
            
            fSampleViewTotalHeight += rect.size.height + 10;
        }
        else if( [str_Type isEqualToString:@"image"] )
        {
            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(8, fSampleViewTotalHeight, self.v_Sample.frame.size.width - 16, 0)];
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
            
            
            [self.v_Sample addSubview:iv];
            
            fSampleViewTotalHeight += iv.frame.size.height + 10;
        }
        else if( [str_Type isEqualToString:@"videoLink"] )
        {
            //유튜브
            self.playerView = [[YTPlayerView alloc] initWithFrame:
                               CGRectMake(8, fSampleViewTotalHeight, self.v_Sample.frame.size.width - 16, (self.v_Sample.frame.size.width - 16) * 0.7f)];
            
            NSDictionary *playerVars = @{
                                         @"controls" : @1,
                                         @"playsinline" : @1,
                                         @"autohide" : @1,
                                         @"showinfo" : @0,
                                         @"modestbranding" : @1
                                         };
            
            [self.playerView loadWithVideoId:str_Body playerVars:playerVars];
            
            self.playerView.userInteractionEnabled = NO;
            [self.v_Sample addSubview:self.playerView];
            
            fSampleViewTotalHeight += self.playerView.frame.size.height + 10;
        }
        else if( [str_Type isEqualToString:@"audio"] )
        {
            //음성
            //            self.btn_QuestionPlay = [YmExtendButton buttonWithType:UIButtonTypeCustom];
            //            self.btn_QuestionPlay.dic_Info = dic;
            //            self.btn_QuestionPlay.frame = CGRectMake(8, fSampleViewTotalHeight, 50, 50);
            //            [self.btn_QuestionPlay setImage:BundleImage(@"play_big.png") forState:UIControlStateNormal];
            //            [self.btn_QuestionPlay setImage:BundleImage(@"pause_big.png") forState:UIControlStateSelected];
            //            [self.btn_QuestionPlay addTarget:self action:@selector(onQuestionPlay:) forControlEvents:UIControlEventTouchUpInside];
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
            
            NSString *str_Body = [dic objectForKey:@"questionBody"];
            NSString *str_Url = [NSString stringWithFormat:@"%@%@", self.str_ImagePreFix, str_Body];
            
            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"AudioView" owner:self options:nil];
            self.v_Audio = [topLevelObjects objectAtIndex:0];
            [self.v_Audio initPlayer:str_Url];

            CGRect frame = self.v_Audio.frame;
            frame.origin.x = 8;
            frame.origin.y = fSampleViewTotalHeight;
            frame.size.width = self.v_Sample.frame.size.width - 16.f;
            frame.size.height = 48;
            self.v_Audio.frame = frame;
            
            self.v_Audio.userInteractionEnabled = NO;
            [self.v_Sample addSubview:self.v_Audio];
            fSampleViewTotalHeight += self.v_Audio.frame.size.height + 10;
            
        }
        else if( [str_Type isEqualToString:@"video"] )
        {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(8, fSampleViewTotalHeight, self.v_Sample.frame.size.width - 16, (self.v_Sample.frame.size.width - 16) * 0.7f)];
            
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
            
            self.vc_Movie.view.userInteractionEnabled = NO;
            [view addSubview:self.vc_Movie.view];
            [self.v_Sample addSubview:view];
            
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
            
            fSampleViewTotalHeight += view.frame.size.height + 10;
        }
    }
    
    
    //보기입력
    CGFloat fX = 15.f;
    NSArray *ar_ExamUserItemInfos = [dic_ExamInfo objectForKey:@"examUserItemInfos"];
    for( NSInteger i = 0; i < ar_ExamUserItemInfos.count; i++ )
    {
        /*
         itemBody = "<p>\Uc2dc\Uc804 \Uc0c1\Uc778\Uc758 \Uae08\Ub09c\Uc804\Uad8c\Uc774 \Uac15\Ud654\Ub418\Uc5c8\Ub2e4.<br></p>";
         itemNo = 1;
         noVal = 2;
         printNo = "\U2461";
         type = item;
         */
        NSDictionary *dic = ar_ExamUserItemInfos[i];
        NSString *str_Type = [dic objectForKey:@"type"];
        NSString *str_Body = [dic objectForKey:@"itemBody"];
        NSString *str_Number = [NSString stringWithFormat:@"%@ ", [dic objectForKey:@"printNo"]];
        
        if( [str_Type isEqualToString:@"itemImage"] )
        {
            UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(fX, fSampleViewTotalHeight, 20, 20)];
            lb_Contents.numberOfLines = 0;
            lb_Contents.text = str_Number;
            [self.v_Sample addSubview:lb_Contents];
            
            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(fX + 20, fSampleViewTotalHeight, self.v_Sample.frame.size.width - (20 + (fX * 2)), 0)];
            iv.contentMode = UIViewContentModeScaleAspectFill;
            iv.clipsToBounds = YES;
            
            NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", self.str_ImagePreFix, str_Body];
            
            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:str_ImageUrl]];
            UIImage *image = [UIImage imageWithData:imageData];
            UIImage *resizeImage = [Util imageWithImage:image convertToWidth:iv.frame.size.width];
            iv.image = resizeImage;
            
            CGRect frame = iv.frame;
            frame.size.height = resizeImage.size.height;
            iv.frame = frame;
            
            [self.v_Sample addSubview:iv];
            
            fSampleViewTotalHeight += iv.frame.size.height + 10;
        }
        else
        {
            NSMutableAttributedString * attrStr_Html = [[NSMutableAttributedString alloc] initWithData:[str_Body dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            
            UIFont *font = [UIFont fontWithName:@"Helvetica" size:14.f];
            NSDictionary *dic_Attr = [NSDictionary dictionaryWithObject:font
                                                                 forKey:NSFontAttributeName];
            NSMutableAttributedString *attrStr = [[NSMutableAttributedString alloc] initWithString:str_Number attributes:dic_Attr];
            [attrStr appendAttributedString:attrStr_Html];
            
            CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(self.v_Sample.frame.size.width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
            
            UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(fX, fSampleViewTotalHeight, self.v_Sample.frame.size.width - 16, rect.size.height)];
            lb_Contents.numberOfLines = 0;
            lb_Contents.attributedText = attrStr;
            [self.v_Sample addSubview:lb_Contents];
            
            fSampleViewTotalHeight += rect.size.height;
        }
    }
    
    
    CGRect frame = self.v_Sample.frame;
    frame.size.height = fSampleViewTotalHeight;
    self.v_Sample.frame = frame;
//    self.v_Sample.backgroundColor = [UIColor redColor];
    
    self.sv_Main.contentSize = CGSizeMake(0, self.v_LastObj.frame.origin.y + self.v_Sample.frame.size.height + 20);
//    self.lc_SampleViewHeight.constant = fSampleViewTotalHeight;
    
//    [self.view setNeedsLayout];
}

#pragma mark - IBAction
- (IBAction)goPurchers:(id)sender
{
    
}

- (IBAction)goDiscription:(id)sender
{
    
}

- (IBAction)goInfo:(id)sender
{
    return;
    
    if( self.dic_Data == nil )  return;
    
    UIButton *btn = (UIButton *)sender;
    CGPoint buttonPosition = [btn convertPoint:CGPointZero toView:self.v_Sample];
    
    NSDictionary *dic_ExamInfo = [self.dic_Data objectForKey:@"examInfo"];
    NSDictionary *dic_SampleQuestionInfo = [self.dic_Data objectForKey:@"sampleQuestionInfo"];
    
    NSMutableString *strM_Msg = [NSMutableString string];
    
    //과목
    NSString *str_Target = [NSString stringWithFormat:@"과목 : %@", [dic_ExamInfo objectForKey:@"subjectName"]];
    [strM_Msg appendString:str_Target];
    
    //단원
    NSInteger nGroupId = [[dic_ExamInfo objectForKey:@"groupId"] integerValue];
    if( nGroupId > 0 )
    {
        [strM_Msg appendString:@"\n"];
        NSString *str_Group = [NSString stringWithFormat:@"단원 : %@", [dic_ExamInfo objectForKey:@"groupName"]];
        [strM_Msg appendString:str_Group];
    }
    
    //정답율
    NSInteger nUserCorrectAnswerCnt = [[dic_SampleQuestionInfo objectForKey:@"userCorrectAnswerCount"] integerValue];
    NSInteger nTotalAnswerCnt = [[dic_SampleQuestionInfo objectForKey:@"totalAnswerCount"] integerValue];
    
    CGFloat fVal = (CGFloat)nUserCorrectAnswerCnt / (CGFloat)nTotalAnswerCnt;
    if( isnan(fVal) )
    {
        fVal = .0f;
    }
    NSInteger nPer = fVal * 100;
    NSString *str_CorrectAnswer = [NSString stringWithFormat:@"정답율 : %ld%%", nPer];
    [strM_Msg appendString:@"\n"];
    [strM_Msg appendString:str_CorrectAnswer];
    
    //이 문제를 푼 사람
    NSString *str_TotalAnswerCnt = [NSString stringWithFormat:@"이 문제를 푼 사람 : %ld명", nTotalAnswerCnt];
    [strM_Msg appendString:@"\n"];
    [strM_Msg appendString:str_TotalAnswerCnt];
    
    //이 문제를 맞힌 사람
    NSString *str_UserCorrentAnswerCnt = [NSString stringWithFormat:@"이 문제를 맞힌 사람 : %ld명", nUserCorrectAnswerCnt];
    [strM_Msg appendString:@"\n"];
    [strM_Msg appendString:str_UserCorrentAnswerCnt];
    
    
    self.popTip.popoverColor = kMainColor;
//    static int direction = 0;
    [self.popTip showText:strM_Msg direction:AMPopTipDirectionDown maxWidth:200 inView:self.v_Sample fromFrame:CGRectMake(buttonPosition.x, buttonPosition.y, btn.frame.size.width, btn.frame.size.height) duration:0];
//    direction = (direction + 1) % 4;

}


- (void)onShowMyPage:(UIButton *)btn
{
    NSDictionary *dic = [self.dic_Data objectForKey:@"examInfo"];
    QuestionStartViewController  *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"QuestionStartViewController"];
    //        vc.hidesBottomBarWhenPushed = YES;
    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
    vc.str_StartIdx = @"0";
    vc.str_Title = [dic objectForKey:@"examTitle"];
    vc.str_ChannelId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]]; //self.str_ChannelId;
    //    vc.str_UserIdx = self.str_UserIdx;
    vc.isPdf = [[dic objectForKey:@"examType"] isEqualToString:@"pdfExam"];
    
    [self.navigationController pushViewController:vc animated:YES];

//    //마이페이지 문제들로 이동
//    [[NSNotificationCenter defaultCenter] postNotificationName:kChangeTabBar object:[NSNumber numberWithInteger:5]];

    
//    //문제풀기
//    [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentQuestionIdx"];
//    [[NSUserDefaults standardUserDefaults] synchronize];
//    
//    NSDictionary *dic = [self.dic_Data objectForKey:@"examInfo"];
//    
//    QuestionContainerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
//    vc.hidesBottomBarWhenPushed = YES;
//    vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
//    vc.str_StartIdx = @"0";
//    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onPrice:(UIButton *)btn
{
    __block NSDictionary *dic = [self.dic_Data objectForKey:@"examInfo"];
    
    UIAlertView *alert = CREATE_ALERT(nil, @"문제를 구매하시겠습니까?", @"예", @"아니요");
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        if( buttonIndex == 0 )
        {
            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                [Util getUUID], @"uuid",
                                                [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]], @"examId",
                                                nil];
            
            [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/user/paymentinfo"
                                                param:dicM_Params
                                           withMethod:@"POST"
                                            withBlock:^(id resulte, NSError *error) {
                                                
                                                [MBProgressHUD hide];
                                                
                                                if( resulte )
                                                {
                                                    NSLog(@"resulte : %@", resulte);
                                                    NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                    if( nCode == 200 )
                                                    {
                                                        ALERT(nil, @"문제를 구매 했습니다", nil, @"확인", nil);
                                                        
                                                        
                                                        //채팅방에서 부른 경우 콜백으로 구매 상태 업데이트
                                                        if( self.completionPriceBlock )
                                                        {
                                                            self.completionPriceBlock(nil);
                                                        }
                                                        
                                                        
//                                                        [[NSNotificationCenter defaultCenter] postNotificationName:kChangeTabBar object:[NSNumber numberWithInteger:5]];

//                                                        UIAlertView *alert = CREATE_ALERT(nil, @"문제를 구매하였습니다\n문제풀기 화면으로 이동하시겠습니까?", @"예", @"아니요");
//                                                        [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
//                                                            if( buttonIndex == 0 )
//                                                            {
//                                                                //TODO: 문제풀기 화면으로 이동
//                                                                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"CurrentQuestionIdx"];
//                                                                [[NSUserDefaults standardUserDefaults] synchronize];
//                                                                
//                                                                QuestionContainerViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionContainerViewController"];
//                                                                vc.hidesBottomBarWhenPushed = YES;
//                                                                vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"examId"] integerValue]];
//                                                                vc.str_StartIdx = @"0";
//                                                                [self.navigationController pushViewController:vc animated:YES];
//                                                            }
//                                                        }];
                                                        
                                                        [self updateList];
                                                    }
                                                    else
                                                    {
                                                        [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                    }
                                                }
                                            }];
        }
    }];
}

- (IBAction)goShared:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chatting" bundle:nil];
    SharedViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SharedViewController"];
    vc.hidesBottomBarWhenPushed = YES;
    vc.str_ExamId = self.str_Idx;
    vc.str_QuestionId = @"0";
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goChannel:(id)sender
{
//    NSDictionary *dic_Main = self.arM_List[btn.tag];
//    
//    NSString *str_ChannelId = @"";
//    NSArray *ar_ExamInfos = [dic_Main objectForKey:@"examInfos"];
//    if( ar_ExamInfos.count > 0 )
//    {
//        NSDictionary *dic = [ar_ExamInfos firstObject];
//        str_ChannelId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]];
//    }
//    else
//    {
//        str_ChannelId = [NSString stringWithFormat:@"%@", [dic_Main objectForKey:@"basicConditionValue"]];
//    }
    
    NSDictionary *dic = [self.dic_Data objectForKey:@"examInfo"];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Channel" bundle:nil];
    ChannelMainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChannelMainViewController"];
    vc.hidesBottomBarWhenPushed = YES;
    vc.isShowNavi = YES;
    vc.str_ChannelId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
