//
//  AddDiscripViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 8. 4..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^DismissBlock)(id completeResult);

@interface AddDiscripViewController : UIViewController
@property (nonatomic, assign) BOOL isQuestionMode;
@property (nonatomic, assign) BOOL isLastObj;   //댓글 달러 들어왔을때 마지막 객체인지 여부 (마지막 객체이면 글 등록후 최하단으로 스크롤을 내려줘야 함)
@property (nonatomic, assign) BOOL isFeedMode;
@property (nonatomic, strong) NSString *str_Idx;
@property (nonatomic, strong) NSString *str_QnAId;
@property (nonatomic, strong) NSString *str_GroupId;
@property (nonatomic, copy) DismissBlock dismissBlock;
- (void)setDismissBlock:(DismissBlock)completionBlock;

@end
