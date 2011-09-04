//
//  PSMultiTextFieldCellController.m
//  MyTime
//
//  Created by Brent Priddy on 8/31/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import "PSMultiTextFieldCellController.h"

@interface PSMultiTextFieldConfiguration ()
@property (nonatomic, assign, readwrite) PSMultiTextFieldCellController *parent;
@property (nonatomic, retain, readwrite) UITextField *textField;
@end


@implementation PSMultiTextFieldConfiguration
@synthesize parent;
@synthesize textField;
@synthesize placeholder;
@synthesize returnKeyType;
@synthesize keyboardType;
@synthesize clearButtonMode;
@synthesize autocapitalizationType;
@synthesize obtainFocus;
@synthesize autocorrectionType;
@synthesize rightView;
@synthesize rightViewMode;
@synthesize widthPercentage;
@synthesize model;
@synthesize modelPath;

- (void)dealloc
{
	self.parent = nil;
	self.textField = nil;
	self.rightView = nil;
	self.placeholder = nil;
	self.rightView = nil;
	self.model = nil;
	self.modelPath = nil;

	[super dealloc];
}

- (void)handleTextFieldChanged:(NSNotification *)note 
{
	[self.model setValue:self.textField.text forKeyPath:self.modelPath];
	
	if(textChangedTarget_)
	{
		NSInvocation * invocation = [NSInvocation invocationWithMethodSignature:[textChangedTarget_ methodSignatureForSelector:textChangedAction_]];
		[invocation setTarget:textChangedTarget_];
		[invocation setSelector:textChangedAction_];
		[invocation setArgument:&self atIndex:2];
		NSString *text = self.textField.text;
		[invocation setArgument:&text atIndex:3];
		[invocation invoke];
	}
}

- (void)setTextChangedTarget:(id)target action:(SEL)action
{
	textChangedTarget_ = target;
	textChangedAction_ = action;
}


@end


@interface PSMultiTextFieldCellController ()
@property (nonatomic, retain, readwrite) NSArray *textFieldConfigurations;
@end


@implementation PSMultiTextFieldCellController
@synthesize textFieldConfigurations;
@synthesize allTextFields;
@synthesize allowSelectionWhenNotEditing;
@synthesize scrollPosition;

- (id)init
{
	return [self initWithTextFieldCount:1];
}

- (id)initWithTextFieldCount:(int)count
{
	if( (self = [super init]) )
	{
		NSMutableArray *array = [NSMutableArray arrayWithCapacity:count];
		self.textFieldConfigurations = array;
		for(int i = 0; i < count; ++i)
		{
			PSMultiTextFieldConfiguration *config = [[PSMultiTextFieldConfiguration alloc] init];
			config.parent = self;
			[array addObject:config];
			[config release];
		}
		self.allowSelectionWhenNotEditing = YES;
	}
	return self;
}

- (void)dealloc
{
	for(PSMultiTextFieldConfiguration *config in self.textFieldConfigurations)
	{
		if(config.textField)
		{
			config.textField.delegate = nil;
			[[NSNotificationCenter defaultCenter] removeObserver:config
															name:UITextFieldTextDidChangeNotification
														  object:config.textField];
			
			[self.allTextFields removeObject:config.textField];
			config.textField = nil;
		}
		config.parent = nil;
	}
	self.textFieldConfigurations = nil;
	self.allTextFields = nil;
	
	[super dealloc];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	for(PSMultiTextFieldConfiguration *config in self.textFieldConfigurations)
	{
		if(config.textField)
		{
			[[NSNotificationCenter defaultCenter] removeObserver:config
															name:UITextFieldTextDidChangeNotification
														  object:config.textField];
			
			[self.allTextFields removeObject:config.textField];
			if(config.rightView)
			{
				config.textField.rightView = nil;
			}
			config.textField = nil;
		}
	}
	NSString *commonIdentifier = [[self class] description];
	UITableViewMultiTextFieldCell *cell = (UITableViewMultiTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:commonIdentifier];
	if(cell == nil)
	{
		cell = [[[UITableViewMultiTextFieldCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:commonIdentifier textFieldCount:self.textFieldConfigurations.count] autorelease];
	}
	cell.widths = [self.textFieldConfigurations valueForKey:@"widthPercentage"];
	int index = 0;
	for(PSMultiTextFieldConfiguration *config in self.textFieldConfigurations)
	{
		
		config.textField = [cell textFieldAtIndex:index++];
	
		if(config.rightView)
		{
			config.textField.rightView = config.rightView;
			config.textField.rightViewMode = config.rightViewMode;
		}
		
		config.textField.placeholder = config.placeholder;
		config.textField.returnKeyType = config.returnKeyType;
		config.textField.clearButtonMode = config.clearButtonMode;
		config.textField.autocapitalizationType = config.autocapitalizationType;
		config.textField.autocorrectionType = config.autocorrectionType;
		[[NSNotificationCenter defaultCenter] addObserver:config
												 selector:@selector(handleTextFieldChanged:)
													 name:UITextFieldTextDidChangeNotification
												   object:config.textField];
		[self.allTextFields addObject:config.textField];
		config.textField.text = [config.model valueForKeyPath:config.modelPath];
		if(config.obtainFocus)
		{
			[config.textField performSelector:@selector(becomeFirstResponder)
								   withObject:nil
								   afterDelay:0.0000001];
			config.obtainFocus = NO;
		}
	}	
	cell.delegate = self;
	cell.allowSelectionWhenEditing = self.allowSelectionWhenNotEditing;
	cell.nextKeyboardResponder = [self nextRowResponderForTableView:tableView indexPath:indexPath];
	cell.selectionStyle = self.selectionStyle;
	
	return cell;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[[(UITableViewMultiTextFieldCell *)[tableView cellForRowAtIndexPath:indexPath] textFieldAtIndex:0] becomeFirstResponder];
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (void)tableViewMultiTextFieldCell:(UITableViewMultiTextFieldCell *)cell textField:(UITextField *)textField selected:(BOOL)selected
{
	// it is only house number and apartment cell that uses this one, so lets scroll to the middle so that we will scroll up if this cell is selected
	if(self.scrollPosition != UITableViewScrollPositionNone)
	{
		NSIndexPath *indexPath = [self.tableViewController.tableView indexPathForCell:cell];
		[self.tableViewController.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
	}
}

@end
