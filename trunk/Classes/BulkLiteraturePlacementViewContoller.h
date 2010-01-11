//
//  BulkLiteraturePlacementViewContoller.h
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
#import "LiteraturePlacementViewControllerDelegate.h"
#import "EmptyListViewController.h"

@interface BulkLiteraturePlacementViewContoller : UIViewController <UITableViewDelegate, 
                                                                    UITableViewDataSource, 
																	LiteraturePlacementViewControllerDelegate> 
{
	UITableView *tableView;
	NSMutableArray *entries;
	
	NSIndexPath *selectedIndexPath;
	EmptyListViewController *emptyView;
}
@property (nonatomic, retain) EmptyListViewController *emptyView;
@property (nonatomic,retain) UITableView *tableView;
@property (nonatomic,retain) NSMutableArray *entries;
@property (nonatomic,retain) NSIndexPath *selectedIndexPath;

/**
 * initialize this view with a watchtower at the current month/year
 *
 * @param rect - the rect
 * @returns self
 */
- (id)init;
- (void)dealloc;
- (void)reloadData;
@end
