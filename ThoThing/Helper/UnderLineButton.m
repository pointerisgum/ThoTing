//
//  UnderLineButton.m
//  PB
//
//  Created by KimYoung-Min on 2014. 12. 14..
//  Copyright (c) 2014년 KimYoung-Min. All rights reserved.
//

#import "UnderLineButton.h"

@implementation UnderLineButton
- (void)addUnderLine
{
    if( self.titleLabel.text.length > 0 )
    {
        NSMutableAttributedString *commentString = [[NSMutableAttributedString alloc] initWithString:self.titleLabel.text];
        [commentString addAttribute:NSUnderlineStyleAttributeName value:[NSNumber numberWithInteger:NSUnderlineStyleSingle] range:NSMakeRange(0, [commentString length])];
        [self setAttributedTitle:commentString forState:UIControlStateNormal];
    }
}
@end
