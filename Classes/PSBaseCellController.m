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
//@synthesize navigationController;
@synthesize tableViewController;
@synthesize selectedRow;
@synthesize nextRowResponder;
@synthesize selectNextRowResponderIncrement;

- (void)dealloc
{
	self.title = nil;
	self.model = nil;
	self.modelPath = nil;
//	self.navigationController = nil;
	self.tableViewController = nil;
	self.selectedRow = nil;
	
	[super dealloc];
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

@end
