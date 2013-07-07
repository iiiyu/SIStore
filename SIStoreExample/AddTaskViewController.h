//
//  AddTaskViewController.h
//  SIStoreExample
//
//  Created by ChenYu Xiao on 13-7-7.
//  Copyright (c) 2013年 iiiyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AddTaskViewControllerDelegate;

@interface AddTaskViewController : UIViewController

@property (weak, nonatomic) id<AddTaskViewControllerDelegate> delegate;
@property (readonly, nonatomic) NSString *content;

@end


@protocol AddTaskViewControllerDelegate <NSObject>

@optional
-(void) addTaskViewControllerDidFinshed:(AddTaskViewController *)viewController;

@optional
-(void) addTaskViewControllerCanceled:(AddTaskViewController *)viewController;


@end