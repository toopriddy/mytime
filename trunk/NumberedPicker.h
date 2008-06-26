//
//  NumberedPicker.h
//  MyTime
//
//  Created by Brent Priddy on 6/22/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <UIKit/UIPickerView.h>

@interface NumberedPicker : UIPickerView {
	int _min;
	int _max;
	int _number;
}

- (id) initWithFrame: (CGRect)rect min:(int)min max:(int)max;
- (id) initWithFrame: (CGRect)rect min:(int)min max:(int)max number:(int)number title:(NSString *)title;

- (int)number;

- (NSString *)pickerView:(UIPickerView *)picker titleForRow:(int)row inColumn:(int)column;
- (void)pickerViewSelectionChanged: (UIPickerView*)p;
- (int)numberOfColumnsInPickerView: (UIPickerView*)p;
- (int) pickerView:(UIPickerView*)p numberOfRowsInColumn:(int)col;
- (id) pickerView:(UIPickerView*)p tableCellForRow:(int)row inColumn:(int)col;
-(void)pickerViewLoaded: (UIPickerView*)p;


@end
