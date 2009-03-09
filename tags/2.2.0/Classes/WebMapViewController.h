//
//  MapViewController.h
//  MyTime
//
//  Created by Brent Priddy on 8/30/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapView.h"

@interface WebMapViewController : UIViewController <MapWebViewDelegate>
{
	MapView *mapView;
	NSMutableDictionary *call;
	UIActivityIndicatorView *progView;
}

@property (nonatomic, retain) MapView *mapView;
@property (nonatomic, retain) NSMutableDictionary *call;

- (id)initWithTitle:(NSString *)theTitle call:(NSMutableDictionary *)call;
- (id)initWithTitle:(NSString *)theTitle;

@end
