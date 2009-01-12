//
//  MapViewController.h
//  MyTime
//
//  Created by Brent Priddy on 8/30/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapView.h"

@interface GeocacheViewController : UIView <MapWebViewDelegate>
{
	MapView *mapView;
	NSMutableDictionary *call;
	UIActivityIndicatorView *progressView;
}

@property (nonatomic, retain) MapView *mapView;
@property (nonatomic, retain) NSMutableDictionary *call;
@property (nonatomic, retain) UIActivityIndicatorView *progressView;

- (id)initWithCall:(NSMutableDictionary *)call;

@end
