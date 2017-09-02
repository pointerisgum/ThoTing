//
//  StarView.m
//  OrangeMT
//
//  Created by KimYoung-Min on 2016. 6. 15..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import "StarView.h"

@implementation StarView

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
    
    self.nScore = 3;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event touchesForView:self]anyObject];
    CGPoint point = [touch locationInView:self];
  
    [self updateImage:point.x];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event touchesForView:self]anyObject];
    CGPoint point = [touch locationInView:self];
    
    [self updateImage:point.x];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [[event touchesForView:self]anyObject];
    CGPoint point = [touch locationInView:self];

    [self updateImage:point.x];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(didUpdateStarView:)])
    {
        [self.delegate didUpdateStarView:self.nScore];
    }
}

- (void)updateImage:(CGFloat)x
{
    CGFloat fPer = (x / self.bounds.size.width) * 177.f;
//    NSLog(@"%f", fPer);
    if( fPer < 0 || fPer > 177.f )
    {
        return;
    }
    
//    self.nScore = (NSInteger)fPer / 5;
    self.nScore = (((fPer / 177.f) / 2) + 0.1) * 10;
//    NSLog(@"self.nScore : %ld", self.nScore);
    [self setStarScore:self.nScore];
}

- (void)setStarScore:(NSInteger)nScore
{
    if( nScore == 0 )
    {
        self.iv_Star1.image = BundleImage(@"star_empty.png");
        self.iv_Star2.image = BundleImage(@"star_empty.png");
        self.iv_Star3.image = BundleImage(@"star_empty.png");
        self.iv_Star4.image = BundleImage(@"star_empty.png");
        self.iv_Star5.image = BundleImage(@"star_empty.png");
    }
    else if( nScore == 1 )
    {
        self.iv_Star1.image = BundleImage(@"star_fill.png");
        self.iv_Star2.image = BundleImage(@"star_empty.png");
        self.iv_Star3.image = BundleImage(@"star_empty.png");
        self.iv_Star4.image = BundleImage(@"star_empty.png");
        self.iv_Star5.image = BundleImage(@"star_empty.png");
    }
    else if( nScore == 2 )
    {
        self.iv_Star1.image = BundleImage(@"star_fill.png");
        self.iv_Star2.image = BundleImage(@"star_fill.png");
        self.iv_Star3.image = BundleImage(@"star_empty.png");
        self.iv_Star4.image = BundleImage(@"star_empty.png");
        self.iv_Star5.image = BundleImage(@"star_empty.png");
    }
    else if( nScore == 3 )
    {
        self.iv_Star1.image = BundleImage(@"star_fill.png");
        self.iv_Star2.image = BundleImage(@"star_fill.png");
        self.iv_Star3.image = BundleImage(@"star_fill.png");
        self.iv_Star4.image = BundleImage(@"star_empty.png");
        self.iv_Star5.image = BundleImage(@"star_empty.png");
    }
    else if( nScore == 4 )
    {
        self.iv_Star1.image = BundleImage(@"star_fill.png");
        self.iv_Star2.image = BundleImage(@"star_fill.png");
        self.iv_Star3.image = BundleImage(@"star_fill.png");
        self.iv_Star4.image = BundleImage(@"star_fill.png");
        self.iv_Star5.image = BundleImage(@"star_empty.png");
    }
    else if( nScore == 5 )
    {
        self.iv_Star1.image = BundleImage(@"star_fill.png");
        self.iv_Star2.image = BundleImage(@"star_fill.png");
        self.iv_Star3.image = BundleImage(@"star_fill.png");
        self.iv_Star4.image = BundleImage(@"star_fill.png");
        self.iv_Star5.image = BundleImage(@"star_fill.png");
    }
}

@end
