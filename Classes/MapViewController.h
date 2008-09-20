//
//  MapViewController.h
//  MyTime
//
//  Created by Brent Priddy on 8/30/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MapView.h"

@interface MapViewController : UIViewController <MapWebViewDelegate>
{
	MapView *webView;
	NSMutableDictionary *call;
}

@property (nonatomic, retain) MapView *webView;
@property (nonatomic, retain) NSMutableDictionary *call;

- (id)initWithTitle:(NSString *)theTitle call:(NSMutableDictionary *)call;
- (id)initWithTitle:(NSString *)theTitle;

@end
