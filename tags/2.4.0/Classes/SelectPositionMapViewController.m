//
//  SelectPositionMapViewController.m
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

#import "SelectPositionMapViewController.h"
#import "Settings.h"
#import "RMMarker.h"
#import "RMMarkerManager.h"
#import "RMVirtualEarthSource.h"
#import "RMCloudMadeMapSource.h"
#import "CallViewController.h"
#import "PSLocalization.h"

@implementation SelectPositionMapViewController
@synthesize mapView;
@synthesize locationManager;
@synthesize point;
@synthesize delegate;

- (id)initWithPosition:(NSString *)latLong
{
	self = [super init];
	if (self)
	{
		// this title will appear in the navigation bar
		self.title = NSLocalizedString(@"Select Location", @"Title for the view where you manually select the location for the call");
		markerMoved = NO;

		pointInitalized = latLong != nil;
		if(latLong && ![latLong isEqualToString:@"nil"])
		{
			NSArray *stringArray = [latLong componentsSeparatedByString:@", "];
			point.latitude = [[stringArray objectAtIndex:0] doubleValue];
			point.longitude = [[stringArray objectAtIndex:1] doubleValue];

			NSMutableDictionary *settings = [[Settings sharedInstance] settings];
			[settings setObject:[NSNumber numberWithFloat:point.latitude] forKey:SettingsLastLattitude];
			[settings setObject:[NSNumber numberWithFloat:point.longitude] forKey:SettingsLastLongitude];
			[[Settings sharedInstance] saveData];
		}
		else
		{
			NSDictionary *settings = [[Settings sharedInstance] settings];
			NSNumber *lat = [settings objectForKey:SettingsLastLattitude];
			NSNumber *lng = [settings objectForKey:SettingsLastLongitude];
			defaultPointInitalized = (lat && lng);
			if(defaultPointInitalized)
			{
				point.latitude = [lat floatValue];
				point.longitude = [lng floatValue];
			}
			else
			{
				point.latitude = 34;
				point.longitude = -86;
			}
		}
	}
	return self;
}

- (void)dealloc
{
	self.mapView = nil;
	self.locationManager = nil;
	
	[super dealloc];
}

- (void)navigationControlDone:(id)sender 
{
	VERBOSE(NSLog(@"navigationControlDone:");)

	// save this position
	NSMutableDictionary *settings = [[Settings sharedInstance] settings];
	[settings setObject:[NSNumber numberWithFloat:point.latitude] forKey:SettingsLastLattitude];
	[settings setObject:[NSNumber numberWithFloat:point.longitude] forKey:SettingsLastLongitude];
	[[Settings sharedInstance] saveData];

	if(delegate && [delegate respondsToSelector:@selector(selectPositionMapViewControllerDone:)])
	{
		[delegate selectPositionMapViewControllerDone:self];
	}
	[[self navigationController] popViewControllerAnimated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)loadMapView
{
	self.mapView = [[[RMMapView alloc] initWithFrame:self.view.bounds WithLocation:point] autorelease];
	mapView.delegate = self;
    mapView.multipleTouchEnabled = YES;
	[mapView setBackgroundColor:[UIColor blackColor]];
	[mapView.contents setTileSource:[[RMVirtualEarthSource alloc] init]];
	[self.view addSubview:mapView];


	[RMMapContents setPerformExpensiveOperations:YES];
	
	RMMarkerManager *markerManager = mapView.markerManager;

	if(pointInitalized)
	{
		marker = [[[RMMarker alloc] initWithKey:RMMarkerBlueKey] autorelease];
		[marker setTextLabel:NSLocalizedString(@"Move me", @"title for the marker when you have to manually set the location for a call")];
		[marker showLabel];
		[markerManager addMarker:marker AtLatLong:point];

		[mapView moveToLatLong:point];
	}
	else
	{
		self.locationManager = [[[CLLocationManager alloc] init] autorelease];
		self.locationManager.delegate = self; // Tells the location manager to send updates to this object
		[self.locationManager startUpdatingLocation];
		if(defaultPointInitalized)
		{
			marker = [[[RMMarker alloc] initWithKey:RMMarkerBlueKey] autorelease];
			[marker setTextLabel:NSLocalizedString(@"Acquiring Location...", @"title for the marker when you have to manually set the location for a call")];
			[marker showLabel];
			[markerManager addMarker:marker AtLatLong:point];

			[mapView moveToLatLong:point];
		}
	}

	// add DONE button
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(navigationControlDone:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:NO];
}

- (void)loadView
{
	self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
	self.view.backgroundColor = [UIColor blackColor];
	self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);


	// load the map after it slides in
	[self performSelector:@selector(loadMapView) withObject:nil afterDelay:0.3];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self.mapView removeFromSuperview];
	[self loadMapView];
	NSLog(@"%f, %f", self.view.frame.size.height, self.view.frame.size.width);
}


// Called when the location is updated
- (void)locationManager:(CLLocationManager *)manager
	didUpdateToLocation:(CLLocation *)newLocation
		   fromLocation:(CLLocation *)oldLocation
{
	// Horizontal coordinates
	if (signbit(newLocation.horizontalAccuracy)) 
	{
		// Negative accuracy means an invalid or unavailable measurement
		if(marker == nil)
		{
			marker = [[[RMMarker alloc] initWithKey:RMMarkerBlueKey] autorelease];
			[marker showLabel];
			[mapView.markerManager addMarker:marker];
		}
		[marker setTextLabel:NSLocalizedString(@"Location Unavaliable, please move me", @"title for the marker when you have to manually set the location for a call")];
	} 
	else 
	{
		if(marker == nil)
		{
			marker = [[[RMMarker alloc] initWithKey:RMMarkerBlueKey] autorelease];
			[marker showLabel];
			[mapView.markerManager addMarker:marker];
			markerMoved = NO; // just in case
		}
		[marker setTextLabel:NSLocalizedString(@"Move me", @"title for the marker when you have to manually set the location for a call")];
		if(!markerMoved)
		{
			point.latitude = newLocation.coordinate.latitude;
			point.longitude = newLocation.coordinate.longitude;
			NSMutableDictionary *settings = [[Settings sharedInstance] settings];
			[settings setObject:[NSNumber numberWithFloat:point.latitude] forKey:SettingsLastLattitude];
			[settings setObject:[NSNumber numberWithFloat:point.longitude] forKey:SettingsLastLongitude];
			[[Settings sharedInstance] saveData];

			[mapView.markerManager moveMarker:marker AtLatLon:point];
			[mapView moveToLatLong:point];
		}
	}
}


// Called when there is an error getting the location
- (void)locationManager:(CLLocationManager *)manager
	   didFailWithError:(NSError *)error
{
	if(marker == nil)
	{
		marker = [[[RMMarker alloc] initWithKey:RMMarkerBlueKey] autorelease];
		[marker setTextLabel:NSLocalizedString(@"Location Unavaliable, please move me", @"title for the marker when you have to manually set the location for a call")];
		[marker showLabel];
		[mapView.markerManager addMarker:marker];
	}
}

- (void)dragMarkerPosition:(RMMarker*)theMarker onMap:(RMMapView*)map position:(CGPoint)position
{
	RMMarkerManager *markerManager = [mapView markerManager];
	CGRect rect = [theMarker bounds];
	CGPoint modifiedPoint = position;
	// account for the marker height, lets get right in the large bubble which is 1/3 the way down
	modifiedPoint.y += rect.size.height/3;
	point = [map pixelToLatLong:modifiedPoint];
	[markerManager moveMarker:theMarker AtXY:modifiedPoint];
	markerMoved = YES;
	if(self.locationManager)
	{
		[self.locationManager stopUpdatingLocation];
		self.locationManager = nil;
	}

}

- (void) tapOnMarker: (RMMarker*) marker onMap: (RMMapView*) map;
{
}

- (void) beforeMapMove: (RMMapView*) map
{
}

- (void) afterMapMove: (RMMapView*) map
{
}

- (void) beforeMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center
{
}

- (void) afterMapZoom: (RMMapView*) map byFactor: (float) zoomFactor near:(CGPoint) center
{
}

- (void) doubleTapOnMap: (RMMapView*) map At: (CGPoint) point
{
}

- (void) tapOnLabelForMarker: (RMMarker*) marker onMap: (RMMapView*) map
{
}

- (void) afterMapTouch: (RMMapView*) map
{
}

- (BOOL)respondsToSelector:(SEL)selector
{
	BOOL ret = [super respondsToSelector:selector];
    VERY_VERBOSE(NSLog(@"%s respondsToSelector: %s ? %s", __FILE__, selector, ret ? "YES" : "NO");)
    return ret;
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"%s methodSignatureForSelector: %s", __FILE__, selector);)
    return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    VERY_VERBOSE(NSLog(@"%s forwardInvocation: %s", __FILE__, [invocation selector]);)
    [super forwardInvocation:invocation];
}

@end

