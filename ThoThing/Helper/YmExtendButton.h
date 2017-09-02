//
//  YmExtendButton.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 7. 5..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YmExtendButton : UIButton
@property (nonatomic, strong) id obj;
@property (nonatomic, assign) NSInteger nSubTag;
@property (nonatomic, strong) NSString *str_SubTitle;
@property (nonatomic, strong) NSString *str_Discription;
@property (nonatomic, strong) NSDictionary *dic_Info;
@property (nonatomic, strong) NSArray *ar_List;
@end
