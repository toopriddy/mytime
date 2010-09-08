// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to MTSettings.h instead.

#import <CoreData/CoreData.h>



















@interface MTSettingsID : NSManagedObjectID {}
@end

@interface _MTSettings : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (MTSettingsID*)objectID;



@property (nonatomic, retain) NSString *lastApartmentNumber;

//- (BOOL)validateLastApartmentNumber:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *lastCity;

//- (BOOL)validateLastCity:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *lastHouseNumber;

//- (BOOL)validateLastHouseNumber:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *backupEmail;

//- (BOOL)validateBackupEmail:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *autobackupInterval;

@property int autobackupIntervalValue;
- (int)autobackupIntervalValue;
- (void)setAutobackupIntervalValue:(int)value_;

//- (BOOL)validateAutobackupInterval:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *secretaryEmailAddress;

//- (BOOL)validateSecretaryEmailAddress:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *lastLattitude;

@property double lastLattitudeValue;
- (double)lastLattitudeValue;
- (void)setLastLattitudeValue:(double)value_;

//- (BOOL)validateLastLattitude:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *lastStreet;

//- (BOOL)validateLastStreet:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *lastState;

//- (BOOL)validateLastState:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *lastLongitude;

@property double lastLongitudeValue;
- (double)lastLongitudeValue;
- (void)setLastLongitudeValue:(double)value_;

//- (BOOL)validateLastLongitude:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSNumber *backupShouldIncludeAttachment;

@property BOOL backupShouldIncludeAttachmentValue;
- (BOOL)backupShouldIncludeAttachmentValue;
- (void)setBackupShouldIncludeAttachmentValue:(BOOL)value_;

//- (BOOL)validateBackupShouldIncludeAttachment:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *passcode;

//- (BOOL)validatePasscode:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *currentUser;

//- (BOOL)validateCurrentUser:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSString *secretaryEmailNotes;

//- (BOOL)validateSecretaryEmailNotes:(id*)value_ error:(NSError**)error_;



@property (nonatomic, retain) NSDate *lastBackupDate;

//- (BOOL)validateLastBackupDate:(id*)value_ error:(NSError**)error_;




@end

@interface _MTSettings (CoreDataGeneratedAccessors)

@end

@interface _MTSettings (CoreDataGeneratedPrimitiveAccessors)

- (NSString*)primitiveLastApartmentNumber;
- (void)setPrimitiveLastApartmentNumber:(NSString*)value;


- (NSString*)primitiveLastCity;
- (void)setPrimitiveLastCity:(NSString*)value;


- (NSString*)primitiveLastHouseNumber;
- (void)setPrimitiveLastHouseNumber:(NSString*)value;


- (NSString*)primitiveBackupEmail;
- (void)setPrimitiveBackupEmail:(NSString*)value;


- (NSNumber*)primitiveAutobackupInterval;
- (void)setPrimitiveAutobackupInterval:(NSNumber*)value;

- (int)primitiveAutobackupIntervalValue;
- (void)setPrimitiveAutobackupIntervalValue:(int)value_;


- (NSString*)primitiveSecretaryEmailAddress;
- (void)setPrimitiveSecretaryEmailAddress:(NSString*)value;


- (NSNumber*)primitiveLastLattitude;
- (void)setPrimitiveLastLattitude:(NSNumber*)value;

- (double)primitiveLastLattitudeValue;
- (void)setPrimitiveLastLattitudeValue:(double)value_;


- (NSString*)primitiveLastStreet;
- (void)setPrimitiveLastStreet:(NSString*)value;


- (NSString*)primitiveLastState;
- (void)setPrimitiveLastState:(NSString*)value;


- (NSNumber*)primitiveLastLongitude;
- (void)setPrimitiveLastLongitude:(NSNumber*)value;

- (double)primitiveLastLongitudeValue;
- (void)setPrimitiveLastLongitudeValue:(double)value_;


- (NSNumber*)primitiveBackupShouldIncludeAttachment;
- (void)setPrimitiveBackupShouldIncludeAttachment:(NSNumber*)value;

- (BOOL)primitiveBackupShouldIncludeAttachmentValue;
- (void)setPrimitiveBackupShouldIncludeAttachmentValue:(BOOL)value_;


- (NSString*)primitivePasscode;
- (void)setPrimitivePasscode:(NSString*)value;


- (NSString*)primitiveCurrentUser;
- (void)setPrimitiveCurrentUser:(NSString*)value;


- (NSString*)primitiveSecretaryEmailNotes;
- (void)setPrimitiveSecretaryEmailNotes:(NSString*)value;


- (NSDate*)primitiveLastBackupDate;
- (void)setPrimitiveLastBackupDate:(NSDate*)value;



@end
