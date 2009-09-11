//
//  SubmitDataFile.m
//  MyTime
//
//  Created by Brent Priddy on 8/10/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//

#import "SubmitDataFile.h"
#import "Settings.h"
#import "HTTPServer.h"

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
	
	for(NSDictionary *entry in self.variableArray)
	{
		if([@"file" isEqualToString:[entry objectForKey:MultipartVariableName]])
		{
			NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
			
			
			NSString *filename = @"records.plist";
			NSFileManager *fileManager = [NSFileManager defaultManager];
			NSString *directory = [paths objectAtIndex:0];
			if(![fileManager createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil])
			{
				errorString = [NSString stringWithFormat:@"could not create directory at %@", directory];
				NSLog(@"%@", errorString);
			}
			else
			{
				directory = [directory stringByAppendingPathComponent:filename];
				[fileManager removeItemAtPath:directory error:nil];
				if(![fileManager moveItemAtPath:[entry objectForKey:MultipartVariableTempFilename] toPath:directory error:nil])
				{
					NSLog(@"did not write file");
				}
			}
			[[Settings sharedInstance] readData];

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
}

@end
