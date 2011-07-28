//
//  PSTextViewCellController.m
//  MyTime
//
//  Created by Brent Priddy on 12/29/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import "PSTextViewCellController.h"
#import "UITableViewMultilineTextCell.h"
#import "NotesViewController.h"

@implementation PSTextViewCellController
@synthesize placeholder;
@synthesize title;

- (void)notesViewControllerDone:(NotesViewController *)notesViewController
{
	[self.model setValue:[notesViewController notes] forKeyPath:self.modelPath];
	
	[self.tableViewController.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.selectedRow] withRowAnimation:UITableViewRowAnimationFade];
	[self.tableViewController.navigationController popViewControllerAnimated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [UITableViewMultilineTextCell heightForWidth:(tableView.bounds.size.width - 90) withText:[self.model valueForKeyPath:self.modelPath]];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSString *identifier = [[self class] description];
	UITableViewMultilineTextCell *cell = (UITableViewMultilineTextCell *)[tableView dequeueReusableCellWithIdentifier:identifier];
	if(cell == nil)
	{
		cell = [[[UITableViewMultilineTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier] autorelease];
	}
	
	NSString *notes = [self.model valueForKeyPath:self.modelPath];
	
	if([notes length] == 0)
		[cell setText:self.placeholder];
	else
		[cell setText:notes];
	
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.selectedRow = indexPath;
	
	// make the new call view 
	NotesViewController *p = [[[NotesViewController alloc] initWithNotes:[self.model valueForKeyPath:self.modelPath]] autorelease];
	p.title = self.title;
	p.delegate = self;
	[self.tableViewController.navigationController pushViewController:p animated:YES];		
	[self.tableViewController retainObject:self whileViewControllerIsManaged:p];
}
@end
