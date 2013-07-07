//
//  StartupViewController.m
//  SIStoreExample
//
//  Created by ChenYu Xiao on 13-7-5.
//  Copyright (c) 2013年 iiiyu. All rights reserved.
//

#import "StartupViewController.h"
#import "TBStore.h"
#import "SIDefines.h"
#import "UseiCloudViewController.h"

@interface StartupViewController ()<UseiCloudViewControllerDelegate>

@end

@implementation StartupViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    BOOL usedBefore = [[NSUserDefaults standardUserDefaults] boolForKey:SI_USED_BEFORE_KEY];
    
    if (usedBefore) {
        [TBStore setupStoreUsingDefaultLocationCompletion:^{
            [self setupComplete];
        }];
    }else{
        [TBStore checkICloudAvailabilityCompletion:^(BOOL available) {
            if (available) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self performSegueWithIdentifier:@"Go To Choose iCloud View" sender:nil];
                });
            }else{
                [TBStore setupLocalStoreCompletion:^{
                    [self setupComplete];
                }];
                
            }
        }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)setupComplete
{
//    [self.activityIndicatorView stopAnimating];
    //    NSTimer *timer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(start:) userInfo:nil repeats:YES];
    //
    //    [timer invalidate];
    [self performSelector:@selector(start) withObject:nil afterDelay:0.8];
}


- (void)start
{
    [self performSegueWithIdentifier:@"Go to Initial Slide View" sender:nil];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Go To Choose iCloud View"]) {
        UseiCloudViewController *viewContorller = segue.destinationViewController;
        viewContorller.delegate = self;
    }
}


#pragma mark - UseiCloudViewControllerDelegate
-(void)useiCloudViewControllerDidFinshed:(UseiCloudViewController *)viewController
{
    [viewController dismissViewControllerAnimated:YES completion:^{
        if (viewController.isICloud) {
            [TBStore setupICloudStoreCompletion:^{
                [self setupComplete];
            }];
        }else{
            [TBStore setupLocalStoreCompletion:^{
                [self setupComplete];
            }];
        }
    }];
}




@end
