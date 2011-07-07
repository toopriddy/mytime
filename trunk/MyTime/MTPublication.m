#import "MTPublication.h"
#import "MTBulkPlacement.h"
#import "MTReturnVisit.h"
#import "NSManagedObjectContext+PriddySoftware.h"

@implementation MTPublication

// Custom logic goes here.
+ (MTPublication *)createPublicationForReturnVisit:(MTReturnVisit *)returnVisit
{
	// first find the highest ordering index
	int order = 0;
	for(MTPublication *publication in [returnVisit.managedObjectContext fetchObjectsForEntityName:[MTPublication entityName]
																				propertiesToFetch:[NSArray arrayWithObject:@"order"]
																					withPredicate:@"returnVisit == %@", returnVisit])
	{
		int userOrder = publication.orderValue;
		if (userOrder > order)
			order = userOrder;
	}
	
	MTPublication *newPublication = [NSEntityDescription insertNewObjectForEntityForName:[MTPublication entityName]
																  inManagedObjectContext:returnVisit.managedObjectContext];
	newPublication.returnVisit = returnVisit;
	newPublication.orderValue = order + 1; // we are using the order to seperate calls and when reordering these will be mobed halfway between users.
	
	return newPublication;
}

+ (MTPublication *)createPublicationForBulkPlacement:(MTBulkPlacement *)bulkPlacement
{
	// first find the highest ordering index
	int order = 0;
	for(MTPublication *publication in [bulkPlacement.managedObjectContext fetchObjectsForEntityName:[MTPublication entityName]
																				  propertiesToFetch:[NSArray arrayWithObject:@"order"]
																					  withPredicate:@"bulkPlacement == %@", bulkPlacement])
	{
		int userOrder = publication.orderValue;
		if (userOrder > order)
			order = userOrder;
	}
	
	MTPublication *newPublication = [NSEntityDescription insertNewObjectForEntityForName:[MTPublication entityName]
																  inManagedObjectContext:bulkPlacement.managedObjectContext];
	newPublication.bulkPlacement = bulkPlacement;
	newPublication.orderValue = order + 1; // we are using the order to seperate calls and when reordering these will be mobed halfway between users.
	
	return newPublication;
}

+ (NSString *)pluralFormForPublicationType:(NSString *)publicationType
{
	if([publicationType isEqualToString:PublicationTypeBook])
	{
		return PublicationTypePluralBook;
	}
	else if([publicationType isEqualToString:PublicationTypeDVDNotCount])
	{
		return PublicationTypePluralDVDNotCount;
	}
	else if([publicationType isEqualToString:PublicationTypeDVDBible])
	{
		return PublicationTypePluralDVDBible;
	}
	else if([publicationType isEqualToString:PublicationTypeDVDBook])
	{
		return PublicationTypePluralDVDBook;
	}
	else if([publicationType isEqualToString:PublicationTypeDVDBrochure])
	{
		return PublicationTypePluralDVDBrochure;
	}
	else if([publicationType isEqualToString:PublicationTypeBrochure])
	{
		return PublicationTypePluralBrochure;
	}
	else if([publicationType isEqualToString:PublicationTypeMagazine])
	{
		return PublicationTypePluralMagazine;
	}
	else if([publicationType isEqualToString:PublicationTypeTwoMagazine])
	{
		return PublicationTypePluralTwoMagazine;
	}
	else if([publicationType isEqualToString:PublicationTypeTract])
	{
		return PublicationTypePluralTract;
	}
	else if([publicationType isEqualToString:PublicationTypeCampaignTract])
	{
		return PublicationTypePluralCampaignTract;
	}
	return publicationType;
}	
	

@end
