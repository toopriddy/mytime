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
- (id) initWithFrame: (CGRect)rect min:(int)min max:(int)max number:(int)number;

- (int)number;

@end
