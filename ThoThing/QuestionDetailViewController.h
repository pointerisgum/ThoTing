//
//  QuestionDetailViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 6. 22..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompletionPriceBlock)(id completeResult);

@interface QuestionDetailViewController : YmBaseViewController
@property (nonatomic, strong) NSString *str_Idx;
@property (nonatomic, strong) NSString *str_Title;
@property (nonatomic, copy) CompletionPriceBlock completionPriceBlock;
- (void)setCompletionPriceBlock:(CompletionPriceBlock)completionBlock;
@end
