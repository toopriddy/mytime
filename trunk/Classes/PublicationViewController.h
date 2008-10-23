//
//  PublicationViewController.h
//  MyTime
//
//  Created by Brent Priddy on 8/9/08.
//  Copyright 2008 PG Software. All rights reserved.
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
- (id) initShowingCount:(BOOL)doShowCount filteredToType:(const NSString *)filter;
- (id) initWithPublication: (NSString *)publication year: (int)year month: (int)month day: (int)day;
- (id) initWithPublication: (NSString *)publication year: (int)year month: (int)month day: (int)day showCount:(BOOL)showCount number:(int)number;
- (id) initWithPublication: (NSString *)publication year: (int)year month: (int)month day: (int)day showCount:(BOOL)doShowCount number:(int)number filter:(const NSString *)filter;

- (void)navigationControlDone:(id)sender;

@end
