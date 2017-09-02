//
//  ChatFeedMemeberInviteViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 12. 23..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompletionBlock)(id completeResult);

@interface ChatFeedMemeberInviteViewController : UIViewController
@property (nonatomic, assign) BOOL isAddMode;   //추가하기
@property (nonatomic, assign) BOOL isViewMode;   //참여자보기
@property (nonatomic, strong) NSDictionary *dic_Info;
@property (strong, nonatomic) SBDGroupChannel *channel;
@property (nonatomic, strong) NSString *str_UserImagePrefix;
@property (nonatomic, strong) NSString *str_ChannelId;
@property (nonatomic, copy) CompletionBlock completionBlock;
- (void)setCompletionBlock:(CompletionBlock)completionBlock;
@end
