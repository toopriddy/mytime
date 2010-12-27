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






@dynamic ownerEmailId;



- (long long)ownerEmailIdValue {
	NSNumber *result = [self ownerEmailId];
	return [result longLongValue];
}

- (void)setOwnerEmailIdValue:(long long)value_ {
	[self setOwnerEmailId:[NSNumber numberWithLongLong:value_]];
}

- (long long)primitiveOwnerEmailIdValue {
	NSNumber *result = [self primitiveOwnerEmailId];
	return [result longLongValue];
}

- (void)setPrimitiveOwnerEmailIdValue:(long long)value_ {
	[self setPrimitiveOwnerEmailId:[NSNumber numberWithLongLong:value_]];
}





@dynamic notes;






@dynamic name;






@dynamic state;






@dynamic ownerId;



- (long long)ownerIdValue {
	NSNumber *result = [self ownerId];
	return [result longLongValue];
}

- (void)setOwnerIdValue:(long long)value_ {
	[self setOwnerId:[NSNumber numberWithLongLong:value_]];
}

- (long long)primitiveOwnerIdValue {
	NSNumber *result = [self primitiveOwnerId];
	return [result longLongValue];
}

- (void)setPrimitiveOwnerIdValue:(long long)value_ {
	[self setPrimitiveOwnerId:[NSNumber numberWithLongLong:value_]];
}





@dynamic date;






@dynamic user;

	

@dynamic streets;

	
- (NSMutableSet*)streetsSet {
	[self willAccessValueForKey:@"streets"];
	NSMutableSet *result = [self mutableSetValueForKey:@"streets"];
	[self didAccessValueForKey:@"streets"];
	return result;
}
	



@end
