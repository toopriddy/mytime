//
//  PSButtonCellController.m
//  MyTime
//
//  Created by Brent Priddy on 1/30/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import "PSButtonCellController.h"
#import "UITableViewButtonCell.h"

@implementation PSButtonCellController
@synthesize image;
@synthesize imagePressed;
@synthesize imageName;
@synthesize imagePressedName;
@synthesize darkTextColor;

- (void)dealloc
{
	self.image = nil;
	self.imagePressed = nil;
	self.imageName = nil;
	self.imagePressedName = nil;
	
	[super dealloc];
}

- (void)setButtonTarget:(id)target action:(SEL)action
{
	buttonTarget_ = target;
	buttonAction_ = action;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewButtonCell *cell;
	NSString *buttonTitle = self.title;
	if([buttonTitle length] == 0)
	{
		buttonTitle = [self.model valueForKeyPath:self.modelPath];
	}
	UIImage *normalImage = self.image;
	if(normalImage == nil)
	{
		normalImage = [UIImage imageNamed:self.imageName];
	}
	
	UIImage *pressedImage = self.imagePressed;
	if(pressedImage == nil)
	{
		pressedImage = [UIImage imageNamed:self.imagePressedName];
	}
	
	cell = [[[UITableViewButtonCell alloc ] initWithTitle:buttonTitle
													image:normalImage
											 imagePressed:pressedImage
											darkTextColor:self.darkTextColor
										  reuseIdentifier:nil] autorelease];
	[cell.button addTarget:buttonTarget_ action:buttonAction_ forControlEvents:UIControlEventTouchUpInside];
	return cell;
}

@end
