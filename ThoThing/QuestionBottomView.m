//
//  QuestionBottomView.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 11. 10..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "QuestionBottomView.h"
#import "QuestionListCell.h"
#import "YTPlayerView.h"
#import "AudioView.h"
#import "YmExtendButton.h"
#import "CommentKeyboardAccView.h"
#import "MWPhotoBrowser.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "ChattingCell.h"
#import "MyMainViewController.h"
#import "UserPageMainViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import "SBJsonParser.h"
#import "DiscripHeaderCell.h"
#import "AddDiscripViewController.h"

@interface QuestionBottomView () <UIGestureRecognizerDelegate, UITextViewDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MWPhotoBrowserDelegate, UIScrollViewDelegate>
{
    CGFloat fOriginalBottom;
    CGFloat fOldY;
    
    CGFloat fKeyboardHeight;

    NSInteger nTotalCnt;
    NSInteger nQTotalCnt;
    
    NSString *str_ImagePreFix;
    NSString *str_ImagePreUrl;
    NSString *str_UserImagePrefix;

    //채팅관련
    NSArray *ar_ColorList;

    BOOL isReplyMode;
    NSDictionary *dic_SelectedItem;
    MWPhotoBrowser *browser;
    NSString *str_OldPosition;
}
@property (nonatomic, strong) NSMutableArray *ar_Photo;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, weak) UIViewController *vc_Parents;
//@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) NSMutableArray *arM_DList;
@property (nonatomic, strong) NSMutableArray *arM_QList;
@property (nonatomic, strong) NSMutableArray *arM_ChannelAdmin;
@property (nonatomic, strong) QuestionListCell *questionListCell;
@property (nonatomic, strong) ChattingCell *c_ChattingCell;
@property (nonatomic, strong) YTPlayerView *playerView;
@property (nonatomic, strong) AudioView *v_Audio;
@property (nonatomic, strong) YmExtendButton *btn_QuestionPlay;
//@property (nonatomic, strong) AVPlayer *currentPlayer;
@property (nonatomic, strong) YmExtendButton *btn_CurrentPlay;
@property (nonatomic, weak) IBOutlet CommentKeyboardAccView *v_CommentKeyboardAccView;
@property (nonatomic, weak) IBOutlet UIButton *btn_Comment;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Bg;
@property (nonatomic, weak) IBOutlet UISegmentedControl *seg;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Contents;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ContentsWidth;
@property (nonatomic, weak) IBOutlet UITableView *tbv_DList;
@property (nonatomic, weak) IBOutlet UITableView *tbv_QList;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Admin;
@property (nonatomic, weak) IBOutlet UIButton *btn_Like;
@property (nonatomic, weak) IBOutlet UIButton *btn_New;
@property (nonatomic, weak) IBOutlet UIButton *btn_AddD;
//금리
//육천백구십
//이천백팔십만원
//21800000 133480원
//336895
@end

@implementation QuestionBottomView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)updateAdminList
{
    //오답, 별표 리스트땐 다이렉트 질문 안되게 함 (왜냐면 채널 아이디를 알 수 없기 때문)
    NSInteger nChannelId = [self.str_ChannelId integerValue];
    if( nChannelId <= 0 )   return;
//    if( self.str_ChannelId == nil || self.str_ChannelId.length <= 0 )   return;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_ChannelId, @"channelId",
                                        @"manager", @"statusCode",
                                        nil];

    __weak __typeof(&*self)weakSelf = self;
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/user/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSString *str_ImagePrefix = [resulte objectForKey:@"userImg_prefix"];
                                            NSArray *ar = [resulte objectForKey:@"userList"];
                                            weakSelf.arM_ChannelAdmin = [NSMutableArray arrayWithArray:ar];
                                            
                                            for( id subview in weakSelf.sv_Admin.subviews )
                                            {
                                                if( [subview isKindOfClass:[UIButton class]] )
                                                {
                                                    UIButton *btn = (UIButton *)subview;
                                                    if( btn.tag > 0 )
                                                    {
                                                        [btn removeFromSuperview];
                                                    }
                                                }
                                            }
                                            
                                            CGFloat fTotalWidth = 0;
                                            for( NSInteger i = 0; i < weakSelf.arM_ChannelAdmin.count; i++ )
                                            {
                                                NSDictionary *dic = weakSelf.arM_ChannelAdmin[i];
                                                NSInteger nUserId = [[dic objectForKey:@"userId"] integerValue];
                                                NSInteger nMyId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue];
                                                if( nUserId == nMyId )
                                                {
                                                    continue;
                                                }
                                                
                                                NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_ImagePrefix, [dic objectForKey:@"imgUrl"]];
                                                UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(fTotalWidth == 0 ? 0 : fTotalWidth + 8, 0, 36, 36)];
                                                iv.tag = nUserId;
                                                iv.clipsToBounds = YES;
                                                iv.contentMode = UIViewContentModeScaleAspectFill;
                                                iv.layer.cornerRadius = iv.frame.size.width / 2;
                                                iv.alpha = 1.f;
                                                iv.userInteractionEnabled = YES;
                                                iv.layer.borderWidth = 1.f;
                                                iv.layer.borderColor = [UIColor clearColor].CGColor;
                                                
                                                [iv sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl] completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {

                                                }];

                                                UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(adminTap:)];
                                                [imageTap setNumberOfTapsRequired:1];
                                                [iv addGestureRecognizer:imageTap];

                                                [weakSelf.sv_Admin addSubview:iv];
                                                
                                                fTotalWidth = iv.frame.origin.x + iv.frame.size.width;
                                            }
                                            
                                            [weakSelf.sv_Admin setContentSize:CGSizeMake(fTotalWidth + 10, weakSelf.sv_Admin.contentSize.height)];
                                        }
                                    }];
}

- (void)adminTap:(UIGestureRecognizer *)gestureRecognizer
{
    UIImageView *iv = (UIImageView *)gestureRecognizer.view;

    BOOL isFirst = YES;
    for( id subView in self.sv_Admin.subviews )
    {
        if( [subView isKindOfClass:[UIImageView class]] )
        {
            UIImageView *iv_Sub = (UIImageView *)subView;
            if( iv_Sub.tag > 0 && iv_Sub.alpha < 1 )
            {
                isFirst = NO;
            }
        }
    }
    
    if( isFirst )
    {
        for( id subView in self.sv_Admin.subviews )
        {
            if( [subView isKindOfClass:[UIImageView class]] )
            {
                UIImageView *iv_Sub = (UIImageView *)subView;
                if( iv_Sub.tag > 0 )
                {
                    iv_Sub.alpha = 0.3f;
                    iv_Sub.layer.borderColor = [UIColor clearColor].CGColor;
                }
            }
        }

        iv.alpha = YES;
        iv.layer.borderColor = [UIColor redColor].CGColor;
        
        return;
    }
    
    
    if( iv.alpha == YES )
    {
        iv.alpha = 0.3f;
        iv.layer.borderColor = [UIColor clearColor].CGColor;
        return;
    }
    
    for( id subView in self.sv_Admin.subviews )
    {
        if( [subView isKindOfClass:[UIImageView class]] )
        {
            UIImageView *iv_Sub = (UIImageView *)subView;
            if( iv_Sub.tag > 0 )
            {
                iv_Sub.alpha = 0.3f;
                iv_Sub.layer.borderColor = [UIColor clearColor].CGColor;
            }
        }
    }
    
    iv.alpha = YES;
    iv.layer.borderColor = [UIColor redColor].CGColor;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self layoutIfNeeded];

    [self initFrame];

    self.btn_Like.hidden = self.btn_New.hidden = YES;
    
    ar_ColorList = @[@"9ED8EB", @"FDE581", @"DAF180", @"DBD6F1", @"FBDADC", @"E1E1E1"];
    
    self.c_ChattingCell = [self.tbv_QList dequeueReusableCellWithIdentifier:NSStringFromClass([ChattingCell class])];
    self.questionListCell = [self.tbv_DList dequeueReusableCellWithIdentifier:NSStringFromClass([QuestionListCell class])];

    //하단에서 끌어 올리는거
//    UIPanGestureRecognizer *recognizer = [[UIPanGestureRecognizer alloc]
//                                          initWithTarget:self action:@selector(handlePan:)];
//    [recognizer setMaximumNumberOfTouches:1];
//    [recognizer setDelegate:self];
//
//    [self addGestureRecognizer:recognizer];

    [self.btn_Back addTarget:self action:@selector(onBack:) forControlEvents:UIControlEventTouchUpInside];
//    [self.btn_AddDiscrip addTarget:self action:@selector(onAddDiscrip:) forControlEvents:UIControlEventTouchUpInside];
    
    self.btn_AddDiscrip.layer.cornerRadius = 8.f;
    self.btn_AddDiscrip.layer.borderWidth = 1.f;
    self.btn_AddDiscrip.layer.borderColor = kMainYellowColor.CGColor;
    self.btn_AddDiscrip.hidden = YES;
    
    self.btn_AddD.layer.cornerRadius = 8.f;
    self.btn_AddD.layer.borderWidth = 1.f;
    self.btn_AddD.layer.borderColor = kMainYellowColor.CGColor;
    [self.btn_AddD addTarget:self action:@selector(onAddDiscrip:) forControlEvents:UIControlEventTouchUpInside];

    
    
    self.v_CommentKeyboardAccView.tv_Contents.placeholder = kChatPlaceHolder;
    self.v_CommentKeyboardAccView.tv_Contents.layer.cornerRadius = 10.f;
    self.v_CommentKeyboardAccView.tv_Contents.layer.borderWidth = 1.f;
    self.v_CommentKeyboardAccView.tv_Contents.layer.borderColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1].CGColor;
    self.v_CommentKeyboardAccView.tv_Contents.delegate = self;
    
    [self.v_CommentKeyboardAccView.btn_Done addTarget:self action:@selector(onAddQuestion:) forControlEvents:UIControlEventTouchUpInside];
    [self.v_CommentKeyboardAccView.btn_Add addTarget:self action:@selector(onTakeFile) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAnimate:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAnimate:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)scrollToTheBottom:(BOOL)animated
{
    if( self.tbv_QList.contentSize.height < self.tbv_QList.frame.size.height )
    {
        return;
    }
    
    if( self.arM_QList.count > 0 )
    {
        CGPoint offset = CGPointMake(0, self.tbv_QList.contentSize.height - self.tbv_QList.frame.size.height);
        [self.tbv_QList setContentOffset:offset animated:animated];
    }
}

#pragma mark - SendBird
- (void)startSendBird
{
//    __weak __typeof(&*self)weakSelf = self;
//
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
//        //        ALERT(nil, message.message, nil, @"확인", nil);
//        
//        NSData* data = [message.data dataUsingEncoding:NSUTF8StringEncoding];
//        
//        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
//        NSMutableDictionary *dicM_Result = [NSMutableDictionary dictionaryWithDictionary:[jsonParser objectWithString:dataString]];
//        
//        NSInteger nMyId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue];
//        NSInteger nTargetId = [[dicM_Result objectForKey_YM:@"userId"] integerValue];
//
//        NSLog(@"dicM_Result : %@", dicM_Result);
//        
//        if( [message.message isEqualToString:@"regist-explain"] )
//        {
//            //            //새로운 문제풀이 등록
//        }
//        else if( [message.message isEqualToString:@"delete-explain"] )
//        {
//            //            [self updateDList];
//        }
//        else if( [message.message isEqualToString:@"regist-qna"] )
//        {
//            //새로운 질문 등록
//            if( nMyId != nTargetId )
//            {
//                NSDictionary *dic_Tmp = [dicM_Result objectForKey:@"result"];
//                if( dic_Tmp )
//                {
//                    [weakSelf.arM_QList addObject:dic_Tmp];
//                    [weakSelf.tbv_QList reloadData];
//                    [weakSelf.tbv_QList setNeedsLayout];
//                    [self scrollToTheBottom:YES];
//                }
//                else
//                {
//                    [dicM_Result setObject:@"qna" forKey:@"itemType"];
//                    [weakSelf updateOneList:dicM_Result];
//                }
//            }
//
//            ++nQTotalCnt;
//            [weakSelf.seg setTitle:[NSString stringWithFormat:@"질문 %ld", nQTotalCnt] forSegmentAtIndex:1];
//
//            if( weakSelf.updateCountBlock )
//            {
//                weakSelf.updateCountBlock([NSString stringWithFormat:@"%ld", weakSelf.arM_DList.count + nQTotalCnt]);
//            }
//        }
//        else if( [message.message isEqualToString:@"delete-qna"] )
//        {
//            //질문삭제
//            if( self.seg.selectedSegmentIndex == 0 )
//            {
//                [weakSelf updateDList];
//                return;
//            }
//            NSInteger nGroupId = 0;
//            NSInteger nEId = [[dicM_Result objectForKey:@"eId"] integerValue];
//            for( NSInteger i = 0; i < self.arM_QList.count; i++ )
//            {
//                NSDictionary *dic_Tmp = self.arM_QList[i];
//                NSInteger nEId_Tmp = [[dic_Tmp objectForKey:@"eId"] integerValue];
//                if( nEId == nEId_Tmp )
//                {
//                    nGroupId = [[dic_Tmp objectForKey:@"groupId"] integerValue];
//                    break;
//                }
//            }
//            
//            NSMutableArray *arM_Tmp = [NSMutableArray array];
//            for( NSInteger i = 0; i < self.arM_QList.count; i++ )
//            {
//                NSDictionary *dic_Tmp = self.arM_QList[i];
//                NSInteger nGroupIdTmp = [[dic_Tmp objectForKey:@"groupId"] integerValue];
//                if( nGroupId != nGroupIdTmp )
//                {
//                    [arM_Tmp addObject:dic_Tmp];
//                }
//            }
//            
//            --nQTotalCnt;
//            [weakSelf.seg setTitle:[NSString stringWithFormat:@"질문 %ld", nQTotalCnt] forSegmentAtIndex:1];
//
//            if( weakSelf.updateCountBlock )
//            {
//                weakSelf.updateCountBlock([NSString stringWithFormat:@"%ld", weakSelf.arM_DList.count + nQTotalCnt]);
//            }
//
//            self.arM_QList = arM_Tmp;
//            [self.tbv_QList reloadData];
//        }
//        else if( [message.message isEqualToString:@"delete-reply"] )
//        {
//            NSInteger nEId = [[dicM_Result objectForKey:@"eId"] integerValue];
//            for( NSInteger i = 0; i < self.arM_QList.count; i++ )
//            {
//                NSDictionary *dic_Tmp = self.arM_QList[i];
//                NSInteger nEId_Tmp = [[dic_Tmp objectForKey:@"eId"] integerValue];
//                if( nEId == nEId_Tmp )
//                {
//                    [self.arM_QList removeObjectAtIndex:i];
//                    [self.tbv_QList reloadData];
//                }
//            }
//        }
//        else if( [message.message isEqualToString:@"regist-reply"] )
//        {
//            //답글등록
//            [dicM_Result setObject:@"reply" forKey:@"itemType"];
//            
//            if( self.seg.selectedSegmentIndex == 0 )
//            {
//                [self updateDList];
//                
//                if( [[dicM_Result objectForKey:@"userId"] integerValue] != [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue] )
//                {
//                    [self.vc_Parents.navigationController.view makeToast:@"새로운 답글이 등록 되었습니다." withPosition:kPositionTop];
//                }
//            }
//            else
//            {
//                BOOL isAnswerOk = NO;
//                
//                //답글인 경우 다이렉트 질문 여부를 찾아서 지정자가 답했을 경우 전체 데이터를 리로드 해준다
//                NSInteger nReplyId = [[dicM_Result objectForKey:@"replyId"] integerValue];
//                for( NSInteger i = 0; i < self.arM_QList.count; i++ )
//                {
//                    NSDictionary *dic = self.arM_QList[i];
//                    NSString *str_Type = [dic objectForKey:@"itemType"];
//                    if( [str_Type isEqualToString:@"qna"] )
//                    {
//                        if( nReplyId == [[dic objectForKey:@"eId"] integerValue] )
//                        {
//                            //질문을 찾음!
//                            if( [[dic objectForKey:@"qnaType"] isEqualToString:@"direct"] )
//                            {
//                                NSInteger nAdminId = [[dic objectForKey:@"answerUserId"] integerValue];
//                                if( [[dicM_Result objectForKey:@"userId"] integerValue] == nAdminId )
//                                {
//                                    //질문자에게 질문한 경우
//                                    isAnswerOk = YES;
//                                    [self updateQList];
//                                }
//                            }
//                            
//                            break;
//                        }
//                    }
//                }
//                
//                if( [[dicM_Result objectForKey:@"userId"] integerValue] != [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue] )
//                {
//                    [self.vc_Parents.navigationController.view makeToast:@"새로운 답글이 등록 되었습니다." withPosition:kPositionTop];
//                    
//                    if( isAnswerOk == NO )
//                    {
//                        [self updateOneList:dicM_Result];
//                    }
//                }
//            }
//        }
//        else if( [message.message isEqualToString:@"join-chat"] )
//        {
//            NSInteger nUserId = [[dicM_Result objectForKey:@"userId"] integerValue];
//            NSInteger nMyUserId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue];
//            if( nUserId != nMyUserId )
//            {
//                NSString *str_UserName = [dicM_Result objectForKey:@"userName"];
//                [self.vc_Parents.navigationController.view makeToast:[NSString stringWithFormat:@"%@님이 참여했습니다.", str_UserName] withPosition:kPositionBottom];
//            }
//        }
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

- (void)updateOneList:(NSDictionary *)dic
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]], @"questionId",
                                        [NSString stringWithFormat:@"%@", [dic objectForKey:@"eId"]], @"eId",
                                        [NSString stringWithFormat:@"%@", [dic objectForKey:@"itemType"]], @"itemType",
                                        nil];
    
    //    if( [[dic objectForKey:@"itemType"] isEqualToString:@"qna"] )
    //    {
    //        //질문
    //
    //    }
    //    else
    //    {
    //        //답글
    //        [dicM_Params setObject:[NSString stringWithFormat:@"%@", [dic objectForKey:@"itemType"]] forKey:@"itemType"];
    //    }
    __weak __typeof(&*self)weakSelf = self;
    
    __block BOOL isMy = NO;
    if( [[dic objectForKey:@"userId"] integerValue] == [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue] )
    {
        isMy = YES;
        return;
    }
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/exam/question/files/info"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        if( resulte )
                                        {
                                            NSLog(@"resulte : %@", resulte);
                                            
                                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT,0), ^{
                                                
                                                NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                if( nCode == 200 )
                                                {
                                                    if( [[dic objectForKey:@"itemType"] isEqualToString:@"qna"] )
                                                    {
                                                        //질문
                                                        if( isMy )
                                                        {
                                                            for( NSInteger i = 0; i < weakSelf.arM_QList.count; i++ )
                                                            {
                                                                NSDictionary *dic_Sub = weakSelf.arM_QList[i];
                                                                if( [[dic_Sub objectForKey:@"isMy"] isEqualToString:@"Y"] )
                                                                {
                                                                    [weakSelf.arM_QList removeObjectAtIndex:i];
                                                                    [weakSelf.arM_QList insertObject:resulte atIndex:i];
                                                                    return;
                                                                }
                                                            }
                                                        }
                                                        else
                                                        {
                                                            [weakSelf.arM_QList addObject:resulte];
                                                            
//                                                            if( weakSelf.updateCountBlock )
//                                                            {
////                                                                [weakSelf.seg setTitle:[NSString stringWithFormat:@"문제풀이 %ld", weakSelf.arM_DList.count] forSegmentAtIndex:0];
////                                                                
////                                                                if( [[resulte objectForKey:@"itemType"] isEqualToString:@"qna"] )
////                                                                {
////                                                                    ++nQTotalCnt;
////                                                                    [weakSelf.seg setTitle:[NSString stringWithFormat:@"질문 %ld", nQTotalCnt] forSegmentAtIndex:1];
////                                                                }
//                                                                
//                                                                weakSelf.updateCountBlock([NSString stringWithFormat:@"%ld", weakSelf.arM_DList.count + nQTotalCnt]);
//
//                                                                
//                                                                
////                                                                [weakSelf performSelector:@selector(onInterval:) withObject:resulte afterDelay:0.1f];
//
////                                                                [weakSelf.seg setTitle:[NSString stringWithFormat:@"질문 %ld", weakSelf.arM_QList.count] forSegmentAtIndex:1];
//                                                            }
                                                        }
                                                    }
                                                    else
                                                    {
                                                        for( NSInteger i = 0; i < weakSelf.arM_QList.count; i++ )
                                                        {
                                                            NSDictionary *dic_Sub = weakSelf.arM_QList[i];
                                                            NSInteger nEId = [[dic_Sub objectForKey:@"groupId"] integerValue];
                                                            NSInteger nParentEid = [[dic objectForKey:@"replyId"] integerValue];
                                                            if( nEId == nParentEid )
                                                            {
                                                                BOOL isLastObj = YES;
                                                                NSInteger nPK = i;
                                                                for( NSInteger j = nPK; j < weakSelf.arM_QList.count; j++ )
                                                                {
                                                                    NSDictionary *dic_Sub2 = weakSelf.arM_QList[j];
                                                                    NSInteger nGroupId = [[dic_Sub2 objectForKey:@"groupId"] integerValue];
                                                                    if( nGroupId != nParentEid )
                                                                    {
                                                                        isLastObj = NO;
                                                                        nPK = j;
                                                                        break;
                                                                    }
                                                                }
                                                                
                                                                if( isLastObj )
                                                                {
                                                                    NSDictionary *dic_Tmp = [weakSelf.arM_QList lastObject];
                                                                    NSInteger nPrevReplyIdx = [[dic_Tmp objectForKey:@"replyInx"] integerValue];
                                                                    
                                                                    NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:resulte];
                                                                    [dicM setObject:[NSString stringWithFormat:@"%ld", ++nPrevReplyIdx] forKey:@"replyInx"];
                                                                    
                                                                    if( isMy )
                                                                    {
                                                                        for( NSInteger i = 0; i < weakSelf.arM_QList.count; i++ )
                                                                        {
                                                                            NSDictionary *dic_Sub = weakSelf.arM_QList[i];
                                                                            if( [[dic_Sub objectForKey:@"isMy"] isEqualToString:@"Y"] )
                                                                            {
                                                                                [weakSelf.arM_QList removeObjectAtIndex:i];
                                                                                [weakSelf.arM_QList insertObject:resulte atIndex:i];
                                                                                [weakSelf.tbv_QList reloadData];
                                                                                return;
                                                                            }
                                                                        }
                                                                    }
                                                                    else
                                                                    {
                                                                        [weakSelf.arM_QList addObject:resulte];
                                                                        
//                                                                        if( weakSelf.updateCountBlock )
//                                                                        {
//                                                                            [weakSelf.seg setTitle:[NSString stringWithFormat:@"문제풀이 %ld", weakSelf.arM_DList.count] forSegmentAtIndex:0];
//                                                                            if( [[resulte objectForKey:@"itemType"] isEqualToString:@"qna"] )
//                                                                            {
//                                                                                nQTotalCnt++;
//                                                                                [weakSelf.seg setTitle:[NSString stringWithFormat:@"질문 %ld", nQTotalCnt] forSegmentAtIndex:1];
//                                                                            }
//
//                                                                            weakSelf.updateCountBlock([NSString stringWithFormat:@"%ld", weakSelf.arM_DList.count + nQTotalCnt]);
//
////                                                                            [weakSelf.seg setTitle:[NSString stringWithFormat:@"질문 %ld", weakSelf.arM_QList.count] forSegmentAtIndex:1];
//                                                                        }
                                                                    }
                                                                }
                                                                else
                                                                {
                                                                    NSDictionary *dic_Tmp = [weakSelf.arM_QList objectAtIndex:nPK - 1];
                                                                    NSInteger nPrevReplyIdx = [[dic_Tmp objectForKey:@"replyInx"] integerValue];
                                                                    
                                                                    NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:resulte];
                                                                    [dicM setObject:[NSString stringWithFormat:@"%ld", ++nPrevReplyIdx] forKey:@"replyInx"];
                                                                    
                                                                    if( isMy )
                                                                    {
                                                                        for( NSInteger i = 0; i < weakSelf.arM_QList.count; i++ )
                                                                        {
                                                                            NSDictionary *dic_Sub = weakSelf.arM_QList[i];
                                                                            if( [[dic_Sub objectForKey:@"isMy"] isEqualToString:@"Y"] )
                                                                            {
                                                                                [weakSelf.arM_QList replaceObjectAtIndex:i withObject:resulte];
                                                                                [weakSelf.tbv_QList reloadData];
                                                                                return;
                                                                            }
                                                                        }
                                                                    }
                                                                    else
                                                                    {
                                                                        [weakSelf.arM_QList insertObject:dicM atIndex:nPK];
                                                                    }
                                                                }
                                                                break;
                                                            }
                                                        }
                                                    }
                                                    
                                                    //혹시라도 같은게 있으면 빼주기 (중복되어 올라오는 현상에 대한 방어코드)
                                                    for( NSInteger i = 0; i < weakSelf.arM_QList.count - 1; i++ )
                                                    {
                                                        NSDictionary *dic_Current = weakSelf.arM_QList[i];
                                                        NSDictionary *dic_Next = weakSelf.arM_QList[i + 1];
                                                        
                                                        if( [[dic_Current objectForKey_YM:@"eId"] integerValue] == [[dic_Next objectForKey_YM:@"eId"] integerValue] )
                                                        {
                                                            [weakSelf.arM_QList removeObjectAtIndex:i + 1];
                                                            break;
                                                        }
                                                    }
                                                }
                                                else
                                                {
                                                    [weakSelf makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                }
                                                
                                                dispatch_async(dispatch_get_main_queue(), ^{
                                                    
                                                    NSLog(@"@@@@@@@@@@@@@@@@@@@Start@@@@@@@@@@@@@@@@@@@");
                                                    [weakSelf.tbv_QList reloadData];
                                                    NSLog(@"@@@@@@@@@@@@@@@@@@@End@@@@@@@@@@@@@@@@@@@");
                                                    
                                                    //                                                    CGPoint offset = CGPointMake(0, self.tbv_List.contentSize.height - self.tbv_List.frame.size.height);
                                                    //                                                    [self.tbv_List setContentOffset:offset animated:NO];
                                                    
                                                });
                                            });
                                            
                                        }
                                    }];
}

//- (void)onInterval:(NSDictionary *)resulte
//{
//    [self.seg setTitle:[NSString stringWithFormat:@"문제풀이 %ld", self.arM_DList.count] forSegmentAtIndex:0];
//    
//    if( [[resulte objectForKey:@"itemType"] isEqualToString:@"qna"] )
//    {
//        ++nQTotalCnt;
//        [self.seg setTitle:[NSString stringWithFormat:@"질문 %ld", nQTotalCnt] forSegmentAtIndex:1];
//    }
//
//    self.updateCountBlock([NSString stringWithFormat:@"%ld", self.arM_DList.count + nQTotalCnt]);
//}

//- (void)dealloc
//{
//    NSLog(@"dealloc");
//}

- (void)initConstant
{
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    self.lc_BottomViewBottom.constant = (window.bounds.size.height - (73 + (self.isNavi ? 64 : 0))) * -1;
    self.lc_BgTop.constant = 29.f;
    fOriginalBottom = self.lc_BottomViewBottom.constant;
    self.btn_Back.alpha = self.btn_AddDiscrip.alpha = self.seg.alpha = NO;
    self.v_CommentKeyboardAccView.lc_Height.constant = 45.f;
    self.lc_CommentX.constant = 135.f;
    self.iv_Bg.alpha = NO;
    
    self.sv_Contents.delegate = self;
    self.sv_Contents.pagingEnabled = YES;
    self.sv_Contents.bounces = NO;
//    self.sv_Contents.contentSize = CGSizeMake(self.bounds.size.width * 2, self.bounds.size.height);
    self.lc_ContentsWidth.constant = self.bounds.size.width * 2;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if( scrollView == self.sv_Contents )
    {
        NSInteger nPage = scrollView.contentOffset.x / scrollView.frame.size.width;
        if( nPage == 0 )
        {
            self.seg.selectedSegmentIndex = 0;
            [self endEditing:YES];
            
            [self performSelector:@selector(onDResetInterval) withObject:nil afterDelay:0.3f];
        }
        else
        {
            self.seg.selectedSegmentIndex = 1;
            
            [self performSelector:@selector(onQResetInterval) withObject:nil afterDelay:0.3f];
        }
    }
}

- (void)onDResetInterval
{
//    [SendBird disconnect];
    [self joinDRoom];
    [self updateDList];
}

- (void)onQResetInterval
{
//    [SendBird disconnect];
    [self joinQRoom];
    [self updateQList];
}

- (void)initFrame
{
    [self initConstant];
}

- (void)initFrame:(UIViewController *)vc
{
    self.vc_Parents = vc;
    [self initFrame];
    
//    [self startSendBird];
    
//    [self joinDRoom];
//    [self joinQRoom];
    
//    [self updateAdminList];

//    [self startSendBird];
//    //thotingQuestion_channel_21413
//    NSString *str_ChannelUrl = [NSString stringWithFormat:@"thotingQuestion_channel_%@", [NSString stringWithFormat:@"%@", self.str_QId]];
//    [SendBird joinChannel:str_ChannelUrl];
//    [SendBird connect];
//    
//    [self performSelector:@selector(onJoinMessageInterval) withObject:nil afterDelay:1.f];
}

- (void)joinDRoom
{
    NSString *str_ChannelUrl = [NSString stringWithFormat:@"thotingQuestion_explain_%@", self.str_QId];
    NSString *str_ChannelName = [NSString stringWithFormat:@"%@문제지 %@번 질문과답", self.str_ExamId, self.str_QId];
    //    NSString *str_ChannelName = [NSString stringWithFormat:@"%@문제지 %@번 문제풀이", self.str_ExamId, self.str_QuestionId];
    
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
                                                 if( [[resulte objectForKey:@"error"] integerValue] == 1 )
                                                 {
                                                     //이미 방이 있으면 조인
//                                                     [SendBird joinChannel:str_ChannelUrl];
//                                                     [SendBird connect];
                                                     //                                                     [SendBird sendMessage:@"@@hi@@"];
                                                 }
                                                 else
                                                 {
//                                                     [SendBird joinChannel:[resulte objectForKey:@"channel_url"]];
//                                                     [SendBird connect];
                                                 }
                                             }
                                         }];
}

- (void)joinQRoom
{
    NSString *str_ChannelUrl = [NSString stringWithFormat:@"thotingQuestion_qna_%@", self.str_QId];
    NSString *str_ChannelName = [NSString stringWithFormat:@"%@문제지 %@번 질문과답", self.str_ExamId, self.str_QId];
    
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
                                                 if( [[resulte objectForKey:@"error"] integerValue] == 1 )
                                                 {
                                                     //이미 방이 있으면 조인
//                                                     [SendBird joinChannel:str_ChannelUrl];
//                                                     [SendBird connect];
                                                     //                                                     [SendBird sendMessage:@"@@hi@@"];
                                                 }
                                                 else
                                                 {
//                                                     [SendBird joinChannel:[resulte objectForKey:@"channel_url"]];
//                                                     [SendBird connect];
                                                 }
                                             }
                                             
//                                             [self performSelector:@selector(onJoinMessageInterval) withObject:nil afterDelay:1.f];
                                         }];
}

- (void)onJoinMessageInterval
{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"userId":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],
                                                                 @"userName":[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]}
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:nil];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//    [SendBird sendMessage:@"join-chat" withData:jsonString];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture
{
    NSLog(@"%f", self.lc_BottomViewBottom.constant);
    
    if (gesture.state == UIGestureRecognizerStateBegan )
    {
        fOldY = self.lc_BottomViewBottom.constant;
    }
    else if( gesture.state == UIGestureRecognizerStateChanged )
    {
        CGPoint translation = [gesture translationInView:self.superview];
//        NSLog(@"%@", NSStringFromCGPoint(translation));
        
        if( fOriginalBottom + (translation.y * -1) >= 0 )
        {
            self.lc_BottomViewBottom.constant = 0;
            self.iv_Bg.alpha = 0.7f;
        }
        else if( fOriginalBottom + (translation.y * -1) < (self.bounds.size.height - 73) * -1 )
        {
            self.lc_BottomViewBottom.constant = (self.bounds.size.height - 73) * -1;
            self.iv_Bg.alpha = 0.0f;
        }
        else
        {
            self.iv_Bg.alpha = 0.7f;
            self.lc_BottomViewBottom.constant = fOriginalBottom + (translation.y * -1);
        }
        
        if( self.completionBlock )
        {
            CGFloat fAlphaMin = (self.frame.size.height / 2) - 73;//260
            CGFloat fAlphaMax = self.frame.size.height - 73;
            
            
            //260이 0이 되어야 함
            //594가 1이 되어야 함
            
            NSLog(@"alpha : %f", self.lc_BottomViewBottom.constant);
            NSLog(@"y: %f", self.frame.origin.y);
            NSLog(@"value : %f", ((self.frame.origin.y) - fAlphaMin) / fAlphaMin);
            
            self.completionBlock(@{@"alpha" : [NSNumber numberWithFloat:((self.frame.origin.y) - fAlphaMin) / fAlphaMin], @"animation" : @NO});
        }
        
        if( self.lc_BottomViewBottom.constant == 0 )
        {
            self.btn_Back.alpha = self.btn_AddDiscrip.alpha = self.seg.alpha = YES;
        }
        else
        {
            self.btn_Back.alpha = self.btn_AddDiscrip.alpha = self.seg.alpha = NO;
        }
    }
    else if( gesture.state == UIGestureRecognizerStateEnded )
    {
        //하단으로 스크롤인지 상단으로 스크롤인지 구분
        CGFloat fY;
        if( fOldY > self.lc_BottomViewBottom.constant )
        {
//            NSLog(@"하단");
            fY = self.frame.origin.y + 100;
        }
        else
        {
//            NSLog(@"상단");
            fY = self.frame.origin.y - 100;
        }

        if( fY < 0 )
        {
            fY *= -1;
        }
        
//        [self layoutIfNeeded];
        
        CGFloat fThreeHeight = self.frame.size.height / 3;
        if( fY < fThreeHeight )
        {
            //상단
            [UIView animateWithDuration:0.3f animations:^{
              
                self.iv_Bg.alpha = 0.7f;
                self.lc_BottomViewBottom.constant = 0;
                self.lc_BgTop.constant = 0.f;
//                self.lc_CommentX.constant = self.frame.size.width / 2 - (self.btn_Comment.frame.size.width/2);
                self.btn_Back.alpha = self.btn_AddDiscrip.alpha = self.seg.alpha = YES;
                
                if( self.completionBlock )
                {
                    self.completionBlock(@{@"alpha" : @0, @"animation" : @YES, @"IsTop" : @YES});
                }
                
                [self.superview layoutIfNeeded];
            }];
        }
        else if( fY > fThreeHeight && fY < fThreeHeight * 2 )
        {
            //중단
            [UIView animateWithDuration:0.3f animations:^{
                
                self.iv_Bg.alpha = 0.7f;
                self.lc_BottomViewBottom.constant = (fThreeHeight + (73 / 2)) * -1;
                self.lc_BgTop.constant = 29.f;
//                self.lc_CommentX.constant = self.frame.size.width / 2 - (self.btn_Comment.frame.size.width/2);
                self.btn_Back.alpha = self.btn_AddDiscrip.alpha = self.seg.alpha = NO;

                if( self.completionBlock )
                {
                    self.completionBlock(@{@"alpha" : @0, @"animation" : @YES, @"IsTop" : @NO});
                }
                
                [self.superview layoutIfNeeded];
            }];
        }
        else
        {
            //하단
            [UIView animateWithDuration:0.3f animations:^{
                
                self.iv_Bg.alpha = 0.0f;
                self.lc_BottomViewBottom.constant = (self.frame.size.height - 73) * -1;
                self.lc_BgTop.constant = 29.f;
//                self.lc_CommentX.constant = 135.f;
                self.btn_Back.alpha = self.btn_AddDiscrip.alpha = self.seg.alpha = NO;
                
                if( self.completionBlock )
                {
                    self.completionBlock(@{@"alpha" : @1, @"animation" : @YES, @"IsTop" : @NO});
                }
                
                [self.superview layoutIfNeeded];
            }];
        }

        fOriginalBottom = self.lc_BottomViewBottom.constant;
    }
}

- (void)deallocBottomView
{
    [self endEditing:YES];
    self.v_CommentKeyboardAccView.lc_Height.constant = 45.f;

    self.seg.selectedSegmentIndex = 0;

//    [SendBird disconnect];
    
    self.sv_Contents.contentOffset = CGPointZero;
    [self endEditing:YES];
    

//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:UIKeyboardWillShowNotification
//                                                  object:nil];
//    
//    [[NSNotificationCenter defaultCenter] removeObserver:self
//                                                    name:UIKeyboardWillHideNotification
//                                                  object:nil];
}

- (void)onBack:(UIButton *)btn
{
    self.lc_BottomViewBottom.constant = (self.frame.size.height - (73 + (self.isNavi ? 64 : 0))) * -1;
//    [self setNeedsUpdateConstraints];
    
    [UIView animateWithDuration:0.3f animations:^{
        
        [self.superview layoutIfNeeded];
    }];

    [UIView animateWithDuration:0.1f animations:^{
        
        self.iv_Bg.alpha = 0.0f;
        self.lc_BgTop.constant = 29.f;
        self.btn_Back.alpha = self.btn_AddDiscrip.alpha = self.seg.alpha = NO;
        fOriginalBottom = self.lc_BottomViewBottom.constant;

        if( self.completionBlock )
        {
            self.completionBlock(@{@"alpha" : @1, @"animation" : @YES});
        }
    }];
    
    [self deallocBottomView];
}

- (void)onAddDiscrip:(UIButton *)btn
{
    if( self.addCompletionBlock )
    {
        self.addCompletionBlock(nil);
    }
}





- (void)updateDList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_QId, @"questionId",
                                        @"", @"limitCount",
                                        @"", @"lastQnaId",
                                        self.btn_Like.selected ? @"thubmup" : @"newest", @"orderBy",
//                                        @"thubmup", @"orderBy",
                                        @"list", @"resultType",
                                        @"Y", @"withReply",
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
                                                nTotalCnt = [[resulte objectForKey:@"dataCount"] integerValue];
                                                
                                                str_ImagePreFix = [resulte objectForKey:@"image_prefix"];
                                                str_ImagePreUrl = [resulte objectForKey:@"imgUrl"];
                                                str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
                                                
                                                [weakSelf.tbv_DList setContentOffset:CGPointZero];
                                                [weakSelf.arM_DList removeAllObjects];
                                                weakSelf.arM_DList = [NSMutableArray arrayWithArray:[resulte objectForKey:@"data"]];
                                                
                                                [weakSelf.seg setTitle:[NSString stringWithFormat:@"문제풀이 %ld", weakSelf.arM_DList.count] forSegmentAtIndex:0];

                                                NSInteger nExplainCnt = 0;
                                                for( NSInteger i = 0; i < weakSelf.arM_DList.count; i++ )
                                                {
                                                    NSDictionary *dic_Tmp = weakSelf.arM_DList[i];
                                                    NSString *str_ItemType = [dic_Tmp objectForKey:@"itemType"];
                                                    if( [str_ItemType isEqualToString:@"explain"] )
                                                    {
                                                        nExplainCnt++;
                                                    }
                                                }
                                                
                                                if( nExplainCnt > 1 )
                                                {
                                                    self.btn_Like.hidden = self.btn_New.hidden = NO;
                                                }
                                                else
                                                {
                                                    self.btn_Like.hidden = self.btn_New.hidden = YES;
                                                }
//                                                [weakSelf updateQList];
                                                
                                                [weakSelf.tbv_DList reloadData];
                                            }
                                            else
                                            {
                                                [weakSelf makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

- (void)updateQList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_QId, @"questionId",
                                        @"list", @"resultType",
                                        @"", @"limitCount",
                                        @"", @"lastQnaId",
//                                        self.btn_QLike.selected ? @"thubmup" : @"newest", @"orderBy",
                                        @"chatQna", @"callWhere",
//                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"], @"getUserId",
//                                        @"", @"",
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
                                                nQTotalCnt = [[resulte objectForKey_YM:@"dataCount"] integerValue];
                                                
                                                nTotalCnt += nQTotalCnt;
                                                
                                                weakSelf.arM_QList = [NSMutableArray arrayWithArray:[resulte objectForKey:@"data"]];
                                                [weakSelf.tbv_QList reloadData];
                                                
                                                if( weakSelf.updateCountBlock )
                                                {
                                                    NSInteger nDcount = [[resulte objectForKey:@"explainCount"] integerValue];
                                                    NSInteger nQcount = [[resulte objectForKey:@"qnaCount"] integerValue];
                                                    weakSelf.updateCountBlock(@{@"dCount":[NSString stringWithFormat:@"%ld", nDcount], @"qCount":[NSString stringWithFormat:@"%ld", nQcount]});

//                                                    weakSelf.updateCountBlock([NSString stringWithFormat:@"%ld", weakSelf.arM_DList.count + nQTotalCnt]);
                                                    [weakSelf.seg setTitle:[NSString stringWithFormat:@"문제풀이 %ld", weakSelf.arM_DList.count] forSegmentAtIndex:0];
                                                    
                                                    [weakSelf.seg setTitle:[NSString stringWithFormat:@"질문 %ld", nQTotalCnt] forSegmentAtIndex:1];

//                                                    [weakSelf.seg setTitle:[NSString stringWithFormat:@"질문 %ld", nQTotalCnt] forSegmentAtIndex:1];
                                                }
                                            }
                                            else
                                            {
                                                [weakSelf makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}


#pragma mark - Notification
- (void)keyboardWillAnimate:(NSNotification *)notification
{
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self convertRect:keyboardBounds toView:nil];
    fKeyboardHeight = keyboardBounds.size.height;
    
    if([notification name] == UIKeyboardWillShowNotification)
    {
        self.v_CommentKeyboardAccView.lc_Bottom.constant = keyboardBounds.size.height;
    }
    else if([notification name] == UIKeyboardWillHideNotification)
    {
        self.v_CommentKeyboardAccView.lc_Bottom.constant = 0.f;
    }

    [UIView animateWithDuration:[duration doubleValue] animations:^{
        [UIView setAnimationCurve:[curve intValue]];
        
        [self layoutIfNeeded];
        
    }completion:^(BOOL finished) {
        
    }];
}


#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [self performSelector:@selector(onChangeInterval) withObject:nil afterDelay:0.1f];
    NSUInteger length = [[textView text] length] - range.length + text.length;
    if( length <= 0 )
    {
        self.v_CommentKeyboardAccView.btn_Done.selected = NO;
        self.v_CommentKeyboardAccView.btn_Done.userInteractionEnabled = NO;
    }
    else
    {
        self.v_CommentKeyboardAccView.btn_Done.selected = YES;
        self.v_CommentKeyboardAccView.btn_Done.userInteractionEnabled = YES;
    }
    
    return YES;
}

- (void)onChangeInterval
{
    CGFloat fHeight = [Util getTextViewHeight:self.v_CommentKeyboardAccView.tv_Contents];
    fHeight += 12.f;
    if( fHeight <= 45.f )
    {
        self.v_CommentKeyboardAccView.lc_Height.constant = 45.f;
    }
    else if( fHeight > 100 )
    {
        self.v_CommentKeyboardAccView.lc_Height.constant = 100.f;
    }
    else
    {
        self.v_CommentKeyboardAccView.lc_Height.constant = fHeight;
    }
    
    [UIView animateWithDuration:0.1f animations:^{
        
        [self layoutIfNeeded];
    }];
}


#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if( tableView == self.tbv_DList )
    {
        return self.arM_DList.count;
    }
    
    return self.arM_QList.count;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( tableView == self.tbv_DList )
    {
        QuestionListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuestionListCell" forIndexPath:indexPath];
        [self configureCell:cell forRowAtIndexPath:indexPath withAddMode:YES];

//        NSDictionary *dic_Info = self.arM_DList[indexPath.section];
//        NSString *str_ItemType = [dic_Info objectForKey:@"itemType"];
//        QuestionListCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuestionListCell" forIndexPath:indexPath];
//        [self configureCell:cell forRowAtIndexPath:indexPath withAddMode:YES];

        return cell;
    }
    
    
    ChattingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChattingCell" forIndexPath:indexPath];
    
    for( UIGestureRecognizer *recognizer in cell.gestureRecognizers )
    {
        [cell removeGestureRecognizer:recognizer];
    }
    
    cell.tag = indexPath.section;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
    [cell addGestureRecognizer:longPress];
    
    UITapGestureRecognizer *cellTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTap:)];
    [cellTap setNumberOfTapsRequired:1];
    [cell addGestureRecognizer:cellTap];

    [self configureChatCell:cell forRowAtIndexPath:indexPath withAddMode:YES];
    
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( tableView == self.tbv_DList )
    {
        [self configureCell:self.questionListCell forRowAtIndexPath:indexPath withAddMode:YES];
        
        [self.questionListCell updateConstraintsIfNeeded];
        [self.questionListCell layoutIfNeeded];
        
        self.questionListCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_DList.bounds), CGRectGetHeight(self.questionListCell.bounds));
        
        //    fContentsHeight = [self.questionListCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        //    return [self.questionListCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
        return self.questionListCell.contentView.bounds.size.height;
    }
    
    
//    NSDictionary *dic_Info = self.arM_List[indexPath.section];
//    NSString *str_ItemType = [dic_Info objectForKey:@"itemType"];
//    if( [str_ItemType isEqualToString:@"explain"] )
//    {
//        [self configureCell:self.questionListCell forRowAtIndexPath:indexPath withAddMode:YES];
//        
//        [self.questionListCell updateConstraintsIfNeeded];
//        [self.questionListCell layoutIfNeeded];
//
//        self.questionListCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.questionListCell.bounds));
//        
//        //    fContentsHeight = [self.questionListCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
//        //    return [self.questionListCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
//        return self.questionListCell.contentView.bounds.size.height;
//    }
    
    [self configureChatCell:self.c_ChattingCell forRowAtIndexPath:indexPath withAddMode:YES];
    
    [self.c_ChattingCell updateConstraintsIfNeeded];
    [self.c_ChattingCell layoutIfNeeded];

    self.c_ChattingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_QList.bounds), CGRectGetHeight(self.c_ChattingCell.bounds));
    
    //    fContentsHeight = [self.questionListCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    
    NSDictionary *dic_Info = self.arM_QList[indexPath.section];
    NSString *str_QnaType = [dic_Info objectForKey:@"qnaType"];
    NSString *str_Read = [dic_Info objectForKey:@"isRead"];
    if( [str_QnaType isEqualToString:@"direct"] && [str_Read isEqualToString:@"W"] == NO )
    {
        return [self.c_ChattingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height + 50.f;
    }
    
    return [self.c_ChattingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if( tableView == self.tbv_QList )
    {
        return 0;
    }
    
    return 56.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *CellIdentifier = @"DiscripHeaderCell";
    DiscripHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if( cell == nil )
    {
        return nil;
    }
    
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
        return nil;
    }
    else
    {
        dic = self.arM_DList[section];
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


//뷰와 뷰컨트롤러이다
//새로고침

- (void)configureChatCell:(ChattingCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withAddMode:(BOOL)isAdd
{
    for( UIView *subView in cell.contentView.subviews )
    {
        [subView removeFromSuperview];
    }
    
    //질문
    static BOOL isLeft = YES;
    
    __block CGFloat fSampleViewTotalHeight = 20;
    
    BOOL isOnlyText = YES;
    CGFloat fTextWidth = 20.0f;
    
    NSDictionary *dic_Info = self.arM_QList[indexPath.section];
    
    if( [[dic_Info objectForKey:@"isMy"] isEqualToString:@"Y"] )
    {
        
    }
    
    NSInteger nColorIdx = [[dic_Info objectForKey_YM:@"groupId"] integerValue];
    nColorIdx = (nColorIdx % 6);
    NSString *str_Color = ar_ColorList[nColorIdx];
    
    UIImageView *iv_Ballon = [[UIImageView alloc] init];
    UIImage *i_Ballon = nil;
    
    NSString *str_ItemType = [dic_Info objectForKey_YM:@"itemType"];
    NSArray *ar = nil;
    BOOL isQna = [str_ItemType isEqualToString:@"qna"];
    NSInteger nX = 80.f;
    NSInteger nTail = 35.f;
    
    if( isQna )
    {
        isLeft = YES;
        ar = [dic_Info objectForKey_YM:@"qnaBody"];
    }
    else
    {
        //댓글이 몇번째 댓글인지 내려주기로 했음
        NSInteger nReplyIdx = [[dic_Info objectForKey_YM:@"replyInx"] integerValue];
        //        isLeft = !(nReplyIdx % 2);
        //        isLeft = !isLeft;
        isLeft = NO;
        
        //질문자가 답한건지에 대한 여부 (질문자는 말풍선이 항상 왼쪽에 위치해야 하기 때문)
        if( [[dic_Info objectForKey_YM:@"isQuestioner"] isEqualToString:@"Y"] )
        {
            isLeft = YES;
        }
        
        ar = [dic_Info objectForKey_YM:@"replyBody"];
    }
    
    if( isLeft )
    {
        NSString *str_ImageName = [NSString stringWithFormat:@"bubble_%ld.png", nColorIdx + 1];
        
        UIImage *i_Ballon = BundleImage(str_ImageName);
        i_Ballon = [Util makeNinePatchImage:i_Ballon];
        [iv_Ballon setImage:i_Ballon];
        //        ar = [dic_Info objectForKey_YM:@"qnaBody"];
        //        cell.contentView.backgroundColor = [UIColor whiteColor];
        
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
        //        ar = [dic_Info objectForKey_YM:@"replyBody"];
        //        cell.contentView.backgroundColor = [UIColor colorWithHexString:@"F3F3F3"];
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
        NSString *str_Type = isQna ? [dic objectForKey_YM:@"qnaType"] : [dic objectForKey_YM:@"replyType"];
        NSString *str_Body = isQna ? [dic objectForKey_YM:@"qnaBody"] : [dic objectForKey_YM:@"replyBody"];
        
        if( [str_Type isEqualToString:@"text"] )
        {
            UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(nX, fSampleViewTotalHeight,
                                                                              cell.contentView.frame.size.width - (nX + nTail) - (isLeft ? 0 : 20), 0)];
            lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(lb_Contents.frame);
            lb_Contents.font = [UIFont fontWithName:@"Helvetica" size:14.f];
            lb_Contents.text = str_Body;
            lb_Contents.numberOfLines = 0;
            //            lb_Contents.textColor = [UIColor whiteColor];
            //            [lb_Contents setBackgroundColor:[UIColor redColor]];
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
            
            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(nX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (nX + nTail) - (isLeft ? 0 : 20), 0)];
            iv.contentMode = UIViewContentModeScaleAspectFill;
            iv.clipsToBounds = YES;
            
            CGFloat fPer = iv.frame.size.width / [[dic objectForKey_YM:@"width"] floatValue];
            CGFloat fHeight = [[dic objectForKey_YM:@"height"] floatValue] * fPer;
            
            if( isnan(fHeight) )    fHeight = 300.f;
            
            CGRect frame = iv.frame;
            frame.size.height = fHeight;
            iv.frame = frame;
            
            if( [[dic objectForKey:@"qnaBody"] isKindOfClass:[UIImage class]] )
            {
                iv.image = [dic objectForKey:@"qnaBody"];
            }
            else if( [[dic objectForKey:@"replyBody"] isKindOfClass:[UIImage class]] )
            {
                iv.image = [dic objectForKey:@"replyBody"];
            }
            else
            {
                NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, str_Body];
                [iv sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
            }
            
            [cell.contentView addSubview:iv];
            
            fSampleViewTotalHeight += iv.frame.size.height + 10;
            
            iv.userInteractionEnabled = YES;
            UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
            [imageTap setNumberOfTapsRequired:1];
            [iv addGestureRecognizer:imageTap];
        }
        else if( [str_Type isEqualToString:@"video"] )
        {
            isOnlyText = NO;
            
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(nX, fSampleViewTotalHeight,
                                                                   cell.contentView.frame.size.width - (nX + nTail), (cell.contentView.frame.size.width - (nX + nTail)) * 0.7f)];
            view.backgroundColor = [UIColor blackColor];
            view.tag = indexPath.section;
            
            NSString *str_Url = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, str_Body];
            NSURL *URL = [NSURL URLWithString:str_Url];
            
            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(nX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (nX + nTail) - (isLeft ? 0 : 20), 0)];
            iv.contentMode = UIViewContentModeScaleAspectFill;
            iv.clipsToBounds = YES;
            
            CGFloat fPer = iv.frame.size.width / [[dic objectForKey_YM:@"videoCoverWidth"] floatValue];
            CGFloat fHeight = [[dic objectForKey_YM:@"videoCoverHeight"] floatValue] * fPer;
            
            if( isnan(fHeight) )    fHeight = 300.f;
            if( fHeight == 0 )      fHeight = 300.f;
            
            CGRect frame = iv.frame;
            frame.size.height = fHeight;
            iv.frame = frame;
            
            if( [[dic objectForKey:@"qnaBody"] isKindOfClass:[UIImage class]] )
            {
                iv.image = [dic objectForKey:@"qnaBody"];
            }
            else if( [[dic objectForKey:@"replyBody"] isKindOfClass:[UIImage class]] )
            {
                iv.image = [dic objectForKey:@"replyBody"];
            }
            else
            {
                NSString *str_ImageUrl = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, [dic objectForKey:@"videoCoverPath"]];
                [iv sd_setImageWithURL:[NSURL URLWithString:str_ImageUrl]];
            }
            
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
            [btn_Play addTarget:self action:@selector(onPlayMove:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:btn_Play];
        }
    }
    
    CGRect frame = cell.frame;
    frame.size.height = fSampleViewTotalHeight + 40;
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
            iv_Ballon.frame = CGRectMake(nX - 20, 10, cell.contentView.frame.size.width - (nX), fSampleViewTotalHeight - 10);
        }
    }
    else
    {
        if( isOnlyText )
        {
            iv_Ballon.frame = CGRectMake(cell.contentView.frame.size.width - 85 - fTextWidth - 10, 10, fTextWidth + 30, fSampleViewTotalHeight - 10);
        }
        else
        {
            iv_Ballon.frame = CGRectMake(20, 10, cell.contentView.frame.size.width - 85, fSampleViewTotalHeight - 10);
        }
    }
    
    
    //유저 이미지
    if( self.arM_QList.count - 1 > indexPath.section)
    {
        NSDictionary *dic_Next = self.arM_QList[indexPath.section + 1];
        
        NSInteger nCurrentUserId = [[dic_Info objectForKey_YM:@"userId"] integerValue];
        NSInteger nNextUserId = [[dic_Next objectForKey_YM:@"userId"] integerValue];
        
        //그 다음이 qna가 아니거나
        NSString *str_NextItemType = [dic_Next objectForKey_YM:@"itemType"];
        if( [str_NextItemType isEqualToString:@"qna"] )
        {
            CGFloat fImageSize = 45.f;
            UIImageView *iv_User = [[UIImageView alloc] initWithFrame:CGRectMake(isLeft ? 10 : cell.contentView.frame.size.width - (fImageSize + 15), fSampleViewTotalHeight - (fImageSize - 10),
                                                                                 fImageSize, fImageSize)];
            iv_User.clipsToBounds = YES;
            [iv_User sd_setImageWithURL:[Util createImageUrl:str_UserImagePrefix withFooter:[dic_Info objectForKey_YM:@"userThumbnail"]]];
            iv_User.layer.cornerRadius = iv_User.frame.size.width/2;
            iv_User.layer.borderColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1].CGColor;
            iv_User.layer.borderWidth = 1.f;
            [cell.contentView addSubview:iv_User];
            
            iv_User.userInteractionEnabled = YES;
            iv_User.tag = indexPath.section;
            UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userImageTap:)];
            [imageTap setNumberOfTapsRequired:1];
            [iv_User addGestureRecognizer:imageTap];
            
        }
        //        if( (isQna || nCurrentUserId != nNextUserId) && [str_NextItemType isEqualToString:@"qna"] == NO )
        else if( isQna || nCurrentUserId != nNextUserId )
        {
            CGFloat fImageSize = 45.f;
            UIImageView *iv_User = [[UIImageView alloc] initWithFrame:CGRectMake(isLeft ? 10 : cell.contentView.frame.size.width - (fImageSize + 15), fSampleViewTotalHeight - (fImageSize - 10),
                                                                                 fImageSize, fImageSize)];
            iv_User.clipsToBounds = YES;
            [iv_User sd_setImageWithURL:[Util createImageUrl:str_UserImagePrefix withFooter:[dic_Info objectForKey_YM:@"userThumbnail"]]];
            iv_User.layer.cornerRadius = iv_User.frame.size.width/2;
            iv_User.layer.borderColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1].CGColor;
            iv_User.layer.borderWidth = 1.f;
            [cell.contentView addSubview:iv_User];
            
            iv_User.userInteractionEnabled = YES;
            iv_User.tag = indexPath.section;
            UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userImageTap:)];
            [imageTap setNumberOfTapsRequired:1];
            [iv_User addGestureRecognizer:imageTap];
        }
    }
    else
    {
        //마지막 인덱스
        CGFloat fImageSize = 45.f;
        UIImageView *iv_User = [[UIImageView alloc] initWithFrame:CGRectMake(isLeft ? 10 : cell.contentView.frame.size.width - (fImageSize + 15), fSampleViewTotalHeight - (fImageSize - 10),
                                                                             fImageSize, fImageSize)];
        iv_User.clipsToBounds = YES;
        [iv_User sd_setImageWithURL:[Util createImageUrl:str_UserImagePrefix withFooter:[dic_Info objectForKey_YM:@"userThumbnail"]]];
        iv_User.layer.cornerRadius = iv_User.frame.size.width/2;
        iv_User.layer.borderColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1].CGColor;
        iv_User.layer.borderWidth = 1.f;
        [cell.contentView addSubview:iv_User];
        
        iv_User.userInteractionEnabled = YES;
        iv_User.tag = indexPath.section;
        UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userImageTap:)];
        [imageTap setNumberOfTapsRequired:1];
        [iv_User addGestureRecognizer:imageTap];
    }
    
    
    //유저 이름
    UILabel *lb_Name = [[UILabel alloc] initWithFrame:CGRectMake(nX - 10, fSampleViewTotalHeight + 8, 0, 15)];
    lb_Name.font = [UIFont fontWithName:@"Helvetica" size:12];
    lb_Name.textColor = [UIColor darkGrayColor];
    lb_Name.text = [dic_Info objectForKey_YM:@"name"];
    
    frame = lb_Name.frame;
    frame.size.width = [Util getTextSize:lb_Name].width;
    if( frame.size.width > self.tbv_QList.bounds.size.width - 250 )
    {
        frame.size.width = self.tbv_QList.bounds.size.width - 250;
    }
    if( isLeft == NO )
    {
        frame.origin.x = cell.contentView.frame.size.width - (frame.size.width + 80);
    }
    lb_Name.frame = frame;
    
    [cell.contentView addSubview:lb_Name];
    
    
    //날짜
    UILabel *lb_Date = [[UILabel alloc] initWithFrame:CGRectMake(frame.origin.x + frame.size.width + 8, fSampleViewTotalHeight + 8, 0, 15)];
    lb_Date.font = [UIFont fontWithName:@"Helvetica" size:12];
    lb_Date.textColor = [UIColor lightGrayColor];
    
    NSString *str_Date = [NSString stringWithFormat:@"%@", [dic_Info objectForKey_YM:@"createDate"]];
    
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
        frame.origin.x = cell.contentView.frame.size.width - (cell.contentView.frame.size.width - lb_Name.frame.origin.x) - frame.size.width - 6;
    }
    
    lb_Date.frame = frame;
    
    [cell.contentView addSubview:lb_Date];
    
    //글 등록할때 그룹 아이디 넣기
    //등록후 eId를 받아서 조회 api에서 eId를 조회 api를 때려서 배열에 찡겨 넣는다 // 센드버드에 eId를 날려준다
    //조회 api에서 replyId는 부모의 eId 이다
    
    
    //    dic_Info = self.arM_List[indexPath.row];
    
    NSInteger nCurrentGourpId = [[dic_Info objectForKey_YM:@"groupId"] integerValue];
    if( self.arM_QList.count > indexPath.section + 1 )
    {
        NSDictionary *dic = [self.arM_QList objectAtIndex:indexPath.section + 1];
        NSInteger nNextGourpId = [[dic objectForKey_YM:@"groupId"] integerValue];
        
        if( nCurrentGourpId != nNextGourpId )
        {
            UIButton *btn_Reply = [UIButton buttonWithType:UIButtonTypeCustom];
            if( isLeft )
            {
                btn_Reply.frame = CGRectMake(frame.origin.x + frame.size.width + 8, fSampleViewTotalHeight + 5, 50, 20);
            }
            else
            {
                btn_Reply.frame = CGRectMake(frame.origin.x + frame.size.width + 8, fSampleViewTotalHeight + 5, 50, 20);
                
                CGRect frame = btn_Reply.frame;
                frame.origin.x = cell.contentView.frame.size.width - (cell.contentView.frame.size.width - lb_Date.frame.origin.x) - frame.size.width - 6;
                btn_Reply.frame = frame;
            }
            [btn_Reply setTitle:@"답글" forState:UIControlStateNormal];
            [btn_Reply setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
            [btn_Reply setBackgroundColor:[UIColor colorWithHexString:str_Color]];
            [btn_Reply.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
            btn_Reply.layer.cornerRadius = 8.f;
            btn_Reply.tag = indexPath.section;
            [btn_Reply addTarget:self action:@selector(onAddReply:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:btn_Reply];
            
            UIImageView *iv_UnderLine = [[UIImageView alloc] initWithFrame:CGRectMake(15, btn_Reply.frame.origin.y + btn_Reply.frame.size.height + 8,
                                                                                      cell.contentView.frame.size.width - 30, 1)];
            iv_UnderLine.backgroundColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1];
            iv_UnderLine.tag = 678;
            [cell.contentView addSubview:iv_UnderLine];
        }
    }
    else if( self.arM_QList.count == indexPath.section + 1 )
    {
        UIButton *btn_Reply = [UIButton buttonWithType:UIButtonTypeCustom];
        if( isLeft )
        {
            btn_Reply.frame = CGRectMake(frame.origin.x + frame.size.width + 8, fSampleViewTotalHeight + 5, 50, 20);
        }
        else
        {
            btn_Reply.frame = CGRectMake(frame.origin.x + frame.size.width + 8, fSampleViewTotalHeight + 5, 50, 20);
            
            CGRect frame = btn_Reply.frame;
            frame.origin.x = cell.contentView.frame.size.width - (cell.contentView.frame.size.width - lb_Date.frame.origin.x) - frame.size.width - 6;
            btn_Reply.frame = frame;
        }
        [btn_Reply setTitle:@"답글" forState:UIControlStateNormal];
        [btn_Reply setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [btn_Reply setBackgroundColor:[UIColor colorWithHexString:str_Color]];
        [btn_Reply.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
        btn_Reply.layer.cornerRadius = 8.f;
        btn_Reply.tag = indexPath.section;
        [btn_Reply addTarget:self action:@selector(onAddReply:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn_Reply];
        
        UIImageView *iv_UnderLine = [[UIImageView alloc] initWithFrame:CGRectMake(15, btn_Reply.frame.origin.y + btn_Reply.frame.size.height + 8,
                                                                                  cell.contentView.frame.size.width - 30, 1)];
        iv_UnderLine.backgroundColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1];
        iv_UnderLine.tag = 678;
        [cell.contentView addSubview:iv_UnderLine];
    }
    
    
    //다이렉트 질문 여부
    NSString *str_QnaType = [dic_Info objectForKey:@"qnaType"];
    NSString *str_Read = [dic_Info objectForKey:@"isRead"];
    if( [str_QnaType isEqualToString:@"direct"] && [str_Read isEqualToString:@"W"] == NO )
    {
        fSampleViewTotalHeight += 40.f;
        
        //다이렉트 질문이면
        NSString *str_AdminName = [dic_Info objectForKey:@"answerUserName"];
        NSURL *url = [Util createImageUrl:str_UserImagePrefix withFooter:[dic_Info objectForKey:@"answerUserThumbNail"]];
        
        UIImageView *iv_DirectUser = [[UIImageView alloc] initWithFrame:CGRectMake(self.tbv_QList.frame.size.width - 30 - 15, fSampleViewTotalHeight,
                                                                                   30, 30)];
        [iv_DirectUser sd_setImageWithURL:url];
        
        iv_DirectUser.clipsToBounds = YES;
        iv_DirectUser.layer.cornerRadius = iv_DirectUser.frame.size.width / 2;
        iv_DirectUser.layer.borderWidth = 1.f;
        iv_DirectUser.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        [cell.contentView addSubview:iv_DirectUser];
        
        UIButton *btn_Message = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn_Message.backgroundColor = [UIColor redColor];
        btn_Message.frame = CGRectMake(15, fSampleViewTotalHeight, self.tbv_QList.frame.size.width - 70, 30);
        btn_Message.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
//        btn_Message.titleLabel.textAlignment = NSTextAlignmentRight;
        btn_Message.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:14.f];
        [btn_Message setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        if( [str_Read isEqualToString:@"Y"] )
        {
            [btn_Message setImage:BundleImage(@"check_green_small.png") forState:UIControlStateNormal];
            [btn_Message setTitle:[NSString stringWithFormat:@" %@님이 질문을 읽었습니다.", str_AdminName] forState:0];
        }
        else
        {
            [btn_Message setTitle:[NSString stringWithFormat:@" %@님의 답변을 기다리고 있습니다.", str_AdminName] forState:0];
        }
        
        [cell.contentView addSubview:btn_Message];
        
        
        
//        UILabel *lb_DirectMessage = [[UILabel alloc] initWithFrame:CGRectMake(15, fSampleViewTotalHeight,
//                                                                              self.tbv_QList.frame.size.width - 70, 30)];
//        lb_DirectMessage.textAlignment = NSTextAlignmentRight;
//        lb_DirectMessage.font = [UIFont fontWithName:@"Helvetica" size:14.f];
//        lb_DirectMessage.text = [NSString stringWithFormat:@"%@님의 답변을 기다리고 있습니다.", str_AdminName];
//        [cell.contentView addSubview:lb_DirectMessage];
        
        fSampleViewTotalHeight += 30.f;
        fSampleViewTotalHeight += 10.f;
        
        UIImageView *iv_UnderLine = (UIImageView *)[cell.contentView viewWithTag:678];
        CGRect frame = iv_UnderLine.frame;
        frame.origin.y = fSampleViewTotalHeight;
        iv_UnderLine.frame = frame;
    }
}

- (void)onAddDReply:(UIButton *)btn
{
    NSDictionary *dic = self.arM_DList[btn.tag];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    AddDiscripViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"AddDiscripViewController"];
    vc.isQuestionMode = YES;
    vc.str_QnAId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"eId"]];
    vc.str_Idx = self.str_QId;
    [self.vc_Parents presentViewController:vc animated:YES completion:nil];
}


#pragma mark - 채팅관련 함수들
- (void)onAddReply:(UIButton *)btn
{
    //답글달기
    NSDictionary *dic = self.arM_QList[btn.tag];
    dic_SelectedItem = [NSDictionary dictionaryWithDictionary:dic];
    isReplyMode = YES;
    self.v_CommentKeyboardAccView.tv_Contents.placeholder = @"답글하기...";
    [self.v_CommentKeyboardAccView.tv_Contents setNeedsDisplay];
    [self.v_CommentKeyboardAccView.tv_Contents becomeFirstResponder];
}

- (void)userImageTap:(UIGestureRecognizer *)gestureRecognizer
{
    UIImageView *iv = (UIImageView *)gestureRecognizer.view;
    NSDictionary *dic = [self.arM_QList objectAtIndex:iv.tag];
    
    if( [[dic objectForKey:@"userId"] integerValue] == [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue] )
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MyMainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
        vc.isManagerView = YES;
        vc.isPermission = YES;
        vc.isShowNavi = YES;
        vc.str_UserIdx = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
        [self.vc_Parents.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        MyMainViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
        vc.isAnotherUser = YES;
        vc.str_UserIdx = [dic objectForKey:@"userId"];
//        vc.isShowNavi = YES;
        [self.vc_Parents.navigationController pushViewController:vc animated:YES];
    }
}

- (void)imageTap:(UIGestureRecognizer *)gestureRecognizer
{
    UIImageView *iv = (UIImageView *)gestureRecognizer.view;
    UIImage *image = iv.image;
    
    self.ar_Photo = [NSMutableArray array];
    self.thumbs = [NSMutableArray array];
    
    [self.thumbs addObject:[MWPhoto photoWithImage:image]];
    [self.ar_Photo addObject:[MWPhoto photoWithImage:image]];
    
    
    BOOL displayActionButton = NO;
    BOOL displaySelectionButtons = NO;
    BOOL displayNavArrows = YES;
    BOOL enableGrid = NO;
    BOOL startOnGrid = NO;
    
    browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
    browser.displayActionButton = displayActionButton;
    browser.displayNavArrows = displayNavArrows;
    browser.displaySelectionButtons = displaySelectionButtons;
    browser.alwaysShowControls = displaySelectionButtons;
    browser.zoomPhotosToFill = YES;
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_7_0
    browser.wantsFullScreenLayout = YES;
#endif
    browser.enableGrid = enableGrid;
    browser.startOnGrid = startOnGrid;
    browser.enableSwipeToDismiss = YES;
    [browser setCurrentPhotoIndex:0];
    
    UINavigationController *nc = [[UINavigationController alloc] initWithRootViewController:browser];
    nc.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self.vc_Parents presentViewController:nc animated:YES completion:nil];
    
    // Release
    
    // Test reloading of data after delay
    double delayInSeconds = 3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    });
    
    self.hidden = NO;
    self.alpha = YES;
}

- (void)cellTap:(UIGestureRecognizer *)gesture
{
    [self endEditing:YES];
}

- (void)handleLongPressGestures:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        [self endEditing:YES];
        
        UIView *view = (UIView *)gesture.view;
        NSDictionary *dic = self.arM_QList[view.tag];
        NSString *str_Type = [dic objectForKey:@"itemType"];
        NSString *str_WriteUserId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]];
        NSString *str_MyUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
        
        if( [str_WriteUserId integerValue] == [str_MyUserId integerValue] )
        {
            //내가 쓴 글
            if( [str_Type isEqualToString:@"qna"] )
            {
                //질문일 경우 아래 달린 댓글도 삭제
                [self deleteQna:view.tag withDType:NO];
            }
            else
            {
                //답변일 경우
                [self deleteReply:view.tag];
            }
        }
        else
        {
            //다른 사람이 쓴 글
            [self report:view.tag withDType:NO];
        }
    }
}

- (void)report:(NSInteger)nTag withDType:(BOOL)isDType
{
    NSDictionary *dic = isDType ? self.arM_DList[nTag] : self.arM_QList[nTag];

    BOOL isReport = [[dic objectForKey:@"isReport"] integerValue];
    if( isReport != NO )
    {
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        [window makeToast:@"이미 신고하셨습니다." withPosition:kPositionCenter];
        return;
    }
    
    NSMutableArray *arM = [NSMutableArray array];
    [arM addObject:@"신고하기"];
    
    [OHActionSheet showSheetInView:self
                             title:nil
                 cancelButtonTitle:@"취소"
            destructiveButtonTitle:nil
                 otherButtonTitles:arM
                        completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
     {
         if( buttonIndex == 0 )
         {
             //신고하기
             UIAlertView *alert = CREATE_ALERT(nil, @"해당 게시글을 신고하시겠습니까?", @"확인", @"취소");
             [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                 
                 if( buttonIndex == 0 )
                 {
                     NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                         [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                         [Util getUUID], @"uuid",
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
                                                             UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                                                             NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                             if( nCode == 200 )
                                                             {
                                                                 [window makeToast:@"신고 되었습니다." withPosition:kPositionCenter];
                                                             }
                                                             else
                                                             {
                                                                 [window makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                             }
                                                         }
                                                     }];
                 }
             }];
         }
     }];
}

- (void)deleteQna:(NSInteger)nTag withDType:(BOOL)isDType
{
    __block NSDictionary *dic = isDType ? self.arM_DList[nTag] : self.arM_QList[nTag];
    
    NSMutableArray *arM = [NSMutableArray array];
    [arM addObject:@"삭제하기"];
    
    [OHActionSheet showSheetInView:self
                             title:nil
                 cancelButtonTitle:@"취소"
            destructiveButtonTitle:nil
                 otherButtonTitles:arM
                        completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
     {
         if( buttonIndex == 0 )
         {
             UIAlertView *alert = CREATE_ALERT(nil, @"해당 게시글을 삭제하시겠습니까?", @"확인", @"취소");
             [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                 
                 if( buttonIndex == 0 )
                 {
                     NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                         [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                         [Util getUUID], @"uuid", 
                                                         self.str_QId, @"questionId",
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
//                                                                 NSInteger nGroupId = [[dic objectForKey:@"groupId"] integerValue];
                                                                 NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"eId":[NSString stringWithFormat:@"%@", [dic objectForKey:@"eId"]]}
                                                                                                                    options:NSJSONWritingPrettyPrinted
                                                                                                                      error:&error];
                                                                 NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                                 
//                                                                 [SendBird sendMessage:@"delete-qna" withData:jsonString];
                                                             }
                                                             else
                                                             {
                                                                 [weakSelf makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                             }
                                                         }
                                                     }];
                 }
             }];
             
         }
     }];
}

- (void)deleteReply:(NSInteger)nTag
{
    __block NSDictionary *dic = self.arM_QList[nTag];
    
    NSMutableArray *arM = [NSMutableArray array];
    [arM addObject:@"삭제하기"];
    
    [OHActionSheet showSheetInView:self
                             title:nil
                 cancelButtonTitle:@"취소"
            destructiveButtonTitle:nil
                 otherButtonTitles:arM
                        completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
     {
         if( buttonIndex == 0 )
         {
             UIAlertView *alert = CREATE_ALERT(nil, @"해당 댓글을 삭제하시겠습니까?", @"확인", @"취소");
             [alert showWithCompletion:^(UIAlertView *alertView, NSInteger buttonIndex) {
                 
                 if( buttonIndex == 0 )
                 {
                     NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                         [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                         [Util getUUID], @"uuid",
                                                         self.str_QId, @"questionId",
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
                                                                 NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"eId":[NSString stringWithFormat:@"%@", [dic objectForKey:@"eId"]]}
                                                                                                                    options:NSJSONWritingPrettyPrinted
                                                                                                                      error:&error];
                                                                 NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                                 
//                                                                 [SendBird sendMessage:@"delete-reply" withData:jsonString];
                                                             }
                                                             else
                                                             {
                                                                 [weakSelf makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                             }
                                                         }
                                                     }];
                 }
             }];
             
         }
     }];
}


- (void)onPlayMove:(YmExtendButton *)btn
{
    NSURL *URL = btn.obj;
    
    MPMoviePlayerViewController *vc_Movie = [[MPMoviePlayerViewController alloc]initWithContentURL:URL];
    vc_Movie.moviePlayer.repeatMode = MPMovieRepeatModeOne;
    vc_Movie.moviePlayer.movieSourceType = MPMovieSourceTypeStreaming;
    vc_Movie.moviePlayer.controlStyle = MPMovieControlStyleFullscreen;
    vc_Movie.moviePlayer.shouldAutoplay = NO;
    vc_Movie.moviePlayer.repeatMode = NO;
    [vc_Movie.moviePlayer setFullscreen:NO animated:NO];
    [vc_Movie.moviePlayer prepareToPlay];
    [vc_Movie.moviePlayer play];
    
    [self.vc_Parents presentViewController:vc_Movie animated:YES completion:^{
        
        self.hidden = NO;
        self.alpha = YES;
    }];
}

#pragma mark - MWPhotoBrowserDelegate
- (NSUInteger)numberOfPhotosInPhotoBrowser:(MWPhotoBrowser *)photoBrowser
{
    return _ar_Photo.count;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser photoAtIndex:(NSUInteger)index
{
    if (index < _ar_Photo.count)
        return [_ar_Photo objectAtIndex:index];
    return nil;
}

- (id <MWPhoto>)photoBrowser:(MWPhotoBrowser *)photoBrowser thumbPhotoAtIndex:(NSUInteger)index
{
    if (index < _thumbs.count)
    {
        return [_thumbs objectAtIndex:index];
    }
    return nil;
}
- (void)photoBrowserDidFinishModalPresentation:(MWPhotoBrowser *)photoBrowser
{
    [browser dismissViewControllerAnimated:YES completion:^{
        
    }];
    self.hidden = NO;
    self.alpha = YES;
}
#pragma mark -

- (void)configureCell:(QuestionListCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath withAddMode:(BOOL)isAdd
{
    for( UIView *subView in cell.contentView.subviews )
    {
        [subView removeFromSuperview];
    }
    
    __block CGFloat fSampleViewTotalHeight = 12;
    
    NSDictionary *dic_Info = self.arM_DList[indexPath.section];
    
    NSString *str_ItemType = [dic_Info objectForKey:@"itemType"];
    NSArray *ar = nil;
    BOOL isDiscrip = [str_ItemType isEqualToString:@"explain"];
    NSInteger nX = 15;
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
            UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(nX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (nX * 2), 0)];
            lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(lb_Contents.frame);
            lb_Contents.font = [UIFont fontWithName:@"Helvetica" size:20.f];
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
            
            UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(nX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (nX * 2), rect.size.height)];
            lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(lb_Contents.frame);
            lb_Contents.font = [UIFont fontWithName:@"Helvetica" size:20.f];
            lb_Contents.numberOfLines = 0;
            lb_Contents.text = attrStr.string;
//            lb_Contents.attributedText = attrStr;
            
            CGRect frame = lb_Contents.frame;
            frame.size.height = [Util getTextSize:lb_Contents].height;
            lb_Contents.frame = frame;

            if( isAdd )
            {
                [cell.contentView addSubview:lb_Contents];
            }
            
            fSampleViewTotalHeight += lb_Contents.frame.size.height + 20;
        }
        else if( [str_Type isEqualToString:@"image"] )
        {
            //            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(nX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (nX * 2), 0)];
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
            
            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(nX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (nX * 2), 0)];
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
            
            fSampleViewTotalHeight += iv.frame.size.height + 20;
            
        }
        else if( [str_Type isEqualToString:@"videoLink"] )
        {
            self.playerView = [[YTPlayerView alloc] initWithFrame:
                               CGRectMake(nX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (nX * 2), (cell.contentView.frame.size.width - (nX * 2)) * 0.7f)];
            
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
            
            fSampleViewTotalHeight += self.playerView.frame.size.height + 20;
            
            
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
            frame.size.width = self.bounds.size.width;
            frame.size.height = 48;
            self.v_Audio.frame = frame;
            
            if( isAdd )
            {
                [cell.contentView addSubview:self.v_Audio];
            }
            
            fSampleViewTotalHeight += self.v_Audio.frame.size.height + 20;
        }
        else if( [str_Type isEqualToString:@"video"] )
        {
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(nX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (nX * 2), (cell.contentView.frame.size.width - (nX * 2)) * 0.7f)];
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
            
            
            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(nX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (nX * 2), 0)];
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
            
            fSampleViewTotalHeight += iv.frame.size.height + 20;
            
            
            
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
    
    
    
    
    
    NSDictionary *dic = self.arM_DList[indexPath.section];
    
    UIButton *btn_ThumUp = [UIButton buttonWithType:UIButtonTypeCustom];
    UIButton *btn_ThumDown = [UIButton buttonWithType:UIButtonTypeCustom];
    
    btn_ThumUp.frame = CGRectMake(self.bounds.size.width - ((45*2)+10+15), fSampleViewTotalHeight, 44, 28);
    btn_ThumDown.frame = CGRectMake(self.bounds.size.width - (45+15), fSampleViewTotalHeight, 44, 28);
    
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
        [btn_Reply addTarget:self action:@selector(onAddDReply:) forControlEvents:UIControlEventTouchUpInside];
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

- (void)onReport:(UIButton *)btn
{
    [self report:btn.tag withDType:YES];
}

- (void)onDelete:(UIButton *)btn
{
    [self deleteQna:btn.tag withDType:YES];
}

- (void)onThumbUp:(UIButton *)btn
{
    NSDictionary *dic = self.arM_DList[btn.tag];
    [self sendLike:[NSString stringWithFormat:@"%@", [dic objectForKey:@"eId"]] withStatus:@"up" withObj:btn withDic:dic];
}

- (void)onThumbDown:(UIButton *)btn
{
    NSDictionary *dic = self.arM_DList[btn.tag];
    [self sendLike:[NSString stringWithFormat:@"%@", [dic objectForKey:@"eId"]] withStatus:@"down" withObj:btn withDic:dic];
}

- (void)sendLike:(NSString *)aId withStatus:(NSString *)aStatus withObj:(UIButton *)btn withDic:(NSDictionary *)dic
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_QId, @"questionId",
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
                                                
                                                NSMutableArray *arM = [NSMutableArray arrayWithArray:weakSelf.arM_DList];
                                                [arM replaceObjectAtIndex:btn.tag withObject:dicM];
                                                weakSelf.arM_DList = [NSMutableArray arrayWithArray:arM];
                                                
                                                NSIndexPath* rowToReload = [NSIndexPath indexPathForRow:0 inSection:btn.tag];
                                                NSArray* rowsToReload = [NSArray arrayWithObjects:rowToReload, nil];
                                                [weakSelf.tbv_DList reloadRowsAtIndexPaths:rowsToReload withRowAnimation:UITableViewRowAnimationNone];
                                            }
                                            else
                                            {
                                                [weakSelf makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

- (void)onAddQuestion:(UIButton *)btn
{
    if( self.v_CommentKeyboardAccView.tv_Contents.text.length <= 0 )    return;

    [self upLoadContents:nil];



//    for( NSInteger i = 0; i < self.arM_List.count; i++ )
//    {
//        NSDictionary *dic = self.arM_List[i];
//        
//        if( [[dic objectForKey:@"type"] isEqualToString:@"text"] )
//        {
//            [strM appendString:@"0"];
//            [strM appendString:@"-"];
//            
//            [strM appendString:[dic objectForKey:@"type"]];
//            [strM appendString:@"-"];
//            
//            [strM appendString:@"0"];
//            [strM appendString:@"-"];
//            
//            [strM appendString:@"N"];
//            [strM appendString:@"-"];
//            
//            //            [strM appendString:[dic objectForKey:@"obj"]];
//            
//            NSString *str_Tmp = [dic objectForKey:@"obj"];
//            str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"%" withString:@"%25"];
//            str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"-" withString:@"%2D"];
//            str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
//            str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
//            
//            //[]{}#%^*+=_/
//            [strM appendString:str_Tmp];
//            
//            //            NSString *str_Text = [str_Tmp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//            //            if( str_Text == nil )
//            //            {
//            //                [strM appendString:str_Tmp];
//            //            }
//            //            else
//            //            {
//            //                [strM appendString:str_Text];
//            //            }
//        }
//        else
//        {
//            [strM appendString:@"0"];
//            [strM appendString:@"-"];
//            
//            [strM appendString:[dic objectForKey:@"type"]];
//            [strM appendString:@"-"];
//            
//            [strM appendString:[NSString stringWithFormat:@"%@", [dic objectForKey:@"tempUploadId"]]];
//            [strM appendString:@"-"];
//            
//            [strM appendString:@"N"];
//            [strM appendString:@"-"];
//            
//            [strM appendString:[dic objectForKey:@"serviceUrl"]];
//        }
//        
//        [strM appendString:@","];
//    }
    
    
//    //stringByAddingPercentEscapesUsingEncoding
//    //stringByReplacingPercentEscapesUsingEncoding
//    NSString *str_Contents = [NSString stringWithString:strM];
//    //    NSString *str_Contents = [str_Tmp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
//    //    if( str_Contents == nil )
//    //    {
//    //        str_Contents = str_Tmp;
//    //    }
//    
//    NSString *str_Path = @"";
//    NSMutableDictionary *dicM_Params = nil;
//    
//    str_Path = @"v1/add/reply/question";
//    dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                   [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                   [Util getUUID], @"uuid",
//                   self.str_QId, @"questionId",
//                   str_Contents, @"replyContents",
//                   self.str_QnAId ? @"replay" : @"qna", @"replyType",   //질문, 답변 여부 [qna-질문, replay-답글)
//                   self.str_QnAId ? self.str_QnAId : @"0", @"replyId",     // [질문일 경우 0, 답변일 경우 해당 질문의 qnaId]
//                   //                       self.str_GroupId ? self.str_GroupId : @"0", @"groupId",  //groupId: 답변인 경우 첫 질문의 eId값 (질문인 경우 0)
//                   nil];
//    
//    
//    
//    __weak __typeof(&*self)weakSelf = self;
//    
//    [[WebAPI sharedData] callAsyncWebAPIBlock:str_Path
//                                        param:dicM_Params
//                                   withMethod:@"POST"
//                                    withBlock:^(id resulte, NSError *error) {
//                                        
//                                        [MBProgressHUD hide];
//                                        
//                                        self.v_CommentKeyboardAccView.btn_Done.userInteractionEnabled = YES;
//
//                                        if( resulte )
//                                        {
//                                            NSLog(@"resulte : %@", resulte);
//                                            
//                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
//                                            if( nCode == 200 )
//                                            {
//                                                //전송완료 후 센드버드 메세지 호출
//                                                if( self.str_QnAId == nil )
//                                                {
//                                                    //새로운 질문
//                                                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"questionId":[resulte objectForKey:@"questionId"],
//                                                                                                                 @"eId":[resulte objectForKey:@"qnaId"]}
//                                                                                                       options:NSJSONWritingPrettyPrinted
//                                                                                                         error:&error];
//                                                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//                                                    
//                                                    [SendBird sendMessage:@"regist-qna" withData:jsonString];
//                                                }
//                                                else
//                                                {
//                                                    //새로운 답글
//                                                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"questionId":[resulte objectForKey:@"questionId"],
//                                                                                                                 @"eId":[resulte objectForKey:@"qnaId"],
//                                                                                                                 @"replyId":self.str_QnAId}
//                                                                                                       options:NSJSONWritingPrettyPrinted
//                                                                                                         error:&error];
//                                                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//                                                    
//                                                    [SendBird sendMessage:@"regist-reply" withData:jsonString];
//                                                }
//                                                
//                                                weakSelf.v_CommentKeyboardAccView.tv_Contents.text = @"";
//                                                [weakSelf performSelectorOnMainThread:@selector(onKeyboardDown) withObject:nil waitUntilDone:YES];
//                                                
//                                            }
//                                            else
//                                            {
//                                                [weakSelf makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
//                                            }
//                                        }
//                                    }];
}

- (void)onKeyboardDown
{
    [self endEditing:YES];
    self.v_CommentKeyboardAccView.lc_Height.constant = 45.f;
}


- (void)onTakeFile
{
    [self endEditing:YES];
    
    [OHActionSheet showSheetInView:self
                             title:nil
                 cancelButtonTitle:@"취소"
            destructiveButtonTitle:nil
                 otherButtonTitles:@[@"라이브러리", @"사진(카메라)", @"동영상(카메라)"]
                        completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
     {
         if( buttonIndex == 0 )
         {
             UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
             imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
             imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, kUTTypeImage, nil];
             imagePickerController.delegate = self;
             imagePickerController.allowsEditing = NO;
             
             if(IS_IOS8_OR_ABOVE)
             {
//                 [self addSubview:imagePickerController.view];
                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                     [self.vc_Parents presentViewController:imagePickerController animated:YES completion:nil];
                 }];
             }
             else
             {
                 [self.vc_Parents presentViewController:imagePickerController animated:YES completion:nil];
             }
         }
         else if( buttonIndex == 1 )
         {
             UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
             imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
             imagePickerController.delegate = self;
             imagePickerController.allowsEditing = NO;
             
             if(IS_IOS8_OR_ABOVE)
             {
                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                     [self.vc_Parents presentViewController:imagePickerController animated:YES completion:nil];
                 }];
             }
             else
             {
                 [self.vc_Parents presentViewController:imagePickerController animated:YES completion:nil];
             }
         }
         else if( buttonIndex == 2 )
         {
             UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
             imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
             imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
             imagePickerController.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
             imagePickerController.delegate = self;
             
             //             UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
             //             imagePickerController.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;
             //             imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
             ////             imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, nil];
             //             imagePickerController.delegate = self;
             //             imagePickerController.allowsEditing = YES;
             
             if(IS_IOS8_OR_ABOVE)
             {
                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                     [self.vc_Parents presentViewController:imagePickerController animated:YES completion:nil];
                 }];
             }
             else
             {
                 [self.vc_Parents presentViewController:imagePickerController animated:YES completion:nil];
             }
         }
     }];
}

#pragma mark - ImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSString *mediaType = [info objectForKey: UIImagePickerControllerMediaType];
    
    if (CFStringCompare ((__bridge CFStringRef) mediaType, kUTTypeMovie, 0) == kCFCompareEqualTo)
    {
        NSURL *videoUrl=(NSURL*)[info objectForKey:UIImagePickerControllerMediaURL];
        
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
        AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
        gen.appliesPreferredTrackTransform = YES;
        CMTime time = CMTimeMakeWithSeconds(0.0, 1);
        NSError *error = nil;
        CMTime actualTime;
        
        CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
        UIImage *thumb = [[UIImage alloc] initWithCGImage:image];
        
        UIImage *resizeImage = [Util imageWithImage:thumb convertToWidth:self.bounds.size.width - 30];
        
        NSData *videoData = [NSData dataWithContentsOfURL:videoUrl];
        [self uploadData:@{@"type":@"video", @"obj":videoData, @"thumb":resizeImage}];
    }
    else
    {
        UIImage* outputImage = [info objectForKey:UIImagePickerControllerEditedImage] ? [info objectForKey:UIImagePickerControllerEditedImage] : [info objectForKey:UIImagePickerControllerOriginalImage];
        
        UIImage *resizeImage = [Util imageWithImage:outputImage convertToWidth:self.bounds.size.width - 30];
        [self uploadData:@{@"type":@"image", @"obj":UIImageJPEGRepresentation(resizeImage, 0.3f), @"thumb":resizeImage}];
    }
    
    [self.vc_Parents dismissViewControllerAnimated:YES completion:^{
        
    }];
    
    self.hidden = NO;
    self.alpha = YES;
}






//////////////////////








- (void)uploadData:(NSDictionary *)dic
{
    self.v_CommentKeyboardAccView.btn_Done.userInteractionEnabled = NO;

    __weak __typeof__(self) weakSelf = self;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.str_QId, @"questionId",
                                        @"reply", @"uploadItem",
                                        [dic objectForKey:@"type"], @"type",
                                        nil];
    
    [[WebAPI sharedData] imageUpload:@"v1/attach/file/uploader"
                               param:dicM_Params
                          withImages:[NSDictionary dictionaryWithObject:[dic objectForKey:@"obj"] forKey:@"file"]
                           withBlock:^(id resulte, NSError *error) {
                               
                               self.v_CommentKeyboardAccView.btn_Done.userInteractionEnabled = YES;
                               
                               if( resulte )
                               {
                                   NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                   if( nCode == 200 )
                                   {
                                       [self upLoadContents:@{@"type" : [dic objectForKey:@"type"],
                                                              @"tempUploadId" : [resulte objectForKey:@"tempUploadId"],
                                                              @"serviceUrl" : [resulte objectForKey:@"serviceUrl"]}];
                                   }
                                   else
                                   {
                                       [self makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                   }
                               }
                               else
                               {
                                   [self makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                               }
                           }];
}

- (void)upLoadContents:(NSDictionary *)dic
{
    self.v_CommentKeyboardAccView.btn_Done.userInteractionEnabled = NO;

    NSMutableString *strM = [NSMutableString string];
    
    if( dic )
    {
        [strM appendString:@"0"];
        [strM appendString:@"-"];
        
        [strM appendString:[dic objectForKey:@"type"]];
        [strM appendString:@"-"];
        
        [strM appendString:[NSString stringWithFormat:@"%@", [dic objectForKey:@"tempUploadId"]]];
        [strM appendString:@"-"];
        
        [strM appendString:@"N"];
        [strM appendString:@"-"];
        
        [strM appendString:[dic objectForKey:@"serviceUrl"]];
    }
    else
    {
        [strM appendString:@"0"];
        [strM appendString:@"-"];
        
        [strM appendString:@"text"];
        [strM appendString:@"-"];
        
        [strM appendString:@"0"];
        [strM appendString:@"-"];
        
        [strM appendString:@"N"];
        [strM appendString:@"-"];
        
        NSString *str_Tmp = self.v_CommentKeyboardAccView.tv_Contents.text;
        str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"%" withString:@"%25"];
        str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"-" withString:@"%2D"];
        str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"," withString:@"%2C"];
        str_Tmp = [str_Tmp stringByReplacingOccurrencesOfString:@"+" withString:@"%2B"];
        
        //[]{}#%^*+=_/
        [strM appendString:str_Tmp];
    }
    
    if( [strM hasSuffix:@","] )
    {
        [strM deleteCharactersInRange:NSMakeRange([strM length]-1, 1)];
    }

    NSString *str_Contents = [NSString stringWithString:strM];
    //    NSString *str_Contents = [str_Tmp stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    //    if( str_Contents == nil )
    //    {
    //        str_Contents = str_Tmp;
    //    }
    
    NSString *str_Path = @"";
    NSMutableDictionary *dicM_Params = nil;
    //    groupId = 12734;
    str_Path = @"v1/add/reply/question/and/view";
    dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                   [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                   [Util getUUID], @"uuid",
                   self.str_QId, @"questionId",
                   str_Contents, @"replyContents",
                   isReplyMode ? @"replay" : @"qna", @"replyType",   //질문, 답변 여부 [qna-질문, replay-답글)
                   isReplyMode ? [NSString stringWithFormat:@"%@", [dic_SelectedItem objectForKey:@"groupId"]] : @"0", @"replyId",     // [질문일 경우 0, 답변일 경우 해당 질문의 qnaId]
                   //                       self.str_GroupId ? self.str_GroupId : @"0", @"groupId",  //groupId: 답변인 경우 첫 질문의 eId값 (질문인 경우 0)
                   self.str_ExamId, @"examId",  //20170424 examId를 넘겨달라고 제권님이 요청함
                   nil];
    
    NSString *str_Key = [NSString stringWithFormat:@"DefaultChannelId_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSString *str_DefaultChannelId = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
    if( str_DefaultChannelId && str_DefaultChannelId.length > 0 )
    {
        [dicM_Params setObject:str_DefaultChannelId forKey:@"managerChannelId"];
    }

    if( isReplyMode == NO )
    {
        //답글이 아닐 경우만 다이렉트 질문 가능
        
        for( id subView in self.sv_Admin.subviews )
        {
            if( [subView isKindOfClass:[UIImageView class]] )
            {
                UIImageView *iv_Sub = (UIImageView *)subView;
                {
                    UIColor *color = [[UIColor alloc] initWithCGColor:iv_Sub.layer.borderColor];
                    if( iv_Sub.tag > 0 && iv_Sub.alpha > 0 && [color isEqual:[UIColor redColor]] )
                    {
                        [dicM_Params setObject:[NSString stringWithFormat:@"%ld", iv_Sub.tag] forKey:@"toUserId"];
                        break;
                    }
                }
            }
        }
        
        
        
//        BOOL isFirst = YES;
//        for( id subView in self.sv_Admin.subviews )
//        {
//            if( [subView isKindOfClass:[UIImageView class]] )
//            {
//                UIImageView *iv_Sub = (UIImageView *)subView;
//                if( iv_Sub.tag > 0 && iv_Sub.alpha < 1 )
//                {
//                    isFirst = NO;
//                }
//            }
//        }
//
//        for( id subView in self.sv_Admin.subviews )
//        {
//            if( [subView isKindOfClass:[UIImageView class]] )
//            {
//                UIImageView *iv_Sub = (UIImageView *)subView;
//                if( iv_Sub.tag > 0 && iv_Sub.alpha == YES && isFirst == NO )
//                {
//                    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", iv_Sub.tag] forKey:@"toUserId"];
//                }
//            }
//        }
    }

    
    if( isReplyMode )
    {
        [dicM_Params setObject:[NSString stringWithFormat:@"%@", [dic_SelectedItem objectForKey:@"groupId"]] forKey:@"groupId"];
    }
    
    BOOL isReply = isReplyMode;
    isReplyMode = NO;
    self.v_CommentKeyboardAccView.tv_Contents.placeholder = @"질문하기";
    [self.v_CommentKeyboardAccView.tv_Contents setNeedsDisplay];

    __weak __typeof(&*self)weakSelf = self;
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:str_Path
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
                                        self.v_CommentKeyboardAccView.btn_Done.userInteractionEnabled = YES;
                                        
                                        //글 등록 후면 기본값인 진한색으로 변경
                                        for( id subView in self.sv_Admin.subviews )
                                        {
                                            if( [subView isKindOfClass:[UIImageView class]] )
                                            {
                                                UIImageView *iv_Sub = (UIImageView *)subView;
                                                if( iv_Sub.tag > 0 )
                                                {
                                                    iv_Sub.alpha = YES;;
                                                    iv_Sub.layer.borderColor = [UIColor clearColor].CGColor;
                                                }
                                            }
                                        }

                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                //전송완료 후 센드버드 메세지 호출
                                                //새로운 질문
                                                
                                                if( isReply )
                                                {
                                                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"questionId":[resulte objectForKey:@"questionId"],
                                                                                                                 @"eId":[resulte objectForKey:@"qnaId"],
                                                                                                                 @"replyId":[NSString stringWithFormat:@"%@", [dic_SelectedItem objectForKey:@"groupId"]],
                                                                                                                 @"userId":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],
                                                                                                                 @"result":resulte}
                                                                                                       options:NSJSONWritingPrettyPrinted
                                                                                                         error:&error];
                                                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                    
//                                                    [SendBird sendMessage:@"regist-reply" withData:jsonString];
                                                }
                                                else
                                                {
                                                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"questionId":[resulte objectForKey:@"questionId"],
                                                                                                                 @"eId":[resulte objectForKey:@"qnaId"],
                                                                                                                 @"userId":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"],
                                                                                                                 @"result":resulte}

                                                                                                       options:NSJSONWritingPrettyPrinted
                                                                                                         error:&error];
                                                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//                                                    [SendBird sendMessage:@"regist-qna" withData:jsonString];
                                                }
                                                
                                                
                                                BOOL isLastObj = YES;
                                                
                                                if( isReply )
                                                {
                                                    for( NSInteger i = 0; i < weakSelf.arM_QList.count; i++ )
                                                    {
                                                        NSDictionary *dic_Sub = weakSelf.arM_QList[i];
                                                        NSInteger nEId = [[dic_Sub objectForKey:@"groupId"] integerValue];
                                                        NSInteger nParentEid = [[dic_SelectedItem objectForKey:@"groupId"] integerValue];
                                                        if( nEId == nParentEid )
                                                        {
                                                            NSInteger nPK = i;
                                                            for( NSInteger j = nPK; j < weakSelf.arM_QList.count; j++ )
                                                            {
                                                                NSDictionary *dic_Sub2 = weakSelf.arM_QList[j];
                                                                NSInteger nGroupId = [[dic_Sub2 objectForKey:@"groupId"] integerValue];
                                                                if( nGroupId != nParentEid )
                                                                {
                                                                    isLastObj = NO;
                                                                    nPK = j;
                                                                    break;
                                                                }
                                                            }
                                                            
                                                            if( isLastObj )
                                                            {
                                                                NSDictionary *dic_Tmp = [weakSelf.arM_QList lastObject];
                                                                NSInteger nPrevReplyIdx = [[dic_Tmp objectForKey:@"replyInx"] integerValue];
                                                                
                                                                NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:resulte];
                                                                [dicM setObject:[NSString stringWithFormat:@"%ld", ++nPrevReplyIdx] forKey:@"replyInx"];
                                                                
                                                                [weakSelf.arM_QList addObject:resulte];
                                                                
//                                                                if( weakSelf.updateCountBlock )
//                                                                {
//                                                                    [weakSelf.seg setTitle:[NSString stringWithFormat:@"문제풀이 %ld", weakSelf.arM_DList.count] forSegmentAtIndex:0];
//
//                                                                    if( [[resulte objectForKey:@"itemType"] isEqualToString:@"qna"] )
//                                                                    {
//                                                                        nQTotalCnt++;
//                                                                        [weakSelf.seg setTitle:[NSString stringWithFormat:@"질문 %ld", nQTotalCnt] forSegmentAtIndex:1];
//                                                                    }
//                                                                    
//                                                                    weakSelf.updateCountBlock([NSString stringWithFormat:@"%ld", weakSelf.arM_DList.count + nQTotalCnt]);
//                                                                }
                                                            }
                                                            else
                                                            {
                                                                NSDictionary *dic_Tmp = [weakSelf.arM_QList objectAtIndex:nPK - 1];
                                                                NSInteger nPrevReplyIdx = [[dic_Tmp objectForKey:@"replyInx"] integerValue];
                                                                
                                                                NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:resulte];
                                                                [dicM setObject:[NSString stringWithFormat:@"%ld", ++nPrevReplyIdx] forKey:@"replyInx"];
                                                                
                                                                [weakSelf.arM_QList insertObject:dicM atIndex:nPK];
                                                            }
                                                            break;
                                                        }
                                                    }
                                                    
                                                    //혹시라도 같은게 있으면 빼주기 (중복되어 올라오는 현상에 대한 방어코드)
                                                    for( NSInteger i = 0; i < weakSelf.arM_QList.count - 1; i++ )
                                                    {
                                                        NSDictionary *dic_Current = weakSelf.arM_QList[i];
                                                        NSDictionary *dic_Next = weakSelf.arM_QList[i + 1];
                                                        
                                                        if( [[dic_Current objectForKey_YM:@"eId"] integerValue] == [[dic_Next objectForKey_YM:@"eId"] integerValue] )
                                                        {
                                                            [weakSelf.arM_QList removeObjectAtIndex:i + 1];
                                                            break;
                                                        }
                                                    }
                                                    
                                                    [weakSelf.tbv_QList reloadData];
                                                    
//                                                    if( isLastObj )
//                                                    {
//                                                        if (weakSelf.tbv_List.contentSize.height > weakSelf.tbv_List.frame.size.height)
//                                                        {
//                                                            CGPoint offset = CGPointMake(0, weakSelf.tbv_List.contentSize.height - weakSelf.tbv_List.frame.size.height);
//                                                            [weakSelf.tbv_List setContentOffset:offset animated:YES];
//                                                        }
//                                                    }
                                                }
                                                else
                                                {
                                                    [weakSelf.arM_QList addObject:resulte];
                                                    [weakSelf.tbv_QList reloadData];
                                                    
//                                                    if( weakSelf.updateCountBlock )
//                                                    {
//                                                        [weakSelf.seg setTitle:[NSString stringWithFormat:@"문제풀이 %ld", weakSelf.arM_DList.count] forSegmentAtIndex:0];
//                                                        if( [[resulte objectForKey:@"itemType"] isEqualToString:@"qna"] )
//                                                        {
//                                                            nQTotalCnt++;
//                                                            [weakSelf.seg setTitle:[NSString stringWithFormat:@"질문 %ld", nQTotalCnt] forSegmentAtIndex:1];
//                                                        }
//                                                        
//                                                        weakSelf.updateCountBlock([NSString stringWithFormat:@"%ld", weakSelf.arM_DList.count + nQTotalCnt]);
//                                                    }

//                                                    if (weakSelf.tbv_List.contentSize.height > weakSelf.tbv_List.frame.size.height)
//                                                    {
//                                                        CGPoint offset = CGPointMake(0, weakSelf.tbv_List.contentSize.height - weakSelf.tbv_List.frame.size.height);
//                                                        [weakSelf.tbv_List setContentOffset:offset animated:YES];
//                                                    }
                                                }
                                                
                                                [self scrollToTheBottom:YES];
                                            }
                                            else
                                            {
                                                [weakSelf makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                            
                                            weakSelf.v_CommentKeyboardAccView.tv_Contents.text = @"";
                                            [weakSelf performSelector:@selector(onKeyboardDown) withObject:nil afterDelay:0.1f];
//                                            [weakSelf endEditing:YES];
//                                            weakSelf.v_CommentKeyboardAccView.lc_Height.constant = 45.f;

//                                            [weakSelf performSelectorOnMainThread:@selector(onKeyboardDown) withObject:nil waitUntilDone:YES];
                                        }
                                    }];
}

//- (IBAction)goTouchComment:(id)sender
//{
//    if( self.lc_BottomViewBottom.constant == 0 )
//    {
//        //상단이였으면 중단으로 변경
//        //중단
//        CGFloat fThreeHeight = self.frame.size.height / 3;
//        [UIView animateWithDuration:0.3f animations:^{
//            
//            self.iv_Bg.alpha = 0.7f;
//            self.lc_BottomViewBottom.constant = (fThreeHeight + (73 / 2)) * -1;
//            self.lc_BgTop.constant = 29.f;
//            self.lc_CommentX.constant = self.frame.size.width / 2 - (self.btn_Comment.frame.size.width/2);
//            self.btn_Back.alpha = self.btn_AddDiscrip.alpha = self.seg.alpha = NO;
//            
//            if( self.completionBlock )
//            {
//                self.completionBlock(@{@"alpha" : @0, @"animation" : @YES, @"IsTop" : @NO});
//            }
//            
//            [self.superview layoutIfNeeded];
//        }];
//        
//        str_OldPosition = @"up";
//    }
//    else if( self.lc_BottomViewBottom.constant == (self.frame.size.height - 73) * -1 )
//    {
//        //하단이였으면 중단으로
//        //중단
//        CGFloat fThreeHeight = self.frame.size.height / 3;
//        [UIView animateWithDuration:0.3f animations:^{
//            
//            self.iv_Bg.alpha = 0.7f;
//            self.lc_BottomViewBottom.constant = (fThreeHeight + (73 / 2)) * -1;
//            self.lc_BgTop.constant = 29.f;
//            self.lc_CommentX.constant = self.frame.size.width / 2 - (self.btn_Comment.frame.size.width/2);
//            self.btn_Back.alpha = self.btn_AddDiscrip.alpha = self.seg.alpha = NO;
//            
//            if( self.completionBlock )
//            {
//                self.completionBlock(@{@"alpha" : @0, @"animation" : @YES, @"IsTop" : @NO});
//            }
//            
//            [self.superview layoutIfNeeded];
//        }];
//        
//        str_OldPosition = @"down";
//    }
//    else
//    {
//        if( [str_OldPosition isEqualToString:@"up"] )
//        {
//            //하단
//            self.lc_BottomViewBottom.constant = (self.frame.size.height - (73 + (self.isNavi ? 64 : 0))) * -1;
//            
//            [UIView animateWithDuration:0.3f animations:^{
//                
//                [self.superview layoutIfNeeded];
//            }];
//            
//            [UIView animateWithDuration:0.1f animations:^{
//                
//                self.iv_Bg.alpha = 0.0f;
//                self.lc_BgTop.constant = 29.f;
//                self.btn_Back.alpha = self.btn_AddDiscrip.alpha = self.seg.alpha = NO;
//                fOriginalBottom = self.lc_BottomViewBottom.constant;
//                
//                if( self.completionBlock )
//                {
//                    self.completionBlock(@{@"alpha" : @1, @"animation" : @YES});
//                }
//            }];
//        }
//        else
//        {
//            //상단
//            [UIView animateWithDuration:0.3f animations:^{
//                
//                self.iv_Bg.alpha = 0.7f;
//                self.lc_BottomViewBottom.constant = 0;
//                self.lc_BgTop.constant = 0.f;
//                self.lc_CommentX.constant = self.frame.size.width / 2 - (self.btn_Comment.frame.size.width/2);
//                self.btn_Back.alpha = self.btn_AddDiscrip.alpha = self.seg.alpha = YES;
//                
//                if( self.completionBlock )
//                {
//                    self.completionBlock(@{@"alpha" : @0, @"animation" : @YES, @"IsTop" : @YES});
//                }
//                
//                [self.superview layoutIfNeeded];
//            }];
//        }
//    }
//}

- (IBAction)goTouchComment:(id)sender
{
    if( self.lc_BottomViewBottom.constant == 0 )
    {
        //하단으로 내리면 디스커넥
//        [SendBird disconnect];
//
//        self.lc_BottomViewBottom.constant = (self.frame.size.height - (73 + (self.isNavi ? 64 : 0))) * -1;
//        
//        [UIView animateWithDuration:0.3f animations:^{
//            
//            [self.superview layoutIfNeeded];
//        }];
//        
//        [UIView animateWithDuration:0.1f animations:^{
//            
//            self.iv_Bg.alpha = 0.0f;
//            self.lc_BgTop.constant = 29.f;
//            self.btn_Back.alpha = self.btn_AddDiscrip.alpha = self.seg.alpha = NO;
//            fOriginalBottom = self.lc_BottomViewBottom.constant;
//            
//            if( self.completionBlock ) 
//            {
//                self.completionBlock(@{@"alpha" : @1, @"animation" : @YES});
//            }
//        }];
    }
    else
    {
        if( self.showQnaViewBlock )
        {
            self.showQnaViewBlock(nil);
        }
        
        //위로 올리면 방 조인과 어드민 리스트를 가져온다
        [self startSendBird];
        [self joinDRoom];
        [self updateAdminList];

        [UIView animateWithDuration:0.3f animations:^{
            
            self.iv_Bg.alpha = 0.7f;
            self.lc_BottomViewBottom.constant = 0;
            self.lc_BgTop.constant = 0.f;
//            self.lc_CommentX.constant = self.frame.size.width / 2 - (self.btn_Comment.frame.size.width/2);
            self.btn_Back.alpha = self.btn_AddDiscrip.alpha = self.seg.alpha = YES;
            
            if( self.completionBlock )
            {
                self.completionBlock(@{@"alpha" : @0, @"animation" : @YES, @"IsTop" : @YES});
            }
            
            [self.superview layoutIfNeeded];
        }];

    }
//    else if( self.lc_BottomViewBottom.constant == (self.frame.size.height - 73) * -1 )
//    {
//        //하단이였으면 중단으로
//        //중단
//        CGFloat fThreeHeight = self.frame.size.height / 3;
//        [UIView animateWithDuration:0.3f animations:^{
//            
//            self.iv_Bg.alpha = 0.7f;
//            self.lc_BottomViewBottom.constant = (fThreeHeight + (73 / 2)) * -1;
//            self.lc_BgTop.constant = 29.f;
//            self.lc_CommentX.constant = self.frame.size.width / 2 - (self.btn_Comment.frame.size.width/2);
//            self.btn_Back.alpha = self.btn_AddDiscrip.alpha = self.seg.alpha = NO;
//            
//            if( self.completionBlock )
//            {
//                self.completionBlock(@{@"alpha" : @0, @"animation" : @YES, @"IsTop" : @NO});
//            }
//            
//            [self.superview layoutIfNeeded];
//        }];
//        
//        str_OldPosition = @"down";
//    }
//    else
//    {
//        if( [str_OldPosition isEqualToString:@"up"] )
//        {
//            //하단
//            self.lc_BottomViewBottom.constant = (self.frame.size.height - (73 + (self.isNavi ? 64 : 0))) * -1;
//            
//            [UIView animateWithDuration:0.3f animations:^{
//                
//                [self.superview layoutIfNeeded];
//            }];
//            
//            [UIView animateWithDuration:0.1f animations:^{
//                
//                self.iv_Bg.alpha = 0.0f;
//                self.lc_BgTop.constant = 29.f;
//                self.btn_Back.alpha = self.btn_AddDiscrip.alpha = self.seg.alpha = NO;
//                fOriginalBottom = self.lc_BottomViewBottom.constant;
//                
//                if( self.completionBlock )
//                {
//                    self.completionBlock(@{@"alpha" : @1, @"animation" : @YES});
//                }
//            }];
//        }
//        else
//        {
//            //상단
//            [UIView animateWithDuration:0.3f animations:^{
//                
//                self.iv_Bg.alpha = 0.7f;
//                self.lc_BottomViewBottom.constant = 0;
//                self.lc_BgTop.constant = 0.f;
//                self.lc_CommentX.constant = self.frame.size.width / 2 - (self.btn_Comment.frame.size.width/2);
//                self.btn_Back.alpha = self.btn_AddDiscrip.alpha = self.seg.alpha = YES;
//                
//                if( self.completionBlock )
//                {
//                    self.completionBlock(@{@"alpha" : @0, @"animation" : @YES, @"IsTop" : @YES});
//                }
//                
//                [self.superview layoutIfNeeded];
//            }];
//        }
//    }
}

- (IBAction)gpSegChange:(id)sender
{
    [UIView animateWithDuration:0.3f animations:^{
        
        if( self.seg.selectedSegmentIndex == 0 )
        {
            self.sv_Contents.contentOffset = CGPointZero;
            [self endEditing:YES];
            
            [self performSelector:@selector(onDResetInterval) withObject:nil afterDelay:0.3f];
        }
        else
        {
            self.sv_Contents.contentOffset = CGPointMake(self.sv_Contents.bounds.size.width, 0);
            
            [self performSelector:@selector(onQResetInterval) withObject:nil afterDelay:0.3f];
        }
    }];
}

- (IBAction)goShowLikeSort:(id)sender
{
    if( self.btn_Like.selected == NO )
    {
        self.btn_Like.selected = YES;
        self.btn_New.selected = NO;
        
        [self updateDList];
    }
}

- (IBAction)goShowNewSort:(id)sender
{
    if( self.btn_New.selected == NO )
    {
        self.btn_Like.selected = NO;
        self.btn_New.selected = YES;
        
        [self updateDList];
    }
}

- (IBAction)goAddDiscrip:(UIButton *)btn
{
    
}

//- (void)initLayout
//{
//    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
//    self.lc_BottomViewBottom.constant = (window.bounds.size.height - (73 + (self.isNavi ? 64 : 0))) * -1;
//}

@end
