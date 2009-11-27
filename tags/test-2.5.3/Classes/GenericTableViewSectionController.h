//
//  GenericTableViewSectionController.h
//  MyTime
//
//  Created by Brent Priddy on 10/11/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "TableViewSectionController.h"

@interface GenericTableViewSectionController : NSObject<TableViewSectionController>
{
@private	
	NSString *_title;
	NSString *_footer;
	NSMutableArray *_cellControllers;
	NSMutableArray *_displayCellControllers;
	BOOL isViewableWhenEditing;
	BOOL isViewableWhenNotEditing;
}
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *footer;
@property (nonatomic, retain) NSMutableArray *cellControllers;
@property (nonatomic, retain) NSMutableArray *displayCellControllers;
@property (nonatomic, assign) BOOL isViewableWhenEditing;
@property (nonatomic, assign) BOOL isViewableWhenNotEditing;

- (id)init;

// from TableViewSectionController
- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section;
- (NSObject<TableViewCellController> *)tableView:(UITableView *)tableView cellControllerAtIndexPath:(NSIndexPath *)indexPath;
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section;    // fixed font style. use custom view (UILabel) if you want something different

@end
