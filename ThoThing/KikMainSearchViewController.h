//
//  KikMainSearchViewController.h
//  ThoThing
//
//  Created by macpro15 on 2017. 10. 13..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompletionBlock)(id completeResult);

@interface KikMainSearchViewController : UIViewController
@property (nonatomic, copy) CompletionBlock completionBlock;
@property (nonatomic, strong) NSString *str_ImagePrefix;
@property (nonatomic, strong) NSMutableArray *arM_Original;
- (void)setCompletionBlock:(CompletionBlock)completionBlock;
@end
