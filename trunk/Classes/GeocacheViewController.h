//
//  MapViewController.h
//  MyTime
//
//  Created by Brent Priddy on 8/30/08.
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
#import "MapView.h"
#import "MTCall.h"

@class GeocacheViewController;
@protocol GeocacheViewControllerDelegate<NSObject>
@required
- (void)geocacheViewControllerDone:(GeocacheViewController *)geocacheViewController;
@end


@interface GeocacheViewController : UIView <MapWebViewDelegate>
{
	BOOL inProgress;
	MapView *mapView;
	MTCall *call;
	UIActivityIndicatorView *progressView;
	NSObject<GeocacheViewControllerDelegate> *_delegate;
}

@property (nonatomic, assign) NSObject<GeocacheViewControllerDelegate> *delegate;
@property (nonatomic, retain) MapView *mapView;
@property (nonatomic, retain) MTCall *call;
@property (nonatomic, retain) UIActivityIndicatorView *progressView;

+ (BOOL)canLookupCall:(MTCall *)call;
- (id)initWithCall:(MTCall *)call;

@end
