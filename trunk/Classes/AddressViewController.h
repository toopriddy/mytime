//
//  AddressViewController.h
//  MyTime
//
//  Created by Brent Priddy on 7/26/08.
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
#import "GenericTableViewController.h"
#import "AddressViewControllerDelegate.h"
#import "CoreLocation/CoreLocation.h"
#import "MapKit/MapKit.h"

@interface AddressViewController : GenericTableViewController <UIAlertViewDelegate,
                                                               CLLocationManagerDelegate,
                                                               MKReverseGeocoderDelegate> 
{
	id<AddressViewControllerDelegate> delegate;

	NSString *apartmentNumber;
	NSString *streetNumber;
    NSString *street;
    NSString *city;
    NSString *state;
	
	BOOL showReverseGeocoding;
	BOOL wasShowingReverseGeocoding;
	BOOL shouldAskAboutReverseGeocoding;
	UIAlertView *locationMessage;
	
	CLLocationManager *locationManager;
	MKReverseGeocoder *geocoder;
	MKPlacemark *placemark;
	
	NSDate *locationStartDate;
}

@property (nonatomic, assign) id<AddressViewControllerDelegate> delegate;
@property (nonatomic, retain) UIAlertView *locationMessage;
@property (nonatomic, retain) CLLocationManager *locationManager;
@property (nonatomic, retain) MKReverseGeocoder *geocoder;
@property (nonatomic, retain) MKPlacemark *placemark;
@property (nonatomic, retain) NSDate *locationStartDate;

@property (nonatomic, retain, readonly) NSString *apartmentNumber;
@property (nonatomic, retain, readonly) NSString *streetNumber;
@property (nonatomic, retain, readonly) NSString *street;
@property (nonatomic, retain, readonly) NSString *city;
@property (nonatomic, retain, readonly) NSString *state;



/**
 * initialize this view 
 *
 * @param rect - the rect
 * @returns self
 */
- (id) init;

/**
 * initialize this view with the address information
 *
 * @param rect - the rect
 * @returns self
 */
- (id) initWithStreetNumber:(NSString *)streetNumber apartment:(NSString *)apartment street:(NSString *)street city:(NSString *)city state:(NSString *)state askAboutReverseGeocoding:(BOOL)askAboutReverseGeocoding;

- (void)navigationControlDone:(id)sender;

@end




