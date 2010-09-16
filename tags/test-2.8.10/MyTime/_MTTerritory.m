// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTTerritory.m instead.

#import "_MTTerritory.h"

@implementation MTTerritoryID
@end

@implementation _MTTerritory

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Territory" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Territory";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Territory" inManagedObjectContext:moc_];
}

- (MTTerritoryID*)objectID {
	return (MTTerritoryID*)[super objectID];
}




@dynamic ownerEmailAddress;






@dynamic city;






@dynamic name;






@dynamic ownerEmailId;






@dynamic notes;






@dynamic state;






@dynamic ownerId;






@dynamic user;

	

@dynamic streets;

	
- (NSMutableSet*)streetsSet {
	[self willAccessValueForKey:@"streets"];
	NSMutableSet *result = [self mutableSetValueForKey:@"streets"];
	[self didAccessValueForKey:@"streets"];
	return result;
}
	



@end
