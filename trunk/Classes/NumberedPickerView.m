//
//  NumberedPickerView.m
//  MyTime
//
//  Created by Brent Priddy on 8/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NumberedPickerView.h"
#import "Settings.h"

@implementation NumberedPickerView
@synthesize number;
@synthesize label;

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    VERBOSE(NSLog(@"pickerView didSelectRow:%d ", row);)
	number = row + _min;
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
    [super dealloc];
}

- (id)initWithFrame: (CGRect)rect min:(int)min max:(int)max
{
    return([self initWithFrame:rect min:min max:max number:min title:nil]);
}

// initialize this view given the curent configuration
- (id) initWithFrame: (CGRect)rect min:(int)min max:(int)max number:(int)initNumber title:(NSString *)title;
{
	DEBUG(NSLog(@"NumberedPicker initWithFrame: min:(int)%d max:(int)%d number:(int)%d", min, max, initNumber);)
    if((self = [super initWithFrame: CGRectZero])) 
    {
		label = nil;
		_min = min;
		_max = max;
		if(initNumber >= _min && initNumber <= _max)
			number = initNumber;
		else
			number = _min;
		self.showsSelectionIndicator = YES;

        // we are managing the picker's data and display
    	[self setDelegate: self];   

		[self selectRow:(number - _min) inComponent:0 animated: NO];

		if(title != nil && ![title isEqualToString:@""])
		{
			#define LABEL_OFFSET 60.0
			CGRect contentRect = [self bounds];

			self.label = [[[UILabel alloc] initWithFrame:CGRectZero] autorelease];
			label.backgroundColor = [UIColor clearColor];
			label.font = [UIFont boldSystemFontOfSize:18];
			CGSize size = [title sizeWithFont:label.font];
			label.frame = CGRectMake(contentRect.origin.x + LABEL_OFFSET, (contentRect.size.height - size.height)/2.0, contentRect.size.width, size.height);
			label.text = title;
			
			
			[self addSubview:label];
		}
    }
    
    return(self);
}

//	return(NSLocalizedString(@"Count:", @"'Count' label for Number Picker; this is the label that is beside the number in the picker"));

- (BOOL)respondsToSelector:(SEL)selector
{
	BOOL ret = [super respondsToSelector:selector];
    VERY_VERBOSE(NSLog(@"%s respondsToSelector: %s ? %s", __FILE__, selector, ret ? "YES" : "NO");)
    return ret;
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"%s methodSignatureForSelector: %s", __FILE__, selector);)
    return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    VERY_VERBOSE(NSLog(@"%s forwardInvocation: %s", __FILE__, [invocation selector]);)
    [super forwardInvocation:invocation];
}

@end