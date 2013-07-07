//
//  ViewController.m
//  SIStoreExample
//
//  Created by ChenYu Xiao on 13-5-25.
//  Copyright (c) 2013年 iiiyu. All rights reserved.
//

#import "ViewController.h"
#import "Task.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UITextView *contentTextView;
@property (weak, nonatomic) IBOutlet UILabel *createAtDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *updateAtDateLabel;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.contentTextView.text = self.task.content;
    self.createAtDateLabel.text = [self.task.createAt description];
    self.updateAtDateLabel.text = [self.task.updateAt description];
}


- (IBAction)doneAction:(id)sender {
    if (![self.contentTextView.text isEqualToString:self.task.content]) {
        self.task.content = self.contentTextView.text;
        self.task.updateAt = [NSDate date];
        
        [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfWithCompletion:^(BOOL success, NSError *error) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)deleteAction:(id)sender {
    if (self.task) {
        [self.task MR_deleteEntity];[[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfWithCompletion:^(BOOL success, NSError *error) {
            [self.navigationController popViewControllerAnimated:YES];
        }];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
