//
//  SubmitNewCall.m
//  MyTime
//
//  Created by Brent Priddy on 8/10/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//

#import "SubmitNewCall.h"
#import "Settings.h"


@implementation SubmitNewCall

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
	if ([requestURL.path isEqualToString:@"/addCall.html"])
	{
		return YES;
	}
	
	return NO;
}

- (void)sendPage
{
	NSString *errorString = nil;
	NSMutableDictionary *call = [NSMutableDictionary dictionary];
	NSMutableArray *returnVisits = [NSMutableArray array];
	[call setObject:returnVisits forKey:CallReturnVisits];
	int found = 0;
	for(NSDictionary *entry in self.variableArray)
	{
		if([@"name" isEqualToString:[entry objectForKey:MultipartVariableName]])
		{
			[call setObject:[entry objectForKey:MultipartVariableValue] forKey:CallName];
			found++;
		}
		else if([@"apartment" isEqualToString:[entry objectForKey:MultipartVariableName]])
		{
			[call setObject:[entry objectForKey:MultipartVariableValue] forKey:CallApartmentNumber];
			found++;
		}
		else if([@"number" isEqualToString:[entry objectForKey:MultipartVariableName]])
		{
			[call setObject:[entry objectForKey:MultipartVariableValue] forKey:CallStreetNumber];
			found++;
		}
		else if([@"street" isEqualToString:[entry objectForKey:MultipartVariableName]])
		{
			[call setObject:[entry objectForKey:MultipartVariableValue] forKey:CallStreet];
			found++;
		}
		else if([@"city" isEqualToString:[entry objectForKey:MultipartVariableName]])
		{
			[call setObject:[entry objectForKey:MultipartVariableValue] forKey:CallCity];
			found++;
		}
		else if([@"state" isEqualToString:[entry objectForKey:MultipartVariableName]])
		{
			[call setObject:[entry objectForKey:MultipartVariableValue] forKey:CallState];
			found++;
		}
	}

	for(int index = 0; index < 100; index++)
	{
		NSString *day = nil;
		NSString *month = nil;
		NSString *year = nil;
		NSString *notes = nil;
		NSDateComponents *comps = [[[NSDateComponents alloc] init] autorelease];
		for(NSDictionary *entry in self.variableArray)
		{
			if([[NSString stringWithFormat:@"day%u", index] isEqualToString:[entry objectForKey:MultipartVariableName]])
			{
				day = [entry objectForKey:MultipartVariableValue];
				int value = [day intValue];
				if(!value)
					day = nil;
				[comps setDay:value];
				found++;
			}
			else if([[NSString stringWithFormat:@"month%u", index] isEqualToString:[entry objectForKey:MultipartVariableName]])
			{
				month = [entry objectForKey:MultipartVariableValue];
				int value = [month intValue];
				if(!value)
					month = nil;
				[comps setMonth:value];
				found++;
			}
			else if([[NSString stringWithFormat:@"year%u", index] isEqualToString:[entry objectForKey:MultipartVariableName]])
			{
				year = [entry objectForKey:MultipartVariableValue];
				int value = [year intValue];
				if(!value)
					year = nil;
				[comps setYear:value];
				found++;
			}
			else if([[NSString stringWithFormat:@"notes%u", index] isEqualToString:[entry objectForKey:MultipartVariableName]])
			{
				notes = [entry objectForKey:MultipartVariableValue];
				found++;
			}
		}
		if(day && month && year && notes)
		{
			NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
			NSDate *date = [gregorian dateFromComponents:comps];
			NSMutableDictionary *returnVisit = [NSMutableDictionary dictionaryWithObjectsAndKeys:notes, CallReturnVisitNotes,
												date, CallReturnVisitDate, nil];
			[returnVisits addObject:returnVisit];
		}
		else
		{
			break;
		}
	}

	if(found)
	{
		NSMutableArray *calls = [[[Settings sharedInstance] userSettings] objectForKey:SettingsCalls];
		if(calls == nil)
		{
			calls = [NSMutableArray array];
			[[[Settings sharedInstance] userSettings] setObject:calls forKey:SettingsCalls];
		}
		[calls addObject:call];
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
