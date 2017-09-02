//
//  ActionSheetBottomViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 1. 20..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompletionBlock)(id completeResult);
typedef void (^CompletionStarBlock)(id completeStarResult);

@interface ActionSheetBottomViewController : UIViewController
@property (nonatomic, strong) NSMutableArray *arM_List;
@property (nonatomic, copy) CompletionBlock completionBlock;
@property (nonatomic, copy) CompletionStarBlock completionStarBlock;
- (void)setCompletionBlock:(CompletionBlock)completionBlock;
- (void)setCompletionStarBlock:(CompletionBlock)completionStarBlock;
@end
