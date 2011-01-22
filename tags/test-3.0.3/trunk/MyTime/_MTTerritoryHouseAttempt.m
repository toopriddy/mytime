// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTTerritoryHouseAttempt.m instead.

#import "_MTTerritoryHouseAttempt.h"

@implementation MTTerritoryHouseAttemptID
@end

@implementation _MTTerritoryHouseAttempt

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"TerritoryHouseAttempt" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"TerritoryHouseAttempt";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"TerritoryHouseAttempt" inManagedObjectContext:moc_];
}

- (MTTerritoryHouseAttemptID*)objectID {
	return (MTTerritoryHouseAttemptID*)[super objectID];
}




@dynamic date;






@dynamic house;

	



@end
