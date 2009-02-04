//
//  MapViewController.h
//  MyTime
//
//  Created by Brent Priddy on 8/30/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapView.h"

@class GeocacheViewController;
@protocol GeocacheViewControllerDelegate<NSObject>
@required
- (void)geocacheViewControllerDone:(GeocacheViewController *)geocacheViewController;
@end


@interface GeocacheViewController : UIView <MapWebViewDelegate>
{
	BOOL inProgress;
	MapView *mapView;
	NSMutableDictionary *call;
	UIActivityIndicatorView *progressView;
	NSObject<GeocacheViewControllerDelegate> *_delegate;
}

@property (nonatomic, assign) NSObject<GeocacheViewControllerDelegate> *delegate;
@property (nonatomic, retain) MapView *mapView;
@property (nonatomic, retain) NSMutableDictionary *call;
@property (nonatomic, retain) UIActivityIndicatorView *progressView;

- (id)initWithCall:(NSMutableDictionary *)call;

@end
