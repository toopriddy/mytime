// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTMultipleChoice.m instead.

#import "_MTMultipleChoice.h"

@implementation MTMultipleChoiceID
@end

@implementation _MTMultipleChoice

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"MultipleChoice" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"MultipleChoice";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"MultipleChoice" inManagedObjectContext:moc_];
}

- (MTMultipleChoiceID*)objectID {
	return (MTMultipleChoiceID*)[super objectID];
}




@dynamic name;






@dynamic type;

	



@end
