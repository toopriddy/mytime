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

extern NSString const * const CallName;
extern NSString const * const CallStreetNumber;
extern NSString const * const CallApartmentNumber;
extern NSString const * const CallStreet;
extern NSString const * const CallCity;
extern NSString const * const CallState;
extern NSString const * const CallLattitudeLongitude;
extern NSString const * const CallLocationType;
extern NSString const * const CallLocationTypeManual;
extern NSString const * const CallLocationTypeGoogleMaps;
extern NSString const * const CallLocationTypeDoNotShow;


extern NSString const * const CallMetadata;
extern NSString const * const CallMetadataName;
extern NSString const * const CallMetadataType;
extern NSString const * const CallMetadataData;
extern NSString const * const CallMetadataValue;
extern NSString const * const CallReturnVisits;
extern NSString const * const CallReturnVisitNotes;
extern NSString const * const CallReturnVisitDate;
extern NSString const * const CallReturnVisitType;
extern NSString const * const CallReturnVisitPublications;
extern NSString const * const CallReturnVisitPublicationTitle;
extern NSString const * const CallReturnVisitPublicationType;
extern NSString const * const CallReturnVisitPublicationName;
extern NSString const * const CallReturnVisitPublicationYear;
extern NSString const * const CallReturnVisitPublicationMonth;
extern NSString const * const CallReturnVisitPublicationDay;

extern NSString const * const CallReturnVisitTypeTransferedStudy;
extern NSString const * const CallReturnVisitTypeTransferedNotAtHome;
extern NSString const * const CallReturnVisitTypeTransferedReturnVisit;
extern NSString const * const CallReturnVisitTypeReturnVisit;
extern NSString const * const CallReturnVisitTypeStudy;
extern NSString const * const CallReturnVisitTypeNotAtHome;

extern NSString const * const SettingsBulkLiterature;
extern NSString const * const BulkLiteratureDate;
extern NSString const * const BulkLiteratureArray;
extern NSString const * const BulkLiteratureArrayCount;
extern NSString const * const BulkLiteratureArrayTitle;
extern NSString const * const BulkLiteratureArrayType;
extern NSString const * const BulkLiteratureArrayName;
extern NSString const * const BulkLiteratureArrayYear;
extern NSString const * const BulkLiteratureArrayMonth;
extern NSString const * const BulkLiteratureArrayDay;


#define PublicationTypeHeading			@""
#define PublicationTypeDVDBible			NSLocalizedString(@"Bible DVD", @"Publication Type name")
#define PublicationTypeDVDBook			NSLocalizedString(@"DVD", @"Publication Type name")
#define PublicationTypeDVDNotCount		NSLocalizedString(@"DVD (not counted)", @"Publication Type name") 
#define PublicationTypeBook				NSLocalizedString(@"Book", @"Publication Type name")
#define PublicationTypeBrochure			NSLocalizedString(@"Brochure", @"Publication Type name")
#define PublicationTypeMagazine			NSLocalizedString(@"Magazine", @"Publication Type name")
#define PublicationTypeTract			NSLocalizedString(@"Tract", @"Publication Type name")
#define PublicationTypeCampaignTract	NSLocalizedString(@"Campaign Tract", @"Publication Type name")



extern NSString const * const MagazinePlacementDate;
extern NSString const * const MagazinePlacementCount;


extern NSString const * const SettingsLastLattitude;
extern NSString const * const SettingsLastLongitude;
extern NSString const * const SettingsCalls;
extern NSString const * const SettingsDeletedCalls;
extern NSString const * const SettingsMagazinePlacements;
extern NSString const * const SettingsLastCallStreetNumber;
extern NSString const * const SettingsLastCallApartmentNumber;
extern NSString const * const SettingsLastCallStreet;
extern NSString const * const SettingsLastCallCity;
extern NSString const * const SettingsLastCallState;
extern NSString const * const SettingsCurrentButtonBarIndex;

extern NSString const * const SettingsMetadata;
extern NSString const * const SettingsMetadataName;
extern NSString const * const SettingsMetadataType;
extern NSString const * const SettingsMetadataValue;
extern NSString const * const SettingsMetadataData;

extern NSString const * const SettingsMonthDisplayCount;

extern NSString const * const SettingsTimeAlertSheetShown;
extern NSString const * const SettingsStatisticsAlertSheetShown;
extern NSString const * const SettingsSecretaryEmailAddress;
extern NSString const * const SettingsSecretaryEmailNotes;

extern NSString const * const SettingsMainAlertSheetShown;
extern NSString const * const SettingsBulkLiteratureAlertSheetShown;
extern NSString const * const SettingsExistingCallAlertSheetShown;

extern NSString const * const SettingsTimeStartDate;
extern NSString const * const SettingsRBCTimeStartDate;
extern NSString const * const SettingsTimeEntries;
extern NSString const * const SettingsRBCTimeEntries;
extern NSString const * const SettingsTimeEntryDate;
extern NSString const * const SettingsTimeEntryMinutes;

extern NSString const * const SettingsDonated;
extern NSString const * const SettingsFirstView;
extern NSString const * const SettingsSecondView;
extern NSString const * const SettingsThirdView;
extern NSString const * const SettingsFourthView;

extern NSString const * const SettingsPublisherType;
extern NSString const * const PublisherTypePublisher;
extern NSString const * const PublisherTypeAuxilliaryPioneer;
extern NSString const * const PublisherTypePioneer;
extern NSString const * const PublisherTypeSpecialPioneer;
extern NSString const * const PublisherTypeTravelingServent;

extern int debugging;

#define DEBUG(a) if(debugging) { a }
#define VERBOSE(a) if(debugging > 1) { a }
#define VERY_VERBOSE(a) if(debugging > 2) { a }


@interface Settings : NSObject {
	NSMutableDictionary *settings;
}
+ (Settings *)sharedInstance;
+ (id)initWithZone:(NSZone *)zone;

+ (void)formatStreetNumber:(NSString *)houseNumber apartment:(NSString *)apartmentNumber street:(NSString *)street city:(NSString *)city state:(NSString *)state topLine:(NSMutableString *)top bottomLine:(NSMutableString *)bottom;

- (NSString *)filename;
- (void)readData;
- (void)saveData;

- (id)copyWithZone:(NSZone *)zone;
- (id)retain;
- (unsigned)retainCount;
- (void)release;
- (id)autorelease;

@property (nonatomic, retain) NSMutableDictionary *settings;
@end
