// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTTerritoryHouse.m instead.

#import "_MTTerritoryHouse.h"

@implementation MTTerritoryHouseID
@end

@implementation _MTTerritoryHouse

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TerritoryHouse" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TerritoryHouse";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TerritoryHouse" inManagedObjectContext:moc_];
}

- (MTTerritoryHouseID*)objectID {
	return (MTTerritoryHouseID*)[super objectID];
}




@dynamic notes;






@dynamic number;






@dynamic apartment;






@dynamic attempts;

	
- (NSMutableSet*)attemptsSet {
	[self willAccessValueForKey:@"attempts"];
	NSMutableSet *result = [self mutableSetValueForKey:@"attempts"];
	[self didAccessValueForKey:@"attempts"];
	return result;
}
	

@dynamic street;

	



@end
