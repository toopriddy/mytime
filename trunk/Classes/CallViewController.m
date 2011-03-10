//
//  CallViewController.m
//  MyTime
//
//  Created by Brent Priddy on 7/26/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//
//  Permission is NOT given to use this source code file in any
//  project, commercial or otherwise, with the condition
//  that any redistribution (in part or whole) of source code must retain
//  this copyright and permission notice. Attribution in non compiled references
//  MUST attribute the source (Priddy Software, LLC).  This file (in part or whole) 
//  is NOT allowed to be used in a compiled or scripted program.
//

#import "CallViewController.h"
#import "UITableViewTextFieldCell.h"
#import "UITableViewTitleAndValueCell.h"
#import "AddressViewController.h"
#import "PublicationViewController.h"
#import "PublicationTypeViewController.h"
#import "DatePickerViewController.h"
#import "UITableViewTextFieldCell.h"
#import "NotesViewControllerDelegate.h"
#import "ReturnVisitTypeViewController.h"
#import "MetadataViewController.h"
#import "MetadataEditorViewController.h"
#import "LocationPickerViewController.h"
#import "SelectPositionMapViewController.h"
#import "GeocacheViewController.h"
#import "UITableViewMultilineTextCell.h"
#import "NotesViewController.h"
#import "AddressTableCell.h"
#import "SwitchTableCell.h"
#import "MetadataViewController.h"
#import "MetadataEditorViewController.h"
#import "Geocache.h"
#import "MyTimeAppDelegate.h"
#import "PSUrlString.h"
#import "PSLocalization.h"
#import "UITableViewButtonCell.h"
#import "UITableViewSwitchCell.h"
#import "QuickNotesViewController.h"
#import "MultipleChoiceMetadataViewController.h"
#import "MTReturnVisit.h"
#import "MTAdditionalInformation.h"
#import "MTAdditionalInformationType.h"
#import "MTMultipleChoice.h"
#import "MTPublication.h"
#import "MTSettings.h"
#import "NSManagedObjectContext+PriddySoftware.h"

#define PLACEMENT_OBJECT_COUNT 2

#define USE_TEXT_VIEW 0

@interface CallViewController ()
@property (nonatomic, assign) BOOL showAddReturnVisit;
- (GenericTableViewSectionController *)genericTableViewSectionControllerForReturnVisit:(MTReturnVisit *)returnVisit;

- (void)addReturnVisitAndEdit;
@end


@interface SelectAddressView : UIResponder <UITextFieldDelegate>
{
	UITableView *tableView;
	NSIndexPath *indexPath;
}
@property (nonatomic,retain) UITableView *tableView;
@property (nonatomic,retain) NSIndexPath *indexPath;

- (id)initWithTable:(UITableView *)theTableView indexPath:(NSIndexPath *)theIndexPath;
@end

@implementation SelectAddressView

@synthesize tableView;
@synthesize indexPath;
- (void)dealloc
{
	self.tableView = nil;
	self.indexPath = nil;
	[super dealloc];
}

- (id)initWithTable:(UITableView *)theTableView indexPath:(NSIndexPath *)theIndexPath
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	[super init];
	self.tableView = theTableView;
	self.indexPath = theIndexPath;
	return(self);
}

- (BOOL)becomeFirstResponder 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	[tableView deselectRowAtIndexPath:nil animated:NO];
	[tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionTop];
	[tableView.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
	return NO;
}
@end

// base class for 
@interface CallViewCellController : NSObject<TableViewCellController>
{
	CallViewController *delegate;
	NSIndexPath *_indexPath;
}
@property (nonatomic, assign) CallViewController *delegate;
@property (nonatomic, retain) NSIndexPath *indexPath;
@end
@implementation CallViewCellController
@synthesize delegate;
@synthesize indexPath = _indexPath;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}

-(void)dealloc
{
	self.indexPath = nil;
	[super dealloc];
}
@end

@interface ReturnVisitCellController : CallViewCellController
{
	MTReturnVisit *returnVisit;
}
@property (nonatomic, retain) MTReturnVisit *returnVisit;
@end
@implementation ReturnVisitCellController
@synthesize returnVisit;
- (void)dealloc
{
	self.returnVisit = nil;
	[super dealloc];
}
@end




/******************************************************************
 *
 *   NAME
 *
 ******************************************************************/
#pragma mark NameCellController

@interface NameViewSectionController : GenericTableViewSectionController
{
	CallViewController *delegate;
}
@property (nonatomic, assign) CallViewController *delegate;
@end
@implementation NameViewSectionController
@synthesize delegate;

- (BOOL)isViewableWhenNotEditing
{
	return [self.delegate.call.name length];
}
@end


@interface NameCellController : CallViewCellController<UITableViewTextFieldCellDelegate>
{
	UITextField *_name;
	BOOL obtainFocus;
}
@property (nonatomic, retain) UITextField *name;
@property (nonatomic, assign) BOOL obtainFocus;
@end
@implementation NameCellController
@synthesize name = _name;
@synthesize obtainFocus;

- (void)dealloc
{
	self.name = nil;
	
	[super dealloc];
}

- (BOOL)isViewableWhenNotEditing
{
	return [self.delegate.call.name length];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return tableView.editing ? indexPath : nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 50.0;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewTextFieldCell *cell = (UITableViewTextFieldCell *)[tableView dequeueReusableCellWithIdentifier:@"NameCell"];
	if(cell == nil)
	{
		cell = [[[UITableViewTextFieldCell alloc] initWithStyle: UITableViewCellStyleDefault textField:_name reuseIdentifier:@"NameCell"] autorelease];
		cell.allowSelectionWhenNotEditing = NO;
	}
	else
	{
		cell.textField = _name;
	}
	cell.delegate = self;
	cell.observeEditing = YES;
	if(tableView.editing)
	{
		if(self.obtainFocus)
		{
			[cell.textField performSelector:@selector(becomeFirstResponder)
			 withObject:nil
			 afterDelay:0.0000001];
			self.obtainFocus = NO;
		}
		
		//  make it where they can hit hext and go into the address view to setup the address
		cell.nextKeyboardResponder = [[[SelectAddressView alloc] initWithTable:tableView indexPath:[NSIndexPath indexPathForRow:0 inSection:1]] autorelease];
	}
	
	return cell;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[_name becomeFirstResponder];
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (BOOL)tableViewTextFieldCell:(UITableViewTextFieldCell *)cell shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
{
	NSString *theText = [cell.value stringByReplacingCharactersInRange:range withString:string];
	self.delegate.call.name = theText;
	return YES;
}
@end

/******************************************************************
 *
 *   ADDRESS
 *
 ******************************************************************/
#pragma mark AddressCellController

@interface AddressViewSectionController : GenericTableViewSectionController
{
	CallViewController *delegate;
}
@property (nonatomic, assign) CallViewController *delegate;
@end
@implementation AddressViewSectionController
@synthesize delegate;

- (BOOL)isViewableWhenNotEditing
{
	MTCall *call = self.delegate.call;
	if([[call addressNumberAndStreet] length] || [[call addressCityAndState] length])
	{
		return YES;
	}
	return NO;
}
@end


@interface AddressCellController : CallViewCellController<AddressViewControllerDelegate>
{
}
@end
@implementation AddressCellController

- (BOOL)isViewableWhenNotEditing
{
	MTCall *call = self.delegate.call;
	if([[call addressNumberAndStreet] length] || [[call addressCityAndState] length])
	{
		return YES;
	}
	return NO;
}

- (void)addressViewControllerDone:(AddressViewController *)addressViewController
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	MTCall *call = self.delegate.call;
	call.houseNumber = addressViewController.streetNumber ? addressViewController.streetNumber : @"";
	call.apartmentNumber = addressViewController.apartmentNumber ? addressViewController.apartmentNumber : @"";
	call.street = addressViewController.street ? addressViewController.street : @"";
	call.city = addressViewController.city ? addressViewController.city : @"";
	call.state = addressViewController.state ? addressViewController.state : @"";
	// remove the gps location so that they will look it up again
	
	self.delegate.call.locationAquiredValue = NO;
	self.delegate.call.locationAquisitionAttempted = NO;

	[self.delegate save];

	// stop trying to get a location... if they want to go back into the address view, they can startup the location then
	self.delegate.locationManager = nil;
	
	NSIndexPath *selectedRow = [self.delegate.tableView indexPathForSelectedRow];
	if(selectedRow)
	{
		[self.delegate.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
	}
	else
	{
		self.delegate.forceReload = YES;
	}
	if(![self.delegate.call.locationLookupType isEqualToString:CallLocationTypeManual])
	{
		[[Geocache sharedInstance] lookupCall:self.delegate.call];
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 70.0;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	AddressTableCell *cell = (AddressTableCell *)[tableView dequeueReusableCellWithIdentifier:@"AddressCell"];
	if(cell == nil)
	{
		cell = [[[AddressTableCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddressCell"] autorelease];
	}
	MTCall *call = self.delegate.call;
	cell.topLabel.text = call.addressNumberAndStreet;
	cell.bottomLabel.text = call.addressCityAndState;
	
	return cell;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	MTCall *call = self.delegate.call;
	NSString *streetNumber = call.houseNumber;
	NSString *apartmentNumber = call.apartmentNumber;
	NSString *street = call.street;
	NSString *city = call.city;
	NSString *state = call.state;

	if(tableView.editing)
	{
		BOOL askAboutReverseGeocoding = NO;
		
		// if they have not initialized the address then assume that it is
		// the same as the last one
		if((streetNumber == nil || [streetNumber isEqualToString:@""]) &&
		   (apartmentNumber == nil || [apartmentNumber isEqualToString:@""]) &&
		   (street == nil || [street isEqualToString:@""]) &&
		   (city == nil || [city isEqualToString:@""]) &&
		   (state == nil || [state isEqualToString:@""]))
		{
			askAboutReverseGeocoding = YES;
			MTSettings *settings = [MTSettings settings];
			// if they are in an apartment territory then just null out the apartment number
			streetNumber = settings.lastHouseNumber;
			apartmentNumber = settings.lastApartmentNumber;
			if(apartmentNumber.length)
				apartmentNumber = @"";
			else
				streetNumber = @"";
			street = settings.lastStreet;
			city = settings.lastCity;
			state = settings.lastState;
		}
		// open up the edit address view 
		AddressViewController *viewController = [[[AddressViewController alloc] initWithStreetNumber:streetNumber
																			               apartment:apartmentNumber
																							  street:street
																							    city:city
																							   state:state
																			askAboutReverseGeocoding:askAboutReverseGeocoding] autorelease];
		viewController.delegate = self;
		[self.delegate.navigationController pushViewController:viewController animated:YES];
		[self.delegate retainObject:self whileViewControllerIsManaged:viewController];
		return;
	}
	else
	{
		// if they have not initialized the address then dont show the map program
		// if they have initalized a latLong then include that
		if(!(street.length == 0 &&
			 city.length == 0 &&
			 state.length == 0) ||
		   call.locationAquired)
		{
			// pop up a alert sheet to display buttons to show in google maps?
			//http://maps.google.com/?hl=en&q=kansas+city
			
			
			// make sure that we have default values for each of the address parts
			if(streetNumber == nil)
				streetNumber = @"";
			if(apartmentNumber == nil || apartmentNumber.length == 0)
				apartmentNumber = @"";
			else
				apartmentNumber = [NSString stringWithFormat:@"(%@)", apartmentNumber];
			if(street == nil)
				street = @"";
			if(city == nil)
				city = @"";
			if(state == nil)
				state = @"";

			NSString *first = [[MTCall topLineOfAddressWithHouseNumber:streetNumber apartmentNumber:apartmentNumber street:street] stringWithEscapedCharacters];
			NSString *second = [[MTCall bottomLineOfAddressWithCity:city state:state] stringWithEscapedCharacters];

			NSString *latLong;
			if(!call.locationAquired)
			{
				latLong = @"";
			}
			else
			{
				latLong = [NSString stringWithFormat:@"@%@,%@", call.lattitude, call.longitude];
			}
			// open up a url
			NSURL *url = [NSURL URLWithString:[NSString 
											   stringWithFormat:@"http://maps.google.com/?lh=%@&q=%@+%@%@", 
											   NSLocalizedString(@"en", @"Google Localized Language Name"),
											   first, 
											   second,
											   latLong]];
			DEBUG(NSLog(@"Trying to open url %@", url);)
			// open up the google map page for this call
			[[UIApplication sharedApplication] openURL:url];
		}
		[self.delegate.tableView deselectRowAtIndexPath:[self.delegate.tableView indexPathForSelectedRow] animated:YES];
	}
}

@end

/******************************************************************
 *
 *   LOCATION
 *
 ******************************************************************/
#pragma mark LocationCellController

@interface LocationCellController : CallViewCellController<LocationPickerViewControllerDelegate, SelectPositionMapViewControllerDelegate>
{
}
@end
@implementation LocationCellController

- (void)locationPickerViewControllerDone:(LocationPickerViewController *)locationPickerViewController
{
	MTCall *call = self.delegate.call;
	call.locationLookupType = locationPickerViewController.type;
	if([locationPickerViewController.type isEqualToString:CallLocationTypeManual])
	{
		[self.delegate save];
		[[self.delegate navigationController] popViewControllerAnimated:NO];
		
		CLLocationCoordinate2D location;
		location.latitude = [call.lattitude doubleValue];
		location.longitude = [call.longitude doubleValue];
		
		MTSettings *settings = [MTSettings settings];
		CLLocationCoordinate2D defaultPosition;
		defaultPosition.latitude = settings.lastLattitudeValue;
		defaultPosition.longitude = settings.lastLongitudeValue;
		
		SelectPositionMapViewController *controller = [[[SelectPositionMapViewController alloc] initWithPosition:(call.locationAquiredValue ? &location : nil) defaultPosition:defaultPosition] autorelease];
		controller.delegate = self;
		[[self.delegate navigationController] pushViewController:controller animated:YES];
		[self.delegate retainObject:self whileViewControllerIsManaged:controller];
		return;
	}
	else
	{
		if([locationPickerViewController.type isEqualToString:CallLocationTypeGoogleMaps])
		{
			// they are using google maps so kick off a lookup
			[[Geocache sharedInstance] lookupCall:self.delegate.call];
		}
		NSIndexPath *selectedRow = [self.delegate.tableView indexPathForSelectedRow];
		if(selectedRow)
		{
			[self.delegate.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
		}
		else
		{
			self.delegate.forceReload = YES;
		}
		[self.delegate save];

		[[self.delegate navigationController] popViewControllerAnimated:YES];
	}
}

- (void)selectPositionMapViewControllerDone:(SelectPositionMapViewController *)selectPositionMapViewController
{
	MTSettings *settings = [MTSettings settings];
	settings.lastLattitudeValue = selectPositionMapViewController.point.latitude;
	settings.lastLongitudeValue = selectPositionMapViewController.point.longitude;
	MTCall *call = self.delegate.call;
	call.lattitude = [[[NSDecimalNumber alloc] initWithDouble:selectPositionMapViewController.point.latitude] autorelease];
	call.longitude = [[[NSDecimalNumber alloc] initWithDouble:selectPositionMapViewController.point.longitude] autorelease];
	call.locationAquiredValue = YES;
	
	[self.delegate save];
	NSIndexPath *selectedRow = [self.delegate.tableView indexPathForSelectedRow];
	if(selectedRow)
	{
		[self.delegate.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
	}
	else
	{
		self.delegate.forceReload = YES;
	}
	[[selectPositionMapViewController navigationController] popViewControllerAnimated:YES];
}


- (BOOL)isViewableWhenNotEditing
{
	return NO;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[tableView dequeueReusableCellWithIdentifier:@"locationCell"];
	if(cell == nil)
	{
		cell = [[[UITableViewTitleAndValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"locationCell"] autorelease];
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;

	MTCall *call = self.delegate.call;
	NSString *locationType = call.locationLookupType;
	[cell setValue:[[PSLocalization localizationBundle] localizedStringForKey:locationType value:locationType table:@""]];
	
	// if this does not have a latitude/longitude then look it up
	if(call.locationAquiredValue)
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		cell.editingAccessoryType = UITableViewCellAccessoryCheckmark;
	}
	
	// if this does not have a latitude/longitude then look it up
	if(!call.locationAquiredValue && [call.locationLookupType isEqualToString:CallLocationTypeGoogleMaps])
	{
		// TODO: Need to have a spinnie show up here
	}
	return cell;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	LocationPickerViewController *p = [[[LocationPickerViewController alloc] initWithCall:self.delegate.call] autorelease];
	p.delegate = self;
	
	[[self.delegate navigationController] pushViewController:p animated:YES];		
	[self.delegate retainObject:self whileViewControllerIsManaged:p];
}

@end

/******************************************************************
 *
 *   METADATA
 *
 ******************************************************************/
#pragma mark CallMetadataCellController

@interface MetadataViewSectionController : GenericTableViewSectionController
{
	CallViewController *delegate;
}
@property (nonatomic, assign) CallViewController *delegate;
@end
@implementation MetadataViewSectionController
@synthesize delegate;

- (BOOL)isViewableWhenNotEditing
{
	return self.delegate.call.additionalInformation.count;
}
@end


@interface CallMetadataCellController : CallViewCellController <MetadataViewControllerDelegate, 
															    MetadataEditorViewControllerDelegate, 
																UITableViewSwitchCellDelegate,
																MultipleChoiceMetadataViewControllerDelegate>
{
	BOOL add;
	MTAdditionalInformation *_metadata;
	UIViewController *_viewController;
}
@property (nonatomic, assign) BOOL add;
@property (nonatomic, retain) MTAdditionalInformation *metadata;
@property (nonatomic, retain) UIViewController *viewController;
@end
@implementation CallMetadataCellController
@synthesize add;
@synthesize metadata = _metadata;
@synthesize viewController = _viewController;

- (void)dealloc
{
	self.viewController = nil;
	self.metadata = nil;
	[super dealloc];
}

- (void)metadataViewControllerAddPreferredMetadata:(MetadataViewController *)metadataViewController metadata:(MTAdditionalInformationType *)type
{
	self.delegate.forceReload = YES;
}

- (void)metadataViewControllerRemoveMetadata:(MetadataViewController *)metadataViewController metadata:(MTAdditionalInformationType *)type
{
	self.delegate.forceReload = YES;
}

- (void)metadataViewControllerAdd:(MetadataViewController *)metadataViewController metadata:(MTAdditionalInformationType *)type
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	MTCall *call = self.delegate.call;
	NSManagedObjectContext *moc = call.managedObjectContext;
	MTAdditionalInformation *info = [MTAdditionalInformation insertInManagedObjectContext:moc];
	info.call = self.delegate.call;
	info.type = type;
	
	switch(info.type.typeValue)
	{
		case PHONE:
		case EMAIL:
		case NOTES:
		case URL:
		case STRING:
			info.value = @"";
			break;
			
		case SWITCH:
			info.value = @"";
			info.booleanValue = NO;
			break;
			
		case DATE:
		{
			NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
			[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
			if([[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"en_GB"])
			{
				[dateFormatter setDateFormat:@"EEE, d/M/yyy h:mma"];
			}
			else
			{
				[dateFormatter setDateFormat:NSLocalizedString(@"EEE, M/d/yyy h:mma", @"localized date string string using http://unicode.org/reports/tr35/tr35-4.html#Date_Format_Patterns as a guide to how to format the date")];
			}
			NSDate *date = [NSDate date];
			NSString *formattedDateString = [NSString stringWithString:[dateFormatter stringFromDate:date]];			
			info.value = formattedDateString;
			info.date = date;
			break;
		}
	}
	CallMetadataCellController *cellController = [[[CallMetadataCellController alloc] init] autorelease];
	cellController.metadata = info;
	cellController.delegate = self.delegate;
	[[[self.delegate.displaySectionControllers objectAtIndex:self.indexPath.section] cellControllers] insertObject:cellController atIndex:self.indexPath.row];
	
	[self.delegate save];

	[self.delegate.navigationController popViewControllerAnimated:YES];

	[self.delegate updateWithoutReload];
}

- (BOOL)isViewableWhenNotEditing
{
	return !self.add;
}

- (void)metadataEditorViewControllerDone:(MetadataEditorViewController *)metadataEditorViewController
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	
	self.metadata.value = [metadataEditorViewController value];
	switch(self.metadata.type.typeValue)
	{
		case PHONE:
		case EMAIL:
		case NOTES:
		case URL:
		case STRING:
			break;
			
		case SWITCH:
			self.metadata.booleanValue = [metadataEditorViewController boolValue];
			break;
			
		case DATE:
			self.metadata.date = [metadataEditorViewController date];
			break;
	}
	
	[self.delegate save];
	NSIndexPath *selectedRow = [self.delegate.tableView indexPathForSelectedRow];
	if(selectedRow)
	{
		[self.delegate.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
	}
	else
	{
		self.delegate.forceReload = YES;
	}
	[metadataEditorViewController.navigationController popViewControllerAnimated:YES];
}

- (void)multipleChoiceMetadataViewControllerDone:(MultipleChoiceMetadataViewController *)metadataCustomViewController
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	
	self.metadata.value = [metadataCustomViewController value];
	
	[self.delegate save];
	NSIndexPath *selectedRow = [self.delegate.tableView indexPathForSelectedRow];
	if(selectedRow)
	{
		[self.delegate.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
	}
	else
	{
		self.delegate.forceReload = YES;
	}
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return self.add ? UITableViewCellEditingStyleInsert : UITableViewCellEditingStyleDelete;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(add)
		return tableView.rowHeight;
	
	if(self.metadata.type.typeValue == NOTES &&
	   [self.metadata.value length])
	{
		return [UITableViewMultilineTextCell heightForWidth:(tableView.bounds.size.width - 90) withText:self.metadata.value];
	}
	else
	{
		return tableView.rowHeight;
	}
}

- (void)uiTableViewSwitchCellChanged:(UITableViewSwitchCell *)uiTableViewSwitchCell
{
	self.metadata.value = uiTableViewSwitchCell.booleanSwitch.on ? NSLocalizedString(@"YES", @"YES for boolean switch in additional information") : NSLocalizedString(@"NO", @"NO for boolean switch in additional information"); 
	self.metadata.booleanValue = uiTableViewSwitchCell.booleanSwitch.on;
	
	[self.delegate save];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(add)
	{
		UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[tableView dequeueReusableCellWithIdentifier:@"addMetadataCell"];
		if(cell == nil)
		{
			cell = [[[UITableViewTitleAndValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"addMetadataCell"] autorelease];
			cell.accessoryType = UITableViewCellAccessoryNone;
			[cell setValue:NSLocalizedString(@"Add Additional Information", @"Button to click to add more information like phone number and email address")];
		}
		
		return cell;
	}
	else
	{
		int type = self.metadata.type.typeValue;
		NSString *name = self.metadata.type.name;
		NSString *value = self.metadata.value;
		
		if(type == NOTES)
		{
			UITableViewMultilineTextCell *cell = (UITableViewMultilineTextCell *)[tableView dequeueReusableCellWithIdentifier:@"MetadataNotesCell"];
			if(cell == nil)
			{
				cell = [[[UITableViewMultilineTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MetadataNotesCell"] autorelease];
				cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			}
			cell.allowSelectionWhenNotEditing = NO;
			[cell setText:value.length ? value : name];
			return(cell);
		}
		else if(type == SWITCH)
		{
			UITableViewSwitchCell *cell = (UITableViewSwitchCell *)[tableView dequeueReusableCellWithIdentifier:@"SwitchCell"];
			if(cell == nil)
			{
				self.viewController = [[[UIViewController alloc] initWithNibName:@"UITableViewSwitchCell" bundle:nil] autorelease];
				cell = (UITableViewSwitchCell *)self.viewController.view;
				cell.observeEditing = YES;
				cell.selectionStyle = UITableViewCellSelectionStyleNone;
			}
			else
			{
				cell = (UITableViewSwitchCell *)self.viewController.view;
			}
			
			cell.otherTextLabel.text = name;
			cell.delegate = self;
			cell.booleanSwitch.on = self.metadata.booleanValue;
			return cell;
		}
		else
		{
			UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[tableView dequeueReusableCellWithIdentifier:@"MetadataCell"];
			if(cell == nil)
			{
				cell = [[[UITableViewTitleAndValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"MetadataCell"] autorelease];
				cell.accessoryType = UITableViewCellAccessoryNone;
				cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
				cell.allowSelectionWhenNotEditing = NO;
			}
			
			switch(type)
			{
				case PHONE:
				case EMAIL:
				case URL:
					cell.allowSelectionWhenNotEditing = YES;
					// fallthrough
				default:
					[cell setTitle:[[PSLocalization localizationBundle] localizedStringForKey:name value:name table:@""]];
					[cell setValue:value];
					break;
			}
			return cell;
		}
	}
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(tableView.editing)
		return indexPath;

	switch(self.metadata.type.typeValue)
	{
		case PHONE:
		case EMAIL:
		case URL:
			return indexPath;
			break;
	}
	
	return nil;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.indexPath = [[indexPath copy] autorelease];
	if(add)
	{
		// make the new call view 
		MetadataViewController *p = [[[MetadataViewController alloc] init] autorelease];
		p.delegate = self;
		
		[[self.delegate navigationController] pushViewController:p animated:YES];		
		[self.delegate retainObject:self whileViewControllerIsManaged:p];
	}
	else
	{
		int type = self.metadata.type.typeValue;
		NSString *name = self.metadata.type.name;
		NSString *value = self.metadata.value;
		
		if(type != SWITCH)
		{
			if(tableView.editing)
			{
				switch(type)
				{
					case CHOICE:
					{
						MultipleChoiceMetadataViewController *p = [[[MultipleChoiceMetadataViewController alloc] initWithAdditionalInformation:self.metadata] autorelease];
						p.delegate = self;
						
						[[self.delegate navigationController] pushViewController:p animated:YES];		
						[self.delegate retainObject:self whileViewControllerIsManaged:p];
						break;
					}	
					case DATE:
					{
						// make the new call view 
						MetadataEditorViewController *p = [[[MetadataEditorViewController alloc] initWithName:name type:type data:self.metadata.date value:value] autorelease];
						p.delegate = self;
						p.tag = indexPath.row;
						
						[[self.delegate navigationController] pushViewController:p animated:YES];		
						[self.delegate retainObject:self whileViewControllerIsManaged:p];
						break;
					}	
					default:
					{
						// make the new call view 
						MetadataEditorViewController *p = [[[MetadataEditorViewController alloc] initWithName:name type:type data:value value:value] autorelease];
						p.delegate = self;
						p.tag = indexPath.row;
						
						[[self.delegate navigationController] pushViewController:p animated:YES];		
						[self.delegate retainObject:self whileViewControllerIsManaged:p];
						break;
					}
				}
			}
			else
			{
				switch(type)
				{
					case PHONE:
						if(value)
						{
							[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", value]]];
							[tableView deselectRowAtIndexPath:indexPath animated:YES];
						}
						break;
					case EMAIL:
						if(value)
						{
							[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", value]]];
							[tableView deselectRowAtIndexPath:indexPath animated:YES];
						}
						break;
					case URL:
						if(value)
						{
							NSString *url;
							if([value hasPrefix:@"http://"])
								url = value;
							else
								url = [NSString stringWithFormat:@"http://%@", value];
							[[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
							[tableView deselectRowAtIndexPath:indexPath animated:YES];
						}
						break;
				}
			}
		}
	}
}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete)
	{
		[self.metadata.managedObjectContext deleteObject:self.metadata];

		// save the data
		[self.delegate save];

		[[self retain] autorelease];
		[self.delegate deleteDisplayRowAtIndexPath:indexPath];
	}
	else if(editingStyle == UITableViewCellEditingStyleInsert)
	{
		[self tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
}

@end

/******************************************************************
 *
 *   ADD RETURN VISIT
 *
 ******************************************************************/
#pragma mark AddReturnVisitCellController

@interface ShowAddReturnVisitViewSectionController : GenericTableViewSectionController
{
	CallViewController *delegate;
}
@property (nonatomic, assign) CallViewController *delegate;
@end
@implementation ShowAddReturnVisitViewSectionController
@synthesize delegate;

- (void)dealloc
{
	[super dealloc];
}

-(BOOL)isViewableWhenEditing
{
	return self.delegate.showAddReturnVisit;
}
@end


@interface AddReturnVisitCellController : CallViewCellController
{
}
@end
@implementation AddReturnVisitCellController
- (void)dealloc
{
	[super dealloc];
}

- (void)delayedSelectRow:(NSArray *)array
{
	UITableView *tableView = [array objectAtIndex:0];
	NSIndexPath *indexPath = [array objectAtIndex:1];
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
	[array release];
}

- (void)delayedHighlightRow:(NSArray *)array
{
	UITableView *tableView = [array objectAtIndex:0];
	NSIndexPath *indexPath = [array objectAtIndex:1];
	[tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionMiddle];
	[self performSelector:@selector(delayedSelectRow:) withObject:[array retain] afterDelay:0.3];
	[array release];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(self.delegate.delayedAddReturnVisit)
	{
		self.delegate.delayedAddReturnVisit = NO;
		
		[self performSelector:@selector(delayedHighlightRow:) withObject:[[NSArray arrayWithObjects:tableView, indexPath, nil] retain] afterDelay:0.3];
	}
	return UITableViewCellEditingStyleInsert;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[tableView dequeueReusableCellWithIdentifier:@"AddReturnVisitCell"];
	if(cell == nil)
	{
		cell = [[[UITableViewTitleAndValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddReturnVisitCell"] autorelease];
		cell.accessoryType = UITableViewCellAccessoryNone;
	}
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[cell setValue:NSLocalizedString(@"Add a return visit", @"Add a return visit action button")];
	return(cell);
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	DEBUG(NSLog(@"addReturnVisitSelected _selectedRow=%d", indexPath.row);)
	if(!tableView.editing)
	{
		[self.delegate addReturnVisitAndEdit];
		return;
	}
	[self.delegate setShowAddReturnVisit:NO];
	
	MTReturnVisit *visit = [MTReturnVisit insertInManagedObjectContext:self.delegate.call.managedObjectContext];
	visit.call = self.delegate.call;
	
	// now update the tableview
	GenericTableViewSectionController *sectionController = [self.delegate genericTableViewSectionControllerForReturnVisit:visit];

	// remove the row from the list of all SectionControllers
	int section = [self.delegate.sectionControllers indexOfObjectIdenticalTo:[self.delegate.displaySectionControllers objectAtIndex:indexPath.section]] + 1;
	// put the new one in its place.
	[self.delegate.sectionControllers insertObject:sectionController atIndex:section];

	[self.delegate.tableView beginUpdates];
		[self.delegate updateTableViewInsideUpdateBlockWithDeleteRowAnimation:UITableViewRowAnimationLeft insertAnimation:UITableViewRowAnimationRight];
	[self.delegate.tableView endUpdates];
}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self tableView:tableView didSelectRowAtIndexPath:indexPath];
}

@end



@interface ReturnVisitNotesCell : UITableViewMultilineTextCell
{
	BOOL lastCell;
}
@property (nonatomic, assign) BOOL lastCell;
@end
@implementation ReturnVisitNotesCell
@synthesize lastCell;

- (void)willTransitionToState:(UITableViewCellStateMask)state
{
	[super willTransitionToState:state];
	if(state & UITableViewCellStateEditingMask)
	{
		
		if([textView.text isEqualToString:NSLocalizedString(@"Initial Visit Notes", @"Initial Visit Notes default text when the user did not enter notes, displayed on the view-mode Call view")])
			[self setText:NSLocalizedString(@"Add Notes", @"Return Visit Notes Placeholder text")];
		else if([textView.text isEqualToString:NSLocalizedString(@"Return Visit Notes", @"Return Visit Notes default text when the user did not enter notes, displayed on the view-mode Call view")])
			[self setText:NSLocalizedString(@"Add Notes", @"Return Visit Notes Placeholder text")];
	}
	else
	{
		if([textView.text isEqualToString:NSLocalizedString(@"Add Notes", @"Return Visit Notes Placeholder text")])
		{
			if(self.lastCell)
				[self setText:NSLocalizedString(@"Initial Visit Notes", @"Initial Visit Notes default text when the user did not enter notes, displayed on the view-mode Call view")];
			else
				[self setText:NSLocalizedString(@"Return Visit Notes", @"Return Visit Notes default text when the user did not enter notes, displayed on the view-mode Call view")];
		}
	}
}
@end


/******************************************************************
 *
 *   RETURN VISIT NOTES
 *
 ******************************************************************/
#pragma mark ReturnVisitNotesCellController

@interface ReturnVisitNotesCellController : ReturnVisitCellController<NotesViewControllerDelegate>
{
}
@end
@implementation ReturnVisitNotesCellController

- (void)notesViewControllerDone:(NotesViewController *)notesViewController
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
    returnVisit.notes = [notesViewController notes];
	[self.delegate save];
	NSIndexPath *selectedRow = [self.delegate.tableView indexPathForSelectedRow];
	if(selectedRow)
	{
		[self.delegate.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
	}
	else
	{
		self.delegate.forceReload = YES;
	}

	[self.delegate.navigationController popToViewController:self.delegate animated:YES];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return tableView.editing ? indexPath : nil;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return self.delegate.call.returnVisits.count == 1 ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [UITableViewMultilineTextCell heightForWidth:(tableView.bounds.size.width - 90) withText:self.returnVisit.notes];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	ReturnVisitNotesCell *cell = (ReturnVisitNotesCell *)[tableView dequeueReusableCellWithIdentifier:@"NotesCell"];
	if(cell == nil)
	{
		cell = [[[ReturnVisitNotesCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"NotesCell"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.allowSelectionWhenNotEditing = NO;
	}
	BOOL initialVisit = NO;
	if([returnVisit isEqual:[[returnVisit.managedObjectContext fetchObjectsForEntityName:[MTReturnVisit entityName]
																	  propertiesToFetch:[NSArray array]
																	withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"date" ascending:NO]]
																		  withPredicate:@"(call == %@)", self.delegate.call] lastObject]])
	{
		initialVisit = YES;
	}
	
	cell.lastCell = initialVisit;
	NSString *notes = self.returnVisit.notes;
	
	if(tableView.editing)
	{
		if([notes length] == 0)
			[cell setText:NSLocalizedString(@"Add Notes", @"Return Visit Notes Placeholder text")];
		else
			[cell setText:notes];
	}
	else
	{
		if([notes length] == 0)
		{
			if(cell.lastCell)
				[cell setText:NSLocalizedString(@"Initial Visit Notes", @"Initial Visit Notes default text when the user did not enter notes, displayed on the view-mode Call view")];
			else
				[cell setText:NSLocalizedString(@"Return Visit Notes", @"Return Visit Notes default text when the user did not enter notes, displayed on the view-mode Call view")];
		}
		else
		{
			[cell setText:notes];
		}
	}
	return(cell);
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	DEBUG(NSLog(@"changeNotesForReturnVisitAtIndex: %d", index);)
	NSString *notes = self.returnVisit.notes;
	if(notes == nil || notes.length == 0)
	{
		// make the new call view 
		QuickNotesViewController *p = [[[QuickNotesViewController alloc] init] autorelease];
		p.delegate = self;
		p.managedObjectContext = self.delegate.call.managedObjectContext;
		[[self.delegate navigationController] pushViewController:p animated:YES];		
		[self.delegate retainObject:self whileViewControllerIsManaged:p];
	}
	else 
	{
		// make the new call view 
		NotesViewController *p = [[[NotesViewController alloc] initWithNotes:notes] autorelease];
		p.delegate = self;
		[[self.delegate navigationController] pushViewController:p animated:YES];		
		[self.delegate retainObject:self whileViewControllerIsManaged:p];
	}
}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete && self.delegate.call.returnVisits.count != 1)
	{
		DEBUG(NSLog(@"deleteReturnVisitAtIndex: %d", index);)
		
		[self.delegate.call.managedObjectContext deleteObject:returnVisit];
		
		// save the data
		[self.delegate save];
		
		[self.delegate deleteDisplaySectionAtIndexPath:indexPath];
	}
}

@end

/******************************************************************
 *
 *   CHANGE DATE OF RETURN VISIT
 *
 ******************************************************************/
#pragma mark ReturnVisitDateCellController

@interface ReturnVisitDateCellController : ReturnVisitCellController<DatePickerViewControllerDelegate>
{
}
@end
@implementation ReturnVisitDateCellController

- (void)datePickerViewControllerDone:(DatePickerViewController *)datePickerViewController
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
    VERBOSE(NSLog(@"date is now = %@", [datePickerViewController date]);)
	
    self.returnVisit.date = [datePickerViewController date];
	
	[self.delegate save];

	// just in case they changed the date to reorder them
	self.delegate.forceReload = YES;
	[[self.delegate navigationController] popViewControllerAnimated:YES];
}

- (BOOL)isViewableWhenNotEditing
{
	return NO;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return tableView.editing ? indexPath : nil;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[tableView dequeueReusableCellWithIdentifier:@"ChangeDateCell"];
	if(cell == nil)
	{
		cell = [[[UITableViewTitleAndValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ChangeDateCell"] autorelease];
		cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
		[cell setValue:NSLocalizedString(@"Change Date", @"Change Date action button for visit in call view")];
		cell.allowSelectionWhenNotEditing = NO;
	}
	
	return cell;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	DEBUG(NSLog(@"changeDateOfReturnVisitAtIndex: %d", index);)
	
	// make the new call view 
	DatePickerViewController *p = [[[DatePickerViewController alloc] initWithDate:self.returnVisit.date] autorelease];
	p.delegate = self;
	[[self.delegate navigationController] pushViewController:p animated:YES];		
	[self.delegate retainObject:self whileViewControllerIsManaged:p];
}

@end

/******************************************************************
 *
 *   CHANGE TYPE OF RETURN VISIT
 *
 ******************************************************************/
#pragma mark ReturnVisitTypeCellController

@interface ReturnVisitTypeCellController : ReturnVisitCellController<ReturnVisitTypeViewControllerDelegate>
{
}
@end
@implementation ReturnVisitTypeCellController

- (void)returnVisitTypeViewControllerDone:(ReturnVisitTypeViewController *)returnVisitTypeViewController
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
    self.returnVisit.type = [returnVisitTypeViewController type];
	[self.delegate save];
	NSIndexPath *selectedRow = [self.delegate.tableView indexPathForSelectedRow];
	if(selectedRow)
	{
		[self.delegate.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
	}
	else
	{
		self.delegate.forceReload = YES;
	}
}

- (BOOL)isViewableWhenNotEditing
{
	BOOL initialVisit = NO;
	if([returnVisit isEqual:[[returnVisit.managedObjectContext fetchObjectsForEntityName:[MTReturnVisit entityName]
																	   propertiesToFetch:[NSArray array]
																	 withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"date" ascending:NO]]
																		   withPredicate:@"(call == %@)", self.delegate.call] lastObject]])
	{
		initialVisit = YES;
	}
	if(initialVisit)
		return ![returnVisit.type isEqualToString:CallReturnVisitTypeInitialVisit];
	else
		return ![returnVisit.type isEqualToString:CallReturnVisitTypeReturnVisit];
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return tableView.editing ? indexPath : nil;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[tableView dequeueReusableCellWithIdentifier:@"returnVisitTypeCell"];
	if(cell == nil)
	{
		cell = [[[UITableViewTitleAndValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"returnVisitTypeCell"] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleBlue;
		cell.accessoryType = UITableViewCellAccessoryNone;
		cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
		cell.allowSelectionWhenNotEditing = NO;
	}

	NSString *type = returnVisit.type;
	[cell setTitle:NSLocalizedString(@"Type", @"Return visit type label")];
	[cell setValue:[[PSLocalization localizationBundle] localizedStringForKey:type value:type table:@""]];
	
	return cell;
}


// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	DEBUG(NSLog(@"isStudyOnForReturnVisitAtIndex: %d", index);)
	
	// they clicked on the Change Type
	NSString *type = self.returnVisit.type;
	
	BOOL initialVisit = NO;
	if([returnVisit isEqual:[[returnVisit.managedObjectContext fetchObjectsForEntityName:[MTReturnVisit entityName]
																	   propertiesToFetch:[NSArray array]
																	 withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"date" ascending:NO]]
																		   withPredicate:@"(call == %@)", self.delegate.call] lastObject]])
	{
		initialVisit = YES;
	}
	 
	// make the new call view 
	ReturnVisitTypeViewController *p = [[[ReturnVisitTypeViewController alloc] initWithType:type isInitialVisit:initialVisit] autorelease];	
	p.delegate = self;	
	[[self.delegate navigationController] pushViewController:p animated:YES];		
	[self.delegate retainObject:self whileViewControllerIsManaged:p];
}

@end

/******************************************************************
 *
 *   RETURN VISIT PUBLICATION
 *
 ******************************************************************/
#pragma mark ReturnVisitPublicationCellController

@interface ReturnVisitPublicationCellController : ReturnVisitCellController<PublicationViewControllerDelegate, PublicationTypeViewControllerDelegate>
{
	MTPublication *publication;
}
@property (nonatomic, retain) MTPublication *publication;
@end
@implementation ReturnVisitPublicationCellController
@synthesize publication;

- (void)dealloc
{
	self.publication = nil;
	[super dealloc];
}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(editingStyle == UITableViewCellEditingStyleDelete)
	{
		DEBUG(NSLog(@"deleteReturnVisitAtIndex: %@", indexPath);)

		// this is the entry that we need to delete
		[self.returnVisit.managedObjectContext deleteObject:self.publication];
		
		// save the data
		[self.delegate save];

		[[self retain] autorelease];
		[self.delegate deleteDisplayRowAtIndexPath:indexPath];
	}
	else if(editingStyle == UITableViewCellEditingStyleInsert)
	{
		[self tableView:tableView didSelectRowAtIndexPath:indexPath];
	}
}


- (void)publicationViewControllerDone:(PublicationViewController *)publicationViewController
{
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	MTPublication *editedPublication = self.publication;
	bool newPublication = (editedPublication == nil);
    if(newPublication)
    {
        VERBOSE(NSLog(@"creating a new publication entry and adding it");)
        // if we are adding a publication then create the NSDictionary and add it to the end
        // of the publications array
		editedPublication = [MTPublication createPublicationForReturnVisit:returnVisit];
    }
    VERBOSE(NSLog(@"_editingPublication was = %@", editedPublication);)
	PublicationPickerView *picker = [publicationViewController publicationPicker];
	
    editedPublication.name = [picker publication];
    editedPublication.title = [picker publicationTitle];
    editedPublication.type = [picker publicationType];
    editedPublication.yearValue = [picker year];
    editedPublication.monthValue = [picker month];
    editedPublication.dayValue =  [picker day];
    VERBOSE(NSLog(@"_editingPublication is = %@", editedPublication);)
	
	// save the data
	[self.delegate save];
	
	if(newPublication)
	{
		// PUBLICATION
		ReturnVisitPublicationCellController *cellController = [[[ReturnVisitPublicationCellController alloc] init] autorelease];
		cellController.delegate = self.delegate;
		cellController.returnVisit = self.returnVisit;
		cellController.publication = editedPublication;
		[[[self.delegate.displaySectionControllers objectAtIndex:self.indexPath.section] cellControllers] insertObject:cellController atIndex:self.indexPath.row];
		
		[self.delegate updateWithoutReload];
	}
	else
	{
		NSIndexPath *selectedRow = [self.delegate.tableView indexPathForSelectedRow];
		if(selectedRow)
		{
			[self.delegate.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:selectedRow] withRowAnimation:UITableViewRowAnimationFade];
		}
		else
		{
			self.delegate.forceReload = YES;
		}
	}		
	[[self.delegate navigationController] popToViewController:self.delegate animated:YES];
}

- (BOOL)isViewableWhenNotEditing
{
	return self.publication != nil;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return self.publication != nil ? UITableViewCellEditingStyleDelete : UITableViewCellEditingStyleInsert;
}

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	return tableView.editing ? indexPath : nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(self.publication)
	{
		UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[tableView dequeueReusableCellWithIdentifier:@"PublicationCell"];
		if(cell == nil)
		{
			cell = [[[UITableViewTitleAndValueCell alloc ] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"PublicationCell"] autorelease];
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.editingAccessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			cell.allowSelectionWhenNotEditing = NO;
		}
		[cell setTitle:self.publication.title];
		return(cell);
	}
	else
	{
		
		UITableViewTitleAndValueCell *cell = (UITableViewTitleAndValueCell *)[tableView dequeueReusableCellWithIdentifier:@"AddPublicationCell"];
		if(cell == nil)
		{
			cell = [[[UITableViewTitleAndValueCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"AddPublicationCell"] autorelease];
			cell.editingAccessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			[cell setValue:NSLocalizedString(@"Add a placed publication", @"Add a placed publication action button in call view")];
		}
		return cell;
	}
}


// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	self.indexPath = [[indexPath copy] autorelease];
	if(self.publication)
	{
		// make the new call view 
		PublicationViewController *p = [[[PublicationViewController alloc] initWithPublication:self.publication.name
																						  year:self.publication.yearValue
																						 month:self.publication.monthValue
																						   day:self.publication.dayValue] autorelease];
		
		p.delegate = self;
		[[self.delegate navigationController] pushViewController:p animated:YES];
		[self.delegate retainObject:self whileViewControllerIsManaged:p];
	}
	else
	{
		// make the new call view 
		PublicationTypeViewController *p = [[[PublicationTypeViewController alloc] init] autorelease];
		p.delegate = self;
		
		[[self.delegate navigationController] pushViewController:p animated:YES];		
		[self.delegate retainObject:self whileViewControllerIsManaged:p];
	}
}

@end


/******************************************************************
 *
 *   DELETE CALL
 *
 ******************************************************************/
#pragma mark DeleteCallCellController
@interface DeleteCallCellController : CallViewCellController<UIActionSheetDelegate>
{
	BOOL deleteForever;
}
@property (nonatomic, assign) BOOL deleteForever;
@end
@implementation DeleteCallCellController
@synthesize deleteForever;

- (BOOL)isViewableWhenNotEditing
{
	return NO;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (void)deleteCall
{
	DEBUG(NSLog(@"deleteCall");)
	UIActionSheet *alertSheet;
	if(self.deleteForever)
	{
		 alertSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to delete the call forever, and remove all return visits, studies, and placed publications in your statistics?", @"Statement to make the user realize that they are deleting a call forever")
												 delegate:self
										cancelButtonTitle:NSLocalizedString(@"No", @"No dont delete the call")
								   destructiveButtonTitle:NSLocalizedString(@"Yes", @"Yes delete the call")
										otherButtonTitles:nil] autorelease];
	}
	else
	{
		alertSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to delete the call?\n\nThe return visits and placed literature will still be counted in your statistics and you can restore or permanently delete this call in the \"Deleted Calls\" View.", @"Statement to make the user realize that this will still save information, and acknowledge they are deleting a call")
												 delegate:self
										cancelButtonTitle:NSLocalizedString(@"No", @"No dont delete the call")
								   destructiveButtonTitle:NSLocalizedString(@"Yes", @"Yes delete the call")
										otherButtonTitles:nil] autorelease];
	}

	// 0: grey with grey and black buttons
	// 1: black background with grey and black buttons
	// 2: transparent black background with grey and black buttons
	// 3: grey transparent background
	alertSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[alertSheet showInView:self.delegate.view];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewButtonCell *cell;
//	cell = (UITableViewButtonCell *)[tableView dequeueReusableCellWithIdentifier:@"DeleteCallCell"];
//	if(cell == nil)
	{
		cell = [[[UITableViewButtonCell alloc ] initWithTitle:NSLocalizedString(@"Delete Call", @"Delete Call button in editing mode of call view") 
														image:[UIImage imageNamed:@"redButton.png"]
												 imagePressed:[UIImage imageNamed:@"redButton.png"]
												darkTextColor:NO
											  reuseIdentifier:nil /*@"DeleteCallCell"*/] autorelease];
	}
	[cell.button addTarget:self action:@selector(deleteCall) forControlEvents:UIControlEventTouchUpInside];
	return cell;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self deleteCall];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)button
{
	VERBOSE(NSLog(@"alertSheet: button:%d", button);)
	if(button == 0)
	{
		if(self.delegate.delegate)
		{
			MTCall *call = self.delegate.call;
			call.deletedCallValue = YES;
			if(self.deleteForever)
			{
				[call.managedObjectContext deleteObject:call];
			}
			[self.delegate save];
			[self.delegate.navigationController popViewControllerAnimated:YES];

			if(self.deleteForever)
			{
				[[NSNotificationCenter defaultCenter] postNotificationName:MTNotificationCallChanged object:nil];
			}
			else
			{
				[[NSNotificationCenter defaultCenter] postNotificationName:MTNotificationCallChanged object:call];
			}

		}
	}
}


@end



/******************************************************************
 *
 *   RESTORE CALL
 *
 ******************************************************************/
#pragma mark RestoreCallCellController
@interface RestoreCallCellController : CallViewCellController<UIActionSheetDelegate>
{
}
@end
@implementation RestoreCallCellController

- (BOOL)isViewableWhenNotEditing
{
	return NO;
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
	return NO;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (void)restoreCall
{
	DEBUG(NSLog(@"deleteCall");)
	UIActionSheet *alertSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to restore the call (your statistics will not change)?", @"Statement to make the user realize that this will still save information, and acknowledge they are deleting a call")
															 delegate:self
												    cancelButtonTitle:NSLocalizedString(@"No", @"No dont restore the call")
											   destructiveButtonTitle:NSLocalizedString(@"Yes", @"Yes restore the call")
												    otherButtonTitles:nil] autorelease];
	// 0: grey with grey and black buttons
	// 1: black background with grey and black buttons
	// 2: transparent black background with grey and black buttons
	// 3: grey transparent background
	alertSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[alertSheet showInView:self.delegate.view];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewButtonCell *cell;
	//	cell = (UITableViewButtonCell *)[tableView dequeueReusableCellWithIdentifier:@"DeleteCallCell"];
	//	if(cell == nil)
	{
		cell = [[[UITableViewButtonCell alloc ] initWithTitle:NSLocalizedString(@"Restore Call", @"Restore Call button in editing mode of call view") 
														image:[UIImage imageNamed:@"blueButton.png"]
												 imagePressed:[UIImage imageNamed:@"blueButton.png"]
												darkTextColor:NO
											  reuseIdentifier:nil /*@"DeleteCallCell"*/] autorelease];
	}
	[cell.button addTarget:self action:@selector(restoreCall) forControlEvents:UIControlEventTouchUpInside];
	return cell;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	[self restoreCall];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)button
{
	VERBOSE(NSLog(@"alertSheet: button:%d", button);)
	if(button == 0)
	{
		self.delegate.call.deletedCallValue = NO;
		[self.delegate save];

		[self.delegate.navigationController popViewControllerAnimated:YES];
	}
}


@end






@implementation CallViewController
@synthesize showAddReturnVisit = _showAddReturnVisit;
@synthesize delegate;
@synthesize currentIndexPath;
@synthesize delayedAddReturnVisit;
@synthesize call = _call;
@synthesize locationManager;
/******************************************************************
 *
 *   INIT
 *
 ******************************************************************/

- (id)initWithCall:(MTCall *)call newCall:(BOOL)newCall
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
    if([super initWithStyle:UITableViewStyleGrouped]) 
    {
		_initialView = YES;
		
		self.hidesBottomBarWhenPushed = YES;
		
        DEBUG(NSLog(@"CallView 2initWithFrame:call:%@", call);)

		_setFirstResponderGroup = -1;
		

		_newCall = newCall;
		_showDeleteButton = !_newCall;
		self.call = call;
		if(_newCall)
		{
			_setFirstResponderGroup = 0;
			_showAddReturnVisit = NO;

			// create a location manager and start getting updates for the location so that we can quickly 
			// obtain the location in the address view
			self.locationManager = [[[CLLocationManager alloc] init] autorelease];
			self.locationManager.delegate = self; // Tells the location manager to send updates to this object
			self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
			[self.locationManager startUpdatingLocation];
		}
		else
		{
			_showAddReturnVisit = YES;
		}

		_name = [[UITextField alloc] initWithFrame:CGRectZero];
		_name.autocapitalizationType = UITextAutocapitalizationTypeWords;
		_name.returnKeyType = UIReturnKeyDone;
        // _name (make sure that it is initalized)
        //[_name setText:NSLocalizedString(@"Name", @"Name label for Call in editing mode")];
		_name.placeholder = NSLocalizedString(@"Name", @"Name label for Call in editing mode");
		_name.text = _call.name;

		if(_newCall)
		{
			self.title = NSLocalizedString(@"New Call", @"Call main title when you are adding a new call");
		}
		else
		{
			self.title = NSLocalizedString(@"Call", @"Call main title when editing an existing call");
		}
    }
    
    return(self);
}

- (void)dealloc 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)

	_name.delegate = nil;
    [_name release];
    self.call = nil;

	if(self.locationManager)
		self.locationManager.delegate = nil;
	self.locationManager = nil;
	
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return(YES);
}

- (void)save
{
	// Save the context.
	NSError *error = nil;
	[_call.managedObjectContext processPendingChanges];
	if (![_call.managedObjectContext save:&error]) 
	{
		[NSManagedObjectContext presentErrorDialog:error];
	}
}


- (void)navigationControlEdit:(id)sender 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	_showDeleteButton = YES;
	_showAddReturnVisit = YES;
	
	[self.tableView flashScrollIndicators];
	
	// update the button in the nav bar
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(navigationControlDone:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:YES];
	
	// update the button in the nav bar
	button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction
															target:self
															action:@selector(navigationControlActionSheet:)] autorelease];
	[self.navigationItem setLeftBarButtonItem:button animated:YES];
	
	// hide the back button so that they cant cancel the edit without hitting done
	self.navigationItem.hidesBackButton = YES;
	
	self.editing = YES;
}	

- (void)navigationControlDone:(id)sender 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	
	[_name resignFirstResponder];
	[self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:NO];
	[self.tableView flashScrollIndicators];
	
	// update the button in the nav bar
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
																			 target:self
																			 action:@selector(navigationControlEdit:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:YES];
	[self.navigationItem setLeftBarButtonItem:nil animated:YES];
	// show the back button when they are done editing
	self.navigationItem.hidesBackButton = NO;
	
	BOOL isNewCall = _newCall;
	// we dont save a new call untill they hit "Done"
	_newCall = NO;

	// we need to reload data now, so we need to hide:
	//   the name field if it does not have a value
	//   the insert new call
	//   the per call insert a new publication
	
	_showAddReturnVisit = YES;
	_showDeleteButton = YES;
	
	// save
	[self retain];
	[self save];
	[[NSNotificationCenter defaultCenter] postNotificationName:MTNotificationCallChanged object:self.call];
	
	if(isNewCall)
	{
		if([self.delegate respondsToSelector:@selector(callViewController:newCallDone:)])
		{
			[self.delegate callViewController:self newCallDone:_call];
		}
	}
	else
	{
		self.editing = NO;
	}		
	[self autorelease];
}	

- (void)navigationControlCancel:(id)sender 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	self.call = nil;
	[self.navigationController popViewControllerAnimated:YES];
}

- (void)navigationControlActionSheet:(id)sender 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	UIActionSheet *alertSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"You can transfer this call to someone else. Transferring will delete this call from your data, but your statistics from this call will stay. The witness who gets this email will be able to click on a link in the email and add the call to MyTime.", @"This message is displayed when the user clicks on a Call then clicks on Edit and clicks on the \"Action\" button at the top left of the screen")
															 delegate:self
												    cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button")
											   destructiveButtonTitle:NSLocalizedString(@"Transfer, and Delete", @"Transferr this call to another MyTime user and delete it off of this iphone, but keep the data")
												    otherButtonTitles:NSLocalizedString(@"Email Details", @"Email the call details to another MyTime user"), nil] autorelease];

	alertSheet.actionSheetStyle = UIActionSheetStyleBlackOpaque;
	[alertSheet showInView:self.view];
	_actionSheetSource = YES;
}

- (void)addReturnVisitAndEdit
{
	self.delayedAddReturnVisit = YES;
	[self navigationControlEdit:nil];
}

- (void)scrollToSelected:(id)unused
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	[self.tableView scrollToNearestSelectedRowAtScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	// force the tableview to load
//	[self reloadData];
//	[theTableView reloadData];
}


- (void)viewDidAppear:(BOOL)animated 
{
	[super viewDidAppear:animated];

    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)

	MTSettings *settings = [MTSettings settings];
	if(!_newCall && !settings.existingCallAlertSheetShownValue)
	{
		settings.existingCallAlertSheetShownValue = YES;
		NSError *error = nil;
		[settings.managedObjectContext processPendingChanges];
		if (![settings.managedObjectContext save:&error]) 
		{
			[NSManagedObjectContext presentErrorDialog:error];
		}
		
		UIAlertView *alertSheet = [[[UIAlertView alloc] init] autorelease];
		[alertSheet addButtonWithTitle:NSLocalizedString(@"OK", @"OK button")];
		alertSheet.title = NSLocalizedString(@"Touch the Edit button to add a return visit or you can see where your call is located by touching the address of your call", @"This is a note displayed when they first see the non editable call view");
		[alertSheet show];
	}
}

- (void)viewWillDisappear:(BOOL)animated
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	[_name resignFirstResponder];
}

- (void)didReceiveMemoryWarning
{
	[super didReceiveMemoryWarning];
}

- (void)loadView 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	[super loadView];
	
	[self updateWithoutReload];
	
	if(_newCall)
	{
		self.editing = YES;
	}
	
	if(_newCall || self.editing)
	{
		// add DONE button
		UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																				 target:self
																				 action:@selector(navigationControlDone:)] autorelease];
		[self.navigationItem setRightBarButtonItem:button animated:NO];
	}
	else
	{
		// add EDIT button
		UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit
																				 target:self
																				 action:@selector(navigationControlEdit:)] autorelease];
		[self.navigationItem setRightBarButtonItem:button animated:NO];
	}
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
	[_name resignFirstResponder];
}

- (void)constructSectionControllers
{
	DEBUG(NSLog(@"CallView reloadData");)
	[super constructSectionControllers];
	
	if(self.tableView == nil)
	{
		return;
	}
	
	// Name
	{
		NameViewSectionController *sectionController = [[[NameViewSectionController alloc] init] autorelease];
		sectionController.delegate = self;
		[self.sectionControllers addObject:sectionController];
		
		NameCellController *cellController = [[[NameCellController alloc] init] autorelease];
		cellController.delegate = self;
		cellController.name = _name;
		if(_setFirstResponderGroup == 0)
		{
			cellController.obtainFocus = YES;
			_setFirstResponderGroup = -1;
		}
	
		[sectionController.cellControllers addObject:cellController];
	}
	
	// Address
	{
		AddressViewSectionController *sectionController = [[[AddressViewSectionController alloc] init] autorelease];
		sectionController.delegate = self;
		[self.sectionControllers addObject:sectionController];
		
		AddressCellController *cellController = [[[AddressCellController alloc] init] autorelease];
		cellController.delegate = self;
		[sectionController.cellControllers addObject:cellController];
		
		LocationCellController *locationCellController = [[[LocationCellController alloc] init] autorelease];
		locationCellController.delegate = self;
		[sectionController.cellControllers addObject:locationCellController];
	}
	
	// Add Metadata
	{
		MetadataViewSectionController *sectionController = [[[MetadataViewSectionController alloc] init] autorelease];
		sectionController.delegate = self;
		[self.sectionControllers addObject:sectionController];
			
		NSArray *additionalInformations = [_call.managedObjectContext fetchObjectsForEntityName:[MTAdditionalInformation entityName]
																			  propertiesToFetch:nil 
																			withSortDescriptors:[NSArray arrayWithObjects:[NSSortDescriptor psSortDescriptorWithKey:@"type.name" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)],
																								 [NSSortDescriptor psSortDescriptorWithKey:@"value" ascending:YES selector:@selector(localizedCaseInsensitiveCompare:)], nil]
																				  withPredicate:@"call == %@", _call];
		for(MTAdditionalInformation *entry in additionalInformations)
		{
			CallMetadataCellController *cellController = [[[CallMetadataCellController alloc] init] autorelease];
			cellController.metadata = entry;
			cellController.delegate = self;
			[sectionController.cellControllers addObject:cellController];
		}
		CallMetadataCellController *cellController = [[[CallMetadataCellController alloc] init] autorelease];
		cellController.add = YES;
		cellController.delegate = self;
		[sectionController.cellControllers addObject:cellController];
	}

	// Add new Return Visit
	{
		ShowAddReturnVisitViewSectionController *sectionController = [[[ShowAddReturnVisitViewSectionController alloc] init] autorelease];
		sectionController.delegate = self;
		[self.sectionControllers addObject:sectionController];

		AddReturnVisitCellController *cellController = [[[AddReturnVisitCellController alloc] init] autorelease];
		cellController.delegate = self;
		[sectionController.cellControllers addObject:cellController];
	}
	
	// RETURN VISITS
	{
		for(MTReturnVisit *visit in [_call.managedObjectContext fetchObjectsForEntityName:[MTReturnVisit entityName]
																		propertiesToFetch:nil
																	  withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"date" ascending:NO]]
																			withPredicate:@"(call == %@)", _call])
		{
			[self.sectionControllers addObject:[self genericTableViewSectionControllerForReturnVisit:visit]];
		}
	}

	// DELETE call
	if(!_newCall)
	{
		{
			GenericTableViewSectionController *sectionController = [[[GenericTableViewSectionController alloc] init] autorelease];
			sectionController.isViewableWhenNotEditing = NO;
			[self.sectionControllers addObject:sectionController];
			
			if(_call.deletedCallValue)
			{
				RestoreCallCellController *cellController = [[[RestoreCallCellController alloc] init] autorelease];
				cellController.delegate = self;
				[sectionController.cellControllers addObject:cellController];
			}
		}
		
		{
			GenericTableViewSectionController *sectionController = [[[GenericTableViewSectionController alloc] init] autorelease];
			sectionController.isViewableWhenNotEditing = NO;
			[self.sectionControllers addObject:sectionController];
			
			DeleteCallCellController *cellController = [[[DeleteCallCellController alloc] init] autorelease];
			cellController.delegate = self;
			cellController.deleteForever = _call.deletedCallValue;
			[sectionController.cellControllers addObject:cellController];
		}		
	}

	DEBUG(NSLog(@"CallView reloadData %s:%d", __FILE__, __LINE__);)
}

- (GenericTableViewSectionController *)genericTableViewSectionControllerForReturnVisit:(MTReturnVisit *)returnVisit
{
	// GROUP TITLE
	NSDate *date = returnVisit.date;	
	// create dictionary entry for This Return Visit
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] init] autorelease];
	[dateFormatter setFormatterBehavior:NSDateFormatterBehavior10_4];
	[dateFormatter setDateStyle:NSDateFormatterShortStyle];
	[dateFormatter setTimeStyle:NSDateFormatterShortStyle];
	NSString *end = [dateFormatter stringFromDate:date];
	[dateFormatter setDateFormat:@"EEE"];
	NSString *formattedDateString = [NSString stringWithFormat:@"%@ %@", [dateFormatter stringFromDate:date], end];			
	
	GenericTableViewSectionController *sectionController = [[[GenericTableViewSectionController alloc] init] autorelease];
	sectionController.title = formattedDateString;
	
	// NOTES
	{
		ReturnVisitNotesCellController *cellController = [[[ReturnVisitNotesCellController alloc] init] autorelease];
		cellController.delegate = self;
		cellController.returnVisit = returnVisit;
		[sectionController.cellControllers addObject:cellController];
	}
	
	// CHANGE DATE
	{
		ReturnVisitDateCellController *cellController = [[[ReturnVisitDateCellController alloc] init] autorelease];
		cellController.delegate = self;
		cellController.returnVisit = returnVisit;
		[sectionController.cellControllers addObject:cellController];
	}
	
	// RETURN VISIT TYPE
	{
		ReturnVisitTypeCellController *cellController = [[[ReturnVisitTypeCellController alloc] init] autorelease];
		cellController.delegate = self;
		cellController.returnVisit = returnVisit;
		[sectionController.cellControllers addObject:cellController];
	}
	
	// Publications
	{
		// they had an array of publications, lets check them too
		for(MTPublication *publication in [returnVisit.managedObjectContext fetchObjectsForEntityName:[MTPublication entityName]
																					propertiesToFetch:[NSArray arrayWithObject:@"order"]
																				  withSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor psSortDescriptorWithKey:@"order" ascending:YES]]
																						withPredicate:@"returnVisit == %@", returnVisit])
		{
			// PUBLICATION
			ReturnVisitPublicationCellController *cellController = [[[ReturnVisitPublicationCellController alloc] init] autorelease];
			cellController.delegate = self;
			cellController.returnVisit = returnVisit;
			cellController.publication = publication;
			[sectionController.cellControllers addObject:cellController];
		}
	}
	
	// add publication
	{
		ReturnVisitPublicationCellController *cellController = [[[ReturnVisitPublicationCellController alloc] init] autorelease];
		cellController.delegate = self;
		cellController.returnVisit = returnVisit;
		[sectionController.cellControllers addObject:cellController];
	}
	
	return sectionController;
}
/******************************************************************
 *
 *   ACTION SHEET DELEGATE FUNCTIONS
 *
 ******************************************************************/
#pragma mark ActionSheet Delegate
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
	[self.navigationController dismissModalViewControllerAnimated:YES];
	if(deleteCall && result != MFMailComposeResultCancelled)
	{
		_call.deletedCallValue = YES;
		[self.navigationController popViewControllerAnimated:YES];
	}
}


- (BOOL)emailCallToUser
{
	MFMailComposeViewController *mailView = [[[MFMailComposeViewController alloc] init] autorelease];
	[mailView setSubject:NSLocalizedString(@"MyTime Call, open this on your iPhone/iTouch", @"Subject text for the email that is sent for sending the details of a call to another witness")];
	
	NSMutableString *string = [[NSMutableString alloc] initWithString:@"<html><body>"];
	[string appendString:NSLocalizedString(@"This return visit has been turned over to you, here are the details.  If you are a MyTime user, please view this email on your iPhone/iTouch and scroll all the way down to the end of the email and click on the link to import this call into MyTime.<br><br>Return Visit Details:<br>", @"This is the first part of the body of the email message that is sent to a user when you click on a Call then click on Edit and then click on the action button in the upper left corner and select transfer or email details")];
	[string appendString:emailFormattedStringForCoreDataCall(_call)];
	[string appendString:NSLocalizedString(@"You are able to import this call into MyTime if you click on the link below while viewing this email from your iPhone/iTouch.  Please make sure that at the end of this email there is a \"VERIFICATION CHECK:\" right after the link, it verifies that all data is contained within this email<br>", @"This is the second part of the body of the email message that is sent to a user when you click on a Call then click on Edit and then click on the action button in the upper left corner and select transfer or email details")];

	// now add the url that will allow importing

	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:[_call.managedObjectContext dictionaryFromManagedObject:_call 
																								 skipRelationshipNames:[NSArray arrayWithObjects:@"self.user", @"self.additionalInformation.type.user", @"self.additionalInformation.type.additionalInformation", nil]]];
	[string appendString:@"<a href=\"mytime://mytime/addCoreDataCall?"];
	int length = data.length;
	unsigned char *bytes = (unsigned char *)data.bytes;
	for(int i = 0; i < length; ++i)
	{
		[string appendFormat:@"%02X", *bytes++];
	}
	[string appendString:@"\">"];
	[string appendString:NSLocalizedString(@"Click on this link from your iPhone/iTouch", @"This is the text that appears in the link of the email when you are transferring a call to another witness.  this is the link that they press to open MyTime")];
	[string appendString:@"</a><br><br>"];
	[string appendString:NSLocalizedString(@"VERIFICATION CHECK: all data was contained in this email", @"This is a very important message that is at the end of the email used to transfer a call to another witness or if you are just emailing a backup to yourself, it verifies that all of the data is contained in the email, if it is not there then all of the data is not in the email and something bad happened :(")];

	[string appendString:@"</body></html>"];
	[mailView setMessageBody:string isHTML:YES];
	[string release];
	mailView.mailComposeDelegate = self;
	[self.navigationController presentModalViewController:mailView animated:YES];
	
	return [MFMailComposeViewController canSendMail];
}


- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)button
{
	VERBOSE(NSLog(@"alertSheet: button:%d", button);)
//	[sheet dismissAnimated:YES];
	deleteCall = NO;
	switch(button)
	{
		//transfer
		case 0:
		{
			deleteCall = YES;
			[self emailCallToUser];
			break;
		}
		// email
		case 1:
		{
			[self emailCallToUser];
			break;
		}
	}
}

@end


