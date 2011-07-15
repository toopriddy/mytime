// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTTerritoryStreet.m instead.

#import "_MTTerritoryStreet.h"

@implementation MTTerritoryStreetID
@end

@implementation _MTTerritoryStreet

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TerritoryStreet" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TerritoryStreet";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TerritoryStreet" inManagedObjectContext:moc_];
}

- (MTTerritoryStreetID*)objectID {
	return (MTTerritoryStreetID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic notes;






@dynamic name;






@dynamic date;






@dynamic territory;

	

@dynamic houses;

	
- (NSMutableSet*)housesSet {
	[self willAccessValueForKey:@"houses"];
	NSMutableSet *result = [self mutableSetValueForKey:@"houses"];
	[self didAccessValueForKey:@"houses"];
	return result;
}
	





@end
