//
//  ChannelMainViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 9..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ChannelMainViewController : UIViewController
@property (nonatomic, assign) BOOL isShowNavi;
@property (nonatomic, assign) BOOL isChannelMode;
@property (nonatomic, strong) NSString *str_ChannelId;
@property (nonatomic, weak) IBOutlet UITableView *tbv_List;
- (void)updateView;
@end
