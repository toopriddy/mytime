//
//  HttpMultipartResponseHandler.h
//  TextTransfer
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
