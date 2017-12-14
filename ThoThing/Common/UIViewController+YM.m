//
//  UIViewController+YM.m
//  EmAritaum
//
//  Created by Kim Young-Min on 2014. 3. 19..
//  Copyright (c) 2014년 Kim Young-Min. All rights reserved.
//

#import "UIViewController+YM.h"
#import "MFSideMenuContainerViewController.h"
#import "TWTSideMenuViewController.h"
#import "MWPhotoBrowser.h"
//#import "MWPhotoBrowser.h"
#import "QuestionViewController.h"


@implementation UIViewController (YM)

//- (void)viewWillAppear:(BOOL)animated
//{
//    [MBProgressHUD hide];
//}

- (UIBarButtonItem *)homeMenuButtonItem
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 40, 40);
    [btn_BarItem addTarget:self action:@selector(goHome:) forControlEvents:UIControlEventTouchUpInside];
    
    [btn_BarItem setImage:BundleImage(@"home_n.png") forState:UIControlStateNormal];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)blackNaviBackButton
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 21, 16);
    [btn_BarItem setImage:BundleImage(@"back_b.png") forState:UIControlStateNormal];
    [btn_BarItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_BarItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica-bold" size:16]];
    [btn_BarItem addTarget:self action:@selector(leftBackSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    //    btn_BarItem.imageEdgeInsets = UIEdgeInsetsMake(0, 50, 0, 0);
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)whiteNaviBackButton
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 21, 16);
    [btn_BarItem setImage:BundleImage(@"back_w.png") forState:UIControlStateNormal];
    [btn_BarItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_BarItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica-bold" size:16]];
    [btn_BarItem addTarget:self action:@selector(leftBackSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    //    btn_BarItem.imageEdgeInsets = UIEdgeInsetsMake(0, 50, 0, 0);
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)modalCloseBarButtonItem
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 40, 40);
    [btn_BarItem setTitle:@"닫기" forState:UIControlStateNormal];
    [btn_BarItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_BarItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica-bold" size:16]];
    [btn_BarItem addTarget:self action:@selector(goModalBack:) forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)writeNaviButton
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 26, 40);
    [btn_BarItem setImage:BundleImage(@"writeicon.png") forState:UIControlStateNormal];
    [btn_BarItem setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_BarItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica-bold" size:16]];
    [btn_BarItem addTarget:self action:@selector(goWrite:) forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)blackWriteNaviButton
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 26, 40);
    [btn_BarItem setImage:BundleImage(@"private_write.png") forState:UIControlStateNormal];
    [btn_BarItem setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_BarItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica-bold" size:16]];
    [btn_BarItem addTarget:self action:@selector(goWrite:) forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)modalCancelButton
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 40, 40);
    //    [btn_BarItem setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    //    [btn_BarItem setTitle:@"취소" forState:0];
    //    [btn_BarItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
    [btn_BarItem setImage:BundleImage(@"comm_tab_btn_close_b.png") forState:UIControlStateNormal];
    [btn_BarItem addTarget:self action:@selector(goModalBack:) forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)modalConfirmButton
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 40, 40);
    [btn_BarItem setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_BarItem setTitle:@"확인" forState:0];
    [btn_BarItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:16]];
    [btn_BarItem addTarget:self action:@selector(goDone:) forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)modalCloseBarButtonItemBlack
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 40, 40);
    [btn_BarItem setImage:BundleImage(@"chat_add.png") forState:UIControlStateNormal];
    [btn_BarItem setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_BarItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica-bold" size:16]];
    [btn_BarItem addTarget:self action:@selector(goModalBack:) forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)leftBackMenuBarButtonItem
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 44, 44);
    btn_BarItem.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    [btn_BarItem setImage:BundleImage(@"Icon_Nav__Black_Back.png") forState:UIControlStateNormal];
    //    [btn_BarItem setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_BarItem addTarget:self action:@selector(leftBackSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)leftBackBlackMenuBarButtonItem
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 44, 44);
    btn_BarItem.imageEdgeInsets = UIEdgeInsetsMake(0, -20, 0, 0);
    [btn_BarItem setImage:BundleImage(@"Icon_Nav__Black_Back.png") forState:UIControlStateNormal];
    //    [btn_BarItem setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_BarItem addTarget:self action:@selector(leftBackSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)EmptyleftBackMenuBarButtonItem
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 26, 40);
    [btn_BarItem setImage:BundleImage(@"") forState:UIControlStateNormal];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)rightMenuBarButtonItem
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 48, 38);
    [btn_BarItem addTarget:self action:@selector(rightSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    btn_BarItem.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -20);
    [btn_BarItem setImage:BundleImage(@"global_n.png") forState:UIControlStateNormal];
    
    //    if( IS_IOS7_LATER )
    //    {
    //        btn_BarItem.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -20);
    //        [btn_BarItem setImage:BundleImage(@"globalicon_s.png") forState:UIControlStateNormal];
    //    }
    //    else
    //    {
    //        [btn_BarItem setImage:BundleImage(@"global_n@2x.png") forState:UIControlStateNormal];
    //    }
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)rightQnaRoomInfo
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 48, 48);
    [btn_BarItem addTarget:self action:@selector(rightQnaRoomInfoPress:) forControlEvents:UIControlEventTouchUpInside];
    
    btn_BarItem.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -20);
    [btn_BarItem setImage:BundleImage(@"info_land.png") forState:UIControlStateNormal];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)rightIngQuestion
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 90, 30);
    [btn_BarItem addTarget:self action:@selector(rightIngQuestionPress:) forControlEvents:UIControlEventTouchUpInside];
    
    [btn_BarItem setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
    [btn_BarItem setTitle:@"풀고있는문제" forState:0];
    [btn_BarItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    
    btn_BarItem.layer.cornerRadius = 15.f;
    btn_BarItem.layer.borderColor = [UIColor darkGrayColor].CGColor;
    btn_BarItem.layer.borderWidth = 1.f;
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (void)rightIngQuestionPress:(UIButton *)btn
{
    
}

- (UIBarButtonItem *)rightQnaRoomInfoAndIcon:(UIButton *)userBtn
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(-20, 0, 70, 44)];
//    view.backgroundColor = [UIColor redColor];
//    view.layoutMargins = UIEdgeInsetsMake(0, -20, 0, 0);
    
    [view addSubview:userBtn];
//    if( image )
//    {
//        UIButton *btn_LeftItem = [UIButton buttonWithType:UIButtonTypeCustom];
//        btn_LeftItem.clipsToBounds = YES;
//        btn_LeftItem.backgroundColor = [UIColor whiteColor];
//        [btn_LeftItem setTitle:@"" forState:UIControlStateNormal];
//        [btn_LeftItem setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
//        [btn_LeftItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:13]];
//        btn_LeftItem.frame = CGRectMake(0, 3, 34, 34);
//        [btn_LeftItem addTarget:self action:@selector(rightLeftItemPress:) forControlEvents:UIControlEventTouchUpInside];
//        [btn_LeftItem setImage:image forState:0];
//        btn_LeftItem.layer.cornerRadius = btn_LeftItem.frame.size.width/2;
//        btn_LeftItem.layer.borderColor = [UIColor darkGrayColor].CGColor;
//        btn_LeftItem.layer.borderWidth = 1.f;
//        [view addSubview:btn_LeftItem];
//    }
    
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
//    btn_BarItem.backgroundColor = [UIColor blueColor];
    btn_BarItem.frame = CGRectMake(30, 0, 40, 40);
    [btn_BarItem addTarget:self action:@selector(rightQnaRoomInfoPress:) forControlEvents:UIControlEventTouchUpInside];
    btn_BarItem.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -10);
    [btn_BarItem setImage:BundleImage(@"info_land.png") forState:UIControlStateNormal];
    [view addSubview:btn_BarItem];
    
    return [[UIBarButtonItem alloc] initWithCustomView:view];
}

- (void)rightLeftItemPress:(UIButton *)btn
{
    
}

- (UIBarButtonItem *)rightInvitation
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 60, 40);
    [btn_BarItem setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_BarItem setTitle:@"초대하기" forState:0];
    [btn_BarItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
    [btn_BarItem addTarget:self action:@selector(rightInvitationPress:) forControlEvents:UIControlEventTouchUpInside];
    
    btn_BarItem.layer.cornerRadius = 8.f;
    btn_BarItem.layer.borderWidth = 1.f;
    btn_BarItem.layer.borderColor = [UIColor colorWithRed:200.f/255.f green:200.f/255.f blue:200.f/255.f alpha:1].CGColor;
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (void)rightInvitationPress:(UIButton *)btn
{
    
}

- (UIBarButtonItem *)rightLogOutButtonItem
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 48, 48);
    [btn_BarItem addTarget:self action:@selector(settingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    btn_BarItem.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -20);
    [btn_BarItem setImage:BundleImage(@"setting.png") forState:UIControlStateNormal];
    
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)addChannelButtionItem
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 48, 48);
    [btn_BarItem addTarget:self action:@selector(plusButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    btn_BarItem.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -20);
    [btn_BarItem setImage:BundleImage(@"add_channel.png") forState:UIControlStateNormal];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (void)plusButtonPressed:(UIButton *)btn
{
    
}

- (UIBarButtonItem *)rightReportButtonItem
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 90, 48);
    [btn_BarItem addTarget:self action:@selector(settingButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
//    btn_BarItem.backgroundColor = [UIColor redColor];
    
    [btn_BarItem setTitle:@"레포트설정\n채널,자신" forState:UIControlStateNormal];
    [btn_BarItem setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [btn_BarItem.titleLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [btn_BarItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:12]];
//    btn_BarItem.titleLabel.lineBreakMode = NSLineBreakByClipping;
//    btn_BarItem.semanticContentAttribute = UISemanticContentAttributeForceRightToLeft;
    
//    if( [self respondsToSelector:@selector(setSemanticContentAttribute:)] )
//    {
//        [btn_BarItem setSemanticContentAttribute:UISemanticContentAttributeForceRightToLeft];
//    }
//    else
//    {
//        btn_BarItem.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
//    }
    
    btn_BarItem.titleEdgeInsets = UIEdgeInsetsMake(0, -50, 0, 0);
//    btn_BarItem.contentEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 0);
    btn_BarItem.imageEdgeInsets = UIEdgeInsetsMake(0, 60, 0, 0);
    [btn_BarItem setImage:BundleImage(@"setting.png") forState:UIControlStateNormal];
    
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (void)settingButtonPressed:(UIButton *)btn
{

}

- (void)rightQnaRoomInfoPress:(UIButton *)btn
{
    
}

- (UIBarButtonItem *)rightBookMarkItem
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 45, 45);
    [btn_BarItem addTarget:self action:@selector(rightBookMarkPress:) forControlEvents:UIControlEventTouchUpInside];
    
    btn_BarItem.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -20);
    [btn_BarItem setImage:BundleImage(@"bookmark.png") forState:UIControlStateNormal];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)rightCropButton
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 40, 40);
    [btn_BarItem setTitle:@"Crop" forState:UIControlStateNormal];
    [btn_BarItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_BarItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica-bold" size:16]];
    [btn_BarItem addTarget:self action:@selector(onCrop:) forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)rightDoneButton
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 70, 40);
    btn_BarItem.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -20);
    [btn_BarItem setTitle:@"만들기" forState:UIControlStateNormal];
    [btn_BarItem setTitleColor:kMainColor forState:UIControlStateNormal];
    [btn_BarItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica-SemiBold" size:16]];
    [btn_BarItem addTarget:self action:@selector(onDone:) forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)addQuestion
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 80, 40);
    btn_BarItem.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -20);
    [btn_BarItem setTitle:@"+문제추가" forState:UIControlStateNormal];
    btn_BarItem.titleLabel.textAlignment = NSTextAlignmentRight;
    [btn_BarItem setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn_BarItem.titleLabel setFont:[UIFont fontWithName:@"Helvetica-bold" size:16]];
    [btn_BarItem addTarget:self action:@selector(onAddQuestion:) forControlEvents:UIControlEventTouchUpInside];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (void)rightBookMarkPress:(UIButton *)btn
{
    
}

- (void)onAddQuestion:(UIButton *)btn
{
    
}

- (void)onCrop:(UIButton *)btn
{
    
}

- (void)onDone:(UIButton *)btn
{
    
}

- (void)onQuestionType:(UIButton *)btn
{
    
}

- (UIBarButtonItem *)leftMenuBarButtonItemWithWhiteColor:(BOOL)isWhite
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 34, 24);
    [btn_BarItem addTarget:self action:@selector(leftSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    //    btn_BarItem.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -20);
    
    if( isWhite )
    {
        [btn_BarItem setImage:BundleImage(@"list_w.png") forState:UIControlStateNormal];
    }
    else
    {
        [btn_BarItem setImage:BundleImage(@"list_b.png") forState:UIControlStateNormal];
    }
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)leftMenuBar
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 44, 44);
    [btn_BarItem addTarget:self action:@selector(leftSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    btn_BarItem.imageEdgeInsets = UIEdgeInsetsMake(0, -40, 0, 0);
    [btn_BarItem setImage:BundleImage(@"comm_tab_btn_list_b.png") forState:UIControlStateNormal];
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (UIBarButtonItem *)rightInfoMenu
{
    UIButton *btn_BarItem = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem.frame = CGRectMake(0, 0, 44, 44);
    [btn_BarItem addTarget:self action:@selector(rightInfoButtonPressed) forControlEvents:UIControlEventTouchUpInside];
    btn_BarItem.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -40);
    [btn_BarItem setImage:BundleImage(@"comm_tab_btn_mypage_b.png") forState:UIControlStateNormal];
    
    
    return [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem];
}

- (NSArray *)rightMenuAndWriteBarButtonItem
{
    UIButton *btn_BarItem1 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem1.frame = CGRectMake(0, 0, 50, 40);
    [btn_BarItem1 addTarget:self action:@selector(rightSideMenuButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    btn_BarItem1.imageEdgeInsets = UIEdgeInsetsMake(0, 0, 0, -20);
    [btn_BarItem1 setImage:BundleImage(@"global_n.png") forState:UIControlStateNormal];
    
    UIButton *btn_BarItem2 = [UIButton buttonWithType:UIButtonTypeCustom];
    btn_BarItem2.frame = CGRectMake(0, 0, 50, 40);
    [btn_BarItem2 addTarget:self action:@selector(goWritePage:) forControlEvents:UIControlEventTouchUpInside];
    btn_BarItem2.imageEdgeInsets = UIEdgeInsetsMake(0, 30, 0, -20);
    [btn_BarItem2 setImage:BundleImage(@"pen.png") forState:UIControlStateNormal];
    
    UIBarButtonItem *barItem1 = [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem1];
    UIBarButtonItem *barItem2 = [[UIBarButtonItem alloc] initWithCustomView:btn_BarItem2];
    
    NSArray *ar = @[barItem1, barItem2];
    
    return ar;
}

- (MFSideMenuContainerViewController *)menuContainerViewController
{
    return (MFSideMenuContainerViewController *)self.navigationController.parentViewController;
}

- (BOOL)shouldAutorotate
{
    //    if( IS_PHONE )
    //    {
    //        return NO;
    //    }
    
    return YES;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations
{
    id rootController = [[(AppDelegate*)[[UIApplication sharedApplication]delegate] window] rootViewController];
    NSLog(@"%@", rootController);
    
    
    NSString *str_ClassName = NSStringFromClass([self class]);
    
    if( [self isKindOfClass:[UINavigationController class]] )
    {
        UINavigationController *navi = (UINavigationController *)self;
        id firtVc = [navi.viewControllers firstObject];
        if( [firtVc isKindOfClass:[MWPhotoBrowser class]] || [firtVc isKindOfClass:[QuestionViewController class]] )
        {
            return UIInterfaceOrientationMaskAll;
        }
    }
    else if( [self isKindOfClass:[QuestionViewController class]] )
    {
        return UIInterfaceOrientationMaskAll;
    }
    else if( [str_ClassName isEqualToString:@"AVFullScreenViewController"] )
    {
        return UIInterfaceOrientationMaskAll;
    }
//    else if( [str_ClassName isEqualToString:@"UIViewController"] )
//    {
//        return UIInterfaceOrientationMaskAll;
//    }

    return UIInterfaceOrientationMaskAll;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}

- (IBAction)rightSideMenuButtonPressed:(id)sender
{
    [self.menuContainerViewController toggleRightSideMenuCompletion:^{
        
    }];
}

- (void)rightInfoButtonPressed
{
    //    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"PadMain" bundle:[NSBundle mainBundle]];
    //    MyPageViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"MyPageViewController"];
    //    vc.isBackButton = YES;
    
}

- (IBAction)leftSideMenuButtonPressed:(id)sender
{
    [self.sideMenuViewController openMenuAnimated:YES completion:nil];
    
    //    [self.menuContainerViewController toggleLeftSideMenuCompletion:^{
    //
    //    }];
}

- (IBAction)goHome:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UINavigationController *navi = [storyboard instantiateViewControllerWithIdentifier:@"MainNavi"];
    [Util setMainNaviBar:navi.navigationBar];
    
    UIViewController *vc = [navi.viewControllers objectAtIndex:0];
    
    UIWindow *window = [[[UIApplication sharedApplication] delegate] window];
    MFSideMenuContainerViewController *rootViewController = (MFSideMenuContainerViewController *)window.rootViewController;
    UINavigationController *navigationController = rootViewController.centerViewController;
    NSArray *controllers = [NSArray arrayWithObject:vc];
    navigationController.viewControllers = controllers;
    [rootViewController setMenuState:MFSideMenuStateClosed];
}

- (void)leftBackSideMenuButtonPressed:(UIButton *)btn
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)goTab:(id)sender
{
    [self.view endEditing:YES];
}

- (IBAction)goBack:(id)sender
{
    [self leftBackSideMenuButtonPressed:sender];
}

- (IBAction)goModalBack:(id)sender
{
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 
                             }];
}

- (void)goWritePage:(UIButton *)btn
{
    
}

- (void)goWrite:(UIButton *)btn
{
    
}

- (void)goDone:(UIButton *)btn
{
    
}

- (void)initNaviWithTitle:(NSString *)aTitle withLeftItem:(UIBarButtonItem *)leftItem withRightItem:(UIBarButtonItem *)rightItem
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    UILabel *lb_Title = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, self.navigationController.navigationBar.frame.size.height)];
    lb_Title.tag = kNaviTitleTag;
    lb_Title.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    lb_Title.textColor = [UIColor whiteColor];
    lb_Title.text = aTitle;
    [Util getTextWith:lb_Title];
    lb_Title.textAlignment = NSTextAlignmentCenter;
    
    CGRect frame = lb_Title.frame;
    frame.size.width = [Util getTextWith:lb_Title];
    lb_Title.frame = frame;
    
    self.navigationItem.titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    self.navigationController.navigationBar.opaque = YES;
    [self.navigationItem.titleView addSubview:lb_Title];
    
    [self.navigationController.navigationBar setBarTintColor:kMainColor];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    if( leftItem )
    {
        self.navigationItem.leftBarButtonItem = leftItem;
    }
    
    if( rightItem )
    {
        self.navigationItem.rightBarButtonItem = rightItem;
    }
}

- (void)initSearchNavi:(UISearchBar *)searchBar withColor:(UIColor *)color
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    
    self.navigationItem.titleView = searchBar;
//    [self.navigationItem.titleView addSubview:searchBar];
    
    [self.navigationController.navigationBar setBarTintColor:color];
    [self.navigationController.navigationBar setTranslucent:NO];    
}

- (void)initNaviWithTitle:(NSString *)aTitle withLeftItem:(UIBarButtonItem *)leftItem withRightItem:(UIBarButtonItem *)rightItem withColor:(UIColor *)color
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];

    UILabel *lb_Title = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, self.navigationController.navigationBar.frame.size.height)];
    lb_Title.tag = kNaviTitleTag;
    lb_Title.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    lb_Title.textColor = [UIColor blackColor];
    lb_Title.text = aTitle;
    lb_Title.textAlignment = NSTextAlignmentCenter;
    lb_Title.lineBreakMode = NSLineBreakByTruncatingTail;
    
    CGFloat fWidth = [Util getTextWith:lb_Title];
    if( fWidth > 200 )
    {
        fWidth = 200;
    }
    CGRect frame = lb_Title.frame;
    frame.size.width = fWidth;
    lb_Title.frame = frame;
    
    self.navigationItem.titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    self.navigationController.navigationBar.opaque = YES;
    [self.navigationItem.titleView addSubview:lb_Title];
    
    [self.navigationController.navigationBar setBarTintColor:color];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    if( leftItem )
    {
        self.navigationItem.leftBarButtonItem = leftItem;
    }
    
    if( rightItem )
    {
        self.navigationItem.rightBarButtonItem = rightItem;
    }
}

- (void)initNaviWithTitle:(NSString *)aTitle withLeftItem:(UIBarButtonItem *)leftItem withRightItem:(UIBarButtonItem *)rightItem withHexColor:(NSString *)aHexColor
{
    UILabel *lb_Title = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, 200, self.navigationController.navigationBar.frame.size.height)];
    lb_Title.tag = kNaviTitleTag;
    lb_Title.font = [UIFont fontWithName:@"Helvetica-Bold" size:18];
    lb_Title.textColor = [UIColor blackColor];
    lb_Title.text = aTitle;
    [Util getTextWith:lb_Title];
    lb_Title.textAlignment = NSTextAlignmentCenter;
    
    CGRect frame = lb_Title.frame;
    frame.size.width = [Util getTextWith:lb_Title];
    lb_Title.frame = frame;
    
    self.navigationItem.titleView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, frame.size.width, self.navigationController.navigationBar.frame.size.height)];
    self.navigationController.navigationBar.opaque = YES;
    [self.navigationItem.titleView addSubview:lb_Title];
    
    [self.navigationController.navigationBar setBarTintColor:[UIColor colorWithHexString:aHexColor]];
    [self.navigationController.navigationBar setTranslucent:NO];
    
    if( leftItem )
    {
        self.navigationItem.leftBarButtonItem = leftItem;
    }
    
    if( rightItem )
    {
        self.navigationItem.rightBarButtonItem = rightItem;
    }
}

@end
