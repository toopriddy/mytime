//
//  SubmitDataFile.m
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

#import "SubmitDataFile.h"
#import "HTTPServer.h"
#import "MyTimeAppDelegate.h"
#import "UIAlertViewQuitter.h"
#import "Settings.h"

@implementation SubmitDataFile

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
	if ([requestURL.path isEqualToString:@"/data.html"])
	{
		return YES;
	}
	
	return NO;
}

- (void)sendPage
{
	NSString *errorString = nil;
	BOOL reallyQuit = NO;
	
	for(NSDictionary *entry in self.variableArray)
	{
		if([@"file" isEqualToString:[entry objectForKey:MultipartVariableName]])
		{
			// try the old format and then assume it is the new format
			NSMutableDictionary *dictionary = nil;
			NSData *data = [[NSData alloc] initWithContentsOfFile:[entry objectForKey:MultipartVariableTempFilename]];
			NSString *err = nil;
			NSPropertyListFormat format;
			@try
			{
				dictionary = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListMutableContainersAndLeaves format:&format errorDescription:&err];
				if(err)
				{
					dictionary = nil;
				}
			}
			@catch (NSException *e) 
			{
				dictionary = nil;
			}
			
			
			if(dictionary)
			{
				[dictionary writeToFile:[Settings filename] atomically: YES];
			}
			else
			{
				NSString *filename = [MyTimeAppDelegate storeFileAndPath];
				NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
				BOOL exists = [fileManager fileExistsAtPath:filename];
				if(exists && ![fileManager removeItemAtPath:filename error:nil])
				{
					NSLog(@"deleted file");
				}
				[data writeToFile:filename atomically:YES];
			}
			[data release];
			reallyQuit = YES;
		}
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
	if(reallyQuit)
	{
		UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
		alertSheet.delegate = [[UIAlertViewQuitter alloc] init];
		[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
		alertSheet.title = NSLocalizedString(@"Backup restored, press OK to quit mytime. You will have to restart to use your restored data", @"This message is displayed after a successful import of a call or a restore of a backup");
		[alertSheet show];
	}
}

@end
