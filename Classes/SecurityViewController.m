//
//  SecurityViewController.m
//  MyTime
//
//  Created by Brent Priddy on 2/4/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "SecurityViewController.h"
#import "PSLocalization.h"

@implementation SecurityInputView
@synthesize text1;
@synthesize text2;
@synthesize text3;
@synthesize text4;
@synthesize label;
@synthesize secondaryLabel;

- (void)reset
{
	self.text1.text = @"";
	self.text2.text = @"";
	self.text3.text = @"";
	self.text4.text = @"";
}
@end

@implementation SecurityViewController
@synthesize mainView;
@synthesize confirmView;
@synthesize input;
@synthesize confirmText;
@synthesize shouldConfirm;
@synthesize delegate;
@synthesize passcode;
@synthesize confirmPasscode;

- (void)viewWillAppear:(BOOL)animated
{
	currentView = self.mainView;
	[self.input becomeFirstResponder];
	mainView.label.text = self.promptText;
	mainView.secondaryLabel.text = self.secondaryPromptText;
	confirmView.secondaryLabel.text = self.secondaryPromptText;
}

- (NSString *)promptText
{
	return [[promptText retain] autorelease];
}

- (void)setPromptText:(NSString *)text
{
	[promptText release];
	promptText = [text copy];
	self.mainView.label.text = text;
}

- (NSString *)secondaryPromptText
{
	return [[secondaryPromptText retain] autorelease];
}

- (void)setSecondaryPromptText:(NSString *)text
{
	[secondaryPromptText release];
	secondaryPromptText = [text copy];
	self.mainView.secondaryLabel.text = text;
}

- (BOOL)validatePasscode:(NSString *)possiblePasscode
{
	// we need to check to see if this is correct
	if(self.passcode.length)
	{
		if([possiblePasscode isEqualToString:self.passcode])
		{
			[self.input resignFirstResponder];
			if(delegate && [delegate respondsToSelector:@selector(securityViewControllerDone:authenticated:)])
			{
				[self.delegate securityViewControllerDone:self authenticated:YES];
			}
		}
		else
		{
			// should implement a try again
			
			[self.input resignFirstResponder];
			if(delegate && [delegate respondsToSelector:@selector(securityViewControllerDone:authenticated:)])
			{
				[self.delegate securityViewControllerDone:self authenticated:NO];
			}
		}
	}
	else
	{
		if(self.shouldConfirm)
		{
			if(currentView == self.mainView)
			{
				self.confirmPasscode = possiblePasscode;
				self.input.text = @"";
				CGRect frame = self.mainView.frame;
				CGRect mainFrame = frame;
				frame.origin.x = frame.size.width;
				
				self.confirmView.label.text = self.confirmText;
				if([self.confirmView superview] == nil)
					[self.view addSubview:self.confirmView];
				self.confirmView.frame = frame;
				[self.confirmView reset];

				frame = mainFrame;
				mainFrame.origin.x = -frame.size.width;
				currentView = self.confirmView;
				[UIView beginAnimations:nil context:nil];
					[UIView setAnimationDuration:0.3];
					self.mainView.frame = mainFrame;
					self.confirmView.frame = frame;
				[UIView commitAnimations];
				
				return NO;
			}
			else
			{
				if([possiblePasscode isEqualToString:self.confirmPasscode])
				{
					self.passcode = possiblePasscode;
					[self.input resignFirstResponder];
					if(delegate && [delegate respondsToSelector:@selector(securityViewControllerDone:authenticated:)])
					{
						[self.delegate securityViewControllerDone:self authenticated:YES];
					}
				}
				else
				{
					self.input.text = @"";
					[self.mainView reset];
					CGRect frame = self.confirmView.frame;
					CGRect mainFrame = frame;
					frame.origin.x = frame.size.width;
					self.mainView.frame = frame;
					frame = mainFrame;
					frame.origin.x = -frame.size.width;
					
					currentView = self.mainView;
					currentView.secondaryLabel.text = NSLocalizedString(@"Passcodes did not match. Try again.", @"text that appears if the passcodes dont match, this should match what is in the iphone's Settings->General->Passcode when you messup the passcode confirm");
					[UIView beginAnimations:nil context:nil];
						[UIView setAnimationDuration:0.3];
						self.mainView.frame = mainFrame;
						self.confirmView.frame = frame;
					[UIView commitAnimations];
					
					return NO;
				}
			}
		}
		else
		{
			self.passcode = possiblePasscode;
			[self.input resignFirstResponder];
			if(delegate && [delegate respondsToSelector:@selector(securityViewControllerDone:authenticated:)])
			{
				[self.delegate securityViewControllerDone:self authenticated:YES];
			}
		}
	}
	return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
	NSString *theText = [textField.text stringByReplacingCharactersInRange:range withString:string];
	if(theText.length > 4)
	{
		return NO;
	}
	switch(theText.length)
	{
		case 4:
			currentView.text4.text = @".";
		case 3:
			currentView.text3.text = @".";
		case 2:
			currentView.text2.text = @".";
		case 1:
			currentView.text1.text = @".";
	}
	switch(theText.length)
	{
		case 0:
			currentView.text1.text = @"";
		case 1:
			currentView.text2.text = @"";
		case 2:
			currentView.text3.text = @"";
		case 3:
			currentView.text4.text = @"";
			break;
		case 4:
			return [self validatePasscode:theText];
	}
	return YES;
}


@end
