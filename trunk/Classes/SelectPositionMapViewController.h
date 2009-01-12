//
//  SelectPositionMapViewController.h
//  MyTime
//
//  Created by Brent Priddy on 8/30/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
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
