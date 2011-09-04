//
//  PSBaseCellController.m
//  MyTime
//
//  Created by Brent Priddy on 12/29/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import "PSBaseCellController.h"

@interface PSSelectRowNextResponder : UIResponder
{
}
@property (nonatomic, assign) GenericTableViewController *tableViewController;
@property (nonatomic, copy) NSIndexPath *incrementIndexPath;
@property (nonatomic, assign) NSObject <TableViewCellController> *cellController;

- (id)initWithGenericTableViewController:(GenericTableViewController *)tableViewController cellController:(NSObject <TableViewCellController> *)cellController incrementIndexPath:(NSIndexPath *)incrementIndexPath;
@end

@implementation PSSelectRowNextResponder
@synthesize tableViewController;
@synthesize incrementIndexPath;
@synthesize cellController;

- (void)dealloc
{
	self.incrementIndexPath = nil;
	[super dealloc];
}

- (id)initWithGenericTableViewController:(GenericTableViewController *)theTableViewController cellController:(NSObject <TableViewCellController> *)theCellController incrementIndexPath:(NSIndexPath *)theIncrementIndexPath
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	if((self = [super init]))
	{
		assert(theTableViewController != nil);
		assert(theCellController != nil);
		assert(theIncrementIndexPath != nil);
		self.tableViewController = theTableViewController;
		self.cellController = theCellController;
		self.incrementIndexPath = theIncrementIndexPath;
	}
	return self;
}

- (BOOL)becomeFirstResponder 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	[self.tableViewController.tableView deselectRowAtIndexPath:nil animated:NO];
	NSIndexPath *currentIndexPath = [self.tableViewController indexPathOfDisplayCellController:self.cellController];
	int row = currentIndexPath.row + incrementIndexPath.row;
	if(incrementIndexPath.section)
		row = incrementIndexPath.row;
	int section = currentIndexPath.section + incrementIndexPath.section;
	NSIndexPath *newIndexPath = [NSIndexPath indexPathForRow:row inSection:section];
	[self.tableViewController.tableView selectRowAtIndexPath:newIndexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
	[self.tableViewController.tableView.delegate tableView:self.tableViewController.tableView didSelectRowAtIndexPath:newIndexPath];
	return NO;
}
@end



@interface PSBaseCellController ()
@end


@implementation PSBaseCellController
@synthesize title;
@synthesize model = model_;
@synthesize modelPath = modelPath_;
@synthesize indentWhileEditing;
@synthesize editingStyle;
@synthesize selectionStyle;
@synthesize accessoryType;
@synthesize editingAccessoryType;
@synthesize accessoryView;
@synthesize editingAccessoryView;
//@synthesize navigationController;
@synthesize tableViewController;
@synthesize selectedRow;
@synthesize nextRowResponder;
@synthesize selectNextRowResponderIncrement;
@synthesize selectNextSectionResponderIncrement;
@synthesize rowHeight;
@synthesize movable;
@synthesize movableWhileEditing;
@synthesize isViewableWhenEditing;
@synthesize isViewableWhenNotEditing;
@synthesize userData;

- (id)init
{
	if ( (self = [super init]) )
	{
		rowHeight = -1;
		isViewableWhenEditing = YES;
		isViewableWhenNotEditing = YES;
		indentWhileEditing = YES;
		self.selectionStyle = UITableViewCellSelectionStyleBlue;
	}
	return self;
}

- (void)dealloc
{
	self.title = nil;
	[model_ release];
	model_ = nil;
	[modelPath_ release];
	modelPath_ = nil;
//	self.navigationController = nil;
	self.tableViewController = nil;
	self.selectedRow = nil;
	self.accessoryView = nil;
	self.editingAccessoryView = nil;
	self.userData = nil;
	
	[super dealloc];
}

- (void)setSelectionTarget:(id)target action:(SEL)action
{
	selectionTarget_ = target;
	selectionAction_ = action;
}

- (void)setDeleteTarget:(id)target action:(SEL)action
{
	deleteTarget_ = target;
	deleteAction_ = action;
}

- (void)setInsertTarget:(id)target action:(SEL)action
{
	insertTarget_ = target;
	insertAction_ = action;
}

- (UIResponder *)nextRowResponderForTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath
{
	if(self.nextRowResponder == nil)
	{
		if(self.selectNextRowResponderIncrement == 0 && self.selectNextSectionResponderIncrement == 0)
		{
			return nil;
		}
		
		self.nextRowResponder = [[[PSSelectRowNextResponder alloc] initWithGenericTableViewController:self.tableViewController cellController:self incrementIndexPath:[NSIndexPath indexPathForRow:self.selectNextRowResponderIncrement inSection:self.selectNextSectionResponderIncrement]] autorelease];
	}
	
	return self.nextRowResponder;
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(tableView.editing)
	{
		return self.movableWhileEditing;
	}
	else
	{
		return self.movable;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(self.rowHeight >= 0)
	{
		return self.rowHeight;
	}
	else
	{
		return tableView.rowHeight;
	}
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return self.indentWhileEditing;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return self.editingStyle;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// you should implement your own
	assert(false);
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)theEditingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(theEditingStyle == UITableViewCellEditingStyleDelete && deleteTarget_)
	{
		NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:[deleteTarget_ methodSignatureForSelector:deleteAction_]];
		[invocation setTarget:deleteTarget_];
		[invocation setSelector:deleteAction_];
		[invocation setArgument:&self atIndex:2];
		[invocation setArgument:&tableView atIndex:3];
		[invocation setArgument:&indexPath atIndex:4];
		[invocation invoke];
	}
	else if(theEditingStyle == UITableViewCellEditingStyleInsert && insertTarget_)
	{
		NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:[insertTarget_ methodSignatureForSelector:insertAction_]];
		[invocation setTarget:insertTarget_];
		[invocation setSelector:insertAction_];
		[invocation setArgument:&self atIndex:2];
		[invocation setArgument:&tableView atIndex:3];
		[invocation setArgument:&indexPath atIndex:4];
		[invocation invoke];
	}
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(selectionTarget_)
	{
		NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:[selectionTarget_ methodSignatureForSelector:selectionAction_]];
		[invocation setTarget:selectionTarget_];
		[invocation setSelector:selectionAction_];
		[invocation setArgument:&self atIndex:2];
		[invocation setArgument:&tableView atIndex:3];
		[invocation setArgument:&indexPath atIndex:4];
		[invocation invoke];
	}
}

@end
