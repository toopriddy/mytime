//
//  MapViewController.m
//  MyTime
//
//  Created by Brent Priddy on 8/30/08.
//  Copyright 2008 PG Software. All rights reserved.
//

#import "WebMapViewController.h"
#import "Settings.h"

@implementation WebMapViewController
@synthesize mapView;
@synthesize call;

- (id)initWithTitle:(NSString *)theTitle call:(NSMutableDictionary *)theCall
{
	self = [super init];
	if (self)
	{
		// this title will appear in the navigation bar
		self.title = theTitle;
		self.call = theCall;

		self.tabBarItem.image = [UIImage imageNamed:@"map.png"];
	}
	return self;
}

- (id)initWithTitle:(NSString *)theTitle
{
	self = [super init];
	if (self)
	{
		// this title will appear in the navigation bar
		self.title = theTitle;
		self.call = nil;

		self.tabBarItem.image = [UIImage imageNamed:@"map.png"];
	}
	return self;
}

- (void)dealloc
{
	self.mapView = nil;
	self.call = nil;
	
	
	[super dealloc];
}

- (void)loadView
{
	self.mapView = [[MapView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    mapView.multipleTouchEnabled = YES;
	self.view = mapView;

	mapView.backgroundColor = [UIColor whiteColor];
	mapView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	mapView.map.mDelegate = self;
	
	//[self.view addSubview: mapView];
	
	// create our progress indicator for busy feedback while loading web pages,
	// make it our custom right view in the navigation bar
	//
	CGRect frame = CGRectMake(0.0, 0.0, 25.0, 25.0);
	progView = [[UIActivityIndicatorView alloc] initWithFrame:frame];
	progView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	progView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
									UIViewAutoresizingFlexibleRightMargin |
									UIViewAutoresizingFlexibleTopMargin |
									UIViewAutoresizingFlexibleBottomMargin);
	
	UINavigationItem *navItem = self.navigationItem;
	UIBarButtonItem *buttonItem = [[[UIBarButtonItem alloc] initWithCustomView:progView] autorelease];
	navItem.rightBarButtonItem = buttonItem;
	// we are done with these since the nav bar retains them:
	
	// start fetching the default web page
	[progView startAnimating];							
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// we support rotation in this view controller
	return YES;
}

#define EMPTY_NSSTRING_IF_NULL(str) ((str) ? (str) : @"")
- (NSString *)getAddressFromCall:(NSMutableDictionary *)theCall useHtml:(BOOL)useHtml
{
	NSString *streetNumber = [theCall objectForKey:CallStreetNumber];
	NSString *apartmentNumber = [theCall objectForKey:CallApartmentNumber];
	NSString *street = [theCall objectForKey:CallStreet];
	NSString *city = [theCall objectForKey:CallCity];
	NSString *state = [theCall objectForKey:CallState];
	NSString *seperator = useHtml ? @"<br>" : @"";
	
	if(street && [street length] && 
	   city && [city length] && 
	   state && [state length])
	{
		apartmentNumber = EMPTY_NSSTRING_IF_NULL(apartmentNumber);
		if(apartmentNumber.length)
			apartmentNumber = [NSString stringWithFormat:@"(%@)", apartmentNumber];
		streetNumber = EMPTY_NSSTRING_IF_NULL(streetNumber);
		street = EMPTY_NSSTRING_IF_NULL(street);
		city = EMPTY_NSSTRING_IF_NULL(city);
		state = EMPTY_NSSTRING_IF_NULL(state);
		return([NSString stringWithFormat:@"%@ %@ %@ %@%@, %@", streetNumber, apartmentNumber, street, seperator, city, state]);
	}
	return(nil);
}

- (NSString *)getInfoFromCall:(NSMutableDictionary *)theCall 
{
	NSString *name = [theCall objectForKey:CallName];
	NSString *address = [self getAddressFromCall:theCall useHtml:YES];
	if(name || address)
	{
		name = EMPTY_NSSTRING_IF_NULL(name);
		address = EMPTY_NSSTRING_IF_NULL(address);
		return([NSString stringWithFormat:@"%@ %@", name, address]);
	}
	return(@"");
}



#pragma mark UIWebView delegate methods

- (void)stopProgressIndicator
{
	[progView stopAnimating];

	// add Start Time button
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Reload", @"'Reload' navigation bar action button for the Mapped Calls view")
																style:UIBarButtonItemStylePlain
															   target:mapView.mMapWebView
															   action:@selector(reload)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:YES];
}

- (void)mapViewDidStartLoad:(MapWebView *)mapView
{	
	UIBarButtonItem *buttonItem = [[[UIBarButtonItem alloc] initWithCustomView:progView] autorelease];
	[self.navigationItem setRightBarButtonItem:buttonItem animated:YES];
	[progView startAnimating];
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
		return;
	}
	else
	{
		NSString *latLong = [mapView.map evalJS:[NSString stringWithFormat:@"getResult(%d)", iter]];
		NSString *address = [mapView.map evalJS:[NSString stringWithFormat:@"getAddress(%d)", iter]];
		NSMutableDictionary *foundCall = call;
		if(foundCall == nil)
		{
			NSEnumerator *e = [[[[Settings sharedInstance] settings] objectForKey:SettingsCalls] objectEnumerator];
			
			while ( (foundCall = [e nextObject]) ) 
			{
				NSString *str = [self getAddressFromCall:foundCall useHtml:NO];
				if(str && [str isEqualToString:address])
				{
					break;
				}
			}
		}
		if(foundCall)
		{
			[foundCall setObject:latLong forKey:CallLattitudeLongitude];
			[[Settings sharedInstance] saveData];
		}
	}

	[self performSelector:@selector(timer) withObject:self afterDelay:1.0];
}

- (void)mapViewDidFinishLoad:(MapWebView *)theWebView
{
	BOOL found = NO;
	
	[self stopProgressIndicator];

	if(call)
	{
		NSString *str = [self getAddressFromCall:call useHtml:NO];
		NSString *info = [self getInfoFromCall:call];
		if(str)
		{
			NSString *latLong = [call objectForKey:CallLattitudeLongitude];
			if(latLong)
			{
				NSString *script = [NSString stringWithFormat:@"showAddress(\"%@\", %@)", info, latLong];
				VERBOSE(NSLog(@"%@", script);)
				if([theWebView evalJS:script] == nil)
				{
					NSLog(@"script failure");
				}
			}
			else
			{
				NSString *script = [NSString stringWithFormat:@"findAddress(\"%@\", \"%@\");", info, str];
				VERBOSE(NSLog(@"%@", script);)
				
				if([theWebView evalJS:script] == nil)
				{
					NSLog(@"script failure");
				}
				found = YES;
			}
		}
	}
	else
	{
		NSEnumerator *e = [[[[Settings sharedInstance] settings] objectForKey:SettingsCalls] objectEnumerator];
		NSMutableDictionary *theCall;
		
		while ( (theCall = [e nextObject]) ) 
		{
			NSString *str = [self getAddressFromCall:theCall useHtml:NO];
			NSString *info = [self getInfoFromCall:theCall];
			if(str)
			{
				NSString *latLong = [theCall objectForKey:CallLattitudeLongitude];
				if(latLong)
				{
					NSString *script = [NSString stringWithFormat:@"showAddress(\"%@\", %@);", info, latLong];
					VERBOSE(NSLog(@"%@", script);)
					if([theWebView evalJS:script] == nil)
					{
						NSLog(@"script failure");
					}
				}
				else
				{
					NSString *script = [NSString stringWithFormat:@"findAddress(\"%@\", \"%@\");", info, str];
					VERBOSE(NSLog(@"%@", script);)
					
					if([theWebView evalJS:script] == nil)
					{
						NSLog(@"script failure");
					}
					found = YES;
				}
			}
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

