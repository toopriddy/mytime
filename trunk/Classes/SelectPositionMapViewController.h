//
//  SelectPositionMapViewController.h
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

#import "RMMapView.h"
#import "MapViewCallDetailController.h"
#import "CoreLocation/CoreLocation.h"

@class SelectPositionMapViewController;

@protocol SelectPositionMapViewControllerDelegate<NSObject>
@required
- (void)selectPositionMapViewControllerDone:(SelectPositionMapViewController *)selectPositionMapViewController;
@end


@interface SelectPositionMapViewController : UIViewController <RMMapViewDelegate,
															   CLLocationManagerDelegate>
{
    RMMapView *mapView;
	RMMarker *marker;
	CLLocationManager *locationManager;

	BOOL markerMoved;
	BOOL pointInitalized;
	BOOL defaultPointInitalized;
	CLLocationCoordinate2D point;

	NSObject<SelectPositionMapViewControllerDelegate> *delegate;
}

@property (nonatomic, retain) RMMapView *mapView;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, assign) NSObject<SelectPositionMapViewControllerDelegate> *delegate;
@property (nonatomic, readonly) CLLocationCoordinate2D point;

- (id)initWithPosition:(NSString *)thePosition;

@end
