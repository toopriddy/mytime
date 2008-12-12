//
//  MapViewController.h
//  MyTime
//
//  Created by Brent Priddy on 8/30/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapView.h"

@interface MapViewController : UIViewController <MapWebViewDelegate>
{
	MapView *webView;
	NSMutableDictionary *call;
	UIActivityIndicatorView *progView;
}

@property (nonatomic, retain) MapView *webView;
@property (nonatomic, retain) NSMutableDictionary *call;

- (id)initWithTitle:(NSString *)theTitle call:(NSMutableDictionary *)call;
- (id)initWithTitle:(NSString *)theTitle;

@end
