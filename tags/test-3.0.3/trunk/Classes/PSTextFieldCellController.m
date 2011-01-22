//
//  PSTextFieldCell.m
//  MyTime
//
//  Created by Brent Priddy on 12/29/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import "PSTextFieldCellController.h"

@interface PSTextFieldCellController ()
@property (nonatomic, retain) UITextField *textField;
@end

@implementation PSTextFieldCellController
@synthesize textField;
@synthesize placeholder;
@synthesize returnKeyType;
@synthesize clearButtonMode;
@synthesize autocapitalizationType;
@synthesize obtainFocus;
@synthesize allTextFields;
@synthesize autocorrectionType;

- (void)dealloc
{
	if(self.textField)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:UITextFieldTextDidChangeNotification
													  object:self.textField];
		
		[self.allTextFields removeObject:self.textField];
		self.textField = nil;
	}
	self.model = nil;
	self.modelPath = nil;
	
	[super dealloc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(self.textField)
	{
		[[NSNotificationCenter defaultCenter] removeObserver:self
														name:UITextFieldTextDidChangeNotification
													  object:self.textField];
		
		[self.allTextFields removeObject:self.textField];
		self.textField = nil;
	}
	NSString *commonIdentifier = [[self class] description];
	UITableViewTextFieldCell *cell = (UITableViewTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier] autorelease];
	}
	self.textField = cell.textField;

	cell.textField.placeholder = self.placeholder;
	cell.textField.returnKeyType = self.returnKeyType;
	cell.textField.clearButtonMode = self.clearButtonMode;
	cell.textField.autocapitalizationType = self.autocapitalizationType;
	cell.textField.autocorrectionType = self.autocorrectionType;
	cell.selectionStyle = self.selectionStyle;
	cell.nextKeyboardResponder = [self nextRowResponderForTableView:tableView indexPath:indexPath];

	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(handleTextFieldChanged:)
                                                 name:UITextFieldTextDidChangeNotification
                                               object:self.textField];
	[self.allTextFields addObject:self.textField];
	cell.textField.text = [self.model valueForKeyPath:self.modelPath];
	if(self.title)
		cell.titleLabel.text = self.title;
	cell.delegate = self;
	if(self.obtainFocus)
	{
		[cell.textField performSelector:@selector(becomeFirstResponder)
							 withObject:nil
							 afterDelay:0.0000001];
		self.obtainFocus = NO;
	}
	
	return cell;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[[(UITableViewTextFieldCell *)[tableView cellForRowAtIndexPath:indexPath] textField] becomeFirstResponder];
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableViewTextFieldCell:(UITableViewTextFieldCell *)cell selected:(BOOL)selected
{
}

- (void)handleTextFieldChanged:(NSNotification *)note 
{
	[self.model setValue:self.textField.text forKeyPath:self.modelPath];
}
@end
