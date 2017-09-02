//
//  ChattingViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 9. 6..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "ChattingViewController.h"
#import "ChattingCell.h"

#import "QuestionListCell.h"
#import "YTPlayerView.h"
#import "YmExtendButton.h"
#import "AudioView.h"
#import "DiscripFooterView.h"
#import "DiscripHeaderCell.h"
#import "AddDiscripViewController.h"
#import "SBJsonParser.h"
#import "VideoPlayerViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import <AVKit/AVKit.h>
#import "InRoomMemberListViewController.h"
#import "InvitationViewController.h"
#import "CommentKeyboardAccView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <AVFoundation/AVFoundation.h>
#import "UserPageMainViewController.h"
#import "MyMainViewController.h"

@import AVFoundation;
@import MediaPlayer;

#import "MWPhotoBrowser.h"


@interface ChattingViewController () <UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, MWPhotoBrowserDelegate>
{
    BOOL isReplyMode;
    CGFloat fKeyboardHeight;
    NSDictionary *dic_SelectedItem;
//    NSString *str_SelectedQId;
//    NSString *str_SelectedGroupId;
    
    BOOL isFirstLoad;
    BOOL isLoding;
    BOOL isMore;    //더보기인지 여부
    
    BOOL isMyContents;  //마이에서 왔을때 사용하는 값
    
    NSInteger nTotalCnt;
    
    NSString *str_ImagePreFix;
    NSString *str_ImagePreUrl;
    NSString *str_UserImagePrefix;
    
    NSArray *ar_ColorList;
    
}
@property (nonatomic, strong) NSMutableArray *ar_Photo;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) ChattingCell *c_ChattingCell;
@property (nonatomic, strong) NSDictionary *dic_LastObj;
@property (nonatomic, strong) UIButton *btn_User;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet UIButton *btn_AddQuestion;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Tutorial;
@property (nonatomic, weak) IBOutlet CommentKeyboardAccView *v_CommentKeyboardAccView;
@end

@implementation ChattingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.v_CommentKeyboardAccView.tv_Contents.placeholder = kChatPlaceHolder;
//    self.v_CommentKeyboardAccView.tv_Contents.contentInset = UIEdgeInsetsMake(0, 0, -200, 0);
    
    id value = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"questionId"]]];
    if( value )
    {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:[NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"questionId"]]];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        self.iv_Tutorial.hidden = NO;
    }

    self.btn_AddQuestion.hidden = YES;

    isFirstLoad = YES;  //처음 로딩할땐 테이블뷰를 맨 아래부터 보여준다
    
    NSString *str_Title = [NSString stringWithFormat:@"#%@", [self.dic_Info objectForKey:@"roomName"]];
//    NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"userImage"];
//    UIImage *image = [[UIImage alloc] initWithData:imageData];
//    if( image == nil )
//    {
//        image = self.i_User;
//    }
    
    self.btn_User = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btn_User.clipsToBounds = YES;
    self.btn_User.backgroundColor = [UIColor whiteColor];
    [self.btn_User setTitle:@"" forState:UIControlStateNormal];
    [self.btn_User setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [self.btn_User.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:13]];
    self.btn_User.frame = CGRectMake(0, 3, 34, 34);
    [self.btn_User addTarget:self action:@selector(rightLeftItemPress:) forControlEvents:UIControlEventTouchUpInside];
//    [self.btn_User setImage:image forState:0];
    self.btn_User.layer.cornerRadius = self.btn_User.frame.size.width/2;
    self.btn_User.layer.borderColor = [UIColor darkGrayColor].CGColor;
    self.btn_User.layer.borderWidth = 1.f;

    [self initNaviWithTitle:str_Title withLeftItem:[self leftBackBlackMenuBarButtonItem] withRightItem:[self rightQnaRoomInfoAndIcon:self.btn_User] withColor:[UIColor colorWithHexString:@"F8F8F8"]];

//    if( self.isMyMode )
//    {
//        [self initNaviWithTitle:str_Title withLeftItem:[self leftBackBlackMenuBarButtonItem] withRightItem:[self rightQnaRoomInfoAndIcon:self.i_User] withColor:[UIColor colorWithHexString:@"F8F8F8"]];
//    }
//    else
//    {
//        [self initNaviWithTitle:str_Title withLeftItem:[self leftBackBlackMenuBarButtonItem] withRightItem:[self rightQnaRoomInfo] withColor:[UIColor colorWithHexString:@"F8F8F8"]];
//    }
    
    //1: #9ED8EB
    //2: #FDE581
    //3: #DAF180
    //4: #DBD6F1
    //5: #FBDADC
    //6: #E1E1E1
    ar_ColorList = @[@"9ED8EB", @"FDE581", @"DAF180", @"DBD6F1", @"FBDADC", @"E1E1E1"];
    
    self.c_ChattingCell = [self.tbv_List dequeueReusableCellWithIdentifier:NSStringFromClass([ChattingCell class])];

    [self startSendBird];
    
    NSString *str_ChannelUrl = [NSString stringWithFormat:@"thotingQuestion_channel_%@", [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"questionId"]]];
//    [SendBird joinChannel:str_ChannelUrl];
//    [SendBird connect];

    [self performSelector:@selector(onJoinMessageInterval) withObject:nil afterDelay:1.f];

    [self updateList];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onMyUpload) name:@"LastObjNoti" object:nil];

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

- (void)onMyUpload
{
    [self performSelector:@selector(onMyUploadInterval) withObject:nil afterDelay:1.f];
}

- (void)onMyUploadInterval
{
    if (self.tbv_List.contentSize.height > self.tbv_List.frame.size.height)
    {
        CGPoint offset = CGPointMake(0, self.tbv_List.contentSize.height - self.tbv_List.frame.size.height);
        [self.tbv_List setContentOffset:offset animated:NO];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAnimate:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillAnimate:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
//    self.btn_AddQuestion.hidden = NO;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [MBProgressHUD hide];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)rightQnaRoomInfoPress:(UIButton *)btn
{
    NSMutableArray *arM = [NSMutableArray array];
    [arM addObject:@"참여자"];
    [arM addObject:@"초대하기"];

    [OHActionSheet showSheetInView:self.view
                             title:nil
                 cancelButtonTitle:@"취소"
            destructiveButtonTitle:nil
                 otherButtonTitles:arM
                        completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
     {
         if( buttonIndex == 0 )
         {
             //참여자
             UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chatting" bundle:nil];
             InRoomMemberListViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"InRoomMemberListViewController"];
             vc.str_ChannelId = self.str_ChannelId;
             vc.str_QuestionId = [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"questionId"]];
             [self.navigationController pushViewController:vc animated:YES];
         }
         else if( buttonIndex == 1 )
         {
             //초대하기
             UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chatting" bundle:nil];
             InvitationViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"InvitationViewController"];
             vc.str_ChannelId = self.str_ChannelId;
             vc.str_QuestionId = [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"questionId"]];
             vc.str_RId = self.str_RId;
             [self.navigationController pushViewController:vc animated:YES];
         }
         else
         {
             isReplyMode = NO;
         }
     }];
}

//유저아이콘 또는 전체버튼 눌렀을때
- (void)rightLeftItemPress:(UIButton *)btn
{
    if( isLoding )  return;
    
    self.tbv_List.userInteractionEnabled = NO;
    
    if( btn.selected )
    {
        NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"userImage"];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        if( image == nil )
        {
            image = self.i_User;
        }

        [self.btn_User setImage:image forState:0];
        [self.btn_User setTitle:@"" forState:UIControlStateNormal];
        
        isMyContents = NO;
        
        [self.arM_List removeAllObjects];
        self.arM_List = nil;
        [self updateList];
    }
    else
    {
        [self.btn_User setTitle:@"전체" forState:UIControlStateNormal];
        [self.btn_User setImage:BundleImage(@"") forState:0];
        
        isMyContents = YES;
        
        [self.arM_List removeAllObjects];
        self.arM_List = nil;
        [self updateList];
    }
    
    self.btn_User.selected = !self.btn_User.selected;
}

- (void)leftBackSideMenuButtonPressed:(UIButton *)btn
{
//    [SendBird disconnect];
    [super leftBackSideMenuButtonPressed:btn];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


#pragma mark - Notification
- (void)keyboardWillAnimate:(NSNotification *)notification
{
    CGRect keyboardBounds;
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    fKeyboardHeight = keyboardBounds.size.height;
    
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        [UIView setAnimationCurve:[curve intValue]];
        if([notification name] == UIKeyboardWillShowNotification)
        {
            self.v_CommentKeyboardAccView.lc_Bottom.constant = keyboardBounds.size.height;
            self.v_CommentKeyboardAccView.lc_AddWidth.constant = 63.f;

//            [self.v_CommentKeyboardAccView setNeedsUpdateConstraints];
//            
//            [UIView animateWithDuration:0.25f animations:^{
//                [self.v_CommentKeyboardAccView layoutIfNeeded];
//            }];
            
            if (self.tbv_List.contentSize.height > self.tbv_List.frame.size.height)
            {
                CGPoint offset = CGPointMake(0, self.tbv_List.contentOffset.y + keyboardBounds.size.height);
                [self.tbv_List setContentOffset:offset animated:NO];
            }
        }
        else if([notification name] == UIKeyboardWillHideNotification)
        {
            self.v_CommentKeyboardAccView.lc_Bottom.constant = 0;
            self.v_CommentKeyboardAccView.lc_AddWidth.constant = 0.f;
            
            isReplyMode = NO;
            self.v_CommentKeyboardAccView.tv_Contents.placeholder = kChatPlaceHolder;

//            [self.v_CommentKeyboardAccView setNeedsUpdateConstraints];
//            
//            [UIView animateWithDuration:0.25f animations:^{
//                [self.v_CommentKeyboardAccView layoutIfNeeded];
//            }];
        }
    }completion:^(BOOL finished) {
        
    }];
}


- (void)updateList
{
    isLoding = YES;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"questionId"]], @"questionId",
                                        @"list", @"resultType",
                                        isMyContents ? @"10" : @"20", @"limitCount",
//                                        @"", @"lastQnaId",
                                        @"newest", @"orderBy",
                                        @"chatQna", @"callWhere",
//                                        self.btn_QLike.selected ? @"thubmup" : @"newest", @"orderBy",
                                        nil];
    
    if( self.arM_List != nil && self.arM_List.count > 0 )
    {
        NSDictionary *dic = [self.arM_List firstObject];
        
        if( self.dic_LastObj )
        {
            NSInteger nLastEId = [[self.dic_LastObj objectForKey:@"eId"] integerValue];
            NSInteger nEId = [[dic objectForKey:@"eId"] integerValue];
            
            if( nEId == nLastEId )
            {
                [self.tbv_List reloadData];
                isLoding = NO;
                return;
            }
        }
        
        NSString *str_EId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"eId"]];
        [dicM_Params setObject:str_EId forKey:@"lastQnaId"];
        
        self.dic_LastObj = dic;
    }
    else
    {
        [dicM_Params setObject:@"" forKey:@"lastQnaId"];
    }
    
    if( isMyContents )
    {
        [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] forKey:@"getUserId"];
    }
    
    __weak __typeof(&*self)weakSelf = self;
    
    __block BOOL isFind = NO;
    __block NSInteger nFindIdx = 0;
    __block NSInteger nCurrentCount = self.arM_List.count;
    
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
                                                NSInteger nQCnt = [[resulte objectForKey:@"qnaCount"] integerValue];
                                                if( nQCnt > 0 )
                                                {
                                                    NSInteger nReplyCnt = [[resulte objectForKey:@"replyCount"] integerValue];
                                                    nTotalCnt = nQCnt + nReplyCnt;
                                                }
                                                
                                                if( str_ImagePreFix == nil )
                                                {
                                                    str_ImagePreFix = [resulte objectForKey:@"image_prefix"];
                                                }
                                                
                                                if( str_ImagePreUrl == nil )
                                                {
                                                    str_ImagePreUrl = [resulte objectForKey:@"imgUrl"];
                                                }
                                                
                                                if( str_UserImagePrefix == nil )
                                                {
                                                    str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
                                                }
                                                
                                                if( weakSelf.arM_List != nil && weakSelf.arM_List.count > 0 )
                                                {
                                                    NSMutableArray *arM = [NSMutableArray arrayWithArray:[resulte objectForKey:@"data"]];
                                                    [arM addObjectsFromArray:weakSelf.arM_List];
                                                    weakSelf.arM_List = [NSMutableArray arrayWithArray:arM];
                                                }
                                                else
                                                {
                                                    weakSelf.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"data"]];
                                                }

                                                //해당 메세지 찾기면
                                                NSInteger nMoveGroupId = [[self.dic_Info objectForKey:@"groupId"] integerValue];
                                                if( self.isMove && isFind == NO && nMoveGroupId > 0 )
                                                {
                                                    //메세지가 있는지 확인하고 없으면 더 불러오기
                                                    for( NSInteger i = 0; i < weakSelf.arM_List.count; i++ )
                                                    {
                                                        NSDictionary *dic = weakSelf.arM_List[i];
                                                        NSInteger nGroupId = [[dic objectForKey:@"groupId"] integerValue];
                                                        if( nGroupId == nMoveGroupId )
                                                        {
                                                            isFind = YES;
                                                            nFindIdx = i;
                                                            weakSelf.isMove = NO;
                                                            break;
                                                        }
                                                    }
                                                    
                                                    if( isFind )
                                                    {
                                                        [weakSelf.tbv_List reloadData];
                                                        
                                                        //찾았으면 해당 아이템으로 이동
                                                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:nFindIdx inSection:0];
                                                        [weakSelf.tbv_List scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                                                    }
                                                    else
                                                    {
                                                        //찾지 못했으면 더불러오기
                                                        [weakSelf updateList];
                                                    }
                                                }
                                                else if( isFirstLoad )
                                                {
                                                    [weakSelf.tbv_List reloadData];

                                                    if (weakSelf.tbv_List.contentSize.height > weakSelf.tbv_List.frame.size.height)
                                                    {
                                                        CGPoint offset = CGPointMake(0, weakSelf.tbv_List.contentSize.height - weakSelf.tbv_List.frame.size.height);
                                                        [weakSelf.tbv_List setContentOffset:offset animated:NO];
                                                    }
                                                    
                                                    isFirstLoad = NO;
                                                }
                                                else
                                                {
                                                    if( isMore )
                                                    {
                                                        [weakSelf.tbv_List reloadData];

                                                        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:weakSelf.arM_List.count - nCurrentCount inSection:0];
                                                        [weakSelf.tbv_List scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
                                                    }
                                                    else
                                                    {
                                                        [weakSelf.tbv_List reloadData];
                                                    }
                                                }
                                                
                                                
//                                                if( isMore )
//                                                {
//                                                    [weakSelf.tbv_List setContentOffset:CGPointMake(0, fCurrentOffsetY) animated:NO];
//                                                }
                                            }
                                            else
                                            {
                                                [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                        

//                                        NSString *str_Title = [NSString stringWithFormat:@"#%@", [self.dic_Info objectForKey:@"roomName"]];
//                                        if( weakSelf.arM_List != nil && weakSelf.arM_List.count > 0 )
//                                        {
//                                            NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"userImage"];
//                                            UIImage *image = [[UIImage alloc] initWithData:imageData];
//                                            if( image == nil )
//                                            {
//                                                image = self.i_User;
//                                            }
//
//                                            [weakSelf initNaviWithTitle:str_Title withLeftItem:[self leftBackBlackMenuBarButtonItem] withRightItem:[self rightQnaRoomInfoAndIcon:image] withColor:[UIColor colorWithHexString:@"F8F8F8"]];
//                                        }
//                                        else
//                                        {
//                                            [weakSelf initNaviWithTitle:str_Title withLeftItem:[self leftBackBlackMenuBarButtonItem] withRightItem:[self rightQnaRoomInfoAndIcon:nil] withColor:[UIColor colorWithHexString:@"F8F8F8"]];
//                                        }
                                        
                                        weakSelf.tbv_List.userInteractionEnabled = YES;
                                        isLoding = NO;
                                        isMore = NO;
                                        
//                                        if( weakSelf.arM_List == nil || weakSelf.arM_List.count <= 0 )
//                                        {
//                                            self.iv_Tutorial.hidden = self.lb_Tutorial.hidden = NO;
//                                        }
//                                        else
//                                        {
//                                            self.iv_Tutorial.hidden = self.lb_Tutorial.hidden = YES;
//                                        }
                                    }];
}

- (void)configureCell:(ChattingCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    for( UIView *subView in cell.contentView.subviews )
    {
        [subView removeFromSuperview];
    }
    
    static BOOL isLeft = YES;
    
    __block CGFloat fSampleViewTotalHeight = 20;
    
    BOOL isOnlyText = YES;
    CGFloat fTextWidth = 20.0f;
    
    NSDictionary *dic_Info = self.arM_List[indexPath.row];
    
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
//        else if( [str_Type isEqualToString:@"html"] )
//        {
//            NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[str_Body dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
//            CGRect rect = [attrStr boundingRectWithSize:CGSizeMake(cell.contentView.frame.size.width, FLT_MAX) options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading context:nil];
//            
//            UILabel * lb_Contents = [[UILabel alloc] initWithFrame:CGRectMake(nX, fSampleViewTotalHeight, cell.contentView.frame.size.width - (nX + nTail), rect.size.height)];
//            lb_Contents.preferredMaxLayoutWidth = CGRectGetWidth(lb_Contents.frame);
//            lb_Contents.numberOfLines = 0;
//            lb_Contents.attributedText = attrStr;
////            lb_Contents.textColor = [UIColor whiteColor];
//            
//            if( isQna )
//            {
//                lb_Contents.textAlignment = NSTextAlignmentLeft;
//            }
//            else
//            {
//                lb_Contents.textAlignment = NSTextAlignmentRight;
//            }
//
//            if( lb_Contents.frame.size.width > fTextWidth )
//            {
//                fTextWidth = lb_Contents.frame.size.width;
//            }
//
//            [cell.contentView addSubview:lb_Contents];
//            
//            fSampleViewTotalHeight += rect.size.height + 10;
//        }
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
//        else if( [str_Type isEqualToString:@"videoLink"] )
//        {
//            isOnlyText = NO;
//            
//            YTPlayerView *playerView = [[YTPlayerView alloc] initWithFrame:
//                                        CGRectMake(8, fSampleViewTotalHeight,
//                                                   cell.contentView.frame.size.width - (nX + nTail), cell.contentView.frame.size.width - (nX + nTail) * 0.7f)];
//            
//            NSDictionary *playerVars = @{
//                                         @"controls" : @1,
//                                         @"playsinline" : @1,
//                                         @"autohide" : @1,
//                                         @"showinfo" : @0,
//                                         @"modestbranding" : @1
//                                         };
//            
//            [playerView loadWithVideoId:str_Body playerVars:playerVars];
//            
//            [cell.contentView addSubview:playerView];
//            
//            fSampleViewTotalHeight += playerView.frame.size.height + 10;
//            
//            
//        }
//        else if( [str_Type isEqualToString:@"audio"] )
//        {
//            //음성
//            NSString *str_Body = [dic objectForKey_YM:@"questionBody"];
//            NSString *str_Url = [NSString stringWithFormat:@"%@%@", str_ImagePreFix, str_Body];
//            
//            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"AudioView" owner:self options:nil];
//            AudioView *v_Audio = [topLevelObjects objectAtIndex:0];
//            [v_Audio initPlayer:str_Url];
//            
//            CGRect frame = v_Audio.frame;
//            frame.origin.y = fSampleViewTotalHeight;
//            frame.size.width = self.view.bounds.size.width;
//            frame.size.height = 48;
//            v_Audio.frame = frame;
//            
//            [cell.contentView addSubview:v_Audio];
//            
//            fSampleViewTotalHeight += v_Audio.frame.size.height + 10;
//        }
        else if( [str_Type isEqualToString:@"video"] )
        {
            isOnlyText = NO;
            
            UIView *view = [[UIView alloc]initWithFrame:CGRectMake(nX, fSampleViewTotalHeight,
                                                                   cell.contentView.frame.size.width - (nX + nTail), (cell.contentView.frame.size.width - (nX + nTail)) * 0.7f)];
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

//            UIImage *resizeImage = nil;
//            if( [[dic objectForKey:@"qnaBody"] isKindOfClass:[UIImage class]] )
//            {
//                resizeImage = [dic objectForKey:@"qnaBody"];
//                iv.image = resizeImage;
//            }
//            else if( [[dic objectForKey:@"replyBody"] isKindOfClass:[UIImage class]] )
//            {
//                resizeImage = [dic objectForKey:@"replyBody"];
//                iv.image = resizeImage;
//            }
//            else
//            {
//                resizeImage = [Util imageWithImage:thumbnail convertToWidth:iv.frame.size.width];
//                iv.image = resizeImage;
//            }
//            
//            CGRect frame = iv.frame;
//            frame.size.height = resizeImage.size.height;
//            iv.frame = frame;
            
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
    if( self.arM_List.count - 1 > indexPath.row)
    {
        NSDictionary *dic_Next = self.arM_List[indexPath.row + 1];
        
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
            iv_User.tag = indexPath.row;
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
            iv_User.tag = indexPath.row;
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
        iv_User.tag = indexPath.row;
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
    if( frame.size.width > self.tbv_List.bounds.size.width - 250 )
    {
        frame.size.width = self.tbv_List.bounds.size.width - 250;
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
    if( self.arM_List.count > indexPath.row + 1 )
    {
        NSDictionary *dic = [self.arM_List objectAtIndex:indexPath.row + 1];
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
            btn_Reply.tag = indexPath.row;
            [btn_Reply addTarget:self action:@selector(onAddReply:) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:btn_Reply];
            
            UIImageView *iv_UnderLine = [[UIImageView alloc] initWithFrame:CGRectMake(15, btn_Reply.frame.origin.y + btn_Reply.frame.size.height + 8,
                                                                                      cell.contentView.frame.size.width - 30, 1)];
            iv_UnderLine.backgroundColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1];
            [cell.contentView addSubview:iv_UnderLine];
        }
    }
    else if( self.arM_List.count == indexPath.row + 1 )
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
        btn_Reply.tag = indexPath.row;
        [btn_Reply addTarget:self action:@selector(onAddReply:) forControlEvents:UIControlEventTouchUpInside];
        [cell.contentView addSubview:btn_Reply];
        
        UIImageView *iv_UnderLine = [[UIImageView alloc] initWithFrame:CGRectMake(15, btn_Reply.frame.origin.y + btn_Reply.frame.size.height + 8,
                                                                                  cell.contentView.frame.size.width - 30, 1)];
        iv_UnderLine.backgroundColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1];
        [cell.contentView addSubview:iv_UnderLine];
    }
    
    
    
//    if( isQna )
//    {
//        UIButton *btn_Reply = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn_Reply.frame = CGRectMake(frame.origin.x + frame.size.width + 8, fSampleViewTotalHeight + 5, 50, 20);
//        [btn_Reply setTitle:@"답글" forState:UIControlStateNormal];
//        [btn_Reply setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
//        [btn_Reply setBackgroundColor:[UIColor colorWithHexString:str_Color]];
//        [btn_Reply.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
//        btn_Reply.layer.cornerRadius = 8.f;
//        btn_Reply.tag = indexPath.row;
//        [btn_Reply addTarget:self action:@selector(onAddReply:) forControlEvents:UIControlEventTouchUpInside];
//        [cell.contentView addSubview:btn_Reply];
//    }
}

- (void)onAddReply:(UIButton *)btn
{
    //답글달기
    NSDictionary *dic = self.arM_List[btn.tag];
    dic_SelectedItem = [NSDictionary dictionaryWithDictionary:dic];
    isReplyMode = YES;
    self.v_CommentKeyboardAccView.tv_Contents.placeholder = @"답글하기...";
    [self.v_CommentKeyboardAccView.tv_Contents becomeFirstResponder];
    
//
//    BOOL isLastObj = NO;
//    if( self.arM_List.count - 1 == btn.tag )
//    {
//        isLastObj = YES;
//    }
//    AddDiscripViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"AddDiscripViewController"];
//    vc.isQuestionMode = YES;
//    vc.str_QnAId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"groupId"]];
//    vc.str_Idx = [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]];
//    vc.str_GroupId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"groupId"]];
//    vc.isLastObj = isLastObj;
//    [self presentViewController:vc animated:YES completion:nil];//groupId
}

- (void)userImageTap:(UIGestureRecognizer *)gestureRecognizer
{
    UIImageView *iv = (UIImageView *)gestureRecognizer.view;
    NSDictionary *dic = [self.arM_List objectAtIndex:iv.tag];
    
    if( [[dic objectForKey:@"userId"] integerValue] == [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue] )
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        MyMainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
        vc.isManagerView = YES;
        vc.isPermission = YES;
        vc.str_UserIdx = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
        MyMainViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
        vc.isAnotherUser = YES;
        vc.str_UserIdx = [dic objectForKey:@"userId"];
        [self.navigationController pushViewController:vc animated:YES];
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
    
    MWPhotoBrowser *browser = [[MWPhotoBrowser alloc] initWithDelegate:self];
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
    [self presentViewController:nc animated:YES completion:nil];
    
    // Release
    
    // Test reloading of data after delay
    double delayInSeconds = 3;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    });
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
    
    [self presentViewController:vc_Movie animated:YES completion:^{
        
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
    if( self.arM_List.count > 0 )
    {
        self.iv_Tutorial.hidden = YES;
    }
    
    NSString *str_Title = [NSString stringWithFormat:@"#%@", [self.dic_Info objectForKey:@"roomName"]];
    if( self.arM_List != nil && self.arM_List.count > 0 )
    {
        self.btn_User.hidden = NO;
        
        NSData *imageData = [[NSUserDefaults standardUserDefaults] objectForKey:@"userImage"];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        if( image == nil )
        {
            image = self.i_User;
        }
        
        if( self.btn_User.selected )
        {
            [self.btn_User setTitle:@"전체" forState:UIControlStateNormal];
            [self.btn_User setImage:BundleImage(@"") forState:0];
        }
        else
        {
            [self.btn_User setImage:image forState:0];
        }

        [self initNaviWithTitle:str_Title withLeftItem:[self leftBackBlackMenuBarButtonItem] withRightItem:[self rightQnaRoomInfoAndIcon:self.btn_User] withColor:[UIColor colorWithHexString:@"F8F8F8"]];
    }
    else 
    {
        self.btn_User.hidden = YES;
        
        [self.btn_User setImage:BundleImage(@"") forState:0];
        
        [self initNaviWithTitle:str_Title withLeftItem:[self leftBackBlackMenuBarButtonItem] withRightItem:[self rightQnaRoomInfoAndIcon:self.btn_User] withColor:[UIColor colorWithHexString:@"F8F8F8"]];
    }

    if( self.btn_User.selected && self.arM_List.count <= 0 )
    {
        self.btn_User.hidden = NO;
        [self.btn_User setTitle:@"전체" forState:UIControlStateNormal];
        [self.btn_User setImage:BundleImage(@"") forState:0];
    }
    
    return self.arM_List.count;
}

- (void)cellTap:(UIGestureRecognizer *)gesture
{
    [self.view endEditing:YES];
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    ChattingCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChattingCell" forIndexPath:indexPath];
    
    for( UIGestureRecognizer *recognizer in cell.gestureRecognizers )
    {
        [cell removeGestureRecognizer:recognizer];
    }
    
    cell.tag = indexPath.row;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestures:)];
    [cell addGestureRecognizer:longPress];
    
    UITapGestureRecognizer *cellTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cellTap:)];
    [cellTap setNumberOfTapsRequired:1];
    [cell addGestureRecognizer:cellTap];

    [self configureCell:cell forRowAtIndexPath:indexPath];
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self configureCell:self.c_ChattingCell forRowAtIndexPath:indexPath];

    [self.c_ChattingCell updateConstraintsIfNeeded];
    [self.c_ChattingCell layoutIfNeeded];
    
    self.c_ChattingCell.bounds = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.tbv_List.bounds), CGRectGetHeight(self.c_ChattingCell.bounds));
    
    //    fContentsHeight = [self.questionListCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    return [self.c_ChattingCell.contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;;
}


#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
//    if( scrollView.contentOffset.y <= 0 && isLoding == NO && nTotalCnt < self.arM_List.count )
    
    if( scrollView.contentOffset.y <= 0 && isLoding == NO && self.arM_List.count > 0 )
    {
        //up
        if( nTotalCnt > 0 && self.arM_List.count >= nTotalCnt )
        {
//            [self.navigationController.view makeToast:@"데이터가 없습니다" withPosition:kPositionTop];
            return;
        }

        isMore = YES;
        [self updateList];
    }
//    else if( isLoding == NO )
//    {
//        //down
//        isLoding = YES;
//        [self updateList];
//    }
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


#pragma mark - DeleteFuntion
- (void)deleteQna:(NSInteger)nTag
{
    __block NSDictionary *dic = self.arM_List[nTag];
    
    NSMutableArray *arM = [NSMutableArray array];
    [arM addObject:@"삭제하기"];
    
    [OHActionSheet showSheetInView:self.view
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
                                                         [self.dic_Info objectForKey:@"questionId"], @"questionId",
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
                                                                 NSInteger nGroupId = [[dic objectForKey:@"groupId"] integerValue];
                                                                 NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"eId":[NSString stringWithFormat:@"%@", [dic objectForKey:@"eId"]]}
                                                                                                                    options:NSJSONWritingPrettyPrinted
                                                                                                                      error:&error];
                                                                 NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                                 
//                                                                 [SendBird sendMessage:@"delete-qna" withData:jsonString];
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
     }];
}

- (void)deleteReply:(NSInteger)nTag
{
    __block NSDictionary *dic = self.arM_List[nTag];
    
    NSMutableArray *arM = [NSMutableArray array];
    [arM addObject:@"삭제하기"];
    
    [OHActionSheet showSheetInView:self.view
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
                                                         [self.dic_Info objectForKey:@"questionId"], @"questionId",
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
                                                                 [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                             }
                                                         }
                                                     }];
                 }
             }];
             
         }
     }];
}

- (void)handleLongPressGestures:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        [self.view endEditing:YES];
        
        UIView *view = (UIView *)gesture.view;
        NSDictionary *dic = self.arM_List[view.tag];
        NSString *str_Type = [dic objectForKey:@"itemType"];
        NSString *str_WriteUserId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]];
        NSString *str_MyUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
        
        if( [str_WriteUserId integerValue] == [str_MyUserId integerValue] )
        {
            //내가 쓴 글
            if( [str_Type isEqualToString:@"qna"] )
            {
                //질문일 경우 아래 달린 댓글도 삭제
                [self deleteQna:view.tag];
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
            NSMutableArray *arM = [NSMutableArray array];
            [arM addObject:@"신고하기"];
            
            [OHActionSheet showSheetInView:self.view
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
                                                                     NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                                     if( nCode == 200 )
                                                                     {
                                                                         [weakSelf.navigationController.view makeToast:@"신고 되었습니다." withPosition:kPositionCenter];
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
             }];
        }
    }
}



#pragma mark - IBAction
- (IBAction)goAddQuestion:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    AddDiscripViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"AddDiscripViewController"];
    vc.isQuestionMode = YES;
    vc.str_Idx = [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"questionId"]];
    vc.str_GroupId = @"0";
    [self presentViewController:vc animated:YES completion:nil];
}


#pragma mark - SendBird
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
//        //        ALERT(nil, message.message, nil, @"확인", nil);
//        
//        NSData* data = [message.data dataUsingEncoding:NSUTF8StringEncoding];
//        
//        NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//        SBJsonParser *jsonParser = [[SBJsonParser alloc] init];
//        NSMutableDictionary *dicM_Result = [NSMutableDictionary dictionaryWithDictionary:[jsonParser objectWithString:dataString]];
//        
//        NSLog(@"dicM_Result : %@", dicM_Result);
//
//        if( [message.message isEqualToString:@"regist-explain"] )
//        {
////            //새로운 문제풀이 등록
//        }
//        else if( [message.message isEqualToString:@"delete-explain"] )
//        {
////            [self updateDList];
//        }
//        else if( [message.message isEqualToString:@"regist-qna"] )
//        {
//            //새로운 질문 등록
//            [dicM_Result setObject:@"qna" forKey:@"itemType"];
//            [self updateOneList:dicM_Result];
////            [self.navigationController.view makeToast:@"새로운 질문이 등록 되었습니다." withPosition:kPositionTop];
////            CGPoint offset = CGPointMake(0, self.tbv_List.contentSize.height - self.tbv_List.frame.size.height);
////            [self.tbv_List setContentOffset:offset animated:NO];
//        }
//        else if( [message.message isEqualToString:@"delete-qna"] )
//        {
//            //질문삭제
//            NSInteger nGroupId = 0;
//            NSInteger nEId = [[dicM_Result objectForKey:@"eId"] integerValue];
//            for( NSInteger i = 0; i < self.arM_List.count; i++ )
//            {
//                NSDictionary *dic_Tmp = self.arM_List[i];
//                NSInteger nEId_Tmp = [[dic_Tmp objectForKey:@"eId"] integerValue];
//                if( nEId == nEId_Tmp )
//                {
//                    nGroupId = [[dic_Tmp objectForKey:@"groupId"] integerValue];
//                    break;
//                }
//            }
//            
//            NSMutableArray *arM_Tmp = [NSMutableArray array];
//            for( NSInteger i = 0; i < self.arM_List.count; i++ )
//            {
//                NSDictionary *dic_Tmp = self.arM_List[i];
//                NSInteger nGroupIdTmp = [[dic_Tmp objectForKey:@"groupId"] integerValue];
//                if( nGroupId != nGroupIdTmp )
//                {
//                    [arM_Tmp addObject:dic_Tmp];
//                }
//            }
//            
//            self.arM_List = arM_Tmp;
//            [self.tbv_List reloadData];
//        }
//        else if( [message.message isEqualToString:@"delete-reply"] )
//        {
//            NSInteger nEId = [[dicM_Result objectForKey:@"eId"] integerValue];
//            for( NSInteger i = 0; i < self.arM_List.count; i++ )
//            {
//                NSDictionary *dic_Tmp = self.arM_List[i];
//                NSInteger nEId_Tmp = [[dic_Tmp objectForKey:@"eId"] integerValue];
//                if( nEId == nEId_Tmp )
//                {
//                    [self.arM_List removeObjectAtIndex:i];
//                    [self.tbv_List reloadData];
//                }
//            }
//        }
//        else if( [message.message isEqualToString:@"regist-reply"] )
//        {
//            //답글등록
//            [dicM_Result setObject:@"reply" forKey:@"itemType"];
//            [self updateOneList:dicM_Result];
//            
//            if( [[dicM_Result objectForKey:@"userId"] integerValue] != [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue] )
//            {
//                [self.navigationController.view makeToast:@"새로운 답글이 등록 되었습니다." withPosition:kPositionTop];
//            }
//        }
//        else if( [message.message isEqualToString:@"join-chat"] )
//        {
//            NSInteger nUserId = [[dicM_Result objectForKey:@"userId"] integerValue];
//            NSInteger nMyUserId = [[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] integerValue];
//            if( nUserId != nMyUserId )
//            {
//                NSString *str_UserName = [dicM_Result objectForKey:@"userName"];
//                [self.navigationController.view makeToast:[NSString stringWithFormat:@"%@님이 참여했습니다.", str_UserName] withPosition:kPositionBottom];
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
    /*
     질문
     eId = 9022;
     itemType = qna;
     questionId = 18119;

    
     댓글
     eId = 9004;
     itemType = reply;
     questionId = 18119;
     replyId = 8990;        //부모의 eId
     */
    

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
//                                            if (weakSelf.tbv_List.contentSize.height > weakSelf.tbv_List.frame.size.height)
//                                            {
//                                                CGPoint offset = CGPointMake(0, weakSelf.tbv_List.contentOffset.y + fKeyboardHeight);
//                                                [weakSelf.tbv_List setContentOffset:offset animated:NO];
//                                            }

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
                                                            for( NSInteger i = 0; i < weakSelf.arM_List.count; i++ )
                                                            {
                                                                NSDictionary *dic_Sub = weakSelf.arM_List[i];
                                                                if( [[dic_Sub objectForKey:@"isMy"] isEqualToString:@"Y"] )
                                                                {
                                                                    [weakSelf.arM_List removeObjectAtIndex:i];
                                                                    [weakSelf.arM_List insertObject:resulte atIndex:i];
                                                                    return;
                                                                }
                                                            }
                                                        }
                                                        else
                                                        {
                                                            [weakSelf.arM_List addObject:resulte];
                                                        }
                                                    }
                                                    else
                                                    {
                                                        for( NSInteger i = 0; i < weakSelf.arM_List.count; i++ )
                                                        {
                                                            NSDictionary *dic_Sub = weakSelf.arM_List[i];
                                                            NSInteger nEId = [[dic_Sub objectForKey:@"groupId"] integerValue];
                                                            NSInteger nParentEid = [[dic objectForKey:@"replyId"] integerValue];
                                                            if( nEId == nParentEid )
                                                            {
                                                                BOOL isLastObj = YES;
                                                                NSInteger nPK = i;
                                                                for( NSInteger j = nPK; j < weakSelf.arM_List.count; j++ )
                                                                {
                                                                    NSDictionary *dic_Sub2 = weakSelf.arM_List[j];
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
                                                                    NSDictionary *dic_Tmp = [weakSelf.arM_List lastObject];
                                                                    NSInteger nPrevReplyIdx = [[dic_Tmp objectForKey:@"replyInx"] integerValue];
                                                                    
                                                                    NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:resulte];
                                                                    [dicM setObject:[NSString stringWithFormat:@"%ld", ++nPrevReplyIdx] forKey:@"replyInx"];
                                                                    
                                                                    if( isMy )
                                                                    {
                                                                        for( NSInteger i = 0; i < weakSelf.arM_List.count; i++ )
                                                                        {
                                                                            NSDictionary *dic_Sub = weakSelf.arM_List[i];
                                                                            if( [[dic_Sub objectForKey:@"isMy"] isEqualToString:@"Y"] )
                                                                            {
                                                                                [weakSelf.arM_List removeObjectAtIndex:i];
                                                                                [weakSelf.arM_List insertObject:resulte atIndex:i];
                                                                                [weakSelf.tbv_List reloadData];
                                                                                return;
                                                                            }
                                                                        }
                                                                    }
                                                                    else
                                                                    {
                                                                        [weakSelf.arM_List addObject:resulte];
                                                                    }
                                                                }
                                                                else
                                                                {
                                                                    NSDictionary *dic_Tmp = [weakSelf.arM_List objectAtIndex:nPK - 1];
                                                                    NSInteger nPrevReplyIdx = [[dic_Tmp objectForKey:@"replyInx"] integerValue];
                                                                    
                                                                    NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:resulte];
                                                                    [dicM setObject:[NSString stringWithFormat:@"%ld", ++nPrevReplyIdx] forKey:@"replyInx"];
                                                                    
                                                                    if( isMy )
                                                                    {
                                                                        for( NSInteger i = 0; i < weakSelf.arM_List.count; i++ )
                                                                        {
                                                                            NSDictionary *dic_Sub = weakSelf.arM_List[i];
                                                                            if( [[dic_Sub objectForKey:@"isMy"] isEqualToString:@"Y"] )
                                                                            {
                                                                                [weakSelf.arM_List replaceObjectAtIndex:i withObject:resulte];
                                                                                [weakSelf.tbv_List reloadData];
                                                                                return;
                                                                            }
                                                                        }
                                                                    }
                                                                    else
                                                                    {
                                                                        [weakSelf.arM_List insertObject:dicM atIndex:nPK];
                                                                    }
                                                                }
                                                                break;
                                                            }
                                                        }
                                                    }
                                                    
                                                    //혹시라도 같은게 있으면 빼주기 (중복되어 올라오는 현상에 대한 방어코드)
                                                    for( NSInteger i = 0; i < weakSelf.arM_List.count - 1; i++ )
                                                    {
                                                        NSDictionary *dic_Current = weakSelf.arM_List[i];
                                                        NSDictionary *dic_Next = weakSelf.arM_List[i + 1];
                                                        
                                                        if( [[dic_Current objectForKey_YM:@"eId"] integerValue] == [[dic_Next objectForKey_YM:@"eId"] integerValue] )
                                                        {
                                                            [weakSelf.arM_List removeObjectAtIndex:i + 1];
                                                            break;
                                                        }
                                                    }
                                                }
                                                else
                                                {
                                                    [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                }

                                                dispatch_async(dispatch_get_main_queue(), ^{

                                                    NSLog(@"@@@@@@@@@@@@@@@@@@@Start@@@@@@@@@@@@@@@@@@@");
                                                    [weakSelf.tbv_List reloadData];
                                                    NSLog(@"@@@@@@@@@@@@@@@@@@@End@@@@@@@@@@@@@@@@@@@");

//                                                    CGPoint offset = CGPointMake(0, self.tbv_List.contentSize.height - self.tbv_List.frame.size.height);
//                                                    [self.tbv_List setContentOffset:offset animated:NO];

                                                });
                                            });

                                        }
                                    }];
}

- (IBAction)goSendMsg:(id)sender
{
    if( self.v_CommentKeyboardAccView.tv_Contents.text.length <= 0 )    return;
    
    //우선 나한테만 달라붙게 해
    /*
     groupId = 10449;
     packageId = 150;
     qnaId = 10449;
     questionId = 18121;
     */
    
//    NSDictionary *dic_LastObj = [self.arM_List lastObject];
//    NSMutableDictionary *dicM_Temp = [NSMutableDictionary dictionary];
//    [dicM_Temp setObject:@"Y" forKey:@"isMy"];
//    [dicM_Temp setObject:[NSString stringWithFormat:@"%ld", [[dic_LastObj objectForKey:@"groupId"] integerValue] + 1] forKey:@"groupId"];
//    [dicM_Temp setObject:isReplyMode ? @"reply" : @"qna" forKey:@"itemType"];
//    
//    NSMutableDictionary *dicM_Contents = [NSMutableDictionary dictionary];
//    [dicM_Contents setObject:@"text" forKey:isReplyMode ? @"replyType" : @"qnaType"];
//    [dicM_Contents setObject:self.v_CommentKeyboardAccView.tv_Contents.text forKey:isReplyMode ? @"replyBody" : @"qnaBody"];
//    [dicM_Temp setObject:@[dicM_Contents] forKey:isReplyMode ? @"replyBody" : @"qnaBody"];
//
//    [dicM_Temp setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] forKey:@"userId"];
//    [dicM_Temp setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userPic"] forKey:@"userThumbnail"];
//    [dicM_Temp setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] forKey:@"name"];
//    
//    NSDateFormatter *now = [[NSDateFormatter alloc] init];
//    [now setDateFormat:@"yyyyMMddHHmmss"];
//    NSString *str_NowTime = [now stringFromDate:[NSDate date]];
//    [dicM_Temp setObject:str_NowTime forKey:@"createDate"];
//    
//    NSInteger nSelectedIdx = 0;
//    if( isReplyMode )
//    {
//        for( NSInteger i = 0; i < self.arM_List.count; i++ )
//        {
//            NSDictionary *dic_Sub = self.arM_List[i];
//            NSInteger nEId = [[dic_Sub objectForKey:@"eId"] integerValue];
//            NSInteger nSelectedEId = [[dic_SelectedItem objectForKey:@"eId"] integerValue];
//            if( nEId == nSelectedEId )
//            {
//                nSelectedIdx = i + 1;
//                [self.arM_List insertObject:dicM_Temp atIndex:nSelectedIdx];
//                break;
//            }
//        }
//        
////        NSDictionary *dic_Ower = nil;
////        for( NSInteger i = 0; i < self.arM_List.count; i++ )
////        {
////            NSDictionary *dic_Sub = self.arM_List[i];
////            if( [[dic_Sub objectForKey:@"itemType"] isEqualToString:@"qna"] )
////            {
////                if( [[dic_Sub objectForKey:@"groupId"] integerValue] == [[dic_SelectedItem objectForKey:@"groupId"] integerValue] )
////                {
////                    dic_Ower = dic_Sub;
////                    break;
////                }
////            }
////        }
////
////        if( dic_Ower )
////        {
////            if( [[dic_Ower objectForKey:@"userId"] integerValue] == [[dic_SelectedItem objectForKey:@"userId"] integerValue] )
////            {
////                [dicM_Temp setObject:@"Y" forKey:@"isQuestioner"];
////            }
////            else
////            {
////                [dicM_Temp setObject:@"N" forKey:@"isQuestioner"];
////            }
////        }
//        if( [[dic_SelectedItem objectForKey:@"itemType"] isEqualToString:@"qna"] )
//        {
//            [dicM_Temp setObject:[dic_SelectedItem objectForKey_YM:@"isOwner"] forKey:@"isQuestioner"];
//        }
//        else
//        {
//            [dicM_Temp setObject:[dic_SelectedItem objectForKey_YM:@"isQuestioner"] forKey:@"isQuestioner"];
//        }
//        [dicM_Temp setObject:[NSString stringWithFormat:@"%@", [dic_SelectedItem objectForKey:@"groupId"]] forKey:@"groupId"];
//    }
//    else
//    {
//        [self.arM_List addObject:dicM_Temp];
//    }
//    
//    [self.tbv_List reloadData];
//    
//    if( isReplyMode == NO )
//    {
//        CGPoint offset = CGPointMake(0, self.tbv_List.contentSize.height - self.tbv_List.frame.size.height);
//        [self.tbv_List setContentOffset:offset animated:NO];
//    }
//    else
//    {
//        NSIndexPath *indexPath = [NSIndexPath indexPathForRow:nSelectedIdx inSection:0];
//        [self.tbv_List scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionBottom animated:NO];
//    }
    
    
    NSMutableString *strM = [NSMutableString string];
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
    //멕시카나할인한데이
    //[]{}#%^*+=_/
    [strM appendString:str_Tmp];

    //    vc.str_QnAId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"groupId"]];
    //    vc.str_Idx = [NSString stringWithFormat:@"%@", [dic objectForKey:@"questionId"]];
    //    vc.str_GroupId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"groupId"]];

    [MBProgressHUD hide];

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"questionId"]], @"questionId",
                                        strM, @"replyContents",
                                        isReplyMode ? @"replay" : @"qna", @"replyType",   //질문, 답변 여부 [qna-질문, replay-답글)
                                        isReplyMode ? [NSString stringWithFormat:@"%@", [dic_SelectedItem objectForKey:@"groupId"]] : @"0", @"replyId",     // [질문일 경우 0, 답변일 경우 해당 질문의 qnaId]
                                        nil];
    //    groupId = 12725;
    if( isReplyMode )
    {
        [dicM_Params setObject:[NSString stringWithFormat:@"%@", [dic_SelectedItem objectForKey:@"groupId"]] forKey:@"groupId"];
    }
    __weak __typeof(&*self)weakSelf = self;
    
    BOOL isReply = isReplyMode;
    [self.v_CommentKeyboardAccView removeContents];
    [self.view endEditing:YES];

    NSString *str_Key = [NSString stringWithFormat:@"DefaultChannelId_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSString *str_DefaultChannelId = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
    if( str_DefaultChannelId && str_DefaultChannelId.length > 0 )
    {
        [dicM_Params setObject:str_DefaultChannelId forKey:@"managerChannelId"];
    }

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/add/reply/question/and/view"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
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
                                                                                                                 @"userId":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]}
                                                                                                       options:NSJSONWritingPrettyPrinted
                                                                                                         error:&error];
                                                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                    
//                                                    [SendBird sendMessage:@"regist-reply" withData:jsonString];
                                                }
                                                else
                                                {
                                                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"questionId":[resulte objectForKey:@"questionId"],
                                                                                                                 @"eId":[resulte objectForKey:@"qnaId"],
                                                                                                                 @"userId":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]}
                                                                                                       options:NSJSONWritingPrettyPrinted
                                                                                                         error:&error];
                                                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//                                                    [SendBird sendMessage:@"regist-qna" withData:jsonString];
                                                }
                                                
                                                
                                                BOOL isLastObj = YES;

                                                if( isReply )
                                                {
                                                    for( NSInteger i = 0; i < weakSelf.arM_List.count; i++ )
                                                    {
                                                        NSDictionary *dic_Sub = weakSelf.arM_List[i];
                                                        NSInteger nEId = [[dic_Sub objectForKey:@"groupId"] integerValue];
                                                        NSInteger nParentEid = [[dic_SelectedItem objectForKey:@"groupId"] integerValue];
                                                        if( nEId == nParentEid )
                                                        {
                                                            NSInteger nPK = i;
                                                            for( NSInteger j = nPK; j < weakSelf.arM_List.count; j++ )
                                                            {
                                                                NSDictionary *dic_Sub2 = weakSelf.arM_List[j];
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
                                                                NSDictionary *dic_Tmp = [weakSelf.arM_List lastObject];
                                                                NSInteger nPrevReplyIdx = [[dic_Tmp objectForKey:@"replyInx"] integerValue];
                                                                
                                                                NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:resulte];
                                                                [dicM setObject:[NSString stringWithFormat:@"%ld", ++nPrevReplyIdx] forKey:@"replyInx"];
                                                                
                                                                [weakSelf.arM_List addObject:resulte];
                                                            }
                                                            else
                                                            {
                                                                NSDictionary *dic_Tmp = [weakSelf.arM_List objectAtIndex:nPK - 1];
                                                                NSInteger nPrevReplyIdx = [[dic_Tmp objectForKey:@"replyInx"] integerValue];
                                                                
                                                                NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:resulte];
                                                                [dicM setObject:[NSString stringWithFormat:@"%ld", ++nPrevReplyIdx] forKey:@"replyInx"];
                                                                
                                                                [weakSelf.arM_List insertObject:dicM atIndex:nPK];
                                                            }
                                                            break;
                                                        }
                                                    }
                                                    
                                                    //혹시라도 같은게 있으면 빼주기 (중복되어 올라오는 현상에 대한 방어코드)
                                                    for( NSInteger i = 0; i < weakSelf.arM_List.count - 1; i++ )
                                                    {
                                                        NSDictionary *dic_Current = weakSelf.arM_List[i];
                                                        NSDictionary *dic_Next = weakSelf.arM_List[i + 1];
                                                        
                                                        if( [[dic_Current objectForKey_YM:@"eId"] integerValue] == [[dic_Next objectForKey_YM:@"eId"] integerValue] )
                                                        {
                                                            [weakSelf.arM_List removeObjectAtIndex:i + 1];
                                                            break;
                                                        }
                                                    }
                                                    
                                                    [weakSelf.tbv_List reloadData];
                                                    
                                                    if( isLastObj )
                                                    {
                                                        if (weakSelf.tbv_List.contentSize.height > weakSelf.tbv_List.frame.size.height)
                                                        {
                                                            CGPoint offset = CGPointMake(0, weakSelf.tbv_List.contentSize.height - weakSelf.tbv_List.frame.size.height);
                                                            [weakSelf.tbv_List setContentOffset:offset animated:YES];
                                                        }
                                                    }
                                                }
                                                else
                                                {
                                                    [weakSelf.arM_List addObject:resulte];
                                                    [weakSelf.tbv_List reloadData];

                                                    if (weakSelf.tbv_List.contentSize.height > weakSelf.tbv_List.frame.size.height)
                                                    {
                                                        CGPoint offset = CGPointMake(0, weakSelf.tbv_List.contentSize.height - weakSelf.tbv_List.frame.size.height);
                                                        [weakSelf.tbv_List setContentOffset:offset animated:YES];
                                                    }
                                                }
                                            }
                                            else
                                            {
                                                [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                            
//                                            [self.view endEditing:YES];
                                        }
                                    }];
}

- (void)onShowAlbumInterval
{
    isReplyMode = YES;
    self.v_CommentKeyboardAccView.tv_Contents.placeholder = @"답글하기...";
}

- (IBAction)goShowAlbum:(id)sender
{
    if( isReplyMode == YES )
    {
        [self performSelector:@selector(onShowAlbumInterval) withObject:nil afterDelay:1.0f];
    }

    [self.view endEditing:YES];
    
    [OHActionSheet showSheetInView:self.view
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
                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                     [self presentViewController:imagePickerController animated:YES completion:nil];
                 }];
             }
             else
             {
                 [self presentViewController:imagePickerController animated:YES completion:nil];
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
                     [self presentViewController:imagePickerController animated:YES completion:nil];
                 }];
             }
             else
             {
                 [self presentViewController:imagePickerController animated:YES completion:nil];
             }
         }
         else if( buttonIndex == 2 )
         {
             UIImagePickerController* imagePickerController = [[UIImagePickerController alloc] init];
             imagePickerController.sourceType = UIImagePickerControllerSourceTypeCamera;
             imagePickerController.videoQuality = UIImagePickerControllerQualityTypeHigh;
             imagePickerController.mediaTypes = [NSArray arrayWithObject:(NSString *)kUTTypeMovie];
             imagePickerController.delegate = self;

             if(IS_IOS8_OR_ABOVE)
             {
                 [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                     [self presentViewController:imagePickerController animated:YES completion:nil];
                 }];
             }
             else
             {
                 [self presentViewController:imagePickerController animated:YES completion:nil];
             }
         }
         else
         {
             isReplyMode = NO;
             self.v_CommentKeyboardAccView.tv_Contents.placeholder = kChatPlaceHolder;
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
        
        UIImage *resizeImage = [Util imageWithImage:thumb convertToWidth:self.view.bounds.size.width - 30];
        
        NSData *videoData = [NSData dataWithContentsOfURL:videoUrl];
        [self uploadData:@{@"type":@"video", @"obj":videoData, @"thumb":UIImageJPEGRepresentation(resizeImage, 0.3f)}];
    }
    else
    {
        UIImage* outputImage = [info objectForKey:UIImagePickerControllerEditedImage] ? [info objectForKey:UIImagePickerControllerEditedImage] : [info objectForKey:UIImagePickerControllerOriginalImage];
        
        UIImage *resizeImage = [Util imageWithImage:outputImage convertToWidth:self.view.bounds.size.width - 30];
        
        [self uploadData:@{@"type":@"image", @"obj":UIImageJPEGRepresentation(resizeImage, 0.3f), @"thumb":resizeImage}];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [UIView animateWithDuration:0.3f animations:^{
        
        [self.tbv_List scrollRectToVisible:CGRectMake(self.tbv_List.contentSize.width - 1, self.tbv_List.contentSize.height - 1, 1, 1) animated:YES];
    }];
}

- (void)uploadData:(NSDictionary *)dic
{
    __weak __typeof__(self) weakSelf = self;
    
    __block NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"questionId"]], @"questionId",
                                        @"reply", @"uploadItem",
                                        [dicM objectForKey:@"type"], @"type",
                                        nil];
    
    [[WebAPI sharedData] imageUpload:@"v1/attach/file/uploader"
                               param:dicM_Params
                          withImages:[NSDictionary dictionaryWithObject:[dicM objectForKey:@"obj"] forKey:@"file"]
                           withBlock:^(id resulte, NSError *error) {
                               
                               if( resulte )
                               {
                                   NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                   if( nCode == 200 )
                                   {
                                       /*
                                        "error_code" = success;
                                        "error_message" = success;
                                        fileName = "/usr/local/tomcat-NEW-THOTING-JM-MOBILE-DEMO/webapps/c_edujm/temp/108";
                                        filePath = "/usr/local/tomcat-NEW-THOTING-JM-MOBILE-DEMO/webapps/c_edujm/temp/108/ed08d72c8d583c859e2555e98dea2332.jpg";
                                        "response_code" = 200;
                                        serviceUrl = "/c_edujm/temp/108/ed08d72c8d583c859e2555e98dea2332.jpg";
                                        success = success;
                                        tempUploadId = 38;
                                        */
                                       
                                       __block NSDictionary *dic_Old = [NSDictionary dictionaryWithDictionary:resulte];
                                       if( [[dic objectForKey:@"type"] isEqualToString:@"video"] )
                                       {
                                           NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                               [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                                               [Util getUUID], @"uuid",
                                                                               [resulte objectForKey:@"tempUploadId"], @"videoTempUploadId",
                                                                               [resulte objectForKey:@"serviceUrl"], @"videoServiceUrl",
                                                                               @"reply", @"uploadItem",
                                                                               @"image", @"type",
                                                                               nil];
                                           
                                           [[WebAPI sharedData] imageUpload:@"v1/attach/video/cover/image/uploader"
                                                                      param:dicM_Params
                                                                 withImages:[NSDictionary dictionaryWithObject:[dicM objectForKey:@"thumb"] forKey:@"file"]
                                                                  withBlock:^(id resulte, NSError *error) {
                                                                      
                                                                      if( resulte )
                                                                      {
                                                                          NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                                                          if( nCode == 200 )
                                                                          {
                                                                              [dicM setObject:[NSString stringWithFormat:@"%@", [dic_Old objectForKey:@"tempUploadId"]] forKey:@"tempUploadId"];
                                                                              [dicM setObject:[NSString stringWithFormat:@"%@", [dic_Old objectForKey:@"serviceUrl"]] forKey:@"serviceUrl"];
                                                                              [weakSelf upLoadContents:dicM];
                                                                          }
                                                                          else
                                                                          {
                                                                              [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                                          }
                                                                      }
                                                                      else
                                                                      {
                                                                          [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                                      }
                                                                  }];
                                       }
                                       else
                                       {
                                           [dicM setObject:[NSString stringWithFormat:@"%@", [resulte objectForKey:@"tempUploadId"]] forKey:@"tempUploadId"];
                                           [dicM setObject:[NSString stringWithFormat:@"%@", [resulte objectForKey:@"serviceUrl"]] forKey:@"serviceUrl"];
                                           [weakSelf upLoadContents:dicM];
                                       }
                                   }
                                   else
                                   {
                                       [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                   }
                               }
                               else
                               {
                                   [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                               }
                           }];
}

- (void)upLoadContents:(NSDictionary *)dic
{
    NSMutableString *strM = [NSMutableString string];
    
//    if( [[dic objectForKey:@"type"] isEqualToString:@"video"] )
    [strM appendString:@"0"];
    [strM appendString:@"-"];
    
    [strM appendString:[dic objectForKey:@"type"]];
    [strM appendString:@"-"];
    
    [strM appendString:[NSString stringWithFormat:@"%@", [dic objectForKey:@"tempUploadId"]]];
    [strM appendString:@"-"];
    
    [strM appendString:@"N"];
    [strM appendString:@"-"];
    
    [strM appendString:[dic objectForKey:@"serviceUrl"]];

    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        [NSString stringWithFormat:@"%@", [self.dic_Info objectForKey:@"questionId"]], @"questionId",
                                        strM, @"replyContents",
                                        isReplyMode ? @"replay" : @"qna", @"replyType",   //질문, 답변 여부 [qna-질문, replay-답글)
                                        isReplyMode ? [NSString stringWithFormat:@"%@", [dic_SelectedItem objectForKey:@"groupId"]] : @"0", @"replyId",     // [질문일 경우 0, 답변일 경우 해당 질문의 qnaId]
                                        isReplyMode ? [NSString stringWithFormat:@"%@", [dic_SelectedItem objectForKey:@"groupId"]] : @"0", @"groupId",
                                        nil];
    
    BOOL isReply = isReplyMode;
    [self.v_CommentKeyboardAccView removeContents];
    [self.view endEditing:YES];

    __weak __typeof(&*self)weakSelf = self;
    
    NSString *str_Key = [NSString stringWithFormat:@"DefaultChannelId_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    NSString *str_DefaultChannelId = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
    if( str_DefaultChannelId && str_DefaultChannelId.length > 0 )
    {
        [dicM_Params setObject:str_DefaultChannelId forKey:@"managerChannelId"];
    }

    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/add/reply/question/and/view"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        [MBProgressHUD hide];
                                        
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
                                                                                                                 @"userId":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]}
                                                                                                       options:NSJSONWritingPrettyPrinted
                                                                                                         error:&error];
                                                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                                                    
//                                                    [SendBird sendMessage:@"regist-reply" withData:jsonString];
                                                }
                                                else
                                                {
                                                    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:@{@"questionId":[resulte objectForKey:@"questionId"],
                                                                                                                 @"eId":[resulte objectForKey:@"qnaId"],
                                                                                                                 @"userId":[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]}
                                                                                                       options:NSJSONWritingPrettyPrinted
                                                                                                         error:&error];
                                                    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//                                                    [SendBird sendMessage:@"regist-qna" withData:jsonString];
                                                }
                                                
                                                
                                                BOOL isLastObj = YES;
                                                
                                                if( isReply )
                                                {
                                                    for( NSInteger i = 0; i < weakSelf.arM_List.count; i++ )
                                                    {
                                                        NSDictionary *dic_Sub = weakSelf.arM_List[i];
                                                        NSInteger nEId = [[dic_Sub objectForKey:@"groupId"] integerValue];
                                                        NSInteger nParentEid = [[dic_SelectedItem objectForKey:@"groupId"] integerValue];
                                                        if( nEId == nParentEid )
                                                        {
                                                            NSInteger nPK = i;
                                                            for( NSInteger j = nPK; j < weakSelf.arM_List.count; j++ )
                                                            {
                                                                NSDictionary *dic_Sub2 = weakSelf.arM_List[j];
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
                                                                NSDictionary *dic_Tmp = [weakSelf.arM_List lastObject];
                                                                NSInteger nPrevReplyIdx = [[dic_Tmp objectForKey:@"replyInx"] integerValue];
                                                                
                                                                NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:resulte];
                                                                [dicM setObject:[NSString stringWithFormat:@"%ld", ++nPrevReplyIdx] forKey:@"replyInx"];
                                                                
                                                                [weakSelf.arM_List addObject:resulte];
                                                            }
                                                            else
                                                            {
                                                                NSDictionary *dic_Tmp = [weakSelf.arM_List objectAtIndex:nPK - 1];
                                                                NSInteger nPrevReplyIdx = [[dic_Tmp objectForKey:@"replyInx"] integerValue];
                                                                
                                                                NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:resulte];
                                                                [dicM setObject:[NSString stringWithFormat:@"%ld", ++nPrevReplyIdx] forKey:@"replyInx"];
                                                                
                                                                [weakSelf.arM_List insertObject:dicM atIndex:nPK];
                                                            }
                                                            break;
                                                        }
                                                    }
                                                    
                                                    //혹시라도 같은게 있으면 빼주기 (중복되어 올라오는 현상에 대한 방어코드)
                                                    for( NSInteger i = 0; i < weakSelf.arM_List.count - 1; i++ )
                                                    {
                                                        NSDictionary *dic_Current = weakSelf.arM_List[i];
                                                        NSDictionary *dic_Next = weakSelf.arM_List[i + 1];
                                                        
                                                        if( [[dic_Current objectForKey_YM:@"eId"] integerValue] == [[dic_Next objectForKey_YM:@"eId"] integerValue] )
                                                        {
                                                            [weakSelf.arM_List removeObjectAtIndex:i + 1];
                                                            break;
                                                        }
                                                    }
                                                    
                                                    [weakSelf.tbv_List reloadData];
                                                    
                                                    if( isLastObj )
                                                    {
                                                        if (weakSelf.tbv_List.contentSize.height > weakSelf.tbv_List.frame.size.height)
                                                        {
                                                            CGPoint offset = CGPointMake(0, weakSelf.tbv_List.contentSize.height - weakSelf.tbv_List.frame.size.height);
                                                            [weakSelf.tbv_List setContentOffset:offset animated:YES];
                                                        }
                                                    }
                                                }
                                                else
                                                {
                                                    [weakSelf.arM_List addObject:resulte];
                                                    [weakSelf.tbv_List reloadData];
                                                    
                                                    if (weakSelf.tbv_List.contentSize.height > weakSelf.tbv_List.frame.size.height)
                                                    {
                                                        CGPoint offset = CGPointMake(0, weakSelf.tbv_List.contentSize.height - weakSelf.tbv_List.frame.size.height);
                                                        [self.tbv_List setContentOffset:offset animated:YES];
                                                    }
                                                }
//                                                [self.v_CommentKeyboardAccView removeContents];
                                            }
                                            else
                                            {
                                                [weakSelf.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                            
//                                            [self.view endEditing:YES];
                                        }
                                    }];
}

@end
