//
//  SorterViewController.h
//  MyTime
//
//  Created by Brent Priddy on 1/30/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericTableViewController.h"
#import <CoreData/CoreData.h>
#import "MTSorter.h"

@class SorterViewController;

@protocol SorterViewControllerDelegate
- (void)sorterViewControllerDone:(SorterViewController *)viewController;
@end

@interface SorterViewController : GenericTableViewController
{
	NSObject<SorterViewControllerDelegate> *delegate;
	MTSorter *sorter;
}
@property (nonatomic, assign) NSObject<SorterViewControllerDelegate> *delegate;
@property (nonatomic, retain) MTSorter *sorter;

- (id)initWithSorter:(MTSorter *)sorter newSorter:(BOOL)newSorter;
@end
