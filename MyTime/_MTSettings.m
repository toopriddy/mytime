// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTSettings.m instead.

#import "_MTSettings.h"

@implementation MTSettingsID
@end

@implementation _MTSettings

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"Settings" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"Settings";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"Settings" inManagedObjectContext:moc_];
}

- (MTSettingsID*)objectID {
	return (MTSettingsID*)[super objectID];
}

+ (NSSet *)keyPathsForValuesAffectingValueForKey:(NSString *)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"lastLongitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"lastLongitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"mainAlertSheetShownValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"mainAlertSheetShown"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"statisticsAlertSheetShownValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"statisticsAlertSheetShown"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"timeAlertSheetShownValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"timeAlertSheetShown"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"backupShouldIncludeAttachmentValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"backupShouldIncludeAttachment"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"autobackupIntervalValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"autobackupInterval"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"lastLattitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"lastLattitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"bulkLiteratureAlertSheetShownValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"bulkLiteratureAlertSheetShown"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"backupShouldCompressLinkValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"backupShouldCompressLink"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}
	if ([key isEqualToString:@"existingCallAlertSheetShownValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"existingCallAlertSheetShown"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
	}

	return keyPaths;
}




@dynamic lastLongitude;



- (double)lastLongitudeValue {
	NSNumber *result = [self lastLongitude];
	return [result doubleValue];
}

- (void)setLastLongitudeValue:(double)value_ {
	[self setLastLongitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLastLongitudeValue {
	NSNumber *result = [self primitiveLastLongitude];
	return [result doubleValue];
}

- (void)setPrimitiveLastLongitudeValue:(double)value_ {
	[self setPrimitiveLastLongitude:[NSNumber numberWithDouble:value_]];
}





@dynamic thirdViewTitle;






@dynamic lastStreet;






@dynamic mainAlertSheetShown;



- (BOOL)mainAlertSheetShownValue {
	NSNumber *result = [self mainAlertSheetShown];
	return [result boolValue];
}

- (void)setMainAlertSheetShownValue:(BOOL)value_ {
	[self setMainAlertSheetShown:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveMainAlertSheetShownValue {
	NSNumber *result = [self primitiveMainAlertSheetShown];
	return [result boolValue];
}

- (void)setPrimitiveMainAlertSheetShownValue:(BOOL)value_ {
	[self setPrimitiveMainAlertSheetShown:[NSNumber numberWithBool:value_]];
}





@dynamic statisticsAlertSheetShown;



- (BOOL)statisticsAlertSheetShownValue {
	NSNumber *result = [self statisticsAlertSheetShown];
	return [result boolValue];
}

- (void)setStatisticsAlertSheetShownValue:(BOOL)value_ {
	[self setStatisticsAlertSheetShown:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveStatisticsAlertSheetShownValue {
	NSNumber *result = [self primitiveStatisticsAlertSheetShown];
	return [result boolValue];
}

- (void)setPrimitiveStatisticsAlertSheetShownValue:(BOOL)value_ {
	[self setPrimitiveStatisticsAlertSheetShown:[NSNumber numberWithBool:value_]];
}





@dynamic fourthViewTitle;






@dynamic lastApartmentNumber;






@dynamic lastState;






@dynamic timeAlertSheetShown;



- (BOOL)timeAlertSheetShownValue {
	NSNumber *result = [self timeAlertSheetShown];
	return [result boolValue];
}

- (void)setTimeAlertSheetShownValue:(BOOL)value_ {
	[self setTimeAlertSheetShown:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveTimeAlertSheetShownValue {
	NSNumber *result = [self primitiveTimeAlertSheetShown];
	return [result boolValue];
}

- (void)setPrimitiveTimeAlertSheetShownValue:(BOOL)value_ {
	[self setPrimitiveTimeAlertSheetShown:[NSNumber numberWithBool:value_]];
}





@dynamic passcode;






@dynamic lastBackupDate;






@dynamic secondViewTitle;






@dynamic lastHouseNumber;






@dynamic backupEmail;






@dynamic backupShouldIncludeAttachment;



- (BOOL)backupShouldIncludeAttachmentValue {
	NSNumber *result = [self backupShouldIncludeAttachment];
	return [result boolValue];
}

- (void)setBackupShouldIncludeAttachmentValue:(BOOL)value_ {
	[self setBackupShouldIncludeAttachment:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveBackupShouldIncludeAttachmentValue {
	NSNumber *result = [self primitiveBackupShouldIncludeAttachment];
	return [result boolValue];
}

- (void)setPrimitiveBackupShouldIncludeAttachmentValue:(BOOL)value_ {
	[self setPrimitiveBackupShouldIncludeAttachment:[NSNumber numberWithBool:value_]];
}





@dynamic lastCity;






@dynamic autobackupInterval;



- (int)autobackupIntervalValue {
	NSNumber *result = [self autobackupInterval];
	return [result intValue];
}

- (void)setAutobackupIntervalValue:(int)value_ {
	[self setAutobackupInterval:[NSNumber numberWithInt:value_]];
}

- (int)primitiveAutobackupIntervalValue {
	NSNumber *result = [self primitiveAutobackupInterval];
	return [result intValue];
}

- (void)setPrimitiveAutobackupIntervalValue:(int)value_ {
	[self setPrimitiveAutobackupInterval:[NSNumber numberWithInt:value_]];
}





@dynamic lastLattitude;



- (double)lastLattitudeValue {
	NSNumber *result = [self lastLattitude];
	return [result doubleValue];
}

- (void)setLastLattitudeValue:(double)value_ {
	[self setLastLattitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLastLattitudeValue {
	NSNumber *result = [self primitiveLastLattitude];
	return [result doubleValue];
}

- (void)setPrimitiveLastLattitudeValue:(double)value_ {
	[self setPrimitiveLastLattitude:[NSNumber numberWithDouble:value_]];
}





@dynamic bulkLiteratureAlertSheetShown;



- (BOOL)bulkLiteratureAlertSheetShownValue {
	NSNumber *result = [self bulkLiteratureAlertSheetShown];
	return [result boolValue];
}

- (void)setBulkLiteratureAlertSheetShownValue:(BOOL)value_ {
	[self setBulkLiteratureAlertSheetShown:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveBulkLiteratureAlertSheetShownValue {
	NSNumber *result = [self primitiveBulkLiteratureAlertSheetShown];
	return [result boolValue];
}

- (void)setPrimitiveBulkLiteratureAlertSheetShownValue:(BOOL)value_ {
	[self setPrimitiveBulkLiteratureAlertSheetShown:[NSNumber numberWithBool:value_]];
}





@dynamic backupShouldCompressLink;



- (BOOL)backupShouldCompressLinkValue {
	NSNumber *result = [self backupShouldCompressLink];
	return [result boolValue];
}

- (void)setBackupShouldCompressLinkValue:(BOOL)value_ {
	[self setBackupShouldCompressLink:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveBackupShouldCompressLinkValue {
	NSNumber *result = [self primitiveBackupShouldCompressLink];
	return [result boolValue];
}

- (void)setPrimitiveBackupShouldCompressLinkValue:(BOOL)value_ {
	[self setPrimitiveBackupShouldCompressLink:[NSNumber numberWithBool:value_]];
}





@dynamic firstViewTitle;






@dynamic existingCallAlertSheetShown;



- (BOOL)existingCallAlertSheetShownValue {
	NSNumber *result = [self existingCallAlertSheetShown];
	return [result boolValue];
}

- (void)setExistingCallAlertSheetShownValue:(BOOL)value_ {
	[self setExistingCallAlertSheetShown:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveExistingCallAlertSheetShownValue {
	NSNumber *result = [self primitiveExistingCallAlertSheetShown];
	return [result boolValue];
}

- (void)setPrimitiveExistingCallAlertSheetShownValue:(BOOL)value_ {
	[self setPrimitiveExistingCallAlertSheetShown:[NSNumber numberWithBool:value_]];
}





@dynamic currentUser;

	





@end
