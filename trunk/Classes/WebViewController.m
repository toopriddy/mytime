//
//  WebViewController.m
//  MyTime
//
//  Created by Brent Priddy on 8/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "WebViewController.h"
#import "Settings.h"

@implementation WebViewController
@synthesize webView;
@synthesize addresses;

- (id)initWithTitle:(NSString *)theTitle address:(NSDictionary *)address
{
	return [self initWithTitle:theTitle addresses:[NSArray arrayWithObject:address]];
}

- (id)initWithTitle:(NSString *)theTitle addresses:(NSArray *)theAddresses
{
	self = [super init];
	if (self)
	{
		// this title will appear in the navigation bar
		self.title = theTitle;
		self.addresses = theAddresses;
	}
	return self;
}

- (void)dealloc
{
	self.webView = nil;
	self.addresses = nil;
	
	
	[super dealloc];
}

- (void)loadView
{
#if 0
	// the base view for this view controller
	UIView *contentView = [[[UIView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]] autorelease];
	contentView.backgroundColor = [UIColor whiteColor];
	
	// important for view orientation rotation
	contentView.autoresizesSubviews = YES;
	contentView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);	
	
	self.view = contentView;
	
	CGRect webFrame = [contentView bounds];
	self.webView = [[UIWebView alloc] initWithFrame:webFrame];
#else
	self.webView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    webView.multipleTouchEnabled = YES;
	self.view = webView;
#endif
	webView.backgroundColor = [UIColor whiteColor];
	webView.scalesPageToFit = YES;
	webView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
	webView.delegate = self;
	//[self.view addSubview: webView];
	
	// create our progress indicator for busy feedback while loading web pages,
	// make it our custom right view in the navigation bar
	//
	CGRect frame = CGRectMake(0.0, 0.0, 25.0, 25.0);
	UIActivityIndicatorView *progressView = [[UIActivityIndicatorView alloc] initWithFrame:frame];
	progressView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleWhiteLarge;
	progressView.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin |
									UIViewAutoresizingFlexibleRightMargin |
									UIViewAutoresizingFlexibleTopMargin |
									UIViewAutoresizingFlexibleBottomMargin);
	
	UINavigationItem *navItem = self.navigationItem;
	UIBarButtonItem *buttonItem = [[[UIBarButtonItem alloc] initWithCustomView:progressView] autorelease];
	navItem.rightBarButtonItem = buttonItem;
	// we are done with these since the nav bar retains them:
	[progressView release];
	
	// start fetching the default web page
	[(UIActivityIndicatorView *)navItem.rightBarButtonItem.customView startAnimating];							
//	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.url]]];
//	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://mytime.googlecode.com/files/maptest5.html"]]];
	[webView loadRequest:[NSURLRequest requestWithURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"map" ofType:@"html"]]]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	// we support rotation in this view controller
	return YES;
}

#pragma mark UIWebView delegate methods

- (void)stopProgressIndicator
{
	UINavigationItem *navItem = self.navigationItem;
	UIActivityIndicatorView *progView = (UIActivityIndicatorView *)navItem.rightBarButtonItem.customView;
	[progView stopAnimating];
	progView.hidden = YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView
{
	UINavigationItem *navItem = self.navigationItem;
	
	UIActivityIndicatorView *progView = (UIActivityIndicatorView *)navItem.rightBarButtonItem.customView;
	[progView startAnimating];
	progView.hidden = NO;
}

- (void)webViewDidFinishLoad:(UIWebView *)theWebView
{
	[self stopProgressIndicator];


	NSEnumerator *e = [addresses objectEnumerator];
	NSDictionary *address;
	
	while ( (address = [e nextObject]) ) 
	{
		NSString *streetNumber = [address objectForKey:CallStreetNumber];
		NSString *street = [address objectForKey:CallStreet];
		NSString *city = [address objectForKey:CallCity];
		NSString *state = [address objectForKey:CallState];
		streetNumber = streetNumber ? streetNumber : @"";
		street = street ? street : @"";
		city = city ? city : @"";
		state = state ? state : @"";
		NSString *script = [NSString stringWithFormat:@"showAddress(\"%@ %@ %@ %@\");", streetNumber, street, city, state];
		NSLog(@"%@", script);
		if([theWebView stringByEvaluatingJavaScriptFromString:script] == nil)
		{
			NSLog(@"script failure");
		}
	}
}

- (void)webView:(UIWebView *)theWebView didFailLoadWithError:(NSError *)error
{
	[self stopProgressIndicator];

	// report the error inside the webview
	NSString* errorString = [NSString stringWithFormat:
							 @"<html><center><font size=+5 color='red'>An error occurred:<br>%@</font></center></html>",
							 error.localizedDescription];
	[webView loadHTMLString:errorString baseURL:nil];
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
