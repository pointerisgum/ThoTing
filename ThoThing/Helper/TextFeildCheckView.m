//
//  TextFeildCheckView.m
//  ASKing
//
//  Created by Kim Young-Min on 2013. 11. 13..
//  Copyright (c) 2013년 Kim Young-Min. All rights reserved.
//

#import "TextFeildCheckView.h"

@implementation TextFeildCheckView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}


#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    [self performSelector:@selector(onCheckTextFieldString:) withObject:textField afterDelay:0.1f];
    
    //패스워드 모드일시 secure 활성화
    if( self.mode == PwMode )
    {
        if( !textField.secureTextEntry )    textField.secureTextEntry = YES;
    }
    
    //글자제한이 있는 경우 백스페이스바 예외처리
    if( self.nMaxCount > 0 )
    {
        const char * _char = [string cStringUsingEncoding:NSUTF8StringEncoding];
        int isBackSpace = strcmp(_char, "\b");
        if (isBackSpace != -8)
        {
            //이건 바이트인데 기획에선 자릿수로 체크하길 원했음
//            NSUInteger bytes = [textField.text lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
            NSUInteger bytes = [textField.text length];
            if( bytes > self.nMaxCount - 1 )
            {
                return NO;
            }
        }
    }
    
    return YES;
}

- (void)onCheckTextFieldString:(UITextField *)textField
{
    NSUInteger bytes = [textField.text length];
    if( bytes <= 0 )
    {
        self.isEnable = NO;
        [self.iv_Check setImage:BundleImage(@"")];
    }
    else
    {
        if( self.mode == EmailMode )
        {
            //제한이 있으면 카운트도 검사
            if( self.nMinCount > 0 && self.nMaxCount > 0 )
            {
                if( [Util isUsableEmail:textField.text] && bytes >= self.nMinCount && bytes <= self.nMaxCount )
                {
                    self.isEnable = YES;
                    [self.iv_Check setImage:BundleImage(@"입력선택.png")];
                }
                else
                {
                    self.isEnable = NO;
                    [self.iv_Check setImage:BundleImage(@"입력선택오류.png")];
                }
            }
            //제한이 없으면 이메일 형식만 검사
            else
            {
                if( [Util isUsableEmail:textField.text] )
                {
                    self.isEnable = YES;
                    [self.iv_Check setImage:BundleImage(@"입력선택.png")];
                }
                else
                {
                    self.isEnable = NO;
                    [self.iv_Check setImage:BundleImage(@"입력선택오류.png")];
                }
            }
        }
        else if( self.mode == PwMode )
        {
            if( bytes >= self.nMinCount && bytes <= self.nMaxCount )
            {
                self.isEnable = YES;
                [self.iv_Check setImage:BundleImage(@"입력선택.png")];
            }
            else
            {
                self.isEnable = NO;
                [self.iv_Check setImage:BundleImage(@"입력선택오류.png")];
            }
        }
        else if( self.mode == SpecialCharacter )
        {
            //특수문자와 자릿수 검사
            if( self.nMinCount > 0 && self.nMaxCount > 0 )
            {
                if( ![Util isSpecialCharacter:textField.text] && bytes >= self.nMinCount && bytes <= self.nMaxCount )
                {
                    self.isEnable = YES;
                    [self.iv_Check setImage:BundleImage(@"입력선택.png")];
                }
                else
                {
                    self.isEnable = NO;
                    [self.iv_Check setImage:BundleImage(@"입력선택오류.png")];
                }
            }
            else
            {
                //특수문자만 검사
                if( ![Util isSpecialCharacter:textField.text] )
                {
                    self.isEnable = YES;
                    [self.iv_Check setImage:BundleImage(@"입력선택.png")];
                }
                else
                {
                    self.isEnable = NO;
                    [self.iv_Check setImage:BundleImage(@"입력선택오류.png")];
                }
            }
        }
    }
    if( [self.delegate respondsToSelector:@selector(onCheckTextFieldString:)] )
    {
        [self.delegate onCheckTextFieldString:textField];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return [self.delegate textFieldShouldReturn:textField];
}

@end
