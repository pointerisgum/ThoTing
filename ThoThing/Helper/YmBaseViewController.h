//
//  YmBaseViewController.h
//  PB
//
//  Created by KimYoung-Min on 2014. 12. 7..
//  Copyright (c) 2014년 KimYoung-Min. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YmBaseViewController : UIViewController
@property (nonatomic, weak) IBOutlet UIScrollView *sv_Main;
@property (nonatomic, weak) IBOutlet UIView *v_LastObj;
- (void)addTabGesture;
- (CGFloat)getLastObjectHeight:(UIView *)view;
- (void)statusBarTappedAction:(NSNotification*)notification;
@end
