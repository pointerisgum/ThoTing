//
//  InvitationViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 9. 13..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CloseCompletBlock)(id completeResult);

@interface InvitationViewController : UIViewController
@property (nonatomic, strong) NSString *str_ChannelId;
@property (nonatomic, strong) NSString *str_QuestionId;
@property (nonatomic, strong) NSString *str_RId;    //채팅방 아이디

//공유하기
@property (nonatomic, assign) BOOL isShare;
@property (nonatomic, strong) NSString *str_ExamId;

@property (nonatomic, copy) CloseCompletBlock completionBlock;
- (void)setCompletionBlock:(CloseCompletBlock)completionBlock;

@end
