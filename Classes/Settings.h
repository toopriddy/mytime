//
//  Settings.h
//  MyTime
//
//  Created by Brent Priddy on 7/24/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
//multiple users
extern NSString * const SettingsCalls; // Done
//multiple users
extern NSString * const SettingsDeletedCalls; // Done

	extern NSString * const CallName; // Done
	extern NSString * const CallStreetNumber; // Done
	extern NSString * const CallApartmentNumber; // Done
	extern NSString * const CallStreet; // Done
	extern NSString * const CallCity; // Done
	extern NSString * const CallState; // Done
	extern NSString * const CallLattitudeLongitude; // Done
	extern NSString * const CallLocationType; // Done
		extern NSString * const CallLocationTypeManual;
		extern NSString * const CallLocationTypeGoogleMaps;
		extern NSString * const CallLocationTypeDoNotShow;


	extern NSString * const CallMetadata; // Done
		extern NSString * const CallMetadataName; // Done
		extern NSString * const CallMetadataType; // Done
		extern NSString * const CallMetadataData; // Done
		extern NSString * const CallMetadataValue; // Done

	extern NSString * const CallReturnVisits; // Done
		extern NSString * const CallReturnVisitNotes; // Done
		extern NSString * const CallReturnVisitDate; // Done
		extern NSString * const CallReturnVisitType; // Done
		extern NSString * const CallReturnVisitPublications; // Done
		extern NSString * const CallReturnVisitPublicationTitle; // Done
		extern NSString * const CallReturnVisitPublicationType; // Done
		extern NSString * const CallReturnVisitPublicationName; // Done
		extern NSString * const CallReturnVisitPublicationYear; // Done
		extern NSString * const CallReturnVisitPublicationMonth; // Done
		extern NSString * const CallReturnVisitPublicationDay; // Done

		extern NSString * const CallReturnVisitTypeTransferedStudy;
		extern NSString * const CallReturnVisitTypeTransferedNotAtHome;
		extern NSString * const CallReturnVisitTypeTransferedReturnVisit;
		extern NSString * const CallReturnVisitTypeReturnVisit;
		extern NSString * const CallReturnVisitTypeStudy;
		extern NSString * const CallReturnVisitTypeNotAtHome;

//multiple users
extern NSString * const SettingsBulkLiterature; // Done
	extern NSString * const BulkLiteratureDate; // Done
	extern NSString * const BulkLiteratureArray; // Done
		extern NSString * const BulkLiteratureArrayCount; // Done
		extern NSString * const BulkLiteratureArrayTitle; // Done
		extern NSString * const BulkLiteratureArrayType; // Done
		extern NSString * const BulkLiteratureArrayName; // Done
		extern NSString * const BulkLiteratureArrayYear; // Done
		extern NSString * const BulkLiteratureArrayMonth; // Done
		extern NSString * const BulkLiteratureArrayDay; // Done

#define AlternateLocalizedString(key, comment) (key)
#define PublicationTypeHeading			@""
#define PublicationTypeDVDBible			AlternateLocalizedString(@"Bible DVD", @"Publication Type name")
#define PublicationTypeDVDBook			AlternateLocalizedString(@"DVD", @"Publication Type name")
#define PublicationTypeDVDBrochure		AlternateLocalizedString(@"DVD Brochure", @"Publication Type name")
#define PublicationTypeDVDNotCount		AlternateLocalizedString(@"DVD (not counted)", @"Publication Type name") 
#define PublicationTypeBook				AlternateLocalizedString(@"Book", @"Publication Type name")
#define PublicationTypeBrochure			AlternateLocalizedString(@"Brochure", @"Publication Type name")
#define PublicationTypeTwoMagazine		AlternateLocalizedString(@"TwoMagazine", @"Publication Type name")
#define PublicationTypeMagazine			AlternateLocalizedString(@"Magazine", @"Publication Type name")
#define PublicationTypeTract			AlternateLocalizedString(@"Tract", @"Publication Type name")
#define PublicationTypeCampaignTract	AlternateLocalizedString(@"Campaign Tract", @"Publication Type name")



extern NSString * const SettingsLastLattitude; // Done
extern NSString * const SettingsLastLongitude; // Done

extern NSString * const SettingsLastCallStreetNumber; // Done
extern NSString * const SettingsLastCallApartmentNumber; // Done
extern NSString * const SettingsLastCallStreet; // Done
extern NSString * const SettingsLastCallCity; // Done
extern NSString * const SettingsLastCallState; // Done

extern NSString * const SettingsCurrentButtonBarName; // Done

//multiple users
extern NSString * const SettingsPreferredMetadata; // Done
//multiple users
extern NSString * const SettingsSortedByMetadata; // Done

extern NSString * const SettingsMetadata; // Deprecated
//multiple users
extern NSString * const SettingsOtherMetadata; // Done
	extern NSString * const SettingsMetadataName; // Done
	extern NSString * const SettingsMetadataType; // Done
	extern NSString * const SettingsMetadataValue; // Done
	extern NSString * const SettingsMetadataData; // Done
		// for the MetadataType of multipleChoice, this is an array of NSStrings

//multiple users
extern NSString * const SettingsMonthDisplayCount; // Done

extern NSString * const SettingsMultipleUsersCurrentUser; // Done
extern NSString * const SettingsMultipleUsers; // Done
	extern NSString * const SettingsMultipleUsersName; // Done

extern NSString * const SettingsSecretaryEmailAddress; // Done
extern NSString * const SettingsSecretaryEmailNotes; // Done

extern NSString * const SettingsTimeAlertSheetShown; // Done
extern NSString * const SettingsStatisticsAlertSheetShown; // Done
extern NSString * const SettingsMainAlertSheetShown; // Done
extern NSString * const SettingsBulkLiteratureAlertSheetShown; // Done
extern NSString * const SettingsExistingCallAlertSheetShown; // Done

//multiple users
extern NSString * const SettingsQuickNotes; // Done

//multiple users
extern NSString * const SettingsTimeStartDate; // Done
//multiple users
extern NSString * const SettingsRBCTimeStartDate; // Done
//multiple users
extern NSString * const SettingsTimeEntries; // Done
//multiple users
extern NSString * const SettingsRBCTimeEntries; // Done
	extern NSString * const SettingsTimeEntryDate; // Done
	extern NSString * const SettingsTimeEntryMinutes; // Done

//multiple users
extern NSString * const SettingsStatisticsAdjustments;

extern NSString * const SettingsPasscode; //Done

extern NSString * const SettingsLastBackupDate; // Done
extern NSString * const SettingsAutoBackupInterval; // Done
extern NSString * const SettingsBackupEmailAddress; // Done
extern NSString * const SettingsBackupEmailDontIncludeAttachment; // Done
extern NSString * const SettingsBackupEmailUncompressedLink; // Done

extern NSString * const SettingsDonated;
extern NSString * const SettingsFirstView; // Done
extern NSString * const SettingsSecondView; // Done
extern NSString * const SettingsThirdView; // Done
extern NSString * const SettingsFourthView; // Done

//multiple users
extern NSString * const SettingsNotAtHomeTerritories; // Done
	extern NSString * const NotAtHomeTerritoryName; // Done
	extern NSString * const NotAtHomeTerritoryOwnerId; // Done
	extern NSString * const NotAtHomeTerritoryOwnerEmailId; // Done
	extern NSString * const NotAtHomeTerritoryOwnerEmailAddress; // Done
	extern NSString * const NotAtHomeTerritoryStreets;
	extern NSString * const NotAtHomeTerritoryCity; // Done
	extern NSString * const NotAtHomeTerritoryState; // Done
	extern NSString * const NotAtHomeTerritoryNotes; // Done
		extern NSString * const NotAtHomeTerritoryStreetName; // Done
		extern NSString * const NotAtHomeTerritoryStreetDate; // Done
		extern NSString * const NotAtHomeTerritoryStreetNotes; // Done
		extern NSString * const NotAtHomeTerritoryHouses; // Done
			extern NSString * const NotAtHomeTerritoryHouseNumber; // Done
			extern NSString * const NotAtHomeTerritoryHouseApartment; // Done
			extern NSString * const NotAtHomeTerritoryHouseNotes; // Done
			extern NSString * const NotAtHomeTerritoryHouseAttempts; // Done


//multiple users
extern NSString * const SettingsPublisherType; // Done

	extern NSString * const PublisherTypePublisher;
	extern NSString * const PublisherTypeAuxilliaryPioneer;
	extern NSString * const PublisherTypePioneer;
	extern NSString * const PublisherTypeSpecialPioneer;
	extern NSString * const PublisherTypeTravelingServant;


// these are in the UserDefaults

extern NSString *const UserDefaultsClearMapCache;
extern NSString *const UserDefaultsEmailBackupInstantly;
extern NSString *const UserDefaultsRemovePasscode;



// notifications

extern NSString *const SettingsNotificationUserChanged;

extern NSString *const SettingsNotificationCallChanged;


#define REVERSE_GEOCODING_ACCURACY 70

extern int debugging;

#define DEBUG(a) if(debugging) { a }
#define VERBOSE(a) if(debugging > 1) { a }
#define VERY_VERBOSE(a) if(debugging > 2) { a }

NSString *emailFormattedStringForCall(NSDictionary *_call);
NSString *emailFormattedStringForNotAtHomeTerritory(NSDictionary *territory);

@interface Settings : NSObject 
{
	NSMutableDictionary *settings;
	NSMutableDictionary *userSettings;
}
+ (Settings *)sharedInstance;
+ (id)initWithZone:(NSZone *)zone;
+ (BOOL)isInitialized;

+ (MFMailComposeViewController *)sendEmailBackup;
+ (MFMailComposeViewController *)sendPrintableEmailBackup;

+ (void)formatStreetNumber:(NSString *)houseNumber apartment:(NSString *)apartmentNumber topLine:(NSMutableString *)top;
+ (void)formatStreetNumber:(NSString *)houseNumber apartment:(NSString *)apartmentNumber street:(NSString *)street topLine:(NSMutableString *)top;
+ (void)formatStreetNumber:(NSString *)houseNumber apartment:(NSString *)apartmentNumber street:(NSString *)street city:(NSString *)city state:(NSString *)state topLine:(NSMutableString *)top bottomLine:(NSMutableString *)bottom;

+ (NSString *)filename;
- (void)readData;
- (void)saveData;

- (void)changeSettingsToUser:(NSString *)username save:(BOOL)save;

- (id)copyWithZone:(NSZone *)zone;
- (id)retain;
- (unsigned)retainCount;
- (void)release;
- (id)autorelease;

@property (nonatomic, retain) NSMutableDictionary *userSettings;
@property (nonatomic, retain) NSMutableDictionary *settings;
@end
