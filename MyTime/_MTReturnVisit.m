// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTReturnVisit.m instead.

#import "_MTReturnVisit.h"

@implementation MTReturnVisitID
@end

@implementation _MTReturnVisit

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"ReturnVisit" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"ReturnVisit";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"ReturnVisit" inManagedObjectContext:moc_];
}

- (MTReturnVisitID*)objectID {
	return (MTReturnVisitID*)[super objectID];
}




@dynamic notes;






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





@dynamic date;






@dynamic publications;

	
- (NSMutableSet*)publicationsSet {
	[self willAccessValueForKey:@"publications"];
	NSMutableSet *result = [self mutableSetValueForKey:@"publications"];
	[self didAccessValueForKey:@"publications"];
	return result;
}
	

@dynamic call;

	



@end
