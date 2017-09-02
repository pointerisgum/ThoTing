//
//  ZoomView.h
//  EmAritaum
//
//  Created by KimYoung-Min on 2014. 8. 29..
//  Copyright (c) 2014년 Kim Young-Min. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ZoomView : UIView <UIScrollViewDelegate>
@property (nonatomic, strong) IBOutlet UIImageView *iv_Zoom;
@property (nonatomic, strong) IBOutlet UIScrollView *sv_Zoom;
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView;
@end
