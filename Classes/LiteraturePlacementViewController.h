//
//  LiteraturePlacementViewController.h
//  MyTime
//
//  Created by Brent Priddy on 8/15/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PublicationViewControllerDelegate.h"
#import "DatePickerViewControllerDelegate.h"
#import "LiteraturePlacementViewControllerDelegate.h"

@interface LiteraturePlacementViewController : UIViewController <UITableViewDelegate, 
                                                                    UITableViewDataSource, 
																	PublicationViewControllerDelegate,
																	DatePickerViewControllerDelegate> 
{
	UITableView *tableView;
	NSMutableDictionary *placements;
	
	NSIndexPath *selectedIndexPath;
	
	id<LiteraturePlacementViewControllerDelegate> delegate;
}
@property (nonatomic,retain) UITableView *tableView;
@property (nonatomic,retain) NSMutableDictionary *placements;
@property (nonatomic,retain) NSIndexPath *selectedIndexPath;
@property (nonatomic,retain) id<LiteraturePlacementViewControllerDelegate> delegate;

/**
 * initialize this view with a watchtower at the current month/year
 *
 * @param rect - the rect
 * @returns self
 */
- (id)init;
- (id)initWithPlacements:(NSMutableDictionary *)placements;
- (void)dealloc;

/**
 * get the placements from this view
 * @return placements from this view
 */
- (NSMutableDictionary *)placements;
 
@end