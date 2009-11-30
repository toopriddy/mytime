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
#import "Settings.h"
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
#import "PSUrlString.h"
#import "PSLocalization.h"
#import "UITableViewButtonCell.h"
#import "UITableViewSwitchCell.h"
#import "QuickNotesViewController.h"
#import "MultipleChoiceMetadataViewController.h"

#define PLACEMENT_OBJECT_COUNT 2

#define USE_TEXT_VIEW 0

@interface CallViewController ()
@property (nonatomic, assign) BOOL showAddReturnVisit;
- (void)addReturnVisitAndEdit;
@end


int sortReturnVisitsByDate(id v1, id v2, void *context)
{
	// for speed sake we are going to assume that the first entry in the array
	// is the most recent entry	
	// ok, we need to compare the dates of the calls since we have
	// at least one call for each of 
	NSDate *date1 = [v1 objectForKey:CallReturnVisitDate];
	NSDate *date2 = [v2 objectForKey:CallReturnVisitDate];
	return [date2 compare:date1];
}

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
	NSMutableDictionary *returnVisit;
}
@property (nonatomic, retain) NSMutableDictionary *returnVisit;
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
	return [[self.delegate.call objectForKey:CallName] length];
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
	return [[self.delegate.call objectForKey:CallName] length];
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
	NSMutableDictionary *call = self.delegate.call;
	NSString *streetNumber = [call objectForKey:CallStreetNumber];
	NSString *apartmentNumber = [call objectForKey:CallApartmentNumber];
	NSString *street = [call objectForKey:CallStreet];
	NSString *city = [call objectForKey:CallCity];
	NSString *state = [call objectForKey:CallState];
	NSString *latLong = [call objectForKey:CallLattitudeLongitude];
	
	if((streetNumber && [streetNumber length]) ||
	   (apartmentNumber && [apartmentNumber length]) || 
	   (street && [street length]) || 
	   (city && [city length]) || 
	   (state && [state length]) ||
	   (latLong && ![latLong isEqualToString:@"nil"]))
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
	NSMutableDictionary *call = self.delegate.call;
	NSString *streetNumber = [call objectForKey:CallStreetNumber];
	NSString *apartmentNumber = [call objectForKey:CallApartmentNumber];
	NSString *street = [call objectForKey:CallStreet];
	NSString *city = [call objectForKey:CallCity];
	NSString *state = [call objectForKey:CallState];
	NSString *latLong = [call objectForKey:CallLattitudeLongitude];
	
	if((streetNumber && [streetNumber length]) ||
	   (apartmentNumber && [apartmentNumber length]) || 
	   (street && [street length]) || 
	   (city && [city length]) || 
	   (state && [state length]) ||
	   (latLong && ![latLong isEqualToString:@"nil"]))
	{
		return YES;
	}
	
	return NO;
}

- (void)addressViewControllerDone:(AddressViewController *)addressViewController
{
	[[self retain] autorelease];
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	NSMutableDictionary *call = self.delegate.call;
	[call setObject:(addressViewController.streetNumber ? addressViewController.streetNumber : @"") forKey:CallStreetNumber];
	[call setObject:(addressViewController.apartmentNumber ? addressViewController.apartmentNumber : @"") forKey:CallApartmentNumber];
	[call setObject:(addressViewController.street ? addressViewController.street : @"") forKey:CallStreet];
	[call setObject:(addressViewController.city ? addressViewController.city : @"") forKey:CallCity];
	[call setObject:(addressViewController.state ? addressViewController.state : @"") forKey:CallState];
	// remove the gps location so that they will look it up again
	[self.delegate.call removeObjectForKey:CallLattitudeLongitude];

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
	if(![[self.delegate.call objectForKey:CallLocationType] isEqualToString:CallLocationTypeManual])
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
	NSMutableDictionary *call = self.delegate.call;
	[cell setStreetNumber:[call objectForKey:CallStreetNumber] 
				apartment:[call objectForKey:CallApartmentNumber] 
	               street:[call objectForKey:CallStreet] 
				     city:[call objectForKey:CallCity] 
					state:[call objectForKey:CallState]];
	
	return cell;
}

// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	if(tableView.editing)
	{
		NSString *streetNumber = [self.delegate.call objectForKey:CallStreetNumber];
		NSString *apartmentNumber = [self.delegate.call objectForKey:CallApartmentNumber];
		NSString *street = [self.delegate.call objectForKey:CallStreet];
		NSString *city = [self.delegate.call objectForKey:CallCity];
		NSString *state = [self.delegate.call objectForKey:CallState];
		
		// if they have not initialized the address then assume that it is
		// the same as the last one
		if((streetNumber == nil || [streetNumber isEqualToString:@""]) &&
		   (apartmentNumber == nil || [apartmentNumber isEqualToString:@""]) &&
		   (street == nil || [street isEqualToString:@""]) &&
		   (city == nil || [city isEqualToString:@""]) &&
		   (state == nil || [state isEqualToString:@""]))
		{
			NSMutableDictionary *settings = [[Settings sharedInstance] settings];
			// if they are in an apartment territory then just null out the apartment number
			streetNumber = [settings objectForKey:SettingsLastCallStreetNumber];
			apartmentNumber = [settings objectForKey:SettingsLastCallApartmentNumber];
			if(apartmentNumber.length)
				apartmentNumber = @"";
			else
				streetNumber = @"";
			street = [settings objectForKey:SettingsLastCallStreet];
			city = [settings objectForKey:SettingsLastCallCity];
			state = [settings objectForKey:SettingsLastCallState];
		}
		// open up the edit address view 
		AddressViewController *viewController = [[[AddressViewController alloc] initWithStreetNumber:streetNumber
																			               apartment:apartmentNumber
																							  street:street
																							    city:city
																							   state:state] autorelease];
		viewController.delegate = self;
		[self.delegate.navigationController pushViewController:viewController animated:YES];
		return;
	}
	else
	{
		NSString *streetNumber = [self.delegate.call objectForKey:CallStreetNumber];
		NSString *apartmentNumber = [self.delegate.call objectForKey:CallApartmentNumber];
		NSString *street = [self.delegate.call objectForKey:CallStreet];
		NSString *city = [self.delegate.call objectForKey:CallCity];
		NSString *state = [self.delegate.call objectForKey:CallState];
		NSString *latLong = [self.delegate.call objectForKey:CallLattitudeLongitude];
		
		// if they have not initialized the address then dont show the map program
		// if they have initalized a latLong then include that
		if(!((street == nil || [street isEqualToString:@""]) &&
			 (city == nil || [city isEqualToString:@""]) &&
			 (state == nil || [state isEqualToString:@""])) ||
		   (latLong != nil && ![latLong isEqualToString:@"nil"]))
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
			if(latLong == nil || [latLong isEqualToString:@"nil"])
				latLong = @"";
			else
				latLong = [NSString stringWithFormat:@"@%@", [[latLong stringByReplacingOccurrencesOfString:@" " withString:@"" ] stringWithEscapedCharacters]];
#if 1		
			// open up a url
			NSURL *url = [NSURL URLWithString:[NSString 
											   stringWithFormat:@"http://maps.google.com/?lh=%@&q=%@+%@+%@+%@,+%@%@", 
											   NSLocalizedString(@"en", @"Google Localized Language Name"),
											   [streetNumber stringWithEscapedCharacters], 
											   [apartmentNumber stringWithEscapedCharacters], 
											   [street stringWithEscapedCharacters], 
											   [city stringWithEscapedCharacters], 
											   [state stringWithEscapedCharacters],
											   latLong]];
			DEBUG(NSLog(@"Trying to open url %@", url);)
			// open up the google map page for this call
			[[UIApplication sharedApplication] openURL:url];
#else				
			WebViewController *p = [[[WebViewController alloc] initWithTitle:@"Map" address:self.delegate.call] autorelease];
			[[self navigationController] pushViewController:p animated:YES];
#endif
		}
		else
		{
			[self.delegate.tableView deselectRowAtIndexPath:[self.delegate.tableView indexPathForSelectedRow] animated:YES];
		}
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
	[[self retain] autorelease];
	[self.delegate.call setObject:locationPickerViewController.type forKey:CallLocationType];
	if([locationPickerViewController.type isEqualToString:CallLocationTypeManual])
	{
		[[Settings sharedInstance] saveData];
		[[self.delegate navigationController] popViewControllerAnimated:NO];
		
		SelectPositionMapViewController *controller = [[[SelectPositionMapViewController alloc] initWithPosition:[self.delegate.call objectForKey:CallLattitudeLongitude]] autorelease];
		controller.delegate = self;
		[[self.delegate navigationController] pushViewController:controller animated:YES];
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
		[[Settings sharedInstance] saveData];

		[[self.delegate navigationController] popViewControllerAnimated:YES];
	}
}

- (void)selectPositionMapViewControllerDone:(SelectPositionMapViewController *)selectPositionMapViewController
{
	[self.delegate.call setObject:[NSString stringWithFormat:@"%f, %f", selectPositionMapViewController.point.latitude, selectPositionMapViewController.point.longitude] forKey:CallLattitudeLongitude];
	[[Settings sharedInstance] saveData];
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

	NSMutableDictionary *call = self.delegate.call;
	NSString *locationType = [call objectForKey:CallLocationType];
	if(locationType == nil)
	{
		locationType = CallLocationTypeGoogleMaps;
	}
	[cell setValue:[[PSLocalization localizationBundle] localizedStringForKey:locationType value:locationType table:@""]];
	
	// if this does not have a latitude/longitude then look it up
	if([locationType isEqualToString:CallLocationTypeGoogleMaps] &&
	   [call objectForKey:CallLattitudeLongitude] != nil)
	{
		cell.accessoryType = UITableViewCellAccessoryCheckmark;
		cell.editingAccessoryType = UITableViewCellAccessoryCheckmark;
	}
	
	// if this does not have a latitude/longitude then look it up
	if([locationType isEqualToString:CallLocationTypeGoogleMaps] &&
	   [call objectForKey:CallLattitudeLongitude] == nil)
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
	NSArray *metadata = [self.delegate.call objectForKey:CallMetadata];
	return metadata && [metadata count];
}
@end


@interface CallMetadataCellController : CallViewCellController <MetadataViewControllerDelegate, 
															    MetadataEditorViewControllerDelegate, 
																UITableViewSwitchCellDelegate,
																MultipleChoiceMetadataViewControllerDelegate>
{
	BOOL add;
	NSMutableDictionary *_metadata;
	UIViewController *_viewController;
}
@property (nonatomic, assign) BOOL add;
@property (nonatomic, retain) NSMutableDictionary *metadata;
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

- (void)metadataViewControllerAddPreferredMetadata:(MetadataViewController *)metadataViewController metadata:(NSDictionary *)metadata
{
	[[self retain] autorelease];
	NSMutableArray *calls = [[[Settings sharedInstance] userSettings] objectForKey:SettingsCalls];
	for(NSMutableDictionary *call in calls)
	{
		NSMutableArray *metadataArray = [call objectForKey:CallMetadata];
		bool found = NO;
		
		// look for this metadata in the call already.
		for(NSMutableDictionary *entry in metadataArray)
		{
			NSString *name = [entry objectForKey:CallMetadataName];
			NSNumber *type = [entry objectForKey:CallMetadataType];
			if([name isEqualToString:[metadata objectForKey:SettingsMetadataName]] && 
			   [type isEqualToNumber:[metadata objectForKey:SettingsMetadataType]])
			{
				found = YES;
			}
		}
		if(metadataArray == nil)
		{
			metadataArray = [NSMutableArray array];
			[call setObject:metadataArray forKey:CallMetadata];
		}
		// if not found then add it
		if(!found)
		{
			NSMutableDictionary *addMetadata = [metadata mutableCopy];
			[metadataArray addObject:addMetadata];
			[addMetadata release];
		}
	}
	NSMutableDictionary *call = self.delegate.call;
	NSMutableArray *metadataArray = [call objectForKey:CallMetadata];
	bool found = NO;
	
	// look for this metadata in the call already.
	for(NSMutableDictionary *entry in metadataArray)
	{
		NSString *name = [entry objectForKey:CallMetadataName];
		NSNumber *type = [entry objectForKey:CallMetadataType];
		if([name isEqualToString:[metadata objectForKey:SettingsMetadataName]] && 
		   [type isEqualToNumber:[metadata objectForKey:SettingsMetadataType]])
		{
			found = YES;
		}
	}
	if(metadataArray == nil)
	{
		metadataArray = [NSMutableArray array];
		[call setObject:metadataArray forKey:CallMetadata];
	}
	// if not found then add it
	if(!found)
	{
		NSMutableDictionary *addedEntry = [metadata mutableCopy];
		[metadataArray addObject:addedEntry];
		[addedEntry release];
	}
	
	
	[self.delegate save];
	self.delegate.forceReload = YES;
}

- (void)metadataViewControllerRemovePreferredMetadata:(MetadataViewController *)metadataViewController metadata:(NSDictionary *)metadata removeAll:(BOOL)removeAll
{
	[[self retain] autorelease];
	NSMutableArray *calls = [[[Settings sharedInstance] userSettings] objectForKey:SettingsCalls];
	for(NSMutableDictionary *call in calls)
	{
		NSMutableArray *metadataArray = [call objectForKey:CallMetadata];
		NSMutableArray *discardedMetadata = [NSMutableArray array];
		for(NSMutableDictionary *entry in metadataArray)
		{
			NSString *name = [entry objectForKey:CallMetadataName];
			NSNumber *type = [entry objectForKey:CallMetadataType];
			if([name isEqualToString:[metadata objectForKey:SettingsMetadataName]] && 
			   [type isEqualToNumber:[metadata objectForKey:SettingsMetadataType]])
			{
				NSString *value = [entry objectForKey:CallMetadataValue];
				if(value == nil || value.length == 0 || removeAll)
				{
					[discardedMetadata addObject:entry];
				}
			}
		}
		[metadataArray removeObjectsInArray:discardedMetadata];
	}
	NSMutableDictionary *call = self.delegate.call;
	NSMutableArray *metadataArray = [call objectForKey:CallMetadata];
	NSMutableArray *discardedMetadata = [NSMutableArray array];
	for(NSMutableDictionary *entry in metadataArray)
	{
		NSString *name = [entry objectForKey:CallMetadataName];
		NSNumber *type = [entry objectForKey:CallMetadataType];
		if([name isEqualToString:[metadata objectForKey:SettingsMetadataName]] && 
		   [type isEqualToNumber:[metadata objectForKey:SettingsMetadataType]])
		{
			NSString *value = [entry objectForKey:CallMetadataValue];
			if(value == nil || value.length == 0 || removeAll)
			{
				[discardedMetadata addObject:entry];
			}
		}
	}
	[metadataArray removeObjectsInArray:discardedMetadata];
	
	[self.delegate save];
	self.delegate.forceReload = YES;
}

- (void)metadataViewControllerAdd:(MetadataViewController *)metadataViewController metadata:(NSDictionary *)metadata
{
	[[self retain] autorelease];
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	NSMutableDictionary *call = self.delegate.call;
	NSMutableArray *metadataArray = [call objectForKey:CallMetadata];
	if(metadataArray == nil)
	{
		metadataArray = [NSMutableArray array];
		[call setObject:metadataArray forKey:CallMetadata];
	}
	
	NSMutableDictionary *newData = [NSMutableDictionary dictionaryWithDictionary:metadata];
	[metadataArray addObject:newData];
	switch([[metadata objectForKey:CallMetadataType] intValue])
	{
		case PHONE:
		case EMAIL:
		case NOTES:
		case URL:
		case STRING:
			[newData setObject:@"" forKey:CallMetadataValue];
			[newData setObject:@"" forKey:CallMetadataData];
			break;
			
		case SWITCH:
			[newData setObject:@"" forKey:CallMetadataValue];
			[newData setObject:[NSNumber numberWithBool:NO] forKey:CallMetadataData];
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
			[newData setObject:formattedDateString forKey:CallMetadataValue];
			[newData setObject:date forKey:CallMetadataData];
			break;
		}
	}
	CallMetadataCellController *cellController = [[[CallMetadataCellController alloc] init] autorelease];
	cellController.metadata = newData;
	cellController.delegate = self.delegate;
	[[[self.delegate.displaySectionControllers objectAtIndex:self.indexPath.section] cellControllers] insertObject:cellController atIndex:self.indexPath.row];
	
	[self.delegate save];

	[self.delegate updateWithoutReload];
}

- (BOOL)isViewableWhenNotEditing
{
	return !self.add;
}

- (void)metadataEditorViewControllerDone:(MetadataEditorViewController *)metadataEditorViewController
{
	[[self retain] autorelease];
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	
	[self.metadata setObject:[metadataEditorViewController data] forKey:CallMetadataData];
	[self.metadata setObject:[metadataEditorViewController value] forKey:CallMetadataValue];
	
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

- (void)multipleChoiceMetadataViewControllerDone:(MultipleChoiceMetadataViewController *)metadataCustomViewController
{
	[[self retain] autorelease];
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	
	[self.metadata setObject:[metadataCustomViewController value] forKey:CallMetadataValue];
	
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
	
	if([[self.metadata objectForKey:CallMetadataType] intValue] == NOTES &&
	   [[self.metadata objectForKey:CallMetadataValue] length])
	{
		return [UITableViewMultilineTextCell heightForWidth:(tableView.bounds.size.width - 90) withText:[self.metadata objectForKey:CallMetadataValue]];
	}
	else
	{
		return tableView.rowHeight;
	}
}

- (void)uiTableViewSwitchCellChanged:(UITableViewSwitchCell *)uiTableViewSwitchCell
{
	NSString *str = uiTableViewSwitchCell.booleanSwitch.on ? NSLocalizedString(@"YES", @"YES for boolean switch in additional information") : NSLocalizedString(@"NO", @"NO for boolean switch in additional information"); 
	[self.metadata setObject:[NSNumber numberWithBool:uiTableViewSwitchCell.booleanSwitch.on] forKey:CallMetadataData];
	[self.metadata setObject:str forKey:CallMetadataValue];
	
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
		NSNumber *type = [self.metadata objectForKey:CallMetadataType];
		NSString *name = [self.metadata objectForKey:CallMetadataName];
		NSString *value = [self.metadata objectForKey:CallMetadataValue];
		
		if([type intValue] == NOTES)
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
		else if([type intValue] == SWITCH)
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
			cell.booleanSwitch.on = [[self.metadata objectForKey:CallMetadataData] boolValue];
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
			
			switch([type intValue])
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

	NSNumber *type = [self.metadata objectForKey:CallMetadataType];
	switch([type intValue])
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
	}
	else
	{
		NSNumber *type = [self.metadata objectForKey:CallMetadataType];
		NSString *name = [self.metadata objectForKey:CallMetadataName];
		NSString *value = [self.metadata objectForKey:CallMetadataValue];
		NSObject *data = [self.metadata objectForKey:CallMetadataData];
		
		if([type intValue] != SWITCH)
		{
			if(tableView.editing)
			{
				if([type intValue] == CHOICE)
				{
					MultipleChoiceMetadataViewController *p = [[[MultipleChoiceMetadataViewController alloc] initWithName:name value:value data:(NSMutableArray *)data] autorelease];
					p.delegate = self;
					
					[[self.delegate navigationController] pushViewController:p animated:YES];		
				}
				else 
				{
					// make the new call view 
					MetadataEditorViewController *p = [[[MetadataEditorViewController alloc] initWithName:name type:[type intValue] data:data value:value] autorelease];
					p.delegate = self;
					p.tag = indexPath.row;
					
					[[self.delegate navigationController] pushViewController:p animated:YES];		
				}
			}
			else
			{
				switch([type intValue])
				{
					case PHONE:
						if(value)
						{
							[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@", value]]];
						}
						break;
					case EMAIL:
						if(value)
						{
							[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"mailto:%@", value]]];
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
		NSMutableArray *array = [self.delegate.call objectForKey:CallMetadata];
		if(array == nil) // this should not happen
			return;
		[array removeObject:self.metadata];

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
	NSMutableDictionary *call = self.delegate.call;
	if([[call objectForKey:CallReturnVisits] count])
	{
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		[cell setValue:NSLocalizedString(@"Add a return visit", @"Add a return visit action button")];
	}
	else
	{
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
		[cell setValue:NSLocalizedString(@"Add a initial visit", @"Add a initial visit action buton")];
	}
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
	
	NSMutableArray *returnVisits = [self.delegate.call objectForKey:CallReturnVisits];
	if(returnVisits == nil)
	{
		returnVisits = [NSMutableArray array];
		[self.delegate.call setObject:returnVisits forKey:CallReturnVisits];
	}
	
	NSMutableDictionary *visit = [NSMutableDictionary dictionary];
	
	[visit setObject:[NSDate date] forKey:CallReturnVisitDate];
	[visit setObject:@"" forKey:CallReturnVisitNotes];
	[visit setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallReturnVisitPublications];
	
	[returnVisits insertObject:visit atIndex:0];
	
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
}
@end
@implementation ReturnVisitNotesCell
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
			[self setText:NSLocalizedString(@"Return Visit Notes", @"Return Visit Notes default text when the user did not enter notes, displayed on the view-mode Call view")];
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
	[[self retain] autorelease];

    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
    [returnVisit setObject:[notesViewController notes] forKey:CallReturnVisitNotes];
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
	NSArray *returnVisits = [self.delegate.call objectForKey:CallReturnVisits];
	return returnVisits.count == 1 ? UITableViewCellEditingStyleNone : UITableViewCellEditingStyleDelete;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return [UITableViewMultilineTextCell heightForWidth:(tableView.bounds.size.width - 90) withText:[self.returnVisit objectForKey:CallReturnVisitNotes]];
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
	
	NSMutableString *notes = [self.returnVisit objectForKey:CallReturnVisitNotes];
	
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
			if([[self.delegate.call objectForKey:CallReturnVisits] lastObject] == returnVisit)
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
	NSString *notes = [self.returnVisit objectForKey:CallReturnVisitNotes];
	if(notes == nil || notes.length == 0)
	{
		// make the new call view 
		QuickNotesViewController *p = [[[QuickNotesViewController alloc] init] autorelease];
		p.delegate = self;
		[[self.delegate navigationController] pushViewController:p animated:YES];		
	}
	else 
	{
		// make the new call view 
		NotesViewController *p = [[[NotesViewController alloc] initWithNotes:[self.returnVisit objectForKey:CallReturnVisitNotes]] autorelease];
		p.delegate = self;
		[[self.delegate navigationController] pushViewController:p animated:YES];		
	}
}

// After a row has the minus or plus button invoked (based on the UITableViewCellEditingStyle for the cell), the dataSource must commit the change
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSMutableArray *returnVisits = [self.delegate.call objectForKey:CallReturnVisits];
	
	if(editingStyle == UITableViewCellEditingStyleDelete && returnVisits.count != 1)
	{
		DEBUG(NSLog(@"deleteReturnVisitAtIndex: %d", index);)
		
		[returnVisits removeObject:returnVisit];

		
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
	
	[[self retain] autorelease];
    [self.returnVisit setObject:[datePickerViewController date] forKey:CallReturnVisitDate];
	
	// just in case they changed the date to reorder them
	NSMutableArray *returnVisits = [self.delegate.call objectForKey:CallReturnVisits];
	returnVisits = [NSMutableArray arrayWithArray:[returnVisits sortedArrayUsingFunction:sortReturnVisitsByDate context:NULL]];
	[self.delegate.call setObject:returnVisits forKey:CallReturnVisits];
    
	[self.delegate save];
	self.delegate.forceReload = YES;
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
	DatePickerViewController *p = [[[DatePickerViewController alloc] initWithDate:[self.returnVisit objectForKey:CallReturnVisitDate]] autorelease];
	p.delegate = self;
	[[self.delegate navigationController] pushViewController:p animated:YES];		
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
	[[self retain] autorelease];
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
    [self.returnVisit setObject:[returnVisitTypeViewController type] forKey:CallReturnVisitType];
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
	NSString *type = [self.returnVisit objectForKey:CallReturnVisitType];
	if(type == nil)
		type = CallReturnVisitTypeReturnVisit;
	return ![type isEqualToString:CallReturnVisitTypeReturnVisit];
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
	NSString *type = [self.returnVisit objectForKey:CallReturnVisitType];
	if(type == nil)
		type = CallReturnVisitTypeReturnVisit;
	
	
	[cell setTitle:NSLocalizedString(@"Type", @"Return visit type label")];
	// if this is the initial visit, then just say that it is the initial visit
	if([type isEqualToString:CallReturnVisitTypeReturnVisit] && 
	   [[self.delegate.call objectForKey:CallReturnVisits] lastObject] == self.returnVisit)
	{
		[cell setValue:NSLocalizedString(@"Initial Visit", @"This is used to signify the first visit which is not counted as a return visit.  This is in the view where you get to pick the visit type")];
	}
	else
	{
		[cell setValue:[[PSLocalization localizationBundle] localizedStringForKey:type value:type table:@""]];
	}
	
	return cell;
}


// Called after the user changes the selection.
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	DEBUG(NSLog(@"isStudyOnForReturnVisitAtIndex: %d", index);)
	
	// they clicked on the Change Type
	NSString *type = [self.returnVisit objectForKey:CallReturnVisitType];
	if(type == nil)
		type = CallReturnVisitTypeReturnVisit;
	
	NSMutableArray *returnVisits = [self.delegate.call objectForKey:CallReturnVisits];
	// make the new call view 
	ReturnVisitTypeViewController *p = [[[ReturnVisitTypeViewController alloc] initWithType:type isInitialVisit:([returnVisits lastObject] == self.returnVisit)] autorelease];	
	p.delegate = self;	
	[[self.delegate navigationController] pushViewController:p animated:YES];		
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
	NSMutableDictionary *publication;
}
@property (nonatomic, retain) NSMutableDictionary *publication;
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
		NSMutableArray *array = [self.returnVisit objectForKey:CallReturnVisitPublications];
		[array removeObject:self.publication];
		
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
	[[self retain] autorelease];
    VERBOSE(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	NSMutableDictionary *editedPublication = self.publication;
	bool newPublication = (editedPublication == nil);
    if(newPublication)
    {
        VERBOSE(NSLog(@"creating a new publication entry and adding it");)
        // if we are adding a publication then create the NSDictionary and add it to the end
        // of the publications array
        editedPublication = [[[NSMutableDictionary alloc] init] autorelease];
        [[returnVisit objectForKey:CallReturnVisitPublications] addObject:editedPublication];
    }
    VERBOSE(NSLog(@"_editingPublication was = %@", editedPublication);)
	PublicationPickerView *picker = [publicationViewController publicationPicker];
    [editedPublication setObject:[picker publication] forKey:CallReturnVisitPublicationName];
    [editedPublication setObject:[picker publicationTitle] forKey:CallReturnVisitPublicationTitle];
    [editedPublication setObject:[picker publicationType] forKey:CallReturnVisitPublicationType];
    [editedPublication setObject:[[[NSNumber alloc] initWithInt:[picker year]] autorelease] forKey:CallReturnVisitPublicationYear];
    [editedPublication setObject:[[[NSNumber alloc] initWithInt:[picker month]] autorelease] forKey:CallReturnVisitPublicationMonth];
    [editedPublication setObject:[[[NSNumber alloc] initWithInt:[picker day]] autorelease] forKey:CallReturnVisitPublicationDay];
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
		[cell setTitle:[self.publication objectForKey:CallReturnVisitPublicationTitle]];
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
		DEBUG(NSLog(@"changeReturnVisit %@ %@", indexPath, self.publication);)
		
		// make the new call view 
		PublicationViewController *p = [[[PublicationViewController alloc] initWithPublication: [ self.publication objectForKey:CallReturnVisitPublicationName]
																						  year: [[self.publication objectForKey:CallReturnVisitPublicationYear] intValue]
																						 month: [[self.publication objectForKey:CallReturnVisitPublicationMonth] intValue]
																						   day: [[self.publication objectForKey:CallReturnVisitPublicationDay] intValue]] autorelease];
		
		p.delegate = self;
		[[self.delegate navigationController] pushViewController:p animated:YES];
	}
	else
	{
		DEBUG(NSLog(@"addPublicationToReturnVisitAtIndex: %@", indexPath);)
		
		// make the new call view 
		PublicationTypeViewController *p = [[[PublicationTypeViewController alloc] init] autorelease];
		p.delegate = self;
		
		[[self.delegate navigationController] pushViewController:p animated:YES];		
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
}
@end
@implementation DeleteCallCellController

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
	UIActionSheet *alertSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Are you sure you want to delete the call (the return visits and placed literature will still be counted)?", @"Statement to make the user realize that this will still save information, and acknowledge they are deleting a call")
															 delegate:self
												    cancelButtonTitle:NSLocalizedString(@"No", @"No dont delete the call")
											   destructiveButtonTitle:NSLocalizedString(@"Yes", @"Yes delete the call")
												    otherButtonTitles:NSLocalizedString(@"Delete and don't keep info", @"Yes delete the call and the data"), nil] autorelease];
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
		if(delegate)
		{
			[self.delegate.delegate callViewController:self.delegate deleteCall:self.delegate.call keepInformation:YES];
			[self.delegate.navigationController popViewControllerAnimated:YES];
		}
	}
	if(button == 1)
	{
		if(delegate)
		{
			[self.delegate.delegate callViewController:self.delegate deleteCall:self.delegate.call keepInformation:NO];
			[self.delegate.navigationController popViewControllerAnimated:YES];
		}
	}
}


@end







@implementation CallViewController
@synthesize showAddReturnVisit = _showAddReturnVisit;
@synthesize delegate;
@synthesize currentIndexPath;
@synthesize delayedAddReturnVisit;

/******************************************************************
 *
 *   INIT
 *
 ******************************************************************/
- (id) init
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
    return([self initWithCall:nil]);
}

- (id) initWithCall:(NSMutableDictionary *)call
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
    if([super initWithStyle:UITableViewStyleGrouped]) 
    {
		_initialView = YES;
		
		self.hidesBottomBarWhenPushed = YES;
		
        NSString *temp;
        DEBUG(NSLog(@"CallView 2initWithFrame:call:%@", call);)

		_setFirstResponderGroup = -1;
		

		_newCall = (call == nil);
		_showDeleteButton = !_newCall;
		if(_newCall)
		{
			_call = [[NSMutableDictionary alloc] init];
			_setFirstResponderGroup = 0;
			_showAddReturnVisit = NO;

			NSMutableArray *returnVisits = [[[NSMutableArray alloc] initWithArray:[_call objectForKey:CallReturnVisits]] autorelease];
			[_call setObject:returnVisits forKey:CallReturnVisits];
			// make the preferred metadata show up
			NSMutableArray *metadata = [[NSMutableArray arrayWithArray:[[[Settings sharedInstance] userSettings] objectForKey:SettingsPreferredMetadata]] mutableCopy];
			[_call setObject:metadata forKey:CallMetadata];
			[metadata release];
			
			NSMutableDictionary *visit = [[[NSMutableDictionary alloc] init] autorelease];

			[visit setObject:[NSDate date] forKey:CallReturnVisitDate];
			[visit setObject:@"" forKey:CallReturnVisitNotes];
			[visit setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallReturnVisitPublications];
			
			[returnVisits insertObject:visit atIndex:0];
		}
		else
		{
			_showAddReturnVisit = YES;

			_call = [call mutableCopy];
		}

		_name = [[UITextField alloc] initWithFrame:CGRectZero];
		_name.autocapitalizationType = UITextAutocapitalizationTypeWords;
		_name.returnKeyType = UIReturnKeyDone;
        // _name (make sure that it is initalized)
        //[_name setText:NSLocalizedString(@"Name", @"Name label for Call in editing mode")];
		_name.placeholder = NSLocalizedString(@"Name", @"Name label for Call in editing mode");
        if((temp = [_call objectForKey:CallName]) != nil)
		{
            _name.text = temp;
		}
        else
		{
            [_call setObject:@"" forKey:CallName];
		}

        // address (make sure that everything is initialized)
        if([_call objectForKey:CallStreet] == nil)
            [_call setObject:@"" forKey:CallStreet];
        if([_call objectForKey:CallCity] == nil)
            [_call setObject:@"" forKey:CallCity];
        if([_call objectForKey:CallState] == nil)
            [_call setObject:@"" forKey:CallState];

		// metadata
        if([_call objectForKey:CallMetadata] == nil)
        {
            [_call setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallMetadata];
        }
		
		// return visits
        if([_call objectForKey:CallReturnVisits] == nil)
        {
            [_call setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallReturnVisits];
        }
        else
        {
           // lets check all of the ReturnVisits to make sure that everything was 
            // initialized correctly
            NSMutableArray *returnVisits = [_call objectForKey:CallReturnVisits];
            NSMutableDictionary *visit;
			returnVisits = [NSMutableArray arrayWithArray:[returnVisits sortedArrayUsingFunction:sortReturnVisitsByDate context:NULL]];
			[_call setObject:returnVisits forKey:CallReturnVisits];
			
            int i;
            int end = [returnVisits count];
            for(i = 0; i < end; ++i)
            {
                visit = [returnVisits objectAtIndex:i];
                if([visit objectForKey:CallReturnVisitDate] == nil)
                    [visit setObject:[NSDate date] forKey:CallReturnVisitDate];
                
                if([visit objectForKey:CallReturnVisitNotes] == nil)
                    [visit setObject:@"" forKey:CallReturnVisitNotes];

                if([visit objectForKey:CallReturnVisitType] == nil)
                    [visit setObject:CallReturnVisitTypeReturnVisit forKey:CallReturnVisitType];
                
                if([visit objectForKey:CallReturnVisitPublications] == nil)
                    [visit setObject:[[[NSMutableArray alloc] init] autorelease] forKey:CallReturnVisitPublications];
                else
                {
                    // they had an array of publications, lets check them too
                    NSMutableArray *publications = [visit objectForKey:CallReturnVisitPublications];
                    NSMutableDictionary *publication;
                    int j;
                    int endPublications = [publications count];
                    for(j = 0; j < endPublications; ++j)
                    {
                        publication = [publications objectAtIndex:j];
                        if([publication objectForKey:CallReturnVisitPublicationTitle] == nil)
                            [publication setObject:@"" forKey:CallReturnVisitPublicationTitle];
                        if([publication objectForKey:CallReturnVisitPublicationName] == nil)
                            [publication setObject:@"" forKey:CallReturnVisitPublicationName];
						// the older version that no one should really have had things saved without a type
						// go ahead and initalize this as a magazine
                        if([publication objectForKey:CallReturnVisitPublicationType] == nil)
                            [publication setObject:PublicationTypeMagazine forKey:CallReturnVisitPublicationType];
                        if([publication objectForKey:CallReturnVisitPublicationYear] == nil)
                            [publication setObject:[[[NSNumber alloc] initWithInt:0] autorelease] forKey:CallReturnVisitPublicationYear];
                        if([publication objectForKey:CallReturnVisitPublicationMonth] == nil)
                            [publication setObject:[[[NSNumber alloc] initWithInt:0] autorelease] forKey:CallReturnVisitPublicationMonth];
                        if([publication objectForKey:CallReturnVisitPublicationDay] == nil)
                            [publication setObject:[[[NSNumber alloc] initWithInt:0] autorelease] forKey:CallReturnVisitPublicationDay];
                    }
                }
                
            }
        }
		

		// 0 = greay
		// 1 = red
		// 2 = left arrow
		// 3 = blue
		if(_newCall)
		{
			self.title = NSLocalizedString(@"New Call", @"Call main title when you are adding a new call");
			// update the button in the nav bar
			UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
																					 target:self
																					 action:@selector(navigationControlCancel:)] autorelease];
			[self.navigationItem setLeftBarButtonItem:button animated:YES];
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

    [_name release];
    [_call release];

	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	return(YES);
}

- (void)save
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)

	[_call setObject:[self name] forKey:CallName];
	
	if(!_newCall)
	{
		if(delegate)
		{
			[delegate callViewController:self saveCall:_call];
		}
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
	[self save];
	
	
	// we need to reload data now, so we need to hide:
	//   the name field if it does not have a value
	//   the insert new call
	//   the per call insert a new publication
	
	_showAddReturnVisit = YES;
	_showDeleteButton = YES;
	
	if(isNewCall)
	{
		[self.navigationController popViewControllerAnimated:YES];
	}
	else
	{
		self.editing = NO;
	}		
}	

- (void)navigationControlCancel:(id)sender 
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	[_call release];
	_call = nil;
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

	NSMutableDictionary *settings = [[Settings sharedInstance] settings];
	if(!_newCall && [settings objectForKey:SettingsExistingCallAlertSheetShown] == nil)
	{
		[settings setObject:@"" forKey:SettingsExistingCallAlertSheetShown];
		[[Settings sharedInstance] saveData];
		
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
			
		NSMutableArray *metadata = [_call objectForKey:CallMetadata];
		for(NSMutableDictionary *entry in metadata)
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
		NSMutableArray *returnVisits = [_call objectForKey:CallReturnVisits];
		for(NSMutableDictionary *visit in returnVisits)
		{
			[self.sectionControllers addObject:[self genericTableViewSectionControllerForReturnVisit:visit]];
		}
	}

	// DELETE call
	if(!_newCall)
	{
		GenericTableViewSectionController *sectionController = [[[GenericTableViewSectionController alloc] init] autorelease];
		sectionController.isViewableWhenNotEditing = NO;
		[self.sectionControllers addObject:sectionController];
		
		DeleteCallCellController *cellController = [[[DeleteCallCellController alloc] init] autorelease];
		cellController.delegate = self;
		[sectionController.cellControllers addObject:cellController];
	}

	DEBUG(NSLog(@"CallView reloadData %s:%d", __FILE__, __LINE__);)
}

- (GenericTableViewSectionController *)genericTableViewSectionControllerForReturnVisit:(NSMutableDictionary *)returnVisit
{
	// GROUP TITLE
	NSDate *date = [returnVisit objectForKey:CallReturnVisitDate];	
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
		NSMutableArray *publications = [returnVisit objectForKey:CallReturnVisitPublications];
		for(NSMutableDictionary *publication in publications)
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
		[delegate callViewController:self deleteCall:_call keepInformation:YES];
		[self.navigationController popViewControllerAnimated:YES];
	}
}


- (BOOL)emailCallToUser
{
	MFMailComposeViewController *mailView = [[[MFMailComposeViewController alloc] init] autorelease];
	[mailView setSubject:NSLocalizedString(@"MyTime Call, open this on your iPhone/iTouch", @"Subject text for the email that is sent for sending the details of a call to another witness")];
	
	NSMutableString *string = [[NSMutableString alloc] init];
	[string appendString:NSLocalizedString(@"This return visit has been turned over to you, here are the details.  If you are a MyTime user, please view this email on your iPhone/iTouch and scroll all the way down to the end of the email and click on the link to import this call into MyTime.<br><br>Return Visit Details:<br>", @"This is the first part of the body of the email message that is sent to a user when you click on a Call then click on Edit and then click on the action button in the upper left corner and select transfer or email details")];
	[string appendString:emailFormattedStringForCall(_call)];
	[string appendString:NSLocalizedString(@"You are able to import this call into MyTime if you click on the link below while viewing this email from your iPhone/iTouch.  Please make sure that at the end of this email there is a \"VERIFICATION CHECK:\" right after the link, it verifies that all data is contained within this email<br>", @"This is the second part of the body of the email message that is sent to a user when you click on a Call then click on Edit and then click on the action button in the upper left corner and select transfer or email details")];

	// now add the url that will allow importing

	NSData *data = [NSKeyedArchiver archivedDataWithRootObject:_call];
	[string appendString:@"<a href=\"mytime://mytime/addCall?"];
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

/******************************************************************
 *
 *   ACCESSOR METHODS
 *
 ******************************************************************/
#pragma mark Accessors

- (NSString *)name
{
    if(_name.text == nil)
        return @"";
    else
        return _name.text;
}

- (NSString *)street
{
    return([_call objectForKey:CallStreet]);
}

- (NSString *)city
{
    return([_call objectForKey:CallCity]);
}

- (NSString *)state
{
    return([_call objectForKey:CallState]);
}

- (NSMutableDictionary *)call
{
    [_call setObject:[self name] forKey:CallName];
    return(_call);
}


- (BOOL)respondsToSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"%s respondsToSelector: %s", __FILE__, selector);)
    return [super respondsToSelector:selector];
}

- (NSMethodSignature*)methodSignatureForSelector:(SEL)selector
{
    VERY_VERBOSE(NSLog(@"%s methodSignatureForSelector: %s", __FILE__, selector);)
    return [super methodSignatureForSelector:selector];
}

- (void)forwardInvocation:(NSInvocation*)invocation
{
    VERY_VERBOSE(NSLog(@"%s forwardInvocation: %s", __FILE__, [invocation selector]);)
    [super forwardInvocation:invocation];
}



@end


