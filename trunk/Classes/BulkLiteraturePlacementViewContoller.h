//
//  BulkLiteraturePlacementViewContoller.h
//  MyTime
//
//  Created by Brent Priddy on 8/15/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PublicationViewControllerDelegate.h"
#import "LiteraturePlacementViewControllerDelegate.h"

@interface BulkLiteraturePlacementViewContoller : UIViewController <UITableViewDelegate, 
                                                                    UITableViewDataSource, 
																	LiteraturePlacementViewControllerDelegate> 
{
	UITableView *tableView;
	NSMutableArray *entries;
	
	NSIndexPath *selectedIndexPath;
}
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
