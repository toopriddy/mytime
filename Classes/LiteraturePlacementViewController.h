//
//  LiteraturePlacementViewController.h
//  MyTime
//
//  Created by Brent Priddy on 8/15/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import <UIKit/UIKit.h>
#import "PublicationViewControllerDelegate.h"
#import "DatePickerViewControllerDelegate.h"
#import "GenericTableViewController.h"
#import "MTBulkPlacement.h"

@class LiteraturePlacementViewController;

@protocol LiteraturePlacementViewControllerDelegate<NSObject>
@required
- (void)literaturePlacementViewControllerDone:(LiteraturePlacementViewController *)literaturePlacementViewController;
@end

@interface LiteraturePlacementViewController : GenericTableViewController
{
	UITableView *tableView;
	MTBulkPlacement *bulkPlacement;
	
	NSIndexPath *selectedIndexPath;
	
	id<LiteraturePlacementViewControllerDelegate> delegate;
}
@property (nonatomic, retain) MTBulkPlacement *bulkPlacement;
@property (nonatomic, retain) NSIndexPath *selectedIndexPath;
@property (nonatomic, assign) id<LiteraturePlacementViewControllerDelegate> delegate;

/**
 * initialize this view with a watchtower at the current month/year
 *
 * @param rect - the rect
 * @returns self
 */
- (id)initWithBulkPlacement:(MTBulkPlacement *)theBulkPlacement;

@end