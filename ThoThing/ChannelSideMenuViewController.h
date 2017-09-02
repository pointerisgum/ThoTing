//
//  ChannelSideMenuViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 4. 14..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompletionBlock)(id completeResult);

@interface ChannelSideMenuViewController : UIViewController
@property (nonatomic, copy) CompletionBlock completionBlock;
- (void)setCompletionBlock:(CompletionBlock)completionBlock;
@end
