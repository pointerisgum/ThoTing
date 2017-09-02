//
//  SharedViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 11. 22..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CloseCompletBlock)(id completeResult);

@interface SharedViewController : UIViewController
@property (nonatomic, assign) BOOL isModalMode;
@property (nonatomic, strong) NSString *str_ExamId;
@property (nonatomic, strong) NSString *str_QuestionId;
@property (nonatomic, strong) NSString *str_ChannelId;
@property (nonatomic, copy) CloseCompletBlock completionBlock;
- (void)setCompletionBlock:(CloseCompletBlock)completionBlock;
@end
