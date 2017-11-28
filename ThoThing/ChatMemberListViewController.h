//
//  ChatMemberListViewController.h
//  ThoThing
//
//  Created by macpro15 on 2017. 9. 27..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChatMemberListViewController : UIViewController
@property (strong, nonatomic) SBDGroupChannel *channel;
@property (strong, nonatomic) NSDictionary *dic_Info;
@end
