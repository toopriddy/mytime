//
//  NumberedPickerView.m
//  MyTime
//
//  Created by Brent Priddy on 8/10/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "NumberedPickerView.h"
#import "Settings.h"
#import <QuartzCore/QuartzCore.h>
#import <QuartzCore/CALayer.h>

@interface NumberPickerLabelFadeInAnimation : NSObject
{
	UILabel *label;
	NSString *newText;
}
@property (nonatomic, retain) UILabel *label;
@property (nonatomic, retain) NSString *newText;
@end
@implementation NumberPickerLabelFadeInAnimation
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

@implementation NumberedPickerView
@synthesize number;
@synthesize label;

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    VERBOSE(NSLog(@"pickerView didSelectRow:%d ", row);)
	int oldNumber = number;
	number = row + _min;
	if(_singularTitle && _title)
	{
		if(titlesAreDifferent)
		{
			// do a cute little fade out/fade in animation when it changes from singular to plural like the countdown picker
			BOOL changed = false;
			if(number == 1 && oldNumber != 1)
			{
				changed = YES;
				_newTitle = _singularTitle;
			}
			else if(number != 1 && oldNumber == 1)
			{
				changed = YES;
				_newTitle = _title;
			}
			
			if(changed)
			{
				[UIView beginAnimations:nil context:nil];
				label.alpha = 0;
				[UIView setAnimationDelegate:[[[NumberPickerLabelFadeInAnimation alloc] initWithLabel:label newText:_newTitle] autorelease]];
				[UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
				[UIView commitAnimations];
			}
		}
	}
}
	
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return(1);
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    VERY_VERBOSE(NSLog(@"pickerView: numberOfRowsInComponent: %d", component);)
	return(_max - _min + 1);
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
	return([NSString stringWithFormat:@"%d", row + _min]);
}

- (void)dealloc
{
    VERY_VERBOSE(NSLog(@"NumberedPicker: dealloc");)
	self.label = nil;
	[_title release];
	[_singularTitle release];
    [super dealloc];
}

- (id)initWithFrame: (CGRect)rect min:(int)min max:(int)max
{
    return([self initWithFrame:rect min:min max:max number:min singularTitle:nil title:nil]);
}

// initialize this view given the curent configuration
- (id) initWithFrame: (CGRect)rect min:(int)min max:(int)max number:(int)initNumber singularTitle:(NSString *)singularTitle title:(NSString *)title;
{
	DEBUG(NSLog(@"NumberedPicker initWithFrame: min:(int)%d max:(int)%d number:(int)%d", min, max, initNumber);)
    if((self = [super initWithFrame: CGRectZero])) 
    {
		label = nil;
		_min = min;
		_max = max;
		_title = nil;
		_singularTitle = nil;

		if(initNumber >= _min && initNumber <= _max)
			number = initNumber;
		else
			number = _min;
		self.showsSelectionIndicator = YES;

        // we are managing the picker's data and display
    	[self setDelegate: self];   

		[self selectRow:(number - _min) inComponent:0 animated: NO];

		if(title != nil && ![title isEqualToString:@""] && 
		   singularTitle != nil && ![singularTitle isEqualToString:@""])
		{
			_title = [[NSString alloc] initWithString:title];
			_singularTitle = [[NSString alloc] initWithString:singularTitle];
			#define LABEL_OFFSET 60.0
			CGRect contentRect = [self bounds];
			
			titlesAreDifferent = ![title isEqualToString:singularTitle];
			
			self.label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
			label.font = [UIFont boldSystemFontOfSize:18];
			label.backgroundColor = [UIColor clearColor];
			label.shadowColor = [UIColor whiteColor];
			label.shadowOffset = CGSizeMake(0,1);
			CGSize size = [title sizeWithFont:label.font];
			label.frame = CGRectMake(contentRect.origin.x + LABEL_OFFSET, (contentRect.size.height - size.height)/2.0, contentRect.size.width, size.height);
			if(number == 1)
				label.text = _singularTitle;
			else
				label.text = _title;
			
			int i = 0;
			for(UIView *view in [self subviews])
			{
				i++;
				if(view.frame.size.height == 44)
				{
					[self insertSubview:label atIndex:i];
					break;
				}
			}
			if(label.superview == nil)
				[self addSubview:label];
		}
    }
    
    return(self);
}

@end