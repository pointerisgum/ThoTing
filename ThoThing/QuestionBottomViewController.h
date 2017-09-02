//
//  QuestionBottomViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 5. 18..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^BottomViewScrollBlock)(id completeResult);
typedef void (^AddDiscriptionBlock)(id completeResult);
typedef void (^UpdateCountBlock)(id completeResult);

@interface QuestionBottomViewController : UIViewController
@property (nonatomic, assign) BOOL isNavi;
@property (nonatomic, strong) NSString *str_QId;
@property (nonatomic, assign) NSInteger nTotalCount;
//@property (nonatomic, strong) NSString *str_QnAId;
@property (nonatomic, strong) NSString *str_ExamId;
@property (nonatomic, strong) NSString *str_ChannelId;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_BottomViewBottom;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_BgTop;
@property (nonatomic, weak) IBOutlet UIButton *btn_Back;
@property (nonatomic, weak) IBOutlet UIButton *btn_AddDiscrip;
@property (nonatomic, copy) BottomViewScrollBlock completionBlock;
@property (nonatomic, copy) AddDiscriptionBlock addCompletionBlock;
@property (nonatomic, copy) UpdateCountBlock updateCountBlock;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_CommentX;
- (void)initConstant;
//- (void)initFrame:(UIViewController *)vc;
- (void)deallocBottomView;
- (void)setCompletionBlock:(BottomViewScrollBlock)completionBlock;
- (void)setAddCompletionBlock:(AddDiscriptionBlock)completionBlock;
- (void)setUpdateCountBlock:(UpdateCountBlock)completionBlock;
- (void)updateDList;
- (void)updateQList;
//- (void)initLayout;

@end
