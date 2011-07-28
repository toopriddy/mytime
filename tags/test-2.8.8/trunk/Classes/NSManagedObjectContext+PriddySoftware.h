//
//  NSManagedObjectContext+PriddySoftware.h
//  MyTime
//
//  Created by Brent Priddy on 5/28/10.
//  Copyright 2010 Priddy Software, LLC. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObjectContext(PriddySoftware)
- (NSArray *)fetchObjectsForEntityName:(NSString *)newEntityName
						 withPredicate:(id)stringOrPredicate, ...;

@end