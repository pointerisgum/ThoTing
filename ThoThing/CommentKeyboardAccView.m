//
//  CommentKeyboardAccView.m
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 8. 4..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "CommentKeyboardAccView.h"

@implementation CommentKeyboardAccView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.tv_Contents.contentInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
//    self.v_InputLayer.layer.cornerRadius = 6.f;
//    self.v_InputLayer.layer.borderColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1].CGColor;
//    self.v_InputLayer.layer.borderWidth = 1.f;
    
    self.btn_Done.layer.cornerRadius = 6.f;
    self.btn_Done.clipsToBounds = YES;
//    self.btn_Done.layer.borderColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1].CGColor;
//    self.btn_Done.layer.borderWidth = 1.f;

//    self.btn_Done.layer.cornerRadius = 6.f;
//    self.btn_Done.layer.borderColor = [UIColor colorWithRed:220.f/255.f green:220.f/255.f blue:220.f/255.f alpha:1].CGColor;
//    self.btn_Done.layer.borderWidth = 1.f;

//    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.btn_Done.bounds byRoundingCorners:UIRectCornerTopRight|UIRectCornerBottomRight cornerRadii:CGSizeMake(6.0f, 6.0f)];
//    CAShapeLayer *maskLayer = [CAShapeLayer layer];
//    maskLayer.frame = self.btn_Done.bounds;
//    maskLayer.path = maskPath.CGPath;
//    self.btn_Done.layer.mask = maskLayer;

}

- (void)layoutSubviews
{
//    [self.lb_PlaceHolder layoutSubviews];
//    [self.lb_PlaceHolder setNeedsLayout];
//    [self.lb_PlaceHolder setNeedsUpdateConstraints];
}

#pragma mark - UITextViewDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    [self performSelector:@selector(onChangeInterval) withObject:nil afterDelay:0.01f];
    NSUInteger length = [[textView text] length] - range.length + text.length;
    if( length <= 0 )
    {
        self.lb_PlaceHolder.hidden = NO;
    }
    else
    {
        self.lb_PlaceHolder.hidden = YES;
    }

    return YES;
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView
{
    if( self.lc_Bottom.constant > 0 )
    {
        //키보드가 올라와 있는 상태면
        if( self.keyboardStatus == kTemplete )
        {
            self.keyboardStatus = kNormal;
            self.btn_TempleteKeyboard.hidden = NO;
            return YES;
        }
    }
    else
    {
        if( self.keyboardStatus == kTemplete )
        {
            if( self.completionBlock )
            {
                self.completionBlock(nil);
            }
            
            if( self.fKeyboardHeight > 0 )
            {
                self.lc_Bottom.constant = self.fKeyboardHeight;
            }
            else
            {
                self.lc_Bottom.constant = 258.f;
            }
            
            [UIView animateWithDuration:0.25f animations:^{
                [self.superview layoutIfNeeded];
            }];
            
            return NO;
        }
    }
    
    self.btn_TempleteKeyboard.hidden = NO;
    
    return YES;
}


- (void)onChangeInterval
{
    CGFloat fHeight = [Util getTextViewHeight:self.tv_Contents];
    if( fHeight <= 45.f )
    {
        self.lc_TfWidth.constant = 45.f;
    }
    else if( fHeight > 100 )
    {
        self.lc_TfWidth.constant = 100.f;
    }
    else
    {
        self.lc_TfWidth.constant = fHeight;
    }

    //20170727 항상 등록 버튼이 보이게 해달라는 요청으로 수정함 @피터 => 이거 아니라고 함..
    if( self.tv_Contents.text.length > 0 )
    {
        self.lc_AddWidth.constant = 54.f;
    }
    else
    {
        self.lc_AddWidth.constant = 0.f;
        
//        [self.tv_Contents setNeedsLayout];
//        [self.tv_Contents layoutIfNeeded];
//        [self setNeedsLayout];
//        [self layoutIfNeeded];
//
//        [self layoutSubviews];
//        [self.tv_Contents layoutSubviews];
        
//        [self setNeedsDisplay];
        [self.tv_Contents setNeedsDisplay];

    }
    
//    [self.tv_Contents setNeedsLayout];
//    [self.tv_Contents setNeedsUpdateConstraints];
    [self.tv_Contents updateConstraints];
    

    [self updateConstraints];
    
    if( self.completionTextChangeBlock )
    {
        self.completionTextChangeBlock(self.tv_Contents.text);
    }
}

- (void)removeContents
{
    self.tv_Contents.text = @"";
    [self onChangeInterval];
    
//    self.tv_Contents.placeholder = @"";
    
//    self.lb_PlaceHolder.hidden = NO;
}

@end
