//
//  SearchBarViewController.h
//  ThoThing
//
//  Created by KimYoung-Min on 2016. 9. 29..
//  Copyright © 2016년 youngmin.kim. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^CompletionBlock)(id completeResult);

@interface SearchBarViewController : UIViewController
@property (nonatomic, copy) CompletionBlock completionBlock;
@property (nonatomic, assign) BOOL isLibraryMode;
@property (nonatomic, assign) BOOL isBotMakeMode;
@property (nonatomic, strong) NSString *str_Type;
@property (nonatomic, strong) NSString *str_SearchWord;
@property (nonatomic, strong) NSArray *ar_DidSelectList;
- (void)setCompletionBlock:(CompletionBlock)completionBlock;
@end
