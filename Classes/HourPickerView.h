//
//  HourPickerView.h
//  MyTime
//
//  Created by Brent Priddy on 4/20/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface HourPickerView : UIPickerView<UIPickerViewDelegate> 
{
	int minutes;
	UILabel *hourLabel;
	UILabel *minutesLabel;
}
@property (nonatomic) int minutes;
@property (nonatomic, retain) UILabel *hourLabel;
@property (nonatomic, retain) UILabel *minutesLabel;

- (id)initWithFrame:(CGRect)rect;
- (id)initWithFrame:(CGRect)rect minutes:(int)minutes;

- (int)minutes;

@end
