//
//  Geocache.m
//  MyTime
//
//  Created by Brent Priddy on 1/28/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "Geocache.h"
#import "GeocacheViewController.h"
#import "MyTimeAppDelegate.h"
#import "MTUser.h"
#import "NSManagedObjectContext+PriddySoftware.h"

static Geocache *instance = nil;

@implementation Geocache

- (void)startLookupProcess
{
	if(_lookupInProgress || _callsToLookup.count == 0)
		return;

	_lookupInProgress = YES;
	
	[_geocacheViewController release];
	
	MTCall *call = [[_callsToLookup objectAtIndex:0] retain];
	[_callsToLookup removeObjectAtIndex:0];
	
	_geocacheViewController = [[GeocacheViewController alloc] initWithCall:call];
	[call release];
	_geocacheViewController.hidden = YES;
	_geocacheViewController.delegate = self;
	[_window addSubview:_geocacheViewController];
}

- (void)geocacheViewControllerDone:(GeocacheViewController *)geocacheViewController
{
	[geocacheViewController removeFromSuperview];
	
	[[NSNotificationCenter defaultCenter] postNotificationName:MTNotificationCallChanged object:geocacheViewController.call];
	_lookupInProgress = NO;
	[self startLookupProcess];
}


- (void)lookupCall:(MTCall *)call
{
	if([GeocacheViewController canLookupCall:call])
	{
		[_callsToLookup addObject:call];

		[self startLookupProcess];
	}
}

- (void)setWindow:(UIWindow*)window
{
	_window = [window retain];
	NSManagedObjectContext *managedObjectContext = [[MyTimeAppDelegate sharedInstance] managedObjectContext];
	NSArray *calls = [managedObjectContext fetchObjectsForEntityName:[MTCall entityName]
												   propertiesToFetch:[NSArray arrayWithObjects:@"houseNumber", @"apartmentNumber", @"street", @"city", @"state", nil] 
													   withPredicate:@"(locationAquisitionAttempted == NO) AND (locationLookupType == %@)", CallLocationTypeGoogleMaps];
	for(MTCall *call in calls)
	{
		[self lookupCall:call];
	}
}

// common singleton stuff below

+ (Geocache *)sharedInstance
{
    @synchronized(self) 
	{
        if(instance == nil) 
		{
            instance = [[self alloc] init]; // assignment not done here
			instance->_callsToLookup = [[NSMutableArray alloc] init];
        }
    }

    return instance;
}

- (void)dealloc
{
	[_callsToLookup release];
	[_window release];
	[super dealloc];
}

+ (id)initWithZone:(NSZone *)zone
{
    @synchronized(self) 
	{
        if(instance == nil) 
		{
            instance = [super allocWithZone:zone];
            return instance;  // assignment and return on first allocation
        }
    }
    return nil; //on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain
{
    return self;
}

- (unsigned)retainCount
{
    return UINT_MAX;  //denotes an object that cannot be released
}

- (void)release
{
    //do nothing
}

- (id)autorelease
{
    return self;
}

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

