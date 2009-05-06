//
//  OverlayViewController.m
//  TableView
//
//  Created by iPhone SDK Articles on 1/17/09.
//  Copyright www.iPhoneSDKArticles.com 2009. 
//

#import "OverlayViewController.h"

@implementation OverlayViewController

@synthesize delegate;

- (id)init
{
	[super init];
	
	self.view = [[UIView alloc] init];
	[self.view release];
	
	return self;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	if(delegate && [delegate respondsToSelector:@selector(overlayViewControllerDone:)])
	{
		[delegate overlayViewControllerDone:self];
	}
}

@end
