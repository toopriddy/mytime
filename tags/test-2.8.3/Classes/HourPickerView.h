//
//  HourPickerView.h
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
