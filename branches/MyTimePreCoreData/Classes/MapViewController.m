//
//  MapViewController.m
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

#import "MapViewController.h"
#import "Settings.h"
#import "CallViewController.h"

#if USE_BUILTIN_MAPS

@implementation MapViewCallAnnotation
@synthesize call;
@synthesize coordinate;
@synthesize animatesDrop;

- (CLLocationCoordinate2D)coordinate
{
	NSString *latLong = [call objectForKey:CallLattitudeLongitude];
	if(latLong && ![latLong isEqualToString:@"nil"])
	{
		CLLocationCoordinate2D point;
		NSArray *stringArray = [latLong componentsSeparatedByString:@", "];
		point.latitude = [[stringArray objectAtIndex:0] doubleValue];
		point.longitude = [[stringArray objectAtIndex:1] doubleValue];
		return point;
	}
	return CLLocationCoordinate2DMake(0 , 0);
}

- (NSString *)title
{
	NSMutableString *top = [[[NSMutableString alloc] init] autorelease];
	NSString *houseNumber = [call objectForKey:CallStreetNumber ];
	NSString *apartmentNumber = [call objectForKey:CallApartmentNumber ];
	NSString *street = [call objectForKey:CallStreet];
	
	[Settings formatStreetNumber:houseNumber apartment:apartmentNumber street:street city:nil state:nil topLine:top bottomLine:nil];
	
	if([top length] == 0)
		[top setString:NSLocalizedString(@"(unknown street)", @"(unknown street) Placeholder Section title in the Sorted By Calls view")];
	return top;
}

- (NSString *)subtitle
{
	return [call objectForKey:CallName];
}

- (id)initWithCall:(NSMutableDictionary *)c
{
	if( (self = [super init]) )
	{
		call = [c retain];
	}
	return self;
}

- (void)dealloc
{
	[call release];
	[super dealloc];
}
@end


@interface MapViewController ()
@property (nonatomic, retain) NSString *currentUser;
@end

@implementation MapViewController
@synthesize mapView;
@synthesize call;
@synthesize currentUser = _currentUser;

- (id)initWithTitle:(NSString *)theTitle call:(NSMutableDictionary *)theCall
{
	self = [super init];
	if (self)
	{
		_shouldReloadMarkers = NO;
		// this title will appear in the navigation bar
		self.title = theTitle;
		self.call = theCall;
		self.currentUser = [[[Settings sharedInstance] settings] objectForKey:SettingsMultipleUsersCurrentUser];
		
		self.tabBarItem.image = [UIImage imageNamed:@"map.png"];
		[[Geocache sharedInstance] addDelegate:self];
	}
	return self;
}

- (id)initWithTitle:(NSString *)theTitle
{
	return [self initWithTitle:theTitle call:nil];
}

- (void)dealloc
{
	[[Geocache sharedInstance] removeDelegate:self];
	self.currentUser = nil;
	self.mapView = nil;
	self.call = nil;
	
	[super dealloc];
}

- (void)loadMapView
{
	self.mapView = [[[MKMapView alloc] initWithFrame:self.view.bounds] autorelease];
	mapView.delegate = self;
	mapView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	mapView.showsUserLocation = YES;
	
	[self.view addSubview:mapView];
		
	BOOL init = false;
	
	if(call)
	{
		NSString *latLong = [call objectForKey:CallLattitudeLongitude];
		if(latLong)
		{
			MapViewCallAnnotation *marker = [[[MapViewCallAnnotation alloc] initWithCall:call] autorelease];
			[self.mapView addAnnotation:marker];
			[self.mapView setRegion:MKCoordinateRegionMake(marker.coordinate , MKCoordinateSpanMake(0.001 , 0.001)) animated:YES];
		}
	}
	else
	{
		CLLocationCoordinate2D ne;
		CLLocationCoordinate2D sw;
		NSEnumerator *e = [[[[Settings sharedInstance] userSettings] objectForKey:SettingsCalls] objectEnumerator];
		NSMutableDictionary *theCall;
		BOOL found = NO;
		
		while ( (theCall = [e nextObject]) ) 
		{
			NSString *latLong = [theCall objectForKey:CallLattitudeLongitude];
			NSArray *stringArray = [latLong componentsSeparatedByString:@", "];
			
			NSString *lookupType = [theCall objectForKey:CallLocationType];
			if([lookupType isEqualToString:CallLocationTypeDoNotShow])
			{
				// they dont want this displayed
				continue;
			}
			
			if(latLong && ![latLong isEqualToString:@"nil"] && stringArray.count == 2)
			{
				MapViewCallAnnotation *marker = [[[MapViewCallAnnotation alloc] initWithCall:theCall] autorelease];
				[self.mapView addAnnotation:marker];

				CLLocationCoordinate2D point = marker.coordinate;
				point.latitude = [[stringArray objectAtIndex:0] doubleValue];
				point.longitude = [[stringArray objectAtIndex:1] doubleValue];
				if(init)
				{
					if(point.latitude > ne.latitude)
						ne.latitude = point.latitude;
					if(point.latitude < sw.latitude)
						sw.latitude = point.latitude;
					if(point.longitude > ne.longitude)
						ne.longitude = point.longitude;
					if(point.longitude < sw.longitude)
						sw.longitude = point.longitude;
				}
				else
				{
					init = true;
					ne = point;
					sw = point;
				}
				found = YES;
			}
		}
		if(found)
		{
			CLLocationCoordinate2D center;
			MKCoordinateSpan span;
			span.latitudeDelta = ne.latitude - sw.latitude;
			span.longitudeDelta = ne.longitude - sw.longitude;
			
			center.latitude = sw.latitude + (span.latitudeDelta)/2.0;
			center.longitude = sw.longitude + (span.longitudeDelta)/2.0;
			[self.mapView setRegion:MKCoordinateRegionMake(center , span)];
		}
	}
}

- (void)loadView
{
	self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
	self.view.backgroundColor = [UIColor blackColor];
	self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	
	
	// load the map after it slides in
	[self performSelector:@selector(loadMapView) withObject:nil afterDelay:0.3];
}

- (void)viewDidDisappear:(BOOL)animated
{
	self.mapView.showsUserLocation = NO;
	_shouldReloadMarkers = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
	NSString *currentUser = [[[Settings sharedInstance] settings] objectForKey:SettingsMultipleUsersCurrentUser];
	self.mapView.showsUserLocation = YES;
	
	if(![currentUser isEqualToString:self.currentUser])
	{
		self.currentUser = currentUser;
		// we should blow away all markers and recreate them
		[self.mapView removeFromSuperview];
		[self performSelector:@selector(loadMapView) withObject:nil afterDelay:0.3];
		
		_shouldReloadMarkers = NO;
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	if(_shouldReloadMarkers)
	{
		_shouldReloadMarkers = NO;
		NSArray *markers = [self.mapView annotations];
		
		NSMutableArray *removeMarkers = [NSMutableArray array];
		for(MapViewCallAnnotation *marker in markers)
		{
			if ([marker isKindOfClass:[MKUserLocation class]])
				continue;

			NSMutableDictionary *theCall = (NSMutableDictionary *)marker.call;
			NSString *latLong = [theCall objectForKey:CallLattitudeLongitude];
			NSString *lookupType = [theCall objectForKey:CallLocationType];
			if([lookupType isEqualToString:CallLocationTypeDoNotShow] || 
			   latLong == nil || 
			   [latLong isEqualToString:@"nil"] ||
			   ![[[[Settings sharedInstance] userSettings] objectForKey:SettingsCalls] containsObject:theCall])
			{
				// make the detail view go away
				[self.mapView deselectAnnotation:marker animated:NO];
				
				[removeMarkers addObject:marker];
				continue;
			}
			
			if(latLong && ![latLong isEqualToString:@"nil"])
			{
#if 0
				CLLocationCoordinate2D point;
				NSArray *stringArray = [latLong componentsSeparatedByString:@", "];
				point.latitude = [[stringArray objectAtIndex:0] doubleValue];
				point.longitude = [[stringArray objectAtIndex:1] doubleValue];
				[marker setCoordinate:point];
#endif				
				[[self.mapView viewForAnnotation:marker] setNeedsDisplay];
			}
		}
		for(MapViewCallAnnotation *marker in removeMarkers)
		{
			[self.mapView removeAnnotation:marker];
		}
	}
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views;
{
	for(MKAnnotationView *view in views)
	{
		MapViewCallAnnotation *annotation = (MapViewCallAnnotation *)view.annotation;
		if ([annotation isKindOfClass:[MKUserLocation class]])
			continue;
		annotation.animatesDrop = NO;
	}
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)theAnnotation
{
    static NSString *AnnotationViewID = @"annotationViewID";
    // if it's the user location, just return nil.
    if ([theAnnotation isKindOfClass:[MKUserLocation class]])
        return nil;

	MapViewCallAnnotation *annotation = (MapViewCallAnnotation *)theAnnotation;
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    if (annotationView == nil)
    {
        annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID] autorelease];

		annotationView.animatesDrop = annotation.animatesDrop;
		annotationView.canShowCallout = YES;
		annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
	}
	annotationView.annotation = annotation;
	NSArray *returnVisits = [annotation.call objectForKey:CallReturnVisits];
	if([returnVisits count])
	{
		NSDate *lastVisit = [[returnVisits objectAtIndex:0] objectForKey:CallReturnVisitDate];
		NSTimeInterval interval = -[lastVisit timeIntervalSinceNow];
		// if the user put a date in the future, fix this
		if(interval < 0)
			interval = 0;
		int days = interval/(60*60*24);
		MKPinAnnotationColor pinColor;
		if(days > 14)
			pinColor = MKPinAnnotationColorRed;
		else if(days > 7)
			pinColor = MKPinAnnotationColorPurple;
		else
			pinColor = MKPinAnnotationColorGreen;
		annotationView.pinColor = pinColor;
	}
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	MapViewCallAnnotation *annotation = (MapViewCallAnnotation *)view.annotation;
	CallViewController *controller = [[[CallViewController alloc] initWithCall:annotation.call] autorelease];
	controller.delegate = self;
	selectedMarker = annotation;
	// push the element view controller onto the navigation stack to display it
	[[self navigationController] pushViewController:controller animated:YES];
}

- (void)geocacheDone:(Geocache *)geocache forCall:(NSMutableDictionary *)theCall
{
	NSArray *markers = [self.mapView annotations];
	BOOL found = NO;
	
	for(MapViewCallAnnotation *marker in markers)
	{
		if ([marker isKindOfClass:[MKUserLocation class]])
			continue;
		if(theCall == marker.call)
		{
			found = YES;
			NSString *latLong = [theCall objectForKey:CallLattitudeLongitude];
			if(latLong && ![latLong isEqualToString:@"nil"])
			{
				[[self.mapView viewForAnnotation:marker] setNeedsDisplay];
			}
		}
	}
	
	if(!found)
	{
		NSString *latLong = [theCall objectForKey:CallLattitudeLongitude];
		if(latLong && ![latLong isEqualToString:@"nil"])
		{
			MapViewCallAnnotation *marker = [[[MapViewCallAnnotation alloc] initWithCall:theCall] autorelease];
			marker.animatesDrop = YES;
			[self.mapView addAnnotation:marker];
			if([[self.mapView annotations] count] == 1)
			{
				[self.mapView setRegion:MKCoordinateRegionMake(marker.coordinate , MKCoordinateSpanMake(0.01 , 0.01)) animated:YES];
			}
		}
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// we support rotation in this view controller
	return YES;
}

//
//
// CallViewControllerDelegate methods
// 
//
- (void)callViewController:(CallViewController *)callViewController deleteCall:(NSMutableDictionary *)thisCall keepInformation:(BOOL)keepInformation
{
	NSMutableDictionary *userSettings = [[Settings sharedInstance] userSettings];
	if(keepInformation)
	{
		NSMutableArray *deletedCalls = [userSettings objectForKey:SettingsDeletedCalls];
		if(deletedCalls == nil)
		{
			deletedCalls = [NSMutableArray array];
			[userSettings setObject:deletedCalls forKey:SettingsDeletedCalls];
		}
		[deletedCalls addObject:thisCall];
	}
	
	NSMutableArray *array = [userSettings objectForKey:SettingsCalls];
	[array removeObject:thisCall];
	[[Settings sharedInstance] saveData];
	
	
	[self.mapView removeAnnotation:selectedMarker];
	selectedMarker = nil;
}

- (void)callViewController:(CallViewController *)callViewController saveCall:(NSMutableDictionary *)newCall
{
	[[Settings sharedInstance] saveData];
	[selectedMarker retain];
	[self.mapView removeAnnotation:selectedMarker];
	[self.mapView addAnnotation:selectedMarker];
	[selectedMarker release];
}


@end
















































#else
#import "RMMarker.h"
#import "RMMarkerManager.h"
#import "RMVirtualEarthSource.h"
#import "RMCloudMadeMapSource.h"

@interface MapViewController ()
@property (nonatomic, retain) NSString *currentUser;
@end

@implementation MapViewController
@synthesize detailView;
@synthesize mapView;
@synthesize call;
@synthesize currentUser = _currentUser;

- (id)initWithTitle:(NSString *)theTitle call:(NSMutableDictionary *)theCall
{
	self = [super init];
	if (self)
	{
		_shouldReloadMarkers = NO;
		// this title will appear in the navigation bar
		self.title = theTitle;
		self.call = theCall;
		self.currentUser = [[[Settings sharedInstance] settings] objectForKey:SettingsMultipleUsersCurrentUser];

		self.tabBarItem.image = [UIImage imageNamed:@"map.png"];
		[[Geocache sharedInstance] addDelegate:self];
	}
	return self;
}

- (id)initWithTitle:(NSString *)theTitle
{
	return [self initWithTitle:theTitle call:nil];
}

- (void)dealloc
{
	[[Geocache sharedInstance] removeDelegate:self];
	self.currentUser = nil;
	self.mapView = nil;
	self.call = nil;
	self.detailView = nil;
		
	[super dealloc];
}

- (void)loadMapView
{
	self.mapView = [[[RMMapView alloc] initWithFrame:self.view.bounds] autorelease];
	mapView.delegate = self;
    mapView.multipleTouchEnabled = YES;
	[mapView setBackgroundColor:[UIColor blackColor]];
	[mapView.contents setTileSource:[[[RMVirtualEarthSource alloc] initWithRoadThemeUsingAccessKey:@"1"] autorelease]];
	mapView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	
	[self.view addSubview:mapView];

	self.detailView = [[[MapViewCallDetailController alloc] initWithNibName:@"MapViewCallDetail" bundle:[NSBundle mainBundle]] autorelease];
	self.detailView.view.hidden = YES;
	if(call == nil)
	{
		// only click on the disclosure if they are displaying all calls
		self.detailView.delegate = self;
	}
	[self.view addSubview:self.detailView.view];
	

	[RMMapContents setPerformExpensiveOperations:YES];
	
	RMMarkerManager *markerManager = mapView.markerManager;
	BOOL init = false;
	
	if(call)
	{
		NSString *latLong = [call objectForKey:CallLattitudeLongitude];
		if(latLong)
		{
			RMMarker *marker = [[[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"marker-blue"]] autorelease];
			[marker setData:call];
			CLLocationCoordinate2D point;
			NSArray *stringArray = [latLong componentsSeparatedByString:@", "];
			point.latitude = [[stringArray objectAtIndex:0] doubleValue];
			point.longitude = [[stringArray objectAtIndex:1] doubleValue];
			[markerManager addMarker:marker AtLatLong:point];
		}
	}
	else
	{
		CLLocationCoordinate2D ne;
		CLLocationCoordinate2D sw;
		NSEnumerator *e = [[[[Settings sharedInstance] userSettings] objectForKey:SettingsCalls] objectEnumerator];
		NSMutableDictionary *theCall;
		BOOL found = NO;
		
		while ( (theCall = [e nextObject]) ) 
		{
			NSString *latLong = [theCall objectForKey:CallLattitudeLongitude];
			NSArray *stringArray = [latLong componentsSeparatedByString:@", "];

			NSString *lookupType = [theCall objectForKey:CallLocationType];
			if([lookupType isEqualToString:CallLocationTypeDoNotShow])
			{
				// they dont want this displayed
				continue;
			}

			if(latLong && ![latLong isEqualToString:@"nil"] && stringArray.count == 2)
			{
				RMMarker *marker = [[[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"marker-blue"]] autorelease];
				[marker setData:theCall];
				CLLocationCoordinate2D point;
				point.latitude = [[stringArray objectAtIndex:0] doubleValue];
				point.longitude = [[stringArray objectAtIndex:1] doubleValue];
				[markerManager addMarker:marker AtLatLong:point];
				[mapView moveToLatLong:point];
				if(init)
				{
					if(point.latitude > ne.latitude)
						ne.latitude = point.latitude;
					if(point.latitude < sw.latitude)
						sw.latitude = point.latitude;
					if(point.longitude > ne.longitude)
						ne.longitude = point.longitude;
					if(point.longitude < sw.longitude)
						sw.longitude = point.longitude;
				}
				else
				{
					init = true;
					ne = point;
					sw = point;
				}
				found = YES;
			}
		}
		if(found)
		{
			[mapView zoomWithLatLngBoundsNorthEast:ne SouthWest:sw];
		}
	}
}

- (void)loadView
{
	self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
	self.view.backgroundColor = [UIColor blackColor];
	self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);


	// load the map after it slides in
	[self performSelector:@selector(loadMapView) withObject:nil afterDelay:0.3];
}

- (void)viewDidDisappear:(BOOL)animated
{
	_shouldReloadMarkers = YES;
}

- (void)viewWillAppear:(BOOL)animated
{
	NSString *currentUser = [[[Settings sharedInstance] settings] objectForKey:SettingsMultipleUsersCurrentUser];
	
	if(![currentUser isEqualToString:self.currentUser])
	{
		self.currentUser = currentUser;
		// we should blow away all markers and recreate them
		[self.mapView removeFromSuperview];
		[self performSelector:@selector(loadMapView) withObject:nil afterDelay:0.3];

		_shouldReloadMarkers = NO;
	}
}

- (void)viewDidAppear:(BOOL)animated
{
	if(_shouldReloadMarkers)
	{
		_shouldReloadMarkers = NO;
		RMMarkerManager *markerManager = mapView.markerManager;
		NSArray *markers = [markerManager markers];

		NSMutableArray *removeMarkers = [NSMutableArray array];
		for(RMMarker *marker in markers)
		{
			NSMutableDictionary *theCall = (NSMutableDictionary *)marker.data;
			NSString *latLong = [theCall objectForKey:CallLattitudeLongitude];
			NSString *lookupType = [theCall objectForKey:CallLocationType];
			if([lookupType isEqualToString:CallLocationTypeDoNotShow] || 
			   latLong == nil || 
			   [latLong isEqualToString:@"nil"] ||
			   ![[[[Settings sharedInstance] userSettings] objectForKey:SettingsCalls] containsObject:theCall])
			{
				// make the detail view go away
				[self tapOnMarker:selectedMarker onMap:mapView];

				[removeMarkers addObject:marker];
				continue;
			}

			if(latLong && ![latLong isEqualToString:@"nil"])
			{
				CLLocationCoordinate2D point;
				NSArray *stringArray = [latLong componentsSeparatedByString:@", "];
				point.latitude = [[stringArray objectAtIndex:0] doubleValue];
				point.longitude = [[stringArray objectAtIndex:1] doubleValue];
				[markerManager moveMarker:marker AtLatLon:point];
			}
		}
		for(RMMarker *marker in removeMarkers)
		{
			[markerManager removeMarker:marker];
		}
	}
}

- (void)geocacheDone:(Geocache *)geocache forCall:(NSMutableDictionary *)theCall
{
	RMMarkerManager *markerManager = mapView.markerManager;
	NSArray *markers = [markerManager markers];
	BOOL found = NO;

	for(RMMarker *marker in markers)
	{
		if(theCall == marker.data)
		{
			found = YES;
			NSString *latLong = [theCall objectForKey:CallLattitudeLongitude];
			if(latLong && ![latLong isEqualToString:@"nil"])
			{
				CLLocationCoordinate2D point;
				NSArray *stringArray = [latLong componentsSeparatedByString:@", "];
				point.latitude = [[stringArray objectAtIndex:0] doubleValue];
				point.longitude = [[stringArray objectAtIndex:1] doubleValue];
				[markerManager moveMarker:marker AtLatLon:point];
			}
		}
	}
	
	if(!found && markerManager)
	{
		NSString *latLong = [theCall objectForKey:CallLattitudeLongitude];
		if(latLong && ![latLong isEqualToString:@"nil"])
		{
			RMMarker *marker = [[[RMMarker alloc] initWithUIImage:[UIImage imageNamed:@"marker-blue"]] autorelease];
			[marker setData:theCall];
			CLLocationCoordinate2D point;
			NSArray *stringArray = [latLong componentsSeparatedByString:@", "];
			point.latitude = [[stringArray objectAtIndex:0] doubleValue];
			point.longitude = [[stringArray objectAtIndex:1] doubleValue];
			[markerManager addMarker:marker AtLatLong:point];
			if([[markerManager markers] count] == 1)
			{
				[mapView moveToLatLong:point];
			}
		}
	}
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
	[self.mapView removeFromSuperview];
	[self loadMapView];
	NSLog(@"%f, %f", self.view.frame.size.height, self.view.frame.size.width);
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// we support rotation in this view controller
	return YES;
}

- (void) tapOnMarker: (RMMarker*) marker onMap: (RMMapView*) map;
{
	if(marker == selectedMarker)
	{
		self.detailView.view.hidden = YES;
		selectedMarker = nil;
	}
	else
	{
		NSMutableDictionary *selectedCall = (NSMutableDictionary *)[marker data];
		CGRect rect = self.detailView.view.frame;
		rect.size.width = self.view.bounds.size.width;
		self.detailView.view.frame = rect;
		self.detailView.call = selectedCall;
		self.detailView.view.hidden = NO;
		selectedMarker = marker;
		if(marker.position.y < 150)
		{
			CGSize move;
			move.width = 0;
			move.height = 100 - marker.position.y + 50;
			[UIView beginAnimations:nil context:nil];
				[UIView setAnimationDuration:1.0];
				[UIView setAnimationsEnabled:YES];
				[mapView moveBy:move];
			[UIView commitAnimations];
		}
	}
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

- (void) dragMarkerPosition: (RMMarker*) marker onMap: (RMMapView*)map position:(CGPoint)position
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

- (void) mapViewCallDetailControllerSelected:(MapViewCallDetailController *)mapViewCallDetailController
{
	CallViewController *controller = [[[CallViewController alloc] initWithCall:mapViewCallDetailController.call] autorelease];
	controller.delegate = self;
	
	// push the element view controller onto the navigation stack to display it
	[[self navigationController] pushViewController:controller animated:YES];
}

- (void) mapViewCallDetailControllerCanceled:(MapViewCallDetailController *)mapViewCallDetailController
{
}


//
//
// CallViewControllerDelegate methods
// 
//
- (void)callViewController:(CallViewController *)callViewController deleteCall:(NSMutableDictionary *)thisCall keepInformation:(BOOL)keepInformation
{
	NSMutableDictionary *userSettings = [[Settings sharedInstance] userSettings];
	if(keepInformation)
	{
		
		NSMutableArray *deletedCalls = [userSettings objectForKey:SettingsDeletedCalls];
		if(deletedCalls == nil)
		{
			deletedCalls = [NSMutableArray array];
			[userSettings setObject:deletedCalls forKey:SettingsDeletedCalls];
		}
		[deletedCalls addObject:thisCall];
	}

	NSMutableArray *array = [userSettings objectForKey:SettingsCalls];
	[array removeObject:detailView.call];
	[[Settings sharedInstance] saveData];

	[mapView.markerManager removeMarker:selectedMarker];
	selectedMarker = nil;
	detailView.view.hidden = YES;
}

- (void)callViewController:(CallViewController *)callViewController saveCall:(NSMutableDictionary *)newCall
{
	NSMutableArray *array = [[[Settings sharedInstance] userSettings] objectForKey:SettingsCalls];
	int index = [array indexOfObject:detailView.call];
	[array replaceObjectAtIndex:index withObject:newCall];
	
	[selectedMarker setData:newCall];
	detailView.call = newCall;
}


@end
#endif