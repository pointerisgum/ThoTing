//
//  SideMenuViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 8. 31..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kAll,
    kPass,
    kNonPass,
    kStar,
} ListType;

typedef void (^SelectedCompletionBlock)(id completeResult);

@interface SideMenuViewController : UIViewController
@property (nonatomic, strong) NSString *str_StartNo;
@property (nonatomic, strong) NSString *str_Idx;
@property (nonatomic, strong) NSString *str_TesterId;
@property (nonatomic, strong) NSString *str_ChannelId;
@property (nonatomic, strong) NSString *str_ExamNo;     //오답문제 다시 풀기시 현재 문제 번호 언더라인 때문에 넘김
@property (nonatomic, strong) NSString *str_SortType;   //오답문제 다시 풀기시 현재 문제 번호 언더라인 때문에 넘김

@property (nonatomic, copy) SelectedCompletionBlock completionBlock;
- (void)setCompletionBlock:(SelectedCompletionBlock)completionBlock;
- (void)closeMenu;
@end
