//
//  UserListViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 1. 25..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    kFollowing  = -1,
    kMember     = 0,
    kAdmin      = 1,
} UserStatusCode;

@interface UserListViewController : UIViewController
@property (nonatomic, assign) UserStatusCode userStatusCode;
@property (nonatomic, strong) NSString *str_UserId;
@end
