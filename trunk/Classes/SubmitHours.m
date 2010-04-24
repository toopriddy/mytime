//
//  SubmitHours.m
//  MyTime
//
//  Created by Brent Priddy on 8/10/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "SubmitHours.h"
#import "Settings.h"
#import "HTTPServer.h"

@implementation SubmitHours

//
// load
//
// Implementing the load method and invoking
// [HTTPResponseHandler registerHandler:self] causes HTTPResponseHandler
// to register this class in the list of registered HTTP response handlers.
//
+ (void)load
{
	[HTTPResponseHandler registerHandler:self];
}

//
// canHandleRequest:method:url:headerFields:
//
// Class method to determine if the response handler class can handle
// a given request.
//
// Parameters:
//    aRequest - the request
//    requestMethod - the request method
//    requestURL - the request URL
//    requestHeaderFields - the request headers
//
// returns YES (if the handler can handle the request), NO (otherwise)
//
+ (BOOL)canHandleRequest:(CFHTTPMessageRef)aRequest
				  method:(NSString *)requestMethod
					 url:(NSURL *)requestURL
			headerFields:(NSDictionary *)requestHeaderFields
{
	if ([requestURL.path isEqualToString:@"/hours.html"])
	{
		return YES;
	}
	
	return NO;
}

- (void)sendPage
{
	NSString *errorString = nil;
	NSString *day = nil;
	NSString *month = nil;
	NSString *year = nil;
	NSString *hours = nil;
	NSString *minutes = nil;
	NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];

	for(NSDictionary *entry in self.variableArray)
	{
		if([@"day" isEqualToString:[entry objectForKey:MultipartVariableName]])
		{
			day = [entry objectForKey:MultipartVariableValue];
			[comps setDay:[day intValue]];
		}
		else if([@"month" isEqualToString:[entry objectForKey:MultipartVariableName]])
		{
			month = [entry objectForKey:MultipartVariableValue];
			[comps setMonth:[month intValue]];
		}
		else if([@"year" isEqualToString:[entry objectForKey:MultipartVariableName]])
		{
			year = [entry objectForKey:MultipartVariableValue];
			[comps setYear:[[entry objectForKey:MultipartVariableValue] intValue]];
		}
		else if([@"hours" isEqualToString:[entry objectForKey:MultipartVariableName]])
		{
			hours = [entry objectForKey:MultipartVariableValue];
		}
		else if([@"minutes" isEqualToString:[entry objectForKey:MultipartVariableName]])
		{
			minutes = [entry objectForKey:MultipartVariableValue];
		}
		
	}
	if(day && month && year && hours && minutes)
	{
		NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
		NSDate *date = [gregorian dateFromComponents:comps];
		NSMutableDictionary *entry = [NSMutableDictionary dictionary];
		[entry setObject:date forKey:SettingsTimeEntryDate];
		[entry setObject:[[[NSNumber alloc] initWithInt:([minutes intValue] + [hours intValue]*60)] autorelease] forKey:SettingsTimeEntryMinutes];
		
		NSMutableArray *timeEntries = [[[Settings sharedInstance] userSettings] objectForKey:SettingsTimeEntries];
		if(timeEntries == nil)
		{
			timeEntries = [NSMutableArray array];
			[[[Settings sharedInstance] userSettings] setObject:timeEntries forKey:SettingsTimeEntries];
		}
		[timeEntries addObject:entry];
		[[Settings sharedInstance] saveData];
	}
	NSData *fileData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"]];
	CFHTTPMessageRef response = CFHTTPMessageCreateResponse(kCFAllocatorDefault, 200, NULL, kCFHTTPVersion1_0);
	CFHTTPMessageSetHeaderFieldValue(response, (CFStringRef)@"Content-Type", (CFStringRef)@"text/html");
	CFHTTPMessageSetHeaderFieldValue(response, (CFStringRef)@"Connection", (CFStringRef)@"close");
	CFHTTPMessageSetHeaderFieldValue(response,
									 (CFStringRef)@"Content-Length",
									 (CFStringRef)[NSString stringWithFormat:@"%ld", fileData.length + errorString.length]);
	CFDataRef headerData = CFHTTPMessageCopySerializedMessage(response);
	
	@try
	{
		[fileHandle writeData:(NSData *)headerData];
		[fileHandle writeData:[errorString dataUsingEncoding:NSUTF8StringEncoding]];
		[fileHandle writeData:fileData];
	}
	@catch (NSException *exception)
	{
		// Ignore the exception, it normally just means the client
		// closed the connection from the other end.
	}
	@finally
	{
		CFRelease(response);
		CFRelease(headerData);
		[server closeHandler:self];
	}
}

@end
