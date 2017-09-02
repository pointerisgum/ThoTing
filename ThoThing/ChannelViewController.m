//
//  ChannelViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 11. 30..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "ChannelViewController.h"
#import "AddChannelViewController.h"
#import "ChannelSelectCell.h"
#import "ChannelMainViewController.h"
#import "PageViewController.h"
#import "MyMainViewController.h"
#import "ChannelSideMenuViewController.h"
#import "UserControllListViewController.h"
#import "UserListViewController.h"
#import "ReportMainViewController.h"
#import "WrongAnsStarViewController.h"

@interface ChannelViewController ()
{
    NSString *str_ImagePrefix;
    NSString *str_UserImagePrefix;
    NSString *str_NoImagePrefix;
    
    NSString *str_DefaultChannelId;
    NSString *str_SideChannelId;
}
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) ChannelMainViewController *vc_ChannelMainViewController;
@property (nonatomic, strong) PageViewController *vc_PageViewController;
@property (nonatomic, strong) MyMainViewController *vc_MyMainViewController;
@property (nonatomic, weak) IBOutlet UIView *v_Guide;
@property (nonatomic, weak) IBOutlet UIView *v_Channel;
@property (nonatomic, weak) IBOutlet UIView *v_ChannelList;
@property (nonatomic, weak) IBOutlet UIButton *btn_ChannelSelect;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_TbvHeight;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_TbvHeightReal;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Dim;
@property (nonatomic, weak) IBOutlet UIButton *btn_Setting;


//채널관련

@end

@implementation ChannelViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self initNaviWithTitle:@"채널등록" withLeftItem:nil withRightItem:[self addChannelButtionItem] withColor:[UIColor colorWithHexString:@"F8F8F8"]];
    
    self.v_Guide.hidden = YES;
    
//    self.arM_List = [NSMutableArray array];
//    [self.arM_List addObject:@"My"];
    
    UITapGestureRecognizer *imageTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTap:)];
    [imageTap setNumberOfTapsRequired:1];
    [self.iv_Dim addGestureRecognizer:imageTap];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateList) name:@"ReloadNoti" object:nil];
    
    [self updateList];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = NO;
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"MyChannelInfo"];
    NSDictionary *resulte = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    NSString *str_ChannelName = [resulte objectForKey:@"channelName"];
    if( str_ChannelName && str_ChannelName.length > 0 )
    {
        [self.btn_ChannelSelect setTitle:[resulte objectForKey:@"channelName"] forState:UIControlStateNormal];
    }
    else
    {
        NSString *str_Name = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
        [self.btn_ChannelSelect setTitle:str_Name forState:UIControlStateNormal];
    }

//    [self updateList];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//#pragma mark - Navigation
//
//// In a storyboard-based application, you will often want to do a little preparation before navigation
//- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
//    // Get the new view controller using [segue destinationViewController].
//    // Pass the selected object to the new view controller.
//    
//    NSLog(@"@@@@@@");
//    
//    NSString *str_ChannelId = [[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedChannel"];
//    ChannelMainViewController *vc = (ChannelMainViewController *)[segue destinationViewController];
//    vc.str_ChannelId = str_ChannelId;
//
//}
//
//- (BOOL)shouldPerformSegueWithIdentifier:(NSString *)identifier sender:(id)sender
//{
//    if( [identifier isEqualToString:@"ChannelMainSegue"] )
//    {
//        NSString *str_ChannelId = [[NSUserDefaults standardUserDefaults] objectForKey:@"SelectedChannel"];
//        if( str_ChannelId == nil || [str_ChannelId integerValue] <= 0 )
//        {
//            return NO;
//        }
//        else
//        {
//        }
//    }
//    
//    return YES;
//}

- (void)updateList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
//                                        @"bookmark", @"listType",
                                        @"my", @"listType",
                                        nil];
    
    __weak __typeof__(self) weakSelf = self;
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/bookmark/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            str_ImagePrefix = [resulte objectForKey:@"img_prefix"];
                                            str_UserImagePrefix = [resulte objectForKey:@"userImg_prefix"];
                                            str_NoImagePrefix = [resulte objectForKey:@"no_image"];
                                            
                                            NSMutableArray *ar_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"channelInfos"]];
                                            NSMutableArray *arM_Tmp = [NSMutableArray array];
                                            for( NSInteger i = 0; i < ar_List.count; i++ )
                                            {
                                                //내가 관리자인 채널만 보이게 하기 위한 코드 (2017.05.12 피터님 요청)
                                                NSDictionary *dic_Tmp = [ar_List objectAtIndex:i];
                                                if( [[dic_Tmp objectForKey:@"memberLevel"] integerValue] <= 9 )
                                                {
                                                    [arM_Tmp addObject:dic_Tmp];
                                                }
                                            }
                                            
                                            ar_List = [NSMutableArray arrayWithArray:arM_Tmp];
                                            
                                            if( ar_List && ar_List.count >= 1 )
                                            {
                                                [weakSelf.btn_ChannelSelect setImage:BundleImage(@"channel_arrow.png") forState:UIControlStateNormal];
                                                
                                                NSDictionary *dic = [ar_List firstObject];
                                                str_SideChannelId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]];
                                            }
//                                            if( weakSelf.arM_List && weakSelf.arM_List.count > 0 && ar_List.count > weakSelf.arM_List.count && ar_List.count > 1 )
//                                            {
//                                                //채널을 추가로 등록 했을시
//                                                [weakSelf goToggleChannelList:nil];
//                                            }
                                            
                                            
                                            weakSelf.arM_List = [NSMutableArray array];
                                            [weakSelf.arM_List addObject:@"My"];
                                            [weakSelf.arM_List addObjectsFromArray:ar_List];
                                            [weakSelf.tbv_List reloadData];
                                            
                                            if( weakSelf.arM_List.count == 1 )
                                            {
//                                                weakSelf.v_Guide.hidden = NO;
                                                
                                                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                self.vc_MyMainViewController = [storyboard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
                                                self.vc_MyMainViewController.str_ChannelId = str_DefaultChannelId;
                                                [self displayContentController:self.vc_MyMainViewController];
                                            }
                                            else
                                            {
//                                                weakSelf.v_Guide.hidden = YES;
                                                
                                                for( NSInteger i = 1; i < weakSelf.arM_List.count; i++ )
                                                {
                                                    NSDictionary *dic = weakSelf.arM_List[i];
                                                    NSString *str_DefaulYn = [dic objectForKey:@"isDefault"];
                                                    if( [str_DefaulYn isEqualToString:@"Y"] )
                                                    {
                                                        str_DefaultChannelId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]];
                                                        break;
                                                    }
                                                }
                                                
                                                if( str_DefaultChannelId == 0 )
                                                {
                                                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                    self.vc_MyMainViewController = [storyboard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
                                                    [self displayContentController:self.vc_MyMainViewController];
                                                }
//                                                else if( weakSelf.arM_List.count == 2 )
//                                                {
//                                                    //선택한 채널이 한개면 바로 보여줌
//                                                    [self hideContentController:self.vc_ChannelMainViewController];
//                                                    [self hideContentController:self.vc_PageViewController];
//
//                                                    NSDictionary *dic = [weakSelf.arM_List firstObject];
//                                                    str_DefaultChannelId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]];
//
//                                                    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
//                                                    [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"MyChannelInfo"];
//                                                    [[NSUserDefaults standardUserDefaults] synchronize];
//                                                    
//                                                    if( str_DefaultChannelId == nil || [str_DefaultChannelId integerValue] == 0 )
//                                                    {
//                                                        str_DefaultChannelId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]];
//                                                    }
//                                                    
//                                                    [self performSelector:@selector(onShowChannelInterval) withObject:nil afterDelay:0.5f];
//                                                }
                                                else
                                                {
                                                    if( str_DefaultChannelId == nil || [str_DefaultChannelId integerValue] <= 0 )
                                                    {
                                                        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                        self.vc_MyMainViewController = [storyboard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
                                                        [self displayContentController:self.vc_MyMainViewController];

//                                                        //내가 선택한 채널이 없을 경우 리스트 쇼잉
//                                                        weakSelf.lc_TbvHeight.constant = self.view.frame.size.height - 64;
//                                                        [Util rotationImage:self.btn_ChannelSelect.imageView withRadian:-180];
//                                                        
//                                                        [UIView animateWithDuration:0.3f animations:^{
//                                                            
//                                                            [self.view layoutIfNeeded];
//                                                        }];
                                                    }
                                                    else
                                                    {
                                                        //내가 선택한 채널이 없는 경우
                                                        BOOL isFindDefualtChannel = NO;
                                                        for( NSInteger i = 1; i < weakSelf.arM_List.count; i++ )
                                                        {
                                                            NSDictionary *dic = weakSelf.arM_List[i];
                                                            NSString *str_DefaulYn = [dic objectForKey:@"isDefault"];
                                                            if( [str_DefaulYn isEqualToString:@"Y"] )
                                                            {
                                                                isFindDefualtChannel = YES;
                                                                break;
                                                            }
                                                        }

                                                        if( isFindDefualtChannel == NO )
                                                        {
//                                                            [weakSelf goToggleChannelList:nil];
                                                            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                            self.vc_MyMainViewController = [storyboard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
                                                            self.vc_MyMainViewController.str_ChannelId = str_DefaultChannelId;
                                                            [self displayContentController:self.vc_MyMainViewController];
                                                        }
                                                        else
                                                        {
                                                            //내가 선택한 채널이 있는 경우
                                                            [self performSelector:@selector(onShowChannelInterval) withObject:nil afterDelay:0.5f];
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }];
}

- (void)onShowChannelInterval
{
    [self saveDefaultChannel];
    
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"MyChannelInfo"];
    NSDictionary *dic = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    if( [[dic objectForKey:@"channelType"] isEqualToString:@"channel"] )
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Channel" bundle:nil];
        self.vc_ChannelMainViewController = [storyboard instantiateViewControllerWithIdentifier:@"ChannelMainViewController"];
        self.vc_ChannelMainViewController.str_ChannelId = str_DefaultChannelId;
        [self displayContentController:self.vc_ChannelMainViewController];
    }
    else
    {
        UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Channel" bundle:nil];
        self.vc_PageViewController = [storyBoard instantiateViewControllerWithIdentifier:@"PageViewController"];
        
        NSString *str_ChannelId = [NSString stringWithFormat:@"%@", [dic objectForKey_YM:@"hashtagChannelId"]];
        if( str_ChannelId == nil || str_ChannelId.length <= 0 )
        {
            str_ChannelId =  [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]];
        }
        
        NSString *str_HashTag = [dic objectForKey_YM:@"channelHashTag"];
        if( str_HashTag == nil || str_HashTag.length <= 0 )
        {
            str_HashTag = [dic objectForKey_YM:@"hashTagStr"];
        }
        
        self.vc_PageViewController.str_ChannelHashTag = str_HashTag;
        self.vc_PageViewController.str_HashtagChannelId = str_ChannelId;
        self.vc_PageViewController.str_ChannelType = [dic objectForKey:@"channelType"];
        [self displayContentController:self.vc_PageViewController];
    }
    
    NSString *str_ChannelName = [dic objectForKey:@"channelName"];
    if( str_ChannelName && str_ChannelName.length > 0 )
    {
        [self.btn_ChannelSelect setTitle:[dic objectForKey:@"channelName"] forState:UIControlStateNormal];
    }
    else
    {
        NSString *str_Name = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
        [self.btn_ChannelSelect setTitle:str_Name forState:UIControlStateNormal];
    }

    if( [[dic objectForKey:@"channelType"] isEqualToString:@"channel"] )
    {
//        NSString *str_ImageUrl = [dic objectForKey:@"channelImgUrl"];
//        if( str_ImageUrl == nil || str_ImageUrl.length <= 0 )
//        {
//            str_ImageUrl = [dic objectForKey:@"imgUrl"];
//        }
//        
//        NSURL *url = [Util createImageUrl:str_UserImagePrefix withFooter:str_ImageUrl];
//        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//        
//        [iv sd_setImageWithURL:url placeholderImage:nil options:SDWebImageHighPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//            
//            CGSize size = CGSizeMake(30, 30);
//            UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
//            [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
//            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//            UIGraphicsEndImageContext();
//            
//            
//            // Begin a new image that will be the new image with the rounded corners
//            // (here with the size of an UIImageView)
//            UIGraphicsBeginImageContextWithOptions(newImage.size, NO, [UIScreen mainScreen].scale);
//            
//            // Add a clip before drawing anything, in the shape of an rounded rect
//            [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, newImage.size.width, newImage.size.height)
//                                        cornerRadius:size.width/2] addClip];
//            // Draw your image
//            [newImage drawInRect:CGRectMake(0, 0, newImage.size.width, newImage.size.height)];
//            
//            // Get the image, here setting the UIImageView image
//            newImage = UIGraphicsGetImageFromCurrentImageContext();
//            
//            // Lets forget about that we were drawing
//            UIGraphicsEndImageContext();
        
            
            //        UITabBarItem *item = [self.tabBar.items objectAtIndex:2];

            /*************하단 구조 바뀌며 주석처리함 20170607*************/
//            UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:2];
//            item.image = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//            item.selectedImage = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
            
//        }];
    }
    else
    {
        /*************하단 구조 바뀌며 주석처리함 20170607*************/
//        UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:2];
//        item.image = BundleImage(@"hashtag.png");
//        item.selectedImage = BundleImage(@"hashtag.png");
    }
}

- (void)displayContentController: (UIViewController*) content;
{
    [self addChildViewController:content];
    
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    [content.view setFrame:CGRectMake(0.0f, 0.0f, self.v_Channel.frame.size.width, window.frame.size.height - (64 + 49))];
    self.v_Channel.frame = CGRectMake(0, 64, self.v_Channel.frame.size.width, window.frame.size.height - (64 + 49));
    [self.v_Channel addSubview:content.view];
    [content didMoveToParentViewController:self];
    self.vc_ChannelMainViewController.navigationController.navigationBarHidden = YES;
}

- (void)hideContentController:(UIViewController *)content
{
    [content willMoveToParentViewController:nil];
    [content.view removeFromSuperview];
    [content removeFromParentViewController];
}

- (void)imageTap:(UIGestureRecognizer *)gestureRecognizer
{
    [self goToggleChannelList:nil];
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
    ChannelSelectCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ChannelSelectCell"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    /*
     channelId = 5;
     channelName = "\Uc601\Uc5b4\Ub4e3\Uae30_\Uae30\Ucd9c";
     channelUrl = englishLC;
     imgUrl = "000/000/english_lc.png";
     isBookMark = N;
     isMemberAllow = A;
     memberLevel = 9;
     statusCode = T;
     */
    
    NSDictionary *dic = self.arM_List[indexPath.row];
    
    if( indexPath.row == 0 )
    {
        NSString *str_UserPic = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPic"];
        NSString *str_Name = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];

        NSURL *url = [Util createImageUrl:str_UserImagePrefix withFooter:str_UserPic];
        [cell.iv_User sd_setImageWithURL:url placeholderImage:BundleImage(@"no_image.png")];
        
        cell.lb_Title.text = str_Name;
        
        cell.btn_Check.selected = NO;
        
        if( str_DefaultChannelId == nil || [str_DefaultChannelId isEqualToString:@"0"] )
        {
            cell.btn_Check.selected = YES;
        }
    }
    else
    {
        if( [[dic objectForKey:@"channelType"] isEqualToString:@"channel"] )
        {
            NSURL *url = [Util createImageUrl:str_UserImagePrefix withFooter:[dic objectForKey:@"imgUrl"]];
            [cell.iv_User sd_setImageWithURL:url placeholderImage:BundleImage(@"no_image.png")];
        }
        else
        {
            cell.iv_User.image = BundleImage(@"hashtag.png");
        }
        
        cell.lb_Title.text = [dic objectForKey_YM:@"channelName"];
        
        cell.btn_Check.selected = NO;
        
        NSString *str_ChannelId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]];
        if( [str_DefaultChannelId isEqualToString:str_ChannelId] )
        {
            cell.btn_Check.selected = YES;
        }
    }

    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if( indexPath.row == 0 )
    {
        str_DefaultChannelId = @"0";
        
        NSString *str_Name = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
        [self.btn_ChannelSelect setTitle:str_Name forState:UIControlStateNormal];
        [self.tbv_List reloadData];
        
        self.lc_TbvHeight.constant = self.lc_TbvHeightReal.constant = 0;
        [Util rotationImage:self.btn_ChannelSelect.imageView withRadian:0];
        
        [UIView animateWithDuration:0.3f animations:^{
            
            [self.view layoutIfNeeded];
            
        }completion:^(BOOL finished) {
            
            NSData *data_Tmp = [[NSUserDefaults standardUserDefaults] objectForKey:@"MyChannelInfo"];
            NSMutableDictionary *dicM = [NSKeyedUnarchiver unarchiveObjectWithData:data_Tmp];
            [dicM setObject:str_Name forKey:@"channelName"];
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dicM];
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"MyChannelInfo"];
            [[NSUserDefaults standardUserDefaults] synchronize];

            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            self.vc_MyMainViewController = [storyboard instantiateViewControllerWithIdentifier:@"MyMainViewController"];
            //        self.vc_MyMainViewController.str_ChannelId = str_DefaultChannelId;
            [self displayContentController:self.vc_MyMainViewController];
            [self saveDefaultChannel];
        }];
        
        
//        NSString *str_ImageUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPic"];
//        NSURL *url = [Util createImageUrl:str_UserImagePrefix withFooter:str_ImageUrl];
//        UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//        
//        [iv sd_setImageWithURL:url placeholderImage:nil options:SDWebImageHighPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//            
//            CGSize size = CGSizeMake(30, 30);
//            UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
//            [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
//            UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//            UIGraphicsEndImageContext();
//            
//            UIGraphicsBeginImageContextWithOptions(newImage.size, NO, [UIScreen mainScreen].scale);
//            [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, newImage.size.width, newImage.size.height)
//                                        cornerRadius:size.width/2] addClip];
//            [newImage drawInRect:CGRectMake(0, 0, newImage.size.width, newImage.size.height)];
//            newImage = UIGraphicsGetImageFromCurrentImageContext();
//            UIGraphicsEndImageContext();
//
//            /*************하단 구조 바뀌며 주석처리함 20170607*************/
////            UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:2];
////            item.image = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
////            item.selectedImage = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        }];
    }
    else
    {
        NSDictionary *dic = self.arM_List[indexPath.row];
        
        [self.btn_ChannelSelect setTitle:[dic objectForKey:@"channelName"] forState:UIControlStateNormal];
        
        NSData *data = [NSKeyedArchiver archivedDataWithRootObject:dic];
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"MyChannelInfo"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        str_DefaultChannelId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]];
        [self performSelector:@selector(onShowChannelInterval) withObject:nil afterDelay:0.1f];
        
        [self.tbv_List reloadData];
        
        self.lc_TbvHeight.constant = self.lc_TbvHeightReal.constant = 0;
        [Util rotationImage:self.btn_ChannelSelect.imageView withRadian:0];
        
        [UIView animateWithDuration:0.3f animations:^{
            
            [self.view layoutIfNeeded];
            
        }completion:^(BOOL finished) {
            
            [self hideContentController:self.vc_ChannelMainViewController];
            [self hideContentController:self.vc_PageViewController];
            
            [self performSelector:@selector(onShowChannelInterval) withObject:nil afterDelay:0.1f];
        }];
    }
}

- (void)saveDefaultChannel
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"MyChannelInfo"];
    NSDictionary *resulte = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        str_DefaultChannelId, @"channelId",
                                        [resulte objectForKey:@"channelType"], @"channelType",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/set/channel/bookmark/default"
                                        param:dicM_Params
                                   withMethod:@"POST"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            
                                        }
                                    }];
}

- (IBAction)goToggleChannelList:(id)sender
{
    if( self.arM_List.count <= 1 )
    {
        return;
    }
    
    if( self.lc_TbvHeight.constant == 0 )
    {
        self.lc_TbvHeight.constant = self.lc_TbvHeightReal.constant = self.view.frame.size.height - 64;
        [Util rotationImage:self.btn_ChannelSelect.imageView withRadian:-180];
    }
    else
    {
        self.lc_TbvHeight.constant = 0;
        [Util rotationImage:self.btn_ChannelSelect.imageView withRadian:0];
    }
    
    [UIView animateWithDuration:0.3f animations:^{
       
        [self.view layoutIfNeeded];
    }completion:^(BOOL finished) {
        
        if( self.lc_TbvHeight.constant != 0 )
        {
            CGFloat fHight = 60 * self.arM_List.count;
            if( fHight <= self.view.frame.size.height - 64 )
            {
                self.lc_TbvHeightReal.constant = fHight;
            }
            else
            {
                self.lc_TbvHeightReal.constant = self.view.frame.size.height - 64;
            }
        }
        else
        {
            self.lc_TbvHeightReal.constant = 0;
        }
    }];
}

- (IBAction)goAddChannel:(id)sender
{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Channel" bundle:nil];
    AddChannelViewController *vc = [storyBoard instantiateViewControllerWithIdentifier:@"AddChannelViewController"];
    [self.navigationController pushViewController:vc animated:YES];
    
    self.lc_TbvHeight.constant = self.lc_TbvHeightReal.constant = 0;
    [Util rotationImage:self.btn_ChannelSelect.imageView withRadian:0];
}

- (IBAction)goSetting:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Setting" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"OptionViewController"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)goSideMenu:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    ChannelSideMenuViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChannelSideMenuViewController"];
    [vc setCompletionBlock:^(id completeResult) {
        
//        [self.arM_List addObject:@"팔로워 팔로우"];       //1
//        [self.arM_List addObject:@"피드"];                //4
//        [self.arM_List addObject:@"라이브러리"];             //6
//        [self.arM_List addObject:@"레포트"];               //8
//        [self.arM_List addObject:@"오답,별표"];             //9
//        [self.arM_List addObject:@"설정"];                //10

        if( [completeResult isEqualToString:@"팔로워 팔로우"] )
        {
            UserListViewController *vc = [kEtcBoard instantiateViewControllerWithIdentifier:@"UserListViewController"];
            vc.userStatusCode = kFollowing;
            vc.str_UserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
            [self.navigationController pushViewController:vc animated:YES];

//            NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
//                                                [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
//                                                [Util getUUID], @"uuid",
//                                                str_SideChannelId, @"channelId",
//                                                nil];
//            
//            [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/my"
//                                                param:dicM_Params
//                                           withMethod:@"GET"
//                                            withBlock:^(id resulte, NSError *error) {
//                                                
//                                                [MBProgressHUD hide];
//                                                
//                                                if( resulte )
//                                                {
//                                                    NSLog(@"resulte : %@", resulte);
//                                                    NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
//                                                    if( nCode == 200 )
//                                                    {
//                                                        NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:resulte];
//
//                                                        BOOL isMannager = [[dicM objectForKey:@"isChannelManager"] boolValue];
//
//                                                        UserControllListViewController *vc = [kEtcBoard instantiateViewControllerWithIdentifier:@"UserControllListViewController"];
//                                                        vc.isMannager = isMannager;
//                                                        vc.str_ChannelId = str_SideChannelId;
//                                                        vc.isChannel = YES;
//                                                        vc.str_Mode = @"follower";
//                                                        [self.navigationController pushViewController:vc animated:YES];
//                                                    }
//                                                    else
//                                                    {
//                                                        [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
//                                                    }
//                                                }
//                                            }];
        }
        else if( [completeResult isEqualToString:@"풀고 있는 문제들"] )
        {
            
        }
        else if( [completeResult isEqualToString:@"피드"] )
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kChangeTabBar object:[NSNumber numberWithInteger:2]];
        }
        else if( [completeResult isEqualToString:@"공유"] )
        {
            
        }
        else if( [completeResult isEqualToString:@"라이브러리"] )
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:kChangeTabBar object:[NSNumber numberWithInteger:1]];
        }
        else if( [completeResult isEqualToString:@"올린문제"] )
        {
            
        }
        else if( [completeResult isEqualToString:@"레포트"] )
        {
            NSLog(@"str_DefaultChannelId : %@", str_DefaultChannelId);
            NSLog(@"str_SideChannelId : %@", str_SideChannelId);

            ReportMainViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportMainViewController"];
//            vc.str_ChannelId = self.str_ChannelId;
            vc.str_UserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];;
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if( [completeResult isEqualToString:@"오답,별표"] )
        {
            WrongAnsStarViewController *vc = [kEtcBoard instantiateViewControllerWithIdentifier:@"WrongAnsStarViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if( [completeResult isEqualToString:@"설정"] )
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Setting" bundle:nil];
            UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"OptionViewController"];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else
        {
            
        }
    }];
    
    [self.tabBarController presentViewController:vc animated:NO completion:^{
        
    }];

}

@end
