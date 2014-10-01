//
//  DataCollectionViewController.m
//  CollectionViewWithNSFetchResultControllerAndSections
//
//  Created by Christian Zimmermann on 01.10.14.
//  Copyright (c) 2014 Christian Zimmermann. All rights reserved.
//

#import "DataCollectionViewController.h"
#import "DataItem+NameAndInfo.h"

@interface DataCollectionViewController () <NSFetchedResultsControllerDelegate>

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;


// UI elements to change data
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButCat1;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButCat2;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButCat3;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButCat4;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *barButSetCurrentDate;

@end

@implementation DataCollectionViewController
{
    NSMutableArray *_itemInserts;
    NSMutableArray *_itemDeletes;
    NSMutableArray *_itemUpdates;
    NSMutableArray *_itemMoves;
    NSMutableArray *_sectionInserts;
    NSMutableArray *_sectionDeletes;
    NSMutableArray *_itemChanges;
    NSMutableArray *_sectionChanges;
}

static NSString * const collectionCellReuseIdentifier = @"DataCollectionCell";
static NSString * const subIdentifier1 = @"CollectionSubReuse";

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

-(IBAction)changeCategory:(UIBarButtonItem*)senderButton
{
    NSNumber *newCategory = @(senderButton.tag);
    if ([self.collectionView.indexPathsForSelectedItems count]>0) // here is a difference to TableViews
    {
        NSIndexPath *ipSelection = [self.collectionView.indexPathsForSelectedItems firstObject];
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
            [self.collectionView deselectItemAtIndexPath:ipSelection animated:NO];
            [self setupToolBar];
        }
    }
}

- (IBAction)changeCreateDateToNow:(id)sender
{
    if ([self.collectionView.indexPathsForSelectedItems count]>0) // here is a difference to TableViews
    {
        NSIndexPath *ipSelection = [self.collectionView.indexPathsForSelectedItems firstObject];
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
            [self.collectionView deselectItemAtIndexPath:ipSelection animated:NO];
            [self setupToolBar];
        }
    }
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

- (void)configureCell:(UICollectionViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    DataItem *item = (DataItem*)[self.fetchedResultsController objectAtIndexPath:indexPath];
    UILabel *textLabel = (UILabel*)[cell viewWithTag:1];
    textLabel.text = item.displayString;
    UIView* selectedBGView = [[UIView alloc] initWithFrame:cell.bounds];
    selectedBGView.backgroundColor = [UIColor darkGrayColor];
    cell.selectedBackgroundView = selectedBGView;
}

-(void)setupToolBar
{
    NSArray *items = nil;
    // data change is only possible if an item is selected
    if ([self.collectionView.indexPathsForSelectedItems count]>0)
    {
        UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        items = @[flexSpace,self.barButCat1,flexSpace,self.barButCat2,flexSpace,self.barButCat3,flexSpace,self.barButCat4,flexSpace,self.barButSetCurrentDate];
    }
    [self setToolbarItems:items animated:YES];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    NSInteger count = [[self.fetchedResultsController sections] count];
    NSLog(@"%@",[NSString stringWithFormat:@"Sections: %@",@(count)]);
    return count;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo = [self.fetchedResultsController sections][section];
    NSInteger count = [sectionInfo numberOfObjects];
    NSLog(@"%@",[NSString stringWithFormat:@"Items: %@",@(count)]);
    return count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:collectionCellReuseIdentifier forIndexPath:indexPath];
    
    [self configureCell:cell atIndexPath:indexPath];
   
    
    return cell;
}

- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    static NSString *subIdentifier1 = @"CollectionSubReuse";
    UICollectionReusableView *sub;
    sub = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:subIdentifier1 forIndexPath:indexPath];
    UILabel *label = (UILabel*)[sub viewWithTag:1];
    label.text = [self titleForHeaderInSection:indexPath.section];
    return sub;
}

- (NSString *)titleForHeaderInSection:(NSInteger)section
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

#pragma mark <UICollectionViewDelegate>

-(BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL shouldSelecte = YES;
    if ([self.collectionView.indexPathsForSelectedItems count]>0)
    {
        NSIndexPath *ipSel = (self.collectionView.indexPathsForSelectedItems)[0];
        if ([ipSel isEqual:indexPath])
        {
            shouldSelecte = NO;
            [self.collectionView deselectItemAtIndexPath:indexPath animated:YES];
            [self setupToolBar];
        }
    }
    return shouldSelecte;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self setupToolBar];
}

-(void) collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
   [self setupToolBar];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController
{
    if (_fetchedResultsController != nil)
    {
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
    if (![self.fetchedResultsController performFetch:&error])
    {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _fetchedResultsController;
}

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    _itemChanges = [NSMutableArray array];
    _sectionChanges = [NSMutableArray array];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
    NSMutableDictionary *change = [[NSMutableDictionary alloc] init];
    change[@(type)] = @(sectionIndex);
    [_sectionChanges addObject:change];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    NSMutableDictionary *change = [NSMutableDictionary dictionary];
    change[@(type)] = newIndexPath;
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [_itemChanges addObject:change];
            break;
            
        case NSFetchedResultsChangeDelete:
            [_itemChanges addObject:change];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [_itemChanges addObject:change];
            break;
       
        case NSFetchedResultsChangeMove:
            change[@(type)] = @[indexPath, newIndexPath];
            [_itemChanges addObject:change];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [self.collectionView performBatchUpdates:^()
     {
         for (NSDictionary *change in _sectionChanges)
         {
             [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                 NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                 switch(type) {
                     case NSFetchedResultsChangeInsert:
                         [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                         break;
                     case NSFetchedResultsChangeDelete:
                         [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[obj unsignedIntegerValue]]];
                         break;
                     case NSFetchedResultsChangeUpdate:
                         break;
                     case NSFetchedResultsChangeMove:
                         break;
                 }
             }];
         }
         
         for (NSDictionary *change in _itemChanges)
         {
             [change enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                 NSFetchedResultsChangeType type = [key unsignedIntegerValue];
                 
                 switch(type) {
                     case NSFetchedResultsChangeInsert:
                         [self.collectionView insertItemsAtIndexPaths:@[obj]];
                         break;
                     case NSFetchedResultsChangeDelete:
                         [self.collectionView deleteItemsAtIndexPaths:@[obj]];
                         break;
                     case NSFetchedResultsChangeUpdate:
                         [self.collectionView reloadItemsAtIndexPaths:@[obj]];
                         break;
                     case NSFetchedResultsChangeMove:
                         [self.collectionView deleteItemsAtIndexPaths:@[obj[0]]];
                         [self.collectionView insertItemsAtIndexPaths:@[obj[1]]];
                         break;
                 }
             }];
         }
     }
    completion:^(BOOL finished)
     {
         _sectionChanges = nil;
         _itemChanges = nil;
     }];
}


@end
