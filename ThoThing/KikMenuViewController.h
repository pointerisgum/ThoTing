//
//  KikMenuViewController.h
//  ThoThing
//
//  Created by macpro15 on 2017. 9. 25..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KikOneOnOneViewController.h"

typedef enum {
    kOneOnOneChat   = 1,
    kMakeGroupChat  = 2,
    kGroups         = 3,
    kExamBot        = 4,
}SelectType;

typedef void (^CompletionBlock)(id completeResult);
typedef void (^CompletionMenuSelectBlock)(SelectType completeResult);

@interface KikMenuViewController : UIViewController
@property (nonatomic, assign) SelectType selectType;
@property (nonatomic, copy) CompletionBlock completionBlock;
@property (nonatomic, copy) CompletionMenuSelectBlock completionMenuSelectBlock;
- (void)setCompletionBlock:(CompletionBlock)completionBlock;
- (void)setCompletionMenuSelectBlock:(CompletionMenuSelectBlock)completionBlock;
@end
