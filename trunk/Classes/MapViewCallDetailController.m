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

	if(houseNumber && [houseNumber length] && apartmentNumber && [apartmentNumber length] && street && [street length])
		[top appendFormat:NSLocalizedString(@"%@ #%@ %@ ", @"House number, apartment number and Street represented by %1$@ as the house number, %2$@ as the apartment number, notice the # before it that will be there as 'number ...' and then %3$@ as the street name"), houseNumber, apartmentNumber, street];
	else if(houseNumber && [houseNumber length] && street && [street length])
		[top appendFormat:NSLocalizedString(@"%@ %@", @"House number and Street represented by %1$@ as the house number and %2$@ as the street name"), houseNumber, street];
	else if(houseNumber && [houseNumber length] && apartmentNumber && [apartmentNumber length])
		[top appendFormat:NSLocalizedString(@"%@ #%@", @"House number and apartment number represented by %1$@ as the house number and %2$@ as the apartment number"), houseNumber, apartmentNumber];
	else if(houseNumber && [houseNumber length])
		[top appendFormat:houseNumber];
	else if(street && [street length] && apartmentNumber && [apartmentNumber length])
		[top appendFormat:NSLocalizedString(@"#%@ %@", @"Apartment Number and street name represented by %1$@ as the apartment number and %2$@ as the street name"), apartmentNumber, street];
	else if(street && [street length])
		[top appendFormat:street];
	else if(apartmentNumber && [apartmentNumber length])
		[top appendFormat:street];

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
