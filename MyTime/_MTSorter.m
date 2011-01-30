// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTSorter.m instead.

#import "_MTSorter.h"

@implementation MTSorterID
@end

@implementation _MTSorter

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Sorter" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Sorter";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Sorter" inManagedObjectContext:moc_];
}

- (MTSorterID*)objectID {
	return (MTSorterID*)[super objectID];
}




@dynamic name;






@dynamic type;



- (short)typeValue {
	NSNumber *result = [self type];
	return [result shortValue];
}

- (void)setTypeValue:(short)value_ {
	[self setType:[NSNumber numberWithShort:value_]];
}

- (short)primitiveTypeValue {
	NSNumber *result = [self primitiveType];
	return [result shortValue];
}

- (void)setPrimitiveTypeValue:(short)value_ {
	[self setPrimitiveType:[NSNumber numberWithShort:value_]];
}





@dynamic path;






@dynamic ascending;



- (BOOL)ascendingValue {
	NSNumber *result = [self ascending];
	return [result boolValue];
}

- (void)setAscendingValue:(BOOL)value_ {
	[self setAscending:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveAscendingValue {
	NSNumber *result = [self primitiveAscending];
	return [result boolValue];
}

- (void)setPrimitiveAscendingValue:(BOOL)value_ {
	[self setPrimitiveAscending:[NSNumber numberWithBool:value_]];
}





@dynamic displayRule;

	



@end
