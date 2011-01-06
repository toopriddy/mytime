//
//  PublicationViewController.h
//  MyTime
//
//  Created by Brent Priddy on 8/9/08.
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
#import "PublicationViewControllerDelegate.h"
#import "PublicationPickerView.h"
#import "NumberedPickerView.h"

@interface  PublicationViewController : UIViewController 
{
	PublicationPickerView *publicationPicker;
	NumberedPickerView *countPicker;
	UIView *containerView;
	
	BOOL showCount;
	
	id<PublicationViewControllerDelegate> delegate;
}

@property (nonatomic, retain) PublicationPickerView *publicationPicker;
@property (nonatomic, retain) NumberedPickerView *countPicker;
@property (nonatomic, retain) UIView *containerView;
@property (nonatomic, assign) id<PublicationViewControllerDelegate> delegate;

/**
 * initialize this view 
 *
 * @param rect - the rect
 * @returns self
 */
- (id) init;
- (id) initShowingCount:(BOOL)showCount;
- (id) initShowingCount:(BOOL)doShowCount filteredToType:(NSString *)filter;
- (id) initWithPublication: (NSString *)publication year: (int)year month: (int)month day: (int)day;
- (id) initWithPublication: (NSString *)publication year: (int)year month: (int)month day: (int)day showCount:(BOOL)showCount number:(int)number;
- (id) initWithPublication: (NSString *)publication year: (int)year month: (int)month day: (int)day showCount:(BOOL)doShowCount number:(int)number filter:(NSString *)filter;

/**
 * @return number of publications
 */
- (int)count;

- (void)navigationControlDone:(id)sender;

@end
