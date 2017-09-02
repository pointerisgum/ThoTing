//
//  TextFeildCheckView.h
//  ASKing
//
//  Created by Kim Young-Min on 2013. 11. 13..
//  Copyright (c) 2013년 Kim Young-Min. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, CheckType) {
    EmailMode,
    PwMode,
    SpecialCharacter,   //특수문자 검사용
};

@protocol TextFeildCheckViewDelegate;

@interface TextFeildCheckView : UIView <UITextFieldDelegate>
@property (nonatomic, weak) id<TextFeildCheckViewDelegate, UITextFieldDelegate>delegate;
@property (nonatomic, assign) CheckType mode;
@property (nonatomic, assign) NSInteger nMinCount;
@property (nonatomic, assign) NSInteger nMaxCount;
@property (nonatomic, assign) BOOL isEnable;
@property (nonatomic, strong) IBOutlet UITextField *tf;
@property (nonatomic, strong) IBOutlet UIImageView *iv_Check;
@end


@protocol TextFeildCheckViewDelegate <NSObject>
@optional
- (void)onCheckTextFieldString:(UITextField *)textField;
@end
