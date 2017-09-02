//
//  UIViewController+YM.h
//  EmAritaum
//
//  Created by Kim Young-Min on 2014. 3. 19..
//  Copyright (c) 2014년 Kim Young-Min. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (YM)
- (UIBarButtonItem *)homeMenuButtonItem;
- (UIBarButtonItem *)leftBackMenuBarButtonItem;
- (UIBarButtonItem *)rightMenuBarButtonItem;
- (UIBarButtonItem *)blackNaviBackButton;
- (UIBarButtonItem *)whiteNaviBackButton;
- (UIBarButtonItem *)EmptyleftBackMenuBarButtonItem;
- (UIBarButtonItem *)modalCloseBarButtonItem;
- (UIBarButtonItem *)modalCloseBarButtonItemBlack;
- (UIBarButtonItem *)writeNaviButton;
- (UIBarButtonItem *)blackWriteNaviButton;
- (NSArray *)rightMenuAndWriteBarButtonItem;
- (void)leftBackSideMenuButtonPressed:(UIButton *)btn;
- (IBAction)goHome:(id)sender;
- (IBAction)goBack:(id)sender;
- (IBAction)goModalBack:(id)sender;
- (void)goWritePage:(UIButton *)btn;

- (UIBarButtonItem *)leftMenuBarButtonItemWithWhiteColor:(BOOL)isWhite;

- (UIBarButtonItem *)modalCancelButton;
- (UIBarButtonItem *)modalConfirmButton;


- (UIBarButtonItem *)leftMenuBar;
- (UIBarButtonItem *)rightInfoMenu;


- (void)initNaviWithTitle:(NSString *)aTitle withLeftItem:(UIBarButtonItem *)leftItem withRightItem:(UIBarButtonItem *)rightItem;
- (void)initNaviWithTitle:(NSString *)aTitle withLeftItem:(UIBarButtonItem *)leftItem withRightItem:(UIBarButtonItem *)rightItem withColor:(UIColor *)color;

- (UIBarButtonItem *)rightCropButton;
- (UIBarButtonItem *)rightDoneButton;
- (UIBarButtonItem *)addQuestion;


- (UIBarButtonItem *)rightBookMarkItem;

- (void)initNaviWithTitle:(NSString *)aTitle withLeftItem:(UIBarButtonItem *)leftItem withRightItem:(UIBarButtonItem *)rightItem withHexColor:(NSString *)aHexColor;
- (UIBarButtonItem *)leftBackBlackMenuBarButtonItem;

- (UIBarButtonItem *)rightLogOutButtonItem;

- (UIBarButtonItem *)rightReportButtonItem;

- (UIBarButtonItem *)rightQnaRoomInfo;

- (UIBarButtonItem *)rightInvitation;   //초대하기 버튼

- (UIBarButtonItem *)rightQnaRoomInfoAndIcon:(UIButton *)userBtn;

- (void)initSearchNavi:(UISearchBar *)searchBar withColor:(UIColor *)color;

- (UIBarButtonItem *)rightIngQuestion;

- (UIBarButtonItem *)addChannelButtionItem;

@end
