//
//  MetadataSortedCallsViewController.h
//  MyTime
//
//  Created by Brent Priddy on 6/14/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SortedCallsViewController.h"
#import "MetadataPickerViewController.h"
#import "OverlayViewController.h"

@interface MetadataSortedCallsViewController : SortedCallsViewController <MetadataPickerViewDelegate, OverlayViewControllerDelegate>
{
	OverlayViewController *_overlay;
	MetadataPickerViewController *_picker;
	BOOL _myOverlay;
}
@property(nonatomic, retain) MetadataPickerViewController *picker;

@end
