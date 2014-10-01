//
//  DataItem.h
//  CollectionViewWithNSFetchResultControllerAndSections
//
//  Created by Christian Zimmermann on 01.10.14.
//  Copyright (c) 2014 Christian Zimmermann. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface DataItem : NSManagedObject

@property (nonatomic, retain) NSNumber * category;
@property (nonatomic, retain) NSDate * createDate;

@end
