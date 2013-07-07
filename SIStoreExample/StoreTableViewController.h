//
//  StoreTableViewController.h
//  SIStoreExample
//
//  Created by ChenYu Xiao on 13-7-2.
//  Copyright (c) 2013年 iiiyu. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StoreTableViewController : UITableViewController

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;


@property (nonatomic) BOOL suspendAutomaticTrackingOfChangesInManagedObjectContext;

@end
