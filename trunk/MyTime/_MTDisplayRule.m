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




@dynamic name;






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
