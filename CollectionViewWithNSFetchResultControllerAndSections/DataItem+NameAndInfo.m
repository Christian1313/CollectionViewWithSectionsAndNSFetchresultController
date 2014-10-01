//
//  DataItem+NameAndInfo.m
//  CollectionViewWithNSFetchResultControllerAndSections
//
//  Created by Christian Zimmermann on 01.10.14.
//  Copyright (c) 2014 Christian Zimmermann. All rights reserved.
//

#import "DataItem+NameAndInfo.h"

@implementation DataItem (NameAndInfo)


-(NSString*)displayString
{
    NSString *catStr = [NSString stringWithFormat:@"Cat: %@",@([self.category integerValue]+1)];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterShortStyle;
    df.timeStyle = NSDateFormatterMediumStyle;
    NSString *str = [NSString stringWithFormat:@"%@ - %@",[df stringFromDate:self.createDate],catStr];
    return str;
}

@end
