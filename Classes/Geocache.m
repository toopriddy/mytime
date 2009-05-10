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
#import "Settings.h"

static Geocache *instance = nil;

@implementation Geocache

- (void)addDelegate:(NSObject<GeocacheDelegate> *)delegate
{
	[_delegates addObject:delegate];
}

- (void)removeDelegate:(NSObject<GeocacheDelegate> *)delegate
{
	[_delegates removeObject:delegate];
}


- (void)startLookupProcess
{
	if(_lookupInProgress || _callsToLookup.count == 0)
		return;

	_lookupInProgress = YES;
	
	[_geocacheViewController release];
	
	NSMutableDictionary *call = [[_callsToLookup objectAtIndex:0] retain];
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
	
	for(NSObject<GeocacheDelegate> *delegate in _delegates)
	{
		if([delegate respondsToSelector:@selector(geocacheDone:forCall:)])
		{
			[delegate geocacheDone:self forCall:geocacheViewController.call];
		}
	}
	_lookupInProgress = NO;
	[self startLookupProcess];
}


- (void)lookupCall:(NSMutableDictionary *)call
{
	[_callsToLookup addObject:call];

	[self startLookupProcess];
}

- (void)setWindow:(UIWindow*)window
{
	_window = [window retain];
	NSMutableArray *calls = [[[Settings sharedInstance] settings] objectForKey:SettingsCalls];
	for(NSMutableDictionary *call in calls)
	{
		if([call objectForKey:CallLattitudeLongitude] == nil &&
		   ![[call objectForKey:CallLocationType] isEqualToString:(NSString *)CallLocationTypeManual] &&
		   ![[call objectForKey:CallLocationType] isEqualToString:(NSString *)CallLocationTypeDoNotShow])
		{
			[self lookupCall:call];
		}
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
			instance->_delegates = [[NSMutableArray alloc] init];
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

