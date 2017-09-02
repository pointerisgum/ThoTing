//
//  ReportPopUpViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 28..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompletionBlock)(id completeResult);

@interface ReportPopUpViewController : UIViewController
@property (nonatomic, assign) NSInteger nSelectedIdx;
@property (nonatomic, strong) NSMutableArray *ar_List;
@property (nonatomic, copy) CompletionBlock completionBlock;
- (void)setCompletionBlock:(CompletionBlock)completionBlock;
@end
