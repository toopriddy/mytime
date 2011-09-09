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
#import "CallViewController.h"
#import "CLLocationManager+PriddySoftware.h"
#import "PSLocalization.h"

@implementation SelectPositionAnnotation
@synthesize coordinate;
@synthesize title;
- (id)initWithCoordinate:(CLLocationCoordinate2D)c
{
	if( (self = [super init]) )
	{
		coordinate = c;
		self.title = @"";
	}
	return self;
}

- (void)setCoordinate:(CLLocationCoordinate2D)newCoordinate
{
	coordinate = newCoordinate;
}

- (void)dealloc
{
	self.title = nil;
	
	[super dealloc];
}
@end

@interface MyMKMapView : MKMapView
{
	SelectPositionMapViewController *controller;
}
@end

@implementation MyMKMapView

- (void)setController:(SelectPositionMapViewController *)it
{
	controller = it;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event;
{
	if(controller)
	{
		CLLocationCoordinate2D coordinate = [self convertPoint:point toCoordinateFromView:self];
		SelectPositionAnnotation *marker = [controller marker];
		MKAnnotationView *view = [self viewForAnnotation:marker];
		[marker setCoordinate:coordinate];
		[view setNeedsDisplay];
	}
	return [super hitTest:point withEvent:event];
}
@end


@implementation SelectPositionMapViewController
@synthesize mapView;
@synthesize marker;
@synthesize point;
@synthesize delegate;

- (id)initWithPosition:(CLLocationCoordinate2D *)position defaultPosition:(CLLocationCoordinate2D)defaultPosition
{
	self = [super init];
	if (self)
	{
		// this title will appear in the navigation bar
		self.title = NSLocalizedString(@"Select Location", @"Title for the view where you manually select the location for the call");
		markerMoved = NO;
		
		pointInitalized = position != nil;
		if(position)
		{
			markerMoved = YES; // if the user had already selected the position, then dont move it around
			point = *position;
		}
		else
		{
			defaultPointInitalized = YES;
			point = defaultPosition;
		}
	}
	return self;
}

- (void)dealloc
{
	self.marker = nil;
	self.mapView = nil;
	
	[super dealloc];
}

- (void)navigationControlDone:(id)sender 
{
	VERBOSE(NSLog(@"navigationControlDone:");)
	
	point = self.marker.coordinate;
	// save this position
	
	if(delegate && [delegate respondsToSelector:@selector(selectPositionMapViewControllerDone:)])
	{
		[delegate selectPositionMapViewControllerDone:self];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
	[self.mapView selectAnnotation:self.marker animated:YES];
}

- (void)loadMapView
{
	MyMKMapView *it = [[[MyMKMapView alloc] initWithFrame:self.view.bounds] autorelease];
	
	id temp = [[[SelectPositionAnnotation alloc] initWithCoordinate:point] autorelease];
	MKPinAnnotationView *annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:temp reuseIdentifier:@""] autorelease];
	if(![annotationView respondsToSelector:@selector(setDraggable:)])
	{
		[it setController:self];
	}
	it.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	self.mapView = it;
	[self.mapView setRegion:MKCoordinateRegionMake(point, MKCoordinateSpanMake(0.001 , 0.001)) animated:YES];
	self.mapView.delegate = self;

	[self.view addSubview:mapView];
		
	if(pointInitalized)
	{
		if(self.marker == nil)
		{
			self.marker = [[[SelectPositionAnnotation alloc] initWithCoordinate:point] autorelease];
			[self.mapView addAnnotation:self.marker];
		}
		self.marker.title = NSLocalizedString(@"Move me", @"title for the marker when you have to manually set the location for a call");
		[self.mapView selectAnnotation:self.marker animated:YES];
		[self.mapView setRegion:MKCoordinateRegionMake(point , MKCoordinateSpanMake(0.001 , 0.001)) animated:YES];
	}
	else
	{
		if(!markerMoved)
		{
			if(self.marker == nil)
			{
				self.marker = [[[SelectPositionAnnotation alloc] initWithCoordinate:point] autorelease];
				[self.mapView addAnnotation:self.marker];
			}
			if([CLLocationManager psLocationServicesEnabled])
			{
				self.marker.title = NSLocalizedString(@"Acquiring Location...", @"title for the marker when you have to manually set the location for a call");
			}
			else
			{
				self.marker.title = NSLocalizedString(@"Move me", @"title for the marker when you have to manually set the location for a call");
			}

			[self.mapView selectAnnotation:self.marker animated:YES];
			[self.mapView setRegion:MKCoordinateRegionMake(point , MKCoordinateSpanMake(0.001 , 0.001)) animated:YES];
		}
	}

	if([CLLocationManager psLocationServicesEnabled])
	{
		self.mapView.showsUserLocation = YES;
	}
	// add DONE button
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(navigationControlDone:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:NO];
}

- (MKAnnotationView *)mapView:(MKMapView *)map viewForAnnotation:(id <MKAnnotation>)annotation
{
    static NSString *AnnotationViewID = @"annotationViewID";
    // if it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
	
    MKPinAnnotationView *annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    if (annotationView == nil)
    {
        annotationView = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID] autorelease];
    }
    annotationView.animatesDrop = !markerDropped;
	markerDropped = YES;
    annotationView.annotation = annotation;
	if([annotationView respondsToSelector:@selector(setDraggable:)])
	{
		annotationView.draggable = YES;
	}
	annotationView.canShowCallout = YES;
  
    return annotationView;
}

- (void)loadView
{
	self.view = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
	self.view.backgroundColor = [UIColor blackColor];
	self.view.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	
	
	// load the map after it slides in
	[self performSelector:@selector(loadMapView) withObject:nil afterDelay:0.3];
}

// Called when the location is updated
- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
{
	CLLocation *newLocation = userLocation.location;
	// Horizontal coordinates
	if (signbit(newLocation.horizontalAccuracy)) 
	{
		// Negative accuracy means an invalid or unavailable measurement
		if(self.marker == nil)
		{
			self.marker = [[[SelectPositionAnnotation alloc] initWithCoordinate:newLocation.coordinate] autorelease];
			self.marker.title = NSLocalizedString(@"Move me", @"title for the marker when you have to manually set the location for a call");
			[self.mapView addAnnotation:self.marker];
			[self.mapView setRegion:MKCoordinateRegionMake(newLocation.coordinate , MKCoordinateSpanMake(0.001 , 0.001)) animated:YES];
		}
		self.marker.title = NSLocalizedString(@"Location Unavaliable, please move me", @"title for the marker when you have to manually set the location for a call");
		[self.mapView selectAnnotation:self.marker animated:YES];
		[[self.mapView viewForAnnotation:self.marker] setNeedsDisplay];
	} 
	else 
	{
		if(self.marker == nil)
		{
			self.marker = [[[SelectPositionAnnotation alloc] initWithCoordinate:newLocation.coordinate] autorelease];
			[self.mapView addAnnotation:self.marker];
			markerMoved = NO; // just in case
		}
		self.marker.title = NSLocalizedString(@"Move me", @"title for the marker when you have to manually set the location for a call");
		[self.mapView selectAnnotation:self.marker animated:YES];
		
		MKAnnotationView *annotationView = [self.mapView viewForAnnotation:self.marker];
		[annotationView setNeedsDisplay];
		if(!markerMoved)
		{
			point = newLocation.coordinate;

			self.marker.coordinate = point;
			[[self.mapView viewForAnnotation:self.marker] setNeedsDisplay];
			[self.mapView setRegion:MKCoordinateRegionMake(newLocation.coordinate , MKCoordinateSpanMake(0.001 , 0.001)) animated:YES];
		}
	}
}


// Called when there is an error getting the location
- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
	if(self.marker == nil)
	{
		self.marker = [[[SelectPositionAnnotation alloc] initWithCoordinate:CLLocationCoordinate2DMake(34 , -86)] autorelease];
		[self.mapView addAnnotation:self.marker];
	}
	self.marker.title =  NSLocalizedString(@"Location Unavaliable, please move me", @"title for the marker when you have to manually set the location for a call");
	[self.mapView selectAnnotation:self.marker animated:YES];
}

- (void)mapView:(MKMapView *)mapView 
 annotationView:(MKAnnotationView *)annotationView 
didChangeDragState:(MKAnnotationViewDragState)newState 
   fromOldState:(MKAnnotationViewDragState)oldState
{
	if(newState == MKAnnotationViewDragStateStarting)
	{
		markerMoved = YES;
	}
	else if(newState == MKAnnotationViewDragStateCanceling || newState == MKAnnotationViewDragStateEnding)
	{
		point = self.marker.coordinate;
	}
}

@end


