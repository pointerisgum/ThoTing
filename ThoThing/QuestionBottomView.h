//
//  QuestionBottomView.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 11. 10..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionBottomView : UIView

typedef void (^BottomViewScrollBlock)(id completeResult);
typedef void (^AddDiscriptionBlock)(id completeResult);
typedef void (^UpdateCountBlock)(id completeResult);
typedef void (^ShowQnaViewBlock)(id completeResult);

@property (nonatomic, assign) BOOL isNavi;
@property (nonatomic, strong) NSString *str_QId;
@property (nonatomic, strong) NSString *str_QnAId;
@property (nonatomic, strong) NSString *str_ExamId;
@property (nonatomic, strong) NSString *str_ChannelId;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_BottomViewBottom;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_BgTop;
@property (nonatomic, weak) IBOutlet UIButton *btn_Back;
@property (nonatomic, weak) IBOutlet UIButton *btn_AddDiscrip;
@property (nonatomic, copy) BottomViewScrollBlock completionBlock;
@property (nonatomic, copy) AddDiscriptionBlock addCompletionBlock;
@property (nonatomic, copy) UpdateCountBlock updateCountBlock;
@property (nonatomic, copy) ShowQnaViewBlock showQnaViewBlock;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_CommentX;
- (void)initConstant;
- (void)initFrame:(UIViewController *)vc;
- (void)deallocBottomView;
- (void)setCompletionBlock:(BottomViewScrollBlock)completionBlock;
- (void)setAddCompletionBlock:(AddDiscriptionBlock)completionBlock;
- (void)setUpdateCountBlock:(UpdateCountBlock)completionBlock;
- (void)setShowQnaViewBlock:(ShowQnaViewBlock)completionBlock;
- (void)updateDList;
- (void)updateQList;
//- (void)initLayout;
@end
