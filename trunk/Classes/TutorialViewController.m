//
//  TutorialViewController.m
//  MyTime
//
//  Created by Brent Priddy on 9/14/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import "TutorialViewController.h"
#import "YouTubeTableViewCell.h"
#import "PSLocalization.h"

@implementation TutorialViewController
@synthesize videos;
@synthesize progress;

- (UIActivityIndicatorView *)progress
{
	if(progress == nil)
	{
		progress = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		progress.center = self.tableView.center;
		[self.tableView addSubview:progress];
	}
	return [[progress retain] autorelease];
}

- (void)parseXMLFile:(NSData *)file
{
	NSLog(@"%s %s", __FILE__, __FUNCTION__);
	parser = [[NSXMLParser alloc] initWithData:file];
	
	// Set self as the delegate of the parser so that it will receive the parser delegate methods callbacks.
	[parser setDelegate:self];
	
	// Depending on the XML document you're parsing, you may want to enable these features of NSXMLParser.
	[parser setShouldProcessNamespaces:NO];
	[parser setShouldReportNamespacePrefixes:NO];
	[parser setShouldResolveExternalEntities:NO];
	
	[parser parse];
}

- (void)loadFile
{
	NSLog(@"%s %s", __FILE__, __FUNCTION__);
	[connection cancel];
	[connection release];
	connection = nil;
	
	NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:_xmlFile]
												cachePolicy:NSURLRequestUseProtocolCachePolicy
											timeoutInterval:60.0];
	connection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
	if(connection) 
	{
		receivedData = [[NSMutableData alloc] init];
		[self.progress setHidden:NO];
		[self.progress startAnimating];
	} 
	else 
	{
		// inform the user that the download could not be made
	}
}

- (void)parseXMLFileURL:(NSString *)file
{
	NSLog(@"%s %s", __FILE__, __FUNCTION__);
	_xmlFile = [file copy];
	
	xmlDocumentDone = NO;
	
	[self.progress setHidden:NO];
	[self.progress startAnimating];
	
	[self loadFile];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
	if( (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) )
	{
		self.title = NSLocalizedString(@"Tutorials", @"'Tutorials' ButtonBar View text, Label for the title of the view that has all of the youtube howto videos");
		self.tabBarItem.image = [UIImage imageNamed:@"tutorials.png"];
		self.tableView.allowsSelection = NO;
	}
	return self;
}

- (void)openMyTimeWebsite
{
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://mytime.googlecode.com"]];
}

- (void)viewWillAppear:(BOOL)animated
{
	if(self.videos.count == 0)
	{
		[self parseXMLFileURL:@"http://mytime.googlecode.com/svn/trunk/tutorialVideos.xml"];
	}
	// create a custom navigation bar button and set it to always say "back"
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] init] autorelease];
	button.title = NSLocalizedString(@"More info...", @"MyTime Website buton in the Tutorials view");
	[button setAction:@selector(openMyTimeWebsite)];
	[button setTarget:self];
	[self.navigationItem setRightBarButtonItem:button];
}

- (void)dealloc 
{
	NSLog(@"%s %s", __FILE__, __FUNCTION__);
	[_xmlFile release];
	[parser release];
	[videos release];
	[progress release];
	
    [super dealloc];
}

- (NSMutableArray *)videos
{
	if(videos == nil)
	{
		videos = [[NSMutableArray alloc] init];
	}
	return [[videos retain] autorelease];
}

#pragma mark -
#pragma mark URL Connection Functions

- (void)connection:(NSURLConnection *)theConnection didReceiveResponse:(NSURLResponse *)response
{
	NSLog(@"%s %s", __FILE__, __FUNCTION__);
    // this method is called when the server has determined that it
    // has enough information to create the NSURLResponse
	
    // it can be called multiple times, for example in the case of a
    // redirect, so each time we reset the data.
    // receivedData is declared as a method instance elsewhere
	if(connection == theConnection)
	{
		[receivedData setLength:0];
	}
}

- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)data
{
	NSLog(@"%s %s", __FILE__, __FUNCTION__);
    // append the new data to the receivedData
    // receivedData is declared as a method instance elsewhere
	if(connection == theConnection)
	{
		[receivedData appendData:data];
	}
}

- (void)connection:(NSURLConnection *)theConnection didFailWithError:(NSError *)error
{
	NSLog(@"%s %s", __FILE__, __FUNCTION__);
    // release the connection, and the data object
    [connection release];
	if(connection == theConnection)
	{
		[self.progress stopAnimating];
		
		[receivedData release];
		receivedData = nil;
		connection = nil;
		[self.progress stopAnimating];
	}
	
 	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading content, you need to be connected to the internet." message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
	[errorAlert release];
	
    // inform the user
    NSLog(@"Connection failed! Error - %@ %@",
          [error localizedDescription],
          [[error userInfo] objectForKey:NSErrorFailingURLStringKey]);
}

- (void)connectionDidFinishLoading:(NSURLConnection *)theConnection
{
	NSLog(@"%s %s", __FILE__, __FUNCTION__);
	[connection release];
	if(connection == theConnection)
	{
		connection = nil;
		[self.progress stopAnimating];
		
		[self parseXMLFile:receivedData];
		
		// release the connection, and the data object
		[receivedData release];
		receivedData = nil;
	}
}

#pragma mark -
#pragma mark XML Parser Functions

- (void)parserDidStartDocument:(NSXMLParser *)parser 
{
	NSLog(@"%s %s", __FILE__, __FUNCTION__);
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError 
{
	NSLog(@"%s %s", __FILE__, __FUNCTION__);
	NSString * errorString = [NSString stringWithFormat:@"Unable to download story feed from web site (Error code %i:%@ )", [parseError code], parseError];
	NSLog(@"error parsing XML: %@", errorString);
	
	UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Error loading content, you need to be connected to the internet." message:errorString delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
	[errorAlert show];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	NSLog(@"%s %s", __FILE__, __FUNCTION__);
	//NSLog(@"found this element: %@", elementName);
	if([elementName isEqualToString:@"video"])
	{
		NSArray *versionComponents = [[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
		NSArray *onlineVersionComponents = [[attributeDict objectForKey:@"version"] componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"."]];
		NSEnumerator *buildVersionEnumerator = [versionComponents objectEnumerator];
		NSEnumerator *onlineVersionEnumerator = [onlineVersionComponents objectEnumerator];
		NSString *buildVersion;
		NSString *onlineVersion;
		while((buildVersion = [buildVersionEnumerator nextObject]) && (onlineVersion = [onlineVersionEnumerator nextObject]))
		{
			if([buildVersion intValue] < [onlineVersion intValue])
			{
				// this video is for a newer version of mytime
				return;
			}
			if([buildVersion intValue] == [onlineVersion intValue])
			{
				continue;
			}
			// the version number is greater so it is ok to use this old video
			break;
		}
		
		[self.videos addObject:[NSDictionary dictionaryWithObjectsAndKeys:[attributeDict objectForKey:@"url"], @"url", 
								                                          [attributeDict objectForKey:@"label"], @"label", 
																		  [attributeDict objectForKey:@"version"], @"version", nil]];
	}
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
}

- (void)parserDidEndDocument:(NSXMLParser *)parser 
{
	NSLog(@"%s %s", __FILE__, __FUNCTION__);
	[self.progress stopAnimating];
	xmlDocumentDone = YES;
	
	[self.tableView performSelector:@selector(reloadData) withObject:nil afterDelay:0];
//	[self.tableView reloadData];
}

- (void)didReceiveMemoryWarning 
{
	NSLog(@"%s %s", __FILE__, __FUNCTION__);
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark -
#pragma mark View lifecycle
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    // Return the number of rows in the section.
    return self.videos.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath;
{
    return 80.0;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"Cell";
    
    YouTubeTableViewCell *cell = (YouTubeTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
		UIViewController *viewController = [[UIViewController alloc] initWithNibName:@"YouTubeTableViewCell" bundle:nil];
		cell = (YouTubeTableViewCell *)viewController.view;
		[[cell retain] autorelease];
		[viewController release];
    }
    NSDictionary *video = [self.videos objectAtIndex:indexPath.row];
	cell.label.text = [video objectForKey:@"label"];
	[cell setYouTubeVideo:[video objectForKey:@"url"]];
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    YouTubeTableViewCell *cell = (YouTubeTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
	[cell playVideo];
}

@end