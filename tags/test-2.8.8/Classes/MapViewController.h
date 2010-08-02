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

#define USE_BUILTIN_MAPS 1
#import <UIKit/UIKit.h>
#import "MapViewCallDetailController.h"
#import "CoreLocation/CoreLocation.h"

#if USE_BUILTIN_MAPS
#import <MapKit/MapKit.h>





#import "CallViewControllerDelegate.h"
#import "Geocache.h"

@interface MapViewCallAnnotation : NSObject <MKAnnotation>
{
	CLLocationCoordinate2D coordinate;
	NSMutableDictionary *call;
	BOOL animatesDrop;
}
// Center latitude and longitude of the annotion view.
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;
@property (nonatomic, readonly) NSString *title;
@property (nonatomic, readonly) NSString *subtitle;
@property (nonatomic, readonly) NSMutableDictionary *call;
@property (nonatomic, assign) BOOL animatesDrop;
- (id)initWithCall:(NSMutableDictionary *)call;
@end


@interface MapViewController : UIViewController <MKMapViewDelegate,
                                                 CallViewControllerDelegate,
                                                 GeocacheDelegate>
{
    MKMapView *mapView;
	NSMutableDictionary *call;
	BOOL _shouldReloadMarkers;
	NSString *_currentUser;
	
	MapViewCallAnnotation *selectedMarker;
}

@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) NSMutableDictionary *call;

- (id)initWithTitle:(NSString *)theTitle call:(NSMutableDictionary *)call;
- (id)initWithTitle:(NSString *)theTitle;

@end





#else


#import "RMMapView.h"
#import "MapViewCallDetailController.h"
#import "CallViewControllerDelegate.h"
#import "Geocache.h"

@interface MapViewController : UIViewController <RMMapViewDelegate,
                                                 MapViewCallDetailControllerDelegate,
												 CallViewControllerDelegate,
												 GeocacheDelegate>
{
    RMMapView *mapView;
	NSMutableDictionary *call;
	UIActivityIndicatorView *progView;
	MapViewCallDetailController *detailView;
	BOOL _shouldReloadMarkers;
	NSString *_currentUser;
	
	RMMarker *selectedMarker;
}

@property (nonatomic, retain) MapViewCallDetailController *detailView;
@property (nonatomic, retain) RMMapView *mapView;
@property (nonatomic, retain) NSMutableDictionary *call;

- (id)initWithTitle:(NSString *)theTitle call:(NSMutableDictionary *)call;
- (id)initWithTitle:(NSString *)theTitle;

@end
#endif