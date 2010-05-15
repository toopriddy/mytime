//
//  MetadataSortedCallsViewController.h
//  MyTime
//
//  Created by Brent Priddy on 6/14/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
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
