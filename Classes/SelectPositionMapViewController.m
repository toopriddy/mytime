//
//  SelectPositionMapViewController.m
//  MyTime
//
//  Created by Brent Priddy on 8/30/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import "SelectPositionMapViewController.h"
#import "Settings.h"
#import "RMMarker.h"
#import "RMMarkerManager.h"
#import "RMVirtualEarthSource.h"
#import "RMCloudMadeMapSource.h"
#import "CallViewController.h"

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
		if(latLong)
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
	if(delegate && [delegate respondsToSelector:@selector(selectPositionMapViewControllerDone:)])
	{
		[delegate selectPositionMapViewControllerDone:self];
	}
	[[self navigationController] popViewControllerAnimated:YES];
}


- (void)loadView
{
	self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];

	self.mapView = [[[RMMapView alloc] initWithFrame:self.view.bounds] autorelease];
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
			point.latitude = newLocation.coordinate.latitude;
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
	
	[markerManager moveMarker:theMarker AtXY:CGPointMake(position.x,position.y +rect.size.height/3)];
	markerMoved = YES;
	point = [map pixelToLatLong:position];
	if(self.locationManager)
	{
		[self.locationManager stopUpdatingLocation];
		self.locationManager = nil;
	}

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

