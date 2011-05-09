//
//  FilterDetailViewController.h
//  MyTime
//
//  Created by Brent Priddy on 1/30/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GenericTableViewController.h"
#import <CoreData/CoreData.h>
#import "MTFilter.h"

@class FilterTableViewController;
@class FilterDetailViewController;

@protocol FilterDetailViewControllerDelegate
- (void)filterViewControllerDone:(FilterDetailViewController *)viewController;
@end

@interface FilterDetailViewController : GenericTableViewController
{
	NSObject<FilterDetailViewControllerDelegate> *delegate;
	MTFilter *filter;
	FilterTableViewController *filterTableViewController_;
}
@property (nonatomic, assign) NSObject<FilterDetailViewControllerDelegate> *delegate;
@property (nonatomic, retain) MTFilter *filter;
@property (nonatomic, copy) NSIndexPath *selectedIndexPath;
@property (nonatomic, readonly) FilterTableViewController *filterTableViewController;
@property (nonatomic, retain) NSMutableSet *allTextFields;

- (id)initWithFilter:(MTFilter *)filter newFilter:(BOOL)newFilter;
@end
