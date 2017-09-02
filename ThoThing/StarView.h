//
//  StarView.h
//  OrangeMT
//
//  Created by KimYoung-Min on 2016. 6. 15..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol StarViewDelegate;

@interface StarView : UIView
@property (nonatomic, weak) id<StarViewDelegate> delegate;
@property (nonatomic, assign) NSInteger nScore;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Star1;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Star2;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Star3;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Star4;
@property (nonatomic, weak) IBOutlet UIImageView *iv_Star5;
- (void)setStarScore:(NSInteger)nScore;
@end


@protocol StarViewDelegate <NSObject>
@optional
- (void)didUpdateStarView:(NSInteger)nScore;
@end
