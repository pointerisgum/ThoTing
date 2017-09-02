//
//  QuestionDiscriptionViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 6. 29..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "QuestionDiscriptionViewController.h"
#import "QuestionListCell.h"
#import "YTPlayerView.h"
#import "YmExtendButton.h"
#import "AudioView.h"
#import "DiscripFooterView.h"
#import "DiscripHeaderCell.h"
#import "AddDiscripViewController.h"
#import "SBJsonParser.h"
//#import "AddDicscriptionFooterCell.h"
#import "VideoPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>

@import AVFoundation;
@import MediaPlayer;

@interface QuestionDiscriptionViewController ()
{
    CGFloat fContentsHeight;    //컨텐츠 셀 높이
    NSString *str_ImagePreFix;
    NSString *str_ImagePreUrl;
    NSString *str_UserImagePrefix;
}

@property (nonatomic, strong) NSArray *ar_DList;
@property (nonatomic, strong) NSArray *ar_QList;
@property (nonatomic, strong) NSMutableDictionary *dicM_Video;

//푸터
@property (nonatomic, strong) UISegmentedControl *sg;
@property (nonatomic, strong) DiscripFooterView *v_Footer;
///////////


@property (nonatomic, strong) QuestionListCell *questionListCell;
@property (nonatomic, strong) YTPlayerView *playerView;
//음성문제 관련
@property (nonatomic, strong) AVPlayerItem *playerItem;
@property (nonatomic, strong) AVPlayer *player;
@property (nonatomic, strong) YmExtendButton *btn_QuestionPlay;
@property (nonatomic, strong) AudioView *v_Audio;
/////////

//비디오 관련
//@property (nonatomic, strong) MPMoviePlayerViewController *vc_Movie;
@property (nonatomic, strong) AVPlayer *currentPlayer;
@property (nonatomic, strong) YmExtendButton *btn_CurrentPlay;
///////////

@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet UITableView *tbv_QList;

@property (nonatomic, weak) IBOutlet UIView *v_DHeader;
@property (nonatomic, weak) IBOutlet UIView *v_QHeader;

@property (nonatomic, weak) IBOutlet UIButton *btn_Like;
@property (nonatomic, weak) IBOutlet UIButton *btn_New;

@property (nonatomic, weak) IBOutlet UIButton *btn_QLike;
@property (nonatomic, weak) IBOutlet UIButton *btn_QNew;

@property (nonatomic, weak) IBOutlet UIImageView *iv_DUnderLine;
@property (nonatomic, weak) IBOutlet UIImageView *iv_QUnderLine;

@end

@implementation QuestionDiscriptionViewController

- (void)stopAllContents
{
    if( self.currentPlayer )
    {
        [self.currentPlayer pause];
        self.currentPlayer = nil;
    }
    if( self.v_Audio.player )
    {
        [self.v_Audio.player pause];
        [self.v_Audio.player seekToTime:CMTimeMake(0, 1)];
        self.v_Audio.player = nil;
    }
    if( self.playerView )
    {
        [self.playerView stopVideo];
        self.playerView = nil;
    }
}

- (void)onSegChange:(UISegmentedControl *)seg
{
    [self.v_Footer.btn_AddDiscrip removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    
    if( seg.selectedSegmentIndex == 0 )
    {
//        [SendBird disconnect];
        [self joinDRoom];

//        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"DiscripFooterView" owner:self options:nil];
//        self.v_Footer = [topLevelObjects objectAtIndex:0];
//        self.tbv_List.tableFooterView = self.v_Footer;
//
//        [self.v_Footer.btn_AddDiscrip setTitle:@"문제풀이 추가하기" forState:UIControlStateNormal];
//        [self.v_Footer.btn_AddDiscrip addTarget:self action:@selector(onAddDiscription:) forControlEvents:UIControlEventTouchUpInside];

        self.tbv_List.hidden = self.v_DHeader.hidden = NO;
        self.tbv_QList.hidden = self.v_QHeader.hidden = YES;
    }
    else
    {
//        [SendBird disconnect];
        [self joinQRoom];

//        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"DiscripFooterView" owner:self options:nil];
//        self.v_Footer = [topLevelObjects objectAtIndex:0];
//        self.tbv_QList.tableFooterView = self.v_Footer;
//
//        [self.v_Footer.btn_AddDiscrip setTitle:@"질문하기" forState:UIControlStateNormal];
//        [self.v_Footer.btn_AddDiscrip addTarget:self action:@selector(onAddQestion:) forControlEvents:UIControlEventTouchUpInside];

        self.tbv_List.hidden = self.v_DHeader.hidden = YES;
        self.tbv_QList.hidden = self.v_QHeader.hidden = NO;
        
        [self.tbv_QList reloadData];
    }
}

- (void)onAddDiscription:(UIButton *)btn
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    AddDiscripViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"AddDiscripViewController"];
    vc.str_Idx = self.str_QuestionId;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)onAddQestion:(UIButton *)btn
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    AddDiscripViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"AddDiscripViewController"];
    vc.isQuestionMode = YES;
    vc.str_Idx = self.str_QuestionId;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.btn_Like.hidden = YES;
    self.btn_New.hidden = YES;
    self.btn_QLike.hidden = YES;
    self.btn_QNew.hidden = YES;

    self.tbv_List.separatorColor = [UIColor clearColor];
    self.tbv_QList.separatorColor = [UIColor clearColor];

    self.dicM_Video = [NSMutableDictionary dictionary];
    
//    NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"DiscripFooterView" owner:self options:nil];
//    self.v_Footer = [topLevelObjects objectAtIndex:0];
//    [self.v_Footer.btn_AddDiscrip addTarget:self action:@selector(onAddDiscription:) forControlEvents:UIControlEventTouchUpInside];
//    self.tbv_List.tableFooterView = self.v_Footer;
    
    self.sg = [[UISegmentedControl alloc] initWithItems:@[@"문제풀이", @"질문"]];
    
    if( self.isQuestion )
    {
        self.sg.selectedSegmentIndex = 1;
        
        self.tbv_List.hidden = self.v_DHeader.hidden = YES;
        self.tbv_QList.hidden = self.v_QHeader.hidden = NO;
    }
    else
    {
        self.sg.selectedSegmentIndex = 0;
        
        self.tbv_List.hidden = self.v_DHeader.hidden = NO;
        self.tbv_QList.hidden = self.v_QHeader.hidden = YES;
    }
    
    [self.sg addTarget:self action:@selector(onSegChange:) forControlEvents:UIControlEventValueChanged];
    
    self.sg.frame = CGRectMake(0, 0, 200, 30);
    
    
    self.navigationItem.titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 30)];
    self.navigationController.navigationBar.opaque = YES;
    [self.navigationItem.titleView addSubview:self.sg];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:@"F8F8F8"]];
    [self.navigationController.navigationBar setTranslucent:NO];

    
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 44, 44);
    btn_BarItem.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    [btn_BarItem setImage:BundleImage(@"Icon_Nav__Black_Back.png") forState:UIControlStateNormal];
    //    [btn_BarItem setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_BarItem addTarget:self action:@selector(leftBackSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
    

//    [self initNaviWithTitle:@"문제풀이" withLeftItem:[self leftBackBlackMenuBarButtonItem] withRightItem:nil withHexColor:@"F8F8F8"];

    self.questionListCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([QuestionListCell class])];

    [self updateDList];
    [self updateQList];
    
    [self startSendBird];

    [self joinDRoom];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [self stopAllContents];
//    [self.vc_Movie.moviePlayer stop];
//    self.vc_Movie = nil;
}

- (void)viewDidLayoutSubviews
{
    CGRect frame = self.v_Footer.frame;
    frame.size.height = 44.f;
    self.v_Footer.frame = frame;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)leftBackSideMenuButtonPressed:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (void)updateDList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_QuestionId, @"questionId",
                                        @"", @"limitCount",
                                        @"", @"lastQnaId",
                                        self.btn_Like.selected ? @"thubmup" : @"newest", @"orderBy",
                                        @"list", @"resultType",
                                        nil];
    
    __weak __typeof(&*self)weakSelf = self;
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exam/question/explain/list"
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
                                                NSInteger nTotalCnt = [[resulte objectForKey:@"dataCount"] integerValue];
                                                
                                                [self.sg setTitle:[NSString stringWithFormat:@"문제풀이 %ld", nTotalCnt] forSegmentAtIndex:0];
                                                
                                                if( nTotalCnt < 2 )
                                                {
                                                    self.btn_Like.hidden = YES;
                                                    self.btn_New.hidden = YES;
                                                }
                                                else
                                                {
                                                    self.btn_Like.hidden = NO;
                                                    self.btn_New.hidden = NO;
                                                }
                                                
                                                str_ImagePreFix = [resulte objectForKey:@"image_prefix"];
                                                str_ImagePreUrl = [resulte objectForKey:@"imgUrl"];
                                                str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
                                                
                                                weakSelf.ar_DList = [resulte objectForKey:@"data"];
                                                
                                                if( weakSelf.ar_DList.count > 0 )
                                                {
                                                    self.iv_DUnderLine.hidden = NO;
                                                }
                                                else
                                                {
                                                    self.iv_DUnderLine.hidden = YES;
                                                }
                                                
                                                [weakSelf.tbv_List reloadData];
                                            }
                                            else
                                            {
                                                [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

- (void)updateQList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_QuestionId, @"questionId",
                                        @"list", @"resultType",
                                        @"", @"limitCount",
                                        @"", @"lastQnaId",
                                        self.btn_QLike.selected ? @"thubmup" : @"newest", @"orderBy",
                                        nil];
    
    __weak __typeof(&*self)weakSelf = self;
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exam/question/qna/list"
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
                                                NSInteger nTotalCnt = [[resulte objectForKey:@"dataCount"] integerValue];
                                                
                                                if( nTotalCnt < 2 )
                                                {
                                                    self.btn_QLike.hidden = YES;
                                                    self.btn_QNew.hidden = YES;
                                                }
                                                else
                                                {
                                                    self.btn_QLike.hidden = NO;
                                                    self.btn_QNew.hidden = NO;
                                                }

                                                [self.sg setTitle:[NSString stringWithFormat:@"질문 %ld", nTotalCnt] forSegmentAtIndex:1];
                                                
//                                                str_ImagePreFix = [resulte objectForKey:@"image_prefix"];
//                                                str_ImagePreUrl = [resulte objectForKey:@"imgUrl"];
//                                                str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
                                                
                                                weakSelf.ar_QList = [resulte objectForKey:@"data"];
                                                
                                                if( weakSelf.ar_QList.count > 0 )
                                                {
                                                    self.iv_QUnderLine.hidden = NO;
                                                }
                                                else
                                                {
                                                    self.iv_QUnderLine.hidden = YES;
                                                }

                                                [weakSelf.tbv_QList reloadData];
                                            }
                                            else
                                            {
                                                [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

- (void)configureCell:(QuestionListCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withAddMode:(BOOL)isAdd
{
    for( UIView *subView in cell.contentView.subviews )
    {
        [subView removeFromSuperview];
    }

    __block CGFloat fSampleViewTotalHeight = 20;

    NSDictionary *dic_Info = self.ar_DList[indexPath.section];
    
    NSString *str_ItemType = [dic_Info objectForKey:@"itemType"];
    NSArray *ar = nil;
    BOOL isDiscrip = [str_ItemType isEqualToString:@"explain"];
    NSInteger nX = 8;
    if( isDiscrip )
    {
        ar = [dic_Info objectForKey:@"explainBody"];
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        ar = [dic_Info objectForKey:@"replyBody"];
        cell.contentView.backgroundColor = [UIColor colorWithHexString:@"F3F3F3"];
        nX = 45.f;
    }

//    NSArray *ar = [dic_Info objectForKey:@"examExplainInfo"];
    
    for( NSInteger i = 0; i < ar.count; i++ )
    {
        NSDictionary *dic = ar[i];
        NSString *str_Type = isDiscrip ? [dic objectForKey:@"explainType"] : [dic objectForKey:@"replyType"];
        NSString *str_Body = isDiscrip ? [dic objectForKey:@"explainBody"] : [dic objectForKey:@"replyBody"];

//        NSDictionary *dic = ar[i];
//        NSString *str_Type = [dic objectForKey:@"explainType"];
//        NSString *str_Body = [dic objectForKey:@"explainBody"];
        //        NSLog(@"%@", str_Type);
        if( [str_Type isEqualToString:@"text"] )
        {
            UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(nX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (nX + 8), 0)];
            lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(lb_Contents.frame);
            lb_Contents.font = [UIFont fontWithName:@"Helvetica" size:14.f];
            lb_Contents.text = str_Body;
            lb_Contents.numberOfLines = 0;
            
            CGRect frame = lb_Contents.frame;
            frame.size.height = [Util getTextSize:lb_Contents].height;
            lb_Contents.frame = frame;
            
            if( isAdd )
            {
                [cell.contentView addSubview:lb_Contents];
            }
            
            
            fSampleViewTotalHeight += lb_Contents.frame.size.height + 20;
        }
        else if( [str_Type isEqualToString:@"html"] )
        {
            NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[str_Body dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(cell.contentView.frame.size.width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
            
            UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(nX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (nX + 8), rect.size.height)];
            lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(lb_Contents.frame);
            lb_Contents.numberOfLines = 0;
            lb_Contents.attributedText = attrStr;
            
            if( isAdd )
            {
                [cell.contentView addSubview:lb_Contents];
            }
            
            fSampleViewTotalHeight += rect.size.height + 20;
        }
        else if( [str_Type isEqualToString:@"image"] )
        {
//            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(nX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (nX + 8), 0)];
//            iv.contentMode = UIViewContentModeScaleAspectFill;
//
//            NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, str_Body];
//
//            [iv sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//
//                UIImage *resizeImage = [Util imageWithImage:image convertToWidth:iv.frame.size.width];
//                CGRect frame = iv.frame;
//                frame.size.height = resizeImage.size.height;
//                iv.frame = frame;
//
//                [cell.contentView addSubview:iv];
//
//                fSampleViewTotalHeight += iv.frame.size.height + 10;
//
//
//                [self.questionListCell setNeedsLayout];
//                //                NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
//                //                NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
//                //                [self.tbv_List reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
//
//
//            }];

            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(nX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (nX + 8), 0)];
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
            
//            NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:str_ImageUrl]];
//            UIImage *image = [UIImage imageWithData:imageData];
//            UIImage *resizeImage = [Util imageWithImage:image convertToWidth:iv.frame.size.width];
//            iv.image = resizeImage;
//            
//            CGRect frame = iv.frame;
//            frame.size.height = resizeImage.size.height;
//            iv.frame = frame;
            
            if( isAdd )
            {
                [cell.contentView addSubview:iv];
            }
            
            fSampleViewTotalHeight += iv.frame.size.height + 10;
            
        }
        else if( [str_Type isEqualToString:@"videoLink"] )
        {
            self.playerView = [[YTPlayerView alloc] initWithFrame:
                                        CGRectMake(nX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (nX + 8), (cell.contentView.frame.size.width - (nX + 8)) * 0.7f)];

            NSDictionary *playerVars = @{
                                         @"controls" : @1,
                                         @"playsinline" : @1,
                                         @"autohide" : @1,
                                         @"showinfo" : @0,
                                         @"modestbranding" : @1
                                         };
            
            [self.playerView loadWithVideoId:str_Body playerVars:playerVars];

            if( isAdd )
            {
                [cell.contentView addSubview:self.playerView];
            }

            fSampleViewTotalHeight += self.playerView.frame.size.height + 10;
 
            
        }
        else if( [str_Type isEqualToString:@"audio"] )
        {
            //음성
//            self.btn_QuestionPlay = [YmExtendButton buttonWithType:UIButtonTypeCustom];
//            self.btn_QuestionPlay.dic_Info = dic;
//            self.btn_QuestionPlay.frame = CGRectMake(nX, fSampleViewTotalHeight, 50, 50);
//            [self.btn_QuestionPlay setImage:BundleImage(@"play_big.png") forState:UIControlStateNormal];
//            [self.btn_QuestionPlay setImage:BundleImage(@"pause_big.png") forState:UIControlStateSelected];
//            [self.btn_QuestionPlay addTarget:self action:@selector(onQuestionPlay:) forControlEvents:UIControlEventTouchUpInside];
//            [cell.contentView addSubview:self.btn_QuestionPlay];
//            
//            fSampleViewTotalHeight += self.btn_QuestionPlay.frame.size.height + 10;
            
            if( self.v_Audio == nil )
            {
                NSString *str_Body = [dic objectForKey:@"questionBody"];
                NSString *str_Url = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, str_Body];
                
                NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"AudioView" owner:self options:nil];
                self.v_Audio = [topLevelObjects objectAtIndex:0];
                [self.v_Audio initPlayer:str_Url];
            }
            
            CGRect frame = self.v_Audio.frame;
            frame.origin.y = fSampleViewTotalHeight;
            frame.size.width = self.view.bounds.size.width;
            frame.size.height = 48;
            self.v_Audio.frame = frame;
            
            if( isAdd )
            {
                [cell.contentView addSubview:self.v_Audio];
            }
            
            fSampleViewTotalHeight += self.v_Audio.frame.size.height + 10;
        }
        else if( [str_Type isEqualToString:@"video"] )
        {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(nX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (nX + 8), (cell.contentView.frame.size.width - (nX + 8)) * 0.7f)];
            view.backgroundColor = [UIColor blackColor];
            view.tag = indexPath.section;
            
            NSString *str_Url = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, str_Body];
            NSURL *URL = [NSURL URLWithString:str_Url];
            
            
            
            
            
            
            
            
            
//            AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
//            playerViewController.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
//            /*NSURL *url = [NSURL URLWithString:@"https://www.youtube.com/watch?v=qcI2_v7Vj2U"];
//             playerViewController.player = [AVPlayer playerWithURL:url];*/
//            //        playerViewController.player = [AVPlayer playerWithURL: [ [filePath]URLForResource:@"Besan"
//            //                                                                withExtension:@"mp4"]];
//            AVPlayerItem* item=[[AVPlayerItem alloc]initWithURL:URL];
//            NSLog(@"\n\nAVPlayerItem\n%@",item);
//            playerViewController.player=[AVPlayer playerWithPlayerItem:item];
////            [playerViewController.player play];
//            [view addSubview:playerViewController.view];


            
            
            
            
//            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:str_Url]];
//            AVPlayer *player = [AVPlayer playerWithPlayerItem:self.playerItem];
////            AVPlayer *player = [AVPlayer playerWithURL:[NSURL URLWithString:str_Url]];
//            [player play];
//            [view addSubview:playerItem];
            
            
            
            
            
            
            
            
            
            
            
            
            
            
//            VideoPlayerViewController *player = [[VideoPlayerViewController alloc] init];
//            player.URL = [NSURL URLWithString:str_Url];
//            player.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
//            [view addSubview:player.view];
            
            
            
            
//            [self.dicM_Video removeObjectForKey:[NSString stringWithFormat:@"%ld", indexPath.section]];
            
//            MPMoviePlayerViewController *vc_Movie = [[MPMoviePlayerViewController alloc]initWithContentURL:URL];
//            vc_Movie.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
//            vc_Movie.moviePlayer.repeatMode = MPMovieRepeatModeOne;
//            //            vc.moviePlayer.fullscreen = NO;
//            //            vc.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
//            vc_Movie.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
//            vc_Movie.moviePlayer.controlStyle = MPMovieControlStyleNone;
//            vc_Movie.moviePlayer.shouldAutoplay = NO;
//            vc_Movie.moviePlayer.repeatMode = NO;
//            //                [self.vc_Movie.moviePlayer setFullscreen:NO animated:NO];
//            [vc_Movie.moviePlayer prepareToPlay];
//            
//            [view addSubview:vc_Movie.moviePlayer.view];

            
            
            
            
//            AVPlayerViewController *playerViewController = [[AVPlayerViewController alloc] init];
//            playerViewController.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
//            AVPlayerItem* item = [[AVPlayerItem alloc]initWithURL:URL];
//            playerViewController.player = [AVPlayer playerWithPlayerItem:item];
//            [view addSubview:playerViewController.view];
//
//
//            YmExtendButton *btn_Play = [YmExtendButton buttonWithType:UIButtonTypeCustom];
//            btn_Play.obj = playerViewController.player;
//            btn_Play.tag = indexPath.section;
//            [btn_Play setImage:BundleImage(@"play_white.png") forState:UIControlStateNormal];
//            [btn_Play setFrame:CGRectMake(0, 0, 48, 48)];
//            btn_Play.backgroundColor = [UIColor blackColor];
//            btn_Play.layer.cornerRadius = 8.f;
//            btn_Play.center = view.center;
//            [btn_Play addTarget:self action:@selector(onPlayMove:) forControlEvents:UIControlEventTouchUpInside];
//            [view addSubview:btn_Play];
//            
//            if( isAdd )
//            {
//                [cell.contentView addSubview:view];
//            }
            
            
            
//            AVAsset *asset = [AVAsset assetWithURL:URL];
//            AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
//            CMTime time = CMTimeMake(1, 1);
//            CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
//            UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
//            CGImageRelease(imageRef);

            
            
//            AVURLAsset* asset = [AVURLAsset URLAssetWithURL:URL options:nil];
//            AVAssetImageGenerator* imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
//            imageGenerator.appliesPreferredTrackTransform = YES;
//            CGImageRef cgImage = [imageGenerator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:nil error:nil];
//            UIImage* thumbnail = [UIImage imageWithCGImage:cgImage];
//            
//            CGImageRelease(cgImage);

            
//            MPMoviePlayerController *player = [[MPMoviePlayerController alloc] initWithContentURL:URL];
//            UIImage *thumbnail = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];

            
            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(nX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (nX + 8), 0)];
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
            
            if( isAdd )
            {
                [cell.contentView addSubview:iv];
            }
            
            fSampleViewTotalHeight += iv.frame.size.height + 10;

            
            
            YmExtendButton *btn_Play = [YmExtendButton buttonWithType:UIButtonTypeCustom];
            btn_Play.obj = URL;
            btn_Play.tag = indexPath.section;
            [btn_Play setImage:BundleImage(@"play_white.png") forState:UIControlStateNormal];
            [btn_Play setFrame:CGRectMake(0, 0, 88, 88)];
//            btn_Play.backgroundColor = [UIColor blackColor];
            btn_Play.layer.cornerRadius = 8.f;
            btn_Play.center = iv.center;
            [btn_Play addTarget:self action:@selector(onPlayMove:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:btn_Play];

            
            
            
//            AVAsset *asset = [AVAsset assetWithURL:URL];
//            AVPlayerItem *playerItem = [AVPlayerItem playerItemWithAsset:asset];
//            AVPlayer *player = [[AVPlayer alloc] initWithPlayerItem:playerItem];
//            AVPlayerLayer *playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
//            [playerLayer setFrame:CGRectMake(0, 0, view.frame.size.width, view.frame.size.height)];
//            [view.layer addSublayer:playerLayer];
//            
//            [self.dicM_Video setObject:player forKey:[NSString stringWithFormat:@"%ld", indexPath.section]];
//
//            UITapGestureRecognizer *videoTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(videoTap:)];
//            [videoTap setNumberOfTapsRequired:1];
//            [view addGestureRecognizer:videoTap];
//            
//            YmExtendButton *btn_Play = [YmExtendButton buttonWithType:UIButtonTypeCustom];
//            btn_Play.obj = player;
//            btn_Play.tag = indexPath.section;
//            [btn_Play setImage:BundleImage(@"play_white.png") forState:UIControlStateNormal];
//            [btn_Play setFrame:CGRectMake(0, 0, 48, 48)];
//            btn_Play.backgroundColor = [UIColor blackColor];
//            btn_Play.layer.cornerRadius = 8.f;
//            btn_Play.center = view.center;
//            [btn_Play addTarget:self action:@selector(onPlayMove:) forControlEvents:UIControlEventTouchUpInside];
//            [view addSubview:btn_Play];
//
//
//            if( isAdd )
//            {
//                [cell.contentView addSubview:view];
//            }
//
//            
//            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:NO];
//            
//            
//            
//            fSampleViewTotalHeight += view.frame.size.height + 10;
        }
    }
    
    
    
    
    
    NSDictionary *dic = self.ar_DList[indexPath.section];
    
    UIButton *btn_ThumUp = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *btn_ThumDown = [UIButton buttonWithType:UIButtonTypeCustom];

    btn_ThumUp.frame = CGRectMake(self.view.bounds.size.width - ((45*2)+10+15), fSampleViewTotalHeight, 44, 28);
    btn_ThumDown.frame = CGRectMake(self.view.bounds.size.width - (45+15), fSampleViewTotalHeight, 44, 28);
    
    btn_ThumUp.tag = btn_ThumDown.tag = indexPath.section;
    
    [btn_ThumUp setImage:BundleImage(@"thumb_up.png") forState:UIControlStateNormal];
    [btn_ThumUp setBackgroundImage:BundleImage(@"lightGrayRect.png") forState:UIControlStateNormal];
    [btn_ThumUp setBackgroundImage:BundleImage(@"redRect.png") forState:UIControlStateSelected];
    [btn_ThumUp setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn_ThumUp setTitleColor:kMainRedColor forState:UIControlStateSelected];
    [btn_ThumUp.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    
    [btn_ThumDown setImage:BundleImage(@"thumbs_down.png") forState:UIControlStateNormal];
    [btn_ThumDown setBackgroundImage:BundleImage(@"lightGrayRect.png") forState:UIControlStateNormal];
    [btn_ThumDown setBackgroundImage:BundleImage(@"redRect.png") forState:UIControlStateSelected];
    [btn_ThumDown setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn_ThumDown setTitleColor:kMainRedColor forState:UIControlStateSelected];
    [btn_ThumDown.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];

    
    [btn_ThumUp setTitle:[NSString stringWithFormat:@"%@", [dic objectForKey:@"thumbUp"]] forState:UIControlStateNormal];
    [btn_ThumUp addTarget:self action:@selector(onThumbUp:) forControlEvents:UIControlEventTouchUpInside];
    
    [btn_ThumDown setTitle:[NSString stringWithFormat:@"%@", [dic objectForKey:@"thumbDown"]] forState:UIControlStateNormal];
    [btn_ThumDown addTarget:self action:@selector(onThumbDown:) forControlEvents:UIControlEventTouchUpInside];
    
    btn_ThumUp.selected = btn_ThumDown.selected = NO;
    
    NSString *str_Liek = [dic objectForKey:@"isLike"];
    if( [str_Liek isEqualToString:@"U"] )
    {
        btn_ThumUp.selected = YES;
        btn_ThumDown.selected = NO;
    }
    else if( [str_Liek isEqualToString:@"D"] )
    {
        btn_ThumUp.selected = NO;
        btn_ThumDown.selected = YES;
    }

    [cell.contentView addSubview:btn_ThumUp];
    [cell.contentView addSubview:btn_ThumDown];
    
    if( isDiscrip )
    {
        UIButton *btn_Reply = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btn_Reply.frame = CGRectMake(15, fSampleViewTotalHeight, 44, 28);
        
        btn_Reply.tag = indexPath.section;
        
        [btn_Reply setBackgroundImage:BundleImage(@"lightGrayRect.png") forState:UIControlStateNormal];
        [btn_Reply setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [btn_Reply.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
        [btn_Reply setTitle:@"답글" forState:UIControlStateNormal];
        [btn_Reply addTarget:self action:@selector(onAddReply:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn_Reply];
    }

    fSampleViewTotalHeight += btn_ThumUp.frame.size.height + 10;
    
    UIImageView *iv_UnderLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, fSampleViewTotalHeight - 1, self.tbv_List.frame.size.width, 1)];
    iv_UnderLine.backgroundColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1];
    [cell.contentView addSubview:iv_UnderLine];

    CGRect frame = cell.frame;
    frame.size.height = fSampleViewTotalHeight;
    cell.frame = frame;
}


- (void)configureQCell:(QuestionListCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withAddMode:(BOOL)isAdd
{
    for( UIView *subView in cell.contentView.subviews )
    {
        [subView removeFromSuperview];
    }
    
    __block CGFloat fSampleViewTotalHeight = 20;
    
    NSDictionary *dic_Info = self.ar_QList[indexPath.section];
    NSString *str_ItemType = [dic_Info objectForKey:@"itemType"];
    NSArray *ar = nil;
    BOOL isQna = [str_ItemType isEqualToString:@"qna"];
    NSInteger nX = 8;
    if( isQna )
    {
        ar = [dic_Info objectForKey:@"qnaBody"];
        cell.contentView.backgroundColor = [UIColor whiteColor];
    }
    else
    {
        ar = [dic_Info objectForKey:@"replyBody"];
        cell.contentView.backgroundColor = [UIColor colorWithHexString:@"F3F3F3"];
        nX = 45.f;
    }
    
    
    for( NSInteger i = 0; i < ar.count; i++ )
    {
        NSDictionary *dic = ar[i];
        NSString *str_Type = isQna ? [dic objectForKey:@"qnaType"] : [dic objectForKey:@"replyType"];
        NSString *str_Body = isQna ? [dic objectForKey:@"qnaBody"] : [dic objectForKey:@"replyBody"];
        
        if( [str_Type isEqualToString:@"text"] )
        {
            UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(nX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (nX + 8), 0)];
            lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(lb_Contents.frame);
            lb_Contents.font = [UIFont fontWithName:@"Helvetica" size:14.f];
            lb_Contents.text = str_Body;
            lb_Contents.numberOfLines = 0;
            
            lb_Contents.text = [lb_Contents.text stringByReplacingOccurrencesOfString:@"<br>" withString:@"\n"];

            CGRect frame = lb_Contents.frame;
            frame.size.height = [Util getTextSize:lb_Contents].height;
            lb_Contents.frame = frame;
            
            
            if( isAdd )
            {
                [cell.contentView addSubview:lb_Contents];
            }
            
            
            fSampleViewTotalHeight += lb_Contents.frame.size.height + 10;
        }
        else if( [str_Type isEqualToString:@"html"] )
        {
            NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[str_Body dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(cell.contentView.frame.size.width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
            
            UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(nX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (nX + 8), rect.size.height)];
            lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(lb_Contents.frame);
            lb_Contents.numberOfLines = 0;
            lb_Contents.attributedText = attrStr;
            
            if( isAdd )
            {
                [cell.contentView addSubview:lb_Contents];
            }
            
            fSampleViewTotalHeight += rect.size.height + 10;
        }
        else if( [str_Type isEqualToString:@"image"] )
        {
            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(nX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (nX + 8), 0)];
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

            if( isAdd )
            {
                [cell.contentView addSubview:iv];
            }
            
            fSampleViewTotalHeight += iv.frame.size.height + 10;
            
        }
        else if( [str_Type isEqualToString:@"videoLink"] )
        {
            self.playerView = [[YTPlayerView alloc] initWithFrame:
                               CGRectMake(nX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (nX + 8), (cell.contentView.frame.size.width - (nX + 8)) * 0.7f)];
            
            NSDictionary *playerVars = @{
                                         @"controls" : @1,
                                         @"playsinline" : @1,
                                         @"autohide" : @1,
                                         @"showinfo" : @0,
                                         @"modestbranding" : @1
                                         };
            
            [self.playerView loadWithVideoId:str_Body playerVars:playerVars];
            
            if( isAdd )
            {
                [cell.contentView addSubview:self.playerView];
            }
            
            fSampleViewTotalHeight += self.playerView.frame.size.height + 10;
            
            
        }
        else if( [str_Type isEqualToString:@"audio"] )
        {
            if( self.v_Audio == nil )
            {
                NSString *str_Body = [dic objectForKey:@"questionBody"];
                NSString *str_Url = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, str_Body];
                
                NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"AudioView" owner:self options:nil];
                self.v_Audio = [topLevelObjects objectAtIndex:0];
                [self.v_Audio initPlayer:str_Url];
            }
            
            CGRect frame = self.v_Audio.frame;
            frame.origin.y = fSampleViewTotalHeight;
            frame.size.width = self.view.bounds.size.width;
            frame.size.height = 48;
            self.v_Audio.frame = frame;
            
            if( isAdd )
            {
                [cell.contentView addSubview:self.v_Audio];
            }
            
            fSampleViewTotalHeight += self.v_Audio.frame.size.height + 10;
        }
        else if( [str_Type isEqualToString:@"video"] )
        {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(nX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (nX + 8), (cell.contentView.frame.size.width - (nX + 8)) * 0.7f)];
            view.backgroundColor = [UIColor blackColor];
            view.tag = indexPath.section;
            
            NSString *str_Url = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, str_Body];
            NSURL *URL = [NSURL URLWithString:str_Url];

//            AVURLAsset* asset = [AVURLAsset URLAssetWithURL:URL options:nil];
//            AVAssetImageGenerator* imageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:asset];
//            imageGenerator.appliesPreferredTrackTransform = YES;
//            CGImageRef cgImage = [imageGenerator copyCGImageAtTime:CMTimeMake(0, 1) actualTime:nil error:nil];
//            UIImage* thumbnail = [UIImage imageWithCGImage:cgImage];
//            
//            CGImageRelease(cgImage);

            
            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(nX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (nX + 8), 0)];
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
            
            if( isAdd )
            {
                [cell.contentView addSubview:iv];
            }
            
            fSampleViewTotalHeight += iv.frame.size.height + 10;
            
            
            YmExtendButton *btn_Play = [YmExtendButton buttonWithType:UIButtonTypeCustom];
            btn_Play.obj = URL;
            btn_Play.tag = indexPath.section;
            [btn_Play setImage:BundleImage(@"play_white.png") forState:UIControlStateNormal];
            [btn_Play setFrame:CGRectMake(0, 0, 88, 88)];
            btn_Play.layer.cornerRadius = 8.f;
            btn_Play.center = iv.center;
            [btn_Play addTarget:self action:@selector(onPlayMove:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:btn_Play];
        }
    }

    
    NSDictionary *dic = self.ar_QList[indexPath.section];
    
    UIButton *btn_ThumUp = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *btn_ThumDown = [UIButton buttonWithType:UIButtonTypeCustom];
    
    btn_ThumUp.backgroundColor = btn_ThumDown.backgroundColor = [UIColor whiteColor];
    
    btn_ThumUp.frame = CGRectMake(self.view.bounds.size.width - ((45*2)+10+15), fSampleViewTotalHeight, 44, 28);
    btn_ThumDown.frame = CGRectMake(self.view.bounds.size.width - (45+15), fSampleViewTotalHeight, 44, 28);
    
    btn_ThumUp.tag = btn_ThumDown.tag = indexPath.section;
    
    [btn_ThumUp setImage:BundleImage(@"thumb_up.png") forState:UIControlStateNormal];
    [btn_ThumUp setBackgroundImage:BundleImage(@"lightGrayRect.png") forState:UIControlStateNormal];
    [btn_ThumUp setBackgroundImage:BundleImage(@"redRect.png") forState:UIControlStateSelected];
    [btn_ThumUp setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn_ThumUp setTitleColor:kMainRedColor forState:UIControlStateSelected];
    [btn_ThumUp.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    
    [btn_ThumDown setImage:BundleImage(@"thumbs_down.png") forState:UIControlStateNormal];
    [btn_ThumDown setBackgroundImage:BundleImage(@"lightGrayRect.png") forState:UIControlStateNormal];
    [btn_ThumDown setBackgroundImage:BundleImage(@"redRect.png") forState:UIControlStateSelected];
    [btn_ThumDown setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    [btn_ThumDown setTitleColor:kMainRedColor forState:UIControlStateSelected];
    [btn_ThumDown.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
    
    
    [btn_ThumUp setTitle:[NSString stringWithFormat:@"%@", [dic objectForKey:@"thumbUp"]] forState:UIControlStateNormal];
    [btn_ThumUp addTarget:self action:@selector(onThumbUp:) forControlEvents:UIControlEventTouchUpInside];
    
    [btn_ThumDown setTitle:[NSString stringWithFormat:@"%@", [dic objectForKey:@"thumbDown"]] forState:UIControlStateNormal];
    [btn_ThumDown addTarget:self action:@selector(onThumbDown:) forControlEvents:UIControlEventTouchUpInside];
    
    btn_ThumUp.selected = btn_ThumDown.selected = NO;
    
    NSString *str_Liek = [dic objectForKey:@"isLike"];
    if( [str_Liek isEqualToString:@"U"] )
    {
        btn_ThumUp.selected = YES;
        btn_ThumDown.selected = NO;
    }
    else if( [str_Liek isEqualToString:@"D"] )
    {
        btn_ThumUp.selected = NO;
        btn_ThumDown.selected = YES;
    }
    
    [cell.contentView addSubview:btn_ThumUp];
    [cell.contentView addSubview:btn_ThumDown];
    
    if( [str_ItemType isEqualToString:@"qna"] )
    {
        UIButton *btn_Reply = [UIButton buttonWithType:UIButtonTypeCustom];
        
        btn_Reply.frame = CGRectMake(15, fSampleViewTotalHeight, 44, 28);
        
        btn_Reply.tag = indexPath.section;
        
        [btn_Reply setBackgroundImage:BundleImage(@"lightGrayRect.png") forState:UIControlStateNormal];
        [btn_Reply setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [btn_Reply.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
        [btn_Reply setTitle:@"답글" forState:UIControlStateNormal];
        [btn_Reply addTarget:self action:@selector(onAddQReply:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn_Reply];
    }

    fSampleViewTotalHeight += btn_ThumUp.frame.size.height + 10;

    
    UIImageView *iv_UnderLine = [[UIImageView alloc] initWithFrame:CGRectMake(0, fSampleViewTotalHeight - 1, self.tbv_List.frame.size.width, 1)];
    iv_UnderLine.backgroundColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1];
    [cell.contentView addSubview:iv_UnderLine];

    
    CGRect frame = cell.frame;
    frame.size.height = fSampleViewTotalHeight;
    cell.frame = frame;
}

- (void)onAddReply:(UIButton *)btn
{
    NSDictionary *dic = self.ar_DList[btn.tag];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    AddDiscripViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"AddDiscripViewController"];
    vc.isQuestionMode = YES;
    vc.str_QnAId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"eId"]];
    vc.str_Idx = self.str_QuestionId;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)onAddQReply:(UIButton *)btn
{
    NSDictionary *dic = self.ar_QList[btn.tag];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    AddDiscripViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"AddDiscripViewController"];
    vc.isQuestionMode = YES;
    vc.str_QnAId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"eId"]];
    vc.str_Idx = self.str_QuestionId;
    [self presentViewController:vc animated:YES completion:nil];
}

- (void)videoTap:(UIGestureRecognizer *)gestureRecognizer
{
//    UIView *view = gestureRecognizer.view;
//    AVPlayer *player = (AVPlayer *)[self.dicM_Video objectForKey:[NSString stringWithFormat:@"%ld", view.tag]];
//    [player pause];
    
    if ((self.currentPlayer.rate != 0) && (self.currentPlayer.error == nil))
    {
        // player is playing
        [self.currentPlayer pause];
        self.btn_CurrentPlay.hidden = NO;
    }
    else
    {
        [self.currentPlayer play];
        self.btn_CurrentPlay.hidden = YES;
    }
}

- (void)onPlayMove:(YmExtendButton *)btn
{
    NSURL *URL = btn.obj;
    
    
    MPMoviePlayerViewController *vc_Movie = [[MPMoviePlayerViewController alloc]initWithContentURL:URL];
//    vc_Movie.view.frame = CGRectMake(0, 0, view.frame.size.width, view.frame.size.height);
    vc_Movie.moviePlayer.repeatMode = MPMovieRepeatModeOne;
//    vc.moviePlayer.fullscreen = YES;
    //            vc.moviePlayer.scalingMode = MPMovieScalingModeAspectFit;
    vc_Movie.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    vc_Movie.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    vc_Movie.moviePlayer.shouldAutoplay = NO;
    vc_Movie.moviePlayer.repeatMode = NO;
    [vc_Movie.moviePlayer setFullscreen:NO animated:NO];
    [vc_Movie.moviePlayer prepareToPlay];
    [vc_Movie.moviePlayer play];
    
    [self presentViewController:vc_Movie animated:YES completion:^{
        
    }];
    
//    if( self.currentPlayer )
//    {
//        [self.currentPlayer pause];
//        self.currentPlayer = nil;
//    }
//
//    AVPlayer *player = (AVPlayer *)btn.obj;
//    //    AVPlayer *player = (AVPlayer *)[self.dicM_Video objectForKey:[NSString stringWithFormat:@"%ld", btn.tag]];
//    self.currentPlayer = player;
//    self.btn_CurrentPlay = btn;
//    
//    if ((self.currentPlayer.rate != 0) && (self.currentPlayer.error == nil))
//    {
//        [self.currentPlayer pause];
//        self.btn_CurrentPlay.hidden = NO;
//    }
//    else
//    {
//        [self.currentPlayer play];
//        self.btn_CurrentPlay.hidden = YES;
//    }
    
    
}

//- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
//                        change:(NSDictionary *)change context:(void *)context
//{
//    AVPlayer *player = (AVPlayer *)object;
//    if (object == player && [keyPath isEqualToString:@"status"])
//    {
//        if (player.status == AVPlayerStatusReadyToPlay)
//        {
////            playButton.enabled = YES;
//        }
//        else if (player.status == AVPlayerStatusFailed)
//        {
//            // something went wrong. player.error should contain some information
//        }
//    }
//}




#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if( tableView == self.tbv_QList )
    {
        return self.ar_QList.count;
    }
    
    return self.ar_DList.count;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    QuestionListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuestionListCell" forIndexPath:indexPath];

    if( tableView == self.tbv_QList )
    {
        [self configureQCell:cell forRowAtIndexPath:indexPath withAddMode:YES];
    }
    else
    {
        [self configureCell:cell forRowAtIndexPath:indexPath withAddMode:YES];
    }
    
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( tableView == self.tbv_QList )
    {
        [self configureQCell:self.questionListCell forRowAtIndexPath:indexPath withAddMode:YES];
    }
    else
    {
        [self configureCell:self.questionListCell forRowAtIndexPath:indexPath withAddMode:YES];
    }
    
    [self.questionListCell updateConstraintsIfNeeded];
    [self.questionListCell layoutIfNeeded];
    
    self.questionListCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.questionListCell.bounds));
    
//    fContentsHeight = [self.questionListCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return [self.questionListCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 56.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *CellIdentifier = @"DiscripHeaderCell";
    DiscripHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    cell.separatorInset = UIEdgeInsetsMake(0, 10000, 0, 0);

//    self.tbv_QList.separatorStyle = UITableViewCellSeparatorStyleNone;
//    self.tbv_QList.separatorColor = [UIColor clearColor];
    
//    for( id subview in cell.subviews )
//    {
//        if( subview != cell.contentView )
//        {
//            UIView *v_Seper = (UIView *)subview;
//            v_Seper.backgroundColor = [UIColor colorWithHexString:@"F3F3F3"];
//            
////            [subview removeFromSuperview];
//        }
//    }


    NSDictionary *dic = nil;
    if( tableView == self.tbv_QList )
    {
        dic = self.ar_QList[section];
        NSString *str_ItemType = [dic objectForKey:@"itemType"];
        if( [str_ItemType isEqualToString:@"qna"] )
        {
            cell.lc_ImageX.constant = 15.f;
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
        else
        {
            cell.lc_ImageX.constant = 35.f;
            cell.contentView.backgroundColor = [UIColor colorWithHexString:@"F3F3F3"];
        }
    }
    else
    {
        dic = self.ar_DList[section];
        NSString *str_ItemType = [dic objectForKey:@"itemType"];
        if( [str_ItemType isEqualToString:@"explain"] )
        {
            cell.lc_ImageX.constant = 15.f;
            cell.contentView.backgroundColor = [UIColor whiteColor];
        }
        else
        {
            cell.lc_ImageX.constant = 35.f;
            cell.contentView.backgroundColor = [UIColor colorWithHexString:@"F3F3F3"];
        }
    }
    
    [cell.iv_User sd_setImageWithURL:[Util createImageUrl:str_UserImagePrefix withFooter:[dic objectForKey:@"userThumbnail"]]];

    cell.lb_Name.text = [dic objectForKey:@"name"];
    
    cell.lb_Tag.text = [NSString  stringWithFormat:@"#%@", [dic objectForKey:@"useraffiliation"]];
    
    NSString *str_Date = [NSString stringWithFormat:@"%@", [dic objectForKey:@"createDate"]];
    
    if( str_Date.length >= 14 )
    {
        NSString *str_Year = [str_Date substringWithRange:NSMakeRange(0, 4)];
        NSString *str_Month = [str_Date substringWithRange:NSMakeRange(4, 2)];
        NSString *str_Day = [str_Date substringWithRange:NSMakeRange(6, 2)];
        NSString *str_Hour = [str_Date substringWithRange:NSMakeRange(8, 2)];
        NSString *str_Minute = [str_Date substringWithRange:NSMakeRange(10, 2)];
        
        cell.lb_Date.text = [NSString stringWithFormat:@"%04ld-%02ld-%02ld", [str_Year integerValue], [str_Month integerValue], [str_Day integerValue]];
        
        cell.lb_Time.text = [NSString stringWithFormat:@"%02ld:%02ld", [str_Hour integerValue], [str_Minute integerValue]];
    }
    
    cell.btn_Report.tag = section;
    
    NSInteger nCreateUserId = [[dic objectForKey:@"userId"] integerValue];
    NSInteger nMyId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue];
    if( nCreateUserId == nMyId )
    {
        //내 글이면 삭제버튼 노출
        [cell.btn_Report setTitle:@"삭제" forState:UIControlStateNormal];
        [cell.btn_Report addTarget:self action:@selector(onDelete:) forControlEvents:UIControlEventTouchUpInside];
    }
    else
    {
        //남의 글이면 신고버튼 노출
        [cell.btn_Report setTitle:@"신고" forState:UIControlStateNormal];
        [cell.btn_Report addTarget:self action:@selector(onReport:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    return cell;
}

- (void)onThumbUp:(UIButton *)btn
{
    NSDictionary *dic = nil;
    if( self.sg.selectedSegmentIndex == 1 )
    {
        dic = self.ar_QList[btn.tag];
    }
    else
    {
        dic = self.ar_DList[btn.tag];
    }

    [self sendLike:[NSString stringWithFormat:@"%@", [dic objectForKey:@"eId"]] withStatus:@"up" withObj:btn withDic:dic];
}

- (void)onThumbDown:(UIButton *)btn
{
    NSDictionary *dic = nil;
    if( self.sg.selectedSegmentIndex == 1 )
    {
        dic = self.ar_QList[btn.tag];
    }
    else
    {
        dic = self.ar_DList[btn.tag];
    }

    [self sendLike:[NSString stringWithFormat:@"%@", [dic objectForKey:@"eId"]] withStatus:@"down" withObj:btn withDic:dic];
}

- (void)onReport:(UIButton *)btn
{
    //신고하기
    UIAlertView *alert = CREATE_ALERT(nil, @"해당 게시글을 신고하시겠습니까?", @"확인", @"취소");
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        if( buttonIndex == 0 )
        {
            NSDictionary *dic = nil;
            if( self.sg.selectedSegmentIndex == 1 )
            {
                dic = self.ar_QList[btn.tag];
            }
            else
            {
                dic = self.ar_DList[btn.tag];
            }
            
            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                [Util getUUID], @"uuid",
                                                //                                        self.str_QuestionId, @"questionId",
                                                [NSString stringWithFormat:@"%@", [dic objectForKey:@"eId"]], @"eId",
                                                nil];
            
            __weak __typeof(&*self)weakSelf = self;
            
            [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/question/explain/report"
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
                                                        [weakSelf.navigationController.view makeToast:@"신고 되었습니다." withPosition:kPositionCenter];
//                                                        [weakSelf updateDList];
                                                    }
                                                    else
                                                    {
                                                        [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                    }
                                                }
                                            }];
        }
    }];

}

- (void)onDelete:(UIButton *)btn
{
    //삭제하기
    UIAlertView *alert = CREATE_ALERT(nil, @"해당 게시글을 삭제하시겠습니까?", @"확인", @"취소");
    [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
        
        if( buttonIndex == 0 )
        {
            NSDictionary *dic = nil;
            if( self.sg.selectedSegmentIndex == 1 )
            {
                dic = self.ar_QList[btn.tag];
            }
            else
            {
                dic = self.ar_DList[btn.tag];
            }
            
            
            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                [Util getUUID], @"uuid",
                                                self.str_QuestionId, @"questionId",
                                                [NSString stringWithFormat:@"%@", [dic objectForKey:@"eId"]], @"eId",
                                                nil];
            
            __weak __typeof(&*self)weakSelf = self;
            
            [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/question/explain/delete"
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
                                                        if( self.sg.selectedSegmentIndex == 1 )
                                                        {
                                                            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"data":@{@"eId":self.str_ExamId,@"tag":[NSString stringWithFormat:@"%ld", btn.tag]}}
                                                                                                               options:NSJSONWritingPrettyPrinted
                                                                                                                 error:&error];
                                                            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                            
//                                                            [SendBird sendMessage:@"delete-qna" withData:jsonString];
                                                        }
                                                        else
                                                        {
                                                            NSMutableArray *arM = [NSMutableArray arrayWithArray:weakSelf.ar_DList];
                                                            [arM removeObjectAtIndex:btn.tag];
                                                            weakSelf.ar_DList = [NSArray arrayWithArray:arM];
                                                            [weakSelf.tbv_List reloadData];
                                                            
                                                            NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"data":@{@"eId":self.str_ExamId}}
                                                                                                               options:NSJSONWritingPrettyPrinted
                                                                                                                 error:&error];
                                                            NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                            
//                                                            [SendBird sendMessage:@"delete-explain" withData:jsonString];
                                                        }
                                                    }
                                                    else
                                                    {
                                                        [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                    }
                                                }
                                            }];
        }
    }];
}

- (void)sendLike:(NSString *)aId withStatus:(NSString *)aStatus withObj:(UIButton *)btn withDic:(NSDictionary *)dic
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_QuestionId, @"questionId",
                                        aId, @"eId",
                                        aStatus, @"setMode",
                                        nil];
    
    __weak __typeof(&*self)weakSelf = self;
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/question/explain/like"
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
                                                btn.selected = !btn.selected;
                                                
                                                NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
                                                if( [aStatus isEqualToString:@"up"] )
                                                {
                                                    if( btn.selected )
                                                    {
                                                        [dicM setObject:@"U" forKey:@"isLike"];
                                                    }
                                                    else
                                                    {
                                                        [dicM setObject:@"" forKey:@"isLike"];
                                                    }
                                                    
                                                    NSInteger nCnt = [[resulte objectForKey:@"thumbUp"] integerValue];
                                                    [dicM setObject:[NSString stringWithFormat:@"%ld", nCnt] forKey:@"thumbUp"];
                                                }
                                                else
                                                {
                                                    if( btn.selected )
                                                    {
                                                        [dicM setObject:@"D" forKey:@"isLike"];
                                                    }
                                                    else
                                                    {
                                                        [dicM setObject:@"" forKey:@"isLike"];
                                                    }
                                                    
                                                    NSInteger nCnt = [[resulte objectForKey:@"thumbDown"] integerValue];
                                                    [dicM setObject:[NSString stringWithFormat:@"%ld", nCnt] forKey:@"thumbDown"];
                                                }
                                                
                                                if( self.sg.selectedSegmentIndex == 0 )
                                                {
                                                    NSMutableArray *arM = [NSMutableArray arrayWithArray:weakSelf.ar_DList];
                                                    [arM replaceObjectAtIndex:btn.tag withObject:dicM];
                                                    weakSelf.ar_DList = [NSArray arrayWithArray:arM];
                                                    
                                                    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:btn.tag];
                                                    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
                                                    [weakSelf.tbv_List reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
                                                }
                                                else
                                                {
                                                    NSMutableArray *arM = [NSMutableArray arrayWithArray:weakSelf.ar_QList];
                                                    [arM replaceObjectAtIndex:btn.tag withObject:dicM];
                                                    weakSelf.ar_QList = [NSArray arrayWithArray:arM];
                                                    
                                                    NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:btn.tag];
                                                    NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
                                                    [weakSelf.tbv_QList reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
                                                }
                                            }
                                            else
                                            {
                                                [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //푸터 고정
//    CGFloat sectionFooterHeight = 36.f;
//    CGFloat tableViewHeight = self.tbv_List.frame.size.height;
//    
//    if( scrollView.contentOffset.y == tableViewHeight )
//    {
//        scrollView.contentInset = UIEdgeInsetsMake(0, 0,-scrollView.contentOffset.y, 0);
//    }
//    else if ( scrollView.contentOffset.y >= sectionFooterHeight + self.tbv_List.frame.size.height )
//    {
//        scrollView.contentInset = UIEdgeInsetsMake(0, 0,-sectionFooterHeight, 0);
//    }
    

//    헤더고정
    CGFloat sectionHeaderHeight = 80.f;
    if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0)
    {
        scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
    }
    else if (scrollView.contentOffset.y>=sectionHeaderHeight)
    {
        scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
    }
}



- (void)onQuestionPlay:(YmExtendButton *)btn
{
    NSString *str_Body = [btn.dic_Info objectForKey:@"explainBody"];
    NSString *str_Url = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, str_Body];
    NSURL *url = [NSURL URLWithString:str_Url];
    self.playerItem = [AVPlayerItem playerItemWithURL:url];
    self.player = [AVPlayer playerWithPlayerItem:self.playerItem];
    self.player = [AVPlayer playerWithURL:url];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(playerItemDidReachEnd:)
                                                 name:AVPlayerItemDidPlayToEndTimeNotification
                                               object:[self.player currentItem]];
    
//    [self.player addObserver:self forKeyPath:@"status" options:0 context:nil];
    
    [self.player play];
    self.btn_QuestionPlay.selected = YES;
}

- (void)playerItemDidReachEnd:(NSNotification *)notification {
    
    //  code here to play next sound file
    NSLog(@"End");
    self.btn_QuestionPlay.selected = NO;
}

- (IBAction)goBack:(id)sender
{
//    [SendBird disconnect];
    [self.navigationController popViewControllerAnimated:YES];
}





#pragma mark - SendBird
- (void)joinDRoom
{
    NSString *str_ChannelUrl = [NSString stringWithFormat:@"thotingQuestion_explain_%@", self.str_QuestionId];
    NSString *str_ChannelName = [NSString stringWithFormat:@"%@문제지 %@번 문제풀이", self.str_ExamId, self.str_QuestionId];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        kSendBirdApiToken, @"auth",
                                        str_ChannelUrl, @"channel_url",
                                        str_ChannelName, @"name",
                                        //                                        @"", @"cover_url",
                                        //                                        @"", @"data",
                                        nil];
    
    [[WebAPI sharedData] callAsyncSendBirdAPIBlock:@"channel/create"
                                             param:dicM_Params
                                        withMethod:@"POST"
                                         withBlock:^(id resulte, NSError *error) {
                                             
                                             if( resulte )
                                             {
//                                                 if( [[resulte objectForKey:@"error"] integerValue] == 1 )
//                                                 {
//                                                     //이미 방이 있으면 조인
//                                                     [SendBird joinChannel:str_ChannelUrl];
//                                                     [SendBird connect];
//                                                     //                                                     [SendBird sendMessage:@"@@hi@@"];
//                                                 }
//                                                 else
//                                                 {
//                                                     [SendBird joinChannel:[resulte objectForKey:@"channel_url"]];
//                                                     [SendBird connect];
//                                                 }
                                             }
                                         }];
}

- (void)joinQRoom
{
    NSString *str_ChannelUrl = [NSString stringWithFormat:@"thotingQuestion_qna_%@", self.str_QuestionId];
    NSString *str_ChannelName = [NSString stringWithFormat:@"%@문제지 %@번 질문과답", self.str_ExamId, self.str_QuestionId];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        kSendBirdApiToken, @"auth",
                                        str_ChannelUrl, @"channel_url",
                                        str_ChannelName, @"name",
                                        //                                        @"", @"cover_url",
                                        //                                        @"", @"data",
                                        nil];
    
    [[WebAPI sharedData] callAsyncSendBirdAPIBlock:@"channel/create"
                                             param:dicM_Params
                                        withMethod:@"POST"
                                         withBlock:^(id resulte, NSError *error) {
                                             
                                             if( resulte )
                                             {
//                                                 if( [[resulte objectForKey:@"error"] integerValue] == 1 )
//                                                 {
//                                                     //이미 방이 있으면 조인
//                                                     [SendBird joinChannel:str_ChannelUrl];
//                                                     [SendBird connect];
//                                                     //                                                     [SendBird sendMessage:@"@@hi@@"];
//                                                 }
//                                                 else
//                                                 {
//                                                     [SendBird joinChannel:[resulte objectForKey:@"channel_url"]];
//                                                     [SendBird connect];
//                                                 }
                                             }
                                         }];
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
//        NSLog(@"message.message: %@, message.data: %@", message.message, message.data);
////        ALERT(nil, message.message, nil, @"확인", nil);
//        
//        NSData* data = [message.data dataUsingEncoding:NSUTF8StringEncoding];
//
//        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
//        id dicM_Result = [jsonParser objectWithString:dataString];
//
//        if( [message.message isEqualToString:@"regist-explain"] )
//        {
//            NSLog(@"%@", message.data);
//            //새로운 문제풀이 등록
//            [self updateDList];
//            
//            [self.navigationController.view makeToast:@"새로운 문제풀이가 등록 되었습니다." withPosition:kPositionTop];
//        }
//        else if( [message.message isEqualToString:@"delete-explain"] )
//        {
//            [self updateDList];
//        }
//        else if( [message.message isEqualToString:@"regist-qna"] )
//        {
//            //새로운 질문 등록
//            [self updateQList];
//            [self.navigationController.view makeToast:@"새로운 질문이 등록 되었습니다." withPosition:kPositionTop];
//        }
//        else if( [message.message isEqualToString:@"delete-qna"] )
//        {
//            //질문삭제
//            NSString *str_Tag = [dicM_Result objectForKey:@"tag"];
//            NSMutableArray *arM = [NSMutableArray arrayWithArray:self.ar_QList];
//            [arM removeObjectAtIndex:[str_Tag integerValue]];
//            self.ar_QList = [NSArray arrayWithArray:arM];
//            [self.tbv_QList reloadData];
//
//            [self updateQList];
//        }
//        else if( [message.message isEqualToString:@"regist-reply"] )
//        {
//            //답글등록
//            [self updateDList];
//            [self updateQList];
//            [self.navigationController.view makeToast:@"새로운 답글이 등록 되었습니다." withPosition:kPositionTop];
//        }
//        
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

- (IBAction)goAddDiscription:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    AddDiscripViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"AddDiscripViewController"];
    vc.str_Idx = self.str_QuestionId;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)goLike:(id)sender
{
    if( self.btn_Like.selected ) return;
    
    self.btn_Like.selected = YES;
    self.btn_New.selected = NO;
    
    [self updateDList];
}

- (IBAction)goNew:(id)sender
{
    if( self.btn_New.selected ) return;

    self.btn_Like.selected = NO;
    self.btn_New.selected = YES;
    
    [self updateDList];
}


- (IBAction)goAddQestion:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    AddDiscripViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"AddDiscripViewController"];
    vc.isQuestionMode = YES;
    vc.str_Idx = self.str_QuestionId;
    [self presentViewController:vc animated:YES completion:nil];
}

- (IBAction)goQLike:(id)sender
{
    if( self.btn_QLike.selected ) return;
    
    self.btn_QLike.selected = YES;
    self.btn_QNew.selected = NO;
    
    [self updateQList];
}

- (IBAction)goQNew:(id)sender
{
    if( self.btn_QNew.selected ) return;
    
    self.btn_QLike.selected = NO;
    self.btn_QNew.selected = YES;
    
    [self updateQList];
}

@end
