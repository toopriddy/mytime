//
//  Geocache.h
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

#import <Foundation/Foundation.h>
#import "GeocacheViewController.h"

@interface Geocache : NSObject <GeocacheViewControllerDelegate>
{
	GeocacheViewController *_geocacheViewController;
	NSMutableArray *_callsToLookup;
	UIWindow *_window;
	bool _lookupInProgress;
}

- (void)lookupCall:(NSMutableDictionary *)call;
- (void)setWindow:(UIWindow*)window;

+ (Geocache *)sharedInstance;
+ (id)initWithZone:(NSZone *)zone;
- (id)copyWithZone:(NSZone *)zone;
- (id)retain;
- (unsigned)retainCount;
- (void)release;
- (id)autorelease;

@end