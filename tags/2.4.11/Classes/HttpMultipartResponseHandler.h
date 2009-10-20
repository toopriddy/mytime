//
//  HttpMultipartResponseHandler.h
//  TextTransfer
//
//  Created by Brent Priddy on 7/28/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//

#import "HTTPResponseHandler.h"

extern NSString * const MultipartVariableFilename;
extern NSString * const MultipartVariableName;
extern NSString * const MultipartVariableValue;
extern NSString * const MultipartVariableTempFilename;

typedef enum {
	FIND_START_FORM_BOUNDARY,
	READ_HEADER,
	READ_FILE_BODY,
	READ_VARIABLE_BODY,
	FINISHED_READING
} MultipartState;

@interface HttpMultipartResponseHandler : HTTPResponseHandler
{
	NSString *boundary;
	NSMutableArray *variableArray;
	NSMutableData *body;
	MultipartState state;
	NSFileHandle *tempFileHandle;
	NSString *variableValue;
	NSString *variableName;
	int totalContentLength;
	int variableContentLength;
}
@property (nonatomic, retain) NSMutableData *body;
@property (nonatomic, retain) NSMutableArray *variableArray;
@property (nonatomic, retain) NSFileHandle *tempFileHandle;
@property (nonatomic, retain) NSString *boundary;

// override this to send the page (you dont have to call super)
-(void)sendPage;

@end
