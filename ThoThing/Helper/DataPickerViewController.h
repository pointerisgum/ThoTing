//
//  DataPickerViewController.h
//  ASKing
//
//  Created by Kim Young-Min on 2013. 11. 28..
//  Copyright (c) 2013년 Kim Young-Min. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DataPickerViewControllerDelegate;
@interface DataPickerViewController : UIViewController
@property (nonatomic, strong) id <DataPickerViewControllerDelegate> delegate;
@property (nonatomic, strong) NSArray *ar_PickerData;
@property (nonatomic, strong) NSString *str_PickerTitle;
@end

@protocol DataPickerViewControllerDelegate <NSObject>
@optional
- (void)dataPickerViewDidSelected:(NSString *)aString;
- (void)dataPickerViewDidSelected:(NSString *)aString withIndex:(NSInteger)idx;
@end



