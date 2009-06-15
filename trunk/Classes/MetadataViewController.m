//
//  MetadataViewController.m
//  MyTime
//
//  Created by Brent Priddy on 10/22/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "MetadataViewController.h"
#import "PublicationViewController.h"
#import "Settings.h"
#import "PSLocalization.h"

#include "PSRemoveLocalizedString.h"
static MetadataInformation commonInformation[] = {
	{NSLocalizedString(@"Email", @"Call Metadata"), EMAIL}
,	{NSLocalizedString(@"Phone", @"Call Metadata"), PHONE}
,	{NSLocalizedString(@"Mobile Phone", @"Call Metadata"), PHONE}
,	{NSLocalizedString(@"Notes", @"Call Metadata"), NOTES}
};
#include "PSAddLocalizedString.h"

#define ARRAY_SIZE(a) (sizeof(a)/sizeof(a[0]))

@interface MetadataViewController ()
@property (nonatomic,retain) UITableView *theTableView;
@end

@implementation MetadataViewController

@synthesize delegate;
@synthesize theTableView;

+ (NSArray *)metadataNames
{
	NSMutableArray *array = [NSMutableArray array];
	for(int i = 0; i < ARRAY_SIZE(commonInformation); i++)
	{
		[array addObject:commonInformation[i].name];
	}
	NSMutableArray *metadata = [[[Settings sharedInstance] settings] objectForKey:SettingsMetadata];
	[array addObjectsFromArray:[metadata valueForKey:SettingsMetadataName]];
	return array;
}

- (id) init;
{
	if ([super init]) 
	{
		theTableView = nil;
		delegate = nil;
		
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = NSLocalizedString(@"Add Info", @"Add Information title");
	}
	return self;
}

- (void)dealloc 
{
	self.theTableView.delegate = nil;
	self.theTableView.dataSource = nil;

	self.theTableView = nil;

	self.delegate = nil;
	
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return(YES);
}

- (void)loadView 
{
	// create a new table using the full application frame
	// we'll ask the datasource which type of table to use (plain or grouped)
	self.theTableView = [[[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] 
														  style:UITableViewStyleGrouped] autorelease];
	theTableView.editing = YES;
	theTableView.allowsSelectionDuringEditing = YES;
	
	// set the autoresizing mask so that the table will always fill the view
	theTableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	
	// set the tableview delegate to this object and the datasource to the datasource which has already been set
	theTableView.delegate = self;
	theTableView.dataSource = self;
	
	// set the tableview as the controller view
	self.view = self.theTableView;

	[self.theTableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	// force the tableview to load
	[self.theTableView reloadData];
	
}

-(void)viewDidAppear:(BOOL)animated
{
	[theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:YES];
	[theTableView flashScrollIndicators];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    int section = [indexPath section];
    DEBUG(NSLog(@"tableRowSelected: tableRowSelected section=%d row=%d", section, row);)
	
	if(section == 0)
	{
		MetadataInformation localMetadata;
		MetadataInformation *returnedMetadata = &localMetadata;
		
		NSMutableArray *metadata = [[[Settings sharedInstance] settings] objectForKey:SettingsMetadata];
		if(row < ARRAY_SIZE(commonInformation))
		{
			returnedMetadata = &commonInformation[row];
		}
		else if(row - ARRAY_SIZE(commonInformation) < metadata.count)
		{
			row -= ARRAY_SIZE(commonInformation);
			localMetadata.name = [[metadata objectAtIndex:row] objectForKey:SettingsMetadataName];
			localMetadata.type = [[[metadata objectAtIndex:row] objectForKey:SettingsMetadataType] intValue];
		}
		else
		{
			// open up the custom metadata type
			MetadataCustomViewController *p = [[[MetadataCustomViewController alloc] init] autorelease];
			p.delegate = self;

			[[self navigationController] pushViewController:p animated:YES];		
			return;
		}

		if(delegate)
		{
			[delegate metadataViewControllerAdd:self metadataInformation:returnedMetadata];
		}
		[[self navigationController] popViewControllerAnimated:YES];
	}
}


// UITableViewDataSource methods


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  
{
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section 
{
	NSMutableArray *metadata = [[[Settings sharedInstance] settings] objectForKey:SettingsMetadata];
	return ARRAY_SIZE(commonInformation) + metadata.count + 1; // additional 1 for custom
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int row = [indexPath row];
	int section = [indexPath section];
    VERBOSE(NSLog(@"tableView: cellForRow:%d inSection:%d", row, section);)
	
	UITableViewCell *cell = (UITableViewCell *)[theTableView dequeueReusableCellWithIdentifier:@"typeCell"];
	if(cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"typeCell"] autorelease];
	}
	
	if(section == 0)
	{
		NSMutableArray *metadata = [[[Settings sharedInstance] settings] objectForKey:SettingsMetadata];
		if(row < ARRAY_SIZE(commonInformation))
		{
			NSString *name = commonInformation[row].name;
			[cell setText:[[PSLocalization localizationBundle] localizedStringForKey:name value:name table:@""]];
		}
		else if(row - ARRAY_SIZE(commonInformation) < metadata.count)
		{
			row -= ARRAY_SIZE(commonInformation);
			[cell setText:[[metadata objectAtIndex:row] objectForKey:SettingsMetadataName]];
		}
		else
		{
			[cell setText:NSLocalizedString(@"Custom", @"Title for field in the Additional Information for the user to create their own additional information field")];
		}
	}
	return(cell);
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return(YES);
}

- (NSInteger)tableView:(UITableView *)tableView indentationLevelForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return(0);
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    int section = [indexPath section];
    DEBUG(NSLog(@"tableView: editingStyleForRowAtIndexPath section=%d row=%d", section, row);)

	if(section == 0)
	{
		NSMutableArray *metadata = [[[Settings sharedInstance] settings] objectForKey:SettingsMetadata];
		if(row < ARRAY_SIZE(commonInformation))
		{
		}
		else if(row - ARRAY_SIZE(commonInformation) < metadata.count)
		{
			return UITableViewCellEditingStyleDelete;
		}
		else
		{
			return UITableViewCellEditingStyleInsert;
		}
	}
	return UITableViewCellEditingStyleNone;
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    int row = [indexPath row];
    int section = [indexPath section];
    DEBUG(NSLog(@"tableView: editingStyleForRowAtIndexPath section=%d row=%d", section, row);)

	if(section == 0)
	{
		NSMutableArray *metadata = [[[Settings sharedInstance] settings] objectForKey:SettingsMetadata];
		if(row < ARRAY_SIZE(commonInformation))
		{
		}
		else if(row - ARRAY_SIZE(commonInformation) < metadata.count)
		{
			row -= ARRAY_SIZE(commonInformation);
			NSMutableArray *array = [NSMutableArray arrayWithArray:[[[Settings sharedInstance] settings] objectForKey:SettingsMetadata]];
			[array removeObjectAtIndex:row];
			[[[Settings sharedInstance] settings] setObject:array forKey:SettingsMetadata];
			[[Settings sharedInstance] saveData];
			[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
		}
		else
		{
			[self tableView:tableView didSelectRowAtIndexPath:indexPath];
		}
	}
}

- (void)metadataCustomViewControllerDone:(MetadataCustomViewController *)metadataCustomViewController
{
	MetadataInformation localMetadata;
	localMetadata.name = metadataCustomViewController.name.text;
	localMetadata.type = metadataCustomViewController.type;
	
	NSMutableArray *array = [NSMutableArray arrayWithArray:[[[Settings sharedInstance] settings] objectForKey:SettingsMetadata]];
	[[[Settings sharedInstance] settings] setObject:array forKey:SettingsMetadata];
	NSMutableDictionary *entry = [NSMutableDictionary dictionaryWithObjectsAndKeys:localMetadata.name, SettingsMetadataName,
																			      [NSNumber numberWithInt:localMetadata.type], SettingsMetadataType, nil];
	[array addObject:entry];

	[[Settings sharedInstance] saveData];																	

	if(delegate)
	{
		[delegate metadataViewControllerAdd:self metadataInformation:&localMetadata];
	}
	[[self navigationController] popToViewController:(UIViewController *)delegate animated:YES];
}

//
//
// UITableViewDelegate methods
//
//

// NONE

- (BOOL)respondsToSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"%s respondsToSelector: %s", __FILE__, selector);)
    return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"%s methodSignatureForSelector: %s", __FILE__, selector);)
    return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    VERY_VERBOSE(NSLog(@"%s forwardInvocation: %s", __FILE__, [invocation selector]);)
    [super forwardInvocation:invocation];
}
@end






