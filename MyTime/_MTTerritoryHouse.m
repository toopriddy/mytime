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



- (short)attemptsValue {
	NSNumber *result = [self attempts];
	return [result shortValue];
}

- (void)setAttemptsValue:(short)value_ {
	[self setAttempts:[NSNumber numberWithShort:value_]];
}

- (short)primitiveAttemptsValue {
	NSNumber *result = [self primitiveAttempts];
	return [result shortValue];
}

- (void)setPrimitiveAttemptsValue:(short)value_ {
	[self setPrimitiveAttempts:[NSNumber numberWithShort:value_]];
}





@dynamic street;

	



@end
