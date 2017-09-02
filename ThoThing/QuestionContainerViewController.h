//
//  QuestionContainerViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 6. 28..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "QuestionListTitleView.h"
#import "QuestionListSwipeViewController.h"

@interface QuestionContainerViewController : YmBaseViewController
@property (nonatomic, assign) NSInteger nTime;
@property (nonatomic, strong) NSString *str_Idx;
@property (nonatomic, strong) NSString *str_StartIdx;
@property (nonatomic, strong) NSString *str_ChannelId;
@property (nonatomic, strong) NSString *str_SortType;
@property (nonatomic, strong) NSString *str_LowPer;
@property (nonatomic, strong) NSString *str_SubjectName;
@property (nonatomic, assign) BOOL isNew;
@property (nonatomic, assign) BOOL isPdf;
@property (nonatomic, strong) QuestionListTitleView *v_Title;
@property (nonatomic, assign) NSInteger nStartPdfPage;

@property (nonatomic, assign) BOOL isWrong;
@property (nonatomic, assign) BOOL isStar;
@property (nonatomic, strong) NSString *str_SubjectTotalCount;

//PDF에 진입하자마자 문제 점프시 사용
@property (nonatomic, strong) NSString *str_PdfPage;
@property (nonatomic, strong) NSString *str_PdfNo;

- (void)addConstraintsForViewController:(UIViewController *)viewController;

- (void)showQuesionVc:(QuestionListSwipeViewController *)vc_Tmp;

@end
