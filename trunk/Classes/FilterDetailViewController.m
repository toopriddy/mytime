//
//  FilterDetailViewController.m
//  MyTime
//
//  Created by Brent Priddy on 1/30/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import "FilterDetailViewController.h"
#import "PSLabelCellController.h"
#import "PSSwitchCellController.h"
#import "FilterDetailViewController.h"
#import "TableViewCellController.h"
#import "GenericTableViewSectionController.h"
#import "PSLabelCellController.h"
#import "PSCheckmarkCellController.h"
#import "PSDateCellController.h"
#import "MTFilter.h"
#import "NSManagedObjectContext+PriddySoftware.h"
#import "PSTextFieldCellController.h"
#import "PSLocalization.h"
#import "FilterTableViewController.h"

@implementation FilterDetailViewController
@synthesize delegate;
@synthesize filter;
@synthesize selectedIndexPath;
@synthesize allTextFields;

- (id) initWithFilter:(MTFilter *)theFilter newFilter:(BOOL)newFilter
{
	if ([super initWithStyle:UITableViewStyleGrouped]) 
	{
		// set the title, and tab bar images from the dataSource
		// object. 
		self.title = NSLocalizedString(@"Edit Sort Rule", @"Sort Rules View title");
		self.filter = theFilter;
		self.hidesBottomBarWhenPushed = YES;
		self.allTextFields = [NSMutableArray array];
	}
	return self;
}

- (void)dealloc 
{
	self.filter = nil;
	self.selectedIndexPath = nil;
	self.allTextFields = nil;
		
	[super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}


- (void)navigationControlDone:(id)sender 
{
	if(self.delegate && [self.delegate respondsToSelector:@selector(filterViewControllerDone:)])
	{
		[self.delegate filterViewControllerDone:self];
	}
}	

- (void)loadView 
{
	[super loadView];
	self.editing = self.filter.listValue;

	[self.navigationItem setHidesBackButton:YES animated:YES];
	// update the button in the nav bar
	UIBarButtonItem *button = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
																			 target:self
																			 action:@selector(navigationControlDone:)] autorelease];
	[self.navigationItem setRightBarButtonItem:button animated:YES];
}

- (void)labelCellController:(PSLabelCellController *)labelCellController tableView:(UITableView *)tableView sortSelectedAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *entry = (NSDictionary *)labelCellController.userData;
	[[self.navigationItem rightBarButtonItem] setEnabled:YES];
	self.filter.name = [entry objectForKey:MTFilterEntryName];
	self.filter.path = [entry objectForKey:MTFilterEntryPath];
	
	if(self.selectedIndexPath)
	{
		[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:self.selectedIndexPath] withRowAnimation:UITableViewRowAnimationNone];
	}
	
	self.selectedIndexPath = indexPath;
}

- (FilterTableViewController *)filterTableViewController
{
	if(filterTableViewController_ == nil)
	{
		filterTableViewController_ = [FilterTableViewController alloc];
		filterTableViewController_.filter = self.filter;
		filterTableViewController_.managedObjectContext = self.filter.managedObjectContext;
	}
	return filterTableViewController_;
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

- (void)constructSectionControllers
{
	[super constructSectionControllers];

	self.title = self.filter.title;
	if(self.filter.listValue)
	{
		// Filters
		[self.filterTableViewController constructSectionControllersForTableViewController:self];
	}
	else
	{
		NSDictionary *foundEntry = nil;
		for(NSDictionary *group in [MTFilter displayEntriesForEntityName:self.filter.filterEntityName])
		{
			for(NSDictionary *entry in [group objectForKey:MTFilterGroupArray])
			{
				if([[entry objectForKey:MTFilterEntryPath] isEqualToString:self.filter.path])
				{
					foundEntry = entry;
					break;
				}
			}
		}
#warning make sure you set the selectedIndexPath		
		if(foundEntry)
		{
			switch([self.filter typeForPath])
			{
				default:
				case NSUndefinedAttributeType:
				case NSInteger16AttributeType:
				case NSInteger32AttributeType:
				case NSInteger64AttributeType:
				case NSDecimalAttributeType:
				case NSDoubleAttributeType:
				case NSFloatAttributeType:
				{
					{

						GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
						[self.sectionControllers addObject:sectionController];
						[sectionController release];

						PSTextFieldCellController *cellController = [[[PSTextFieldCellController alloc] init] autorelease];
						cellController.model = self.filter;
						cellController.modelPath = @"value";
						cellController.placeholder = NSLocalizedString(@"Value", @"This is the placeholder text in the Display Rule detail screen where you name the display rule");
						cellController.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
						cellController.returnKeyType = UIReturnKeyDone;
						cellController.clearButtonMode = UITextFieldViewModeAlways;
						cellController.autocapitalizationType = UITextAutocapitalizationTypeNone;
						cellController.selectionStyle = UITableViewCellSelectionStyleNone;
						cellController.allTextFields = self.allTextFields;
						cellController.indentWhileEditing = NO;
					}
					{
						GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
						[self.sectionControllers addObject:sectionController];
						[sectionController release];

						{
							PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
							cellController.title = NSLocalizedString(@"Equals", @"Title for switch in the filter for the number operator");
							cellController.model = self.filter;
							cellController.modelPath = @"operator";
							cellController.checkedValue = @"==";
							[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:sortSelectedAtIndexPath:)];
							[self addCellController:cellController toSection:sectionController];
						}
						
						{
							PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
							cellController.title = NSLocalizedString(@"Greater Than or Equals", @"Title for switch in the filter for the number operator");
							cellController.model = self.filter;
							cellController.modelPath = @"operator";
							cellController.checkedValue = @">=";
							[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:sortSelectedAtIndexPath:)];
							[self addCellController:cellController toSection:sectionController];
						}
						
						{
							PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
							cellController.title = NSLocalizedString(@"Less Than or Equals", @"Title for switch in the filter for the number operator");
							cellController.model = self.filter;
							cellController.modelPath = @"operator";
							cellController.checkedValue = @"<=";
							[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:sortSelectedAtIndexPath:)];
							[self addCellController:cellController toSection:sectionController];
						}
						
						{
							PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
							cellController.title = NSLocalizedString(@"Greater Than", @"Title for switch in the filter for the number operator");
							cellController.model = self.filter;
							cellController.modelPath = @"operator";
							cellController.checkedValue = @">";
							[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:sortSelectedAtIndexPath:)];
							[self addCellController:cellController toSection:sectionController];
						}
						
						{
							PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
							cellController.title = NSLocalizedString(@"Less Than", @"Title for switch in the filter for the number operator");
							cellController.model = self.filter;
							cellController.modelPath = @"operator";
							cellController.checkedValue = @"<";
							[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:sortSelectedAtIndexPath:)];
							[self addCellController:cellController toSection:sectionController];
						}
					}						
					break;
				}

				case NSStringAttributeType:
				{
					{
						
						GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
						[self.sectionControllers addObject:sectionController];
						[sectionController release];
						
						PSTextFieldCellController *cellController = [[[PSTextFieldCellController alloc] init] autorelease];
						cellController.model = self.filter;
						cellController.modelPath = @"value";
						cellController.placeholder = NSLocalizedString(@"Value", @"This is the placeholder text in the Display Rule detail screen where you name the display rule");
						cellController.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
						cellController.returnKeyType = UIReturnKeyDone;
						cellController.clearButtonMode = UITextFieldViewModeAlways;
						cellController.autocapitalizationType = UITextAutocapitalizationTypeNone;
						cellController.selectionStyle = UITableViewCellSelectionStyleNone;
						cellController.allTextFields = self.allTextFields;
						cellController.indentWhileEditing = NO;
						[self addCellController:cellController toSection:sectionController];
					}
					{
						GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
						[self.sectionControllers addObject:sectionController];
						[sectionController release];
						
						{
							PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
							cellController.title = NSLocalizedString(@"Equals", @"Title for switch in the filter for the strings operator");
							cellController.model = self.filter;
							cellController.modelPath = @"operator";
							cellController.checkedValue = @"LIKE";
							[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:sortSelectedAtIndexPath:)];
							[self addCellController:cellController toSection:sectionController];
						}
						
						{
							PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
							cellController.title = NSLocalizedString(@"Contains", @"Title for switch in the filter for the strings operator");
							cellController.model = self.filter;
							cellController.modelPath = @"operator";
							cellController.checkedValue = @"CONTAINS";
							[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:sortSelectedAtIndexPath:)];
							[self addCellController:cellController toSection:sectionController];
						}
						
						{
							PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
							cellController.title = NSLocalizedString(@"Begins With", @"Title for switch in the filter for the strings operator");
							cellController.model = self.filter;
							cellController.modelPath = @"operator";
							cellController.checkedValue = @"BEGINSWITH";
							[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:sortSelectedAtIndexPath:)];
							[self addCellController:cellController toSection:sectionController];
						}
						
						{
							PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
							cellController.title = NSLocalizedString(@"Ends With", @"Title for switch in the filter for the strings operator");
							cellController.model = self.filter;
							cellController.modelPath = @"operator";
							cellController.checkedValue = @"ENDSWITH";
							[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:sortSelectedAtIndexPath:)];
							[self addCellController:cellController toSection:sectionController];
						}
						
						{
							PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
							cellController.title = NSLocalizedString(@"Ends With", @"Title for switch in the filter for the strings operator");
							cellController.model = self.filter;
							cellController.modelPath = @"operator";
							cellController.checkedValue = @"ENDSWITH";
							[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:sortSelectedAtIndexPath:)];
							[self addCellController:cellController toSection:sectionController];
						}
						
						{
							PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
							cellController.title = NSLocalizedString(@"Regular Expression Match", @"Title for switch in the filter for the strings operator");
							cellController.model = self.filter;
							cellController.modelPath = @"operator";
							cellController.checkedValue = @"MATCHES";
							[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:sortSelectedAtIndexPath:)];
							[self addCellController:cellController toSection:sectionController];
						}
					}						
					{
						GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
						[self.sectionControllers addObject:sectionController];
						[sectionController release];
						
						{
							PSSwitchCellController *cellController = [[[PSSwitchCellController alloc] init] autorelease];
							cellController.title = NSLocalizedString(@"Case Sensitive", @"Title for switch in the filter view to have the strings be compared in a case sensitive manor");
							cellController.model = self.filter;
							cellController.modelPath = @"caseSensitive";
							[self addCellController:cellController toSection:sectionController];
						}
						{
							PSSwitchCellController *cellController = [[[PSSwitchCellController alloc] init] autorelease];
							cellController.title = NSLocalizedString(@"Diacritic Sensitive", @"Title for switch in the filter view to have the strings be compared in a diacritic sensitive manor");
							cellController.model = self.filter;
							cellController.modelPath = @"diacriticSensitive";
							[self addCellController:cellController toSection:sectionController];
						}
					}
					break;
				}
				case NSBooleanAttributeType:
				{
					GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
					[self.sectionControllers addObject:sectionController];
					[sectionController release];
					
					{
						PSSwitchCellController *cellController = [[[PSSwitchCellController alloc] init] autorelease];
						cellController.title = NSLocalizedString(@"Match With", @"Title for switch in the filter view to match the switch value");
						cellController.model = self.filter;
						cellController.modelPath = @"caseSensitive";
						[self addCellController:cellController toSection:sectionController];
					}
					break;
				}
				case NSDateAttributeType:
				{
					{
						
						GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
						[self.sectionControllers addObject:sectionController];
						[sectionController release];

						PSDateCellController *cellController = [[PSDateCellController alloc] init];
						cellController.model = self.filter;
						cellController.modelPath = @"value";
						cellController.title = NSLocalizedString(@"Value", @"Label for filter view for the date value to match with");
						cellController.datePickerMode = UIDatePickerModeDate;
						if([[[NSLocale currentLocale] localeIdentifier] isEqualToString:@"en_GB"])
						{
							[cellController setDateFormat:@"d/M/yyy"];
						}
						else
						{
							[cellController setDateFormat:NSLocalizedString(@"M/d/yyy", @"localized date string string using http://unicode.org/reports/tr35/tr35-4.html#Date_Format_Patterns as a guide to how to format the date")];
						}
						
						[self addCellController:cellController toSection:sectionController];
					}
					{
						GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
						[self.sectionControllers addObject:sectionController];
						[sectionController release];
						
						{
							PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
							cellController.title = NSLocalizedString(@"Equals", @"Title for switch in the filter for the number operator");
							cellController.model = self.filter;
							cellController.modelPath = @"operator";
							cellController.checkedValue = @"==";
							[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:sortSelectedAtIndexPath:)];
							[self addCellController:cellController toSection:sectionController];
						}
						
						{
							PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
							cellController.title = NSLocalizedString(@"Greater Than or Equals", @"Title for switch in the filter for the number operator");
							cellController.model = self.filter;
							cellController.modelPath = @"operator";
							cellController.checkedValue = @">=";
							[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:sortSelectedAtIndexPath:)];
							[self addCellController:cellController toSection:sectionController];
						}
						
						{
							PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
							cellController.title = NSLocalizedString(@"Less Than or Equals", @"Title for switch in the filter for the number operator");
							cellController.model = self.filter;
							cellController.modelPath = @"operator";
							cellController.checkedValue = @"<=";
							[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:sortSelectedAtIndexPath:)];
							[self addCellController:cellController toSection:sectionController];
						}
						
						{
							PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
							cellController.title = NSLocalizedString(@"Greater Than", @"Title for switch in the filter for the number operator");
							cellController.model = self.filter;
							cellController.modelPath = @"operator";
							cellController.checkedValue = @">";
							[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:sortSelectedAtIndexPath:)];
							[self addCellController:cellController toSection:sectionController];
						}
						
						{
							PSCheckmarkCellController *cellController = [[[PSCheckmarkCellController alloc] init] autorelease];
							cellController.title = NSLocalizedString(@"Less Than", @"Title for switch in the filter for the number operator");
							cellController.model = self.filter;
							cellController.modelPath = @"operator";
							cellController.checkedValue = @"<";
							[cellController setSelectionTarget:self action:@selector(labelCellController:tableView:sortSelectedAtIndexPath:)];
							[self addCellController:cellController toSection:sectionController];
						}
					}						
					break;
				}
			}
			
			{
				GenericTableViewSectionController *sectionController = [[GenericTableViewSectionController alloc] init];
				[self.sectionControllers addObject:sectionController];
				[sectionController release];
				
				PSSwitchCellController *cellController = [[[PSSwitchCellController alloc] init] autorelease];
				cellController.title = NSLocalizedString(@"Invert Logic", @"Title for switch in the filter view to change the logical result of the filter to the logical alternate value TRUE->FALSE or FALSE->TRUE");
				cellController.model = self.filter;
				cellController.modelPath = @"not";
				[self addCellController:cellController toSection:sectionController];
			}
			
		}
	}

	
	
	[[self.navigationItem rightBarButtonItem] setEnabled:self.selectedIndexPath != nil];
}

@end


#if 0
// String
// 		Value

// 		Equals
// 		Contains
// 		Starts With
// 		Ends with
//      MATCHES regular expression

//		not
//		case sensitive
//		diacritic sensitive

// NUMBER
//		Value

//		Equals
//		Less Than
//      Greater Than
//		Less Than or Equal To
//		Greater Than or Equal To

//		not

// BOOLEAN
//		Value

//		ON
//		OFF

//		not

#endif
