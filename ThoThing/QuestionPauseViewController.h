//
//  QuestionPauseViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 5. 17..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompletionBlock)(id completeResult);

@interface QuestionPauseViewController : UIViewController

@property (nonatomic, assign) NSInteger nTime;
@property (nonatomic, strong) NSString *str_CurrentQ;
@property (nonatomic, strong) NSString *str_TotalQ;
@property (nonatomic, copy) CompletionBlock completionBlock;

- (void)setCompletionBlock:(CompletionBlock)completionBlock;

@end
