// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTDisplayRule.m instead.

#import "_MTDisplayRule.h"

@implementation MTDisplayRuleID
@end

@implementation _MTDisplayRule

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"DisplayRule" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"DisplayRule";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"DisplayRule" inManagedObjectContext:moc_];
}

- (MTDisplayRuleID*)objectID {
	return (MTDisplayRuleID*)[super objectID];
}




@dynamic order;



- (double)orderValue {
	NSNumber *result = [self order];
	return [result doubleValue];
}

- (void)setOrderValue:(double)value_ {
	[self setOrder:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveOrderValue {
	NSNumber *result = [self primitiveOrder];
	return [result doubleValue];
}

- (void)setPrimitiveOrderValue:(double)value_ {
	[self setPrimitiveOrder:[NSNumber numberWithDouble:value_]];
}





@dynamic name;






@dynamic deleteable;



- (BOOL)deleteableValue {
	NSNumber *result = [self deleteable];
	return [result boolValue];
}

- (void)setDeleteableValue:(BOOL)value_ {
	[self setDeleteable:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveDeleteableValue {
	NSNumber *result = [self primitiveDeleteable];
	return [result boolValue];
}

- (void)setPrimitiveDeleteableValue:(BOOL)value_ {
	[self setPrimitiveDeleteable:[NSNumber numberWithBool:value_]];
}





@dynamic filters;

	

@dynamic sorters;

	
- (NSMutableSet*)sortersSet {
	[self willAccessValueForKey:@"sorters"];
	NSMutableSet *result = [self mutableSetValueForKey:@"sorters"];
	[self didAccessValueForKey:@"sorters"];
	return result;
}
	

@dynamic user;

	



@end
