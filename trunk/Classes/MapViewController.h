//
//  MapViewController.h
//  MyTime
//
//  Created by Brent Priddy on 8/30/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
//#define USEMAPVIEW

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
	
	RMMarker *selectedMarker;
}

@property (nonatomic, retain) MapViewCallDetailController *detailView;
@property (nonatomic, retain) RMMapView *mapView;
@property (nonatomic, retain) NSMutableDictionary *call;

- (id)initWithTitle:(NSString *)theTitle call:(NSMutableDictionary *)call;
- (id)initWithTitle:(NSString *)theTitle;

- (NSString *)getAddressFromCall:(NSMutableDictionary *)theCall useHtml:(BOOL)useHtml;
- (NSString *)getInfoFromCall:(NSMutableDictionary *)theCall;

@end
