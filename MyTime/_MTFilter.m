// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTFilter.m instead.

#import "_MTFilter.h"

@implementation MTFilterID
@end

@implementation _MTFilter

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Filter" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Filter";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Filter" inManagedObjectContext:moc_];
}

- (MTFilterID*)objectID {
	return (MTFilterID*)[super objectID];
}




@dynamic predicate;






@dynamic name;






@dynamic displayRule;

	



@end
