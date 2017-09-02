//
//  QuestionMainCellView.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 6. 24..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface QuestionMainCellView : UIView
@property (nonatomic, assign) NSInteger nSection;
@property (nonatomic, strong) NSDictionary *dic_Info;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Cover;
@property (nonatomic, weak) IBOutlet UILabel *lb_Subject;       //국어
@property (nonatomic, weak) IBOutlet UILabel *lb_Grade;         //학년
@property (nonatomic, weak) IBOutlet UILabel *lb_Ower;          //출처
@property (nonatomic, weak) IBOutlet UILabel *lb_Price;         //가격
@property (nonatomic, weak) IBOutlet UIButton *btn_Info;        //정보버튼
@property (nonatomic, weak) IBOutlet UILabel *lb_Title;         //문제집 제목
@end
