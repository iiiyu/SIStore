//
//  AddTaskViewController.m
//  SIStoreExample
//
//  Created by ChenYu Xiao on 13-7-7.
//  Copyright (c) 2013年 iiiyu. All rights reserved.
//

#import "AddTaskViewController.h"

@interface AddTaskViewController ()
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;

@end

@implementation AddTaskViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)doneAction:(id)sender {
    _content = self.contentTextView.text;
    if ([self.delegate respondsToSelector:@selector(addTaskViewControllerDidFinshed:)]) {
        [self.delegate addTaskViewControllerDidFinshed:self];
    }
}


- (IBAction)cancelAction:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


@end
