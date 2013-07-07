//
//  StoreTableViewController.m
//  SIStoreExample
//
//  Created by ChenYu Xiao on 13-7-2.
//  Copyright (c) 2013年 iiiyu. All rights reserved.
//

#import "StoreTableViewController.h"
#import <CoreData/CoreData.h>
#import <CoreData+MagicalRecord.h>
#import "AddTaskViewController.h"
#import "ViewController.h"
#import "Task.h"

@interface StoreTableViewController ()<NSFetchedResultsControllerDelegate, AddTaskViewControllerDelegate>
@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic) BOOL beganUpdates;
@property (strong, nonatomic) NSIndexPath *selectIndex;
//@property (strong, nonatomic) Task *selectTask;

@end

@implementation StoreTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
//    if (!self.selectIndex) {
//        self.selectIndex = [[NSIndexPath alloc] init];
//    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Init Mehtods

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
//    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"position > 0"];
//    _fetchedResultsController = [Task MR_fetchAllSortedBy:@"createAt" ascending:YES withPredicate:predicate groupBy:nil delegate:self];
    _fetchedResultsController = [Task MR_fetchAllSortedBy:@"createAt" ascending:YES withPredicate:nil groupBy:nil delegate:self];
    return _fetchedResultsController;
}


#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[self.fetchedResultsController sections] objectAtIndex:section] numberOfObjects];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [[[self.fetchedResultsController sections] objectAtIndex:section] name];
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
	return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:index];
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return [self.fetchedResultsController sectionIndexTitles];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    self.selectTask = [self.fetchedResultsController objectAtIndexPath:indexPath];
    self.selectIndex = indexPath;
    [self performSegueWithIdentifier:@"Show Task Detail" sender:nil];
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext) {
        [self.tableView beginUpdates];
        self.beganUpdates = YES;
    }
}

- (void)controller:(NSFetchedResultsController *)controller
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
		   atIndex:(NSUInteger)sectionIndex
	 forChangeType:(NSFetchedResultsChangeType)type
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext)
    {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
}


- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
	   atIndexPath:(NSIndexPath *)indexPath
	 forChangeType:(NSFetchedResultsChangeType)type
	  newIndexPath:(NSIndexPath *)newIndexPath
{
    if (!self.suspendAutomaticTrackingOfChangesInManagedObjectContext)
    {
        switch(type)
        {
            case NSFetchedResultsChangeInsert:
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeDelete:
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeUpdate:
                [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
                
            case NSFetchedResultsChangeMove:
                [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
                [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
        }
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    if (self.beganUpdates) [self.tableView endUpdates];
}

- (void)endSuspensionOfUpdatesDueToContextChanges
{
    self.suspendAutomaticTrackingOfChangesInManagedObjectContext = NO;
}

- (void)setSuspendAutomaticTrackingOfChangesInManagedObjectContext:(BOOL)suspend
{
    if (suspend) {
        self.suspendAutomaticTrackingOfChangesInManagedObjectContext = YES;
    } else {
        [self performSelector:@selector(endSuspensionOfUpdatesDueToContextChanges) withObject:0 afterDelay:0];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];

    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];

    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *object = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = [[object valueForKey:@"content"] description];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"Add Task Content"]) {
        AddTaskViewController *viewController = segue.destinationViewController;
        viewController.delegate = self;
    }else if ([segue.identifier isEqualToString:@"Show Task Detail"]){
        ViewController *viewController = segue.destinationViewController;
        viewController.task = [self.fetchedResultsController objectAtIndexPath:self.selectIndex];
//        viewController.task = self.selectTask;
    }
}


-(void) addTaskViewControllerDidFinshed:(AddTaskViewController *)viewController
{
    Task *ttask = [Task MR_createEntity];
    NSInteger count = [Task MR_countOfEntities];
    ttask.position = @(count + 1);
    ttask.createAt = [NSDate date];
    ttask.updateAt = [NSDate date];
    ttask.content = viewController.content;
    
    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfWithCompletion:^(BOOL success, NSError *error) {
        [viewController dismissViewControllerAnimated:YES completion:nil];
    }];

}

- (IBAction)addTaskAction:(id)sender {
    
//    Task *tt = [Task MR_createEntity];
//    NSInteger count = [Task MR_countOfEntities];
//    tt.position = @(count + 1);
//    tt.createAt = [NSDate date];
//
//    [[NSManagedObjectContext MR_defaultContext] MR_saveOnlySelfAndWait];
}

@end
