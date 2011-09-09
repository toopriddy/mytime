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
#import "CoreLocation/CoreLocation.h"
#import <MapKit/MapKit.h>
#import "CallViewControllerDelegate.h"
#import "Geocache.h"
#import "MTCall.h"

@interface MapViewCallAnnotation : NSObject <MKAnnotation>
{
	CLLocationCoordinate2D _coordinate;
	MTCall *_call;
	BOOL _animatesDrop;
}
// Center latitude and longitude of the annotion view.
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic, readonly) MTCall *call;
@property (nonatomic, assign) BOOL animatesDrop;
- (id)initWithCall:(MTCall *)call;
@end


@interface MapViewController : UIViewController <MKMapViewDelegate,
                                                 CallViewControllerDelegate>
{
    MKMapView *_mapView;
	MTCall *_call;
	BOOL _shouldReloadMarkers;
	BOOL _reloadMapView;
	
	MKCoordinateRegion savedRegion;
	BOOL hasSavedRegion;
	MTCall *selectedCall_;
	MapViewCallAnnotation *selectedMarker;
}

@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) MTCall *call;
@property (nonatomic, retain) MTCall *selectedCall;

- (id)initWithTitle:(NSString *)theTitle call:(MTCall *)call;
- (id)initWithTitle:(NSString *)theTitle;

@end
