//
//  KikMyViewController.h
//  ThoThing
//
//  Created by macpro15 on 2017. 9. 23..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KikMyViewController : UIViewController
//@property (nonatomic, strong) NSString *str_UserIdx;
@property (nonatomic, strong) SBDUser *user;
@property (nonatomic, strong) SBDGroupChannel *channel;
@property (nonatomic, assign) BOOL isOneOneChatIng;
@end
