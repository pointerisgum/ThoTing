//
//  DataPickerViewController.m
//  ASKing
//
//  Created by Kim Young-Min on 2013. 11. 28..
//  Copyright (c) 2013년 Kim Young-Min. All rights reserved.
//

#import "DataPickerViewController.h"

@interface DataPickerViewController ()
@property (nonatomic, assign) NSInteger nSelectedRow;
@property (nonatomic, strong) IBOutlet UIPickerView *picker;
@property (nonatomic, strong) IBOutlet UILabel *lb_Title;
- (IBAction)goClosed:(id)sender;
@end

@implementation DataPickerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
//    self.ar_PickerData = [NSArray arrayWithObjects:@"미혼", @"기혼", nil];
    self.lb_Title.text = self.str_PickerTitle;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.ar_PickerData count];
}


#pragma mark -
#pragma mark UIPickerViewDelegate
- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [self.ar_PickerData objectAtIndex:row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.nSelectedRow = row;
}

- (IBAction)goClosed:(id)sender
{
    if( [self.delegate respondsToSelector:@selector(dataPickerViewDidSelected:)] )
    {
        [self.delegate dataPickerViewDidSelected:[self.ar_PickerData objectAtIndex:self.nSelectedRow]];
    }
    
    if( [self.delegate respondsToSelector:@selector(dataPickerViewDidSelected:withIndex:)] )
    {
        [self.delegate dataPickerViewDidSelected:[self.ar_PickerData objectAtIndex:self.nSelectedRow] withIndex:self.nSelectedRow];
    }
    
    [self dismissViewControllerAnimated:YES
                             completion:^{
                                 
                             }];
}

@end
