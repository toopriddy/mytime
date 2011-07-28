//
//  HourPickerView.m
//  MyTime
//
//  Created by Brent Priddy on 4/20/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "HourPickerView.h"
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CALayer.h>

@interface PickerLabelFadeInAnimation : NSObject
{
	UILabel *label;
	NSString *newText;
}
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) NSString *newText;
@end
@implementation PickerLabelFadeInAnimation
@synthesize label;
@synthesize newText;

- (id)initWithLabel:(UILabel *)theLabel newText:(NSString *)theText
{
	if( (self = [super init]) )
	{
		self.label = theLabel;
		self.newText = theText;
	}
	return self;
}

- (void)dealloc
{
	self.label = nil;
	self.newText = nil;
	[super dealloc];
}

- (void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
	if([finished boolValue])
	{
		[UIView beginAnimations:nil context:nil];
		self.label.alpha = 1;
		self.label.text = self.newText;
		[UIView commitAnimations];
	}
}
@end


@implementation HourPickerView
@synthesize minutes;
@synthesize hourLabel;
@synthesize minutesLabel;

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
	NSString *newText = nil;
	UILabel *changedLabel = nil;
	
	if(component == 0)
	{
		int oldHours = minutes/60;
		minutes = minutes % 60 + row * 60;
		int newHours = minutes/60;
		changedLabel = hourLabel;
		
		// do a cute little fade out/fade in animation when it changes from singular to plural like the countdown picker
		if(newHours == 1 && oldHours != 1)
		{
			newText = NSLocalizedString(@"hour", @"label used in the Statistics->Edit->press hours picker view");
		}
		else if(newHours != 1 && oldHours == 1)
		{
			newText = NSLocalizedString(@"hours", @"label used in the Statistics->Edit->press hours picker view");
		}
	}
	else if(component == 1)
	{
		int oldMinutes = minutes % 60;
		minutes = row + (minutes - oldMinutes);
		int newMinutes = minutes % 60;
		changedLabel = minutesLabel;
		
		// do a cute little fade out/fade in animation when it changes from singular to plural like the countdown picker
		if(newMinutes == 1 && oldMinutes != 1)
		{
			newText = NSLocalizedString(@"minute", @"label used in the Statistics->Edit->press hours picker view");
		}
		else if(newMinutes != 1 && oldMinutes == 1)
		{
			newText = NSLocalizedString(@"minutes", @"label used in the Statistics->Edit->press hours picker view");
		}
	}
	
	if(newText)
	{
		[UIView beginAnimations:nil context:nil];
		changedLabel.alpha = 0;
		[UIView setAnimationDelegate:[[[PickerLabelFadeInAnimation alloc] initWithLabel:changedLabel newText:newText] autorelease]];
		[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
		[UIView commitAnimations];
	}
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	if(component == 0)
		return 1000;
	return 60;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return([NSString stringWithFormat:@"%d", row]);
}

- (void)dealloc
{
	self.hourLabel = nil;
	self.minutesLabel = nil;
	
    [super dealloc];
}

- (id)initWithFrame:(CGRect)rect;
{
    return [self initWithFrame:rect minutes:0];
}

// initialize this view given the curent configuration
- (id)initWithFrame:(CGRect)rect minutes:(int)theMinutes;
{
    if((self = [super initWithFrame:CGRectZero])) 
    {
		self.showsSelectionIndicator = YES;
		minutes = theMinutes;
		
        // we are managing the picker's data and display
    	[self setDelegate:self];   
		
		[self selectRow:(minutes/60) inComponent:0 animated:NO];
		[self selectRow:(minutes%60) inComponent:1 animated:NO];
		
#define HOUR_LABEL_OFFSET 60.0
		CGRect contentRect = [self bounds];
		
		self.hourLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		hourLabel.font = [UIFont boldSystemFontOfSize:18];
		hourLabel.backgroundColor = [UIColor clearColor];
		hourLabel.shadowColor = [UIColor whiteColor];
		hourLabel.shadowOffset = CGSizeMake(0,1);
		if(minutes/60 == 1)
		{
			hourLabel.text = NSLocalizedString(@"hour", @"label used in the Statistics->Edit->press hours picker view");
		}
		else
		{
			hourLabel.text = NSLocalizedString(@"hours", @"label used in the Statistics->Edit->press hours picker view");
		}
		CGSize size = [hourLabel.text sizeWithFont:hourLabel.font];
		hourLabel.frame = CGRectMake(contentRect.origin.x + HOUR_LABEL_OFFSET, (contentRect.size.height - size.height)/2.0, size.width, size.height);

#define MINUTES_LABEL_OFFSET 320/2 + 40
		// now for minutes label
		self.minutesLabel = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
		minutesLabel.font = [UIFont boldSystemFontOfSize:18];
		minutesLabel.backgroundColor = [UIColor clearColor];
		minutesLabel.shadowColor = [UIColor whiteColor];
		minutesLabel.shadowOffset = CGSizeMake(0,1);
		if(minutes%60 == 1)
		{
			minutesLabel.text = NSLocalizedString(@"minute", @"label used in the Statistics->Edit->press hours picker view");
		}
		else
		{
			minutesLabel.text = NSLocalizedString(@"minutes", @"label used in the Statistics->Edit->press hours picker view");
		}
		size = [minutesLabel.text sizeWithFont:minutesLabel.font];
		minutesLabel.frame = CGRectMake(contentRect.origin.x + MINUTES_LABEL_OFFSET, (contentRect.size.height - size.height)/2.0, size.width, size.height);
		int i = 0;
		NSEnumerator *objectEnumerator = [[self subviews] objectEnumerator];
		for(UIView *view = [objectEnumerator nextObject]; view; view = [objectEnumerator nextObject])
		{
			i++;
			if(view.frame.size.height == 44)
			{
				[self insertSubview:hourLabel atIndex:i];
				i++; // advance over the one we just inserted
				break;
			}
		}
		for(UIView *view = [objectEnumerator nextObject]; view; view = [objectEnumerator nextObject])
		{
			i++;
			if(view.frame.size.height == 44)
			{
				[self insertSubview:minutesLabel atIndex:i];
				break;
			}
		}
		if(hourLabel.superview == nil)
		{
			[self addSubview:hourLabel];
		}
		if(minutesLabel.superview == nil)
		{
			[self addSubview:minutesLabel];
		}
	}
    
    return(self);
}

@end