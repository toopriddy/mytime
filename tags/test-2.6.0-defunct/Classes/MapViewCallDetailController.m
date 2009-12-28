//
//  MapViewCellDetailController.m
//  MyTime
//
//  Created by Brent Priddy on 8/30/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//
#import "MapViewCallDetailController.h"
#import "Settings.h"
#import "PSLocalization.h"

@implementation MapViewCallDetailController
@synthesize delegate;
@synthesize call;

- (IBAction)callDetailSelected 
{
	if(delegate && [delegate respondsToSelector:@selector(mapViewCallDetailControllerSelected:)])
	{
		[delegate mapViewCallDetailControllerSelected:self];
	}
}

- (IBAction)cancelSelected 
{
	if(delegate && [delegate respondsToSelector:@selector(mapViewCallDetailControllerSelected:)])
	{
		[delegate mapViewCallDetailControllerSelected:self];
	}
}

- (NSMutableDictionary *)call
{
	return call;
}

- (void)dealloc
{
	[call release];
	
	[super dealloc];
}

- (void)setCall:(NSMutableDictionary *)theCall
{
	NSMutableDictionary *oldCall = call;
	call = [theCall retain];
	[oldCall release];
	
	NSMutableString *top = [[[NSMutableString alloc] init] autorelease];
	NSString *houseNumber = [call objectForKey:CallStreetNumber ];
	NSString *apartmentNumber = [call objectForKey:CallApartmentNumber ];
	NSString *street = [call objectForKey:CallStreet];

	[Settings formatStreetNumber:houseNumber apartment:apartmentNumber street:street city:nil state:nil topLine:top bottomLine:nil];

	if([top length] == 0)
		[top setString:NSLocalizedString(@"(unknown street)", @"(unknown street) Placeholder Section title in the Sorted By Calls view")];

	if([[call objectForKey:CallReturnVisits] count] > 0)
	{
		NSMutableDictionary *returnVisit = [[call objectForKey:CallReturnVisits] objectAtIndex:0];
		info.text = [returnVisit objectForKey:CallReturnVisitNotes];
	}
	else
	{
		info.text = @"";
	}
	name.text = [call objectForKey:CallName];
	address.text = top;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event 
{
	[self callDetailSelected];
}

@end
