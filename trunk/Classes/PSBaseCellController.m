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
@property (nonatomic, retain) UITableView *tableView;
@property (nonatomic, retain) NSIndexPath *indexPath;

- (id)initWithTable:(UITableView *)theTableView indexPath:(NSIndexPath *)theIndexPath;
@end

@implementation PSSelectRowNextResponder
@synthesize tableView;
@synthesize indexPath;

- (void)dealloc
{
	self.tableView = nil;
	self.indexPath = nil;
	[super dealloc];
}

- (id)initWithTable:(UITableView *)theTableView indexPath:(NSIndexPath *)theIndexPath
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	if((self = [super init]))
	{
		self.tableView = theTableView;
		self.indexPath = theIndexPath;
	}
	return self;
}

- (BOOL)becomeFirstResponder 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	[self.tableView deselectRowAtIndexPath:nil animated:NO];
	[self.tableView selectRowAtIndexPath:self.indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
	[self.tableView.delegate tableView:self.tableView didSelectRowAtIndexPath:self.indexPath];
	return NO;
}
@end



@interface PSBaseCellController ()
@property (nonatomic, retain) PSSelectRowNextResponder *nextRowResponder;
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
@synthesize movable;
@synthesize movableWhileEditing;
@synthesize isViewableWhenEditing;
@synthesize isViewableWhenNotEditing;
@synthesize userData;

- (id)init
{
	if ( (self = [super init]) )
	{
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
	if(self.selectNextRowResponderIncrement == 0)
	{
		self.nextRowResponder = nil;
		return nil;
	}
	
	if(self.nextRowResponder == nil)
	{
		self.nextRowResponder = [[[PSSelectRowNextResponder alloc] initWithTable:tableView indexPath:[NSIndexPath indexPathForRow:indexPath.row+self.selectNextRowResponderIncrement inSection:indexPath.section]] autorelease];
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
