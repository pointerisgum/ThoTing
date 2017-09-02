//
//  MainViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 6. 22..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "MainViewController.h"
#import "ChatFeedMainViewController.h"
//#import "QuestionMainViewController.h"

const CGFloat kBarHeight = 45;

@interface MainViewController () <UITabBarControllerDelegate>
@property (nonatomic, weak) IBOutlet UITabBar *myTabBar;
@end

@implementation MainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.delegate = self;
    
//    self.selectedIndex = 2;
    
    //앱 구동시 미리 로드할 탭 미리로드 viewwill 안타고 viewdidload만 탐
    NSArray *myViewControllers = self.viewControllers;
    for (UINavigationController *navViewController in myViewControllers)
    {
        UIViewController *ctrl = navViewController.topViewController;
        if( [ctrl isKindOfClass:[ChatFeedMainViewController class]] )
        {
            [ctrl.view setNeedsLayout];
            [ctrl.view layoutIfNeeded];
        }
    }

//    ChatFeedMainViewController *vc = [[ChatFeedMainViewController alloc] init];
//    ChatFeedMainViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"ChatFeedMainViewController"];
//    QuestionMainViewController *vc1 = [kMainBoard instantiateViewControllerWithIdentifier:@"QuestionMainViewController"];
//    [self setViewControllers:@[self, vc1, vc]];
    
    [self initNaviWithTitle:@"피드" withLeftItem:nil withRightItem:nil withColor:[UIColor colorWithHexString:@"F8F8F8"]];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTabBar:) name:kChangeTabBar object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTabBarController:) name:@"kChangeTabBarController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setMyDefaultChannel) name:@"UserTabBarIconUpdate" object:nil];

    //내가 기본으로 선택한 채널에 대한 정보를 가져와서 하단 탭바 이미지를 바꿔준다
    [self setMyDefaultChannel];
    
//    NSURL *url = [NSURL URLWithString:@"http://data.thoting.com:8282/c_edujm/images/user/000/000/realEstateAgent.jpg"];
//    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
//    [iv sd_setImageWithURL:url placeholderImage:nil options:SDWebImageHighPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        
//        NSLog(@"@@@@@@@@@");
//        UITabBarItem *item = [self.tabBar.items objectAtIndex:2];
//        //                                                item.image = image;
//        item.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    }];

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillLayoutSubviews {
    
    CGRect tabFrame = self.myTabBar.frame; //self.TabBar is IBOutlet of your TabBar
    tabFrame.size.height = kBarHeight;
    tabFrame.origin.y = self.view.frame.size.height - kBarHeight;
    self.myTabBar.frame = tabFrame;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
}

- (void)setMyDefaultChannel
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        nil];
    
    __weak __typeof__(self) weakSelf = self;
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/channel/bookmark/default/info"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            /*
                                             channelId = 7;
                                             channelImgUrl = "000/000/realEstateAgent.jpg";
                                             channelName = "\Uacf5\Uc778\Uc911\Uac1c\Uc0ac";
                                             defaultChannelDesc = "\Uacf5\Uc778\Uc911\Uac1c\Uc0ac \Uc790\Uaca9 \Uc2dc\Ud5d8";
                                             "error_code" = success;
                                             "error_message" = success;
                                             "img_prefix" = "http://data.thoting.com:8282/c_edujm/exam/";
                                             isMemberAllow = A;
                                             memberLevel = 99;
                                             "no_image" = "http://dev.thoting.com/common/clipnote/img/no-image-256.png";
                                             "response_code" = 200;
                                             statusCode = T;
                                             success = success;
                                             "userImg_prefix" = "http://data.thoting.com:8282/c_edujm/images/user/";
                                             */
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode != 200 )
                                            {
//                                                UITabBarItem *item = [weakSelf.tabBar.items objectAtIndex:2];
//                                                item.image = BundleImage(@"tabbar_channel.png");
//                                                item.selectedImage = BundleImage(@"tabbar_channel_p.png");
                                                
                                                [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"MyChannelInfo"];
                                                [[NSUserDefaults standardUserDefaults] synchronize];

//                                                NSString *str_ImageBaseUrl = [resulte objectForKey:@"userImg_prefix"];
//                                                NSString *str_ImageUrl = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPic"];
//                                                NSURL *url = [Util createImageUrl:str_ImageBaseUrl withFooter:str_ImageUrl];
//                                                UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//                                                
//                                                
//                                                NSURLRequest *theRequest=[NSURLRequest requestWithURL:url
//                                                                                          cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                                                                      timeoutInterval:60.0];      
//
//                                                NSLog(@"SSSS");
//                                                [iv setImageWithURLRequest:theRequest placeholderImage:nil usingCache:NO success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
//                                                
//                                                    NSLog(@"ING");
//                                                    CGSize size = CGSizeMake(30, 30);
//                                                    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
//                                                    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
//                                                    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//                                                    UIGraphicsEndImageContext();
//                                                    
//                                                    UIGraphicsBeginImageContextWithOptions(newImage.size, NO, [UIScreen mainScreen].scale);
//                                                    [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, newImage.size.width, newImage.size.height)
//                                                                                cornerRadius:size.width/2] addClip];
//                                                    [newImage drawInRect:CGRectMake(0, 0, newImage.size.width, newImage.size.height)];
//                                                    newImage = UIGraphicsGetImageFromCurrentImageContext();
//                                                    UIGraphicsEndImageContext();
//
//                                                    /*************하단 구조 바뀌며 주석처리함 20170607*************/
////                                                    UITabBarItem *item = [self.tabBar.items objectAtIndex:2];
////                                                    item.image = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
////                                                    item.selectedImage = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//
//                                                } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//                                                   
//                                                    NSLog(@"@@@@@");
//                                                }];

                                                NSLog(@"EEEE");
                                                return;
                                            }
                                            
//                                            NSString *str_ImageBaseUrl = [resulte objectForKey:@"userImg_prefix"];
//                                            NSString *str_ImageUrl = [resulte objectForKey:@"channelImgUrl"];
//                                            if( str_ImageUrl == nil || str_ImageUrl.length <= 0 )
//                                            {
//                                                str_ImageUrl = [resulte objectForKey:@"imgUrl"];
//                                            }
//                                            
//                                            NSURL *url = [Util createImageUrl:str_ImageBaseUrl withFooter:str_ImageUrl];
//                                            UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
//                                            [iv sd_setImageWithURL:url placeholderImage:nil options:SDWebImageHighPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//
////                                                UITabBarItem *item = [self.tabBar.items objectAtIndex:2];
//////                                                item.image = image;
////                                                item.image = [image imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//                                            }];

                                            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:resulte];
                                            [[NSUserDefaults standardUserDefaults] setObject:data forKey:@"MyChannelInfo"];
                                            [[NSUserDefaults standardUserDefaults] synchronize];
                                            
                                            [weakSelf performSelector:@selector(onInterval) withObject:nil afterDelay:0.1f];
//                                            item.selectedImage = [[UIImage imageNamed:@"add_channel.png"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
                                        }
                                    }];

}

- (void)onMyImageInterval:(NSURL *)url
{
//    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//    [iv sd_setImageWithURL:url placeholderImage:nil options:SDWebImageHighPriority completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
//        
//        CGSize size = CGSizeMake(30, 30);
//        UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
//        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
//        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//        
//        UIGraphicsBeginImageContextWithOptions(newImage.size, NO, [UIScreen mainScreen].scale);
//        [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, newImage.size.width, newImage.size.height)
//                                    cornerRadius:size.width/2] addClip];
//        [newImage drawInRect:CGRectMake(0, 0, newImage.size.width, newImage.size.height)];
//        newImage = UIGraphicsGetImageFromCurrentImageContext();
//        UIGraphicsEndImageContext();
//
//        /*************하단 구조 바뀌며 주석처리함 20170607*************/
////        UITabBarItem *item = [self.tabBar.items objectAtIndex:2];
////        item.image = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
////        item.selectedImage = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//    }];
}

- (void)onInterval
{
    NSData *data = [[NSUserDefaults standardUserDefaults] objectForKey:@"MyChannelInfo"];
    NSDictionary *resulte = [NSKeyedUnarchiver unarchiveObjectWithData:data];

    if( [[resulte objectForKey:@"channelType"] isEqualToString:@"channel"] )
    {
//        NSString *str_ImageBaseUrl = [resulte objectForKey:@"userImg_prefix"];
//        NSString *str_ImageUrl = [resulte objectForKey:@"channelImgUrl"];
//        if( str_ImageUrl == nil || str_ImageUrl.length <= 0 )
//        {
//            str_ImageUrl = [resulte objectForKey:@"imgUrl"];
//        }
//        
//        NSURL *url = [Util createImageUrl:str_ImageBaseUrl withFooter:str_ImageUrl];
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
//            //이미지뷰가 아닌 이미지를 원형으로 표현
//            UIGraphicsBeginImageContextWithOptions(newImage.size, NO, [UIScreen mainScreen].scale);
//            [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, newImage.size.width, newImage.size.height)
//                                        cornerRadius:size.width/2] addClip];
//            [newImage drawInRect:CGRectMake(0, 0, newImage.size.width, newImage.size.height)];
//            newImage = UIGraphicsGetImageFromCurrentImageContext();
//            UIGraphicsEndImageContext();
//            
//            /*************하단 구조 바뀌며 주석처리함 20170607*************/
////            UITabBarItem *item = [self.tabBar.items objectAtIndex:2];
////            item.image = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
////            item.selectedImage = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        }];
    }
    else
    {
        /*************하단 구조 바뀌며 주석처리함 20170607*************/
//        UITabBarItem *item = [self.tabBar.items objectAtIndex:2];
//        item.image = BundleImage(@"hashtag.png");
//        item.selectedImage = BundleImage(@"hashtag.png");
    }
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

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
    [self updateTitle];
}

- (void)changeTabBarController:(NSNotification *)notification
{
    UIViewController *vc = notification.object;
    
    NSMutableArray *arM = [self.viewControllers mutableCopy];
    
    UINavigationController *navi = [arM objectAtIndex:3];
    NSMutableArray *arM_Navi = [navi.viewControllers mutableCopy];
    [arM_Navi removeAllObjects];
    [arM_Navi addObject:vc];
    navi.viewControllers = arM_Navi;
    
    [arM replaceObjectAtIndex:3 withObject:navi];
    
    self.viewControllers = arM;


    
}

- (void)updateTitle
{
    self.navigationController.navigationBarHidden = NO;

//    if( self.selectedIndex == 0 )
//    {
//        [self initNaviWithTitle:@"피드" withLeftItem:nil withRightItem:nil withColor:[UIColor colorWithHexString:@"F8F8F8"]];
//    }
//    else if( self.selectedIndex == 1 )
//    {
//        self.navigationController.navigationBarHidden = YES;
//        [self initNaviWithTitle:@"문제들" withLeftItem:nil withRightItem:nil withColor:[UIColor colorWithHexString:@"F8F8F8"]];
//    }
//    else if( self.selectedIndex == 2 )
//    {
//        [self initNaviWithTitle:@"레포트" withLeftItem:nil withRightItem:nil withColor:[UIColor colorWithHexString:@"F8F8F8"]];
//    }
//    else if( self.selectedIndex == 3 )
//    {
//        [self initNaviWithTitle:@"MY" withLeftItem:nil withRightItem:nil withColor:[UIColor colorWithHexString:@"F8F8F8"]];
//    }
}

- (void)changeTabBar:(NSNotification *)notification
{
    NSInteger nTabBarIdx = [notification.object integerValue];
    if( nTabBarIdx == 5 )
    {
        //구매함 눌렀을때
        //이때는 마이페이지->문제들로 이동해야 함
        self.selectedIndex = 4;
        [[NSNotificationCenter defaultCenter] postNotificationName:kShowMyPageQuestion object:nil];
    }
    
    self.selectedIndex = nTabBarIdx;
    [self updateTitle];
}

@end
