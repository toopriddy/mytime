//
//  SubmitTranslationFile.m
//  MyTime
//
//  Created by Brent Priddy on 7/28/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "SubmitTranslationFile.h"
#import "HTTPServer.h"


@implementation SubmitTranslationFile

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
	if ([requestURL.path isEqualToString:@"/translation.html"])
	{
		return YES;
	}
	if ([requestURL.path isEqualToString:@"/"])
	{
		return YES;
	}
	if ([requestURL.path isEqualToString:@""])
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
			
			
			NSString *directory = [NSString stringWithFormat:@"%@.lproj", [[NSLocale currentLocale] localeIdentifier]];
			NSString *filename = @"Localizable.strings";
			NSFileManager *fileManager = [NSFileManager defaultManager];
			NSMutableString *bundlePath = [NSMutableString stringWithString:[[[paths objectAtIndex:0] stringByAppendingPathComponent:@"translation.bundle/Contents/Resources/"] stringByAppendingPathComponent:directory]];
			
			if(![fileManager createDirectoryAtPath:bundlePath withIntermediateDirectories:YES attributes:nil error:nil])
			{
				errorString = [NSString stringWithFormat:@"could not create directory at %@", bundlePath];
				NSLog(@"%@", errorString);
			}
			else
			{
				[bundlePath appendFormat:@"/%@", filename];
				if(![fileManager moveItemAtPath:[entry objectForKey:MultipartVariableTempFilename] toPath:bundlePath error:nil])
				{
					NSLog(@"did not write file");
				}
			}
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
