//
//  TutorialViewController.h
//  MyTime
//
//  Created by Brent Priddy on 9/14/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TutorialViewController : UITableViewController <NSXMLParserDelegate>
{
	UIActivityIndicatorView *progress;

	NSXMLParser *parser;
	NSMutableArray *videos;
	
	NSURLConnection *connection;
	NSMutableData *receivedData;
	
	NSString *_hostname;
	NSString *_xmlFile;
	BOOL xmlDocumentDone;
}
@property (nonatomic, retain) NSMutableArray *videos;
@property (nonatomic, retain) UIActivityIndicatorView *progress;

- (void)parseXMLFileURL:(NSString *)URL;

@end