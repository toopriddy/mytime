#import "MapViewCallDetailController.h"
#import "Settings.h"

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


@end
