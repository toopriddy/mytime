//
//  Geocache.h
//  MyTime
//
//  Created by Brent Priddy on 1/28/09.
//  Copyright 2009 Priddy Software, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GeocacheViewController.h"

@class Geocache;
@protocol GeocacheDelegate<NSObject>
@required
- (void)geocacheDone:(Geocache *)geocache forCall:(NSMutableDictionary *)call;
@end


@interface Geocache : NSObject <GeocacheViewControllerDelegate>
{
	GeocacheViewController *_geocacheViewController;
	NSMutableArray *_callsToLookup;
	UIWindow *_window;
	bool _lookupInProgress;
	NSMutableArray *_delegates;
}

- (void)addDelegate:(NSObject<GeocacheDelegate> *)delegate;
- (void)removeDelegate:(NSObject<GeocacheDelegate> *)delegate;
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