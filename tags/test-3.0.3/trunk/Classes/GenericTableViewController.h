//
//  GenericTableViewController.h
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

#import <UIKit/UIKit.h>
#import "GenericTableViewSectionController.h"

@interface GenericTableViewController : UITableViewController
{
@private	
	NSMutableArray *_sectionControllers;
	NSMutableArray *_displaySectionControllers;
	BOOL _editing;
	BOOL _forceReload;
	NSMutableArray *_retainedObjectsAndViewControllers;
	BOOL _viewControllerCheckerRunning;
}
@property (nonatomic, retain) NSMutableArray *sectionControllers;
@property (nonatomic, assign) BOOL editing;
@property (nonatomic, readonly, retain) NSMutableArray *displaySectionControllers;
@property (nonatomic, assign) BOOL forceReload;

- (id)initWithStyle:(UITableViewStyle)style;

- (void)constructSectionControllers;
- (void)updateAndReload;
- (void)updateWithoutReload;
- (void)updateTableViewInsideUpdateBlockWithDeleteRowAnimation:(UITableViewRowAnimation)deleteAnimation insertAnimation:(UITableViewRowAnimation)insertAnimation;

- (void)deleteDisplayRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)deleteDisplaySectionAtIndexPath:(NSIndexPath *)indexPath;
- (void)replaceDisplaySectionAtIndexPath:(NSIndexPath *)indexPath withSection:(GenericTableViewSectionController *)newSectionController;
- (void)addSectionAfterSection:(GenericTableViewSectionController *)sectionController newSection:(GenericTableViewSectionController *)newSectionController;

- (void)retainObject:(NSObject *)object whileViewControllerIsManaged:(UIViewController *)viewController;

@end

@interface URLCellController : NSObject<TableViewCellController>
{
	NSURL *ps_url;
	NSString *ps_title;
}
@property (nonatomic, retain) NSURL *url;
@property (nonatomic, retain) NSString *title;
- (id)initWithTitle:(NSString *)title;
- (id)initWithTitle:(NSString *)title URL:(NSURL *)url;
@end

@interface TitleValueCellController : NSObject<TableViewCellController>
{
	NSString *ps_title;
	NSString *ps_value;
}
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *value;
- (id)initWithTitle:(NSString *)title;
- (id)initWithTitle:(NSString *)title value:(NSString *)value;
@end

