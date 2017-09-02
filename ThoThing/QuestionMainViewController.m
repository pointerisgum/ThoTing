//
//  QuestionMainViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 6. 22..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "QuestionMainViewController.h"
#import "QuestionMainCell.h"
#import "QuestionDetailViewController.h"
#import "QuestionAllViewController.h"
#import "QuestionMainCellView.h"
#import "ChannelMainViewController.h"
#import "SearchBarViewController.h"
#import "QuestionVerticalItemCell.h"
#import "QuestionMainHeaderCell.h"
#import "QuestionStartViewController.h"
#import "ActionSheetBottomViewController.h"
#import "SharedViewController.h"
#import "GroupWebViewController.h"
#import "ReportDetailViewController.h"
#import "QuestionVerticalOneItemCell.h"
#import "FTPopOverMenu.h"
#import "QuestionMainTagCell.h"
#import "QuestionMainFeedCell.h"
#import "SharpChannelMainViewController.h"
#import "QuestionMainMakeChannelCell.h"
#import "ChannelMakeTypeViewController.h"

//test code
#import "QuestionListViewController.h"

@import AMPopTip;

@interface QuestionMainViewController () <UISearchBarDelegate, UIScrollViewDelegate, UISearchBarDelegate>
@property (nonatomic, strong) NSMutableArray *arM_CellSvList;
@property (nonatomic, strong) NSMutableArray *arM_Feed;
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) NSMutableArray *arM_Base;
@property (nonatomic, strong) NSAttributedString *attrString;
@property (nonatomic, strong) NSAttributedString *moreString;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ContentsHeight;
@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet UITableView *tbv_Feed;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_FeedHeight;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, strong) AMPopTip *popTip;

@property (nonatomic, strong) IBOutlet UIButton *btn_SearchType; //고등학교, 중학교, 일반
@end

@implementation QuestionMainViewController

- (BOOL)searchBarShouldBeginEditing:(UISearchBar *)searchBar
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    UINavigationController *navi = [storyboard instantiateViewControllerWithIdentifier:@"SearchNavi"];
    SearchBarViewController *vc = [navi.viewControllers firstObject];
    vc.str_Type = self.searchBar.placeholder;
    [self presentViewController:navi animated:YES completion:^{
        
    }];
    
    return NO;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
//    [self initNaviWithTitle:@"문제들" withLeftItem:nil withRightItem:nil];
    
//    self.navigationController.navigationBarHidden = YES;
    
//    [self updateIcon];
    
    self.view.backgroundColor = self.tbv_List.backgroundColor;  //탭바 사이즈를 줄였더니 self.view의 백그라운드 색이 보여서 처리함
    self.searchBar.delegate = self;
    
//    [self initNaviWithTitle:@"문제들" withLeftItem:nil withRightItem:nil withColor:[UIColor colorWithHexString:@"F8F8F8"]];
//    
//    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0,
//                                                                           self.navigationController.navigationBar.frame.size.width,
//                                                                           self.navigationController.navigationBar.frame.size.height)];
//    searchBar.placeholder = @"검색";
//    searchBar.searchBarStyle = UISearchBarStyleMinimal;
//    searchBar.delegate = self;
//    
//    [self initSearchNavi:searchBar withColor:[UIColor colorWithHexString:@"F8F8F8"]];

    self.tbv_Feed.bounces = self.tbv_List.bounces = NO;
    self.tbv_Feed.scrollEnabled = self.tbv_List.scrollEnabled = NO;
    
    self.lc_FeedHeight.constant = 70.f;
    
    self.arM_CellSvList = [NSMutableArray array];
    
    [AMPopTip appearance].font = [UIFont fontWithName:@"Avenir-Medium" size:12];
    
    self.popTip = [AMPopTip popTip];
    self.popTip.edgeMargin = 5;
    self.popTip.offset = 2;
    self.popTip.edgeInsets = UIEdgeInsetsMake(0, 10, 0, 10);
    self.popTip.shouldDismissOnTap = YES;
    self.popTip.animationIn = 0;
    self.popTip.animationOut = 0;
    self.popTip.tapHandler = ^{
        NSLog(@"Tap!");
    };
    self.popTip.dismissHandler = ^{
        NSLog(@"Dismiss!");
    };
    
    NSString *str_QDW = [[NSUserDefaults standardUserDefaults] objectForKey:@"QDW"];    //QuestionDefaultWord
    if( str_QDW == nil || str_QDW.length <= 0 )
    {
        self.searchBar.placeholder = @"고등학교";
    }
    else
    {
        self.searchBar.placeholder = str_QDW;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUpdateNewChannel:) name:@"kUpdateNewChannel" object:nil];
}

- (void)onUpdateNewChannel:(NSNotification *)noti
{
    [self updateMyChannelsMoveChannelId:[noti object]];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"kUpdateNewChannel" object:nil];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.hidesBottomBarWhenPushed = NO;

    self.navigationController.navigationBarHidden = YES;
    
    [MBProgressHUD hide];
    
    [self updateFeedList];
    [self updateList:@"고등학교"];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
//    NSString *str_Path = [NSString stringWithFormat:@"%@/api/v1/get/my/feed/keyword/list", kBaseUrl];
//    [[WebAPI sharedData] cancelMethod:@"GET" withPath:str_Path];
//    
//    str_Path = [NSString stringWithFormat:@"%@/api/v1/get/main/recommend/package/exam/browse", kBaseUrl];
//    [[WebAPI sharedData] cancelMethod:@"GET" withPath:str_Path];

    [self.popTip hide];
}

- (void)viewDidLayoutSubviews
{
    for( NSInteger i = 0; i < self.arM_CellSvList.count; i++ )
    {
        NSDictionary *dic = self.arM_CellSvList[i];
        UIScrollView *sv = [dic objectForKey:@"object"];
        NSNumber *width = [dic objectForKey:@"contentsWidth"];
        [sv setContentSize:CGSizeMake([width floatValue], 0)];
    }
    
    self.sv_Main.contentSize = CGSizeMake(self.sv_Main.frame.size.width, self.tbv_Feed.contentSize.height + self.tbv_List.contentSize.height);
    self.lc_ContentsHeight.constant = self.sv_Main.contentSize.height + 10;
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

- (void)updateFeedList
{
    __weak __typeof__(self) weakSelf = self;

    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/my/feed/keyword/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                weakSelf.arM_Base = [NSMutableArray arrayWithArray:[resulte objectForKey:@"feedList"]];
                                                [weakSelf.arM_Base addObject:@{@"keyword":[[NSUserDefaults standardUserDefaults] objectForKey:@"hashtagStr"],
                                                                               @"title":[[NSUserDefaults standardUserDefaults] objectForKey:@"hashtagStr"],
                                                                               @"callType":@"hashTag"}];
//                                                [[NSUserDefaults standardUserDefaults] setObject:[resulte objectForKey:@"hashtagStr"] forKey:@"hashtagStr"];
//                                                [[NSUserDefaults standardUserDefaults] setObject:[NSString stringWithFormat:@"%@", [resulte objectForKey:@"hashtagChannelId"]] forKey:@"hashtagChannelId"];

                                                //내가 관리자나 회원으로 있는 채널
                                                [weakSelf updateMyChannelsMoveChannelId:nil];


                                            }
                                            
                                            [[NSUserDefaults standardUserDefaults] setObject:[resulte objectForKey:@"img_prefix"] forKey:@"img_prefix"];
                                            [[NSUserDefaults standardUserDefaults] setObject:[resulte objectForKey:@"no_image"] forKey:@"no_image"];
                                            [[NSUserDefaults standardUserDefaults] setObject:[resulte objectForKey:@"userImg_prefix"] forKey:@"userImg_prefix"];
                                            [[NSUserDefaults standardUserDefaults] synchronize];
                                        }
                                    }];
}

- (void)updateMyChannelsMoveChannelId:(NSString *)aMoveChannelId
{
    __weak __typeof__(self) weakSelf = self;
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/home/channels"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                [weakSelf.arM_Feed removeAllObjects];
                                                weakSelf.arM_Feed = [NSMutableArray arrayWithArray:weakSelf.arM_Base];
                                                
                                                NSMutableArray *arM_T = [NSMutableArray array];
                                                NSMutableArray *arM_M = [NSMutableArray array];
//                                                NSMutableArray *arM_F = [NSMutableArray array];
                                                
                                                NSMutableArray *arM = [NSMutableArray array];
                                                arM = [NSMutableArray arrayWithArray:[resulte objectForKey:@"channelInfos"]];
                                                for( NSInteger i = 0; i < arM.count; i++ )
                                                {
                                                    NSDictionary *dic = arM[i];
                                                    NSString *str_Status = [dic objectForKey_YM:@"statusCode"];
                                                    if( [str_Status isEqualToString:@"T"] )
                                                    {
                                                        [arM_T addObject:dic];
                                                    }
                                                    else if( [str_Status isEqualToString:@"M"] )
                                                    {
                                                        [arM_M addObject:dic];
                                                    }
//                                                    else if( [str_Status isEqualToString:@"F"] )
//                                                    {
//                                                        [arM_F addObject:dic];
//                                                    }
                                                }
                                                
                                                NSSortDescriptor * descriptor = [[NSSortDescriptor alloc] initWithKey:@"channelFollowerCount" ascending:NO];
                                                NSArray *ar_Temp = [arM_T sortedArrayUsingDescriptors:@[descriptor]];
                                                [weakSelf.arM_Feed addObjectsFromArray:ar_Temp];
                                                
                                                ar_Temp = [arM_M sortedArrayUsingDescriptors:@[descriptor]];
                                                [weakSelf.arM_Feed addObjectsFromArray:ar_Temp];
                                                
                                                [weakSelf.arM_Feed addObject:@{@"callType":@"makeChannel"}];
                                            }
                                            
                                            weakSelf.lc_FeedHeight.constant = weakSelf.arM_Feed.count * 70 + (weakSelf.arM_Feed.count <= 0 ? 0 : (weakSelf.arM_Feed.count - 1) * 10);
                                            [weakSelf.tbv_Feed reloadData];
                                            
                                            if( aMoveChannelId )
                                            {
                                                for( NSInteger i = 0; i < weakSelf.arM_Feed.count; i++ )
                                                {
                                                    NSDictionary *dic = weakSelf.arM_Feed[i];
                                                    NSInteger nCurrentChannelId = [[dic objectForKey_YM:@"channelId"] integerValue];
                                                    if( aMoveChannelId > 0 && [aMoveChannelId integerValue] == nCurrentChannelId )
                                                    {
                                                        NSArray *ar = [NSArray arrayWithObject:dic];
                                                        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                                        [appDelegate showChannelView:@{@"examInfos":ar}];

                                                        break;
                                                    }
                                                }
                                            }
                                        }
                                    }];
}

- (void)updateList:(NSString *)aSearch
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        @"10", @"limitCount",
                                        nil];
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/main/recommend/package/exam/browse"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                //성공
                                                self.arM_List = [NSMutableArray arrayWithArray:[resulte objectForKey:@"recommendInfo"]];
                                                [self.tbv_List reloadData];
                                                [self.view setNeedsLayout];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                    }];
}

//- (void)updateIcon
//{
//    NSString *str_IsTeacher = [[NSUserDefaults standardUserDefaults] objectForKey:@"isTeacher"];
//    if( [str_IsTeacher isEqualToString:@"Y"] )
//    {
//        NSString *str_Name = @"";
//        NSString *str_Key = [NSString stringWithFormat:@"DefaultChannel_%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"]];
//        NSString *str_DefaultChannel = [[NSUserDefaults standardUserDefaults] objectForKey:str_Key];
//        if( str_DefaultChannel == nil || str_DefaultChannel.length <= 0 )
//        {
//            str_Name = [[NSUserDefaults standardUserDefaults] objectForKey:@"userName"];
//        }
//        else
//        {
//            str_Name = str_DefaultChannel;
//        }
//        
//        if( [str_Name isEqualToString:[[NSUserDefaults standardUserDefaults] objectForKey:@"userName"]] )
//        {
//            NSString *str_UserPic = [[NSUserDefaults standardUserDefaults] objectForKey:@"userPic"];
//            [self setIcon:str_UserPic];
//            //            [self.iv_Icon sd_setImageWithURL:[NSURL URLWithString:str_UserPic] placeholderImage:BundleImage(@"no_image.png")];
//        }
//        else
//        {
//            NSString *str_IconUrl = [[NSUserDefaults standardUserDefaults] objectForKey:[NSString stringWithFormat:@"%@_Pic", str_Key]];
//            [self setIcon:str_IconUrl];
//            
//            //            [self.iv_Icon sd_setImageWithURL:[NSURL URLWithString:str_IconUrl] placeholderImage:BundleImage(@"no_image.png")];
//        }
//    }
//    else
//    {
//        UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:kTabBarMyIdx];
//        item.image = BundleImage(@"bottom_menu4.png");
//        item.selectedImage = BundleImage(@"bottom_menu4_p.png");
//    }
//}
//
//- (void)setIcon:(NSString *)aUrl
//{
//    NSURL *url = [NSURL URLWithString:aUrl];
//    UIImageView *iv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
//    
//    
//    NSURLRequest *theRequest=[NSURLRequest requestWithURL:url
//                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
//                                          timeoutInterval:60.0];
//    
//    [iv setImageWithURLRequest:theRequest placeholderImage:nil usingCache:NO success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
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
//        UITabBarItem *item = [self.tabBarController.tabBar.items objectAtIndex:kTabBarMyIdx];
//        item.image = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        item.selectedImage = [newImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
//        
//    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
//        
//    }];
//}



#pragma mark - UISearchBarDelegate
- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.view endEditing:YES];
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    if( searchBar.text.length > 0 )
    {
        [self.view endEditing:YES];
        [self updateList:searchBar.text];
    }
}



#pragma mark - UIGesture
- (void)handleSingleTap:(UIGestureRecognizer *)gestureRecognizer
{
    QuestionMainCellView *view = (QuestionMainCellView *)gestureRecognizer.view;
    NSLog(@"%ld", view.tag);
    
//    //test code
//    QuestionListViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionListViewController"];
//    vc.str_Idx = [NSString stringWithFormat:@"%ld", view.tag];
//    vc.dic_Info = view.dic_Info;
//    [self.navigationController pushViewController:vc animated:YES];
    
    //문제집 디테일로 이동
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    QuestionDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"QuestionDetailViewController"];
    vc.str_Idx = [NSString stringWithFormat:@"%ld", view.tag];
    vc.str_Title = [view.dic_Info objectForKey:@"examTitle"];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)tagTap:(UITapGestureRecognizer *)recognizer
{
    UITextView *textView =  (UITextView *)recognizer.view;
    if( textView.tag == 1 )
    {
        NSDictionary *dic_Main = self.arM_List[0];
        
        AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
        [appDelegate showChannelView:dic_Main];
        return;
    }
    
    CGPoint location = [recognizer locationInView:textView];
    
    CGPoint position = CGPointMake(location.x, location.y);
    
    //get location in text from textposition at point
    UITextPosition *tapPosition = [textView closestPositionToPoint:position];
    
    //fetch the word at this position (or nil, if not available)
    UITextRange *textRange = [textView.tokenizer rangeEnclosingPosition:tapPosition withGranularity:UITextGranularityWord inDirection:UITextLayoutDirectionRight];
    NSString *tappedWord = [textView textInRange:textRange];
    
    NSLog(@"tapped word : %@", tappedWord);
    
    
    /*
     텍스트뷰의 텍스트를 공백을 세퍼레이터로 배열을 만들어서 해당 인덱스를 찾아 검색해야 함
     */

    NSInteger nFindIdx = 0;
    NSArray *ar_Words = [textView.text componentsSeparatedByString:@" "];
    for( NSInteger i = 0; i < ar_Words.count; i++ )
    {
        NSString *str_Word = [ar_Words objectAtIndex:i];
        str_Word = [str_Word stringByReplacingOccurrencesOfString:@"#" withString:@""];
        if( [tappedWord isEqualToString:str_Word] )
        {
            nFindIdx = i;
            break;
        }
    }
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
    UINavigationController *navi = [storyboard instantiateViewControllerWithIdentifier:@"SearchNavi"];
    SearchBarViewController *vc = [navi.viewControllers firstObject];
    NSDictionary *dic = [self.arM_Feed objectAtIndex:textView.tag];
    vc.str_SearchWord = [dic objectForKey:@"keyword"];
    vc.str_Type = self.searchBar.placeholder;
//    vc.str_SearchWord = tappedWord;
    [self presentViewController:navi animated:YES completion:^{
        
    }];
}



#pragma mark - UITableViewDelegate & DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if( tableView == self.tbv_Feed )
    {
        return self.arM_Feed.count;
    }
    
    return self.arM_List.count;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( tableView == self.tbv_Feed )
    {
        NSDictionary *dic_Main = self.arM_Feed[indexPath.section];
        
        static NSString *CellIdentifier = @"QuestionMainTagCell";
        QuestionMainTagCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        if( cell.tv_Tag )
        {
            cell.tv_Tag.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
        }
        
        if( [[dic_Main objectForKey:@"callType"] isEqualToString:@"search"] )
        {
            cell.tv_Tag.userInteractionEnabled = YES;
            
            NSString *str_Tag = [NSString stringWithFormat:@"#%@", [dic_Main objectForKey:@"keyword"]];
            str_Tag = [str_Tag stringByReplacingOccurrencesOfString:@" " withString:@""];
            cell.tv_Tag.text = str_Tag;
            
//            cell.tv_Tag.text = @"#영어듣기기출 #수학 #과학 #영동고등학교 #진명학원 #서울대 #모의고사 #토팅";

            for( UIGestureRecognizer *recognizer in cell.tv_Tag.gestureRecognizers )
            {
                [cell.tv_Tag removeGestureRecognizer:recognizer];
            }

            cell.tv_Tag.tag = indexPath.section;
            
            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagTap:)];
            tapGesture.numberOfTapsRequired = 1;
            [cell.tv_Tag addGestureRecognizer:tapGesture];

            cell.tv_Tag.textColor = [UIColor blackColor];
            
            return cell;
        }
        else if( [[dic_Main objectForKey:@"callType"] isEqualToString:@"hashTag"] )
        {
            cell.tv_Tag.userInteractionEnabled = NO;
            
            NSString *str_Tag = [NSString stringWithFormat:@"%@", [dic_Main objectForKey:@"keyword"]];
            str_Tag = [str_Tag stringByReplacingOccurrencesOfString:@" " withString:@""];
            cell.tv_Tag.text = str_Tag;
            
            //            cell.tv_Tag.text = @"#영어듣기기출 #수학 #과학 #영동고등학교 #진명학원 #서울대 #모의고사 #토팅";
            
            for( UIGestureRecognizer *recognizer in cell.tv_Tag.gestureRecognizers )
            {
                [cell.tv_Tag removeGestureRecognizer:recognizer];
            }
            
            cell.tv_Tag.tag = indexPath.section;
            
//            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagTap:)];
//            tapGesture.numberOfTapsRequired = 1;
//            [cell.tv_Tag addGestureRecognizer:tapGesture];
            
            cell.tv_Tag.textColor = kMainColor;
            
            return cell;
        }
        else if( [[dic_Main objectForKey:@"callType"] isEqualToString:@"makeChannel"] )
        {
            QuestionMainMakeChannelCell *cell = [tableView dequeueReusableCellWithIdentifier:@"QuestionMainMakeChannelCell"];
            [tableView deselectRowAtIndexPath:indexPath animated:YES];
            
            return cell;
        }
        else
        {
            cell.tv_Tag.userInteractionEnabled = NO;
            cell.tv_Tag.textContainer.lineBreakMode = NSLineBreakByWordWrapping;
            
//            NSString *str_Tag = [NSString stringWithFormat:@"#%@", [dic_Main objectForKey:@"keyword"]];
//            str_Tag = [str_Tag stringByReplacingOccurrencesOfString:@" " withString:@""];
//            cell.tv_Tag.text = str_Tag;

            NSString *str_ChannelName = [dic_Main objectForKey_YM:@"channelName"];
            NSString *str_StatusCode = [dic_Main objectForKey:@"statusCode"];
            if( [str_StatusCode isEqualToString:@"T"] )
            {
                cell.tv_Tag.text = [NSString stringWithFormat:@"%@(%@)", str_ChannelName, @"관리자"];
            }
            else
            {
                cell.tv_Tag.text = [NSString stringWithFormat:@"%@(%@)", str_ChannelName, @"회원"];
            }
            
            for( UIGestureRecognizer *recognizer in cell.tv_Tag.gestureRecognizers )
            {
                [cell.tv_Tag removeGestureRecognizer:recognizer];
            }
            
            cell.tv_Tag.tag = indexPath.section;
            
//            UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tagTap:)];
//            tapGesture.numberOfTapsRequired = 1;
//            [cell.tv_Tag addGestureRecognizer:tapGesture];
            
            cell.tv_Tag.textColor = kMainColor;
            
            return cell;

//            static NSString *CellIdentifier = @"QuestionMainFeedCell";
//            QuestionMainFeedCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
//            [tableView deselectRowAtIndexPath:indexPath animated:YES];
//
//            return cell;
        }
    }
    
    
    
    NSDictionary *dic_Main = self.arM_List[indexPath.section];

    if( indexPath.section == 0 )
    {
        static NSString *CellIdentifier = @"QuestionMainCell";
        QuestionMainCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        
        cell.tag = cell.lb_Title.tag = cell.btn_More.tag = cell.btn_Setting.tag = indexPath.row;
 
        NSArray *ar_ExamInfos = [dic_Main objectForKey:@"examInfos"];

        for( id subView in cell.contentView.subviews )
        {
            if( [subView isKindOfClass:[UIScrollView class]] )
            {
                UIScrollView *sv_Sub = (UIScrollView *)subView;
                if( sv_Sub.tag > 0 )
                {
                    [sv_Sub removeFromSuperview];
                }
            }
        }
        
//        [cell.btn_More addTarget:self action:@selector(onMoreChannel:) forControlEvents:UIControlEventTouchUpInside];
        
        UIScrollView *sv = [[UIScrollView alloc]initWithFrame:CGRectMake(15, 0, tableView.frame.size.width - 30, 180)];
        sv.tag = indexPath.row + 1;
        sv.delegate = self;
        [cell.contentView addSubview:sv];
        
        for( NSInteger i = 0; i < ar_ExamInfos.count; i++ )
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"QuestionMainCellView" owner:self options:nil];
            QuestionMainCellView *view = [topLevelObjects objectAtIndex:0];
            
            view.clipsToBounds = YES;
            view.layer.borderColor = [UIColor colorWithRed:200.f/255.f green:200.f/255.f blue:200.f/255.f alpha:1].CGColor;
            view.layer.borderWidth = 0.5f;
            view.layer.cornerRadius = 1.f;
            
            NSDictionary *dic = ar_ExamInfos[i];
            view.dic_Info = dic;
            view.iv_Cover.backgroundColor = [UIColor colorWithHexString:[dic objectForKey_YM:@"codeHex"]];
            
            view.lb_Title.text = [dic objectForKey:@"examTitle"];
            
            view.lb_Subject.text = [dic objectForKey:@"subjectName"];
            NSInteger nGrade = [[dic objectForKey:@"personGrade"] integerValue];
            view.lb_Grade.text = [NSString stringWithFormat:@"%@ %@학년", [dic objectForKey:@"schoolGrade"], nGrade == 0 ? @"전체" : [NSString stringWithFormat:@"%ld", nGrade]];
            view.lb_Ower.text = [dic objectForKey:@"publisherName"];
            
            NSString *str_Purchase = [dic objectForKey_YM:@"isPaid"];
            if( [str_Purchase isEqualToString:@"paid"] )
            {
                view.lb_Price.text = @"문제풀기";
            }
            else
            {
                if( [[dic objectForKey:@"heartCount"] integerValue] == 0 )
                {
                    //무료
                    view.lb_Price.text = @"무료";
                }
                else
                {
                    //유료
                    CGFloat fQuestionCount = [[dic objectForKey:@"amount"] floatValue];
                    view.lb_Price.text = [NSString stringWithFormat:@"$%f", fQuestionCount];
                }
            }
            view.tag = [[dic objectForKey:@"examId"] integerValue];
            view.btn_Info.tag = i;
            [view.btn_Info addTarget:self action:@selector(onInfo:) forControlEvents:UIControlEventAllTouchEvents];
            
            UITapGestureRecognizer *singleTap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
            [singleTap1 setNumberOfTapsRequired:1];
            [view addGestureRecognizer:singleTap1];
            
            
            CGRect frame = view.frame;
            frame.origin.x = i * (frame.size.width + 10);
            view.frame = frame;
            [sv addSubview:view];
        }
        
        sv.contentSize = CGSizeMake(ar_ExamInfos.count * 96, 0);
        //    cell.sv_Cell.contentSize = CGSizeMake(2000, 1000);
        //    [self.arM_CellSvList addObject:@{@"object":cell.sv_Cell, @"contentsWidth":[NSNumber numberWithFloat:ar_ExamInfos.count * 96]}];
        //    [self.view setNeedsLayout];
        
        return cell;
    }

    QuestionVerticalItemCell *cell_Main = [tableView dequeueReusableCellWithIdentifier:@"QuestionVerticalItemCell"];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    for( id subView in cell_Main.contentView.subviews )
    {
        if( [subView isKindOfClass:[QuestionVerticalOneItemCell class]] )
        {
            QuestionVerticalOneItemCell *item = (QuestionVerticalOneItemCell *)subView;
            if( item.tag > 0 )
            {
                [item removeFromSuperview];
            }
        }
    }
    
    NSArray *ar_ExamInfos = [dic_Main objectForKey:@"examInfos"];
    NSInteger nCount = ar_ExamInfos.count;
//    if( nCount > 5 )
//    {
//        nCount = 5;
//    }
    
    for( NSInteger i = 0; i < nCount; i++ )
    {
        NSDictionary *dic = [ar_ExamInfos objectAtIndex:i];
        
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:@"QuestionVerticalOneItemCell" owner:self options:nil];
        QuestionVerticalOneItemCell *cell = [topLevelObjects objectAtIndex:0];
        
        cell.v_Item.clipsToBounds = YES;
        cell.v_Item.layer.borderColor = [UIColor colorWithRed:200.f/255.f green:200.f/255.f blue:200.f/255.f alpha:1].CGColor;
        cell.v_Item.layer.borderWidth = 0.5f;
//        cell.v_Item.layer.cornerRadius = 14.f;

        CGRect frame = cell.frame;
        frame.origin.y = i * cell.frame.size.height;
        frame.size.width = self.tbv_List.bounds.size.width;
        cell.frame = frame;
        
//        frame = cell.contentView.frame;
//        frame.size.width = 375.f;
//        cell.contentView.frame = frame;

//        cell.lc_Tail.constant = cell_Main.bounds.size.width - 375.f;

//        [cell setNeedsLayout];
//        [cell updateConstraints];
//        [cell.contentView setNeedsLayout];
//        [cell.contentView updateConstraints];
//        [self.view setNeedsLayout];
//        [self.view updateConstraints];
        
        cell.tag = i + 1;
        
        cell.lb_SubjectName.text = [dic objectForKey_YM:@"subjectName"];
        cell.v_SubJectBg.backgroundColor = [UIColor colorWithHexString:[dic objectForKey_YM:@"codeHex"]];
        cell.lb_Title.text = [dic objectForKey_YM:@"examTitle"];
        
        NSString *str_SubTitle = [NSString stringWithFormat:@"%@  문제 %@  USER %@",
                                  [dic objectForKey_YM:@"schoolGrade"], [dic objectForKey_YM:@"questionCount"], [dic objectForKey_YM:@"paidUserCount"]];
        cell.lb_SubTitle.text = str_SubTitle;
        
        cell.lb_Owner.text = [dic objectForKey_YM:@"publisherName"];
        
        NSString *str_Purchase = [dic objectForKey:@"isPaid"];
        if( [str_Purchase isEqualToString:@"paid"] )
        {
            cell.lb_Price.text = @"문제풀기";
        }
        else
        {
            if( [[dic objectForKey:@"heartCount"] integerValue] == 0 )
            {
                //무료
                cell.lb_Price.text = @"무료";
            }
            else
            {
                CGFloat fQuestionCount = [[dic objectForKey:@"amount"] floatValue];
                cell.lb_Price.text = [NSString stringWithFormat:@"$%f", fQuestionCount];
            }
        }
        
        cell.btn_Select.tag = cell.btn_Info.tag = cell.btn_Price.tag = (indexPath.section * 1000) + i;
        [cell.btn_Select addTarget:self action:@selector(onItemSelected:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_Info addTarget:self action:@selector(onItemInfo:) forControlEvents:UIControlEventTouchUpInside];
        [cell.btn_Price addTarget:self action:@selector(onPriceSelected:) forControlEvents:UIControlEventTouchUpInside];
        
        
        [cell_Main.contentView addSubview:cell];
    }

    return cell_Main;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if( tableView == self.tbv_Feed )
    {
        NSDictionary *dic_Main = self.arM_Feed[indexPath.section];

        if( [[dic_Main objectForKey:@"callType"] isEqualToString:@"search"] )
        {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
            UINavigationController *navi = [storyboard instantiateViewControllerWithIdentifier:@"SearchNavi"];
            SearchBarViewController *vc = [navi.viewControllers firstObject];
            NSDictionary *dic = [self.arM_Feed objectAtIndex:indexPath.section];
            vc.str_SearchWord = [dic objectForKey:@"keyword"];
            vc.str_Type = self.searchBar.placeholder;
            //    vc.str_SearchWord = tappedWord;
            [self presentViewController:navi animated:YES completion:^{
                
            }];
        }
        else if( [[dic_Main objectForKey:@"callType"] isEqualToString:@"hashTag"] )
        {
            SharpChannelMainViewController *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"SharpChannelMainViewController"];
            vc.isShowNavi = NO;
            vc.dic_Info = @{@"channelHashTag":[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"channelHashTag"]],
                            @"hashtagChannelId":[NSString stringWithFormat:@"%@", [[NSUserDefaults standardUserDefaults] objectForKey:@"hashtagChannelId"]]};
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if( [[dic_Main objectForKey:@"callType"] isEqualToString:@"makeChannel"] )
        {
            UINavigationController *navi = [kMainBoard instantiateViewControllerWithIdentifier:@"ChannelMakeTypeNavi"];
            ChannelMakeTypeViewController *vc = [navi.viewControllers firstObject];
            [self presentViewController:navi animated:YES completion:^{
                
            }];
        }
        else
        {
            NSArray *ar = [NSArray arrayWithObject:dic_Main];
            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
            [appDelegate showChannelView:@{@"examInfos":ar}];
        }
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        
//        if( indexPath.section == 1 )
//        {
//            //이것만 진명학원 페이지로 이동
//            NSDictionary *dic_Main = self.arM_List[0];
//            
//            AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
//            [appDelegate showChannelView:dic_Main];
//            
//            return;
//        }
//
//        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
//        UINavigationController *navi = [storyboard instantiateViewControllerWithIdentifier:@"SearchNavi"];
//        SearchBarViewController *vc = [navi.viewControllers firstObject];
//        NSDictionary *dic = [self.arM_Feed objectAtIndex:indexPath.section];
//        vc.str_SearchWord = [dic objectForKey:@"keyword"];
//        vc.str_Type = self.searchBar.placeholder;
//        //    vc.str_SearchWord = tappedWord;
//        [self presentViewController:navi animated:YES completion:^{
//            
//        }];
    }

//    nSelectedIdx = indexPath.row;
//    [self.tbv_List reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if( tableView == self.tbv_Feed )
    {
        return 70.f;
    }
    else
    {
        if( indexPath.section == 0 )
        {
            //진명 가로 리스트
            return 180.f;
        }
        
        NSDictionary *dic_Main = self.arM_List[indexPath.section];
        NSArray *ar_ExamInfos = [dic_Main objectForKey:@"examInfos"];
        NSInteger nCount = ar_ExamInfos.count;
        
        return nCount * 100;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if( tableView == self.tbv_Feed )
    {
        if( self.arM_Feed.count <= 1 )
        {
            return 0;
        }
        
        return 10.f;
    }
    
    return 60.0f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if( tableView == self.tbv_Feed )
    {
        if( self.arM_Feed.count <= 1 )
        {
            return nil;
        }

        UIView *v_Section = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10)];
        v_Section.backgroundColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1];
        return v_Section;
    }
    
    
    static NSString *CellIdentifier = @"QuestionMainHeaderCell";
    QuestionMainHeaderCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    [cell.btn_Select removeTarget:self action:NULL forControlEvents:UIControlEventAllEvents];
    
    //        NSDictionary *dic = self.arM_List[[self.str_StartIdx integerValue] - 1];
    NSDictionary *dic_Main = self.arM_List[section];

    cell.btn_Select.tag = section;
    cell.lb_Title.text = [dic_Main objectForKey_YM:@"hashTag"];
    [cell.btn_Select addTarget:self action:@selector(onGoChannel:) forControlEvents:UIControlEventTouchUpInside];
    
    return cell;
}

- (void)onItemSelected:(UIButton *)btn
{
    NSDictionary *dic_Main = self.arM_List[btn.tag/1000];
    NSArray *ar_ExamInfos = [dic_Main objectForKey:@"examInfos"];
    __block NSDictionary *dic = [ar_ExamInfos objectAtIndex:(btn.tag%1000)];
    
    NSString *str_Purchase = [dic objectForKey:@"isPaid"];
    if( [str_Purchase isEqualToString:@"paid"] )
    {
        QuestionStartViewController  *vc = [kMainBoard instantiateViewControllerWithIdentifier:@"QuestionStartViewController"];
        //        vc.hidesBottomBarWhenPushed = YES;
        vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"examId"] integerValue]];
        vc.str_StartIdx = @"0";
        vc.str_Title = [dic objectForKey:@"examTitle"];
        vc.str_ChannelId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"channelId"]]; //self.str_ChannelId;
        //    vc.str_UserIdx = self.str_UserIdx;
        vc.isPdf = [[dic objectForKey:@"examType"] isEqualToString:@"pdfExam"];
        
        [self.navigationController pushViewController:vc animated:YES];
    }
    else
    {
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
//                                                            [self updateList:@"고등학교"];
                                                            
                                                            NSMutableDictionary *dicM = [NSMutableDictionary dictionaryWithDictionary:dic];
                                                            [dicM setObject:@"paid" forKey:@"isPaid"];
                                                            
                                                            NSMutableArray *arM_ExamInfos = [NSMutableArray arrayWithArray:[dic_Main objectForKey:@"examInfos"]];
                                                            
                                                            [arM_ExamInfos replaceObjectAtIndex:(btn.tag%1000) withObject:dicM];
                                                             
                                                            NSMutableDictionary *dicM_Main_Tmp = [NSMutableDictionary dictionaryWithDictionary:dic_Main];
                                                            [dicM_Main_Tmp setObject:arM_ExamInfos forKey:@"examInfos"];
                                                            [self.arM_List replaceObjectAtIndex:(btn.tag/1000) withObject:dicM_Main_Tmp];

                                                            [self.tbv_List reloadData];
                                                        }
                                                        else
                                                        {
                                                            ALERT_ONE([resulte objectForKey:@"error_message"]);
//                                                            [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                                        }
                                                    }
                                                }];
            }
        }];
    }
}

- (void)onItemInfo:(UIButton *)btn
{
    NSDictionary *dic_Main = self.arM_List[btn.tag/1000];
    NSArray *ar_ExamInfos = [dic_Main objectForKey:@"examInfos"];
    NSDictionary *dic = [ar_ExamInfos objectAtIndex:(btn.tag%1000)];
    
    __block NSString *str_ExamId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"examId"]];
    
    NSMutableArray *arM_Test = [NSMutableArray array];
    [arM_Test addObject:@{@"type":@"info", @"contents":[dic objectForKey:@"examTitle"]}];
    [arM_Test addObject:@{@"type":@"share", @"contents":@"공유"}];
    
    //단원보기 버튼 유무
    NSInteger nGroupId = [[dic objectForKey:@"groupId"] integerValue];
    if( nGroupId > 0 )
    {
        [arM_Test addObject:@{@"type":@"normal", @"contents":@"단원보기"}];
    }
    
    //결과보기 버튼 유무
    NSInteger nFinishCount = [[dic objectForKey:@"isFinishCount"] integerValue];
    NSInteger nSolve = [[dic objectForKey:@"isSolve"] integerValue];
    if( nFinishCount > 0 || nSolve == 1 )
    {
        //표시
        [arM_Test addObject:@{@"type":@"result", @"contents":@"결과보기"}];
    }
    
    if( [[dic objectForKey:@"isPaid"] isEqualToString:@"paid"] )
    {
        //구매 했을 경우에만 별점 띄우기
        [arM_Test addObject:@{@"type":@"star", @"contents":@"평가", @"data":dic}];
    }
    
    ActionSheetBottomViewController *vc = [kEtcBoard instantiateViewControllerWithIdentifier:@"ActionSheetBottomViewController"];
    vc.arM_List = arM_Test;
    [vc setCompletionStarBlock:^(id completeResult) {
        
        [self.arM_List replaceObjectAtIndex:btn.tag%1000 withObject:completeResult];
    }];

    [vc setCompletionBlock:^(id completeResult) {
        
        NSString *str_Type = [completeResult objectForKey:@"type"];
        if( [str_Type isEqualToString:@"info"] )
        {
            //정보
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            QuestionDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"QuestionDetailViewController"];
            vc.str_Idx = [NSString stringWithFormat:@"%@", [dic objectForKey:@"examId"]];
            vc.str_Title = [dic objectForKey:@"examTitle"];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if( [str_Type isEqualToString:@"share"] )
        {
            //공유
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chatting" bundle:nil];
            SharedViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SharedViewController"];
            vc.hidesBottomBarWhenPushed = YES;
            vc.str_ExamId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"examId"]];
            vc.str_QuestionId = @"0";
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if( [str_Type isEqualToString:@"normal"] )
        {
            //단원보기
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
            GroupWebViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"GroupWebViewController"];
            vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"groupId"] integerValue]];
            vc.str_GroupName = [dic objectForKey_YM:@"groupName"];
            vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if( [str_Type isEqualToString:@"result"] )
        {
            //결과보기
            NSInteger nGrade = [[dic objectForKey:@"personGrade"] integerValue];
            NSString *str_Grade = [NSString stringWithFormat:@"%@ %@학년", [dic objectForKey:@"schoolGrade"], nGrade == 0 ? @"전체" : [NSString stringWithFormat:@"%ld", nGrade]];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
            ReportDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ReportDetailViewController"];
            vc.str_Title = [NSString stringWithFormat:@"%@ %@ %@", [dic objectForKey:@"subjectName"], str_Grade, [dic objectForKey:@"publisherName"]];
            vc.str_ExamId = [dic objectForKey:@"examId"];
            vc.str_PUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
            [self presentViewController:vc animated:YES completion:^{
                
            }];
        }
        else if( [str_Type isEqualToString:@"toggle"] )
        {
//            NSNumber *num = [completeResult objectForKey:@"onOff"];
//            BOOL isOnOff = [num boolValue];
//            [self onSharedChange:isOnOff withExamId:str_ExamId withIdx:btn.tag];
        }
    }];
    
    [self presentViewController:vc animated:YES completion:^{
        
    }];
}

- (void)onPriceSelected:(UIButton *)btn
{

}

- (void)onGoChannel:(UIButton *)btn
{
    NSDictionary *dic_Main = self.arM_List[btn.tag];
 
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate showChannelView:dic_Main];

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
//    
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Channel" bundle:nil];
//    ChannelMainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChannelMainViewController"];
//    vc.hidesBottomBarWhenPushed = YES;
//    vc.isShowNavi = YES;
//    vc.str_ChannelId = str_ChannelId;
//    [self.navigationController pushViewController:vc animated:YES];

}



#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self.popTip hide];
}


#pragma mark - IBAction
- (void)onMoreChannel:(UIButton *)btn
{
    NSDictionary *dic = self.arM_List[btn.tag];
    
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate showChannelView:dic];
}

- (void)onMore:(UIButton *)btn
{
//    //전체보기로 이동
//    QuestionAllViewController *vc = [self.storyboard instantiateViewControllerWithIdentifier:@"QuestionAllViewController"];
//    vc.ar_List = self.arM_List;
//    [self.navigationController pushViewController:vc animated:YES];
    
    //해당 채널로 이동
    NSDictionary *dic = self.arM_List[btn.tag];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Channel" bundle:nil];
    ChannelMainViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChannelMainViewController"];
    vc.isShowNavi = YES;
    vc.str_ChannelId = [NSString stringWithFormat:@"%ld", [[dic objectForKey:@"basicConditionValue"] integerValue]];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)onInfo:(UIButton *)btn
{
//    self.popTip.bubbleOffset = 0;

    CGPoint buttonPosition = [btn convertPoint:CGPointZero toView:self.tbv_List];
    NSIndexPath *indexPath = [self.tbv_List indexPathForRowAtPoint:buttonPosition];

    NSDictionary *dic_Main = self.arM_List[indexPath.row];
    NSArray *ar_ExamInfos = [dic_Main objectForKey:@"examInfos"];

    NSDictionary *dic = ar_ExamInfos[btn.tag];
    
    
    
    NSMutableArray *arM_Test = [NSMutableArray array];
    [arM_Test addObject:@{@"type":@"info", @"contents":[dic objectForKey:@"examTitle"]}];
    [arM_Test addObject:@{@"type":@"share", @"contents":@"공유"}];
    
    //단원보기 버튼 유무
    NSInteger nGroupId = [[dic objectForKey:@"groupId"] integerValue];
    if( nGroupId > 0 )
    {
        [arM_Test addObject:@{@"type":@"normal", @"contents":@"단원보기"}];
    }
    
    //결과보기 버튼 유무
    NSInteger nFinishCount = [[dic objectForKey:@"isFinishCount"] integerValue];
    NSInteger nSolve = [[dic objectForKey:@"isSolve"] integerValue];
    if( nFinishCount > 0 || nSolve == 1 )
    {
        //표시
        [arM_Test addObject:@{@"type":@"result", @"contents":@"결과보기"}];
    }
    
    if( [[dic objectForKey:@"isPaid"] isEqualToString:@"paid"] )
    {
        //구매 했을 경우에만 별점 띄우기
        [arM_Test addObject:@{@"type":@"star", @"contents":@"평가", @"data":dic}];
    }
    
    ActionSheetBottomViewController *vc = [kEtcBoard instantiateViewControllerWithIdentifier:@"ActionSheetBottomViewController"];
    vc.arM_List = arM_Test;
    [vc setCompletionStarBlock:^(id completeResult) {
        
        [self.arM_List replaceObjectAtIndex:btn.tag%1000 withObject:completeResult];
    }];

    [vc setCompletionBlock:^(id completeResult) {
        
        NSString *str_Type = [completeResult objectForKey:@"type"];
        if( [str_Type isEqualToString:@"info"] )
        {
            //정보
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            QuestionDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"QuestionDetailViewController"];
            vc.str_Idx = [NSString stringWithFormat:@"%@", [dic objectForKey:@"examId"]];
            vc.str_Title = [dic objectForKey:@"examTitle"];
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if( [str_Type isEqualToString:@"share"] )
        {
            //공유
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Chatting" bundle:nil];
            SharedViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"SharedViewController"];
            vc.hidesBottomBarWhenPushed = YES;
            vc.str_ExamId = [NSString stringWithFormat:@"%@", [dic objectForKey:@"examId"]];
            vc.str_QuestionId = @"0";
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if( [str_Type isEqualToString:@"normal"] )
        {
            //단원보기
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
            GroupWebViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"GroupWebViewController"];
            vc.str_Idx = [NSString stringWithFormat:@"%ld", [[dic objectForKey_YM:@"groupId"] integerValue]];
            vc.str_GroupName = [dic objectForKey_YM:@"groupName"];
            vc.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            
            [self.navigationController pushViewController:vc animated:YES];
        }
        else if( [str_Type isEqualToString:@"result"] )
        {
            //결과보기
            NSInteger nGrade = [[dic objectForKey:@"personGrade"] integerValue];
            NSString *str_Grade = [NSString stringWithFormat:@"%@ %@학년", [dic objectForKey:@"schoolGrade"], nGrade == 0 ? @"전체" : [NSString stringWithFormat:@"%ld", nGrade]];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Etc" bundle:nil];
            ReportDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ReportDetailViewController"];
            vc.str_Title = [NSString stringWithFormat:@"%@ %@ %@", [dic objectForKey:@"subjectName"], str_Grade, [dic objectForKey:@"publisherName"]];
            vc.str_ExamId = [dic objectForKey:@"examId"];
            vc.str_PUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
            [self presentViewController:vc animated:YES completion:^{
                
            }];
        }
        else if( [str_Type isEqualToString:@"toggle"] )
        {
            //            NSNumber *num = [completeResult objectForKey:@"onOff"];
            //            BOOL isOnOff = [num boolValue];
            //            [self onSharedChange:isOnOff withExamId:str_ExamId withIdx:btn.tag];
        }
    }];
    
    [self presentViewController:vc animated:YES completion:^{
        
    }];

//    //대상
//    NSInteger nGrade = [[dic_Sub objectForKey:@"personGrade"] integerValue];
//    NSString *str_Target = [NSString stringWithFormat:@"%@ %@학년", [dic_Sub objectForKey:@"schoolGrade"], nGrade == 0 ? @"전체" : [NSString stringWithFormat:@"%ld", nGrade]];
//    
//    //문제수
//    NSString *str_QuestionCnt = [NSString stringWithFormat:@"%ld문제", [[dic_Sub objectForKey:@"questionCount"] integerValue]];
//    
//    //시험본 사람
//    NSString *str_ExamUserCnt = [NSString stringWithFormat:@"%ld명", [[dic_Sub objectForKey:@"examSolveCount"] integerValue]];
//    
//    //출제자
//    NSString *str_Ower = [dic_Sub objectForKey:@"teacherName"];
//    
//    //만든일자
//    NSString *str_MakeDate = [dic_Sub objectForKey:@"createDate"];
//     
//    
//    self.popTip.popoverColor = kMainColor;
//    static int direction = 0;
//    NSString *str_Msg = [NSString stringWithFormat:@"대상 : %@\n문제수 : %@\n시험본 사람 : %@\n출제자 : %@\n만든일자 : %@", str_Target, str_QuestionCnt, str_ExamUserCnt, str_Ower, str_MakeDate];
//    [self.popTip showText:str_Msg direction:AMPopTipDirectionUp maxWidth:200 inView:self.tbv_List fromFrame:CGRectMake(buttonPosition.x + 10, buttonPosition.y, btn.frame.size.width, btn.frame.size.height) duration:0];
//    direction = (direction + 1) % 4;
}

- (void)onSetting:(UIButton *)btn
{
    NSMutableArray *arM = [NSMutableArray array];
    NSDictionary *dic_Main = self.arM_List[btn.tag];
    NSArray *ar = [dic_Main objectForKey:@"settingInfos"];
    for( NSInteger i = 0; i < ar.count; i++ )
    {
        NSDictionary *dic = ar[i];
        NSString *str_Title = [NSString stringWithFormat:@"%@(%@)", [dic objectForKey:@"subjectName"], [dic objectForKey:@"subjectNameCount"]];
        [arM addObject:str_Title];
    }
    
    [OHActionSheet showSheetInView:self.view
                             title:nil
                 cancelButtonTitle:@"취소"
            destructiveButtonTitle:nil
                 otherButtonTitles:arM
                        completion:^(OHActionSheet* sheet, NSInteger buttonIndex){
                            
         
                            
     }];
}

- (IBAction)goShowSearchType:(id)sender
{
    NSArray *ar = @[@"고등학교", @"일반", @"중학교"];
    [FTPopOverMenu showForSender:sender
                   withMenuArray:ar
                      imageArray:nil
                       doneBlock:^(NSInteger selectedIndex) {
                           
                           NSLog(@"done block. do something. selectedIndex : %ld", (long)selectedIndex);
                           
                           NSString *str_QDW = ar[selectedIndex];
                           self.searchBar.placeholder = str_QDW;
                           
                           [[NSUserDefaults standardUserDefaults] setObject:str_QDW forKey:@"QDW"];
                           [[NSUserDefaults standardUserDefaults] synchronize];
                           
                       } dismissBlock:^{
                           
                           NSLog(@"user canceled. do nothing.");
                           
                           //                           FTPopOverMenuConfiguration *configuration = [FTPopOverMenuConfiguration defaultConfiguration];
                           //                           configuration.allowRoundedArrow = !configuration.allowRoundedArrow;
                           
                       }];
}

@end
