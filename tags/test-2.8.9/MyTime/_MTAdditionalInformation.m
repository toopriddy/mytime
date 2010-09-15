// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTAdditionalInformation.m instead.

#import "_MTAdditionalInformation.h"

@implementation MTAdditionalInformationID
@end

@implementation _MTAdditionalInformation

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"AdditionalInformation" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"AdditionalInformation";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"AdditionalInformation" inManagedObjectContext:moc_];
}

- (MTAdditionalInformationID*)objectID {
	return (MTAdditionalInformationID*)[super objectID];
}




@dynamic data;






@dynamic value;






@dynamic type;

	

@dynamic call;

	



@end
