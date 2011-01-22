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

#import "GeocacheViewController.h"
#import "NSObject+PriddySoftware.h"
#import "NSManagedObjectContext+PriddySoftware.h"

@implementation GeocacheViewController
@synthesize mapView;
@synthesize call;
@synthesize progressView;
@synthesize delegate = _delegate;

- (id)initWithCall:(MTCall *)theCall
{
	CGRect frame = CGRectMake(0.0, 0.0, 25.0, 25.0);
	self = [super initWithFrame:frame];
	if (self)
	{
		inProgress = YES;
		self.call = theCall;
		self.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
									UIViewAutoresizingFlexibleRightMargin |
									UIViewAutoresizingFlexibleTopMargin |
									UIViewAutoresizingFlexibleBottomMargin);

		
		self.mapView = [[MapView alloc] initWithFrame:frame];
		[self addSubview:mapView];
		mapView.backgroundColor = [UIColor whiteColor];
		mapView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
		mapView.map.mDelegate = self;
		mapView.hidden = YES;

		// create our progress indicator for busy feedback while loading web pages,
		// make it our custom right view in the navigation bar
		//
		progressView = [[UIActivityIndicatorView alloc] initWithFrame:frame];
		// create our progress indicator for busy feedback while loading web pages,
		// make it our custom right view in the navigation bar
		//
		progressView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
		progressView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
										UIViewAutoresizingFlexibleRightMargin |
										UIViewAutoresizingFlexibleTopMargin |
										UIViewAutoresizingFlexibleBottomMargin);

		
		// add the progressView over the map view behind
		[self addSubview:progressView];

		// start fetching the default web page
		[[[UIApplication sharedApplication] mainThreadProxy] setNetworkActivityIndicatorVisible:YES];
		[progressView startAnimating];							
	}
	return self;
}

- (void)dealloc
{
	mapView.map.mDelegate = nil;
	self.mapView = nil;
	self.call = nil;
	
	[super dealloc];
}

#define EMPTY_NSSTRING_IF_NULL(str) ((str) ? (str) : @"")
+ (NSString *)getAddressFromCall:(MTCall *)call useHtml:(BOOL)useHtml
{
	NSString *apartmentNumber = call.apartmentNumber;
	NSString *streetNumber = call.houseNumber; // for some reason if this call is first 3.0 devices will bomb.
	NSString *street = call.street;
	NSString *city = call.city;
	NSString *state = call.state;
	NSString *seperator = useHtml ? @"<br>" : @"";
	
	if(street && [street length] && 
	   city && [city length] && 
	   state && [state length])
	{
		apartmentNumber = EMPTY_NSSTRING_IF_NULL(apartmentNumber);
		if(apartmentNumber.length)
			apartmentNumber = [NSString stringWithFormat:@"(%@)", apartmentNumber];
		streetNumber = EMPTY_NSSTRING_IF_NULL(streetNumber);
		if(streetNumber.length)
			apartmentNumber = @"";
		street = EMPTY_NSSTRING_IF_NULL(street);
		city = EMPTY_NSSTRING_IF_NULL(city);
		state = EMPTY_NSSTRING_IF_NULL(state);
		return([NSString stringWithFormat:@"%@ %@ %@ %@%@, %@", streetNumber, apartmentNumber, street, seperator, city, state]);
	}
	return(nil);
}

+ (NSString *)getInfoFromCall:(MTCall *)call 
{
	NSString *name = call.name;
	NSString *address = [self getAddressFromCall:call useHtml:YES];
	if(name || address)
	{
		name = EMPTY_NSSTRING_IF_NULL(name);
		address = EMPTY_NSSTRING_IF_NULL(address);
		return([NSString stringWithFormat:@"%@ %@", name, address]);
	}
	return(@"");
}

- (void)layoutSubviews
{
	[super layoutSubviews];
}

+ (BOOL)canLookupCall:(MTCall *)call
{
	return [GeocacheViewController getAddressFromCall:call useHtml:NO] != NULL;
}

#pragma mark UIWebView delegate methods

- (void)stopProgressIndicator
{
	[[[UIApplication sharedApplication] mainThreadProxy] setNetworkActivityIndicatorVisible:NO];
	[progressView stopAnimating];
}

- (void)mapViewDidStartLoad:(MapWebView *)mapView
{	
	[[[UIApplication sharedApplication] mainThreadProxy] setNetworkActivityIndicatorVisible:YES];
	[progressView startAnimating];
}

- (void)timer
{
	NSInteger iter = [[mapView.map evalJS:@"getNextResult()"] intValue];
	if(iter == -2)
	{
		// there are unresolved addresses, keep going
	}
	else if(iter == -1)
	{
		// all done, dont need to keep calling the timer
		[self stopProgressIndicator];
		inProgress = NO;
		if(_delegate && [_delegate respondsToSelector:@selector(geocacheViewControllerDone:)])
		{
			[_delegate geocacheViewControllerDone:self];
		}

		return;
	}
	else
	{
		NSString *latLong = [mapView.map evalJS:[NSString stringWithFormat:@"getResult(%d)", iter]];
		NSString *address = [mapView.map evalJS:[NSString stringWithFormat:@"getAddress(%d)", iter]];
		BOOL isAddressLookup = [[mapView.map evalJS:[NSString stringWithFormat:@"getIsAddressLookup(%d)", iter]] boolValue];
		
		// make sure the address has not changed
		if(isAddressLookup && [address isEqualToString:[[self class] getAddressFromCall:call useHtml:NO]])
		{
			if(latLong == nil || [latLong isEqualToString:@"nil"])
			{
				call.locationAquiredValue = NO;
				call.locationAquisitionAttemptedValue = YES;
			}
			else
			{
				NSArray *stringArray = [latLong componentsSeparatedByString:@", "];
				if(stringArray.count == 2)
				{
					call.lattitude = [NSDecimalNumber decimalNumberWithString:[stringArray objectAtIndex:0]];
					call.longitude = [NSDecimalNumber decimalNumberWithString:[stringArray objectAtIndex:1]];
					call.locationAquisitionAttemptedValue = YES;
					call.locationAquiredValue = YES;
				}
				else
				{
					// something was malformed... look it up again
					call.locationAquiredValue = NO;
					call.locationAquisitionAttemptedValue = NO;
				}
				
			}
			
			NSError *error = nil;
			if (![call.managedObjectContext save:&error]) 
			{
				[NSManagedObjectContext presentErrorDialog:error];
			}			
		}
	}
	[self performSelector:@selector(timer) withObject:self afterDelay:1.0];
}

- (void)mapViewDidFinishLoad:(MapWebView *)theWebView
{
	BOOL found = NO;
	
	NSString *str = [GeocacheViewController getAddressFromCall:call useHtml:NO];
	if(str)
	{
		NSString *info = [GeocacheViewController getInfoFromCall:call];
		NSString *script = [NSString stringWithFormat:@"findLocationFromAddress(\"%@\", \"%@\");", info, str];
		VERBOSE(NSLog(@"%@", script);)
		
		if([theWebView evalJS:script] == nil)
		{
			NSLog(@"script failure");
		}
		found = YES;
	}
	else
	{
		[self stopProgressIndicator];
		if(_delegate && [_delegate respondsToSelector:@selector(geocacheViewControllerDone:)])
		{
			[_delegate geocacheViewControllerDone:self];
		}
	}
	if(found)
	{
		[self performSelector:@selector(timer) withObject:self afterDelay:1.0];
	}
}

- (void) mapView:(MapWebView *)theWebView didFailLoadWithError:(NSError *)error;
{
	[self stopProgressIndicator];

	// report the error inside the webview
	NSString* errorString = [NSString stringWithFormat:
							 @"<html><center><font size=+5 color='red'>An error occurred:<br>%@</font></center></html>",
							 error.localizedDescription];
	[theWebView loadHTMLString:errorString baseURL:nil];
}

- (void) mapZoomUpdatedTo:(int)zoomLevel
{
}

- (void) mapCenterUpdatedToLatLng:(GLatLng)latlng
{
}

- (void) mapCenterUpdatedToPixel:(GPoint)pixel
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



@end

// ABQIAAAA8ZaIKMZcvWHNxFL4rpcPlxR4MgLgohEpMJOdpRIqyc07Qp4zFRRNU4wM18YEuS7Vh24_NSPNY8OJVA



#if 0
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
  <title>Google Maps JavaScript API Example - simple</title>
  <script src="http://maps.google.com/maps?file=api&v=1&key=ABQIAAAAy6MBiqsAuMYcRcIXE-SdkhQI513BVj7Itr7WPMGFabbrMAySrRTqrYgzCD2NDBq2Npe_EDAW--Is2A" type="text/javascript"></script>

<!-- Make the document body take up the full screen --> <style type="text/css"> v\:* {behavior:url(#default#VML);} html, body {width: 100%; height: 100%} body {margin-top: 0px; margin-right: 0px; margin-left: 0px; margin-bottom: 0px} </style>

</head>
<body>

  <!-- Declare the div, make it take up the full document body -->
  <div id="map" style="width: 100%; height: 100%;"></div>

  <script type="text/javascript">
    //<![CDATA[        

    var map;
    if (GBrowserIsCompatible()) {
      map = new GMap(document.getElementById("map"));
      map.centerAndZoom(new GPoint(-122.141944, 36.441944), 4);

// Monitor the window resize event and let the map know when it occurs if (window.attachEvent) { window.attachEvent("onresize", function() {this.map.onResize()} ); } else { window.addEventListener("resize", function() {this.map.onResize()} , false); }

    }

    //]]>
  </script>

</body></html>

#endif

