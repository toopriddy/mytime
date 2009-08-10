//
//  MyTimeWebServerView.m
//  MyTime
//
//  Created by Brent Priddy on 8/10/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//

#import "MyTimeWebServerView.h"
#import "HTTPServer.h"
#include <ifaddrs.h> 
#include <arpa/inet.h>

@implementation MyTimeWebServerView

- (NSString *)getIPAddress 
{ 
	NSString *address = nil; 
	struct ifaddrs *interfaces = NULL; 
	struct ifaddrs *temp_addr = NULL; 
	int success = 0; 
	// retrieve the current interfaces - returns 0 on success  
	success = getifaddrs(&interfaces); 
	if (success == 0)  
	{ // Loop through linked list of interfaces  
		temp_addr = interfaces; 
		while(temp_addr != NULL)  
		{ 
			if(temp_addr->ifa_addr->sa_family == AF_INET)  
			{ // Check if interface is en0 which is the wifi connection on the iPhone 
				if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]  
				 || [[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en1"])  
				{ // Get NSString from C String  
					address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)]; 
				} 
			} 
			temp_addr = temp_addr->ifa_next; 
		} 
	} // Free memory  
	freeifaddrs(interfaces); 
	return address; 
} 

- (id)init
{
	if (self = [super init]) 
	{
		[self autoresizesSubviews];
		self.autoresizingMask = UIViewAutoresizingFlexibleHeight;
		[self addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel button")];
		NSString *address = [self getIPAddress];
		if(address == nil)
		{
			self.title = NSLocalizedString(@"You need ot be on a Wifi Network for the MyTime Webserver to work", @"these are the instructions for connecting to the MyTime web server from the Settings View");
		}
		else
		{
			self.title = [NSString stringWithFormat:NSLocalizedString(@"Make sure you are on the same network as your iPhone/iPod then open a web browser and type in \"http://%@:8080\" as the location.", @"these are the instructions for connecting to the MyTime web server from the Settings View"), address];
		}
		self.delegate = self;
	}
	[[HTTPServer sharedHTTPServer] start];
	
	
	return self;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
	[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
	alertSheet.title = [NSString stringWithFormat:NSLocalizedString(@"Please quit MyTime if you changed any data using the MyTime Webserver", @"This message is displayed after you turn off the MyTime Webserver from the Settings View")];
	[alertSheet show];
}


- (void)dealloc 
{
	[[HTTPServer sharedHTTPServer] stop];
	[super dealloc];
}


@end
