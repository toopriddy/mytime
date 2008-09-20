//
//  NumberedPickerView.h
//  MyTime
//
//  Created by Brent Priddy on 8/10/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NumberedPickerView : UIPickerView<UIPickerViewDelegate> {
	int _min;
	int _max;
	int number;
	
	UILabel *label;
}
@property (nonatomic) int number;
@property (nonatomic, retain) UILabel *label;

- (id) initWithFrame: (CGRect)rect min:(int)min max:(int)max;
- (id) initWithFrame: (CGRect)rect min:(int)min max:(int)max number:(int)initNumber title:(NSString *)title;

- (int)number;

@end
