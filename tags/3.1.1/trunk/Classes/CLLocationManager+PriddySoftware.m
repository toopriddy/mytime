//
//  CLLocationManager+PriddySoftware.m
//  MyTime
//
//  Created by Brent Priddy on 7/27/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import "CLLocationManager+PriddySoftware.h"


@implementation CLLocationManager (PriddySoftware)

+ (BOOL)psLocationServicesEnabled
{
	BOOL locationAccessAllowed = NO ;
	if( [CLLocationManager respondsToSelector:@selector(locationServicesEnabled)] )
	{
		// iOS 4.x
		locationAccessAllowed = [CLLocationManager locationServicesEnabled] ;
	}
	else if( [CLLocationManager instancesRespondToSelector:@selector(locationServicesEnabled)] )
	{
		CLLocationManager *locationManager = [[CLLocationManager alloc] init];
		// iOS 3.x and earlier
		locationAccessAllowed = locationManager.locationServicesEnabled;
		[locationManager release];
	}
	return locationAccessAllowed;
}

@end
