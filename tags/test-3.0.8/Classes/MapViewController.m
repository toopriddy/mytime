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
#import "CallViewController.h"
#import "MTUser.h"
#import "MTReturnVisit.h"
#import "NSManagedObjectContext+PriddySoftware.h"


@implementation MapViewCallAnnotation
@synthesize call = _call;
@synthesize coordinate = _coordinate;
@synthesize animatesDrop = _animatesDrop;

- (CLLocationCoordinate2D)coordinate
{
	if(_call.locationAquiredValue)
	{
		CLLocationCoordinate2D point;
		point.latitude = [_call.lattitude doubleValue];
		point.longitude = [_call.longitude doubleValue];
		return point;
	}
	return CLLocationCoordinate2DMake(0 , 0);
}

- (NSString *)title
{
	NSString *top = [_call addressNumberAndStreet];
	if(top == nil || [top length] == 0)
		top = NSLocalizedString(@"(unknown street)", @"(unknown street) Placeholder Section title in the Sorted By Calls view");
	return top;
}

- (NSString *)subtitle
{
	return _call.name;
}

- (id)initWithCall:(MTCall *)call
{
	if( (self = [super init]) )
	{
		_call = [call retain];
	}
	return self;
}

- (void)dealloc
{
	[_call release];
	[super dealloc];
}
@end


@interface MapViewController ()
- (void)callChanged:(NSNotification *)notification;
@end

@implementation MapViewController
@synthesize mapView = _mapView;
@synthesize call = _call;
@synthesize selectedCall = selectedCall_;

- (void)userChanged
{
	_reloadMapView = YES;
	[self.mapView removeFromSuperview];
	self.mapView = nil;
	self.selectedCall = nil;
	hasSavedRegion = NO;
}

- (id)initWithTitle:(NSString *)theTitle call:(MTCall *)theCall
{
	self = [super init];
	if (self)
	{
		_shouldReloadMarkers = NO;
		// this title will appear in the navigation bar
		self.title = theTitle;
		self.call = theCall;
		
		self.tabBarItem.image = [UIImage imageNamed:@"map.png"];
		
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(callChanged:) name:MTNotificationCallChanged object:nil];
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userChanged) name:MTNotificationUserChanged object:nil];
	}
	return self;
}

- (id)initWithTitle:(NSString *)theTitle
{
	return [self initWithTitle:theTitle call:nil];
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MTNotificationUserChanged object:nil];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:MTNotificationCallChanged object:nil];
	self.mapView = nil;
	self.call = nil;
	self.selectedCall = nil;
	
	[super dealloc];
}

- (void)loadMapView
{
	self.mapView = [[[MKMapView alloc] initWithFrame:self.view.bounds] autorelease];
	_mapView.delegate = self;
	_mapView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	_mapView.showsUserLocation = YES;
	
	[self.view addSubview:_mapView];
	
	MKCoordinateRegion region;
	
	if(_call)
	{
		if(_call.locationAquired)
		{
			MapViewCallAnnotation *marker = [[[MapViewCallAnnotation alloc] initWithCall:_call] autorelease];
			[_mapView addAnnotation:marker];
			region = MKCoordinateRegionMake(marker.coordinate , MKCoordinateSpanMake(0.001 , 0.001));
		}
	}
	else
	{
		BOOL found = NO;
		MTUser *currentUser = [MTUser currentUser];
		NSArray *calls = [currentUser.managedObjectContext fetchObjectsForEntityName:[MTCall entityName]
																   propertiesToFetch:[NSArray arrayWithObjects:@"name", @"lattitude", @"longitude", nil]
																	   withPredicate:[NSPredicate predicateWithFormat:@"(user == %@) AND (locationLookupType != %@) AND (locationAquired == YES) AND (deletedCall == NO)", currentUser, CallLocationTypeDoNotShow]];
					
		CLLocationCoordinate2D topLeftCoord;
		topLeftCoord.latitude = -90;
		topLeftCoord.longitude = 180;
		
		CLLocationCoordinate2D bottomRightCoord;
		bottomRightCoord.latitude = 90;
		bottomRightCoord.longitude = -180;
		
		for(MTCall *call in calls)
		{
			MapViewCallAnnotation *marker = [[[MapViewCallAnnotation alloc] initWithCall:call] autorelease];
			[_mapView addAnnotation:marker];
			if(self.selectedCall == call)
			{
				[_mapView selectAnnotation:marker animated:NO];
				self.selectedCall = nil;
			}
			CLLocationCoordinate2D point = marker.coordinate;
			point.latitude = [call.lattitude doubleValue];
			point.longitude = [call.longitude doubleValue];

			topLeftCoord.longitude = fmin(topLeftCoord.longitude, point.longitude);
			topLeftCoord.latitude = fmax(topLeftCoord.latitude, point.latitude);
			
			bottomRightCoord.longitude = fmax(bottomRightCoord.longitude, point.longitude);
			bottomRightCoord.latitude = fmin(bottomRightCoord.latitude, point.latitude);
			found = YES;
		}
		self.selectedCall = nil;
		region.center.latitude = topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5;
		region.center.longitude = topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5;
		region.span.latitudeDelta = fabs(topLeftCoord.latitude - bottomRightCoord.latitude) * 1.1; // Add a little extra space on the sides
		region.span.longitudeDelta = fabs(bottomRightCoord.longitude - topLeftCoord.longitude) * 1.1; // Add a little extra space on the sides
		
		region = [_mapView regionThatFits:region];
	}
	
	// if we were previously loaded with a region use that one
	if(hasSavedRegion)
	{
		region = savedRegion;
	}
	
	[_mapView setRegion:region];
}

- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload 
{
	hasSavedRegion = YES;
	savedRegion = [self.mapView region];
	MapViewCallAnnotation *annotation = (MapViewCallAnnotation *)[self.mapView.selectedAnnotations lastObject];
	if([annotation isKindOfClass:[MapViewCallAnnotation class]])
	{
		self.selectedCall = annotation.call;
	}
	else
	{
		self.selectedCall = nil;
	}
	self.mapView = nil;
	
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
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
	self.mapView.showsUserLocation = YES;
	
	if(_reloadMapView)
	{
		_reloadMapView = NO;
		hasSavedRegion = NO;
		
		// we should blow away all markers and recreate them
		[self.mapView removeFromSuperview];
		self.mapView = nil;
		[self performSelector:@selector(loadMapView) withObject:nil afterDelay:0.3];
		
		_shouldReloadMarkers = NO;
	}
}

- (void)callChanged:(NSNotification *)notification
{
	MTCall *changedCall = notification.object;
	NSArray *markers = [self.mapView annotations];
	
	for(MapViewCallAnnotation *marker in markers)
	{
		if ([marker isKindOfClass:[MKUserLocation class]])
			continue;
		
		MTCall *theCall = (MTCall *)marker.call;
		if([theCall isEqual:changedCall])
		{
			[self.mapView removeAnnotation:marker];
			
			if(!changedCall.locationAquiredValue ||
 			   changedCall.deletedCallValue ||
			   [changedCall.locationLookupType isEqualToString:CallLocationTypeDoNotShow])
			{
				// dont insert the marker back, it should be hidden or not there
			}
			else
			{
				// insert the marker back in the moved position
				[self.mapView addAnnotation:marker];
			}

			return;
		}
	}

	// well this call does not exist, lets see if it needs to get added
	if(!changedCall.locationAquiredValue ||
	   changedCall.deletedCallValue ||
	   [changedCall.locationLookupType isEqualToString:CallLocationTypeDoNotShow])
	{
		// it shouldnt get added
		return;
	}

	// if this is a new call or a undeleted all, then add it to the map
	if(changedCall.locationAquiredValue)
	{
		MapViewCallAnnotation *marker = [[[MapViewCallAnnotation alloc] initWithCall:changedCall] autorelease];
		marker.animatesDrop = YES;
		[self.mapView addAnnotation:marker];
		if([[self.mapView annotations] count] == 1)
		{
			[self.mapView setRegion:MKCoordinateRegionMake(marker.coordinate , MKCoordinateSpanMake(0.01 , 0.01)) animated:YES];
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

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)theAnnotation
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

	NSDate *lastVisit = annotation.call.mostRecentReturnVisitDate;
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
    return annotationView;
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
	MapViewCallAnnotation *annotation = (MapViewCallAnnotation *)view.annotation;
	CallViewController *controller = [[[CallViewController alloc] initWithCall:annotation.call newCall:NO] autorelease];
	controller.delegate = self;
	selectedMarker = annotation;
	// push the element view controller onto the navigation stack to display it
	[[self navigationController] pushViewController:controller animated:YES];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// we support rotation in this view controller
	return YES;
}

@end
