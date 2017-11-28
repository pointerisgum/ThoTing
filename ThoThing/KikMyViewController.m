//
//  KikMyViewController.m
//  ThoThing
//
//  Created by macpro15 on 2017. 9. 23..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "KikMyViewController.h"
#import "KikMyCell.h"
#import "OptionViewController.h"
#import "SharpChannelMainViewController.h"
#import "ReciveSendViewController.h"
#import "WrongAnsStarViewController.h"
#import "ReportMainViewController.h"
#import "ChatFeedViewController.h"
#import "KikMyBotCollectionCell.h"
#import "KikTbvBotCell.h"
#import "MWPhotoBrowser.h"
//#import <AVKit/AVKit.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import "MyAccountViewController.h"
#import "KikRoomInfoViewController.h"

@interface KikMyViewController () <UICollectionViewDelegate, UICollectionViewDataSource, MWPhotoBrowserDelegate, UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, DZImageEditingControllerDelegate>
{
    NSString *str_UserImagePrefix;
    NSString *str_TargetName;
    NSString *str_UserImageUrl;
    
    MWPhotoBrowser *browser;
}
//@property (strong, nonatomic) SBDGroupChannel *channel;
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) NSMutableArray *arM_Bot;
@property (nonatomic, strong) NSMutableArray *ar_Photo;
@property (nonatomic, strong) NSMutableArray *thumbs;
@property (nonatomic, strong) UIImageView *overlayImageView;
@property (nonatomic, assign) CGRect frameRect;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Main;
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Name;
@property (nonatomic, weak) IBOutlet UIButton *btn_Tag;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet UIButton *btn_JoinChat;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_TopHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_TbvHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_CvHeight;
@property (nonatomic, weak) IBOutlet UICollectionView *cv_Bot;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ContentsHeight;
@property (nonatomic, weak) IBOutlet UIButton *btn_Share;
@property (nonatomic, weak) IBOutlet UIButton *btn_Info;
@end

@implementation KikMyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIImage *overlayImage = [UIImage imageNamed:@"kik_image_edith.png"];
    CGFloat newX = [UIScreen mainScreen].bounds.size.width / 2 - [UIScreen mainScreen].bounds.size.width / 2;
    CGFloat newY = [UIScreen mainScreen].bounds.size.height / 2 - [UIScreen mainScreen].bounds.size.width / 2;
    self.frameRect = CGRectMake(newX, newY, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.width);
    self.overlayImageView = [[UIImageView alloc] initWithFrame:self.frameRect];
    self.overlayImageView.image = overlayImage;
    

    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.width / 2;
    self.iv_User.layer.borderColor = [UIColor colorWithRed:245.f/255.f green:245.f/255.f blue:245.f/255.f alpha:1].CGColor;
    self.iv_User.layer.borderWidth = 1.f;
    
//    [self.arM_List addObject:@{@"title":@"내 계정", @"icon":@"kik_user.png"}];
//    [self.arM_List addObject:@{@"title":@"라이브러리", @"icon":@"kik_menu_libary.png"}];
//    [self.arM_List addObject:@{@"title":@"오답. 별표", @"icon":@"kik_start.png"}];
//    [self.arM_List addObject:@{@"title":@"받은 문제. 보낸 문제", @"icon":@"kik_recive_send.png"}];
//    [self.arM_List addObject:@{@"title":@"레포트", @"icon":@"kik_report.png"}];
//    [self.arM_List addObject:@{@"title":@"대화 설정", @"icon":@""}];
//    [self.arM_List addObject:@{@"title":@"도움말 및 토팅 정보", @"icon":@""}];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden = YES;
    
    self.lc_TbvHeight.constant = 0.f;

    __weak __typeof__(self) weakSelf = self;

    self.arM_List = [NSMutableArray array];
    
    NSString *str_MyId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    
    if( [str_MyId isEqualToString:self.user.userId] )
    {
        self.btn_Info.hidden = YES;
        self.btn_Share.hidden = NO;
        
        self.lc_TopHeight.constant = 180.f;
        
        SBDUser *user = [SBDMain getCurrentUser];
        str_UserImageUrl = user.profileUrl;
        
        [self.arM_List addObject:@{@"title":@"나의 봇", @"icon":user.profileUrl}];
        [self.arM_List addObject:@{@"title":@"내 계정", @"icon":@"kik_user.png"}];
        [self.arM_List addObject:@{@"title":@"알림, 설정", @"icon":@"kik_setting.png"}];
        [self.arM_List addObject:@{@"title":@"도움말, 토팅 정보", @"icon":@"kik_setting.png"}];
        [self.arM_List addObject:@{@"title":@"봇들", @"icon":@"kik_bot.png"}];
        
        self.lc_TbvHeight.constant = self.arM_List.count * 55.f;
        
        [self.iv_User sd_setImageWithURL:[NSURL URLWithString:str_UserImageUrl]];
        self.lb_Name.text = user.nickname;
        //        [self.btn_Tag setTitle:str_HashTag forState:UIControlStateNormal];
        [self.tbv_List reloadData];
    }
    else
    {
        self.btn_Info.hidden = NO;
        self.btn_Share.hidden = YES;
        
        self.lb_Name.text = self.user.nickname;
        [self.iv_User sd_setImageWithURL:[NSURL URLWithString:self.user.profileUrl]];
        [self.btn_JoinChat setTitle:[NSString stringWithFormat:@"%@님과 챗 시작", self.user.nickname] forState:0];
        
        str_UserImageUrl = self.user.profileUrl;
        str_TargetName = self.user.nickname;
        
        if( self.isOneOneChatIng )
        {
            //1:1 챗중이면
            self.lc_TopHeight.constant = 180.f;
        }
        else
        {
            //챗중이 아니면
            self.lc_TopHeight.constant = 220.f;
        }
//        NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                            [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                                            [Util getUUID], @"uuid",
//                                            self.user.userId, @"pUserId",
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
//                                                    str_TargetName = [NSString stringWithFormat:@"%@", [resulte objectForKey_YM:@"userName"]];
//                                                    NSString *str_HashTag = [NSString stringWithFormat:@"%@", [resulte objectForKey_YM:@"hashtagStr"]];
//                                                    str_UserImageUrl = [NSString stringWithFormat:@"%@", [resulte objectForKey_YM:@"imgUrl"]];
//
//                                                    [weakSelf.iv_User sd_setImageWithURL:[NSURL URLWithString:str_UserImageUrl]];
//                                                    weakSelf.lb_Name.text = str_TargetName;
//                                                    //                                                    [weakSelf.btn_Tag setTitle:str_HashTag forState:UIControlStateNormal];
//                                                    [weakSelf.btn_JoinChat setTitle:[NSString stringWithFormat:@"%@님과 그룹 챗 시작", str_TargetName] forState:0];
//                                                }
//                                            }
//                                        }];
    }
    
    [self setMyChatBotList];
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

- (void)setMyChatBotList
{
    __weak __typeof(&*self)weakSelf = self;

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        self.user.userId, @"userId",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/my/chatbot/list"
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
                                                str_UserImagePrefix = [resulte objectForKey_YM:@"userImg_prefix"];
                                                weakSelf.arM_Bot = [NSMutableArray arrayWithArray:[resulte objectForKey:@"chatBotList"]];
                                                [weakSelf.cv_Bot reloadData];
                                                
                                                [weakSelf.view layoutIfNeeded];
                                                [weakSelf.view setNeedsDisplay];
                                                [weakSelf.view updateConstraints];

                                                weakSelf.lc_CvHeight.constant = weakSelf.cv_Bot.contentSize.height;

                                                weakSelf.lc_ContentsHeight.constant = weakSelf.cv_Bot.frame.origin.y + weakSelf.lc_CvHeight.constant;
                                                [weakSelf.sv_Main setContentSize:CGSizeMake(weakSelf.sv_Main.contentSize.width,
                                                                                            weakSelf.lc_ContentsHeight.constant)];
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
    return self.arM_List.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    KikMyCell *cell = [tableView dequeueReusableCellWithIdentifier:@"KikMyCell"];
    
    NSDictionary *dic = self.arM_List[indexPath.row];
    NSString *str_Title = [dic objectForKey:@"title"];
    cell.lb_Title.text = str_Title;
    
    if( [str_Title isEqualToString:@"나의 봇"] )
    {
        cell.iv_Icon.layer.cornerRadius = cell.iv_Icon.frame.size.width / 2;
        cell.sw.hidden = NO;
        
        [cell.iv_Icon sd_setImageWithURL:[NSURL URLWithString:str_UserImageUrl]];
//        [cell.iv_Icon setImageWithURL:[NSURL URLWithString:str_UserImageUrl] usingCache:NO];

        [cell.sw addTarget:self action:@selector(myBotValueChange:) forControlEvents:UIControlEventValueChanged];
    }
    else
    {
        cell.iv_Icon.layer.cornerRadius = 0.f;
        cell.sw.hidden = YES;
        
        cell.iv_Icon.image = BundleImage([dic objectForKey:@"icon"]);
        
        [cell.sw removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    }
    
    if( indexPath.row == 0 )
    {
        cell.iv_TopLine.hidden = YES;
    }
    else
    {
        cell.iv_TopLine.hidden = YES;
    }
    
    if( indexPath.row == self.arM_List.count - 1 )
    {
        cell.lc_LineLeft.constant = 0.f;
    }
    else
    {
        cell.lc_LineLeft.constant = 15.f;
    }
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *dic = self.arM_List[indexPath.row];
    NSString *str_Title = [dic objectForKey:@"title"];

    if( [str_Title isEqualToString:@"나의 봇"] )
    {
        
    }
    else if( [str_Title isEqualToString:@"내 계정"] )
    {
        MyAccountViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"MyAccountViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if( [str_Title isEqualToString:@"알림, 설정"] )
    {
        UIViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"AlrimMenuViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }
    else if( [str_Title isEqualToString:@"도움말, 토팅 정보"] )
    {
        UIViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"HelpMenuViewController"];
        [self.navigationController pushViewController:vc animated:YES];
    }

}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView *v_Section = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10)];
//    v_Section.backgroundColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1];
//    return v_Section;
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    id obj = self.arM_List[indexPath.row];
//    if( [obj isKindOfClass:[NSArray class]] )
//    {
//        return 120.f;
//    }
    
    return 55.f;
}

#pragma mark - CollectionView
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.arM_Bot.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"KikMyBotCollectionCell";
    
    KikMyBotCollectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NSDictionary *dic = self.arM_Bot[indexPath.row];
    
    /*
     bId = 36;
     botId = 127;
     botOwnerId = 138;
     botType = categoryBot;
     cc = 1;
     chatUserId = "<null>";
     displayName = "\Ubd073";
     examId = 3377;
     hashtagStr = "#\Ud0dc\Uadf81 #\Ubd07";
     questionId = 0;
     rId = 0;
     roomType = chatBot;
     sendbirdChannelUrl = "";
     thumbnail = "000/000/ca08edf9d2a43d5d90234633e95dccfd.jpg";
     userCount = 0;
     userEmail = "categorybot127@t.com";
     userId = 601;
     userName = "\Ubd073";
     userType = B;
     */

    NSString *str_UserImageUrl = [NSString stringWithFormat:@"%@%@", str_UserImagePrefix, [dic objectForKey_YM:@"thumbnail"]];
    [cell.iv_User sd_setImageWithURL:[NSURL URLWithString:str_UserImageUrl] placeholderImage:BundleImage(@"kik_no_user_30.png")];
    cell.lb_Title.text = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"displayName"]];
    cell.lb_Tag.text = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"hashtagStr"]];
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *dic = self.arM_Bot[indexPath.row];
    
    NSString *str_QuestionId = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"questionId"]];
    if( str_QuestionId == nil || str_QuestionId.length <= 0 || [str_QuestionId integerValue] <= 0 )
    {
        //퀘스쳔아이디가 없으면 방을 만들고 이동해야 함
//        [self makePublicGroup:[NSString stringWithFormat:@"%@", [dic objectForKey:@"userId"]] withTitle:[dic objectForKey_YM:@"displayName"] withCover:[dic objectForKey_YM:@"thumbnail"]];
    }
    else
    {
        KikRoomInfoViewController *vc = [kMyBoard instantiateViewControllerWithIdentifier:@"KikRoomInfoViewController"];
        vc.str_QuestionId = str_QuestionId;
        vc.roomType = kBot;
        //        vc.str_BotId = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"userId"]];
        vc.str_BotId = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"botId"]];
        vc.str_ChannelUrl = [dic objectForKey_YM:@"sendbirdChannelUrl"];
        [self.navigationController pushViewController:vc animated:YES];
    }
}


#pragma mark - ImagePickerDelegate
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [self dismissViewControllerAnimated:NO completion:^{
        
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        DZImageEditingController *editingViewController = [DZImageEditingController new];
        editingViewController.defaultScale = 1.0f;
        editingViewController.image = image;
        editingViewController.overlayView = self.overlayImageView;
        editingViewController.cropRect = self.frameRect;
        editingViewController.delegate = self;
        
        [self presentViewController:editingViewController
                           animated:YES
                         completion:nil];
    }];
    
//    [self dismissViewControllerAnimated:YES completion:^{
//
//    }];
}


#pragma mark - DZImageEditingControllerDelegate
- (void)imageEditingControllerDidCancel:(DZImageEditingController *)editingController
{
    [editingController dismissViewControllerAnimated:YES
                                          completion:nil];
}

- (void)imageEditingController:(DZImageEditingController *)editingController
     didFinishEditingWithImage:(UIImage *)editedImage
{
    //    [self.imageView setImage:editedImage];
    
//    UIImage* outputImage = [info objectForKey:UIImagePickerControllerEditedImage] ? [info objectForKey:UIImagePickerControllerEditedImage] : [info objectForKey:UIImagePickerControllerOriginalImage];
    
    self.iv_User.image = editedImage;
    
    CGFloat compression = 0.9f;
    CGFloat maxCompression = 0.1f;
    int maxFileSize = 5000000; //5메가
    
    NSData *imageData = UIImageJPEGRepresentation(editedImage, compression);
    
    while ([imageData length] > maxFileSize && compression > maxCompression)
    {
        compression -= 0.1;
        imageData = UIImageJPEGRepresentation(editedImage, compression);
    }
    
    __weak __typeof(&*self)weakSelf = self;
    
    weakSelf.iv_User.image = editedImage;
    
    //https://upload.wikimedia.org/wikipedia/commons/2/2c/Rotating_earth_%28large%29.gif
    SBDUser *user = [SBDMain getCurrentUser];
    [SBDMain updateCurrentUserInfoWithNickname:user.nickname profileImage:imageData progressHandler:^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
        
    } completionHandler:^(SBDError * _Nullable error) {
        
        if( error )
        {
            NSLog(@"sendbird image upload error");
        }
        else
        {
            SDImageCache *imageCache = [SDImageCache sharedImageCache];
            [imageCache clearMemory];
            [imageCache clearDisk];

            [[NSUserDefaults standardUserDefaults] setObject:user.profileUrl forKey:@"userPic"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            
            SBDUser *user = [SBDMain getCurrentUser];
            str_UserImageUrl = user.profileUrl;
            [weakSelf.iv_User sd_setImageWithURL:[NSURL URLWithString:str_UserImageUrl]];
            [weakSelf.tbv_List reloadData];

//            [SBDMain updateCurrentUserInfoWithNickname:user.nickname
//                                            profileUrl:user.profileUrl
//                                     completionHandler:^(SBDError * _Nullable error) {
//
//
//                                         [[NSUserDefaults standardUserDefaults] setObject:user.profileUrl forKey:@"userPic"];
//                                         [[NSUserDefaults standardUserDefaults] synchronize];
//
//                                         SBDUser *user = [SBDMain getCurrentUser];
//                                         str_UserImageUrl = user.profileUrl;
//                                         [weakSelf.iv_User sd_setImageWithURL:[NSURL URLWithString:str_UserImageUrl]];
//                                         [weakSelf.tbv_List reloadData];
//
//                                     }];
        }
    }];

    
    [editingController dismissViewControllerAnimated:YES
                                          completion:nil];
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


#pragma mark - IBAction
- (IBAction)goTag:(id)sender
{
    SharpChannelMainViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"SharpChannelMainViewController"];
    vc.isShowNavi = NO;
    vc.dic_Info = @{@"channelHashTag":[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"channelHashTag"]],
                    @"hashtagChannelId":[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"hashtagChannelId"]]};
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goJoinChat:(id)sender
{
    [self moveChat:self.user.userId];
}

- (void)moveChat:(NSString *)aInviteUser
{
    __weak __typeof(&*self)weakSelf = self;
    
    self.view.userInteractionEnabled = NO;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        @"", @"channelId",
                                        @"", @"roomName",
                                        aInviteUser, @"inviteUserIdStr",
                                        @"user", @"channelType",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/make/chat/room"
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
                                                NSDictionary *dic = [resulte objectForKey:@"qnaRoomInfo"];
                                                [self makeSendbird:dic withUserId:aInviteUser];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                        
                                        weakSelf.view.userInteractionEnabled = YES;
                                    }];
}

- (void)makeSendbird:(NSDictionary *)dic withUserId:(NSString *)aUserId
{
    NSString *str_SBDChannelUrl = [dic objectForKey_YM:@"sendbirdChannelUrl"];
    
    __block NSString *str_RId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"rId"]];
    //    NSString *str_ChannelUrl = [NSString stringWithFormat:@"thotingQuestion_main_%@", str_RId];
    NSString *str_ChannelName = [NSString stringWithFormat:@"thotingQuestion_main_%@_%@", @"1:1", str_RId];
    
    //isDistinct : YES 기존 채널 활용
    //isDistinct : NO 새로운 채널 생성
    
    NSMutableArray *arM_UserList = [NSMutableArray array];
    NSMutableDictionary *dicM_MyInfo = [NSMutableDictionary dictionary];
    [dicM_MyInfo setObject:[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]] forKey:@"userId"];
    [dicM_MyInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"] forKey:@"userName"];
    [dicM_MyInfo setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userPic"] forKey:@"imgUrl"];
    [arM_UserList addObject:dicM_MyInfo];
    
    //유저 이름 가져오기
    __block NSString *str_UserName = @"";
    __block NSString *str_UserThumb = @"";

    
    str_UserName = str_TargetName;
    str_UserThumb = str_UserImageUrl;
    
    NSMutableDictionary *dicM_TargetInfo = [NSMutableDictionary dictionary];
    [dicM_TargetInfo setObject:aUserId forKey:@"userId"];
    [dicM_TargetInfo setObject:str_UserName forKey:@"userName"];
    [dicM_TargetInfo setObject:str_UserThumb forKey:@"imgUrl"];
    [arM_UserList addObject:dicM_TargetInfo];
    

    //qnaRoomInfos로 감싸서 보낼것
    __block NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
    //    [dicM setObject:self.str_ChannelId forKey:@"channelIds"];
    [dicM setObject:arM_UserList forKey:@"userThumbnail"];
    
    NSDictionary *dic_QnaRoomInfos = [NSDictionary dictionaryWithObject:dicM forKey:@"qnaRoomInfos"];
    
    NSError * err;
    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic_QnaRoomInfos options:0 error:&err];
    __block NSString *str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    if( str_SBDChannelUrl && str_SBDChannelUrl.length > 0 )
    {
        [SBDGroupChannel getChannelWithUrl:str_SBDChannelUrl completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
            
            NSDictionary *dic_Tmp = [NSJSONSerialization JSONObjectWithData:[channel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
            NSDictionary *dic = [dic_Tmp objectForKey:@"qnaRoomInfos"];
            id tmp = [dic objectForKey_YM:@"channelIds"];
            NSMutableArray *arM_ChannelIds;
            if( [tmp isKindOfClass:[NSArray class]] == NO )
            {
                arM_ChannelIds = [NSMutableArray array];
            }
            else
            {
                arM_ChannelIds = [NSMutableArray arrayWithArray:[dic objectForKey:@"channelIds"]];
            }

            if( arM_ChannelIds == nil )
            {
                [dicM setObject:[NSArray array] forKey:@"channelIds"];
            }
            else
            {
                [dicM setObject:arM_ChannelIds forKey:@"channelIds"];
            }
            
            
            NSDictionary *dic_QnaRoomInfos = [NSDictionary dictionaryWithObject:dicM forKey:@"qnaRoomInfos"];
            
            NSError * err;
            NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic_QnaRoomInfos options:0 error:&err];
            str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
            
            __block NSString *str_BotId = nil;
            NSString *str_RoomType = [NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"roomType"]];
            if( [str_RoomType isEqualToString:@"chatBot"] )
            {
                str_BotId = self.user.userId;
            }

            [channel updateChannelWithName:self.user.nickname isDistinct:NO coverUrl:self.user.profileUrl data:str_Dic customType:[dicM objectForKey_YM:@"roomType"] completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
                
                //기존에 만든방이면
                UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
                ChatFeedViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedViewController"];
                vc.str_RId = str_RId;
                vc.dic_Info = dic;
                vc.str_RoomName = str_ChannelName;
                vc.str_RoomTitle = str_UserName;
                vc.str_RoomThumb = str_UserThumb;
                vc.ar_UserIds = @[aUserId];
                vc.channel = channel;
                vc.str_ChannelIdTmp = nil;
                if( [str_BotId integerValue] > 0 )
                {
                    vc.dic_BotInfo = @{@"userId":str_BotId};
                }
                [self.navigationController pushViewController:vc animated:YES];
            }];
        }];
    }
    else
    {
        //1:1방은 기존방 유지
        //userThumbnail : [{userId:{userId}, userName:{userName}, imgUrl:{이미지경로}]
        //방 이름은 그룹채팅일때만 쓰임
        //1:1은 유저 섬네일에서 가져와서 씀
        
        NSMutableArray *arM_ChannelId = [NSMutableArray array];
        //        if( self.str_ChannelId && self.str_ChannelId.length > 0 )
        //        {
        //            [arM_ChannelId addObject:self.str_ChannelId];
        //        }
        
        [dicM setObject:arM_ChannelId forKey:@"channelIds"];
        
        NSDictionary *dic_QnaRoomInfos = [NSDictionary dictionaryWithObject:dicM forKey:@"qnaRoomInfos"];

        NSError * err;
        NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic_QnaRoomInfos options:0 error:&err];
        __block NSString *str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
        __block NSString *str_BotId = nil;
        NSString *str_RoomType = [NSString stringWithFormat:@"%@", [dicM objectForKey_YM:@"roomType"]];
        if( [str_RoomType isEqualToString:@"chatBot"] )
        {
            str_BotId = self.user.userId;
        }
        
        
        [SBDGroupChannel createChannelWithName:self.user.nickname isDistinct:NO userIds:@[self.user.userId] coverUrl:self.user.profileUrl data:str_Dic customType:[dicM objectForKey_YM:@"roomType"]
                             completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
                                 
                                 if (error != nil)
                                 {
                                     NSLog(@"Error: %@", error);
                                     if( error.code == 400201 )
                                     {
                                         UIWindow *window = [[UIApplication sharedApplication] keyWindow];
                                         [window makeToast:@"가입된 회원이 아닙니다" withPosition:kPositionCenter];
                                     }
                                     return;
                                 }
                                 //sendbird_group_channel_33963702_f367360d2ae3758e8ea7bc29f321bdc57db463ce
                                 SBDBaseChannel *baseChannel = (SBDBaseChannel *)channel;
                                 NSLog(@"%@", baseChannel.channelUrl);
                                 [Util addChannelUrl:baseChannel.channelUrl withRId:str_RId];
                                 
                                 //https://sites.google.com/site/thotingapi/api/api-jeong-ui/api-list/chaetingbangsendbirdchannelurlbyeongyeong
                                 //여기에 채널url 등록
                                 
                                 UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Feed" bundle:nil];
                                 ChatFeedViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"ChatFeedViewController"];
                                 vc.str_RId = str_RId;
                                 vc.dic_Info = dic;
                                 vc.str_RoomName = str_ChannelName;
                                 vc.str_RoomTitle = str_UserName;
                                 vc.str_RoomThumb = str_UserThumb;
                                 vc.ar_UserIds = @[aUserId];
                                 vc.channel = channel;
                                 vc.str_ChannelIdTmp = nil;
                                 if( [str_BotId integerValue] > 0 )
                                 {
                                     vc.dic_BotInfo = @{@"userId":str_BotId};
                                 }
                                 [self.navigationController pushViewController:vc animated:YES];
                             }];
    }
}


//- (void)leave:(NSString *)aRId
//{
//    __weak __typeof(&*self)weakSelf = self;
//
//    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                                        [Util getUUID], @"uuid",
//                                        @"menu", @"pageInfo",
//                                        @"hide", @"setMode",
//                                        aRId, @"rId",
//                                        nil];
//
//    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/hide/my/qna/chat/room"
//                                        param:dicM_Params
//                                   withMethod:@"POST"
//                                    withBlock:^(id resulte, NSError *error) {
//
//                                        [MBProgressHUD hide];
//
//                                        if( resulte )
//                                        {
//                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
//                                            if( nCode == 200 )
//                                            {
//                                                NSString *str_MyName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
//                                                NSString *str_Msg = [NSString stringWithFormat:@"%@님이 나갔습니다.", str_MyName];
//                                                [weakSelf sendSendBirdPlatformApi:nil withMsg:str_Msg];
//
//                                                NSDictionary *dic_Tmp = [NSJSONSerialization JSONObjectWithData:[weakSelf.channel.data dataUsingEncoding:NSUTF8StringEncoding] options:0 error:nil];
//                                                NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:[dic_Tmp objectForKey:@"qnaRoomInfos"]];
//
//                                                if( 1 )
//                                                {
//                                                    [dicM setObject:[NSArray array] forKey:@"channelIds"];
//                                                    NSDictionary *dic_QnaRoomInfos = [NSDictionary dictionaryWithObject:dicM forKey:@"qnaRoomInfos"];
//                                                    NSError * err;
//                                                    NSData * jsonData = [NSJSONSerialization dataWithJSONObject:dic_QnaRoomInfos options:0 error:&err];
//                                                    NSString *str_Dic = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//                                                    [weakSelf.channel updateChannelWithName:weakSelf.channel.name
//                                                                                 isDistinct:weakSelf.channel.isDistinct
//                                                                                   coverUrl:weakSelf.channel.coverUrl
//                                                                                       data:str_Dic
//                                                                                 customType:weakSelf.channel.customType
//                                                                          completionHandler:^(SBDGroupChannel * _Nullable channel, SBDError * _Nullable error) {
//
//                                                                              [weakSelf.channel leaveChannelWithCompletionHandler:^(SBDError * _Nullable error) {
//
//                                                                              }];
//                                                                          }];
//                                                }
//                                            }
//                                            else
//                                            {
//                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
//                                            }
//                                        }
//                                    }];
//}

//- (void)sendSendBirdPlatformApi:(id)data withMsg:(NSString *)aMsg
//{
//    SBDUser *user = [SBDMain getCurrentUser];
//
////    NSString *str_UserId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
////    NSString *str_UserName = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
//
//    NSMutableDictionary *dicM_Param = [NSMutableDictionary dictionary];
//    [dicM_Param setObject:@"ADMM" forKey:@"message_type"];
//    [dicM_Param setObject:aMsg forKey:@"message"];
//    [dicM_Param setObject:@"cmd" forKey:@"custom_type"];
//
//    NSMutableDictionary *dicM_Data = [NSMutableDictionary dictionary];
//    [dicM_Data setObject:@"USER_LEFT" forKey:@"type"];
//
//    NSMutableDictionary *dicM_Inviter = [NSMutableDictionary dictionary];
//    [dicM_Inviter setObject:user.userId forKey:@"user_id"];
//    [dicM_Inviter setObject:user.nickname forKey:@"nickname"];
//    [dicM_Data setObject:dicM_Inviter forKey:@"sender"];
//
//
//    NSMutableArray *arM_Users = [NSMutableArray array];
//    NSArray *ar_Users = [NSArray arrayWithArray:data];
//    for( NSInteger i = 0; i < ar_Users.count; i++ )
//    {
//        NSDictionary *dic_User = ar_Users[i];
//        NSString *str_UserId = [NSString stringWithFormat:@"%@", [dic_User objectForKey:@"userId"]];
//        [arM_Users addObject:@{@"user_id":str_UserId, @"nickname":[dic_User objectForKey:@"userName"]}];
//    }
//    [dicM_Data setObject:arM_Users forKey:@"users"];
//
//    [dicM_Data setObject:aMsg forKey:@"message"];
//
//    NSError *error;
//    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dicM_Data
//                                                       options:NSJSONWritingPrettyPrinted
//                                                         error:&error];
//    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
//
//    [dicM_Param setObject:jsonString forKey:@"data"];
//
//    //        [dicM_Param setObject:@"true" forKey:@"is_silent"];
//    [dicM_Param setObject:@"true" forKey:@"is_silent"];
//
//    NSString *str_Path = [NSString stringWithFormat:@"v3/group_channels/%@/messages", self.channel.channelUrl];
//    [[WebAPI sharedData] callAsyncSendBirdAPIBlock:str_Path
//                                             param:dicM_Param
//                                        withMethod:@"POST"
//                                         withBlock:^(id resulte, NSError *error) {
//
//                                             if( resulte )
//                                             {
//
//                                             }
//                                         }];
//}

- (IBAction)goChatInfo:(id)sender
{
    __weak __typeof(&*self)weakSelf = self;

    NSMutableArray *arM_Menu = [NSMutableArray array];
    if( self.isOneOneChatIng )
    {
        //1:1 챗이면
        [arM_Menu addObject:[NSString stringWithFormat:@"%@님 차단", self.user.nickname]];
        [arM_Menu addObject:@"나가기"];
        [arM_Menu addObject:@"신고"];
    }
    else
    {
        [arM_Menu addObject:@"신고"];

    }
    
    [OHActionSheet showSheetInView:self.view
                             title:nil
                 cancelButtonTitle:@"취소"
            destructiveButtonTitle:nil
                 otherButtonTitles:arM_Menu
                        completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
     {
         if( self.isOneOneChatIng )
         {
             if( buttonIndex == 0 )
             {
                 //차단
                 [UIAlertController showAlertInViewController:self
                                                    withTitle:@""
                                                      message:[NSString stringWithFormat:@"%@님을 차단 하시겠습니까?", self.user.nickname]
                                            cancelButtonTitle:@"취소"
                                       destructiveButtonTitle:nil
                                            otherButtonTitles:@[@"확인"]
                                                     tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                                                         
                                                         if (buttonIndex == controller.cancelButtonIndex)
                                                         {
                                                             NSLog(@"Cancel Tapped");
                                                         }
                                                         else if (buttonIndex == controller.destructiveButtonIndex)
                                                         {
                                                             NSLog(@"Delete Tapped");
                                                         }
                                                         else if (buttonIndex >= controller.firstOtherButtonIndex)
                                                         {
                                                             NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                                                 [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                                                                 [Util getUUID], @"uuid",
                                                                                                 weakSelf.user.userId, @"blockUserId",
                                                                                                 @"on", @"blockStatus",
                                                                                                 nil];
                                                             
                                                             [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/user/set/block"
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
                                                                                                         [weakSelf.navigationController popToRootViewControllerAnimated:YES];
                                                                                                         [[NSNotificationCenter defaultCenter] postNotificationName:@"NOTI_RELOAD_DASHBOARD" object:nil];
                                                                                                     }
                                                                                                 }
                                                                                             }];
                                                         }
                                                     }];
             }
             else if( buttonIndex == 1 )
             {
                 //나가기
                 [self leaveChat];
             }
             else if( buttonIndex == 2 )
             {
                 //신고
                 [self reportChat];
             }
         }
         else
         {
             if( buttonIndex == 0 )
             {
                 //신고
                 [self reportChat];
             }
         }
     }];
}

- (void)reportChat
{
    //유저 페이지에서 신고는 해당 유저 신고뿐이 없음
    //방 신고는 챗방 정보에서 해야 함
    __weak __typeof(&*self)weakSelf = self;

    [UIAlertController showAlertInViewController:self
                                       withTitle:@""
                                         message:[NSString stringWithFormat:@"%@님을 신고하시겠습니까?", self.user.nickname]
                               cancelButtonTitle:@"취소"
                          destructiveButtonTitle:nil
                               otherButtonTitles:@[@"확인"]
                                        tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                                            
                                            if (buttonIndex == controller.cancelButtonIndex)
                                            {
                                                NSLog(@"Cancel Tapped");
                                            }
                                            else if (buttonIndex == controller.destructiveButtonIndex)
                                            {
                                                NSLog(@"Delete Tapped");
                                            }
                                            else if (buttonIndex >= controller.firstOtherButtonIndex)
                                            {
                                                NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                                                                    [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                                                                    [Util getUUID], @"uuid",
                                                                                    weakSelf.user.userId, @"reportUserId",
                                                                                    nil];
                                                
                                                [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/user/set/report"
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
                                                                                            [Util showToast:@"신고하였습니다"];
                                                                                        }
                                                                                    }
                                                                                }];
                                            }
                                        }];
}

- (void)leaveChat
{
    __weak __typeof(&*self)weakSelf = self;

    [UIAlertController showAlertInViewController:self
                                       withTitle:@""
                                         message:[NSString stringWithFormat:@"%@님과의 대화방을 나가시겠습니까?", self.user.nickname]
                               cancelButtonTitle:@"취소"
                          destructiveButtonTitle:nil
                               otherButtonTitles:@[@"확인"]
                                        tapBlock:^(UIAlertController *controller, UIAlertAction *action, NSInteger buttonIndex){
                                            
                                            if (buttonIndex == controller.cancelButtonIndex)
                                            {
                                                NSLog(@"Cancel Tapped");
                                            }
                                            else if (buttonIndex == controller.destructiveButtonIndex)
                                            {
                                                NSLog(@"Delete Tapped");
                                            }
                                            else if (buttonIndex >= controller.firstOtherButtonIndex)
                                            {
                                                [weakSelf.channel leaveChannelWithCompletionHandler:^(SBDError * _Nullable error) {
                                                    
                                                    [weakSelf performSelectorOnMainThread:@selector(onPopToRoomView) withObject:nil waitUntilDone:YES];
                                                }];
                                            }
                                        }];
}

- (void)onPopToRoomView
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)myBotValueChange:(id)sender
{
    NSMutableArray *arM = [NSMutableArray array];
    [arM addObject:@"대화하기"];
    [arM addObject:@"설정하기"];
    
    [OHActionSheet showSheetInView:self.view
                             title:nil
                 cancelButtonTitle:@"취소"
            destructiveButtonTitle:nil
                 otherButtonTitles:arM
                        completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
     {
         if( buttonIndex == 0 )
         {
             
         }
         else if( buttonIndex == 1 )
         {
             
         }
     }];
}

- (IBAction)goShare:(id)sender
{
    
}

- (IBAction)goThumbTouch:(id)sender
{
    NSString *str_MyId = [NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
    
    NSMutableArray *arM = [NSMutableArray array];
    [arM addObject:@"사진보기"];

    if( [str_MyId isEqualToString:self.user.userId] )
    {
        [arM addObject:@"사진찍기"];
        [arM addObject:@"기존 항목 선택"];
    }
    else
    {
        
    }
    
    [OHActionSheet showSheetInView:self.view
                             title:@"프로필 사진"
                 cancelButtonTitle:@"취소"
            destructiveButtonTitle:nil
                 otherButtonTitles:arM
                        completion:^(OHActionSheet* sheet, NSInteger buttonIndex)
     {
         if( buttonIndex == 0 )
         {
             //사진보기
             self.ar_Photo = [NSMutableArray array];
             self.thumbs = [NSMutableArray array];
             
             NSURL *url = [NSURL URLWithString:str_UserImageUrl];
             [self.thumbs addObject:[MWPhoto photoWithURL:url]];
             [self.ar_Photo addObject:[MWPhoto photoWithURL:url]];
             
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
             [self presentViewController:nc animated:YES completion:nil];
             
             double delayInSeconds = 3;
             dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
             dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
             });
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
             UIImagePickerController *imagePickerController = [[UIImagePickerController alloc]init];
             imagePickerController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
             //             imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, kUTTypeImage, nil];
             imagePickerController.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeImage, nil];
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
     }];
}
@end
