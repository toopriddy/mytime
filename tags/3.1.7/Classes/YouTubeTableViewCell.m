//
//  YouTubeTableViewCell.m
//  MyTime
//
//  Created by Brent Priddy on 9/14/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import "YouTubeTableViewCell.h"


@implementation YouTubeTableViewCell
@synthesize webView;
@synthesize label;

- (void)setYouTubeVideo:(NSString *)urlString
{
	NSString *embedHTML = @"\
    <html><script type=\"text/javascript\">\
    //<![CDATA[        \
	function playVideo() {var evt = document.createEvent('MouseEvents');\
	evt.initMouseEvent('click', true, true, document.defaultView, 1, 0, 0, 0, 0, false, false, false, false, 0, document.body);\
	document.body.dispatchEvent(evt);}\
    //]]>\
	</script>\
	<head>\
	<style type=\"text/css\">\
	body {\
	background-color: transparent;\
	color: white;\
	}\
	</style>\
	</head><body style=\"margin:0\">\
    <embed id=\"yt\" src=\"%@\" type=\"application/x-shockwave-flash\" \
	width=\"%0.0f\" height=\"%0.0f\"></embed>\
    </body></html>";
	CGRect frame = self.webView.frame;
	NSString *html = [NSString stringWithFormat:embedHTML, urlString, frame.size.width, frame.size.height];
	[self.webView loadHTMLString:html baseURL:nil];
}

- (void)playVideo
{
//	[self.webView stringByEvaluatingJavaScriptFromString:@"playVideo();"];
	[self.webView stringByEvaluatingJavaScriptFromString:@"document.getElementById(\"yt\").click();"];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {

    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (void)dealloc 
{
	self.webView = nil;
	self.label = nil;
    [super dealloc];
}


@end
