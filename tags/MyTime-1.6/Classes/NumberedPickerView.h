//
//  NumberedPickerView.h
//  MyTime
//
//  Created by Brent Priddy on 8/10/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NumberedPickerView : UIPickerView<UIPickerViewDelegate> {
	int _min;
	int _max;
	int number;
	NSString *_title;
	NSString *_singularTitle;
	
	UILabel *label;
}
@property (nonatomic) int number;
@property (nonatomic, retain) UILabel *label;

- (id) initWithFrame: (CGRect)rect min:(int)min max:(int)max;
- (id) initWithFrame: (CGRect)rect min:(int)min max:(int)max number:(int)initNumber singularTitle:(NSString *)singularTitle title:(NSString *)title;

- (int)number;

@end
