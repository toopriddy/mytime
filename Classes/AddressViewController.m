//
//  AddressViewController.m
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

#import "AddressViewController.h"
#import "UITableViewTextFieldCell.h"
#import "MTSettings.h"
#import "MTCall.h"
#import "UITableViewTitleAndValueCell.h"
#import "CLLocationManager+PriddySoftware.h"
#import "PSLabelCellController.h"
#import "PSMultiTextFieldCellController.h"
#import "PSTextFieldCellController.h"
#import "PSLocalization.h"

#define REVERSE_GEOCODING_ACCURACY 80

@interface AddressViewController()
@property (nonatomic, retain, readwrite) NSString *apartmentNumber;
@property (nonatomic, retain, readwrite) NSString *streetNumber;
@property (nonatomic, retain, readwrite) NSString *street;
@property (nonatomic, retain, readwrite) NSString *city;
@property (nonatomic, retain, readwrite) NSString *state;
@property (nonatomic, assign) BOOL showReverseGeocoding;
@property (nonatomic, assign) BOOL obtainFocus;
@property (nonatomic, retain) NSMutableSet *allTextFields;
@end


@interface SaveAndDone : UIResponder <UITextFieldDelegate>
{
	AddressViewController *viewController;
}
@property (nonatomic,retain) AddressViewController *viewController;

- (id)initWithAddressViewController:(AddressViewController *)theViewController;
@end

@implementation SaveAndDone

@synthesize viewController;

- (void)dealloc
{
	self.viewController = nil;
	[super dealloc];
}

- (id)initWithAddressViewController:(AddressViewController *)theViewController;
{
	[super init];
	self.viewController = theViewController;
	return(self);
}

- (BOOL)becomeFirstResponder 
{
	[viewController navigationControlDone:nil];
	return NO;
}
@end



/******************************************************************
 *
 *   Geocoder section
 *
 ******************************************************************/
#pragma mark NameCellController

@interface AddressGeocacheSectionController : GenericTableViewSectionController
{
	AddressViewController *delegate;
}
@property (nonatomic, assign) AddressViewController *delegate;
@end
@implementation AddressGeocacheSectionController
@synthesize delegate;

- (BOOL)isViewableWhenNotEditing
{
	return self.delegate.showReverseGeocoding;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 5;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	UIView *view = [[[UIView alloc] init] autorelease];
	view.backgroundColor = [UIColor clearColor];
	
	return view;
}
@end

@interface AddressSectionController : GenericTableViewSectionController
{
}
@end
@implementation AddressSectionController
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 200;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	UIView *view = [[[UIView alloc] init] autorelease];
	view.backgroundColor = [UIColor clearColor];
	
	return view;
}
@end



@implementation AddressViewController

@synthesize delegate;
@synthesize apartmentNumber;
@synthesize streetNumber;
@synthesize street;
@synthesize city;
@synthesize state;
@synthesize locationMessage;
@synthesize locationManager;
@synthesize geocoder;
@synthesize placemark;
@synthesize locationStartDate;
@synthesize showReverseGeocoding;
@synthesize obtainFocus;
@synthesize allTextFields;

- (id)init
{
    return([self initWithStreetNumber:@"" apartment:@"" street:@"" city:@"" state:@"" askAboutReverseGeocoding:YES]);
}

- (id) initWithStreetNumber:(NSString *)theStreetNumber apartment:(NSString *)apartment street:(NSString *)theStreet city:(NSString *)theCity state:(NSString *)theState askAboutReverseGeocoding:(BOOL)askAboutReverseGeocoding;
{
	if( (self = [super initWithStyle:UITableViewStyleGrouped]) ) 
	{
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = NSLocalizedString(@"Call Address", @"Address title for address form");
		self.allTextFields = [NSMutableSet set];
		self.obtainFocus = YES;
		self.streetNumber = theStreetNumber;
		self.apartmentNumber = apartment;
		self.street = theStreet;
		self.city = theCity;
		self.state = theState;
		shouldAskAboutReverseGeocoding = askAboutReverseGeocoding;
		showReverseGeocoding = shouldAskAboutReverseGeocoding && [CLLocationManager psLocationServicesEnabled];
	}
	return self;
}

- (void)dealloc 
{
	self.locationManager = nil;
	self.locationMessage = nil;
	self.geocoder = nil;
	self.placemark = nil;
	self.locationStartDate = nil;

    self.apartmentNumber = nil;
    self.streetNumber = nil;
    self.street = nil;
    self.city = nil;
    self.state = nil;
	self.delegate = nil;
	
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)resignAllFirstResponders
{
	for(UITextField *textField in self.allTextFields)
	{
		[textField resignFirstResponder];
	}
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
	[self resignAllFirstResponders];
}

- (void)navigationControlDone:(id)sender 
{
	VERBOSE(NSLog(@"navigationControlDone:");)
	// go through the notes and make them resign the first responder
	[self resignAllFirstResponders];

	if(self.streetNumber == nil)
		self.streetNumber = @"";
	if(self.apartmentNumber == nil)
		self.apartmentNumber = @"";
	if(self.street == nil)
		self.street = @"";
	if(self.city == nil)
		self.city = @"";
	if(self.state == nil)
		self.state = @"";
	
	MTSettings *settings = [MTSettings settings];
	settings.lastHouseNumber = self.streetNumber;
	settings.lastApartmentNumber = self.apartmentNumber;
	settings.lastStreet = self.street;
	settings.lastCity = self.city;
	settings.lastState = self.state;

	if(delegate)
	{
		[delegate addressViewControllerDone:self];
	}

	[[self navigationController] popViewControllerAnimated:YES];
}


- (void)labelCellController:(PSLabelCellController *)labelCellController tableView:(UITableView *)tableView lookupAddressSelectedAtIndexPath:(NSIndexPath *)indexPath
{
	showReverseGeocoding = NO;
	wasShowingReverseGeocoding = YES;
	
	self.locationStartDate = [NSDate date];
	self.locationManager = [[[CLLocationManager alloc] init] autorelease];
	self.locationManager.delegate = self; // Tells the location manager to send updates to this object
	self.locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
	[self.locationManager startUpdatingLocation];
	
	self.locationMessage = [[[UIAlertView alloc] initWithTitle:nil
													   message:NSLocalizedString(@"Looking up your position with Location Services", @"This is the first message you see when you make a new Call -> press on the address -> press on automatically lookup address") 
													  delegate:self 
											 cancelButtonTitle:NSLocalizedString(@"Cancel", @"Cancel button") 
											 otherButtonTitles:nil] autorelease];
	[self.locationMessage setOpaque:NO];
	[self.locationMessage show];
	
	[self resignAllFirstResponders ];
//	[tableView deselectRowAtIndexPath:indexPath animated:YES];
//	[tableView deleteSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];

	[self updateWithoutReload];
}


- (void)constructSectionControllers
{
	[super constructSectionControllers];
	
	{
		AddressGeocacheSectionController *sectionController = [[AddressGeocacheSectionController alloc] init];
		sectionController.delegate = self;
		[self.sectionControllers addObject:sectionController];
		[sectionController release];
		
		PSLabelCellController *cellController = [[[PSLabelCellController alloc] init] autorelease];
		cellController.textAlignment = UITextAlignmentCenter;
		cellController.title = NSLocalizedString(@"Automatically Lookup Address", @"This is a button you see when you create a new call and go to the address view for the first time, it allows the user to use google to lookup the address by the current location");
		[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:lookupAddressSelectedAtIndexPath:)];
		[self addCellController:cellController toSection:sectionController];
	}
	{
		AddressSectionController *sectionController = [[AddressSectionController alloc] init];
		[self.sectionControllers addObject:sectionController];
		[sectionController release];
		// house and apartment number
		{
			PSMultiTextFieldCellController *cellController = [[[PSMultiTextFieldCellController alloc] initWithTextFieldCount:2] autorelease];
			PSMultiTextFieldConfiguration *houseNumberConfig = [cellController.textFieldConfigurations objectAtIndex:0];
			PSMultiTextFieldConfiguration *apartmentNumberConfig = [cellController.textFieldConfigurations objectAtIndex:1];
			houseNumberConfig.model = self;
			houseNumberConfig.modelPath = @"streetNumber";
			houseNumberConfig.placeholder = NSLocalizedString(@"House Number", @"House Number");
			houseNumberConfig.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
			houseNumberConfig.autocorrectionType = UITextAutocorrectionTypeNo;
			houseNumberConfig.returnKeyType = UIReturnKeyNext;
			houseNumberConfig.clearButtonMode = UITextFieldViewModeAlways;
			houseNumberConfig.obtainFocus = self.obtainFocus;
			houseNumberConfig.widthPercentage = 0.55;
			self.obtainFocus = NO;

			
			apartmentNumberConfig.model = self;
			apartmentNumberConfig.modelPath = @"apartmentNumber";
			apartmentNumberConfig.placeholder = NSLocalizedString(@"Apt/Floor", @"Apartment/Floor Number");
			apartmentNumberConfig.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
			apartmentNumberConfig.autocorrectionType = UITextAutocorrectionTypeNo;
			apartmentNumberConfig.returnKeyType = UIReturnKeyNext;
			apartmentNumberConfig.clearButtonMode = UITextFieldViewModeAlways;
			apartmentNumberConfig.widthPercentage = 0.45;
			
			cellController.selectionStyle = UITableViewCellSelectionStyleNone;
			cellController.selectNextRowResponderIncrement = 1;
			cellController.allTextFields = self.allTextFields;
			cellController.scrollPosition = UITableViewScrollPositionMiddle;
			[self addCellController:cellController toSection:sectionController];
		}	
		
		{
			// Street Name
			PSTextFieldCellController *cellController = [[[PSTextFieldCellController alloc] init] autorelease];
			cellController.model = self;
			cellController.modelPath = @"street";
			cellController.placeholder = NSLocalizedString(@"Street", @"Street");
			cellController.returnKeyType = UIReturnKeyNext;
			cellController.clearButtonMode = UITextFieldViewModeAlways;
			cellController.autocapitalizationType = UITextAutocapitalizationTypeWords;
			cellController.selectionStyle = UITableViewCellSelectionStyleNone;
			cellController.selectNextRowResponderIncrement = 1;
			cellController.allTextFields = self.allTextFields;
			cellController.scrollPosition = UITableViewScrollPositionMiddle;
			[self addCellController:cellController toSection:sectionController];
		}
		
		{
			// City
			PSTextFieldCellController *cellController = [[[PSTextFieldCellController alloc] init] autorelease];
			cellController.model = self;
			cellController.modelPath = @"city";
			cellController.placeholder = NSLocalizedString(@"City", @"City");
			cellController.returnKeyType = UIReturnKeyNext;
			cellController.clearButtonMode = UITextFieldViewModeAlways;
			cellController.autocapitalizationType = UITextAutocapitalizationTypeWords;
			cellController.selectionStyle = UITableViewCellSelectionStyleNone;
			cellController.selectNextRowResponderIncrement = 1;
			cellController.allTextFields = self.allTextFields;
			cellController.scrollPosition = UITableViewScrollPositionMiddle;
			[self addCellController:cellController toSection:sectionController];
		}
		
		{
			// State
			PSTextFieldCellController *cellController = [[[PSTextFieldCellController alloc] init] autorelease];
			cellController.model = self;
			cellController.modelPath = @"state";
			cellController.placeholder = NSLocalizedString(@"State or Country", @"State or Country");
			cellController.returnKeyType = UIReturnKeyDone;
			cellController.clearButtonMode = UITextFieldViewModeAlways;
			cellController.autocapitalizationType = UITextAutocapitalizationTypeWords;
			cellController.selectionStyle = UITableViewCellSelectionStyleNone;
			cellController.scrollPosition = UITableViewScrollPositionMiddle;
			// if the localization does not capitalize the state, then just leave it default to capitalize the first letter
			if([NSLocalizedStringWithDefaultValue(@"State in all caps", @"", [NSBundle mainBundle], @"1", @"Set this to 1 if your country abbreviates the state in all capital letters, otherwise set this to 0") isEqualToString:@"1"])
			{
				cellController.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
				cellController.autocorrectionType = UITextAutocorrectionTypeNo;
			}
			cellController.allTextFields = self.allTextFields;
			cellController.nextRowResponder = [[[SaveAndDone alloc] initWithAddressViewController:self] autorelease];
			[self addCellController:cellController toSection:sectionController];
		}
	}	
	
}	

- (void)loadView 
{
	[super loadView];
	
	// add DONE button
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(navigationControlDone:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:NO];
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFailWithError:(NSError *)error
{
	self.geocoder.delegate = nil;
	self.geocoder = nil;

	self.locationMessage.message = NSLocalizedString(@"Error acquiring location, reverse lookup failed", @"This is a message you see when you make a new Call -> press on the address -> press on automatically lookup address, and there is a geolocation error (the google lookup of the address failed)");
}

- (void)reverseGeocoder:(MKReverseGeocoder *)geocoder didFindPlacemark:(MKPlacemark *)thePlacemark
{
	[self.locationMessage dismissWithClickedButtonIndex:-1 animated:NO];
	self.locationManager.delegate = nil;
	self.locationManager = nil;

	self.placemark = thePlacemark;
	NSString *houseNumber = [placemark subThoroughfare];
	NSString *streetName = [placemark thoroughfare];
	NSString *cityName = [placemark locality];
	if(cityName == nil)
		cityName = [[[placemark addressDictionary] objectForKey:@"FormattedAddressLines"] objectAtIndex:1];
	NSString *stateName = [placemark administrativeArea];
	if(stateName == nil)
		stateName = [placemark country];

	NSString *topLine = [MTCall topLineOfAddressWithHouseNumber:houseNumber apartmentNumber:nil street:streetName];

	self.locationMessage = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Would you like to use this address?", @"This is a success message you see when you make a new Call -> press on the address -> press on automatically lookup address")
													   message:[NSString stringWithFormat:@"%@\n%@\n%@",
																		topLine,
																		cityName,
																		stateName] 
													  delegate:self
											 cancelButtonTitle:NSLocalizedString(@"No", @"No button title")
											 otherButtonTitles:NSLocalizedString(@"Yes", @"Yes button title"), nil] autorelease];
	[self.locationMessage show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
	if(self.geocoder == nil)
	{
		if([self.locationStartDate earlierDate:newLocation.timestamp] == newLocation.timestamp)
		{
			// we have a stale location, try again
			return;
		}
		int accuracy = MAX(newLocation.horizontalAccuracy, newLocation.verticalAccuracy);
//#warning DONT PUT THIS IN PRODUCTION CODE
//accuracy = 0;
		if(accuracy > REVERSE_GEOCODING_ACCURACY)
		{
			self.locationMessage.message = [NSString stringWithFormat:NSLocalizedString(@"Looking up position, current accuracy is %dm", @"This is a message you see when you make a new Call -> press on the address -> press on automatically lookup address, and geolocation is having a hard time getting accurate results"), accuracy];
			return;
		}
		
		self.locationStartDate = nil;
//#warning DONT PUT THIS IN PRODUCTION CODE
//newLocation = [[[CLLocation alloc] initWithLatitude:57.6689616 longitude:11.9303895] autorelease];
		self.geocoder = [[[MKReverseGeocoder alloc] initWithCoordinate:newLocation.coordinate] autorelease];
		self.geocoder.delegate = self;
		[self.geocoder start];
	}
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
	switch([error code])
	{
		case kCLErrorLocationUnknown:
		{
			int accuracy = MAX(self.locationManager.location.horizontalAccuracy, self.locationManager.location.verticalAccuracy);
			if(accuracy >= 0)
			{
				self.locationMessage.message = [NSString stringWithFormat:NSLocalizedString(@"Looking up position, current accuracy is %dm", @"This is a message you see when you make a new Call -> press on the address -> press on automatically lookup address, and geolocation is having a hard time getting accurate results"), accuracy];
			}
			else
			{
				self.locationMessage.message = [NSString stringWithFormat:NSLocalizedString(@"Error: Location Services can not find your location.", @"This is a message you see when you make a new Call -> press on the address -> press on automatically lookup address, and the location services can not obtain a location (could happen for iPod or iPhone with only wifi turned on and location cant be determined by wifi)"), accuracy];
			}

			break;
		}
		case kCLErrorDenied:
		{
			[self alertViewCancel:self.locationMessage];
			break;
		}
	}
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	if(buttonIndex == 0)
	{
		self.placemark = nil;
		self.geocoder = nil;
		[self alertViewCancel:alertView];
		return;
	}
	if(self.geocoder)
	{
		shouldAskAboutReverseGeocoding = NO;
		self.streetNumber = [self.placemark subThoroughfare];
		self.street = [self.placemark thoroughfare];
		NSString *cityName = [placemark locality];
		if(cityName == nil)
			cityName = [[[placemark addressDictionary] objectForKey:@"FormattedAddressLines"] objectAtIndex:1];
		NSString *stateName = [placemark administrativeArea];
		if(stateName == nil)
			stateName = [placemark country];
		
		self.city = cityName;
		self.state = stateName;
		
		self.geocoder = nil;
		self.placemark = nil;
		[self updateAndReload];
	}
}

- (void)alertViewCancel:(UIAlertView *)alertView
{
	[self.locationMessage dismissWithClickedButtonIndex:0 animated:YES];
	self.locationManager.delegate = nil;
	self.locationManager = nil;
	self.locationMessage = nil;
	self.locationStartDate = nil;
	self.geocoder = nil;
	self.placemark = nil;
	
	if(wasShowingReverseGeocoding)
	{
		showReverseGeocoding = shouldAskAboutReverseGeocoding && [CLLocationManager psLocationServicesEnabled];
		wasShowingReverseGeocoding = NO;
		if(showReverseGeocoding)
		{
			//[self.theTableView insertSections:[NSIndexSet indexSetWithIndex:0] withRowAnimation:UITableViewRowAnimationFade];
			[self updateWithoutReload];
		}
		
//		[[self.streetNumberAndApartmentCell textFieldAtIndex:0] performSelector:@selector(becomeFirstResponder) withObject:nil afterDelay:0];
	}
}
@end






