//
//  DataCollectionViewController.h
//  CollectionViewWithNSFetchResultControllerAndSections
//
//  Created by Christian Zimmermann on 01.10.14.
//  Copyright (c) 2014 Christian Zimmermann. All rights reserved.
//

@import UIKit;
@import CoreData;

@interface DataCollectionViewController : UICollectionViewController

@property (nonatomic, strong) NSManagedObjectContext *context;

@end
