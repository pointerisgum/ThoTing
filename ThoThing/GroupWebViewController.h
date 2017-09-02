//
//  GroupWebViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 11..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompletionWebBlock)(id completeResult);

@interface GroupWebViewController : UIViewController
@property (nonatomic, assign) BOOL isGrupMode;  //레포트에서 그리드 눌러서 들어왔을때
@property (nonatomic, strong) NSString *str_Idx;
@property (nonatomic, strong) NSString *str_GroupName;
@property (nonatomic, copy) CompletionWebBlock completionWebBlock;
- (void)setCompletionWebBlock:(CompletionWebBlock)completionBlock;
@end
