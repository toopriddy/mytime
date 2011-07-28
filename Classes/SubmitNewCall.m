//
//  SubmitNewCall.m
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

#import "SubmitNewCall.h"
#import "MTCall.h"
#import "MTReturnVisit.h"
#import "MyTimeAppDelegate.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "HTTPServer.h"


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
	NSManagedObjectContext *moc = [[MyTimeAppDelegate sharedInstance] managedObjectContext];
	MTCall *call = [MTCall insertInManagedObjectContext:moc];
	[call initializeNewCallWithoutReturnVisit];

	int found = 0;
	for(NSDictionary *entry in self.variableArray)
	{
		if([@"name" isEqualToString:[entry objectForKey:MultipartVariableName]])
		{
			call.name = [entry objectForKey:MultipartVariableValue];
			found++;
		}
		else if([@"apartment" isEqualToString:[entry objectForKey:MultipartVariableName]])
		{
			call.apartmentNumber = [entry objectForKey:MultipartVariableValue];
			found++;
		}
		else if([@"number" isEqualToString:[entry objectForKey:MultipartVariableName]])
		{
			call.houseNumber = [entry objectForKey:MultipartVariableValue];
			found++;
		}
		else if([@"street" isEqualToString:[entry objectForKey:MultipartVariableName]])
		{
			call.street = [entry objectForKey:MultipartVariableValue];
			found++;
		}
		else if([@"city" isEqualToString:[entry objectForKey:MultipartVariableName]])
		{
			call.city = [entry objectForKey:MultipartVariableValue];
			found++;
		}
		else if([@"state" isEqualToString:[entry objectForKey:MultipartVariableName]])
		{
			call.state = [entry objectForKey:MultipartVariableValue];
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
			MTReturnVisit *returnVisit = [MTReturnVisit insertInManagedObjectContext:call.managedObjectContext];
			returnVisit.call = call;
			returnVisit.notes = notes;
			returnVisit.date = date;
		}
		else
		{
			break;
		}
	}

	NSError *error = nil;
	if(![moc save:&error])
	{
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		[NSManagedObjectContext sendCoreDataSaveFailureEmailWithNavigationController:nil error:error];
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
