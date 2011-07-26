//
//  FilterViewController.h
//  MyTime
//
//  Created by Brent Priddy on 1/30/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericTableViewController.h"
#import <CoreData/CoreData.h>
#import "MTFilter.h"

@class FilterViewController;

@protocol FilterViewControllerDelegate
- (void)filterViewControllerDone:(FilterViewController *)viewController;
@end

@interface FilterViewController : GenericTableViewController
{
	NSObject<FilterViewControllerDelegate> *delegate;
	MTFilter *filter;
}
@property (nonatomic, assign) NSObject<FilterViewControllerDelegate> *delegate;
@property (nonatomic, retain) MTFilter *filter;
@property (nonatomic, copy) NSIndexPath *selectedIndexPath;

- (id)initWithFilter:(MTFilter *)filter newFilter:(BOOL)newFilter;
@end
