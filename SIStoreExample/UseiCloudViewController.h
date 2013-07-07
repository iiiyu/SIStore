//
//  UseiCloudViewController.h
//  SIStoreExample
//
//  Created by ChenYu Xiao on 13-7-2.
//  Copyright (c) 2013年 iiiyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol UseiCloudViewControllerDelegate;




@interface UseiCloudViewController : UIViewController

@property (weak, nonatomic) id<UseiCloudViewControllerDelegate> delegate;
@property (nonatomic, assign) BOOL isICloud;

@end


@protocol UseiCloudViewControllerDelegate <NSObject>

@optional
-(void)useiCloudViewControllerDidFinshed:(UseiCloudViewController *)viewController;

@end