//
//  NumberedPickerView.h
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
