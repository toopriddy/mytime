// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTBulkPlacement.m instead.

#import "_MTBulkPlacement.h"

@implementation MTBulkPlacementID
@end

@implementation _MTBulkPlacement

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"BulkPlacement" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"BulkPlacement";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"BulkPlacement" inManagedObjectContext:moc_];
}

- (MTBulkPlacementID*)objectID {
	return (MTBulkPlacementID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic notes;






@dynamic date;






@dynamic publications;

	
- (NSMutableSet*)publicationsSet {
	[self willAccessValueForKey:@"publications"];
	NSMutableSet *result = [self mutableSetValueForKey:@"publications"];
	[self didAccessValueForKey:@"publications"];
	return result;
}
	

@dynamic user;

	





@end
