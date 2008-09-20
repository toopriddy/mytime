//
//  WebViewController.h
//  MyTime
//
//  Created by Brent Priddy on 8/12/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface WebViewController : UIViewController <UIWebViewDelegate>
{
	UIWebView *webView;
	NSArray *addresses;
}

@property (nonatomic, retain) UIWebView *webView;
@property (nonatomic, retain) NSArray *addresses;

- (id)initWithTitle:(NSString *)theTitle address:(NSDictionary *)address;
- (id)initWithTitle:(NSString *)theTitle addresses:(NSArray *)addresses;

@end
