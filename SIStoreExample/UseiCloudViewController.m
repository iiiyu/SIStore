//
//  UseiCloudViewController.m
//  SIStoreExample
//
//  Created by ChenYu Xiao on 13-7-2.
//  Copyright (c) 2013年 iiiyu. All rights reserved.
//

#import "UseiCloudViewController.h"

@interface UseiCloudViewController ()

@end

@implementation UseiCloudViewController


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


#pragma mark - Actions

- (IBAction)chooseIcloudAction:(UIButton *)sender {
    self.isICloud = sender.tag;
    if ([self.delegate respondsToSelector:@selector(useiCloudViewControllerDidFinshed:)]) {
        [self.delegate useiCloudViewControllerDidFinshed:self];
    }
}

@end
