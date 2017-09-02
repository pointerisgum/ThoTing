//
//  Answer6Cell.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 1..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoundButton.h"

@interface Answer6Cell : UITableViewCell
@property (nonatomic, weak) IBOutlet UIView *v_ButtonContainer;
@property (nonatomic, weak) IBOutlet RoundButton *btn1;
@property (nonatomic, weak) IBOutlet RoundButton *btn2;
@property (nonatomic, weak) IBOutlet RoundButton *btn3;
@property (nonatomic, weak) IBOutlet RoundButton *btn4;
@property (nonatomic, weak) IBOutlet RoundButton *btn5;
@property (nonatomic, weak) IBOutlet RoundButton *btn6;
@end
