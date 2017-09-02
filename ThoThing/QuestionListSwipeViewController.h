//
//  QuestionListSwipeViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 6. 28..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@class QuestionContainerViewController;
@interface QuestionListSwipeViewController : UIViewController
- (void)onShowNormalQuestion:(NSNotification *)noti;
@property (nonatomic, strong) NSString *str_Idx;
@property (nonatomic, strong) NSString *str_StartIdx;
@property (nonatomic, strong) NSString *str_ChannelId;
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, weak) QuestionContainerViewController *vc_Parent;

@property (nonatomic, strong) NSString *str_SortType;

@property (nonatomic, assign) BOOL Prev;    //콜 모드가 이전 화면인지 여부. NO면 next

@property (nonatomic, assign) BOOL isNew;  //새로 풀기인지 여부
@property (nonatomic, assign) BOOL isPdf;

@property (nonatomic, strong) NSString *str_LowPer;
@property (nonatomic, assign) NSInteger nStartPdfPage;

//오답, 별표 문제 풀기 때문에 추가된 변수
@property (nonatomic, strong) NSString *str_SubjectName;
@property (nonatomic, assign) BOOL isWrong;
@property (nonatomic, assign) BOOL isStar;
@property (nonatomic, strong) UIButton *btn_Check;
@property (nonatomic, strong) NSString *str_SubjectTotalCount;

//PDF에 진입하자마자 문제 점프시 사용
@property (nonatomic, strong) NSString *str_PdfPage;
@property (nonatomic, strong) NSString *str_PdfNo;

@end
