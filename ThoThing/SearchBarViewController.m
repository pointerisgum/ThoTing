//메뉴탭이 검색이 안되면 그건 통외의 검색임 통외의 검색은 표현방식이 다름
//
//  SearchBarViewController.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 9. 29..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "SearchBarViewController.h"
#import "QuestionDetailViewController.h"
#import "ActionSheetBottomViewController.h"
#import "SharedViewController.h"
#import "GroupWebViewController.h"
#import "ReportDetailViewController.h"

//static CGFloat kMenuWidth = 67.f;

@interface SearchBarViewController () <UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource>
{
    BOOL isLoding;
    CGFloat kMenuWidth;
    CGRect keyboardBounds;
    BOOL isSearchIn;
    NSInteger nSelectedIdx;
    CGFloat fBottomHeight;
}
@property (nonatomic, strong) NSMutableArray *arM_SelectItem;
@property (nonatomic, strong) NSMutableArray *arM_TopList;
@property (nonatomic, strong) NSMutableDictionary *dicM_List;
@property (nonatomic, strong) NSMutableDictionary *dicM_TbvList;
@property (nonatomic, strong) NSMutableDictionary *dicM_TotalCount;

@property (nonatomic, weak) IBOutlet UISearchBar *searchBar;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_CancelWidth;

@property (nonatomic, weak) IBOutlet UIScrollView *sv_Menu;
@property (nonatomic, weak) IBOutlet UIView *v_Menu;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_MenuWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_MenuHeight;

@property (nonatomic, weak) IBOutlet UIScrollView *sv_BottomList;
@property (nonatomic, weak) IBOutlet UIView *v_Bottom;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_ContentsWidth;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_CotentsBottom;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_BackWidth;
@end

@implementation SearchBarViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    kMenuWidth = (self.view.bounds.size.width / 6) + 4;
    
    if( self.isBotMakeMode )
    {
        if( self.ar_DidSelectList )
        {
            self.arM_SelectItem = [NSMutableArray arrayWithArray:self.ar_DidSelectList];
        }
        else
        {
            self.arM_SelectItem = [NSMutableArray array];
        }
    }
    
    self.dicM_List = [NSMutableDictionary dictionary];
    self.dicM_TbvList = [NSMutableDictionary dictionary];
    self.dicM_TotalCount = [NSMutableDictionary dictionary];
    
    self.sv_BottomList.backgroundColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1];
    
    if( self.str_SearchWord )
    {
        self.searchBar.text = self.str_SearchWord;
        self.lc_CancelWidth.constant = 60.f;
    }
    else if( self.isBotMakeMode )
    {
        self.lc_CancelWidth.constant = 0.f;
        self.lc_BackWidth.constant = 60.f;
    }
    else
    {
        self.lc_CancelWidth.constant = 0.f;
        [self.searchBar becomeFirstResponder];
    }
    
    [self updateBestMenu];
}

- (void)viewDidLayoutSubviews
{
    if( self.lc_CotentsBottom.constant <= 0 )
    {
        //키보드가 내려가 있는 상태
        NSArray *ar_AllKeys = [self.dicM_List allKeys];
        for( NSInteger i = 0; i < ar_AllKeys.count; i++ )
        {
            UITableView *tbv = [self.dicM_TbvList objectForKey:[ar_AllKeys objectAtIndex:i]];
            CGRect frame = tbv.frame;
            frame.size.height = self.view.bounds.size.height - (64 + 44 + (isSearchIn ? 0 : -44));
            tbv.frame = frame;
        }
    }
    else
    {
        //키보드가 올라가 있는 상태
        NSArray *ar_AllKeys = [self.dicM_List allKeys];
        for( NSInteger i = 0; i < ar_AllKeys.count; i++ )
        {
            UITableView *tbv = [self.dicM_TbvList objectForKey:[ar_AllKeys objectAtIndex:i]];
            CGRect frame = tbv.frame;
            frame.size.height = self.view.bounds.size.height - (64 + 44 + (isSearchIn ? 0 : -44) + keyboardBounds.size.height);
            tbv.frame = frame;
        }
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBarHidden = YES;
    self.hidesBottomBarWhenPushed = YES;

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
    
    fBottomHeight = self.v_Bottom.frame.size.height;

    if( self.lc_CancelWidth.constant < 60.f )
    {
        if( self.isBotMakeMode )
        {
            self.lc_CancelWidth.constant = 0.f;
        }
        else
        {
            self.lc_CancelWidth.constant = 60.0f;
        }
        
        [self.view setNeedsUpdateConstraints];
        
        [UIView animateWithDuration:0.1f animations:^{
            [self.view layoutIfNeeded];
        }completion:^(BOOL finished) {
            
//            if( [self.searchBar isFirstResponder] == NO )
//            {
//                [self.searchBar becomeFirstResponder];
//            }
        }];
    }

    [self.view setNeedsLayout];
    
//    if( [self.searchBar isFirstResponder] == NO )
//    {
//        if( self.lc_CancelWidth.constant < 60.f )
//        {
//            self.lc_CancelWidth.constant = 60.0f;
//            [self.view setNeedsUpdateConstraints];
//            
//            [UIView animateWithDuration:0.25f animations:^{
//                [self.view layoutIfNeeded];
//            }completion:^(BOOL finished) {
//
//            }];
//        }
//    }

}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.hidesBottomBarWhenPushed = NO;

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
    [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardBounds];
    NSNumber *duration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [notification.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    [UIView animateWithDuration:[duration doubleValue] animations:^{
        [UIView setAnimationCurve:[curve intValue]];
        if([notification name] == UIKeyboardWillShowNotification)
        {
            self.lc_CotentsBottom.constant = keyboardBounds.size.height;
            [self.view updateConstraints];
            [self.view setNeedsLayout];
        }
        else if([notification name] == UIKeyboardWillHideNotification)
        {
            self.lc_CotentsBottom.constant = 0;
            [self.view updateConstraints];
            [self.view setNeedsLayout];
        }
    }completion:^(BOOL finished) {
        
    }];
}

#pragma mark - UISearchBarDelegate
- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar resignFirstResponder];
    
    [UIView animateWithDuration:0.3f animations:^{
        self.sv_BottomList.contentOffset = self.sv_Menu.contentOffset = CGPointZero;
    }completion:^(BOOL finished) {
        [self updateBestMenu];
    }];
}

- (void)onSearchInterval
{
    [self reloadList];
}


- (void)updateBestMenu
{
    nSelectedIdx = 0;
    
    for( id subView in self.v_Menu.subviews )
    {
        if( [subView isKindOfClass:[UIButton class]] )
        {
            UIButton *obj = (UIButton *)subView;
            [obj removeFromSuperview];
        }
    }
    
    for( id subView in self.v_Bottom.subviews )
    {
        if( [subView isKindOfClass:[UITableView class]] )
        {
            UITableView *obj = (UITableView *)subView;
            [obj removeFromSuperview];
        }
    }
    
    [self.arM_TopList removeAllObjects];
    [self.dicM_List removeAllObjects];
    [self.dicM_TbvList removeAllObjects];
    
    
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
//                                        self.searchBar.text, @"keyword",
                                        self.str_Type, @"keyword",
                                        nil];
    
    if( self.isLibraryMode )
    {
        [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] forKey:@"pUserId"];
        [dicM_Params setObject:self.searchBar.text forKey:@"keyword"];
    }
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/search/tab/info"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                //성공
                                                //통 안의 검색
                                                self.arM_TopList = [NSMutableArray arrayWithArray:[resulte objectForKey:@"tabInfos"]];
                                                [self menuUpdate];
                                                [self updateList];
                                            }
                                            else if( nCode == 201 )
                                            {
                                                //통 외의 검색
                                                [self updateList];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                        
//                                        [self.searchBar resignFirstResponder];
                                    }];
}

- (void)updateList
{
    NSMutableDictionary *dicM_Params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                        [[NSUserDefaults standardUserDefaults] objectForKey:@"apiToken"], @"apiToken",
                                        [Util getUUID], @"uuid",
                                        nil];
    
    if( self.arM_TopList != nil && self.arM_TopList.count > 0 )
    {
        //통 안의 검색
        isSearchIn = YES;
        self.lc_MenuHeight.constant = 0.f;
        
        NSDictionary *dic = self.arM_TopList[nSelectedIdx];
        [dicM_Params setObject:self.searchBar.text ? self.searchBar.text : @"" forKey:@"keyword"];
        [dicM_Params setObject:[dic objectForKey_YM:@"tabKeywordType"] forKey:@"keywordType"];
        [dicM_Params setObject:[NSString stringWithFormat:@"%@", [dic objectForKey:@"tabSchoolGrade"]] forKey:@"schoolGrade"];
        [dicM_Params setObject:[NSString stringWithFormat:@"%@", [dic objectForKey:@"tabPersonGrade"]] forKey:@"personGrade"];
    }
    else
    {
        //통 외의 검색
        isSearchIn = NO;
        self.lc_MenuHeight.constant = -44.f;
        
        [dicM_Params setObject:self.searchBar.text ? self.searchBar.text : @"" forKey:@"keyword"];
        [dicM_Params setObject:@"" forKey:@"keywordType"];
        [dicM_Params setObject:@"" forKey:@"schoolGrade"];
        [dicM_Params setObject:@"" forKey:@"personGrade"];
    }
    //v1/get/search/exam/list?
    //apiToken=teacherApiToken
    //uuid=teacherUUID
    //mode=test
    //keywordType=hit
    
    if( self.isLibraryMode )
    {
        [dicM_Params setObject:[[NSUserDefaults standardUserDefaults] objectForKey:@"userId"] forKey:@"pUserId"];
    }
    
    NSArray *ar_Tmp = [self.dicM_List objectForKey:[NSString stringWithFormat:@"%ld", nSelectedIdx]];

    NSString *str_TotalCnt = [self.dicM_TotalCount objectForKey:[NSString stringWithFormat:@"%ld", nSelectedIdx]];
    if( ar_Tmp && ar_Tmp.count > 0 )
    {
        if( ar_Tmp.count >= [str_TotalCnt integerValue] )
        {
            return;
        }
    }
    
    [dicM_Params setObject:[NSString stringWithFormat:@"%ld", ar_Tmp.count] forKey:@"offsetCount"];
    
    [dicM_Params setObject:@"30" forKey:@"limitCount"];

    isLoding = YES;
    
    [[WebAPI sharedData] callAsyncWebAPIBlock:@"v1/get/search/exam/list"
                                        param:dicM_Params
                                   withMethod:@"GET"
                                    withBlock:^(id resulte, NSError *error) {
                                        
                                        if( resulte )
                                        {
                                            NSInteger nCode = [[resulte objectForKey:@"response_code"] integerValue];
                                            if( nCode == 200 )
                                            {
                                                //성공
                                                NSArray *ar_Tmp = [self.dicM_List objectForKey:[NSString stringWithFormat:@"%ld", nSelectedIdx]];
                                                if( ar_Tmp == nil )
                                                {
                                                    ar_Tmp = [NSArray array];
                                                }
                                                NSMutableArray *arM = [NSMutableArray arrayWithArray:ar_Tmp];
                                                NSArray *ar = [NSArray arrayWithArray:[resulte objectForKey:@"examInfos"]];
                                                [arM addObjectsFromArray:ar];
                                                
                                                NSString *str_TotalCnt = [NSString stringWithFormat:@"%@", [resulte objectForKey:@"totalExamCount"]];
                                                [self.dicM_TotalCount setObject:str_TotalCnt forKey:[NSString stringWithFormat:@"%ld", nSelectedIdx]];
                                                
                                                [self.dicM_List setObject:arM
                                                                   forKey:[NSString stringWithFormat:@"%ld", nSelectedIdx]];
                                                [self addTbv:1];
                                                [self reloadList];
                                            }
                                            else
                                            {
                                                [self.navigationController.view makeToast:[resulte objectForKey:@"error_message"] withPosition:kPositionCenter];
                                            }
                                        }
                                        
                                        isLoding = NO;
                                    }];
}

- (void)menuUpdate
{
    for( NSInteger i = 0; i < self.arM_TopList.count; i++ )
    {
        NSDictionary *dic = self.arM_TopList[i];
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.tag = i;
        btn.frame = CGRectMake(i * kMenuWidth, 0, kMenuWidth, self.sv_Menu.bounds.size.height);
        [btn setTitle:[dic objectForKey:@"tabName"] forState:0];
        [btn.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:13]];
        [btn setTitleColor:kMainColor forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
        [btn addTarget:self action:@selector(onMeneSelected:) forControlEvents:UIControlEventTouchUpInside];
        [btn setBackgroundImage:BundleImage(@"underbar.png") forState:UIControlStateSelected];
        
        if( nSelectedIdx == i )
        {
            btn.selected = YES;
        }
        
        [self.v_Menu addSubview:btn];
    }
    
    self.sv_Menu.contentSize = CGSizeMake(self.arM_TopList.count * kMenuWidth, self.sv_Menu.bounds.size.height);
    self.lc_MenuWidth.constant = self.sv_Menu.contentSize.width;
    
    self.sv_BottomList.contentSize = CGSizeMake(self.arM_TopList.count * self.sv_BottomList.bounds.size.width, self.sv_BottomList.bounds.size.height);
    self.lc_ContentsWidth.constant = self.arM_TopList.count * self.sv_BottomList.bounds.size.width;
    
    [self addTbv:self.arM_TopList.count];
}

- (void)addTbv:(NSInteger)nCnt
{
    for( NSInteger i = 0; i < nCnt; i++ )
    {
        UITableView *tbv = [self.dicM_TbvList objectForKey:[NSString stringWithFormat:@"%ld", i]];
        if( tbv == nil )
        {
            tbv = [[UITableView alloc] initWithFrame:CGRectMake((i * self.sv_BottomList.bounds.size.width) == 0 ? 10 : i * self.sv_BottomList.bounds.size.width + 10,
                                                                0,
                                                                self.sv_BottomList.bounds.size.width - 20,
                                                                self.view.bounds.size.height - (64 + 44))];
            
            tbv.delegate = self;
            tbv.dataSource = self;
            tbv.backgroundColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1];
            tbv.separatorStyle = UITableViewCellSeparatorStyleNone;
            
            [self.dicM_TbvList setObject:tbv forKey:[NSString stringWithFormat:@"%ld", i]];
            [self.v_Bottom addSubview:tbv];
        }
    }
    
    [self.view setNeedsLayout];
}

- (void)onMeneSelected:(UIButton *)btn
{
    UITableView *tbv = [self.dicM_TbvList objectForKey:[NSString stringWithFormat:@"%ld", nSelectedIdx]];
    [tbv setContentOffset:tbv.contentOffset animated:NO];

    nSelectedIdx = btn.tag;
    
    for( id subView in self.v_Menu.subviews )
    {
        if( [subView isKindOfClass:[UIButton class]] )
        {
            UIButton *btn_Sub = (UIButton *)subView;
            if( btn_Sub.tag == nSelectedIdx )
            {
                btn_Sub.selected = YES;
            }
            else
            {
                btn_Sub.selected = NO;
            }
        }
    }
    
    [UIView animateWithDuration:0.3f animations:^{
    
        self.sv_BottomList.contentOffset = CGPointMake(self.sv_BottomList.bounds.size.width * nSelectedIdx, 0);
    }];
    
    [self updateList];
    
    [self.view endEditing:YES];
}

- (void)reloadList
{
    UITableView *tbv = [self.dicM_TbvList objectForKey:[NSString stringWithFormat:@"%ld", nSelectedIdx]];
    [tbv reloadData];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if( scrollView.contentOffset.y > scrollView.contentSize.height - self.view.frame.size.height - 70 && isLoding == NO )
    {
        [self updateList];
    }
    //    else if( isLoding == NO )
    //    {
    //        //down
    //        isLoding = YES;
    //        [self updateList];
    //    }
}


#pragma mark - UITableView Delegate & DataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSArray *ar_List = [self.dicM_List objectForKey:[NSString stringWithFormat:@"%ld", nSelectedIdx]];
    return ar_List.count;
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

//- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (indexPath.row == [self tableView:tableView numberOfRowsInSection:indexPath.section] - 1)
//    {
//        // last row
//        cell.layer.shadowOpacity = 0.5;
//        cell.layer.shadowPath = [UIBezierPath bezierPathWithRect:cell.bounds].CGPath;
//        cell.layer.masksToBounds = NO;
//    }
//}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
//    cell.contentView.layer.shadowOffset = CGSizeMake(10, 10);
//    cell.layer.shadowOffset = CGSizeMake(10, 10);

    
    cell.layer.masksToBounds = NO;
    cell.clipsToBounds = YES;
    cell.layer.borderColor = [UIColor colorWithRed:200.f/255.f green:200.f/255.f blue:200.f/255.f alpha:1].CGColor;
    cell.layer.borderWidth = 0.5f;

    
//    cell.layer.shadowOpacity = 1.0;
//    cell.layer.shadowRadius = 1;
//    cell.layer.shadowOffset = CGSizeMake(5, 5);
//    cell.layer.shadowColor = [UIColor redColor].CGColor;

//    cell.layer.shadowOffset = CGSizeMake(25, 25);
//    cell.layer.shadowColor = [[UIColor redColor] CGColor];
//    cell.layer.shadowRadius = 3;
//    cell.layer.shadowOpacity = .75f;
//    CGRect shadowFrame = cell.layer.bounds;
//    CGPathRef shadowPath = [UIBezierPath bezierPathWithRect:shadowFrame].CGPath;
//    cell.layer.shadowPath = shadowPath;

//    cell.contentView.layer.shadowOpacity = 1.0;
//    cell.contentView.layer.shadowRadius = 1;
//    cell.contentView.layer.shadowOffset = CGSizeMake(0, 2);
//    cell.contentView.layer.shadowColor = [UIColor blackColor].CGColor;

//    UIView *v = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 375, 100)];
//    v.backgroundColor = [UIColor whiteColor];
    

    
    for( id subView in cell.contentView.subviews )
    {
        [subView removeFromSuperview];
    }
    
    NSArray *ar_List = [self.dicM_List objectForKey:[NSString stringWithFormat:@"%ld", nSelectedIdx]];
    NSDictionary *dic = ar_List[indexPath.section];
    
    if( isSearchIn )
    {
        /*
         통안의 검색 결과
         bgColor = "bgm-bluegray";
         codeHex = "#607D8B";
         codeName = "bgm-bluegray";
         examId = 415;
         examTitle = "2016\Ud559\Ub144\Ub3c4 3\Uc6d4 \Uace03 \Uc804\Uad6d\Uc5f0\Ud569\Ud559\Ub825\Ud3c9\Uac00";
         examUniqueUserCount = 13;
         examUserCount = 18;
         hashTag = "#\Ud559\Ud3c9";
         personGrade = 0;
         questionCount = 8;
         schoolGrade = "\Uace0\Ub4f1\Ud559\Uad50";
         score = 160;
         subjectName = "\Uad6d\Uc5b4";
         */
        
        UIImageView *iv_Cover = [[UIImageView alloc] initWithFrame:CGRectMake(5, 10, 60, 80)];
        
        if( [[dic objectForKey:@"codeHex"] isEqual:[NSNull null]] || [dic objectForKey:@"codeHex"] == nil )
        {
            iv_Cover.backgroundColor = [UIColor blackColor];
        }
        else
        {
            iv_Cover.backgroundColor = [UIColor colorWithHexString:[dic objectForKey_YM:@"codeHex"]];
        }
        
        UILabel *lb_Subject = [[UILabel alloc] initWithFrame:CGRectMake(iv_Cover.frame.origin.x + 5, iv_Cover.frame.origin.y + 5,
                                                                        iv_Cover.frame.size.width - 10, iv_Cover.frame.size.height - 10)];
        lb_Subject.text = [dic objectForKey:@"subjectName"];
        lb_Subject.numberOfLines = 0;
        lb_Subject.textAlignment = NSTextAlignmentCenter;
        lb_Subject.font = [UIFont fontWithName:@"Helvetica" size:12.f];
        lb_Subject.textColor = [UIColor whiteColor];
        lb_Subject.minimumScaleFactor = 0.5f;
        
        UILabel *lb_Title = [[UILabel alloc] initWithFrame:CGRectMake(iv_Cover.frame.origin.x + iv_Cover.frame.size.width + 10, 10,
                                                                      self.view.bounds.size.width - (iv_Cover.frame.origin.x + iv_Cover.frame.size.width + 10 + 8 + 40), 36)];
        lb_Title.text = [dic objectForKey:@"examTitle"];
        lb_Title.numberOfLines = 2;
        lb_Title.textAlignment = NSTextAlignmentLeft;
        lb_Title.font = [UIFont fontWithName:@"Helvetica" size:14.f];
        lb_Title.textColor = kMainColor;
        
        UILabel *lb_Tag = [[UILabel alloc] initWithFrame:CGRectMake(lb_Title.frame.origin.x, lb_Title.frame.origin.y + lb_Title.frame.size.height,
                                                                    lb_Title.frame.size.width, 20)];
        lb_Tag.text = [dic objectForKey:@"hashTag"];
        lb_Tag.numberOfLines = 1;
        lb_Tag.textAlignment = NSTextAlignmentLeft;
        lb_Tag.font = [UIFont fontWithName:@"Helvetica" size:14.f];
        lb_Tag.textColor = [UIColor lightGrayColor];
        
        UILabel *lb_Ower = [[UILabel alloc] initWithFrame:CGRectMake(lb_Tag.frame.origin.x, lb_Tag.frame.origin.y + lb_Tag.frame.size.height,
                                                                     lb_Tag.frame.size.width, 20)];
        lb_Ower.text = [dic objectForKey:@"schoolGrade"];
        lb_Ower.numberOfLines = 1;
        lb_Ower.textAlignment = NSTextAlignmentLeft;
        lb_Ower.font = [UIFont fontWithName:@"Helvetica" size:14.f];
        lb_Ower.textColor = [UIColor darkGrayColor];
        
        UIWindow *window = [[UIApplication sharedApplication] keyWindow];
        UIButton *btn_Info = [UIButton buttonWithType:UIButtonTypeCustom];
        if( self.isBotMakeMode )
        {
            btn_Info.frame = CGRectMake(window.bounds.size.width - 55, 0, 40, 50);
        }
        else
        {
            btn_Info.frame = CGRectMake(window.bounds.size.width - 55, 0, 40, 100);
        }
        [btn_Info setImage:BundleImage(@"info.png") forState:UIControlStateNormal];
        btn_Info.tag = indexPath.section;
        [btn_Info addTarget:self action:@selector(onItemInfo:) forControlEvents:UIControlEventTouchUpInside];

        [cell.contentView addSubview:iv_Cover];
        [cell.contentView addSubview:lb_Subject];
        [cell.contentView addSubview:lb_Title];
        [cell.contentView addSubview:lb_Tag];
        [cell.contentView addSubview:lb_Ower];
        [cell.contentView addSubview:btn_Info];

        if( self.isBotMakeMode )
        {
            UIButton *btn_Check = [UIButton buttonWithType:UIButtonTypeCustom];
            btn_Check.selected = NO;
            btn_Check.frame = CGRectMake(window.bounds.size.width - 55, 50, 40, 50);
            
            [btn_Check setImage:BundleImage(@"kik_cell_select_off.png") forState:UIControlStateNormal];
            [btn_Check setImage:BundleImage(@"kik_cell_select_on.png") forState:UIControlStateSelected];
            btn_Check.tag = indexPath.section;
            [btn_Check addTarget:self action:@selector(onCheck:) forControlEvents:UIControlEventTouchUpInside];
            
            for( NSInteger i = 0; i < self.arM_SelectItem.count; i++ )
            {
                NSDictionary *dic_Tmp = self.arM_SelectItem[i];
                if( [dic_Tmp isEqual:dic] )
                {
                    btn_Check.selected = YES;
                    break;
                }
            }
            
            [cell.contentView addSubview:btn_Check];
        }
    }
    else
    {
        /*
         channelName = "\Uc9c4\Uba85\Ud559\Uc6d0";
         examId = 62;
         examNo = 319;
         examTitle = "1\Ub4f1\Uae09\Ub9cc\Ub4e4\Uae30 \Ud55c\Uad6d\Uc0ac 1060\Uc81c";
         hashString = "\Uc774\Uc21c\Uc2e0\Uc774 \Uc774\Ub044\Ub294 \Uc218\Uad70\Uc758 \Uc2b9\Ub9ac\Ub97c \Ud1b5\Ud574 (\U3000\U3000\U3000\U3000\U3000\U3000\U3000\U3000\U3000)\Uace1\Ucc3d\n\Uc9c0\Ub300\Ub97c \Uc9c0\Ud0a4\Uace0\Uff0c \Uc65c\Uad70\Uc758 \Ubb3c\Uc790 \Uc218\Uc1a1\Uc5d0 \Ud0c0\Uaca9\Uc744 \Uc904 \Uc218 \Uc788\Uc5c8\Ub2e4.";
         personGrade = "\Uc804\Uccb4";
         publisherName = "\Ubbf8\Ub798\Uc5d4";
         questionCount = 520;
         questionId = 3141;
         schoolGrade = "\Uace0\Ub4f1\Ud559\Uad50";
         subjectName = "\Ud55c\Uad6d\Uc0ac";
         teacherName = "\Uc9c4\Uba85\Ud559\Uc6d0";
         */
        
        UILabel *lb_Title = [[UILabel alloc] initWithFrame:CGRectMake(15, 10,
                                                                      self.view.bounds.size.width - 30, 20)];
        lb_Title.text = [dic objectForKey:@"examTitle"];
        lb_Title.numberOfLines = 1;
        lb_Title.textAlignment = NSTextAlignmentLeft;
        lb_Title.font = [UIFont fontWithName:@"Helvetica" size:14.f];
        lb_Title.textColor = kMainColor;

        UILabel *lb_Tag = [[UILabel alloc] initWithFrame:CGRectMake(lb_Title.frame.origin.x, lb_Title.frame.origin.y + lb_Title.frame.size.height,
                                                                      lb_Title.frame.size.width, 20)];
        lb_Tag.text = [NSString stringWithFormat:@"#%@ #%@ #%@", [dic objectForKey:@"schoolGrade"], [dic objectForKey:@"personGrade"], [dic objectForKey:@"subjectName"]];
        lb_Tag.numberOfLines = 1;
        lb_Tag.textAlignment = NSTextAlignmentLeft;
        lb_Tag.font = [UIFont fontWithName:@"Helvetica" size:14.f];
        lb_Tag.textColor = [UIColor lightGrayColor];
        
        UILabel *lb_Discription = [[UILabel alloc] initWithFrame:CGRectMake(lb_Tag.frame.origin.x, lb_Tag.frame.origin.y + lb_Tag.frame.size.height,
                                                                            lb_Title.frame.size.width, 36)];
        lb_Discription.text = [dic objectForKey:@"hashString"];
        lb_Discription.numberOfLines = 2;
        lb_Discription.textAlignment = NSTextAlignmentLeft;
        lb_Discription.font = [UIFont fontWithName:@"Helvetica" size:14.f];
        lb_Discription.textColor = [UIColor darkGrayColor];
        
        [cell.contentView addSubview:lb_Title];
        [cell.contentView addSubview:lb_Tag];
        [cell.contentView addSubview:lb_Discription];
    }

    return cell;
}


// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if( self.lc_CotentsBottom.constant > 0 )
    {
        [self.view endEditing:YES];
        return;
    }
    
    NSArray *ar_List = [self.dicM_List objectForKey:[NSString stringWithFormat:@"%ld", nSelectedIdx]];
    NSDictionary *dic = ar_List[indexPath.section];

    [self.view endEditing:YES];
    [self performSelector:@selector(onPushInterval:) withObject:dic afterDelay:0.3f];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *v_Section = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, 10)];
    v_Section.backgroundColor = [UIColor colorWithRed:240.f/255.f green:240.f/255.f blue:240.f/255.f alpha:1];
    return v_Section;
}

- (void)onCheck:(UIButton *)btn
{
    NSArray *ar_List = [self.dicM_List objectForKey:[NSString stringWithFormat:@"%ld", nSelectedIdx]];
    NSDictionary *dic = ar_List[btn.tag];

    for( NSInteger i = 0; i < self.arM_SelectItem.count; i++ )
    {
        NSDictionary *dic_Tmp = self.arM_SelectItem[i];
        if( [dic_Tmp isEqual:dic] )
        {
            [self.arM_SelectItem removeObject:dic];
            [self reloadList];
            return;
        }
    }
    
    [self.arM_SelectItem addObject:dic];
    [self reloadList];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    //    //푸터 고정
    //    CGFloat sectionFooterHeight = 70.f;
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
    
//    if( scrollView == self.tb )
    {
        //    헤더고정
        CGFloat sectionHeaderHeight = 10.f;
        if (scrollView.contentOffset.y <= sectionHeaderHeight && scrollView.contentOffset.y >= 0)
        {
            scrollView.contentInset = UIEdgeInsetsMake(-scrollView.contentOffset.y, 0, 0, 0);
        }
        else if (scrollView.contentOffset.y>=sectionHeaderHeight)
        {
            scrollView.contentInset = UIEdgeInsetsMake(-sectionHeaderHeight, 0, 0, 0);
        }
    }
}

- (void)onPushInterval:(NSDictionary *)dic
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    QuestionDetailViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"QuestionDetailViewController"];
    vc.str_Idx = [NSString stringWithFormat:@"%@", [dic objectForKey:@"examId"]];
    vc.str_Title = [dic objectForKey:@"examTitle"];
    [self.navigationController pushViewController:vc animated:YES];
}



#pragma mark - IBAction
- (IBAction)goCancel:(id)sender
{
    [self.searchBar resignFirstResponder];
    
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}

- (void)onItemInfo:(UIButton *)btn
{
    NSArray *ar_List = [self.dicM_List objectForKey:[NSString stringWithFormat:@"%ld", nSelectedIdx]];
    NSDictionary *dic = ar_List[btn.tag];
    
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
        
//        [self.arM_List replaceObjectAtIndex:btn.tag withObject:completeResult];
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
    }];
    
    [self presentViewController:vc animated:YES completion:^{
        
    }];
    
}

- (IBAction)goBack:(id)sender
{
    if( self.completionBlock )
    {
        self.completionBlock(self.arM_SelectItem);
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
