//
//  MyHeaderView.m
//  ThoThing
//
//  Created by KimYoung-Min on 2017. 1. 24..
//  Copyright © 2017년 youngmin.kim. All rights reserved.
//

#import "MyHeaderView.h"
#import "SchoolCell.h"

@implementation MyHeaderView

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    [self layoutIfNeeded];
    
    self.isFirst = YES;
    
    self.iv_User.layer.cornerRadius = self.iv_User.frame.size.width / 2;
    self.iv_User.layer.borderColor = [UIColor lightGrayColor].CGColor;
    self.iv_User.layer.borderWidth = 1.f;
    
    self.btn_Following.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.btn_Member.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)updateSubjectList
{
//    for( id subView in self.sv_Subject.subviews )
//    {
//        if( [subView isKindOfClass:[UIButton class]] )
//        {
//            self.isFirst = NO;
//        }
//    }
    
    if( 1 )
    {
//        self.isFirst = NO;

        for( id subView in self.sv_Subject.subviews )
        {
            if( [subView isKindOfClass:[UIButton class]] )
            {
                [subView removeFromSuperview];
            }
        }

        for( NSInteger i = 0; i < self.arM_SubjectiList.count; i++ )
        {
            NSDictionary *dic = self.arM_SubjectiList[i];
            
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = i;
            btn.frame = CGRectMake(i * 70, 0, 70, 50);
            btn.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
            btn.titleLabel.textAlignment = NSTextAlignmentCenter;
            [btn.titleLabel setFont:[UIFont fontWithName:@"Helvetica" size:14]];
            
            NSString *str_Title = [NSString stringWithFormat:@"%@\n%@", [dic objectForKey:@"examCount"], [dic objectForKey:@"subjectName"]];
            [btn setTitle:str_Title forState:UIControlStateNormal];
            
            if( [[dic objectForKey:@"subjectName"] isEqualToString:@"레포트"] )
            {
                [btn setTitleColor:[UIColor colorWithHexString:@"4FB826"] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(onReportTouchDown:) forControlEvents:UIControlEventTouchDown];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                [btn setBackgroundImage:BundleImage(@"rect_green.png") forState:UIControlStateHighlighted];
            }
            else if( [[dic objectForKey:@"subjectName"] isEqualToString:@"오답,별표"] )
            {
                [btn setTitleColor:[UIColor colorWithHexString:@"F62B00"] forState:UIControlStateNormal];
                [btn addTarget:self action:@selector(onReportTouchDown:) forControlEvents:UIControlEventTouchDown];
                [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
                [btn setBackgroundImage:BundleImage(@"rect_red.png") forState:UIControlStateHighlighted];
            }
            else
            {
                [btn setTitleColor:kMainColor forState:UIControlStateNormal];
            }
            
            if( self.isFirst )
            {
                if( [[dic objectForKey:@"subjectName"] isEqualToString:@"전체"] )
                {
                    btn.selected = YES;
                }
            }
            
            if( [[dic objectForKey:@"subjectName"] isEqualToString:@"레포트"] == NO && [[dic objectForKey:@"subjectName"] isEqualToString:@"오답,별표"] == NO )
            {
                [btn setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
            }
            
            [btn addTarget:self action:@selector(onMenuSelected:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.sv_Subject addSubview:btn];
        }
        
        self.sv_Subject.contentSize = CGSizeMake(70 * self.arM_SubjectiList.count, 0);
        
        if( self.isFirst )
        {
            self.isFirst = NO;
            
            if(self.delegate && [self.delegate respondsToSelector:@selector(updateTableView:)])
            {
                [self.delegate updateTableView:@"전체"];
            }
        }
    }
}

- (void)updateSelectSubject:(NSString *)aSubject
{
    if( aSubject == nil || aSubject.length <= 0 )   return;
    
    for( id subView in self.sv_Subject.subviews )
    {
        if( [subView isKindOfClass:[UIButton class]] )
        {
            UIButton *btn = (UIButton *)subView;
            if( [btn.titleLabel.text rangeOfString:aSubject].location != NSNotFound )
            {
                btn.selected = YES;
            }
            else
            {
                btn.selected = NO;
            }
        }
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(updateTableView:)])
    {
        [self.delegate updateTableView:aSubject];
    }
}

- (void)onReportTouchDown:(UIButton *)btn
{
    if( [btn.titleLabel.text rangeOfString:@"레포트"].location != NSNotFound )
    {
        [btn setBackgroundImage:BundleImage(@"rect_green.png") forState:UIControlStateNormal];
    }
    else if( [btn.titleLabel.text rangeOfString:@"오답,별표"].location != NSNotFound )
    {
        [btn setBackgroundImage:BundleImage(@"rect_red.png") forState:UIControlStateNormal];
    }
    
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self performSelector:@selector(onRemoveInteraction:) withObject:btn afterDelay:0.5f];
}

- (void)onReportTouchCancel:(UIButton *)btn
{
    if( [btn.titleLabel.text rangeOfString:@"레포트"].location != NSNotFound )
    {
        [btn setTitleColor:[UIColor colorWithHexString:@"4FB826"] forState:UIControlStateNormal];
    }
    else if( [btn.titleLabel.text rangeOfString:@"오답,별표"].location != NSNotFound )
    {
        [btn setTitleColor:[UIColor colorWithHexString:@"F62B00"] forState:UIControlStateNormal];
    }
    
    [btn setBackgroundImage:BundleImage(@"") forState:UIControlStateNormal];
}

- (void)onRemoveInteraction:(UIButton *)btn
{
    if( [btn.titleLabel.text rangeOfString:@"레포트"].location != NSNotFound )
    {
        [btn setTitleColor:[UIColor colorWithHexString:@"4FB826"] forState:UIControlStateNormal];
    }
    else if( [btn.titleLabel.text rangeOfString:@"오답,별표"].location != NSNotFound )
    {
        [btn setTitleColor:[UIColor colorWithHexString:@"F62B00"] forState:UIControlStateNormal];
    }
    
    [btn setBackgroundImage:BundleImage(@"") forState:UIControlStateNormal];
}

- (void)onMenuSelected:(UIButton *)btn
{
    NSDictionary *dic = self.arM_SubjectiList[btn.tag];

    if( btn.tag != 0 )
    {
        for( id subView in self.sv_Subject.subviews )
        {
            if( [subView isKindOfClass:[UIButton class]] )
            {
                UIButton *btn_Sub = (UIButton *)subView;
                btn_Sub.selected = NO;
            }
        }
        
        btn.selected = YES;
    }
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(updateTableView:)])
    {
        [self.delegate updateTableView:[dic objectForKey:@"subjectName"]];
    }
}


#pragma mark - Table view methods
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arM_List.count;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SchoolCell";
    SchoolCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle]loadNibNamed:CellIdentifier owner:self options:nil];
        cell = [topLevelObjects objectAtIndex:0];
    }

    cell.btn_Title.userInteractionEnabled = NO;
    
    [cell.btn_Title setTitleColor:kMainColor forState:UIControlStateNormal];
    
    NSDictionary *dic = self.arM_List[indexPath.row];
    if( [[dic objectForKey_YM:@"type"] isEqualToString:@"school"] )
    {
        NSString *str_Title = [NSString stringWithFormat:@"%@ %@명",
                               [self.dic_Data objectForKey_YM:@"channelHashTag"], [self.dic_Data objectForKey_YM:@"useHashCodeCount"]];
        [cell.btn_Title setTitle:str_Title forState:UIControlStateNormal];
    }
    else
    {
        NSString *str_Title = [NSString stringWithFormat:@"%@ %@명",
                               [dic objectForKey_YM:@"channelName"], [dic objectForKey_YM:@"channelMemberCount"]];
        [cell.btn_Title setTitle:str_Title forState:UIControlStateNormal];
        
        NSInteger nMemberLevel = [[dic objectForKey:@"memberLevel"] integerValue];
        NSString *str_StatusCode = [dic objectForKey:@"statusCode"];
        if( [str_StatusCode isEqualToString:@"T"] && nMemberLevel < 10 )
        {
            //관리자
            [cell.btn_Title setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
        }
    }
    
    return cell;
}

// Override to support row selection in the table view.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(tableViewTouch:)])
    {
        NSDictionary *dic = self.arM_List[indexPath.row];
        [self.delegate tableViewTouch:dic];
    }
}

- (IBAction)goShowFollowingList:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(goShowFollowingList:)])
    {
        [self.delegate goShowFollowingList:sender];
    }
}

- (IBAction)goShowMemberList:(id)sender
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(goShowMemberList:)])
    {
        [self.delegate goShowMemberList:sender];
    }
}

- (IBAction)goQ1Touch:(id)sender
{
    
}

- (IBAction)goQ2Touch:(id)sender
{
    
}

@end
