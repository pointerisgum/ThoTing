//
//  MyHeaderView.h
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 1. 24..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MyHeaderViewDelegate;


@interface MyHeaderView : UIView
@property (nonatomic, weak) id<MyHeaderViewDelegate> delegate;
@property (nonatomic, assign) BOOL isFirst;
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, strong) NSMutableArray *arM_SubjectiList;
@property (nonatomic, strong) NSDictionary *dic_Data;
@property (nonatomic, weak) IBOutlet UIImageView *iv_User;
@property (nonatomic, weak) IBOutlet UILabel *lb_Name;
@property (nonatomic, weak) IBOutlet UIButton *btn_Following;
@property (nonatomic, weak) IBOutlet UIButton *btn_Member;
@property (nonatomic, weak) IBOutlet UITableView *tbv_School;
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Subject;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *lc_QuestionHeight;
@property (nonatomic, weak) IBOutlet UIButton *btn_Q1;
@property (nonatomic, weak) IBOutlet UIButton *btn_Q2;
- (void)updateSubjectList;
- (void)updateSelectSubject:(NSString *)aSubject;
@end

@protocol MyHeaderViewDelegate <NSObject>
@optional
- (void)updateTableView:(NSString *)aSubject;
- (void)tableViewTouch:(NSDictionary *)dic;
- (void)goShowFollowingList:(id)sender;
- (void)goShowMemberList:(id)sender;
@end
