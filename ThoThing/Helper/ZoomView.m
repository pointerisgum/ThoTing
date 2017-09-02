//
//  ZoomView.m
//  EmAritaum
//
//  Created by KimYoung-Min on 2014. 8. 29..
//  Copyright (c) 2014년 Kim Young-Min. All rights reserved.
//

#import "ZoomView.h"

@implementation ZoomView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    self.sv_Zoom.delegate = self;
    self.sv_Zoom.minimumZoomScale = 1.0f;
    self.sv_Zoom.maximumZoomScale = 3.0f;
    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    [doubleTap setNumberOfTapsRequired:2];
    [self.sv_Zoom addGestureRecognizer:doubleTap];
    
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

- (void)handleDoubleTap:(UIGestureRecognizer *)gestureRecognizer
{
    if(self.sv_Zoom.zoomScale > self.sv_Zoom.minimumZoomScale)
    {
        [self.sv_Zoom setZoomScale:self.sv_Zoom.minimumZoomScale animated:YES];
    }
    else
    {
        CGRect zoomRect = [self zoomRectForScale:self.sv_Zoom.maximumZoomScale withCenter:[gestureRecognizer locationInView:gestureRecognizer.view]];
        [self.sv_Zoom zoomToRect:zoomRect animated:YES];
    }
}

- (CGRect)zoomRectForScale:(float)scale withCenter:(CGPoint)center {
    
    CGRect zoomRect;
    
    zoomRect.size.height = [self.iv_Zoom frame].size.height / scale;
    zoomRect.size.width  = [self.iv_Zoom frame].size.width  / scale;
    
    center = [self.iv_Zoom convertPoint:center fromView:self.sv_Zoom];
    
    zoomRect.origin.x = center.x - ((zoomRect.size.width / 2.0));
    zoomRect.origin.y = center.y - ((zoomRect.size.height / 2.0));
    
    return zoomRect;
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.iv_Zoom;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    if( scrollView.zoomScale <= 1.0f )
    {
        self.hidden = YES;
    }
}

@end
