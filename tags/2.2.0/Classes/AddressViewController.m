//
//  AddressViewController.m
//  MyTime
//
//  Created by Brent Priddy on 7/26/08.
//  Copyright 2008 Priddy Software, LLC. All rights reserved.
//

#import "AddressViewController.h"
#import "Settings.h"
#import "UITableViewTextFieldCell.h"



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


@implementation AddressViewController

@synthesize delegate;
@synthesize theTableView;
@synthesize apartmentNumber;
@synthesize streetNumber;
@synthesize street;
@synthesize city;
@synthesize state;
@synthesize streetCell;
@synthesize cityCell;
@synthesize stateCell;
@synthesize streetNumberAndApartmentCell;


- (id)init
{
    return([self initWithStreetNumber:@"" apartment:@"" street:@"" city:@"" state:@""]);
}

- (id) initWithStreetNumber:(NSString *)theStreetNumber apartment:(NSString *)apartment street:(NSString *)theStreet city:(NSString *)theCity state:(NSString *)theState;
{
	if ([super init]) 
	{
		theTableView = nil;
		delegate = nil;
		
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = NSLocalizedString(@"Call Address", @"Address title for address form");
		self.tabBarItem.image = [UIImage imageNamed:@"statistics.png"];

		self.streetNumber = theStreetNumber;
		self.apartmentNumber = apartment;
		self.street = theStreet;
		self.city = theCity;
		self.state = theState;
	}
	return self;
}

- (void)dealloc 
{
	self.theTableView.delegate = nil;
	self.theTableView.dataSource = nil;

	self.theTableView = nil;

    self.streetNumberAndApartmentCell = nil;
    self.streetCell = nil;
    self.cityCell = nil;
    self.stateCell = nil;

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

- (void)navigationControlDone:(id)sender 
{
	VERBOSE(NSLog(@"navigationControlDone:");)
	// go through the notes and make them resign the first responder
	[theTableView deselectRowAtIndexPath:[theTableView indexPathForSelectedRow] animated:YES];
	self.streetNumber = [streetNumberAndApartmentCell textFieldAtIndex:0].text;
	self.apartmentNumber = [streetNumberAndApartmentCell textFieldAtIndex:1].text;
	self.street = streetCell.textField.text;
	self.city = cityCell.textField.text;
	self.state = stateCell.textField.text;
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
	NSMutableDictionary *settings = [[Settings sharedInstance] settings];

	[settings setObject:self.streetNumber forKey:SettingsLastCallStreetNumber];
	[settings setObject:self.apartmentNumber forKey:SettingsLastCallApartmentNumber];
	[settings setObject:self.street forKey:SettingsLastCallStreet];
	[settings setObject:self.street forKey:SettingsLastCallStreet];
	[settings setObject:self.city forKey:SettingsLastCallCity];
	[settings setObject:self.state forKey:SettingsLastCallState];

	if(delegate)
	{
		[delegate addressViewControllerDone:self];
	}

	[[self navigationController] popViewControllerAnimated:YES];
}

- (void)loadView 
{
	// create a new table using the full application frame
	// we'll ask the datasource which type of table to use (plain or grouped)
	self.theTableView = [[[UITableView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame] 
													  style:UITableViewStyleGrouped] autorelease];
	
	// alow the loupe to work within text fields
//	theTableView.scrollEnabled = NO;
	// set the autoresizing mask so that the table will always fill the view
	theTableView.autoresizingMask = (UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight);
	
	// set the tableview delegate to this object and the datasource to the datasource which has already been set
	theTableView.delegate = self;
	theTableView.dataSource = self;
	
	// set the tableview as the controller view
	self.view = self.theTableView;

	self.streetNumberAndApartmentCell = [[[UITableViewMultiTextFieldCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"UITableViewMultiTextFieldCell" textFieldCount:2] autorelease];
	streetNumberAndApartmentCell.widths = [NSArray arrayWithObjects:[NSNumber numberWithFloat:.55], [NSNumber numberWithFloat:.45], nil];
	streetNumberAndApartmentCell.delegate = self;
	UITextField *streetTextField = [streetNumberAndApartmentCell textFieldAtIndex:0];
	UITextField *apartmentTextField = [streetNumberAndApartmentCell textFieldAtIndex:1];
	streetTextField.text = streetNumber;
	streetTextField.placeholder = NSLocalizedString(@"House Number", @"House Number");
	streetTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	streetTextField.autocorrectionType = UITextAutocorrectionTypeNo;
	streetTextField.returnKeyType = UIReturnKeyNext;
	streetTextField.clearButtonMode = UITextFieldViewModeAlways;
	
	apartmentTextField.text = apartmentNumber;
	apartmentTextField.placeholder = NSLocalizedString(@"Apt/Floor", @"Apartment/Floor Number");
	apartmentTextField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
	apartmentTextField.autocorrectionType = UITextAutocorrectionTypeNo;
	apartmentTextField.returnKeyType = UIReturnKeyNext;
	apartmentTextField.clearButtonMode = UITextFieldViewModeAlways;
	
	self.streetCell = [[[UITableViewTextFieldCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"UITableViewTextFieldCell"] autorelease];
	streetCell.textField.text = street;
	streetCell.textField.placeholder = NSLocalizedString(@"Street", @"Street");
	streetCell.textField.returnKeyType = UIReturnKeyNext;
	streetCell.textField.clearButtonMode = UITextFieldViewModeAlways;
	streetCell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
	streetCell.delegate = self;
	
	self.cityCell = [[[UITableViewTextFieldCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"UITableViewTextFieldCell"] autorelease];
	cityCell.textField.text = city;
	cityCell.textField.placeholder = NSLocalizedString(@"City", @"City");
	cityCell.textField.returnKeyType = UIReturnKeyNext;
	cityCell.textField.clearButtonMode = UITextFieldViewModeAlways;
	cityCell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
	cityCell.delegate = self;


	self.stateCell = [[[UITableViewTextFieldCell alloc] initWithFrame:CGRectZero reuseIdentifier:@"UITableViewTextFieldCell"] autorelease];
	stateCell.textField.text = state;
	stateCell.textField.placeholder = NSLocalizedString(@"State", @"State");
	stateCell.textField.returnKeyType = UIReturnKeyDone;
	stateCell.textField.clearButtonMode = UITextFieldViewModeAlways;
	stateCell.textField.autocapitalizationType = UITextAutocapitalizationTypeWords;
	stateCell.delegate = self;

	streetNumberAndApartmentCell.nextKeyboardResponder = streetCell.textField;
	streetCell.nextKeyboardResponder = cityCell.textField;
	cityCell.nextKeyboardResponder = stateCell.textField;
	stateCell.nextKeyboardResponder = [[[SaveAndDone alloc] initWithAddressViewController:self] autorelease];
	
	// if the localization does not capitalize the state, then just leave it default to capitalize the first letter
	if([NSLocalizedStringWithDefaultValue(@"State in all caps", @"", [NSBundle mainBundle], @"1", @"Set this to 1 if your country abbreviates the state in all capital letters, otherwise set this to 0") isEqualToString:@"1"])
	{
		stateCell.textField.autocapitalizationType = UITextAutocapitalizationTypeAllCharacters;
		stateCell.textField.autocorrectionType = UITextAutocorrectionTypeNo;
	}

	// add DONE button
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(navigationControlDone:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:NO];

	[self.theTableView reloadData];
}

-(void)viewWillAppear:(BOOL)animated
{
	// force the tableview to load
	[self.theTableView reloadData];

	[super viewWillAppear:animated];
}

- (void)viewDidLoad
{
	[self.theTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:NO scrollPosition:UITableViewScrollPositionTop];
}

// UITableViewDataSource methods

- (void)tableViewMultiTextFieldCell:(UITableViewMultiTextFieldCell *)cell textField:(UITextField *)textField selected:(BOOL)selected
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	if(selected)
	{
		if(cell == self.streetNumberAndApartmentCell)
		{
			[theTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
		}
	}
}

- (void)tableViewTextFieldCell:(UITableViewTextFieldCell *)cell selected:(BOOL)selected
{
    DEBUG(NSLog(@"%s: %s", __FILE__, __FUNCTION__);)
	if(selected)
	{
		if(cell == self.streetCell)
		{
			[theTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
		}
		else if(cell == self.cityCell)
		{
			[theTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
		}
		else if(cell == self.stateCell)
		{
			[theTableView selectRowAtIndexPath:[NSIndexPath indexPathForRow:3 inSection:0] animated:YES scrollPosition:UITableViewScrollPositionTop];
		}
	}
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView  
{
	return 1;
}


- (NSInteger)tableView:(UITableView *)tableView  numberOfRowsInSection:(NSInteger)section 
{
	return 4;
}


// make the footer be as tall as the keyboard is tall when we are in landscape mode.
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
	return 165;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
	UIView *view = [[[UIView alloc] init] autorelease];
	view.backgroundColor = [UIColor clearColor];
	
	return view;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	int row = [indexPath row];
	int section = [indexPath section];
    VERBOSE(NSLog(@"tableView: cellForRow:%d inSection:%d", row, section);)
    if(section == 0)
    {
        switch(row) 
        {
            // House Number
            case 0:
				return streetNumberAndApartmentCell;
            case 1:
				return streetCell;
            case 2:
				return cityCell;
            case 3:
				return stateCell;
        }
    }
	return(nil);
}


//
//
// UITableViewDelegate methods
//
//

// NONE

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






