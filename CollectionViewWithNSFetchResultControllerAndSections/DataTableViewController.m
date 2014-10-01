//
//  DataTableViewController.m
//  CollectionViewWithNSFetchResultControllerAndSections
//
//  Created by Christian Zimmermann on 01.10.14.
//  Copyright (c) 2014 Christian Zimmermann. All rights reserved.
//

#import "DataTableViewController.h"
#import "DataItem+NameAndInfo.h"

@interface DataTableViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;


// UI elements to change data
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButCat1;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButCat2;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButCat3;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButCat4;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButSetCurrentDate;

@end

@implementation DataTableViewController

static NSString * const tableCellReuseIdentifier = @"DataTableCell";

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupToolBar];
    self.barButCat1.tag = 0;
    self.barButCat2.tag = 1;
    self.barButCat3.tag = 2;
    self.barButCat4.tag = 3;
}

- (IBAction)cancelView:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)createNewItem:(id)sender
{
    DataItem *newItem = (DataItem*)[NSEntityDescription insertNewObjectForEntityForName:NSStringFromClass([DataItem class]) inManagedObjectContext:self.context];
    newItem.createDate = [NSDate date];
    newItem.category = @(0);
    
    NSError *error;
    [self.context save:&error];
    if (error)
    {
        NSLog(@"%@",[error localizedDescription]);
    }
}

-(IBAction)changeCategory:(UIBarButtonItem*)senderButton
{
    NSNumber *newCategory = @(senderButton.tag);
    NSIndexPath *ipSelection = self.tableView.indexPathForSelectedRow;
    if (ipSelection)
    {
        DataItem *item = (DataItem*)[self.fetchedResultsController objectAtIndexPath:ipSelection];
        if (item)
        {
            item.category = newCategory;
            NSError *error;
            [self.context save:&error];
            if (error)
            {
                NSLog(@"%@",[error localizedDescription]);
            }
        }
        [self.tableView deselectRowAtIndexPath:ipSelection animated:NO];
        [self setupToolBar];
    }
}

- (IBAction)changeCreateDateToNow:(id)sender
{
    NSIndexPath *ipSelection = self.tableView.indexPathForSelectedRow;
    if (ipSelection)
    {
        DataItem *item = (DataItem*)[self.fetchedResultsController objectAtIndexPath:ipSelection];
        if (item)
        {
            item.createDate = [NSDate date];
            NSError *error;
            [self.context save:&error];
            if (error)
            {
                NSLog(@"%@",[error localizedDescription]);
            }
        }
        [self.tableView deselectRowAtIndexPath:ipSelection animated:NO];
        [self setupToolBar];
    }

}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    DataItem *item = (DataItem*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = item.displayString;
}

-(void)setupToolBar
{
    NSArray *items = nil;
    // data change is only possible if an item is selected
    if (self.tableView.indexPathForSelectedRow)
    {
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        items = @[flexSpace,self.barButCat1,flexSpace,self.barButCat2,flexSpace,self.barButCat3,flexSpace,self.barButCat4,flexSpace,self.barButSetCurrentDate];
    }
    [self setToolbarItems:items animated:YES];
}


#pragma mark - Table View Delegates (Selection and deselection)

-(NSIndexPath*)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *ip = indexPath;
    if ([self.tableView isEqual:tableView])
    {
        if ([[self.tableView indexPathForSelectedRow] isEqual:indexPath])
        {
            [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
            ip = nil;
            [self setupToolBar];
        }
    }
    return indexPath;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setupToolBar];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self setupToolBar];
}

#pragma mark - Table View Data Source Delegates

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[self.fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:tableCellReuseIdentifier forIndexPath:indexPath];
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSInteger cat = -1;
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    NSArray *objs = sectionInfo.objects;
    if (objs&&[objs count]>0)
    {
        DataItem *item = (DataItem*)[objs firstObject];
        cat = [item.category integerValue];
    }
    NSString *sectionTitle = @"";
    if (cat!=-1)
    {
        sectionTitle = [NSString stringWithFormat:@"Cat %@",@(cat+1)];
    }
    return sectionTitle;
}


#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil) {
        return _fetchedResultsController;
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"DataItem" inManagedObjectContext:self.context];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
        NSSortDescriptor *sortDescriptorCat = [[NSSortDescriptor alloc] initWithKey:@"category" ascending:YES];
    NSSortDescriptor *sortDescriptorDate = [[NSSortDescriptor alloc] initWithKey:@"createDate" ascending:NO];
    NSArray *sortDescriptors = @[sortDescriptorCat,sortDescriptorDate];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // "category" for section name key path.
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.context sectionNameKeyPath:@"category" cacheName:nil];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        default:
            return;
    }
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = self.tableView;
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.tableView endUpdates];
}


@end
