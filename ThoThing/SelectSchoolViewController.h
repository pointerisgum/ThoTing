//
//  SelectSchoolViewController.h
//  ThoTing
//
//  Created by KimYoung-Min on 2016. 6. 15..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SchoolCompletionBlock)(id completeResult);

@interface SelectSchoolViewController : UIViewController
@property (nonatomic, copy) SchoolCompletionBlock completionBlock;
@end
