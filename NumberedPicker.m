//
//  NumberedPicker.m
//  MyTime
//
//  Created by Brent Priddy on 6/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "NumberedPicker.h"
#import "App.h"

@implementation NumberedPicker

- (void)pickerViewSelectionChanged: (UIPickerView*)p
{
    VERBOSE(NSLog(@"pickerViewSelectionChanged: ");)
	_number = [p selectedRowForColumn: 0] + _min;
}
	
// how many columns should be in the picker
- (int)numberOfColumnsInPickerView: (UIPickerView*)p
{
    return(1);
}

// given a column how many rows should be in the column
- (int) pickerView:(UIPickerView*)p numberOfRowsInColumn:(int)col
{
    VERY_VERBOSE(NSLog(@"pickerView: numberOfRowsInColumn: %d", col);)
	return(_max - _min + 1);
}

// given a column and a row get the cell for the table
- (id) pickerView:(UIPickerView*)p tableCellForRow:(int)row inColumn:(int)col
{
    VERY_VERBOSE(NSLog(@"pickerView: tableCellForRow: %d inColumn:%d", row, col);)
	id cell = [[[UIImageAndTextTableCell alloc] init] autorelease];
	
	[cell setAlignment: 2];
	[cell setTitle:[NSString stringWithFormat:@"%d", row + _min]];
	return(cell);
}
#if 0
-(float)pickerView:(UIPickerView*)p tableWidthForColumn: (int)col
{
}
#endif

	// set the Picker to the current data values
-(void)pickerViewLoaded: (UIPickerView*)p
{
    VERY_VERBOSE(NSLog(@"pickerViewLoaded: ");)
	[p selectRow:_number - _min inColumn: 0 animated: NO];
}

- (void) dealloc
{
    VERY_VERBOSE(NSLog(@"NumberedPicker: dealloc");)
    [super dealloc];
}

- (id) initWithFrame: (CGRect)rect min:(int)min max:(int)max
{
    return([self initWithFrame:rect min:min max:max number:1]);
}

// initialize this view given the curent configuration
- (id) initWithFrame: (CGRect)rect min:(int)min max:(int)max number:(int)number
{
	DEBUG(NSLog(@"NumberedPicker initWithFrame: min:(int)%d max:(int)%d number:(int)%d", min, max, number);)
    if((self = [super initWithFrame: rect])) 
    {
		_min = min;
		_max = max;
		_number = number;
		
        // we are managing the picker's data and display
    	[self setDelegate: self];   
    }
    
    return(self);
}

// year of our common era
- (int)number
{
    return(_number);
}




- (BOOL)respondsToSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"NumberedPicker respondsToSelector: %s", selector);)
    return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"NumberedPicker methodSignatureForSelector: %s", selector);)
    return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    VERY_VERBOSE(NSLog(@"NumberedPicker forwardInvocation: %s", [invocation selector]);)
    [super forwardInvocation:invocation];
}



@end
