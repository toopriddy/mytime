//
//  HttpMultipartResponseHandler.m
//  TextTransfer
//
//  Created by Brent Priddy on 7/28/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//

#import "HttpMultipartResponseHandler.h"
#import "HTTPServer.h"
#import "CSRegex.h"




NSString * const MultipartVariableFilename = @"filename";
NSString * const MultipartVariableName = @"name";
NSString * const MultipartVariableValue = @"value";
NSString * const MultipartVariableTempFilename = @"tempFilename";

@implementation HttpMultipartResponseHandler
@synthesize body;
@synthesize variableArray;
@synthesize tempFileHandle;
@synthesize boundary;

- (void)receivedData
{
	if(totalContentLength == 0)
	{
		if(self.tempFileHandle)
		{
			[self.tempFileHandle closeFile];
			self.tempFileHandle = nil;
		}
		[self sendPage];
		return;
	}
	
	switch(state)
	{
		case FIND_START_FORM_BOUNDARY:
		{
			char *ptr = (char *)self.body.bytes;
			int length = self.body.length;
			for(int i = 0; i < length;)
			{
				i++;
				if(*ptr++ == '\n')
				{
					self.body = [NSMutableData dataWithBytes:ptr length:(self.body.length - i)];
					state = READ_HEADER;
					
					[self receivedData];
					break;
				}
			}
			break;
		}			
		case READ_HEADER:
		{
			int crlfCount = 0;
			char *ptr = (char *)self.body.bytes;
			int length = self.body.length;
			for(int i = 0; i < length;)
			{
				char c = *ptr++;
				i++;
				if(c == '\n')
				{
					crlfCount++;
					if(crlfCount == 2)
					{
						NSAutoreleasePool *pool2 = [[NSAutoreleasePool alloc] init];
						CFHTTPMessageRef message = CFHTTPMessageCreateEmpty(kCFAllocatorDefault, TRUE);
						char *fake = "GET / HTTP/1.0\r\n";
						CFHTTPMessageAppendBytes(message, (unsigned char *)fake, strlen(fake));
						CFHTTPMessageAppendBytes(message, self.body.bytes, i);
						NSDictionary *requestHeaderFields = [(NSDictionary *)CFHTTPMessageCopyAllHeaderFields(message) autorelease];
						CFRelease(message);

						// we should be able to pull out the Content-Disposition out of the header
						NSString *contentDisposition = [requestHeaderFields objectForKey:@"Content-Disposition"];
						NSArray *nameArray = [contentDisposition substringsCapturedByPattern:@"name=\"([^\"]*)\""];
						NSString *name = nil;
						if(nameArray && nameArray.count == 2)
							name = [nameArray objectAtIndex:1];
						
						NSArray *filenameArray = [contentDisposition substringsCapturedByPattern:@"filename=\"([^\"]*)\""];
						NSString *filename = nil;
						if(filenameArray && filenameArray.count == 2)
							filename = [filenameArray objectAtIndex:1];
						
						if(filename)
						{
							if(self.tempFileHandle)
							{
								[self.tempFileHandle closeFile];
								self.tempFileHandle = nil;
							}
							// we are at the start of the body
							NSString *tempFilename = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"upload%d", self.variableArray.count]];
							[self.variableArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:filename, MultipartVariableFilename, 
													  name, MultipartVariableName, 
													  tempFilename, MultipartVariableTempFilename, nil]];
							[[NSFileManager defaultManager] createFileAtPath:tempFilename contents:[NSData data] attributes:nil];
							self.tempFileHandle = [NSFileHandle fileHandleForWritingAtPath:tempFilename];
							
							state = READ_FILE_BODY;
							// should open and write to a file
						}
						else
						{
							[self.variableArray addObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:name, MultipartVariableName,
													  [NSMutableString string], MultipartVariableValue, nil]];
							state = READ_VARIABLE_BODY;
						}
						self.body = [NSMutableData dataWithBytes:ptr length:(self.body.length - i)];
						[pool2 release];
						
						// handle the rest of the data
						[self receivedData];
						break; 
					}
				}
				else if(c != '\r')
				{
					crlfCount = 0;
				}
			}
			break;
		}
			
		case READ_FILE_BODY:
		case READ_VARIABLE_BODY:
		{
			const char *needle = [self.boundary UTF8String];
			const char *haystack = self.body.bytes;
			char *found = strnstr(haystack, needle, self.body.length);
			if(found)
			{
				if(state == READ_FILE_BODY)
				{
					[self.tempFileHandle seekToEndOfFile];
					[self.tempFileHandle writeData:[NSData dataWithBytesNoCopy:(unsigned char *)haystack length:(found - haystack)]];
					[self.tempFileHandle closeFile];
					self.tempFileHandle = nil;
				}
				else
				{
					NSData *data = [NSData dataWithBytesNoCopy:(unsigned char *)haystack length:(found - haystack)];
					NSMutableString *value = [[self.variableArray lastObject] objectForKey:MultipartVariableValue];
					[value appendString:[[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease]];
				}
				self.body = [NSMutableData dataWithBytes:found length:(self.body.length - (found - haystack))];
				// check to see if this was a --boundary--
				if( *(found + self.boundary.length) == '-' &&  *(found + self.boundary.length + 1) == '-')
				{
					state = FINISHED_READING;
				}
				else
				{
					state = FIND_START_FORM_BOUNDARY;
				}

				[self receivedData];
			}
			else
			{
				if(state == READ_FILE_BODY)
				{
					[self.tempFileHandle seekToEndOfFile];
					[self.tempFileHandle writeData:self.body];
				}
				else
				{
					NSMutableString *value = [[self.variableArray lastObject] objectForKey:MultipartVariableValue];
					[value appendString:[[[NSString alloc] initWithData:self.body encoding:NSUTF8StringEncoding] autorelease]];
				}
				[self.body setLength:0];
			}
			break;
		}
	}
}

- (void)receiveIncomingDataNotification:(NSNotification *)notification
{
	NSFileHandle *incomingFileHandle = [notification object];
	NSData *data = [incomingFileHandle availableData];
	
	if ([data length] == 0)
	{
		[server closeHandler:self];
	}
	else
	{
		[body appendData:data];
		NSLog(@"%d bytes", body.length);
		[self receivedData];
		
		totalContentLength -= data.length;
		if(totalContentLength <= 0)
		{
			[self receivedData];
			return;
		}
	}
	
	[incomingFileHandle waitForDataInBackgroundAndNotify];
}


//
// startResponse
//
// Since this is a simple response, we handle it synchronously by sending
// everything at once.
//
- (void)startResponse
{
	[self receivedData];
}

- (void)dealloc
{
	// cleanup any uploaded files that were not moved
	NSFileManager *filemanager = [NSFileManager defaultManager];
	for(NSDictionary *entry in self.variableArray)
	{
		NSString *filename = [entry objectForKey:MultipartVariableTempFilename];
		if(filename)
		{
			[filemanager removeItemAtPath:filename error:nil];
		}
	}
	self.body = nil;
	self.boundary = nil;
	self.variableArray = nil;
	self.tempFileHandle = nil;
	
	[super dealloc];
}

- (id)initWithRequest:(CFHTTPMessageRef)aRequest
			   method:(NSString *)method
				  url:(NSURL *)requestURL
		 headerFields:(NSDictionary *)requestHeaderFields
		   fileHandle:(NSFileHandle *)requestFileHandle
			   server:(HTTPServer *)aServer
{
	/*
	 "Accept-Charset" = "ISO-8859-1,utf-8;q=0.7,*;q=0.7";
	 "Accept-Encoding" = "gzip,deflate";
	 "Accept-Language" = "en-us,en;q=0.5";
	 "Cache-Control" = "max-age=0";
	 Connection = "keep-alive";
	 "Content-Length" = 196104;
	 "Content-Type" = "multipart/form-data; boundary=---------------------------1722463037135670129997368447";
	 Host = "127.0.0.1:8080";
	 "Keep-Alive" = 300;
	 Referer = "http://127.0.0.1:8080/";
	 "User-Agent" = "Mozilla/5.0 (Macintosh; U; Intel Mac OS X 10.5; en-US; rv:1.9.0.12) Gecko/2009070609 Firefox/3.0.12";
	 */	
	
	self = [super initWithRequest:aRequest method:method url:requestURL headerFields:requestHeaderFields fileHandle:requestFileHandle server:aServer];
	self.body = [NSMutableData dataWithData:[(NSData *)CFHTTPMessageCopyBody(aRequest) autorelease]];
	self.variableArray = [NSMutableArray array];
	state = FIND_START_FORM_BOUNDARY;
	
	//"Content-Type" = "multipart/form-data; boundary=---------------------------1722463037135670129997368447";
	NSString *contentType = [headerFields objectForKey:@"Content-Type"];
	NSArray *boundaryArray = [contentType substringsCapturedByPattern:@"boundary=([^ ]*)"];
	if(boundaryArray && boundaryArray.count == 2)
		self.boundary = [NSString stringWithFormat:@"\r\n--%@", [boundaryArray objectAtIndex:1]];
	
	
	totalContentLength = [[requestHeaderFields objectForKey:@"Content-Length"] intValue];
	int currentLength = self.body.length;
//	NSLog(@"%@", [[[NSString alloc] initWithData:self.body encoding:NSUTF8StringEncoding] autorelease]);
	if(currentLength)
	{
		// if there is any additional content length then process it
		[self receivedData];
	}
	totalContentLength -= currentLength;
	return self;
}

- (void)sendPage
{
	[server closeHandler:self];
}


@end
