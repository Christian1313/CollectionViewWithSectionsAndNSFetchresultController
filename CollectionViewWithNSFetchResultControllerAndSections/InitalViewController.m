//
//  InitalViewController.m
//  CollectionViewWithNSFetchResultControllerAndSections
//
//  Created by Christian Zimmermann on 01.10.14.
//  Copyright (c) 2014 Christian Zimmermann. All rights reserved.
//

#import "InitalViewController.h"
#import "DataTableViewController.h"
#import "DataCollectionViewController.h"

@implementation InitalViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showTable"])
    {
        UINavigationController *nav = (UINavigationController*)segue.destinationViewController;
        DataTableViewController *dTable = (DataTableViewController*)nav.topViewController;
        dTable.context = self.context;
    }
    else if ([segue.identifier isEqualToString:@"showCollection"])
    {
        UINavigationController *nav = (UINavigationController*)segue.destinationViewController;
        DataCollectionViewController *dCollection = (DataCollectionViewController*)nav.topViewController;
        dCollection.context = self.context;
    }
}


@end
