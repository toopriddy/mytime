//
//  PSExtendedFetchedResultsController.m
//  MyTime
//
//  Created by Brent Priddy on 3/8/11.
//  Copyright 2011 Priddy Software, LLC. All rights reserved.
//

#import "PSExtendedFetchedResultsController.h"

@interface PSFetchedResultsSectionInfo : NSObject
{
}
/* Name of the section
 */
@property (nonatomic, copy) NSString *name;

/* Title of the section (used when displaying the index)
 */
@property (nonatomic, copy) NSString *indexTitle;

/* Number of objects in section
 */
@property (nonatomic, assign) NSUInteger numberOfObjects;

/* Returns the array of objects in the section.
 */
@property (nonatomic, retain) NSArray *objects;

@end // NSFetchedResultsSectionInfo
@implementation PSFetchedResultsSectionInfo
@synthesize name;
@synthesize indexTitle;
@synthesize numberOfObjects;
@synthesize objects;
@end


@interface  PSExtendedFetchedResultsController ()
@property (nonatomic, retain, readwrite) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, retain, readwrite) NSArray *fetchedObjects;
@property (nonatomic, retain, readwrite) NSArray *sectionIndexTitles;
@property (nonatomic, retain, readwrite) NSArray *sections;
@property (nonatomic, retain, readwrite) NSString *sectionNameKeyPath;
@end

@implementation PSExtendedFetchedResultsController
@synthesize delegate = _delegate;
@synthesize fetchedObjects = _fetchedObjects;
@synthesize sectionIndexTitles = _sectionIndexTitles;
@synthesize sections = _sections;
@synthesize fetchedResultsController;
@synthesize requiresArraySorting = _requiresArraySorting;
@synthesize sectionNameKeyPath;
@synthesize sortDescriptors;

/* ========================================================*/
/* ========================= INITIALIZERS ====================*/
/* ========================================================*/

- (void)dealloc
{
	self.fetchedResultsController.delegate = nil;
	self.fetchedResultsController = nil;
	[_sections release];
	[_sectionIndexTitles release];
	[_fetchedObjects release];
	self.sectionNameKeyPath = nil;

	[super dealloc];
}

/* Initializes an instance of NSFetchedResultsController
 fetchRequest - the fetch request used to get the objects. It's expected that the sort descriptor used in the request groups the objects into sections.
 context - the context that will hold the fetched objects
 sectionNameKeyPath - keypath on resulting objects that returns the section name. This will be used to pre-compute the section information.
 cacheName - Section info is cached persistently to a private file under this name. Cached sections are checked to see if the time stamp matches the store, but not if you have illegally mutated the readonly fetch request, predicate, or sort descriptor.
 */
- (id)initWithFetchRequest:(NSFetchRequest *)theFetchRequest 
	  managedObjectContext:(NSManagedObjectContext *)context 
		sectionNameKeyPath:(NSString *)theSectionNameKeyPath 
				 cacheName:(NSString *)name
		   sortDescriptors:(NSArray *)theSortDescriptors
{
	if( (self = [super init]) )
	{
		self.requiresArraySorting = theSortDescriptors != nil;
		self.sectionNameKeyPath = theSectionNameKeyPath;
		self.sortDescriptors = theSortDescriptors;
		if(self.requiresArraySorting)
			theSectionNameKeyPath = nil;
		self.fetchedResultsController = [[[NSFetchedResultsController alloc] initWithFetchRequest:theFetchRequest 
																			 managedObjectContext:context 
																			   sectionNameKeyPath:theSectionNameKeyPath 
																						cacheName:name] autorelease];
	}
	
	return self;
}

- (void)setDelegate:(NSObject<NSFetchedResultsControllerDelegate> *)delegate
{
	_delegate = delegate;
	if(_requiresArraySorting)
	{
		self.fetchedResultsController.delegate = self;
	}
	else
	{
		self.fetchedResultsController.delegate = delegate;
	}
}

- (NSArray *)fetchedObjects
{
	if(_requiresArraySorting)
	{
		if(_fetchedObjects == nil)
		{
			// get the objects and sort them
			self.fetchedObjects = [[self.fetchedResultsController fetchedObjects] sortedArrayUsingDescriptors:self.sortDescriptors];
			
			// figure out the sections, sectionIndexTitles
			PSFetchedResultsSectionInfo *sectionInfo = [[PSFetchedResultsSectionInfo alloc] init];
			sectionInfo.name = @"";
			sectionInfo.objects = self.fetchedObjects;
			sectionInfo.indexTitle = @"";
			sectionInfo.numberOfObjects = [sectionInfo.objects count];

// TODO: add code her to add the sections and section index titles
			self.sections = [NSArray arrayWithObject:sectionInfo];
		}
		return _fetchedObjects;
	}
	else
	{
		return [self.fetchedResultsController fetchedObjects];
	}
}

- (NSArray *)sections
{
	if(_sections)
	{
		__attribute__ ((unused)) NSArray *objects = self.fetchedObjects; // make sure that we have created the objects array
		return [[_sections retain] autorelease];
	}
	else
	{
		return [self.fetchedResultsController sections];
	}
}

- (NSArray *)sectionIndexTitles
{
	if(_sectionIndexTitles)
	{
		__attribute__ ((unused)) NSArray *objects = self.fetchedObjects; // make sure that we have created the objects array
		return [[_sectionIndexTitles retain] autorelease];
	}
	else
	{
		return [self.fetchedResultsController sectionIndexTitles];
	}
}

/* Executes the fetch request on the store to get objects.
 Returns YES if successful or NO (and an error) if a problem occurred. 
 An error is returned if the fetch request specified doesn't include a sort descriptor that uses sectionNameKeyPath.
 After executing this method, the fetched objects can be accessed with the property 'fetchedObjects'
 */
- (BOOL)performFetch:(NSError **)error
{
	return [self.fetchedResultsController performFetch:error];
}


/* Returns the fetched object at a given indexPath.
 */
- (id)objectAtIndexPath:(NSIndexPath *)indexPath
{
	if(_requiresArraySorting)
	{
		__attribute__ ((unused)) NSArray *objects = self.fetchedObjects; // make sure that we have created the objects array
		return [[[self.sections objectAtIndex:indexPath.section] objects] objectAtIndex:indexPath.row];
	}
	else
	{
		return [self.fetchedResultsController objectAtIndexPath:indexPath];
	}
}

/* Returns the indexPath of a given object.
 */
-(NSIndexPath *)indexPathForObject:(id)object
{
	if(_requiresArraySorting)
	{
		__attribute__ ((unused)) NSArray *objectsCache = self.fetchedObjects; // make sure that we have created the objects array
		int section = 0;
		for(NSArray *objects in self.sections)
		{
			int row = [objects indexOfObject:object];
			if(row != NSNotFound)
			{
				return [NSIndexPath indexPathForRow:row inSection:section];
			}
			++section;
		}
		return nil;
	}
	else
	{
		return [self.fetchedResultsController indexPathForObject:object];
	}
}

/* ========================================================*/
/* =========== CONFIGURING SECTION INFORMATION ============*/
/* ========================================================*/
/*	These are meant to be optionally overridden by developers.
 */

/* Returns the corresponding section index entry for a given section name.	
 Default implementation returns the capitalized first letter of the section name.
 Developers that need different behavior can implement the delegate method -(NSString*)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName
 Only needed if a section index is used.
 */
- (NSString *)sectionIndexTitleForSectionName:(NSString *)sectionName
{
	if(_requiresArraySorting)
	{
		if([_delegate respondsToSelector:@selector(sectionIndexTitleForSectionName:)])
		{
			return [_delegate controller:self.fetchedResultsController sectionIndexTitleForSectionName:sectionName];
		}

		for(PSFetchedResultsSectionInfo *info in self.sections)
		{
			if([info.name isEqualToString:sectionName])
			{
				return info.indexTitle;
			}
		}
		return [[sectionName substringToIndex:1] capitalizedString];
	}
	else
	{
		return [self.fetchedResultsController sectionIndexTitleForSectionName:sectionName];
	}
}


/* Returns the section number for a given section title and index in the section index.
 It's expected that developers call this method when executing UITableViewDataSource's
 - (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index;
 */
- (NSInteger)sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)sectionIndex
{
	if(_requiresArraySorting)
	{
		int section = 0;
		for(PSFetchedResultsSectionInfo *info in self.sections)
		{
			if([info.name isEqualToString:title])
			{
				return section;
			}
			++section;
		}
		return section;
	}
	else
	{
		return [self.fetchedResultsController sectionForSectionIndexTitle:title atIndex:sectionIndex];
	}
}

/* Notifies the delegate that a fetched object has been changed due to an add, remove, move, or update. Enables NSFetchedResultsController change tracking.
 controller - controller instance that noticed the change on its fetched objects
 anObject - changed object
 indexPath - indexPath of changed object (nil for inserts)
 type - indicates if the change was an insert, delete, move, or update
 newIndexPath - the destination path for inserted or moved objects, nil otherwise
 
 Changes are reported with the following heuristics:
 
 On Adds and Removes, only the Added/Removed object is reported. It's assumed that all objects that come after the affected object are also moved, but these moves are not reported. 
 The Move object is reported when the changed attribute on the object is one of the sort descriptors used in the fetch request.  An update of the object is assumed in this case, but no separate update message is sent to the delegate.
 The Update object is reported when an object's state changes, and the changed attributes aren't part of the sort keys. 
 */
- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
	if([_delegate respondsToSelector:@selector(controller:didChangeObject:atIndexPath:forChangeType:newIndexPath:)])
	{
		return [_delegate controller:controller didChangeObject:anObject atIndexPath:indexPath forChangeType:type newIndexPath:newIndexPath];
	}
#warning fix me
}

/* Notifies the delegate of added or removed sections.  Enables NSFetchedResultsController change tracking.
 
 controller - controller instance that noticed the change on its sections
 sectionInfo - changed section
 index - index of changed section
 type - indicates if the change was an insert or delete
 
 Changes on section info are reported before changes on fetchedObjects. 
 */
- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type
{
	if([_delegate respondsToSelector:@selector(controller:didChangeSection:atIndex:forChangeType:)])
	{
		return [_delegate controller:controller didChangeSection:sectionInfo atIndex:sectionIndex forChangeType:type];
	}
#warning fix me
}

/* Notifies the delegate that section and object changes are about to be processed and notifications will be sent.  Enables NSFetchedResultsController change tracking.
 Clients utilizing a UITableView may prepare for a batch of updates by responding to this method with -beginUpdates
 */
- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
	if([_delegate respondsToSelector:@selector(controllerWillChangeContent:)])
	{
		return [_delegate controllerWillChangeContent:controller];
	}
}

/* Notifies the delegate that all section and object changes have been sent. Enables NSFetchedResultsController change tracking.
 Providing an empty implementation will enable change tracking if you do not care about the individual callbacks.
 */
- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	if([_delegate respondsToSelector:@selector(controllerDidChangeContent:)])
	{
		return [_delegate controllerDidChangeContent:controller];
	}
}

/* Asks the delegate to return the corresponding section index entry for a given section name.	Does not enable NSFetchedResultsController change tracking.
 If this method isn't implemented by the delegate, the default implementation returns the capitalized first letter of the section name (seee NSFetchedResultsController sectionIndexTitleForSectionName:)
 Only needed if a section index is used.
 */
- (NSString *)controller:(NSFetchedResultsController *)controller sectionIndexTitleForSectionName:(NSString *)sectionName
{
	if([_delegate respondsToSelector:@selector(controller:sectionIndexTitleForSectionName:)])
	{
		return [_delegate controller:controller sectionIndexTitleForSectionName:sectionName];
	}
	
	return [[sectionName substringToIndex:1] capitalizedString];
}


@end
